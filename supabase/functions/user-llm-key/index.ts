// 사용자 소유 LLM 키(BYOK) 연결/조회/해제 엔드포인트.
//
//   POST   { provider, apiKey, model? }  → provider 실호출로 검증 후 봉인 저장
//   GET                                  → 연결된 provider 메타데이터 목록
//   DELETE { provider }                  → 연결 해제 (행 삭제)
//
// 보안 계약 (깨면 사용자 결제 계정이 털린다):
//  1. 평문 키는 이 함수 안에서만 존재한다. 저장은 AES-GCM 암호문 + IV 로만 한다.
//  2. **어떤 응답도 평문/암호문/IV 를 돌려주지 않는다.** 본인 것이라도 안 된다.
//     사용자가 알 수 있는 건 provider, last4, model, is_active, verified_at,
//     created_at 뿐이다.
//  3. 요청 본문을 통째로 로깅하지 않는다. 키가 로그로 새는 가장 흔한 경로다.
//  4. provider 응답 본문을 읽지도, 클라이언트에 되돌리지도 않는다 — 일부 provider
//     는 에러 메시지에 요청한 키를 그대로 되비춘다. 상태 코드만 본다.
//  5. verify_jwt 는 게이트웨이 기본값(true)을 그대로 쓴다. config.toml 은
//     verify_jwt=false 오버라이드만 나열하는 파일이라 이 함수는 등록하지 않는다.
//     함수 안에서도 deriveUserIdFromJwt 로 한 번 더 확인한다 (이중 방어).
//  6. **익명 세션은 거부한다** (서버에서). 웹의 운세/채팅 경로는
//     signInAnonymously() 를 부르므로 사실상 모든 방문자가 JWT 를 갖는다.
//     익명 계정에 자격증명을 저장하면 쿠키가 지워지는 순간 주인이 사라진 암호문이
//     남고, 사용자는 목록/해제도 못 한다. 브라우저 쪽 검사만으로는 curl 을 못 막는다.
//  7. POST 는 **레이트 리밋 뒤에서만** provider 를 호출한다. 제한이 없으면 이
//     엔드포인트가 훔친 키를 다섯 벤더에 대조해 보는 검증기로 쓰인다.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";
import { deriveUserIdFromJwt } from "../_shared/auth.ts";
import { buildRecordAad, encryptSecret } from "../_shared/llm/crypto.ts";
import {
  isUserLlmProvider,
  type UserLlmProvider,
} from "../_shared/llm/user_key.ts";

// _shared/cors.ts 의 Allow-Methods 는 'POST, GET, OPTIONS' 라 DELETE preflight 가
// 막힌다. 공유 파일을 건드리지 않고 이 함수 응답에서만 메서드 목록을 넓힌다.
// **요청** 헤더 allowlist(authorization, x-client-info, apikey, content-type)는
// 그대로다 — 커스텀 요청 헤더는 보내지도 받지도 않는다.
const responseHeaders = {
  ...corsHeaders,
  "Access-Control-Allow-Methods": "GET, POST, DELETE, OPTIONS",
};

/** provider 검증 호출 타임아웃. 사용자를 무한 대기시키지 않는다. */
const VERIFY_TIMEOUT_MS = 10_000;

/** 키 길이 상한/하한 — 뻔한 오입력(빈 문자열, 붙여넣기 실패)을 조기 차단. */
const MIN_KEY_LENGTH = 16;
const MAX_KEY_LENGTH = 400;
const MAX_MODEL_LENGTH = 100;

/**
 * 검증 시도 레이트 리밋.
 *
 * 사람이 자기 키를 연결하는 데 한 시간에 열 번이면 오타/재발급까지 충분하다.
 * IP 버킷은 계정을 여러 개 만들어 도는 경우를 잡는다 (같은 사무실에서 여러 명이
 * 연결하는 경우를 막지 않을 만큼은 넉넉하게).
 */
const ATTEMPT_WINDOW_SECONDS = 3600;
const MAX_ATTEMPTS_PER_USER = 10;
const MAX_ATTEMPTS_PER_IP = 30;

