/**
 * 12신살 (년지 기준 지지 고정 매핑).
 *
 *   년지\순위  겁살 재살 천살 지살 연살 월살 망신 장성 반안 역마 육해 화개
 *   寅午戌    해   자   축   인   묘   진   사   오   미   신   유   술
 *   巳酉丑    인   묘   진   사   오   미   신   유   술   해   자   축
 *   申子辰    사   오   미   신   유   술   해   자   축   인   묘   진
 *   亥卯未    신   유   술   해   자   축   인   묘   진   사   오   미
 *
 * 각 4주의 지지에 대해 12신살 중 어느 것인지 판정해 리턴.
 */

import type {
  BranchKr,
  FourPillars,
  TwelveSpirit,
  TwelveSpiritsResult,
  PillarName,
} from '../types.ts';

/** 12신살 순서 (지살 0부터 — 삼합 생지가 지살) */
const SPIRIT_ORDER: readonly TwelveSpirit[] = [
  '겁살', '재살', '천살',
  '지살', '연살', '월살',
  '망신', '장성', '반안',
  '역마', '육해', '화개',
];

/** 년지 그룹 → 시작 지지 (겁살 지지) */
// 寅午戌 → 겁살=해, 巳酉丑 → 겁살=인, 申子辰 → 겁살=사, 亥卯未 → 겁살=신
const YEAR_GROUP_START: Record<BranchKr, BranchKr> = {
  '인': '해', '오': '해', '술': '해',
  '사': '인', '유': '인', '축': '인',
  '신': '사', '자': '사', '진': '사',
  '해': '신', '묘': '신', '미': '신',
};

const BRANCH_ORDER: readonly BranchKr[] = [
  '자','축','인','묘','진','사','오','미','신','유','술','해',
];

/** 년지 + 대상 지지 → 12신살 */
export function computeTwelveSpirit(
  yearBranch: BranchKr,
  targetBranch: BranchKr,
): TwelveSpirit {
  const start = YEAR_GROUP_START[yearBranch];
  const startIdx = BRANCH_ORDER.indexOf(start);
  const tgtIdx = BRANCH_ORDER.indexOf(targetBranch);
  const offset = ((tgtIdx - startIdx) % 12 + 12) % 12;
  return SPIRIT_ORDER[offset] ?? '화개';
}

export function calculateTwelveSpirits(pillars: FourPillars): TwelveSpiritsResult {
  const yb = pillars.year.branch.korean;
  const pick = (name: PillarName): TwelveSpirit =>
    computeTwelveSpirit(yb, pillars[name].branch.korean);

  return {
    year: pick('year'),
    month: pick('month'),
    day: pick('day'),
    hour: pick('hour'),
  };
}

/** 일지 기준 12신살 */
export function calculateTwelveSpiritsByDay(
  pillars: FourPillars,
): TwelveSpiritsResult {
  const db = pillars.day.branch.korean;
  const pick = (name: PillarName): TwelveSpirit =>
    computeTwelveSpirit(db, pillars[name].branch.korean);
  return {
    year: pick('year'),
    month: pick('month'),
    day: pick('day'),
    hour: pick('hour'),
  };
}
