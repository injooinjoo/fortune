// 운세 Edge Function 공통 과금 게이트.
//
// 배경: fortune-* 45개 중 서버에서 토큰을 차감하는 곳은 fortune-tarot 뿐이고
// 나머지는 RN 클라이언트가 soul-consume 을 따로 호출하는 것에 의존했다.
// 브라우저에서 Edge Function 을 직접 때리면 차감 없이 LLM 을 무한히 쓸 수 있는
// 구멍 → 서버가 직접 인증 + 차감하도록 단일 진입점으로 통합.
//
// 설계 포인트:
//  1. userId 는 JWT 에서만 파생. 'anonymous' fallback 금지 (게스트 = 401).
//  2. idempotency key 를 서버가 만든다. 클라가 키를 고정해 무료 재생성을
//     유도하지 못하도록 `user + fortuneType + 정규화된 body 해시 + 창 번호` 로 결정.
//  3. 같은 키가 fortune_result_cache 에 살아있으면 LLM 재호출 없이 그 결과를
//     그대로 돌려준다 — "키를 고정하면 공짜 생성" 구멍을 막는 핵심.
//  4. 키에 24h 창 번호를 넣는다. consume_token_atomic 은 같은 idempotency_key 를
//     영구히 replayed=true (무차감) 로 처리하는데, 캐시 row 는 TTL 로 사라진다.
//     창 번호가 없으면 "하루 지난 뒤 같은 body 재전송 = 캐시 미스 + 차감 replay
//     = 공짜 LLM" 이 영구히 성립한다. 창이 바뀌면 키도 바뀌므로 실제로 차감된다.

import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import { deriveUserIdFromJwt } from "./auth.ts";
import { corsHeaders } from "./cors.ts";
import { chargeTokens, refundTokens } from "./token_charge.ts";
import { getFortuneCostPoints } from "./fortune-pricing-generated.ts";
import { normalizeFortuneType } from "./types.ts";

/** 캐시 테이블명 — 마이그레이션 20260819100000_fortune_result_cache.sql */
const CACHE_TABLE = "fortune_result_cache";

/** token_transactions.reference_type — 운세 차감 공통 값. */
const REFERENCE_TYPE = "fortune";

/** 캐시 창 = 24h. 마이그레이션의 expires_at 기본값과 같은 길이. */
const WINDOW_MS = 24 * 60 * 60 * 1000;

/** 현재 창 번호 (epoch 기준 고정 24h 창). 키와 expires_at 이 같이 롤오버한다. */
function currentWindow(): number {
  return Math.floor(Date.now() / WINDOW_MS);
}

/**
 * 요청마다 달라지지만 "같은 논리적 요청" 여부와는 무관한 필드.
 * 해시에서 제외하지 않으면 클라가 nonce 하나만 바꿔 캐시를 우회할 수 있다.
 */
const DEFAULT_OMIT_KEYS = [
  "clientChargeId",
  "idempotencyKey",
  "requestId",
  "timestamp",
  "nonce",
];

/**
 * 응답 최상위에 실어 보내는 서버 차감 마커.
 *
 * 이게 없으면 RN 클라이언트가 **이중 과금**한다:
 * apps/mobile-rn/src/features/chat-results/edge-runtime.ts 가 응답의 최상위
 * `tokenCharge` 를 `payload.serverTokenCharge` 로 옮기고,
 * chat-screen.tsx:2179 의 `tokensConsumedForResult = Boolean(serverTokenCharge)`
 * 가 true 여야만 클라이언트가 자체 soul-consume 호출을 건너뛴다.
 * fortune-tarot(index.ts:731, 810)이 원래부터 쓰던 계약을 그대로 따른다.
 *
 * 이 방식이라 **앱 OTA 없이도** 서버 배포만으로 이중 과금이 사라진다.
 */
export interface ServerTokenChargeMarker {
  cost: number;
  balance: number | null;
  consumeTransactionId: string | null;
  /** 같은 24h 윈도우 안의 동일 요청 재생 — 추가 차감 없음. */
  replayed: boolean;
}

export interface PaidCallerOk {
  userId: string;
  idempotencyKey: string;
  replayed: false;
  /** 200 응답 최상위에 `tokenCharge` 로 그대로 넣는다. */
  tokenCharge: ServerTokenChargeMarker;
}