/** 클라이언트에 나가는 유일한 형태. ciphertext / iv 는 절대 포함하지 않는다. */
interface KeyMetadata {
  provider: string;
  last4: string;
  model: string | null;
  isActive: boolean;
  verifiedAt: string | null;
  createdAt: string;
}

interface KeyRow {
  provider: string;
  last4: string;
  model: string | null;
  is_active: boolean;
  verified_at: string | null;
  created_at: string;
}

/** GET/POST 가 공유하는 SELECT 컬럼. ciphertext / iv 는 의도적으로 빠져 있다. */
const METADATA_COLUMNS = "provider, last4, model, is_active, verified_at, created_at";

function toMetadata(row: KeyRow): KeyMetadata {
  return {
    provider: row.provider,
    last4: row.last4,
    model: row.model,
    isActive: row.is_active,
    verifiedAt: row.verified_at,
    createdAt: row.created_at,
  };
}

function json(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...responseHeaders, "Content-Type": "application/json" },
  });
}

function fail(code: string, message: string, status: number): Response {
  return json({ code, message }, status);
}

type ProbeResult = "ok" | "rejected" | "unreachable";

/**
 * provider 에 인증만 확인하는 최소 호출 (전부 GET 목록/키정보 API — 토큰 소모 없음).
 *
 * 응답 **본문은 읽지 않는다**. provider 가 에러 본문에 키를 되비추는 경우가 있어
 * 읽는 순간 로그/에러 경로로 샐 위험이 생긴다. 상태 코드만으로 판정한다.
 */
async function probe(
  url: string,
  headers: Record<string, string>,
): Promise<ProbeResult> {
  let response: Response;
  try {
    response = await fetch(url, {
      method: "GET",
      headers,
      signal: AbortSignal.timeout(VERIFY_TIMEOUT_MS),
    });
  } catch {
    // 네트워크 실패/타임아웃. 예외 객체에 요청 헤더가 실릴 수 있으므로 로깅하지 않는다.
    return "unreachable";
  }

  // 본문 폐기 (읽지 않고 스트림만 닫는다).
  await response.body?.cancel().catch(() => {});

  if (response.ok) return "ok";
  if (response.status === 401 || response.status === 403) return "rejected";
  // 429(쿼터)/5xx 등은 "키가 틀렸다" 는 증거가 아니다.
  return "unreachable";
}

/**
 * ⚠️ apiKey 평문을 받는다. 이 함수 밖으로 흘리지 말 것.
 * Gemini 는 ?key= 쿼리스트링 대신 x-goog-api-key 헤더를 쓴다 — URL 에 자격증명이
 * 들어가면 중간 로그(프록시/에러 리포터)에 그대로 남는다.
 */
function verifyKey(
  provider: UserLlmProvider,
  apiKey: string,
): Promise<ProbeResult> {
  switch (provider) {
    case "openai":
      return probe("https://api.openai.com/v1/models", {
        Authorization: `Bearer ${apiKey}`,
      });

    case "grok":
      return probe("https://api.x.ai/v1/models", {
        Authorization: `Bearer ${apiKey}`,
      });

    case "openrouter":
      return probe("https://openrouter.ai/api/v1/key", {
        Authorization: `Bearer ${apiKey}`,
      });

    case "anthropic":
      return probe("https://api.anthropic.com/v1/models", {
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
      });

    case "gemini":
      return probe("https://generativelanguage.googleapis.com/v1beta/models", {
        "x-goog-api-key": apiKey,
      });
  }
}

function createServiceClient() {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { autoRefreshToken: false, persistSession: false } },
  );
}

// ── 익명 세션 차단 ────────────────────────────────────────────────────────────

type AccountKind = "real" | "anonymous" | "unknown";

/**
 * JWT 가 가리키는 계정이 진짜 로그인 계정인지 확인한다.
 *
 * JWT 페이로드의 `is_anonymous` 를 그냥 믿지 않고 admin API 로 계정을 다시 읽는다.
 * 확인이 안 되면 "unknown" 을 돌려주고 호출부가 **거부**한다 (fail-closed) —
 * 자격증명을 받는 엔드포인트에서 "확인 못 했으니 통과" 는 있을 수 없다.
 */
