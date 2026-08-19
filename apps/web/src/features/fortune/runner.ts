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

import { invokeEdgeFunction } from '@/lib/edge-invoke';
import { getBrowserSupabase } from '@/lib/supabase/client';

export type FortuneFailureKind = 'auth' | 'tokens' | 'error';

export type FortuneRunResult<T> =
  | { ok: true; data: T; tokenCharge?: unknown }
  | { ok: false; kind: FortuneFailureKind; message: string };

/** 세션 만료/익명 차단. 화면은 로그인 유도로 분기한다. */
export const AUTH_FAILURE_MESSAGE = '세션이 만료됐어요. 다시 로그인하면 이어서 볼 수 있어요.';

/** 402 바디는 `{ code, required, available }` 뿐이라 사용자 문구가 없다. */
export const TOKENS_FAILURE_MESSAGE =
  '잔액이 모자라서 운세를 생성하지 못했어요. 앱에서 온도를 충전한 뒤 다시 시도해 주세요.';

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
  const supabase = getBrowserSupabase();
  if (!supabase) {
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

  if (!result.ok) {
    if (isAuthFailure(result.status, result.errorCode)) {
      return { ok: false, kind: 'auth', message: AUTH_FAILURE_MESSAGE };
    }
    if (isTokenFailure(result.status, result.errorCode)) {
      return { ok: false, kind: 'tokens', message: TOKENS_FAILURE_MESSAGE };
    }
    return { ok: false, kind: 'error', message: result.message };
  }

  // 200 인데 바디가 통째로 비는 경우 (LLM 실패 후 빈 응답 등).
  if (result.data === null || result.data === undefined) {
    return { ok: false, kind: 'error', message: EMPTY_RESPONSE_MESSAGE };
  }

  return { ok: true, data: result.data, tokenCharge: readTokenCharge(result.data) };
}
