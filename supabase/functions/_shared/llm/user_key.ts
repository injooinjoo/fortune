// 사용자 소유 LLM 키(BYOK) 해석기.
//
// 사용자가 user-llm-key Edge Function 으로 자기 키를 연결해두면, 운세 함수는
// 플랫폼 키 대신 그 키로 생성한다. 이 모듈이 그 "사용자 키가 있는가" 판정과
// 복호화, 그리고 **provider 인스턴스 생성까지** 담당한다.
//
// ⚠️⚠️ 복호화된 `apiKey` 는 **사용자의 서드파티 자격증명 평문**이다. 그래서 이
//      모듈은 평문을 밖으로 반환하지 않는다 — `createUserLlmProvider` 가 provider
//      인스턴스를 만들어 돌려주고, 평문은 그 인스턴스 안에만 남는다.
//      다음을 절대 하지 말 것:
//        - console.log / console.error / 어떤 로깅에도 넣기
//        - HTTP 응답 본문이나 에러 메시지에 싣기 (스택 트레이스 포함)
//        - DB / 캐시 / 파일에 다시 쓰기
//        - LLM 프롬프트 본문에 넣기
//      허용된 용도는 provider 호출의 Authorization 헤더뿐이다.
//      provider 가 4xx 를 주더라도 그 응답 본문을 클라이언트로 되돌리지 말 것 —
//      일부 provider 는 에러 메시지에 요청한 키를 그대로 되비춘다.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { buildRecordAad, decryptSecret } from "./crypto.ts";
import type { ILLMProvider } from "./types.ts";
import { GeminiProvider } from "./providers/gemini.ts";
import { OpenAIProvider } from "./providers/openai.ts";
import { AnthropicProvider } from "./providers/anthropic.ts";
import { GrokProvider } from "./providers/grok.ts";
import { OpenRouterProvider } from "./providers/openrouter.ts";
import { GEMINI_SAFE_TEXT_MODEL, OPENROUTER_SAFE_TEXT_MODEL } from "./models.ts";

/** user_llm_keys.provider CHECK 제약과 반드시 일치해야 한다. */
export const USER_LLM_PROVIDERS = [
  "openai",
  "gemini",
  "anthropic",
  "grok",
  "openrouter",
] as const;

export type UserLlmProvider = typeof USER_LLM_PROVIDERS[number];

export function isUserLlmProvider(value: unknown): value is UserLlmProvider {
  return typeof value === "string" &&
    (USER_LLM_PROVIDERS as readonly string[]).includes(value);
}

/**
 * 사용자가 모델을 고르지 않았을 때 쓰는 provider 별 기본 모델.
 * 전부 각 벤더의 최저가 텍스트 모델이다 — 요금을 내는 쪽이 사용자이므로
 * 우리가 임의로 비싼 모델을 고르지 않는다.
 */
const DEFAULT_USER_MODELS: Record<UserLlmProvider, string> = {
  openai: "gpt-4o-mini",
  gemini: GEMINI_SAFE_TEXT_MODEL,
  anthropic: "claude-3-5-haiku-latest",
  grok: "grok-3-mini-fast",
  openrouter: OPENROUTER_SAFE_TEXT_MODEL,
};

/** 호출부(운세 함수)가 로깅/분기에 쓸 수 있는 **비밀이 아닌** 정보. */
export interface UserProviderSelection {
  provider: UserLlmProvider;
  model: string;
}

export interface UserProviderResult extends UserProviderSelection {
  /** 사용자 키로 만든 provider. 평문 키는 이 인스턴스 안에만 있다. */
  llm: ILLMProvider;
}

interface ResolvedUserKey {
  provider: UserLlmProvider;
  model: string | null;
  /** ⚠️ 평문 자격증명. 이 모듈 밖으로 나가지 않는다. */
  apiKey: string;
}

function createServiceClient() {
  return createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    { auth: { autoRefreshToken: false, persistSession: false } },
  );
}

