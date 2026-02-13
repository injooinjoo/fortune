export interface FortuneRequest {
  name?: string
  birthDate?: string
  birthTime?: string
  isLunar?: boolean
  gender?: 'male' | 'female'
  partnerName?: string
  partnerBirthDate?: string
  mbtiType?: string
  bloodType?: string
  zodiacSign?: string
  additionalInfo?: Record<string, any>
}

export interface FortuneResponse {
  fortune: {
    title: string
    description: string
    details?: Record<string, any>
    advice?: string
    luckyItems?: string[]
    warnings?: string[]
    score?: number
    period?: string
  }
  tokensUsed: number
  generatedAt: string
}

export interface TokenInfo {
  balance: number
  required: number
  sufficient: boolean
}

// 포인트 비용 체계 (API 비용 기반)
// 모든 운세가 포인트를 소비함 (획득형 없음)
export const FORTUNE_POINT_COSTS = {
  // === 기본 운세 (1-2P) - Gemini Flash Lite ===
  daily: 1,
  daily_calendar: 1,
  today: 1,
  tomorrow: 1,
  hourly: 1,
  'lucky-color': 2,
  'lucky-number': 2,
  'lucky-food': 2,
  'lucky-outfit': 2,
  'lucky-items': 2,
  'fortune-cookie': 1,
  birthstone: 2,
  'blood-type': 2,
  'zodiac-animal': 2,
  zodiac: 2,

  // === 중급 운세 (3-5P) - Gemini Flash ===
  love: 4,
  career: 4,
  wealth: 4,
  health: 3,
  compatibility: 5,
  tarot: 5,
  dream: 3,
  biorhythm: 3,
  mbti: 3,
  personality: 3,
  'personality-dna': 4,
  weekly: 4,
  monthly: 5,
  'birth-season': 3,
  birthdate: 3,
  'avoid-people': 3,
  'lucky-place': 3,
  'lucky-series': 3,
  'lucky-baseball': 3,
  'lucky-golf': 3,
  'lucky-tennis': 3,
  'lucky-cycling': 3,
  'lucky-running': 3,
  'lucky-hiking': 3,
  'lucky-fishing': 3,
  'lucky-swim': 3,
  'lucky-fitness': 3,
  'lucky-yoga': 3,
  wish: 4,
  talisman: 4,
  talent: 4,
  naming: 4,
  'baby-nickname': 4,
  baby_nickname: 4,
  babyNickname: 4,
  moving: 4,
  'moving-date': 4,

  // === 프리미엄 운세 (8-15P) - GPT/Claude ===
  saju: 12,
  'traditional-saju': 12,
  traditional_saju: 12,
  'traditional-unified': 12,
  'saju-psychology': 10,
  tojeong: 12,
  'past-life': 10,
  destiny: 15,
  marriage: 12,
  'couple-match': 10,
  chemistry: 8,
  'ex-lover': 10,
  ex_lover: 10,
  'blind-date': 8,
  blind_date: 8,
  'celebrity-match': 8,
  'traditional-compatibility': 12,
  palmistry: 10,
  physiognomy: 12,
  'face-reading': 15,
  timeline: 12,
  'lucky-exam': 8,
  exam: 8,
  network: 10,
  'network-report': 15,

  // === 채팅/롤플레이 (4P per message) ===
  'free-chat': 4,
  'character-chat': 4,

  // === 울트라 프리미엄 (20-50P) ===
  startup: 30,
  business: 30,
  'lucky-investment': 35,
  'lucky-realestate': 30,
  'lucky-stock': 30,
  'lucky-crypto': 30,
  'lucky-sidejob': 25,
  celebrity: 25,
  'five-blessings': 30,
  yearly: 50,
  'new-year': 20,
  'lucky-lottery': 25,
  employment: 20,
  salpuli: 15,
  'health-document': 10,
  'fashion-image': 35,
  'lucky-job': 8,
} as const

// 레거시 호환성을 위한 alias
export const FORTUNE_TOKEN_COSTS = FORTUNE_POINT_COSTS

export type FortuneType = keyof typeof FORTUNE_TOKEN_COSTS
