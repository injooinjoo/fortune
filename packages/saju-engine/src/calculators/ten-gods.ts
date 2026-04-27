import type {
  FourPillars,
  TenGodsResult,
  PillarTenGods,
  Stem,
  BranchKr,
} from '../types.ts';
import { computeTenGod } from '../constants/ten-gods.ts';
import { getJiJangGanMain } from '../constants/ji-jang-gan.ts';
import { getStemByKr } from '../constants/stems.ts';

export function computePillarTenGods(dayMaster: Stem, pillarStem: Stem, branch: BranchKr): PillarTenGods {
  const stemTG = computeTenGod(dayMaster, pillarStem);
  const mainStemKr = getJiJangGanMain(branch);
  const branchTG = computeTenGod(dayMaster, getStemByKr(mainStemKr));
  return { stem: stemTG, branch: branchTG };
}

export function calculateTenGods(pillars: FourPillars): TenGodsResult {
  const dayMaster = pillars.day.stem;

  return {
    year: computePillarTenGods(dayMaster, pillars.year.stem, pillars.year.branch.korean),
    month: computePillarTenGods(dayMaster, pillars.month.stem, pillars.month.branch.korean),
    day: {
      stem: '일간',
      branch: computeTenGod(dayMaster, getStemByKr(getJiJangGanMain(pillars.day.branch.korean))),
    },
    hour: computePillarTenGods(dayMaster, pillars.hour.stem, pillars.hour.branch.korean),
  };
}
