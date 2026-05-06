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

// 가격 SoT — packages/product-contracts/src/fortune-pricing.ts.
// 본 파일은 generated 파일에서 re-export. 직접 수정 금지.
// 가격 변경: SoT 수정 → `pnpm sync:edge-pricing` → fortune-pricing-generated.ts 자동 갱신.
//
// 가격 계층:
//  - 1 (Light): 단순/짧은 텍스트, 채팅 1턴
//  - 5 (Mid): 중간 텍스트 + vision (관상/손금/OOTD 등)
//  - 12 (Heavy): 사주 장문, 6K+ 출력
//  - 25 (Premium): 헤비 보고서 + 이미지 1장
//  - 50 (Ultra): 이미지 + 장문 통합 (전생/이상형/yearly)
export {
  FORTUNE_POINT_COSTS,
  FORTUNE_TOKEN_COSTS,
  type FortuneType,
} from './fortune-pricing-generated.ts'

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
