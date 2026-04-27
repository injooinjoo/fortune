import type { FourPillars, JiJangGanResult } from '../types.ts';
import { getJiJangGan } from '../constants/ji-jang-gan.ts';

export function calculateJiJangGan(pillars: FourPillars): JiJangGanResult {
  return {
    year: getJiJangGan(pillars.year.branch.korean),
    month: getJiJangGan(pillars.month.branch.korean),
    day: getJiJangGan(pillars.day.branch.korean),
    hour: getJiJangGan(pillars.hour.branch.korean),
  };
}
