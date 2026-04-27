/**
 * @fortune/saju-engine — 만세력 데이터 엔진
 *
 * 생년월일시 + 성별을 입력으로 받아 4주/십성/12운성/납음/지장간/
 * 합충형파해/공망/신살/대운 전체를 결정적으로 계산.
 */

export * from './types.ts';

import type { SajuInput, SajuResult } from './types.ts';
import { calculatePillars, type CalcOptions } from './calculators/pillars.ts';
import { calculateTenGods } from './calculators/ten-gods.ts';
import {
  calculateTwelveStages,
  calculateTwelveStagesDual,
} from './calculators/twelve-stages.ts';
import { calculateNapEum } from './calculators/nap-eum.ts';
import { calculateJiJangGan } from './calculators/ji-jang-gan.ts';
import {
  calculateInteractions,
  calculateBranchRelations,
} from './calculators/interactions.ts';
import { calculateVoids, calculateVoidFlags } from './calculators/void.ts';
import { calculateStars } from './calculators/stars.ts';
import {
  calculateTwelveSpirits,
  calculateTwelveSpiritsByDay,
} from './calculators/twelve-spirits.ts';
import { calculateNobleStars } from './calculators/noble-stars.ts';
import { calculateLuckCycles } from './calculators/luck-cycles.ts';
import { calculateElements } from './calculators/elements.ts';

/** 메인 진입점 */
export function calculateSaju(input: SajuInput, opts: CalcOptions = {}): SajuResult {
  const pillars = calculatePillars(input, opts);
  const tenGods = calculateTenGods(pillars);
  const twelveStages = calculateTwelveStages(pillars);
  const twelveStagesDual = calculateTwelveStagesDual(pillars);
  const napEum = calculateNapEum(pillars);
  const jiJangGan = calculateJiJangGan(pillars);
  const interactions = calculateInteractions(pillars);
  const branchRelations = calculateBranchRelations(pillars, interactions);
  const voids = calculateVoids(pillars);
  const voidFlags = calculateVoidFlags(pillars, voids);
  const stars = calculateStars(pillars);
  const twelveSpirits = calculateTwelveSpirits(pillars);
  const twelveSpiritsByDay = calculateTwelveSpiritsByDay(pillars);
  const nobleStars = calculateNobleStars(pillars);
  const luckCycles = calculateLuckCycles(pillars, input);
  const elements = calculateElements(pillars);

  return {
    input,
    dayMaster: pillars.day.stem,
    pillars,
    tenGods,
    twelveStages,
    twelveStagesDual,
    napEum,
    jiJangGan,
    interactions,
    branchRelations,
    voids,
    voidFlags,
    stars,
    twelveSpirits,
    twelveSpiritsByDay,
    nobleStars,
    luckCycles,
    elements,
  };
}

// Re-export helpers
export { calculatePillars };
export { calculateTenGods };
export { calculateTwelveStages, calculateTwelveStagesDual };
export { calculateNapEum };
export { calculateJiJangGan };
export { calculateInteractions, calculateBranchRelations };
export { calculateVoids, calculateVoidFlags };
export { calculateStars };
export { calculateTwelveSpirits, calculateTwelveSpiritsByDay };
export { computeTwelveSpirit } from './calculators/twelve-spirits.ts';
export { calculateNobleStars };
export { calculateLuckCycles };
export { calculateElements };
export { resolveZodiacSign, listZodiacSigns } from './calculators/zodiac.ts';

// Constants (opt-in access for UI)
export {
  STEMS,
  STEM_KR_ORDER,
  stemIndex,
  getStemByKr,
  getStemByIndex,
} from './constants/stems.ts';
export {
  BRANCHES,
  BRANCH_KR_ORDER,
  branchIndex,
  getBranchByKr,
  getBranchByIndex,
} from './constants/branches.ts';
export { getJiJangGan } from './constants/ji-jang-gan.ts';
export { getNapEum } from './constants/nap-eum.ts';
export { computeTenGod } from './constants/ten-gods.ts';
export { computeTwelveStage } from './constants/twelve-stages.ts';
