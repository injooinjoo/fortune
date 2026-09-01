/**
 * 웹 운세 호출기 — `daily-form.tsx` 가 인라인으로 하던 게스트 부트스트랩 +
 * Edge 호출 + 실패 분류를 모든 운세가 공유하는 하나의 함수로 뽑았다.
 *
 * 설계 제약 (전부 실제 서버 동작에서 온 것, 취향 아님):
 *
 * 1. 커스텀 헤더 금지. `supabase/functions/_shared/cors.ts` 의 허용 목록은
 *    authorization / x-client-info / apikey / content-type 뿐이라 하나라도
 *    더 붙이면 브라우저 preflight 가 깨진다. 그래서 여기서도 body 만 보낸다.
 *
 * 2. body 에 timestamp/nonce 금지. 새 서버(`_shared/fortune_charge.ts`)의
 *    idempotency 키가 `user + fortuneType + body 해시 + 24h 창` 이라
 *    제출마다 달라지는 값을 실으면 같은 질문도 매번 새로 과금된다.
 *    (`DEFAULT_OMIT_KEYS` 가 timestamp/nonce 를 걸러주긴 하지만, date 처럼
 *    목록에 없는 키로 새는 경우가 있어 호출부에서 아예 넣지 않는 게 안전하다.)
 *
 * 3. 배포된 Edge Function 은 아직 과금 게이트가 없는 구버전이다. 그래서
 *    최상위 `tokenCharge` 는 있을 수도 없을 수도 있고, 401/402 도 날 수도
 *    안 날 수도 있다. 양쪽 다 정상으로 취급한다.
 */

import type { SupabaseClient } from '@supabase/supabase-js';

import { invokeEdgeFunction } from '@/lib/edge-invoke';
import { trackProductEvent } from '@/lib/analytics-client';
import { notifyBalanceChanged } from '@/lib/balance-signal';
import {
  fortuneTitle,
  projectFortuneSummary,
  stableFortuneFingerprintSource,
} from '@/lib/fortune-context';
import { getBrowserSupabase } from '@/lib/supabase/client';

export type FortuneFailureKind = 'auth' | 'tokens' | 'error';

export type FortuneRunResult<T> =
  | { ok: true; data: T; tokenCharge?: unknown }
  | { ok: false; kind: FortuneFailureKind; message: string };

/** 세션 만료/익명 차단. 화면은 로그인 유도로 분기한다. */
export const AUTH_FAILURE_MESSAGE = '세션이 만료됐어요. 다시 로그인하면 이어서 볼 수 있어요.';

/** 402 바디는 `{ code, required, available }` 뿐이라 사용자 문구가 없다. */
export const TOKENS_FAILURE_MESSAGE =
  '잔액이 모자라서 운세를 생성하지 못했어요. 로그인하면 계정에 남은 온도를 확인하고 이어서 볼 수 있어요.';

const CONFIG_FAILURE_MESSAGE = '서비스 설정이 아직 준비되지 않았어요.';

const EMPTY_RESPONSE_MESSAGE = '운세 응답이 비어 있어요. 잠시 후 다시 시도해 주세요.';

/**
 * fortune-type → Edge Function 이름.
 * repo 안의 운세 함수는 전부 `fortune-<type>` 규칙이다
 * (`packages/product-contracts/src/fortunes.ts` 의 endpoint 와 동일).
 */
export function edgeFunctionName(fortuneType: string): string {
  return fortuneType.startsWith('fortune-') ? fortuneType : `fortune-${fortuneType}`;
}

/**
 * 코드 문자열은 대소문자를 무시하고 본다 — fortune-tarot 은 `auth_required`,
 * `_shared/fortune_charge.ts` 는 `AUTH_REQUIRED` 를 내려준다.
 */
function matchesCode(errorCode: string | undefined, expected: string): boolean {
  return errorCode?.toLowerCase() === expected;
}

function isAuthFailure(status: number | undefined, errorCode: string | undefined): boolean {
  return status === 401 || matchesCode(errorCode, 'auth_required');
}

function isTokenFailure(status: number | undefined, errorCode: string | undefined): boolean {
  return status === 402 || matchesCode(errorCode, 'insufficient_tokens');
}

/** 구버전 Edge 는 이 필드를 안 내려준다. 없으면 undefined 로 조용히 넘어간다. */
function readTokenCharge(data: unknown): unknown {
  if (data === null || typeof data !== 'object') return undefined;
  return (data as Record<string, unknown>).tokenCharge;
}

async function sha256(value: string): Promise<string> {
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(value));
  return [...new Uint8Array(digest)]
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join('');
}

async function saveFortuneContext(
  supabase: SupabaseClient,
  fortuneType: string,
  body: Record<string, unknown>,
  data: unknown,
): Promise<void> {
  if (data === null || typeof data !== 'object') return;
  const summary = projectFortuneSummary(data);
  if (summary.highlights.length === 0 && summary.score === null) return;

  const day = new Date().toISOString().slice(0, 10);
  const historyKey = await sha256(stableFortuneFingerprintSource(fortuneType, body, day));
  const title = fortuneTitle(fortuneType);
  const { data: historyId, error } = await supabase.rpc('save_web_fortune_history', {
    p_fortune_type: fortuneType,
    p_title: title,
    p_summary: summary,
    // Persist the admitted presentation projection, never the raw provider envelope.
    p_fortune_data: { projectedSummary: summary },
    p_score: summary.score,
    p_history_key: historyKey,
  });
  if (error || typeof historyId !== 'string') {
    console.warn('[fortune] 결과 이력을 저장하지 못했어요.');
    return;
  }

  sessionStorage.setItem(
    'ondo:last-fortune-context',
    JSON.stringify({ id: historyId, title, createdAt: Date.now() }),
  );
}