export interface PaidCallerReplay {
  userId: string;
  idempotencyKey: string;
  replayed: true;
  cached: unknown;
  /** replay 도 마커를 실어야 클라이언트가 중복 차감하지 않는다. */
  tokenCharge: ServerTokenChargeMarker;
}

/**
 * 캐시된 payload 에 최신 차감 마커를 붙여 응답 본문을 만든다.
 * 저장된 payload 에는 마커를 넣지 않는다 — balance 가 곧 낡기 때문.
 */
export function withTokenCharge(
  body: unknown,
  marker: ServerTokenChargeMarker,
): Record<string, unknown> {
  if (typeof body !== "object" || body === null || Array.isArray(body)) {
    // 응답 본문이 평범한 객체가 아니면 최상위 tokenCharge 를 붙일 자리가 없어
    // 감싸게 되고, 그 순간 클라이언트 계약(응답 shape)이 바뀐다.
    // 조용히 넘어가면 이중 과금 또는 파싱 실패로 나타나므로 반드시 로그를 남긴다.
    console.error(
      "[fortune_charge] withTokenCharge: 응답 본문이 객체가 아니다 — 응답 shape 가 변경됨. 해당 함수의 200 응답을 점검할 것.",
    );
    return { data: body, tokenCharge: marker };
  }
  return { ...(body as Record<string, unknown>), tokenCharge: marker };
}

export type PaidCallerResult =
  | PaidCallerOk
  | PaidCallerReplay
  | { error: Response };

export interface RequirePaidFortuneCallerOptions {
  /** 해시에서 제외할 volatile 필드. 기본값 DEFAULT_OMIT_KEYS. */
  omitKeys?: string[];
}

