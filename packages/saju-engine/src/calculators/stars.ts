import type {
  FourPillars,
  StarsResult,
  StarName,
  PillarName,
  PillarData,
  StemKr,
  BranchKr,
} from '../types.ts';
import {
  CHEONEUL_GWIIN,
  TAEGUK_GWIIN,
  MUNCHANG_GWIIN,
  AMROK,
  YANGIN,
  BAEKHO_PILLARS,
  GOEGANG_PILLARS,
  HONGYEOM,
  HYEONCHIM_STEMS,
  HYEONCHIM_BRANCHES,
  HWAGAE,
  YEOKMA,
  DOHWA,
  JISAL,
  GEOPSAL,
  MANGSIN,
  BANAHN,
  CHEONDEOK,
  WOLDEOK,
  GWANGWI_HAKGWAN,
  computeHyeoprok,
} from '../constants/stars.ts';

const PILLAR_NAMES: PillarName[] = ['year', 'month', 'day', 'hour'];

function hasStar(arr: StarName[], s: StarName): boolean {
  return arr.includes(s);
}

function pushStar(arr: StarName[], s: StarName): void {
  if (!hasStar(arr, s)) arr.push(s);
}

/**
 * 신살 20종 계산.
 *
 * 기준:
 *   일간 기준 신살: 천을귀인, 태극귀인, 문창귀인, 암록, 양인살, 홍염살, 관귀학관, 협록
 *   년지 기준 신살(12신살): 화개살, 역마살, 도화살, 지살, 겁살, 망신살, 반안살
 *   월지 기준: 천덕귀인, 월덕귀인
 *   간지 쌍 자체: 백호살, 괴강살
 *   간/지 글자: 현침살
 */
export function calculateStars(pillars: FourPillars): StarsResult {
  const dayStem = pillars.day.stem.korean;
  const yearBranch = pillars.year.branch.korean;
  const monthBranch = pillars.month.branch.korean;

  const result: StarsResult = {
    year: [],
    month: [],
    day: [],
    hour: [],
  };

  const pillarArr: Array<[PillarName, PillarData]> = PILLAR_NAMES.map(
    (n) => [n, pillars[n]] as [PillarName, PillarData],
  );

  // 1. 천을귀인 (일간 → 지지)
  const cheoneul = CHEONEUL_GWIIN[dayStem];
  for (const [name, p] of pillarArr) {
    if (cheoneul.includes(p.branch.korean)) pushStar(result[name], '천을귀인');
  }

  // 2. 태극귀인 (일간 → 지지)
  const taeguk = TAEGUK_GWIIN[dayStem];
  for (const [name, p] of pillarArr) {
    if (taeguk.includes(p.branch.korean)) pushStar(result[name], '태극귀인');
  }

  // 3. 문창귀인 (일간 → 지지)
  const munchang = MUNCHANG_GWIIN[dayStem];
  for (const [name, p] of pillarArr) {
    if (p.branch.korean === munchang) pushStar(result[name], '문창귀인');
  }

  // 4. 암록 (일간 → 지지)
  const amrok = AMROK[dayStem];
  for (const [name, p] of pillarArr) {
    if (p.branch.korean === amrok) pushStar(result[name], '암록');
  }

  // 5. 협록 (일간 → 지지 2개)
  const hyeoprok = computeHyeoprok(dayStem);
  for (const [name, p] of pillarArr) {
    if (hyeoprok.includes(p.branch.korean)) pushStar(result[name], '협록');
  }

  // 6. 관귀학관 (일간 → 지지)
  const gwangwi = GWANGWI_HAKGWAN[dayStem];
  for (const [name, p] of pillarArr) {
    if (p.branch.korean === gwangwi) pushStar(result[name], '관귀학관');
  }

  // 7. 양인살 (일간 → 지지)
  const yangin = YANGIN[dayStem];
  for (const [name, p] of pillarArr) {
    if (p.branch.korean === yangin) pushStar(result[name], '양인살');
  }

  // 8. 홍염살 (일간 → 지지)
  const hongyeom = HONGYEOM[dayStem];
  for (const [name, p] of pillarArr) {
    if (p.branch.korean === hongyeom) pushStar(result[name], '홍염살');
  }

  // 9. 백호살 (간지 쌍)
  for (const [name, p] of pillarArr) {
    const match = BAEKHO_PILLARS.some(
      (x) => x.stem === p.stem.korean && x.branch === p.branch.korean,
    );
    if (match) pushStar(result[name], '백호살');
  }

  // 10. 괴강살 (간지 쌍)
  for (const [name, p] of pillarArr) {
    const match = GOEGANG_PILLARS.some(
      (x) => x.stem === p.stem.korean && x.branch === p.branch.korean,
    );
    if (match) pushStar(result[name], '괴강살');
  }

  // 11. 현침살 — 간 또는 지가 뾰족한 글자
  for (const [name, p] of pillarArr) {
    const stemMatch = HYEONCHIM_STEMS.includes(p.stem.korean);
    const branchMatch = HYEONCHIM_BRANCHES.includes(p.branch.korean);
    if (stemMatch || branchMatch) pushStar(result[name], '현침살');
  }

  // 12. 화개살 (년지 → 지지)
  const hwagae = HWAGAE[yearBranch];
  for (const [name, p] of pillarArr) {
    if (p.branch.korean === hwagae) pushStar(result[name], '화개살');
  }

  // 13. 역마살 (년지 → 지지)
  const yeokma = YEOKMA[yearBranch];
  for (const [name, p] of pillarArr) {
    if (p.branch.korean === yeokma) pushStar(result[name], '역마살');
  }

  // 14. 도화살 (년지 → 지지)
  const dohwa = DOHWA[yearBranch];
  for (const [name, p] of pillarArr) {
    if (p.branch.korean === dohwa) pushStar(result[name], '도화살');
  }

  // 15. 지살 (년지 → 지지)
  const jisal = JISAL[yearBranch];
  for (const [name, p] of pillarArr) {
    if (p.branch.korean === jisal) pushStar(result[name], '지살');
  }

  // 16. 겁살 (년지 → 지지)
  const geopsal = GEOPSAL[yearBranch];
  for (const [name, p] of pillarArr) {
    if (p.branch.korean === geopsal) pushStar(result[name], '겁살');
  }

  // 17. 망신살 (년지 → 지지)
  const mangsin = MANGSIN[yearBranch];
  for (const [name, p] of pillarArr) {
    if (p.branch.korean === mangsin) pushStar(result[name], '망신살');
  }

  // 18. 반안살 (년지 → 지지)
  const banahn = BANAHN[yearBranch];
  for (const [name, p] of pillarArr) {
    if (p.branch.korean === banahn) pushStar(result[name], '반안살');
  }

  // 19. 천덕귀인 (월지 → 간/지)
  const cheondeok = CHEONDEOK[monthBranch];
  for (const [name, p] of pillarArr) {
    if (p.stem.korean === cheondeok || p.branch.korean === cheondeok) {
      pushStar(result[name], '천덕귀인');
    }
  }

  // 20. 월덕귀인 (월지 → 천간)
  const woldeok = WOLDEOK[monthBranch];
  for (const [name, p] of pillarArr) {
    if (p.stem.korean === woldeok) pushStar(result[name], '월덕귀인');
  }

  return result;
}

export { PILLAR_NAMES };
export type { StemKr, BranchKr };