/**
 * LLM provider 원본 에러를 사용자에게 그대로 보여주지 않는다.
 *
 * 실제로 프로덕션에서 이런 게 화면에 그대로 찍혔다:
 *   Gemini API error: 400 - { "error": { "code": 400, "message": "API key not valid. ...
 *
 * 사용자에게 쓸모없고, provider·모델·내부 구조를 노출한다. 원문은 콘솔로만 남긴다.
 */
const PROVIDER_ERROR_PATTERNS = [
  /API key/i,
  /API error/i,
  /INVALID_ARGUMENT/,
  /googleapis\.com/i,
  /generativelanguage/i,
  /quota/i,
  /RESOURCE_EXHAUSTED/,
];

function userFacingMessage(fortuneType: string, raw: string): string {
  const looksInternal =
    raw.trimStart().startsWith('{') ||
    raw.length > 200 ||
    PROVIDER_ERROR_PATTERNS.some((pattern) => pattern.test(raw));

  if (!looksInternal) return raw;

  console.error(`[${fortuneType}] 서버 원본 에러:`, raw);
  return '지금 운세를 만들지 못했어요. 잠시 후 다시 시도해 주세요.';
}

/**
 * 운세 하나를 호출한다.
 *
 * 게스트 우선: 결과 "앞"에 로그인 벽을 두지 않는다. 세션이 없으면 익명 로그인을
 * 시도하고, 프로젝트에서 Anonymous sign-ins 가 꺼져 있어 실패해도 anon key 로
 * 그대로 호출한다. 서버가 401 을 주면 그때 `kind: 'auth'` 로 로그인 안내를 띄운다.
 *
 * @param fortuneType `daily`, `tarot` 처럼 catalog 의 fortune-type id.
 * @param body Edge Function 이 요구하는 실제 필드. 함수마다 다르니
 *             `supabase/functions/fortune-<type>/index.ts` 를 읽고 맞출 것.
 *             타임스탬프/난수는 절대 넣지 말 것 (위 2번).
 */
export async function runFortune<T>(
  fortuneType: string,
  body: Record<string, unknown>,
): Promise<FortuneRunResult<T>> {
  const startedAt = performance.now();
  trackProductEvent('fortune_started', { fortune_type: fortuneType });
  const supabase = getBrowserSupabase();
  if (!supabase) {
    trackProductEvent('fortune_completed', {
      fortune_type: fortuneType,
      outcome: 'configuration_error',
    });
    return { ok: false, kind: 'error', message: CONFIG_FAILURE_MESSAGE };
  }

  const { data: sessionData } = await supabase.auth.getSession();
  if (!sessionData.session) {
    const { error: anonError } = await supabase.auth.signInAnonymously();
    if (anonError) {
      console.warn(`[${fortuneType}] 익명 세션 발급 실패 — anon key 로 계속:`, anonError.message);
    }
  }

  const result = await invokeEdgeFunction<T>(supabase, edgeFunctionName(fortuneType), body);

  // 차감은 엣지 함수 안에서 끝난다. 성공이면 깎였고, 잔액부족이면 바닥을 친
  // 상태다. 어느 쪽이든 화면에 남아 있는 잔액은 이미 낡았으니 여기서 알린다.
  notifyBalanceChanged();

  if (!result.ok) {
    const errorKind = isAuthFailure(result.status, result.errorCode)
      ? 'auth'
      : isTokenFailure(result.status, result.errorCode)
        ? 'tokens'
        : 'server';
    trackProductEvent('fortune_completed', {
      duration_ms: Math.round(performance.now() - startedAt),
      error_kind: errorKind,
      fortune_type: fortuneType,
      outcome: 'error',
    });
    if (isAuthFailure(result.status, result.errorCode)) {
      return { ok: false, kind: 'auth', message: AUTH_FAILURE_MESSAGE };
    }
    if (isTokenFailure(result.status, result.errorCode)) {
      return { ok: false, kind: 'tokens', message: TOKENS_FAILURE_MESSAGE };
    }
    return { ok: false, kind: 'error', message: userFacingMessage(fortuneType, result.message) };
  }

  // 200 인데 바디가 통째로 비는 경우 (LLM 실패 후 빈 응답 등).
  if (result.data === null || result.data === undefined) {
    trackProductEvent('fortune_completed', {
      duration_ms: Math.round(performance.now() - startedAt),
      error_kind: 'empty_response',
      fortune_type: fortuneType,
      outcome: 'error',
    });
    return { ok: false, kind: 'error', message: EMPTY_RESPONSE_MESSAGE };
  }

  trackProductEvent('fortune_completed', {
    duration_ms: Math.round(performance.now() - startedAt),
    fortune_type: fortuneType,
    outcome: 'success',
  });
  try {
    await saveFortuneContext(supabase, fortuneType, body, result.data);
  } catch {
    // History persistence cannot turn a successfully generated/charged result into a failure.
    console.warn('[fortune] 결과 이력 저장 중 오류가 발생했어요.');
  }
  return { ok: true, data: result.data, tokenCharge: readTokenCharge(result.data) };
}
