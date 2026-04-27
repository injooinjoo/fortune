import type { Element, Stem, TenGod } from '../types.ts';

/** 상생: X가 Y를 생한다 (X → Y) */
export const SHENG: Record<Element, Element> = {
  '목': '화',
  '화': '토',
  '토': '금',
  '금': '수',
  '수': '목',
};

/** 상극: X가 Y를 극한다 (X → Y) */
export const KE: Record<Element, Element> = {
  '목': '토',
  '화': '금',
  '토': '수',
  '금': '목',
  '수': '화',
};

/**
 * 일간(dayMaster) 기준 대상 천간의 십성 계산.
 *
 * 규칙:
 *   일간과 같은 오행:
 *     같은 음양 → 비견, 다른 음양 → 겁재
 *   일간이 생하는 오행 (목 → 화):
 *     같은 음양 → 식신, 다른 음양 → 상관
 *   일간이 극하는 오행 (목 → 토):
 *     같은 음양 → 편재, 다른 음양 → 정재
 *   일간을 극하는 오행 (목 ← 금):
 *     같은 음양 → 편관, 다른 음양 → 정관
 *   일간을 생하는 오행 (목 ← 수):
 *     같은 음양 → 편인, 다른 음양 → 정인
 */
export function computeTenGod(dayMaster: Stem, target: Stem): TenGod {
  const sameYinYang = dayMaster.yin === target.yin;
  const dmEl = dayMaster.element;
  const tgEl = target.element;

  if (dmEl === tgEl) {
    return sameYinYang ? '비견' : '겁재';
  }
  if (SHENG[dmEl] === tgEl) {
    return sameYinYang ? '식신' : '상관';
  }
  if (KE[dmEl] === tgEl) {
    return sameYinYang ? '편재' : '정재';
  }
  if (KE[tgEl] === dmEl) {
    // target이 dayMaster를 극 → 관살
    return sameYinYang ? '편관' : '정관';
  }
  if (SHENG[tgEl] === dmEl) {
    // target이 dayMaster를 생 → 인성
    return sameYinYang ? '편인' : '정인';
  }
  // should be unreachable
  throw new Error(`Cannot compute TenGod: ${dayMaster.korean} vs ${target.korean}`);
}
