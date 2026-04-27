import type {
  BranchKr,
  FourPillars,
  PillarName,
  StemKr,
  VoidFlagsResult,
  VoidResult,
} from '../types.ts';
import { STEM_KR_ORDER } from '../constants/stems.ts';
import { BRANCH_KR_ORDER } from '../constants/branches.ts';

/**
 * 공망(空亡) 계산.
 *
 * 60갑자를 10개씩 6순으로 나눔:
 *   갑자순(0~9): 공망 = 戌, 亥
 *   갑술순(10~19): 공망 = 申, 酉
 *   갑신순(20~29): 공망 = 午, 未
 *   갑오순(30~39): 공망 = 辰, 巳
 *   갑진순(40~49): 공망 = 寅, 卯
 *   갑인순(50~59): 공망 = 子, 丑
 *
 * 알고리즘:
 *   stem index + N = branch index 에서 N을 찾는다.
 *   순(旬)의 시작 지지 = (branchIdx - stemIdx + 12) % 12
 *   공망은 (시작지지 + 10), (+11)
 */
function computeVoidBranches(stem: StemKr, branch: BranchKr): [BranchKr, BranchKr] {
  const si = STEM_KR_ORDER.indexOf(stem);
  const bi = BRANCH_KR_ORDER.indexOf(branch);
  const xunStart = ((bi - si) % 12 + 12) % 12;
  const v1 = BRANCH_KR_ORDER[(xunStart + 10) % 12]!;
  const v2 = BRANCH_KR_ORDER[(xunStart + 11) % 12]!;
  return [v1, v2];
}

export function calculateVoids(pillars: FourPillars): VoidResult {
  return {
    year: computeVoidBranches(pillars.year.stem.korean, pillars.year.branch.korean),
    day: computeVoidBranches(pillars.day.stem.korean, pillars.day.branch.korean),
  };
}

/** 각 기둥 지지가 년주/일주 공망에 해당하는지 플래그 */
export function calculateVoidFlags(
  pillars: FourPillars,
  voids: VoidResult,
): VoidFlagsResult {
  const names: PillarName[] = ['year', 'month', 'day', 'hour'];
  const out: Partial<VoidFlagsResult> = {};
  for (const name of names) {
    const branch = pillars[name].branch.korean;
    out[name] = {
      yearVoid: voids.year.includes(branch),
      dayVoid: voids.day.includes(branch),
    };
  }
  return out as VoidFlagsResult;
}
