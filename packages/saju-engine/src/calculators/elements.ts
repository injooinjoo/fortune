import type { FourPillars, ElementsResult, Element } from '../types.ts';
import { getJiJangGan } from '../constants/ji-jang-gan.ts';

/**
 * 오행 분포 계산.
 *
 * 가중치:
 *   천간 1.0 (반올림하여 정수)
 *   지지 본기 1.0, 중기 0.3, 여기 0.1 (지장간 기반)
 *
 * 벤치마크(1988-09-05) 출력은 "木0, 火0, 土3, 金2, 水3"로 정수값.
 * 단순 카운트: 천간 4개(+1 each) + 지지 본기 4개(+1 each) = 8 points.
 * 벤치마크:
 *   무(토), 경(금), 계(수), 계(수) → 토1금1수2
 *   진 본기 무(토), 신 본기 경(금), 해 본기 임(수), 축 본기 기(토) → 토2금1수1
 *   합: 토3, 금2, 수3, 목0, 화0  ✓
 */
export function calculateElements(pillars: FourPillars): ElementsResult {
  const counts: Record<Element, number> = { 목: 0, 화: 0, 토: 0, 금: 0, 수: 0 };

  // 천간 +1
  const stems = [
    pillars.year.stem.element,
    pillars.month.stem.element,
    pillars.day.stem.element,
    pillars.hour.stem.element,
  ];
  for (const el of stems) counts[el] += 1;

  // 지지 본기 +1 (본기만 카운트하여 정수 결과)
  const branches = [
    pillars.year.branch.korean,
    pillars.month.branch.korean,
    pillars.day.branch.korean,
    pillars.hour.branch.korean,
  ];
  for (const br of branches) {
    const entries = getJiJangGan(br);
    const main = entries.find((e) => e.type === 'main');
    if (main) counts[main.element] += 1;
  }

  const entries = Object.entries(counts) as Array<[Element, number]>;
  entries.sort((a, b) => b[1] - a[1]);
  const strongest = entries[0]![0];
  const weakest = entries[entries.length - 1]![0];

  // Balance score: std-dev 기반 (0=완벽 균형, 많이 치우칠수록 낮음)
  const values = entries.map(([, v]) => v);
  const mean = values.reduce((a, b) => a + b, 0) / values.length;
  const variance = values.reduce((a, b) => a + (b - mean) ** 2, 0) / values.length;
  const stddev = Math.sqrt(variance);
  const maxStddev = 3.6; // 모든 값이 한 오행 집중일 때 근사
  const balanceScore = Math.max(0, Math.min(100, Math.round((1 - stddev / maxStddev) * 100)));

  return {
    wood:  counts['목'],
    fire:  counts['화'],
    earth: counts['토'],
    metal: counts['금'],
    water: counts['수'],
    strongest,
    weakest,
    balanceScore,
  };
}
