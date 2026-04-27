import type { BranchKr, Stem, TwelveStage } from '../types.ts';
import { BRANCH_KR_ORDER } from './branches.ts';

/** 12운성 순서 (장생에서 시작) */
export const TWELVE_STAGES_ORDER: readonly TwelveStage[] = [
  '장생', '목욕', '관대', '건록', '제왕',
  '쇠',   '병',   '사',   '묘',   '절',
  '태',   '양',
];

/**
 * 일간별 장생지(長生) — 지지 한글
 *
 * 양간: 갑=해, 병=인, 무=인, 경=사, 임=신
 * 음간: 을=오, 정=유, 기=유, 신=자, 계=묘
 *
 * 양간은 장생에서 순행 / 음간은 장생에서 역행(반대 방향 순서).
 */
const CHANGSAENG: Record<string, BranchKr> = {
  '갑': '해',
  '병': '인',
  '무': '인',
  '경': '사',
  '임': '신',
  '을': '오',
  '정': '유',
  '기': '유',
  '신': '자',
  '계': '묘',
};

/**
 * 주어진 일간과 지지의 12운성 반환.
 *
 * 양간: 장생지에서 순행(+1 씩 다음 지지로)
 * 음간: 장생지에서 역행(-1 씩 이전 지지로)
 */
export function computeTwelveStage(dayMaster: Stem, branch: BranchKr): TwelveStage {
  const startBranch = CHANGSAENG[dayMaster.korean];
  if (!startBranch) {
    throw new Error(`No 장생 mapping for ${dayMaster.korean}`);
  }
  const startIdx = BRANCH_KR_ORDER.indexOf(startBranch);
  const targetIdx = BRANCH_KR_ORDER.indexOf(branch);

  const diff = dayMaster.yin
    ? (startIdx - targetIdx + 12) % 12   // 음간 역행
    : (targetIdx - startIdx + 12) % 12;  // 양간 순행

  return TWELVE_STAGES_ORDER[diff]!;
}
