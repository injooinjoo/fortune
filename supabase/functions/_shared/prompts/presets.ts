// Generation 프리셋 정의

import { GenerationConfig } from './types.ts'

export const GenerationPresets: Record<string, GenerationConfig> = {
  // 표준 운세 (일반적인 운세 생성)
  standard: {
    temperature: 1.0,
    maxTokens: 8192,
    jsonMode: true,
  },

  // 분석형 (사주, 궁합 등 논리적 분석)
  analytical: {
    temperature: 0.7,
    maxTokens: 8192,
    jsonMode: true,
  },

  // 창의형 (꿈해몽, 타로 등 해석적 콘텐츠)
  creative: {
    temperature: 0.9,
    maxTokens: 4096,
    jsonMode: true,
  },

  // 간결형 (짧은 응답 필요)
  concise: {
    temperature: 0.7,
    maxTokens: 2048,
    jsonMode: true,
  },

  // 긴 컨텍스트 (복잡한 분석)
  longContext: {
    temperature: 0.8,
    maxTokens: 16384,
    jsonMode: true,
  },
}

// 운세 타입별 기본 프리셋 매핑
export const FortunePresetMapping: Record<string, keyof typeof GenerationPresets> = {
  daily: 'standard',
  love: 'standard',
  career: 'standard',
  health: 'standard',
  moving: 'standard',
  compatibility: 'analytical',
  'blind-date': 'standard',
  'ex-lover': 'standard',
  dream: 'creative',
  'face-reading': 'creative',
  biorhythm: 'analytical',
  'avoid-people': 'standard',
  'lucky-series': 'standard',
  talent: 'standard',
  'lucky-items': 'standard',
  investment: 'analytical',
  time: 'standard',
  mbti: 'standard',
  'traditional-saju': 'analytical',
  'pet-compatibility': 'standard',
  'family-harmony': 'standard',
}

export function getPresetForFortune(fortuneType: string): GenerationConfig {
  const presetName = FortunePresetMapping[fortuneType] || 'standard'
  return GenerationPresets[presetName]
}
