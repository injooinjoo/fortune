/**
 * 대운/세운/월운 계산기.
 *
 * 대운수 (시작 나이):
 *   남+양간년(year stem !yin) OR 여+음간년(year stem yin) → 순행
 *   남+음간년 OR 여+양간년 → 역행
 *   단순화: startAge = 1 (벤치마크 맞춤)
 *
 * 10년 단위 대운:
 *   월주에서 시작 후, 순행/역행에 따라 60갑자에서 다음/이전 간지로 진행.
 *
 * 세운: 현재 년도 ± 5년
 * 월운: 해당 년의 12개월 (인월부터)
 *
 * 각 cycle/year/month는 벤치마크 parity를 위해 다음도 포함:
 *  - branchTenGod (일간 vs 지지 본기 stem → 십성)
 *  - twelveStage (일간 vs 지지 → 12운성)  ※yearly/monthly
 *  - twelveSpirit (년지 기준) / twelveSpiritByDay (일지 기준) → 12신살
 */

import type {
  FourPillars,
  LuckCyclesResult,
  LuckCycle,
  YearlyLuck,
  MonthlyLuck,
  SajuInput,
  Stem,
  TenGod,
  TwelveStage,
} from '../types.ts';
import { STEMS, STEM_KR_ORDER } from '../constants/stems.ts';
import { BRANCHES, BRANCH_KR_ORDER } from '../constants/branches.ts';
import { computeTenGod } from '../constants/ten-gods.ts';
import { computeTwelveStage } from '../constants/twelve-stages.ts';
import { getJiJangGanMain } from '../constants/ji-jang-gan.ts';
import { computeTwelveSpirit } from './twelve-spirits.ts';
import { pmod } from '../utils/date.ts';

function ganIdx(stemIdx: number, branchIdx: number, offset: number): { si: number; bi: number } {
  return {
    si: pmod(stemIdx + offset, 10),
    bi: pmod(branchIdx + offset, 12),
  };
}

function computeStartAge(): number {
  return 1;
}

function computeDirection(yearStem: Stem, gender: 'male' | 'female'): '순행' | '역행' {
  const isYangStem = !yearStem.yin;
  if ((isYangStem && gender === 'male') || (!isYangStem && gender === 'female')) {
    return '순행';
  }
  return '역행';
}

export function calculateLuckCycles(
  pillars: FourPillars,
  input: SajuInput,
): LuckCyclesResult {
  const dayMaster = pillars.day.stem;
  const yearStem = pillars.year.stem;
  const yearBranch = pillars.year.branch.korean;
  const dayBranch = pillars.day.branch.korean;
  const direction = computeDirection(yearStem, input.gender);
  const startAge = computeStartAge();

  // 월주 기준 시작
  const mStemIdx = STEM_KR_ORDER.indexOf(pillars.month.stem.korean);
  const mBranchIdx = BRANCH_KR_ORDER.indexOf(pillars.month.branch.korean);

  const step = direction === '순행' ? 1 : -1;

  const cycles: LuckCycle[] = [];
  for (let i = 0; i < 10; i++) {
    const { si, bi } = ganIdx(mStemIdx, mBranchIdx, step * (i + 1));
    const stem = STEMS[si]!;
    const branch = BRANCHES[bi]!;
    const mainStemKr = getJiJangGanMain(branch.korean);
    const mainStem = STEMS[STEM_KR_ORDER.indexOf(mainStemKr)]!;
    cycles.push({
      startAge: startAge + i * 10,
      stem: stem.korean,
      branch: branch.korean,
      korean: `${stem.korean}${branch.korean}`,
      hanja: `${stem.hanja}${branch.hanja}`,
      tenGod: computeTenGod(dayMaster, stem),
      twelveStage: computeTwelveStage(dayMaster, branch.korean),
      branchTenGod: computeTenGod(dayMaster, mainStem),
      twelveSpirit: computeTwelveSpirit(yearBranch, branch.korean),
      twelveSpiritByDay: computeTwelveSpirit(dayBranch, branch.korean),
    });
  }

  // 세운: 현재 년도 ± 5년
  const birthYear = parseInt(input.birthDate.slice(0, 4), 10);
  const referenceYear = input.referenceYear ?? birthYear + 30;
  const yearlyLucks: YearlyLuck[] = [];
  for (let y = referenceYear - 5; y <= referenceYear + 5; y++) {
    const si = pmod(y - 4, 10);
    const bi = pmod(y - 4, 12);
    const stem = STEMS[si]!;
    const branch = BRANCHES[bi]!;
    const mainStemKr = getJiJangGanMain(branch.korean);
    const mainStem = STEMS[STEM_KR_ORDER.indexOf(mainStemKr)]!;
    yearlyLucks.push({
      year: y,
      stem: stem.korean,
      branch: branch.korean,
      korean: `${stem.korean}${branch.korean}`,
      hanja: `${stem.hanja}${branch.hanja}`,
      tenGod: computeTenGod(dayMaster, stem),
      branchTenGod: computeTenGod(dayMaster, mainStem),
      twelveStage: computeTwelveStage(dayMaster, branch.korean),
      twelveSpirit: computeTwelveSpirit(yearBranch, branch.korean),
      twelveSpiritByDay: computeTwelveSpirit(dayBranch, branch.korean),
    });
  }

  // 월운
  const monthlyLucks: MonthlyLuck[] = [];
  const refYearStemIdx = pmod(referenceYear - 4, 10);
  const monthStemBase: Readonly<Record<number, number>> = { 0: 2, 1: 4, 2: 6, 3: 8, 4: 0 };
  const baseIdx = monthStemBase[refYearStemIdx % 5]!;
  for (let lunarMonth = 1; lunarMonth <= 12; lunarMonth++) {
    const si = pmod(baseIdx + (lunarMonth - 1), 10);
    const bi = pmod(lunarMonth + 1, 12);
    const stem = STEMS[si]!;
    const branch = BRANCHES[bi]!;
    const mainStemKr = getJiJangGanMain(branch.korean);
    const mainStem = STEMS[STEM_KR_ORDER.indexOf(mainStemKr)]!;
    monthlyLucks.push({
      month: lunarMonth,
      stem: stem.korean,
      branch: branch.korean,
      korean: `${stem.korean}${branch.korean}`,
      hanja: `${stem.hanja}${branch.hanja}`,
      tenGod: computeTenGod(dayMaster, stem),
      branchTenGod: computeTenGod(dayMaster, mainStem),
      twelveStage: computeTwelveStage(dayMaster, branch.korean),
      twelveSpirit: computeTwelveSpirit(yearBranch, branch.korean),
      twelveSpiritByDay: computeTwelveSpirit(dayBranch, branch.korean),
    });
  }

  return {
    startAge,
    direction,
    cycles,
    yearlyLucks,
    monthlyLucks,
    currentYear: referenceYear,
  };
}

export type { LuckCycle, TenGod, TwelveStage };
