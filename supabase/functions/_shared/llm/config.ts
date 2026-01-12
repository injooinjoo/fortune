// LLM 설정 관리

// 환경변수에서 Provider 결정 (단일 선택)
export const LLM_GLOBAL_CONFIG = {
  provider: (Deno.env.get('LLM_PROVIDER') || 'gemini') as 'openai' | 'gemini' | 'anthropic' | 'grok',
  defaultModel: Deno.env.get('LLM_DEFAULT_MODEL') || 'gemini-2.0-flash-lite',
  defaultTemperature: 1,
  defaultMaxTokens: 8192,
} as const

// 운세별 커스텀 모델 (선택사항)
export const FORTUNE_SPECIFIC_MODELS: Record<string, string | undefined> = {
  'moving': 'gemini-2.0-flash-lite',
  'tarot': 'gemini-2.0-flash-lite',
  'love': 'gemini-2.0-flash-lite',
  'daily': 'gemini-2.0-flash-lite',
  'career': 'gemini-2.0-flash-lite',
  'health': 'gemini-2.0-flash-lite',
  'mbti': 'gemini-2.0-flash-lite',
  'compatibility': 'gemini-2.0-flash-lite',
  'exam': 'gemini-2.0-flash-lite',
  'investment': 'gemini-2.0-flash-lite',
  'talent': 'gemini-2.0-flash-lite',
  'face-reading': 'gemini-2.0-flash-lite',
  'dream': 'gemini-2.0-flash-lite',
  'avoid-people': 'gemini-2.0-flash-lite',
  'blind-date': 'gemini-2.0-flash-lite',
  'ex-lover': 'gemini-2.0-flash-lite',
  'lucky-series': 'gemini-2.0-flash-lite',
  'fortune-celebrity': 'gemini-2.0-flash-lite',
  'fortune-pet': 'gemini-2.0-flash-lite',
  'ootd-evaluation': 'gemini-2.0-flash-lite',
  'fortune-recommend': 'gemini-2.0-flash-lite',
  'fortune-past-life': 'gemini-2.0-flash-lite',
  'wealth': 'gemini-2.0-flash-lite',
  'talisman': 'gemini-2.0-flash-lite',
  'yearly-encounter': 'gemini-2.0-flash-lite',
  'free-chat': 'gemini-2.0-flash-lite',
}

export function getModelConfig(fortuneType: string) {
  return {
    provider: LLM_GLOBAL_CONFIG.provider,
    model: FORTUNE_SPECIFIC_MODELS[fortuneType] || LLM_GLOBAL_CONFIG.defaultModel,
    temperature: LLM_GLOBAL_CONFIG.defaultTemperature,
    maxTokens: LLM_GLOBAL_CONFIG.defaultMaxTokens,
  }
}
