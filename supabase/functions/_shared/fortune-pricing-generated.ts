// AUTO-GENERATED FILE — DO NOT EDIT DIRECTLY.
//
// Source: packages/product-contracts/src/fortune-pricing.ts
// Regenerate: pnpm sync:edge-pricing
//
// 본 파일을 직접 수정하면 precommit / CI 가 fail. 가격 변경은 SoT 에서.

/**
 * Fortune 가격 SoT — 클라/Edge 양쪽이 단일 소스를 본다.
 *
 * 본 파일이 SoT. Edge Function 은 codegen (`scripts/sync-edge-pricing.ts`) 으로
 * 생성된 `supabase/functions/_shared/fortune-pricing-generated.ts` 를 import.
 * 클라이언트는 `fortune-catalog.ts` 가 본 파일의 lookup 으로 `costPoints` 채움.
 *
 * 가격 계층:
 *  - 1 (Light):    단순/짧은 텍스트 운세, 채팅 1턴 (배칭됨)
 *  - 5 (Mid):      중간 텍스트 + vision input (관상/손금/OOTD 등)
 *  - 12 (Heavy):   사주 등 장문 / 6K+ 출력 텍스트
 *  - 25 (Premium): 헤비 보고서 + 이미지 생성 1장 (~₩52 원가)
 *  - 50 (Ultra):   이미지 + 장문 통합 (전생/이상형/yearly 등)
 *
 * 모든 운세가 토큰을 소비함 (획득형 없음). free-chat / character-chat 도 1 토큰.
 *
 * 변경 절차:
 *  1. 본 파일에서 가격 추가/변경
 *  2. `pnpm sync:edge-pricing` 실행 → `fortune-pricing-generated.ts` 자동 갱신
 *  3. precommit / CI 가 generated 파일 sync 검증
 *  4. /ultrareview 자동 트리거 (FORTUNE_POINT_COSTS 변경)
 */

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
  'lucky-guide': 1,

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
  'weekly-review': 5,
  'face-reading': 5,
  'palm-reading': 5,
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
  'ootd-evaluation': 5,
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
  talent: 12,
  naming: 12,
  'baby-nickname': 12,
  employment: 12,

  // === Premium (25 토큰) — 이미지 생성 1장 또는 헤비 보고서 ===
  talisman: 25,
  'past-life-guide': 25,
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
  'past-life': 50,
  'yearly-encounter': 50,
  yearly: 50,
  'fashion-image': 50,

  // === 채팅/롤플레이 (1 토큰 per LLM 호출, 배칭됨) ===
  'free-chat': 1,
  'character-chat': 1,

  // === 카탈로그 13개 중 Edge SoT 신규 추가 — Step 1.6 결정 결과 ===
  // breathing: 단순 호흡 안내 텍스트 (Light) → 1P.
  // coaching: 대화 컨텍스트 읽고 장문 코칭 (Mid, career-coaching 5P 와 일관) → 5P.
  // daily-review: 하루 회고 LLM 정리 (Mid, weekly-review 5P 와 일관) → 5P.
  breathing: 1,
  coaching: 5,
  'daily-review': 5,
} as const

/**
 * SoT 키 — Edge 가 받는 모든 fortune type identifier.
 * `FortuneTypeId` 는 클라이언트 노출 type 의 sub set.
 */
export type FortunePricingKey = keyof typeof FORTUNE_POINT_COSTS

/**
 * 가격 lookup. 미정의 키는 1 (Edge fallback 동작과 일치).
 *
 * 클라가 `FortuneTypeId` 로 호출 시 SoT 에 없는 키 → 1P (방어적 fallback).
 * Edge 와 동일 동작이므로 클라/Edge drift 0.
 */
export function getFortuneCostPoints(
  key: string,
): number {
  return (FORTUNE_POINT_COSTS as Record<string, number>)[key] ?? 1
}

/**
 * 레거시 호환 alias — Edge 의 기존 import 경로 (`FORTUNE_TOKEN_COSTS`) 유지.
 */
export const FORTUNE_TOKEN_COSTS = FORTUNE_POINT_COSTS

export type FortuneType = FortunePricingKey
