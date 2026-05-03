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

// BM v2.2 토큰 가격 체계 — 6단계: 0 / 1 / 5 / 12 / 25 / 50.
// 원가 (LLM input/output + 이미지 생성) + 사용자 perception 기준 정합.
//
// - 0: daily 1회/일 무료 (별도 daily_free_fortune 로직)
// - 1 (Light): 단순/짧은 텍스트 운세, 채팅 1턴 (배칭됨)
// - 5 (Mid): 중간 텍스트 + vision input (관상/손금/OOTD 등)
// - 12 (Heavy): 사주 등 장문 / 6K+ 출력 텍스트
// - 25 (Premium): 헤비 텍스트 보고서 + **이미지 생성 1장** (₩52 원가)
// - 50 (Ultra): 이미지 + 장문 통합 (전생/이상형/yearly 등)
//
// 모든 운세가 토큰을 소비함 (획득형 없음). free-chat / character-chat 도 1 토큰.
export const FORTUNE_POINT_COSTS = {
  // === Light (1 토큰) ===
  daily: 1,
  'daily-calendar': 1,
  today: 1,
  tomorrow: 1,
  hourly: 1,
  'lucky-color': 1,
  'lucky-number': 1,
  'lucky-food': 1,
  'lucky-outfit': 1,
  'lucky-items': 1,
  'lucky-place': 1,
  'lucky-series': 1,
  'lucky-baseball': 1,
  'lucky-golf': 1,
  'lucky-tennis': 1,
  'lucky-cycling': 1,
  'lucky-running': 1,
  'lucky-hiking': 1,
  'lucky-fishing': 1,
  'lucky-swim': 1,
  'lucky-fitness': 1,
  'lucky-yoga': 1,
  'lucky-job': 1,
  'fortune-cookie': 1,
  birthstone: 1,
  'blood-type': 1,
  'zodiac-animal': 1,
  zodiac: 1,
  mbti: 1,
  dream: 1,
  'birth-season': 1,
  birthdate: 1,

  // === Mid (5 토큰) ===
  love: 5,
  career: 5,
  wealth: 5,
  health: 5,
  compatibility: 5,
  tarot: 5,
  biorhythm: 5,
  personality: 5,
  'personality-dna': 5,
  weekly: 5,
  monthly: 5,
  'avoid-people': 5,
  wish: 5,
  moving: 5,
  'moving-date': 5,
  'couple-match': 5,
  chemistry: 5,
  'ex-lover': 5,
  'blind-date': 5,
  'celebrity-match': 5,
  'lucky-exam': 5,
  exam: 5,
  'face-reading': 5,        // vision input 만, 텍스트 출력 위주
  'palm-reading': 5,        // vision input 만
  palmistry: 5,
  physiognomy: 5,
  'ootd-guide': 5,
  'hair-style-guide': 5,
  'face-reading-guide': 5,
  'blind-date-guide': 5,
  'health-document': 5,
  'beauty-simulation': 5,
  exercise: 5,
  'match-insight': 5,
  'ootd-evaluation': 5,        // vision input
  'game-enhance': 5,
  pet: 5,
  'pet-compatibility': 5,
  family: 5,
  'family-health': 5,
  'family-children': 5,
  'family-wealth': 5,
  'family-relationship': 5,
  'career-coaching': 5,
  decision: 5,
  'lucky-guide': 1,

  // === Heavy (12 토큰) ===
  saju: 12,
  'traditional-saju': 12,
  'traditional-unified': 12,
  'saju-psychology': 12,
  'traditional-compatibility': 12,
  tojeong: 12,
  destiny: 12,
  marriage: 12,
  timeline: 12,
  network: 12,
  salpuli: 12,
  talent: 12,               // 실측 출력 6.8K 토큰 — Heavy 적정
  naming: 12,
  'baby-nickname': 12,
  employment: 12,

  // === Premium (25 토큰) — 이미지 생성 1장 또는 헤비 보고서 ===
  talisman: 25,             // 이미지 생성 (gpt-image-1-mini, ~₩30)
  'past-life-guide': 25,    // 이미지 생성
  'network-report': 25,
  'new-year': 25,
  startup: 25,
  business: 25,
  'lucky-investment': 25,
  'lucky-realestate': 25,
  'lucky-stock': 25,
  'lucky-crypto': 25,
  'lucky-sidejob': 25,
  'lucky-lottery': 25,
  'five-blessings': 25,
  celebrity: 25,

  // === Ultra (50 토큰) — 이미지 + 장문 + 헤비 작업 ===
  'past-life': 50,            // 전생 초상화 (이미지 생성, ₩52)
  'yearly-encounter': 50,     // 이상형 만남 (이미지 생성)
  yearly: 50,
  'fashion-image': 50,        // 이미지 생성

  // === 채팅/롤플레이 (1 토큰 per LLM 호출, 배칭됨) ===
  // 5s idle window 안에 사용자가 N개 메시지를 보내도 batched 되어
  // edge function 은 1 회만 호출되므로 1 토큰만 차감된다.
  'free-chat': 1,
  'character-chat': 1,
} as const

// 레거시 호환성을 위한 alias
export const FORTUNE_TOKEN_COSTS = FORTUNE_POINT_COSTS

export type FortuneType = keyof typeof FORTUNE_TOKEN_COSTS

/**
 * fortuneType 키를 canonical kebab-case 로 정규화한다.
 * DB 에 dailyCalendar / daily_calendar / daily-calendar 가 혼재해 토큰
 * 차감 lookup 이 깨지는 사례 차단. soul-consume 등 entry point 에서 사용.
 */
export function normalizeFortuneType(input: string): string {
  return input
    .replace(/_/g, "-")
    .replace(/([a-z0-9])([A-Z])/g, "$1-$2")
    .toLowerCase();
}
