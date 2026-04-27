import type { BranchKr, Element, InteractionType } from '../types.ts';

/** 삼합: 3개 지지로 이뤄짐 → 결과 오행 */
export const SAM_HAP: Array<{ branches: [BranchKr, BranchKr, BranchKr]; element: Element }> = [
  { branches: ['신', '자', '진'], element: '수' },
  { branches: ['해', '묘', '미'], element: '목' },
  { branches: ['인', '오', '술'], element: '화' },
  { branches: ['사', '유', '축'], element: '금' },
];

/** 육합: 2개 지지 쌍 → 결과 오행 */
export const YUK_HAP: Array<{ pair: [BranchKr, BranchKr]; element: Element }> = [
  { pair: ['자', '축'], element: '토' },
  { pair: ['인', '해'], element: '목' },
  { pair: ['묘', '술'], element: '화' },
  { pair: ['진', '유'], element: '금' },
  { pair: ['사', '신'], element: '수' },
  { pair: ['오', '미'], element: '화' }, // 오미합은 '화' (일부 유파) or '토'
];

/** 방합 (계절별 삼방합): 3개 지지 → 결과 오행 */
export const BANG_HAP: Array<{ branches: [BranchKr, BranchKr, BranchKr]; element: Element }> = [
  { branches: ['인', '묘', '진'], element: '목' },
  { branches: ['사', '오', '미'], element: '화' },
  { branches: ['신', '유', '술'], element: '금' },
  { branches: ['해', '자', '축'], element: '수' },
];

/** 육충 (6쌍, 대칭적) */
export const YUK_CHUNG: Array<[BranchKr, BranchKr]> = [
  ['자', '오'],
  ['축', '미'],
  ['인', '신'],
  ['묘', '유'],
  ['진', '술'],
  ['사', '해'],
];

/**
 * 삼형 (무은지형/지세지형/무예지형)
 * - 인사신 (무은지형)
 * - 축술미 (지세지형)
 * - 자묘 (무예지형) — 자형
 * - 진오유해 (자형)
 */
export const SAM_HYUNG: Array<[BranchKr, BranchKr, BranchKr]> = [
  ['인', '사', '신'],
  ['축', '술', '미'],
];

/** 상형 (2개 지지): 자묘 */
export const SANG_HYUNG: Array<[BranchKr, BranchKr]> = [
  ['자', '묘'],
];

/** 자형: 진진, 오오, 유유, 해해 (같은 지지가 두 번 이상 나오면) */
export const JA_HYUNG: readonly BranchKr[] = ['진', '오', '유', '해'];

/** 육파 (6쌍) */
export const YUK_PA: Array<[BranchKr, BranchKr]> = [
  ['자', '유'],
  ['오', '묘'],
  ['신', '사'],
  ['인', '해'],
  ['진', '축'],
  ['술', '미'],
];

/** 육해 (6쌍) */
export const YUK_HAE: Array<[BranchKr, BranchKr]> = [
  ['자', '미'],
  ['축', '오'],
  ['인', '사'],
  ['묘', '진'],
  ['신', '해'],
  ['유', '술'],
];

/** 원진 (6쌍) */
export const WON_JIN: Array<[BranchKr, BranchKr]> = [
  ['자', '미'],
  ['축', '오'],
  ['인', '유'],
  ['묘', '신'],
  ['진', '해'],
  ['사', '술'],
];

/** 귀문 (6쌍) — 원진과 겹치는 경우 있음 */
export const GUIMUN: Array<[BranchKr, BranchKr]> = [
  ['자', '유'],
  ['축', '오'],
  ['인', '미'],
  ['묘', '신'],
  ['진', '해'],
  ['사', '술'],
];

/** 페어 매칭 유틸 */
export function pairMatches(
  a: BranchKr,
  b: BranchKr,
  table: Array<[BranchKr, BranchKr]>,
): boolean {
  return table.some(([x, y]) => (x === a && y === b) || (x === b && y === a));
}

export type { InteractionType };