async function readAccountKind(userId: string): Promise<AccountKind> {
  try {
    const { data, error } = await createServiceClient().auth.admin.getUserById(
      userId,
    );
    if (error || !data?.user) return "unknown";
    return data.user.is_anonymous === true ? "anonymous" : "real";
  } catch {
    return "unknown";
  }
}

// ── 레이트 리밋 ───────────────────────────────────────────────────────────────

/**
 * 게이트웨이가 붙이는 클라이언트 IP. 브라우저는 이 헤더를 스스로 세울 수 없다.
 * (curl 로는 위조할 수 있으므로 IP 버킷은 사용자 버킷의 보조 수단이다.)
 */
function callerIp(req: Request): string | null {
  const forwarded = req.headers.get("x-forwarded-for");
  const candidate = forwarded?.split(",")[0]?.trim() ||
    req.headers.get("cf-connecting-ip")?.trim();
  if (!candidate) return null;

  // IP 모양이 아닌 값(위조된 긴 문자열)으로 카운터 행을 무한히 만들지 못하게 막는다.
  // IPv6 최대 표기가 45자다.
  if (candidate.length > 45 || !/^[0-9a-fA-F.:]+$/.test(candidate)) return null;

  return candidate;
}

/** 버킷 하나를 1 올리고 상한 초과 여부를 받는다. RPC 실패는 초과로 취급한다. */
async function consumeAttempt(
  bucketKey: string,
  maxAttempts: number,
): Promise<{ allowed: boolean; retryAfterSeconds: number }> {
  const { data, error } = await createServiceClient().rpc(
    "record_user_llm_key_attempt",
    {
      p_bucket_key: bucketKey,
      p_window_seconds: ATTEMPT_WINDOW_SECONDS,
      p_max_attempts: maxAttempts,
    },
  );

  if (error) {
    // 마이그레이션 미적용 등. 카운터를 못 세는 동안 provider 호출을 열어 두면
    // 그게 곧 무제한 키 검증기다. 여기서는 막는 쪽이 맞다.
    console.error(
      `[user-llm-key] 레이트 리밋 조회 실패 code=${error.code ?? "unknown"}`,
    );
    return { allowed: false, retryAfterSeconds: ATTEMPT_WINDOW_SECONDS };
  }

  const row = Array.isArray(data) ? data[0] : data;
  return {
    allowed: row?.allowed === true,
    retryAfterSeconds: Number(row?.retry_after_seconds ?? ATTEMPT_WINDOW_SECONDS),
  };
}

/**
 * 사용자 버킷 → IP 버킷 순서로 소진한다.
 * 사용자 버킷에서 이미 걸리면 IP 버킷은 건드리지 않는다 (한 시도가 두 번 세지지
 * 않게, 그리고 같은 IP 를 쓰는 다른 사람이 말려들지 않게).
 */
async function checkAttemptLimits(
  req: Request,
  userId: string,
): Promise<{ allowed: boolean; retryAfterSeconds: number }> {
  const byUser = await consumeAttempt(`user:${userId}`, MAX_ATTEMPTS_PER_USER);
  if (!byUser.allowed) return byUser;

  const ip = callerIp(req);
  if (!ip) return byUser;

  return await consumeAttempt(`ip:${ip}`, MAX_ATTEMPTS_PER_IP);
}

async function readJsonBody(req: Request): Promise<Record<string, unknown> | null> {
  try {
    const parsed = await req.json();
    if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
      return null;
    }
    return parsed as Record<string, unknown>;
  } catch {
    return null;
  }
}

// ── POST: 검증 → 봉인 → upsert ────────────────────────────────────────────────

