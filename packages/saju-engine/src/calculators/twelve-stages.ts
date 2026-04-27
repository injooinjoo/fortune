import type {
  FourPillars,
  PillarName,
  Stem,
  TwelveStageDual,
  TwelveStagesDualResult,
  TwelveStagesResult,
} from '../types.ts';
import { getStemByKr } from '../constants/stems.ts';
import { getJiJangGanMain } from '../constants/ji-jang-gan.ts';
import { computeTwelveStage } from '../constants/twelve-stages.ts';

export function calculateTwelveStages(pillars: FourPillars): TwelveStagesResult {
  const dayMaster: Stem = pillars.day.stem;
  return {
    year: computeTwelveStage(dayMaster, pillars.year.branch.korean),
    month: computeTwelveStage(dayMaster, pillars.month.branch.korean),
    day: computeTwelveStage(dayMaster, pillars.day.branch.korean),
    hour: computeTwelveStage(dayMaster, pillars.hour.branch.korean),
  };
}

/**
 * 12운성 이중표기 계산.
 *
 * - primary: 일간(dayMaster) 기준 × 각 기둥 지지
 * - jiJangGanMain: 각 기둥 지장간 본기 stem을 "일간으로 간주" × 동일 지지
 *   (전통 해석: 본기 오행의 운성)
 */
export function calculateTwelveStagesDual(
  pillars: FourPillars,
): TwelveStagesDualResult {
  const dayMaster: Stem = pillars.day.stem;
  const pick = (name: PillarName): TwelveStageDual => {
    const branchKr = pillars[name].branch.korean;
    const primary = computeTwelveStage(dayMaster, branchKr);
    const mainStemKr = getJiJangGanMain(branchKr);
    const mainStem = getStemByKr(mainStemKr);
    const jiJangGanMain = computeTwelveStage(mainStem, branchKr);
    return { primary, jiJangGanMain };
  };
  return {
    year: pick('year'),
    month: pick('month'),
    day: pick('day'),
    hour: pick('hour'),
  };
}
