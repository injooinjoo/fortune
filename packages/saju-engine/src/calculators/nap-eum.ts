import type { FourPillars, NapEumResult } from '../types.ts';
import { getNapEum } from '../constants/nap-eum.ts';

export function calculateNapEum(pillars: FourPillars): NapEumResult {
  return {
    year: getNapEum(pillars.year.stem.korean, pillars.year.branch.korean),
    month: getNapEum(pillars.month.stem.korean, pillars.month.branch.korean),
    day: getNapEum(pillars.day.stem.korean, pillars.day.branch.korean),
    hour: getNapEum(pillars.hour.stem.korean, pillars.hour.branch.korean),
  };
}
