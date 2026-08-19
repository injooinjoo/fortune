/**
 * `user-llm-key` Edge Function 호출부.
 *
 * ## 계약 (supabase/functions/user-llm-key/index.ts 를 그대로 따른다)
 *
 *   POST   { provider, apiKey, model? }  → { success, key: 메타데이터 }
 *   GET                                  → { success, keys: [ 메타데이터, ... ] }
 *   DELETE { provider }                  → { success, deleted }
 *
 * 메타데이터는 provider / last4 / model / isActive / verifiedAt / createdAt 뿐이다.
 * 암호문·IV·평문 키는 어떤 응답에도 들어오지 않는다.
 *
 * ## 왜 GET / DELETE 만 래퍼를 안 쓰는가
 * `lib/edge-invoke.ts` 는 supabase-js 기본값대로 body 를 실은 POST 만 보낸다
 * (method 옵션을 노출하지 않는다). 연결(POST)은 래퍼를 그대로 쓰고, 래퍼로
 * 표현할 수 없는 목록(GET) / 해제(DELETE) 만 아래 `callWithMethod` 로 부른다.
 * 래퍼의 핵심 규칙인 **커스텀 요청 헤더 금지** 는 양쪽 다 지킨다 — headers 옵션을
 * 넘기지 않으므로 supabase-js 가 붙이는 authorization / apikey / x-client-info /
 * content-type 만 나가고, 이 넷은 `_shared/cors.ts` 의 허용 목록 안에 있다.
 * (DELETE 자체는 user-llm-key 가 자기 응답에서 Allow-Methods 를
 * `GET, POST, DELETE, OPTIONS` 로 넓혀 두어 preflight 를 통과한다.)
 *
 * ## 이 파일에서 절대 하면 안 되는 것
 * - apiKey 를 console 로 찍지 않는다. 성공/실패 어느 경로에서도.
 * - apiKey 를 모듈 스코프나 캐시에 담지 않는다. 인자로 받아 그 호출에서만 쓴다.
 * - 서버가 준 `message` 를 화면에 올리지 않는다. provider 원문 에러에는 키가
 *   그대로 섞여 나오는 경우가 있다 (프로덕션에서 Gemini 가 실제로 그랬다).
 *   Edge 쪽도 원문을 싣지 않도록 막아 두었지만, 여기서도 `code` 와 status 만
 *   보고 우리 문구로 번역한다 — 이중 방어.
 */

import type { SupabaseClient } from '@supabase/supabase-js';

import { invokeEdgeFunction } from '@/lib/edge-invoke';
import { getBrowserSupabase } from '@/lib/supabase/client';

import type { UserLlmProviderId } from './providers';

const FUNCTION_NAME = 'user-llm-key';

/** 클라이언트가 볼 수 있는 전부. 키 본문에 해당하는 필드는 여기 없다. */
export interface UserLlmKeyMeta {
  provider: string;
  /** 키의 마지막 네 자리. 서버가 만들어 준 값을 표시만 한다. */
  last4: string;
  model?: string;
  createdAt?: string;
  verifiedAt?: string;
  isActive: boolean;
}

export type UserLlmKeyFailureKind = 'auth' | 'invalid_key' | 'error';

export type UserLlmKeyResult<T> =
  | { ok: true; data: T }
  | { ok: false; kind: UserLlmKeyFailureKind; message: string };

/** 연결/해제는 돌려받을 데이터가 없다 — 성공하면 목록을 다시 읽는다. */
export type UserLlmKeyMutationResult =
  | { ok: true }
  | { ok: false; kind: UserLlmKeyFailureKind; message: string };

export type SettingsSession =
  | { kind: 'ready'; supabase: SupabaseClient }
  | { kind: 'signed-out' }
  | { kind: 'unavailable' };

const SIGNED_OUT_MESSAGE = '로그인이 필요해요.';
const UNAVAILABLE_MESSAGE = '서비스 설정이 아직 준비되지 않았어요.';
const GENERIC_FAILURE_MESSAGE = '지금 요청을 처리하지 못했어요. 잠시 후 다시 시도해 주세요.';
const AUTH_FAILURE_MESSAGE = '로그인이 풀렸어요. 다시 로그인한 뒤 시도해 주세요.';

