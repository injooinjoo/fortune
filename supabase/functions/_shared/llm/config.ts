// LLM 설정 관리

import {
  GEMINI_CHAT_MODEL,
  GEMINI_SAFE_TEXT_MODEL,
  OPENROUTER_SAFE_TEXT_MODEL,
} from "./models.ts";

export type LlmProviderId =
  | "openai"
  | "gemini"
  | "anthropic"
  | "grok"
  | "openrouter";

const ENV_PROVIDER =
  (Deno.env.get("LLM_PROVIDER") || "gemini") as LlmProviderId;
const ENV_DEFAULT_MODEL = Deno.env.get("LLM_DEFAULT_MODEL")?.trim();

// 환경변수에서 Provider 결정 (단일 선택)
export const LLM_GLOBAL_CONFIG = {
  provider: ENV_PROVIDER,
  // OpenRouter 는 "<vendor>/<model>" 슬러그를 쓰므로 Gemini 모델 ID 를 기본값으로
  // 쓰면 요청이 그대로 실패한다. provider 에 맞는 기본 모델을 고른다.
  defaultModel: ENV_DEFAULT_MODEL ||
    (ENV_PROVIDER === "openrouter"
      ? OPENROUTER_SAFE_TEXT_MODEL
      : GEMINI_SAFE_TEXT_MODEL),
  defaultTemperature: 0.7,
  defaultMaxTokens: 2048,
} as const;

// 운세별 커스텀 모델 (선택사항)
export const FORTUNE_SPECIFIC_MODELS: Record<string, string | undefined> = {
  "moving": GEMINI_SAFE_TEXT_MODEL,
  "tarot": GEMINI_SAFE_TEXT_MODEL,
  "love": GEMINI_SAFE_TEXT_MODEL,
  "daily": GEMINI_SAFE_TEXT_MODEL,
  "career": GEMINI_SAFE_TEXT_MODEL,
  "health": GEMINI_SAFE_TEXT_MODEL,
  "mbti": GEMINI_SAFE_TEXT_MODEL,
  "compatibility": GEMINI_SAFE_TEXT_MODEL,
  "exam": GEMINI_SAFE_TEXT_MODEL,
  "investment": GEMINI_SAFE_TEXT_MODEL,
  "talent": GEMINI_SAFE_TEXT_MODEL,
  "face-reading": GEMINI_SAFE_TEXT_MODEL,
  "dream": GEMINI_SAFE_TEXT_MODEL,
  "avoid-people": GEMINI_SAFE_TEXT_MODEL,
  "blind-date": GEMINI_SAFE_TEXT_MODEL,
  "ex-lover": GEMINI_SAFE_TEXT_MODEL,
  "lucky-series": GEMINI_SAFE_TEXT_MODEL,
  "fortune-celebrity": GEMINI_SAFE_TEXT_MODEL,
  "fortune-pet": GEMINI_SAFE_TEXT_MODEL,
  "ootd-evaluation": GEMINI_SAFE_TEXT_MODEL,
  "fortune-recommend": GEMINI_SAFE_TEXT_MODEL,
  "fortune-past-life": GEMINI_SAFE_TEXT_MODEL,
  "wealth": GEMINI_SAFE_TEXT_MODEL,
  "talisman": GEMINI_SAFE_TEXT_MODEL,
  "yearly-encounter": GEMINI_SAFE_TEXT_MODEL,
  "saju-interpret": GEMINI_SAFE_TEXT_MODEL, // 만세력 AI 해석 (Sprint 3)
  "free-chat": GEMINI_CHAT_MODEL, // 대화 맥락 이해 개선
  "chat-insight": GEMINI_CHAT_MODEL, // 카톡 대화 분석 — 대화 맥락 이해 필요
};

export function getModelConfig(fortuneType: string) {
  return {
    provider: LLM_GLOBAL_CONFIG.provider,
    // FORTUNE_SPECIFIC_MODELS 는 Gemini 모델 ID 목록이라 OpenRouter 에서는 쓸 수 없다.
    model: LLM_GLOBAL_CONFIG.provider === "openrouter"
      ? LLM_GLOBAL_CONFIG.defaultModel
      : FORTUNE_SPECIFIC_MODELS[fortuneType] || LLM_GLOBAL_CONFIG.defaultModel,
    temperature: LLM_GLOBAL_CONFIG.defaultTemperature,
    maxTokens: LLM_GLOBAL_CONFIG.defaultMaxTokens,
  };
}
