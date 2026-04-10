// LLM 설정 관리

import { GEMINI_CHAT_MODEL, GEMINI_SAFE_TEXT_MODEL } from "./models.ts";

// 환경변수에서 Provider 결정 (단일 선택)
export const LLM_GLOBAL_CONFIG = {
  provider: (Deno.env.get("LLM_PROVIDER") || "gemini") as
    | "openai"
    | "gemini"
    | "anthropic"
    | "grok",
  defaultModel: Deno.env.get("LLM_DEFAULT_MODEL") || GEMINI_SAFE_TEXT_MODEL,
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
  "free-chat": GEMINI_CHAT_MODEL, // 대화 맥락 이해 개선
  "chat-insight": GEMINI_CHAT_MODEL, // 카톡 대화 분석 — 대화 맥락 이해 필요
};

export function getModelConfig(fortuneType: string) {
  return {
    provider: LLM_GLOBAL_CONFIG.provider,
    model: FORTUNE_SPECIFIC_MODELS[fortuneType] ||
      LLM_GLOBAL_CONFIG.defaultModel,
    temperature: LLM_GLOBAL_CONFIG.defaultTemperature,
    maxTokens: LLM_GLOBAL_CONFIG.defaultMaxTokens,
  };
}
