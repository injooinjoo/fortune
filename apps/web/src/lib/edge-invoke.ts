import type { SupabaseClient } from '@supabase/supabase-js';

/**
 * Supabase Edge Function 호출 래퍼.
 *
 * 절대 커스텀 헤더를 붙이지 말 것 — repo 안의 어떤 함수도
 * `Access-Control-Allow-Headers` 에 `x-request-id` 류를 넣지 않는다
 * (`supabase/functions/_shared/cors.ts`: authorization, x-client-info,
 * apikey, content-type 뿐). 하나라도 추가하면 브라우저 preflight 가 깨진다.
 * supabase-js 가 기본으로 보내는 헤더는 전부 허용 목록 안에 있다.
 */

export type EdgeInvokeSuccess<T> = { ok: true; data: T };

export type EdgeInvokeFailure = {
  ok: false;
  /** HTTP status. 네트워크 단계에서 실패하면 undefined. */
  status?: number;
  /**
   * 서버가 내려준 머신 리더블 코드. repo 안에 두 컨벤션이 공존한다 —
   * fortune-tarot 은 `errorCode: "auth_required"` (소문자),
   * _shared/fortune_charge.ts 는 `code: "AUTH_REQUIRED"` (대문자).
   * 원문 그대로 실어 보내므로 비교는 호출부에서 대소문자 무시로 한다.
   */
  errorCode?: string;
  /** 사용자에게 그대로 보여줄 수 있는 한국어 메시지. */
  message: string;
};

export type EdgeInvokeResult<T> = EdgeInvokeSuccess<T> | EdgeInvokeFailure;

type ErrorContext = {
  status?: number;
  json?: () => Promise<unknown>;
};

function readString(source: unknown, key: string): string | undefined {
  if (source === null || typeof source !== 'object') return undefined;
  const value = (source as Record<string, unknown>)[key];
  return typeof value === 'string' && value.length > 0 ? value : undefined;
}

/** `errorCode` (tarot) 와 `code` (_shared/fortune_charge.ts) 둘 다 받는다. */
function readCode(source: unknown): string | undefined {
  return readString(source, 'errorCode') ?? readString(source, 'code');
}

/** `error` (tarot) 와 `message` (_shared/fortune_charge.ts) 둘 다 받는다. */
function readMessage(source: unknown): string | undefined {
  return readString(source, 'error') ?? readString(source, 'message');
}

function readErrorContext(error: unknown): ErrorContext | undefined {
  if (error === null || typeof error !== 'object') return undefined;
  const context = (error as { context?: unknown }).context;
  if (context === null || typeof context !== 'object') return undefined;
  return context as ErrorContext;
}

export async function invokeEdgeFunction<T>(
  supabase: SupabaseClient,
  functionName: string,
  body: Record<string, unknown>,
  options: { signal?: AbortSignal } = {},
): Promise<EdgeInvokeResult<T>> {
  let data: unknown;
  let error: unknown;

  try {
    // supabase-js v2 는 signal 을 fetch 로 pass-through 하지만 타입 선언에는 없다.
    const invoked = await supabase.functions.invoke<T>(functionName, {
      body,
      ...(options.signal ? ({ signal: options.signal } as { signal: AbortSignal }) : {}),
    });
    data = invoked.data;
    error = invoked.error;
  } catch (caught) {
    return {
      ok: false,
      message: caught instanceof Error ? caught.message : '요청을 보내지 못했어요.',
    };
  }

  // 성공 바디에도 { error, errorCode } 를 담아 200 으로 내려주는 함수가 있어
  // error 유무와 무관하게 바디를 먼저 훑는다.
  const context = readErrorContext(error);
  let status = context?.status;
  let errorCode = readCode(data);
  let serverMessage = readMessage(data);

  if (context?.json && (errorCode === undefined || serverMessage === undefined)) {
    try {
      const parsed = await context.json();
      errorCode ??= readCode(parsed);
      serverMessage ??= readMessage(parsed);
      status ??= context.status;
    } catch {
      // 4xx/5xx 바디가 JSON 이 아닌 경우 (게이트웨이 HTML 등).
      // status/errorCode 없이 아래 generic 메시지로 떨어진다.
    }
  }

  if (error !== null && error !== undefined) {
    return {
      ok: false,
      status,
      errorCode,
      message: serverMessage ?? `운세를 불러오지 못했어요. (${status ?? '네트워크 오류'})`,
    };
  }

  // 200 인데 바디에 `error` 를 실어 실패를 알리는 함수가 있다 (fortune-tarot 계열).
  // `message` 는 성공 바디에도 흔한 키라 여기서는 근거로 쓰지 않는다.
  const softFailure = readString(data, 'error');
  if (softFailure !== undefined) {
    return { ok: false, status, errorCode, message: softFailure };
  }

  return { ok: true, data: data as T };
}