/**
 * 사용자의 활성 + 검증된 BYOK 키를 하나 골라 복호화한다. (모듈 내부 전용)
 *
 * user_llm_keys 는 RLS 정책이 0개라 service_role 클라이언트로만 읽힌다.
 *
 * @returns 쓸 수 있는 키가 없으면 null → 호출부는 플랫폼 키로 폴백한다.
 *          조회/복호화 실패도 null 로 떨어뜨린다. 사용자 키 문제로 운세 생성
 *          자체가 실패하는 것보다 플랫폼 키 폴백이 낫다.
 *
 * 여러 provider 를 연결했으면 **가장 최근에 검증된 것**을 쓴다. 사용자가 방금
 * 연결/재검증한 키가 곧 그가 쓰려는 키라는 가정이고, 우선순위를 우리가 임의로
 * 매기지 않는다.
 */
async function resolveUserKey(userId: string): Promise<ResolvedUserKey | null> {
  if (!userId) return null;

  // ciphertext / iv 는 여기서만 읽고 밖으로 내보내지 않는다.
  const { data, error } = await createServiceClient()
    .from("user_llm_keys")
    .select("provider, model, ciphertext, iv")
    .eq("user_id", userId)
    .eq("is_active", true)
    .not("verified_at", "is", null)
    .order("verified_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (error) {
    console.warn(`[user_key] BYOK 조회 실패 (플랫폼 키로 폴백): ${error.message}`);
    return null;
  }
  if (!data) return null;

  if (!isUserLlmProvider(data.provider)) {
    // CHECK 제약이 있으므로 정상 경로에서는 도달 불가. 도달했다면 스키마 drift.
    console.warn(`[user_key] 알 수 없는 provider: ${String(data.provider)}`);
    return null;
  }

  let apiKey: string;
  try {
    apiKey = await decryptSecret(
      data.ciphertext as string,
      data.iv as string,
      buildRecordAad(userId, data.provider),
    );
  } catch (e) {
    // e.message 에는 암호문/키가 들어가지 않는다 (crypto.ts 참고).
    console.warn(
      `[user_key] BYOK 복호화 실패 (플랫폼 키로 폴백): ${
        e instanceof Error ? e.message : "unknown"
      }`,
    );
    return null;
  }

  if (!apiKey) return null;

  const model = typeof data.model === "string" && data.model.trim()
    ? data.model.trim()
    : null;

  return { provider: data.provider, model, apiKey };
}

/**
 * 사용자 키로 만든 LLM provider 를 돌려준다. 없으면 null → 플랫폼 키로 폴백.
 *
 * 운세/채팅 함수에서의 사용법:
 *
 *   const llm = await LLMFactory.createFromConfigAsync(fortuneType, userId);
 *
 * 를 쓰면 이 함수가 자동으로 먼저 시도된다. 직접 부를 일은 거의 없다.
 *
 * `billingOwner: "user"` 를 넘기는 이유: 이 호출의 요금은 사용자 계정에 찍히므로
 * 플랫폼 예산 가드(LLM_ENABLED_PROVIDERS 화이트리스트, Gemini 서킷, 지출 상한)를
 * 적용하지 않는다. 킬 스위치(LLM_DISABLED_PROVIDERS)는 그대로 걸린다.
 */
export async function createUserLlmProvider(
  userId: string | null | undefined,
  fortuneType: string,
): Promise<UserProviderResult | null> {
  if (!userId) return null;

  const resolved = await resolveUserKey(userId);
  if (!resolved) return null;

  const model = resolved.model ?? DEFAULT_USER_MODELS[resolved.provider];
  const config = {
    apiKey: resolved.apiKey,
    model,
    featureName: fortuneType,
    billingOwner: "user" as const,
  };

  let llm: ILLMProvider;
  switch (resolved.provider) {
    case "openai":
      llm = new OpenAIProvider(config);
      break;
    case "gemini":
      llm = new GeminiProvider(config);
      break;
    case "anthropic":
      llm = new AnthropicProvider(config);
      break;
    case "grok":
      llm = new GrokProvider(config);
      break;
    case "openrouter":
      llm = new OpenRouterProvider(config);
      break;
  }

  // provider / model / fortuneType 만 남긴다. 키는 절대 로그에 넣지 않는다.
  console.log(
    `🔑 [user_key] 사용자 키 사용: ${resolved.provider}/${model} / ${fortuneType}`,
  );

  return { provider: resolved.provider, model, llm };
}
