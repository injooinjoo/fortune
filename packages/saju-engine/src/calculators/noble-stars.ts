/**
 * 귀인 (Noble Stars) — 천을귀인 지지 + 월령.
 *
 * 천을귀인: 일간 → 지지 2개 (CHEONEUL_GWIIN)
 * 월령: 월주 천간
 */

import type { FourPillars, NobleStarsResult } from '../types.ts';
import { CHEONEUL_GWIIN } from '../constants/stars.ts';

export function calculateNobleStars(pillars: FourPillars): NobleStarsResult {
  const dayStem = pillars.day.stem.korean;
  const cheoneul = CHEONEUL_GWIIN[dayStem];
  return {
    cheoneul: [...cheoneul],
    wollyeong: pillars.month.stem.korean,
  };
}
