// 영혼 시스템 비율 정의
// 무료 운세는 영혼을 획득하고, 프리미엄 운세는 영혼을 소비합니다.

// 영혼을 획득하는 무료 운세 (양수)
export const SOUL_EARN_RATES: Record<string, number> = {
  // 기본 운세 (1-2 영혼 획득)
  'daily': 1,
  'today': 1,
  'tomorrow': 1,
  'lucky-color': 1,
  'lucky-number': 1,
  'lucky-food': 1,
  'lucky-outfit': 1,
  'lucky-items': 1,
  'fortune-cookie': 1,
  'birthstone': 2,
  'blood-type': 2,
  'zodiac-animal': 2,
  'zodiac': 2,
  
  // 중급 운세 (3-5 영혼 획득)
  'love': 3,
  'career': 3,
  'wealth': 3,
  'health': 3,
  'compatibility': 4,
  'tarot': 4,
  'dream': 3,
  'biorhythm': 3,
  'mbti': 3,
  'personality': 3,
  'weekly': 4,
  'monthly': 5,
  'birth-season': 3,
  'birthdate': 3,
  'avoid-people': 2,
  'lucky-place': 2,
  'lucky-series': 3,
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
  'wish': 3,
  'talisman': 3,
}

// 영혼을 소비하는 프리미엄 운세 (음수로 저장)
export const SOUL_CONSUME_RATES: Record<string, number> = {
  // 프리미엄 운세 (10-20 영혼 소비)
  'saju': -15,
  'traditional-saju': -15,
  'saju-psychology': -12,
  'tojeong': -15,
  'past-life': -18,
  'destiny': -20,
  'marriage': -15,
  'couple-match': -12,
  'chemistry': -10,
  'ex-lover': -12,
  'blind-date': -10,
  'celebrity-match': -10,
  'traditional-compatibility': -15,
  'palmistry': -12,
  'physiognomy': -15,
  'face-reading': -15,
  'timeline': -15,
  'talent': -12,
  'lucky-exam': -10,
  'moving': -15,
  'moving-date': -15,
  
  // 울트라 프리미엄 운세 (30-50 영혼 소비)
  'startup': -30,
  'business': -35,
  'lucky-investment': -40,
  'lucky-realestate': -35,
  'lucky-stock': -35,
  'lucky-crypto': -35,
  'lucky-sidejob': -30,
  'celebrity': -30,
  'network-report': -30,
  'five-blessings': -35,
  'yearly': -50,
  'new-year': -20,
  'lucky-lottery': -30,
  'employment': -25,
  'salpuli': -20,
}

// 특별 조건부 운세
export const SOUL_CONDITIONAL_RATES: Record<string, any> = {
  'hourly': {
    freeCount: 3,
    freeAmount: 1,
    paidAmount: -5,
  },
}

// 운세 타입에 따른 영혼 양 반환
export function getSoulAmount(fortuneType: string): number {
  // 먼저 획득 목록에서 확인
  if (SOUL_EARN_RATES[fortuneType] !== undefined) {
    return SOUL_EARN_RATES[fortuneType]
  }
  
  // 소비 목록에서 확인
  if (SOUL_CONSUME_RATES[fortuneType] !== undefined) {
    return SOUL_CONSUME_RATES[fortuneType]
  }
  
  // 조건부 운세는 별도 처리 필요
  if (SOUL_CONDITIONAL_RATES[fortuneType]) {
    return 0 // 조건부는 별도 로직으로 처리
  }
  
  // 정의되지 않은 운세는 기본값 1 획득
  return 1
}

// 프리미엄 운세인지 확인
export function isPremiumFortune(fortuneType: string): boolean {
  return SOUL_CONSUME_RATES[fortuneType] !== undefined
}

// 무료 운세인지 확인
export function isFreeFortune(fortuneType: string): boolean {
  return SOUL_EARN_RATES[fortuneType] !== undefined
}

// 영혼 액션 타입
export enum SoulActionType {
  EARN = 'earn',
  CONSUME = 'consume',
  CONDITIONAL = 'conditional'
}

// 영혼 액션 타입 반환
export function getSoulActionType(fortuneType: string): SoulActionType {
  if (SOUL_EARN_RATES[fortuneType] !== undefined) {
    return SoulActionType.EARN
  } else if (SOUL_CONSUME_RATES[fortuneType] !== undefined) {
    return SoulActionType.CONSUME
  } else if (SOUL_CONDITIONAL_RATES[fortuneType]) {
    return SoulActionType.CONDITIONAL
  }
  return SoulActionType.EARN // 기본값
}