/**
 * 서버 `code` → 우리 문구. 여기 없는 code 는 전부 `GENERIC_FAILURE_MESSAGE` 로 덮는다.
 * 키는 소문자다 — 비교 직전에 code 를 소문자로 접는다.
 */
const ERROR_COPY: Record<string, string> = {
  auth_required: AUTH_FAILURE_MESSAGE,
  key_invalid: '이 키로는 인증되지 않았어요. 값을 다시 확인하고 붙여 넣어 주세요.',
  bad_request: '입력한 값을 다시 확인해 주세요.',
  encryption_unavailable: '지금은 키를 저장할 수 없어요. 잠시 후 다시 시도해 주세요.',
  // 서버가 사용자/IP 단위로 검증 시도 횟수를 제한한다 (user-llm-key/index.ts).
  rate_limited: '키 확인 시도가 너무 많아요. 잠시 후 다시 시도해 주세요.',
  method_not_allowed: GENERIC_FAILURE_MESSAGE,
};

/**
 * 이 페이지는 진짜 로그인 세션이 있어야 한다.
 *
 * 익명 세션은 "로그인" 으로 치지 않는다 — 쿠키가 지워지면 그 user_id 로 다시
 * 들어올 방법이 없어서 저장한 키가 주인 없는 행으로 남는다. 운세 페이지처럼
 * 여기서 `signInAnonymously()` 를 부르지 않는 것도 같은 이유다.
 *
 * 이 검사는 **UX 용**이다. 실제 게이트는 Edge Function 쪽에 있다 —
 * `user-llm-key` 는 JWT 가 없으면 401 을 주고, JWT 가 있어도 admin API 로
 * 계정을 다시 읽어 익명 계정이면 401 을 준다. 브라우저를 거치지 않는 요청도
 * 같은 규칙을 받는다.
 */
export async function readSettingsSession(): Promise<SettingsSession> {
  const supabase = getBrowserSupabase();
  if (!supabase) return { kind: 'unavailable' };

  const { data } = await supabase.auth.getSession();
  const user = data.session?.user;
  if (!user || user.is_anonymous === true) return { kind: 'signed-out' };

  return { kind: 'ready', supabase };
}

function toRecord(value: unknown): Record<string, unknown> | undefined {
  return value !== null && typeof value === 'object'
    ? (value as Record<string, unknown>)
    : undefined;
}

/** snake_case 와 camelCase 를 둘 다 받는다 — repo 안에 두 컨벤션이 공존한다. */
function readString(source: Record<string, unknown>, ...keys: string[]): string | undefined {
  for (const key of keys) {
    const value = source[key];
    if (typeof value === 'string' && value.length > 0) return value;
  }
  return undefined;
}

/** provider 와 last4 가 없으면 화면에 그릴 게 없으므로 버린다. */
function parseKeyMeta(value: unknown): UserLlmKeyMeta | undefined {
  const raw = toRecord(value);
  if (!raw) return undefined;

  const provider = readString(raw, 'provider');
  const last4 = readString(raw, 'last4');
  if (!provider || !last4) return undefined;

  return {
    provider,
    last4,
    model: readString(raw, 'model'),
    createdAt: readString(raw, 'createdAt', 'created_at'),
    verifiedAt: readString(raw, 'verifiedAt', 'verified_at'),
    // 명시적으로 false 일 때만 비활성. 필드가 없으면 활성으로 본다.
    isActive: raw.isActive !== false && raw.is_active !== false,
  };
}

function parseKeyList(data: unknown): UserLlmKeyMeta[] {
  const keys = toRecord(data)?.keys;
  if (!Array.isArray(keys)) return [];

  return keys.map(parseKeyMeta).filter((entry): entry is UserLlmKeyMeta => entry !== undefined);
}