function jsonResponse(body: Record<string, unknown>, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

/**
 * 객체 키를 재귀적으로 정렬하고 undefined / volatile 필드를 제거한다.
 * 같은 논리적 요청이면 키 순서가 달라도 동일한 문자열이 나오도록 정규화.
 */
export function canonicalJson(value: unknown, omitKeys: string[]): string {
  const omit = new Set(omitKeys);

  const normalize = (input: unknown): unknown => {
    if (input === undefined) return undefined;
    if (input === null) return null;
    if (Array.isArray(input)) {
      return input.map((item) => (item === undefined ? null : normalize(item)));
    }
    if (typeof input === "object") {
      const source = input as Record<string, unknown>;
      const result: Record<string, unknown> = {};
      for (const key of Object.keys(source).sort()) {
        if (omit.has(key)) continue;
        const normalized = normalize(source[key]);
        if (normalized === undefined) continue;
        result[key] = normalized;
      }
      return result;
    }
    return input;
  };

  const normalized = normalize(value);
  return JSON.stringify(normalized === undefined ? null : normalized);
}

/** Web Crypto SHA-256 hex — Deno Deploy 에서 사용 가능. */
export async function sha256Hex(input: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(input),
  );
  return Array.from(new Uint8Array(digest))
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

/**
 * 인증 + 서버 주도 idempotency + 토큰 차감을 한 번에 처리한다.
 *
 * 반환:
 *  - { error }        → 그대로 return (401 인증 필요 / 402 토큰 부족)
 *  - { replayed:true } → cached 를 그대로 200 응답으로 반환 (LLM 재호출 금지)
 *  - { replayed:false } → 차감 완료. 생성 진행 후 storeFortuneResult 호출.
 *
 * 호출 위치: body 파싱 직후, 어떤 LLM/캐시 조회보다 먼저.
 */
export async function requirePaidFortuneCaller(
  req: Request,
  supabase: SupabaseClient,
  fortuneType: string,
  requestBody: unknown,
  options: RequirePaidFortuneCallerOptions = {},
): Promise<PaidCallerResult> {
  // 1) JWT 에서만 userId 파생. anon key bearer → null → 401.
  const userId = await deriveUserIdFromJwt(req);
  if (!userId) {
    return {
      error: jsonResponse({
        code: "AUTH_REQUIRED",
        message: "로그인이 필요합니다",
      }, 401),
    };
  }

  // 2) idempotency key 는 서버가 만든다. 클라가 고정할 수 없음.
  const normalizedType = normalizeFortuneType(fortuneType);
  const bodyHash = await sha256Hex(
    canonicalJson(requestBody, options.omitKeys ?? DEFAULT_OMIT_KEYS),
  );
  const idempotencyKey =
    `fortune:${userId}:${normalizedType}:${bodyHash}:${currentWindow()}`;

  const cost = getFortuneCostPoints(normalizedType);

  // 3) 살아있는 캐시가 있으면 재생성 없이 그대로 반환.
  const { data: cachedRow, error: cacheError } = await supabase
    .from(CACHE_TABLE)
    .select("payload")
    .eq("idempotency_key", idempotencyKey)
    .gt("expires_at", new Date().toISOString())
    .maybeSingle();

  if (cacheError) {
    // 캐시 조회 실패로 사용자 요청을 막지는 않는다 (차감 후 정상 생성).
    console.warn(
      `[fortune_charge] 캐시 조회 실패 (무시): ${cacheError.message}`,
    );
  } else if (cachedRow) {
    console.log(`[fortune_charge] 캐시 히트 — ${normalizedType} / ${userId}`);
    // replay 에도 마커가 필요하다. 없으면 클라이언트가 "서버가 안 걷었네" 로 보고
    // soul-consume 을 호출해 같은 윈도우 안에서 이중 과금한다.
    const { data: balanceRow } = await supabase
      .from("token_balance")
      .select("balance")
      .eq("user_id", userId)
      .maybeSingle();

    return {
      userId,
      idempotencyKey,
      replayed: true,
      cached: cachedRow.payload,
      tokenCharge: {
        cost,
        balance: (balanceRow?.balance as number | undefined) ?? null,
        consumeTransactionId: null,
        replayed: true,
      },
    };
  }

  // 4) 토큰 차감. 잔액 부족이면 402.
  const charge = await chargeTokens(supabase, userId, cost, {
    description: `${fortuneType} 운세`,
    referenceType: REFERENCE_TYPE,
    referenceId: idempotencyKey,
    idempotencyKey,
  });

  if (!charge.charged) {
    return {
      error: jsonResponse({
        code: "INSUFFICIENT_TOKENS",
        required: cost,
        available: charge.balanceAfter,
      }, 402),
    };
  }

  if (charge.replayed) {
    // 캐시는 없는데 같은 창의 차감 기록만 남아 있다 = 이번 생성은 무차감.
    // 정상 경로는 캐시 저장 실패 후 재시도 / 생성 실패 후 환불 재시도뿐이다.
    console.warn(
      `[fortune_charge] 차감 replay (무차감 생성) — ${normalizedType} / ${userId}`,
    );
  }

  return {
    userId,
    idempotencyKey,
    replayed: false,
    tokenCharge: {
      cost,
      balance: charge.balanceAfter ?? null,
      consumeTransactionId: charge.transactionId ?? null,
      replayed: charge.replayed,
    },
  };
}

/**
 * 생성 결과를 캐시에 저장 (best-effort).
 * 캐시 저장 실패로 사용자 응답을 실패시키지 않는다.
 */
export async function storeFortuneResult(
  supabase: SupabaseClient,
  idempotencyKey: string,
  userId: string,
  fortuneType: string,
  payload: unknown,
): Promise<void> {
  try {
    const { error } = await supabase
      .from(CACHE_TABLE)
      .upsert({
        idempotency_key: idempotencyKey,
        user_id: userId,
        fortune_type: normalizeFortuneType(fortuneType),
        payload,
        // 키의 창이 끝나는 시각. 창이 롤오버하면 키도 바뀌어 이 row 는 어차피
        // 조회되지 않으므로, 만료 시각을 창 끝에 맞춰 cron 이 바로 회수하게 한다.
        expires_at: new Date((currentWindow() + 1) * WINDOW_MS).toISOString(),
      }, { onConflict: "idempotency_key" });

    if (error) {
      console.warn(`[fortune_charge] 캐시 저장 실패 (무시): ${error.message}`);
    }
  } catch (e) {
    console.warn("[fortune_charge] 캐시 저장 예외 (무시):", e);
  }
}

/**
 * 생성 실패 시 차감분 환불.
 * referenceId 는 차감 때 쓴 idempotencyKey 와 동일해야 원본 consume 을 찾는다.
 */
export async function refundFortuneCharge(
  supabase: SupabaseClient,
  userId: string,
  idempotencyKey: string,
  fortuneType: string,
): Promise<void> {
  try {
    await refundTokens(supabase, userId, 0, 0, {
      description: `${fortuneType} 운세`,
      referenceType: REFERENCE_TYPE,
      referenceId: idempotencyKey,
      idempotencyKey,
    });
  } catch (e) {
    console.warn("[fortune_charge] 환불 실패 (무시):", e);
  }
}