async function handlePost(req: Request, userId: string): Promise<Response> {
  const body = await readJsonBody(req);
  if (!body) return fail("BAD_REQUEST", "잘못된 요청 본문입니다", 400);

  const provider = body.provider;
  if (!isUserLlmProvider(provider)) {
    return fail("BAD_REQUEST", "지원하지 않는 provider 입니다", 400);
  }

  const rawKey = body.apiKey;
  if (typeof rawKey !== "string") {
    return fail("BAD_REQUEST", "apiKey 가 필요합니다", 400);
  }
  const apiKey = rawKey.trim();

  // 형식 검증 실패 메시지에 입력값을 절대 넣지 않는다.
  if (apiKey.length < MIN_KEY_LENGTH || apiKey.length > MAX_KEY_LENGTH) {
    return fail("BAD_REQUEST", "API 키 형식이 올바르지 않습니다", 400);
  }
  if (!/^[\x21-\x7e]+$/.test(apiKey)) {
    // 공백/개행/제어문자/비ASCII → 복사 실패이거나 키가 아니다.
    return fail("BAD_REQUEST", "API 키 형식이 올바르지 않습니다", 400);
  }

  let model: string | null = null;
  if (body.model !== undefined && body.model !== null) {
    if (typeof body.model !== "string") {
      return fail("BAD_REQUEST", "model 형식이 올바르지 않습니다", 400);
    }
    const trimmed = body.model.trim();
    if (trimmed) {
      if (trimmed.length > MAX_MODEL_LENGTH || !/^[A-Za-z0-9._:\/-]+$/.test(trimmed)) {
        return fail("BAD_REQUEST", "model 형식이 올바르지 않습니다", 400);
      }
      model = trimmed;
    }
  }

  // provider 를 부르기 **전에** 시도 횟수를 소진한다. 형식 검증만 통과하면
  // 누구나 다섯 벤더에 대조 요청을 날릴 수 있는 상태를 만들지 않는다.
  const limit = await checkAttemptLimits(req, userId);
  if (!limit.allowed) {
    console.warn(`[user-llm-key] 레이트 리밋 user=${userId}`);
    return new Response(
      JSON.stringify({
        code: "RATE_LIMITED",
        message: "키 확인 시도가 너무 많아요. 잠시 후 다시 시도해 주세요.",
      }),
      {
        status: 429,
        headers: {
          ...responseHeaders,
          "Content-Type": "application/json",
          "Retry-After": String(limit.retryAfterSeconds),
        },
      },
    );
  }

  // 저장 전에 반드시 provider 실호출로 검증한다.
  const probeResult = await verifyKey(provider, apiKey);
  if (probeResult !== "ok") {
    console.warn(
      `[user-llm-key] 검증 실패 user=${userId} provider=${provider} result=${probeResult}`,
    );
    // 코드는 하나로 고정(웹이 분기할 값은 code 뿐), 원인은 message 로만 구분한다.
    // provider 의 원본 응답은 어떤 형태로도 싣지 않는다.
    return json({
      code: "KEY_INVALID",
      reason: probeResult === "rejected" ? "rejected" : "unreachable",
      message: probeResult === "rejected"
        ? "해당 키로 인증에 실패했습니다. 키를 다시 확인해 주세요."
        : "지금은 키를 확인할 수 없습니다. 잠시 후 다시 시도해 주세요.",
    }, 400);
  }

  let sealed: { ciphertext: string; iv: string };
  try {
    // AAD 로 소유 행 (user_id, provider) 을 묶는다 — 다른 행으로 복사해 붙여도
    // 인증 태그가 깨져 복호화되지 않는다.
    sealed = await encryptSecret(apiKey, buildRecordAad(userId, provider));
  } catch (e) {
    // BYOK_ENCRYPTION_KEY 미설정/길이 오류. 평문 저장으로 폴백하지 않는다.
    console.error(
      `[user-llm-key] 암호화 실패: ${e instanceof Error ? e.message : "unknown"}`,
    );
    return fail("ENCRYPTION_UNAVAILABLE", "지금은 키를 저장할 수 없습니다", 503);
  }

  const now = new Date().toISOString();
  const { data, error } = await createServiceClient()
    .from("user_llm_keys")
    .upsert({
      user_id: userId,
      provider,
      ciphertext: sealed.ciphertext,
      iv: sealed.iv,
      last4: apiKey.slice(-4),
      model,
      is_active: true,
      verified_at: now,
      updated_at: now,
    }, { onConflict: "user_id,provider" })
    .select(METADATA_COLUMNS)
    .single();

  if (error || !data) {
    // ⚠️ error.message 를 찍지 않는다 — 이 요청 본문에는 ciphertext 가 들어 있고
    // 일부 Postgres 에러는 실패한 row 값을 문자열에 담는다. code 만으로 충분하다.
    console.error(
      `[user-llm-key] 저장 실패 user=${userId} provider=${provider} code=${
        error?.code ?? "unknown"
      }`,
    );
    return fail("SAVE_FAILED", "키를 저장하지 못했습니다", 500);
  }

  return json({ success: true, key: toMetadata(data as KeyRow) });
}

