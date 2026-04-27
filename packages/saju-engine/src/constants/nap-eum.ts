import { STEM_KR_ORDER } from './stems.ts';
import { BRANCH_KR_ORDER } from './branches.ts';
import type { StemKr, BranchKr } from '../types.ts';

/**
 * 납음오행 — 60갑자 (30쌍, 각 쌍 2개 간지)
 *
 * 순서: 갑자/을축, 병인/정묘, 무진/기사, 경오/신미, 임신/계유, 갑술/을해, ...
 * 총 60개.
 *
 * 벤치마크:
 *   戊辰(무진) → 대림목 ✓
 *   庚申(경신) → 석류목 ✓
 *   癸亥(계해) → 대해수 ✓
 *   癸丑(계축) → 상자목(桑柘木) ✓
 */
const NAPEUM_PAIRS: readonly string[] = [
  '해중금',   // 甲子/乙丑
  '노중화',   // 丙寅/丁卯
  '대림목',   // 戊辰/己巳
  '노방토',   // 庚午/辛未
  '검봉금',   // 壬申/癸酉
  '산두화',   // 甲戌/乙亥
  '간하수',   // 丙子/丁丑
  '성두토',   // 戊寅/己卯
  '백랍금',   // 庚辰/辛巳
  '양류목',   // 壬午/癸未
  '천중수',   // 甲申/乙酉
  '옥상토',   // 丙戌/丁亥
  '벽력화',   // 戊子/己丑
  '송백목',   // 庚寅/辛卯
  '장류수',   // 壬辰/癸巳
  '사중금',   // 甲午/乙未
  '산하화',   // 丙申/丁酉
  '평지목',   // 戊戌/己亥
  '벽상토',   // 庚子/辛丑
  '금박금',   // 壬寅/癸卯
  '복등화',   // 甲辰/乙巳
  '천하수',   // 丙午/丁未
  '대역토',   // 戊申/己酉
  '차천금',   // 庚戌/辛亥
  '상자목',   // 壬子/癸丑
  '대계수',   // 甲寅/乙卯
  '사중토',   // 丙辰/丁巳
  '천상화',   // 戊午/己未
  '석류목',   // 庚申/辛酉
  '대해수',   // 壬戌/癸亥
];

/**
 * 간지(천간+지지)로부터 60갑자 내 index(0~59)를 계산.
 * sexagenary: 천간과 지지는 음양이 같아야 짝이 맞음. (갑자, 을축, 병인, ...)
 */
function sexagenaryIndex(stem: StemKr, branch: BranchKr): number {
  const si = STEM_KR_ORDER.indexOf(stem);
  const bi = BRANCH_KR_ORDER.indexOf(branch);
  // Stem cycles every 10, branch every 12. LCM 60.
  // Find n in [0, 60) such that n % 10 === si and n % 12 === bi.
  for (let n = 0; n < 60; n++) {
    if (n % 10 === si && n % 12 === bi) return n;
  }
  throw new Error(`Invalid sexagenary pair: ${stem}${branch}`);
}

export function getNapEum(stem: StemKr, branch: BranchKr): string {
  const n = sexagenaryIndex(stem, branch);
  const pairIdx = Math.floor(n / 2);
  return NAPEUM_PAIRS[pairIdx]!;
}
