import type { Stem, StemKr } from '../types.ts';

/** 천간 10 — 순서: 갑을병정무기경신임계 (index 0~9) */
export const STEMS: readonly Stem[] = [
  { hanja: '甲', korean: '갑', element: '목', yin: false },
  { hanja: '乙', korean: '을', element: '목', yin: true  },
  { hanja: '丙', korean: '병', element: '화', yin: false },
  { hanja: '丁', korean: '정', element: '화', yin: true  },
  { hanja: '戊', korean: '무', element: '토', yin: false },
  { hanja: '己', korean: '기', element: '토', yin: true  },
  { hanja: '庚', korean: '경', element: '금', yin: false },
  { hanja: '辛', korean: '신', element: '금', yin: true  },
  { hanja: '壬', korean: '임', element: '수', yin: false },
  { hanja: '癸', korean: '계', element: '수', yin: true  },
];

export const STEM_KR_ORDER: readonly StemKr[] = [
  '갑', '을', '병', '정', '무', '기', '경', '신', '임', '계',
];

export function stemIndex(kr: StemKr): number {
  return STEM_KR_ORDER.indexOf(kr);
}

export function getStemByKr(kr: StemKr): Stem {
  const idx = stemIndex(kr);
  if (idx < 0) throw new Error(`Unknown stem: ${kr}`);
  return STEMS[idx]!;
}

export function getStemByIndex(i: number): Stem {
  const m = ((i % 10) + 10) % 10;
  return STEMS[m]!;
}