/** 서버 `message` 는 쓰지 않는다 (파일 상단 주석). code 와 status 로만 분기한다. */
function toFailure(
  status: number | undefined,
  errorCode: string | undefined,
): { ok: false; kind: UserLlmKeyFailureKind; message: string } {
  const code = errorCode?.toLowerCase();

  if (status === 401 || code === 'auth_required') {
    return { ok: false, kind: 'auth', message: AUTH_FAILURE_MESSAGE };
  }
  if (code === 'key_invalid') {
    return { ok: false, kind: 'invalid_key', message: ERROR_COPY.key_invalid };
  }

  return {
    ok: false,
    kind: 'error',
    message: (code ? ERROR_COPY[code] : undefined) ?? GENERIC_FAILURE_MESSAGE,
  };
}

function sessionFailure(
  session: SettingsSession,
): { ok: false; kind: UserLlmKeyFailureKind; message: string } {
  return session.kind === 'unavailable'
    ? { ok: false, kind: 'error', message: UNAVAILABLE_MESSAGE }
    : { ok: false, kind: 'auth', message: SIGNED_OUT_MESSAGE };
}

type MethodCallResult =
  | { ok: true; data: unknown }
  | { ok: false; status?: number; code?: string };

/**
 * GET / DELETE 전용 호출 (파일 상단 "왜 래퍼를 안 쓰는가" 참고).
 * 실패 바디에서 `code` 하나만 꺼낸다 — `message` 는 의도적으로 읽지 않는다.
 */
async function callWithMethod(
  supabase: SupabaseClient,
  method: 'GET' | 'DELETE',
  body?: Record<string, unknown>,
): Promise<MethodCallResult> {
  let data: unknown;
  let error: unknown;

  try {
    const invoked = await supabase.functions.invoke<unknown>(FUNCTION_NAME, {
      method,
      ...(body ? { body } : {}),
    });
    data = invoked.data;
    error = invoked.error;
  } catch {
    // 네트워크 단계 실패. 예외 메시지는 그대로 버린다.
    return { ok: false };
  }

  if (error === null || error === undefined) return { ok: true, data };

  const context = toRecord(error)?.context as
    | { status?: number; json?: () => Promise<unknown> }
    | undefined;

  let code: string | undefined;
  if (context?.json) {
    try {
      const parsed = toRecord(await context.json());
      code = parsed ? readString(parsed, 'code') : undefined;
    } catch {
      // 4xx/5xx 바디가 JSON 이 아닌 경우 (게이트웨이 HTML 등). status 로만 분기한다.
    }
  }

  return { ok: false, status: context?.status, code };
}

export async function listUserLlmKeys(): Promise<UserLlmKeyResult<UserLlmKeyMeta[]>> {
  const session = await readSettingsSession();
  if (session.kind !== 'ready') return sessionFailure(session);

  const result = await callWithMethod(session.supabase, 'GET');
  if (!result.ok) return toFailure(result.status, result.code);

  return { ok: true, data: parseKeyList(result.data) };
}

/**
 * 키를 연결한다.
 *
 * `apiKey` 는 이 함수의 인자로만 존재한다 — 호출이 끝나면 참조가 사라진다.
 * 여기서 어디에도 보관하지 않고, 응답도 성공 여부만 쓴다.
 */
export async function connectUserLlmKey(
  provider: UserLlmProviderId,
  apiKey: string,
  model?: string,
): Promise<UserLlmKeyMutationResult> {
  const session = await readSettingsSession();
  if (session.kind !== 'ready') return sessionFailure(session);

  const result = await invokeEdgeFunction<unknown>(session.supabase, FUNCTION_NAME, {
    provider,
    apiKey,
    ...(model ? { model } : {}),
  });

  // KEY_INVALID 는 400 + `{ code: 'KEY_INVALID' }` 로 온다. 래퍼가 code 를 그대로
  // 실어 주므로 여기서는 code 만 보고 우리 문구로 바꾼다.
  if (!result.ok) return toFailure(result.status, result.errorCode);

  return { ok: true };
}

export async function disconnectUserLlmKey(
  provider: string,
): Promise<UserLlmKeyMutationResult> {
  const session = await readSettingsSession();
  if (session.kind !== 'ready') return sessionFailure(session);

  const result = await callWithMethod(session.supabase, 'DELETE', { provider });
  if (!result.ok) return toFailure(result.status, result.code);

  return { ok: true };
}
