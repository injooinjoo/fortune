import type { BranchKr, JiJangGanEntry, StemKr, Element } from '../types.ts';

const STEM_HANJA: Record<StemKr, string> = {
  '갑': '甲', '을': '乙', '병': '丙', '정': '丁', '무': '戊',
  '기': '己', '경': '庚', '신': '辛', '임': '壬', '계': '癸',
};

const STEM_ELEMENT: Record<StemKr, Element> = {
  '갑': '목', '을': '목',
  '병': '화', '정': '화',
  '무': '토', '기': '토',
  '경': '금', '신': '금',
  '임': '수', '계': '수',
};

type RawEntry = { stem: StemKr; type: JiJangGanEntry['type']; ratio: number };

/**
 * 지장간 테이블 (본기/중기/여기 + 비율)
 * ratio는 백분율 — 합=100
 */
const RAW: Record<BranchKr, RawEntry[]> = {
  '자': [{ stem: '임', type: 'remnant', ratio: 30 }, { stem: '계', type: 'main', ratio: 70 }],
  '축': [{ stem: '계', type: 'remnant', ratio: 10 }, { stem: '신', type: 'middle', ratio: 30 }, { stem: '기', type: 'main', ratio: 60 }],
  '인': [{ stem: '무', type: 'remnant', ratio: 10 }, { stem: '병', type: 'middle', ratio: 30 }, { stem: '갑', type: 'main', ratio: 60 }],
  '묘': [{ stem: '갑', type: 'remnant', ratio: 30 }, { stem: '을', type: 'main', ratio: 70 }],
  '진': [{ stem: '을', type: 'remnant', ratio: 30 }, { stem: '계', type: 'middle', ratio: 10 }, { stem: '무', type: 'main', ratio: 60 }],
  '사': [{ stem: '무', type: 'remnant', ratio: 10 }, { stem: '경', type: 'middle', ratio: 30 }, { stem: '병', type: 'main', ratio: 60 }],
  '오': [{ stem: '병', type: 'remnant', ratio: 30 }, { stem: '기', type: 'middle', ratio: 10 }, { stem: '정', type: 'main', ratio: 60 }],
  '미': [{ stem: '정', type: 'remnant', ratio: 30 }, { stem: '을', type: 'middle', ratio: 10 }, { stem: '기', type: 'main', ratio: 60 }],
  '신': [{ stem: '무', type: 'remnant', ratio: 10 }, { stem: '임', type: 'middle', ratio: 30 }, { stem: '경', type: 'main', ratio: 60 }],
  '유': [{ stem: '경', type: 'remnant', ratio: 30 }, { stem: '신', type: 'main', ratio: 70 }],
  '술': [{ stem: '신', type: 'remnant', ratio: 30 }, { stem: '정', type: 'middle', ratio: 10 }, { stem: '무', type: 'main', ratio: 60 }],
  '해': [{ stem: '무', type: 'remnant', ratio: 10 }, { stem: '갑', type: 'middle', ratio: 30 }, { stem: '임', type: 'main', ratio: 60 }],
};

function enrich(entries: RawEntry[]): JiJangGanEntry[] {
  return entries.map((e) => ({
    stem: e.stem,
    hanja: STEM_HANJA[e.stem],
    type: e.type,
    ratio: e.ratio,
    element: STEM_ELEMENT[e.stem],
  }));
}

const TABLE: Record<BranchKr, JiJangGanEntry[]> = {
  '자': enrich(RAW['자']),
  '축': enrich(RAW['축']),
  '인': enrich(RAW['인']),
  '묘': enrich(RAW['묘']),
  '진': enrich(RAW['진']),
  '사': enrich(RAW['사']),
  '오': enrich(RAW['오']),
  '미': enrich(RAW['미']),
  '신': enrich(RAW['신']),
  '유': enrich(RAW['유']),
  '술': enrich(RAW['술']),
  '해': enrich(RAW['해']),
};

export function getJiJangGan(branch: BranchKr): JiJangGanEntry[] {
  return TABLE[branch];
}

/** 본기(정기) 천간 반환 */
export function getJiJangGanMain(branch: BranchKr): StemKr {
  const entries = TABLE[branch];
  const main = entries.find((e) => e.type === 'main');
  if (!main) throw new Error(`No main jijanggan for ${branch}`);
  return main.stem;
}
