import type { Branch, BranchKr } from '../types.ts';

/** 지지 12 — 순서: 자축인묘진사오미신유술해 (index 0~11) */
export const BRANCHES: readonly Branch[] = [
  { hanja: '子', korean: '자', element: '수', animal: '쥐',     yin: false, lunarMonth: 11 },
  { hanja: '丑', korean: '축', element: '토', animal: '소',     yin: true,  lunarMonth: 12 },
  { hanja: '寅', korean: '인', element: '목', animal: '호랑이', yin: false, lunarMonth: 1  },
  { hanja: '卯', korean: '묘', element: '목', animal: '토끼',   yin: true,  lunarMonth: 2  },
  { hanja: '辰', korean: '진', element: '토', animal: '용',     yin: false, lunarMonth: 3  },
  { hanja: '巳', korean: '사', element: '화', animal: '뱀',     yin: true,  lunarMonth: 4  },
  { hanja: '午', korean: '오', element: '화', animal: '말',     yin: false, lunarMonth: 5  },
  { hanja: '未', korean: '미', element: '토', animal: '양',     yin: true,  lunarMonth: 6  },
  { hanja: '申', korean: '신', element: '금', animal: '원숭이', yin: false, lunarMonth: 7  },
  { hanja: '酉', korean: '유', element: '금', animal: '닭',     yin: true,  lunarMonth: 8  },
  { hanja: '戌', korean: '술', element: '토', animal: '개',     yin: false, lunarMonth: 9  },
  { hanja: '亥', korean: '해', element: '수', animal: '돼지',   yin: true,  lunarMonth: 10 },
];

export const BRANCH_KR_ORDER: readonly BranchKr[] = [
  '자', '축', '인', '묘', '진', '사',
  '오', '미', '신', '유', '술', '해',
];

export function branchIndex(kr: BranchKr): number {
  return BRANCH_KR_ORDER.indexOf(kr);
}

export function getBranchByKr(kr: BranchKr): Branch {
  const idx = branchIndex(kr);
  if (idx < 0) throw new Error(`Unknown branch: ${kr}`);
  return BRANCHES[idx]!;
}

export function getBranchByIndex(i: number): Branch {
  const m = ((i % 12) + 12) % 12;
  return BRANCHES[m]!;
}
