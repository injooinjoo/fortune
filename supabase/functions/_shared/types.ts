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

export const FORTUNE_TOKEN_COSTS = {
  daily: 1,
  today: 1,
  tomorrow: 1,
  weekly: 2,
  monthly: 3,
  yearly: 5,
  hourly: 1,
  saju: 5,
  'traditional-saju': 5,
  'saju-psychology': 4,
  tojeong: 4,
  salpuli: 3,
  palmistry: 3,
  physiognomy: 4,
  mbti: 2,
  personality: 2,
  'blood-type': 2,
  love: 3,
  marriage: 4,
  compatibility: 4,
  'traditional-compatibility': 4,
  'couple-match': 3,
  'blind-date': 3,
  'ex-lover': 3,
  'celebrity-match': 2,
  chemistry: 3,
  career: 3,
  employment: 3,
  business: 4,
  startup: 4,
  'lucky-job': 2,
  wealth: 3,
  health: 3,
  destiny: 5,
  'past-life': 4,
  talent: 3,
  network: 3,
  timeline: 4,
  biorhythm: 3,
  'birth-season': 2,
  birthdate: 2,
  birthstone: 2,
  'zodiac-animal': 2,
  zodiac: 2,
  'five-blessings': 3,
  wish: 3,
  'avoid-people': 2,
  'lucky-number': 2,
  'lucky-color': 2,
  'lucky-items': 2,
  'lucky-food': 2,
  'lucky-place': 2,
  'lucky-outfit': 2,
  'lucky-series': 3,
  'lucky-lottery': 3,
  'lucky-stock': 3,
  'lucky-crypto': 3,
  'lucky-investment': 3,
  'lucky-realestate': 3,
  'lucky-sidejob': 3,
  'lucky-baseball': 2,
  'lucky-golf': 2,
  'lucky-tennis': 2,
  'lucky-cycling': 2,
  'lucky-running': 2,
  'lucky-hiking': 2,
  'lucky-fishing': 2,
  'lucky-swim': 2,
  'lucky-fitness': 2,
  'lucky-yoga': 2,
  'lucky-exam': 3,
  moving: 3,
  'moving-date': 3,
  'new-year': 4,
  'face-reading': 4,
  celebrity: 3,
  talisman: 3,
  'network-report': 3
} as const

export type FortuneType = keyof typeof FORTUNE_TOKEN_COSTS