// ── GET: 메타데이터만 ─────────────────────────────────────────────────────────

async function handleGet(userId: string): Promise<Response> {
  const { data, error } = await createServiceClient()
    .from("user_llm_keys")
    .select(METADATA_COLUMNS)
    .eq("user_id", userId)
    .order("created_at", { ascending: true });

  if (error) {
    console.error(`[user-llm-key] 조회 실패 user=${userId}: ${error.message}`);
    return fail("LOAD_FAILED", "연결된 키를 불러오지 못했습니다", 500);
  }

  return json({
    success: true,
    keys: ((data ?? []) as KeyRow[]).map(toMetadata),
  });
}

// ── DELETE: 연결 해제 ─────────────────────────────────────────────────────────

async function handleDelete(req: Request, userId: string): Promise<Response> {
  const body = await readJsonBody(req);
  if (!body) return fail("BAD_REQUEST", "잘못된 요청 본문입니다", 400);

  const provider = body.provider;
  if (!isUserLlmProvider(provider)) {
    return fail("BAD_REQUEST", "지원하지 않는 provider 입니다", 400);
  }

  const { data, error } = await createServiceClient()
    .from("user_llm_keys")
    .delete()
    .eq("user_id", userId)
    .eq("provider", provider)
    .select("provider");

  if (error) {
    console.error(`[user-llm-key] 삭제 실패 user=${userId}: ${error.message}`);
    return fail("DELETE_FAILED", "키를 해제하지 못했습니다", 500);
  }

  return json({ success: true, deleted: (data ?? []).length > 0 });
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: responseHeaders });
  }

  // JWT 필수. 게스트/anon key bearer 는 null → 401.
  const userId = await deriveUserIdFromJwt(req);
  if (!userId) {
    return fail("AUTH_REQUIRED", "로그인이 필요합니다", 401);
  }

  // 익명 세션 차단 (파일 상단 6번). 웹에도 같은 검사가 있지만 그건 UX 용이고
  // 실제 게이트는 여기다 — 브라우저를 거치지 않는 요청도 같은 규칙을 받는다.
  const accountKind = await readAccountKind(userId);
  if (accountKind !== "real") {
    console.warn(
      `[user-llm-key] 비-정식 계정 거부 user=${userId} kind=${accountKind}`,
    );
    return fail(
      "AUTH_REQUIRED",
      "이 기능은 로그인한 계정에서만 쓸 수 있어요",
      401,
    );
  }

  try {
    switch (req.method) {
      case "POST":
        return await handlePost(req, userId);
      case "GET":
        return await handleGet(userId);
      case "DELETE":
        return await handleDelete(req, userId);
      default:
        return fail("METHOD_NOT_ALLOWED", "지원하지 않는 메서드입니다", 405);
    }
  } catch (e) {
    // 예외 문자열에 키가 섞일 가능성을 차단하기 위해 message 를 밖으로 내지 않는다.
    console.error(
      `[user-llm-key] 처리 실패 user=${userId} method=${req.method}: ${
        e instanceof Error ? e.name : "unknown"
      }`,
    );
    return fail("INTERNAL_ERROR", "요청을 처리하지 못했습니다", 500);
  }
});
