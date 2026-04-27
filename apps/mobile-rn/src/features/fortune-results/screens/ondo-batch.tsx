/**
 * ondo-batch — Ondo Design System/project/fortune_results의 Hero + ResultCardFrame
 * 기반 1:1 포팅 결과들.
 *
 * Registry에서 이 파일의 컴포넌트로 라우팅하면 해당 fortune type이 ondo 디자인
 * 그대로 렌더된다.
 */

import { ResultCardFrame } from '../primitives/result-card-frame';
import type { FortuneResultComponentProps } from '../types';

import HeroAvoid from '../heroes/hero-avoid';
import HeroBirthstone from '../heroes/hero-birthstone';
import HeroBlood from '../heroes/hero-blood';
import HeroCalendar from '../heroes/hero-calendar';
import HeroCelebrity from '../heroes/hero-celebrity';
import HeroCoach from '../heroes/hero-coach';
import HeroCompat from '../heroes/hero-compat';
import HeroDate from '../heroes/hero-date';
import HeroDecision from '../heroes/hero-decision';
import HeroDream from '../heroes/hero-dream';
import HeroEx from '../heroes/hero-ex';
import HeroExam from '../heroes/hero-exam';
import HeroExercise from '../heroes/hero-exercise';
import HeroFace from '../heroes/hero-face';
import HeroFamily from '../heroes/hero-family';
import HeroGauge from '../heroes/hero-gauge';
import HeroHealth from '../heroes/hero-health';
import HeroLine from '../heroes/hero-line';
import HeroLove from '../heroes/hero-love';
import HeroLucky from '../heroes/hero-lucky';
import HeroMbti from '../heroes/hero-mbti';
import HeroMoving from '../heroes/hero-moving';
import HeroNaming from '../heroes/hero-naming';
import HeroNewYear from '../heroes/hero-new-year';
import HeroOotd from '../heroes/hero-ootd';
import HeroPast from '../heroes/hero-past';
import HeroPet from '../heroes/hero-pet';
import HeroRadar from '../heroes/hero-radar';
import HeroReview from '../heroes/hero-review';
import HeroSaju from '../heroes/hero-saju';
import HeroTarot from '../heroes/hero-tarot';
import HeroWish from '../heroes/hero-wish';
import HeroYearlyEncounter from '../heroes/hero-yearly-encounter';
import HeroZodiac from '../heroes/hero-zodiac';

export function OndoBloodTypeResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="blood-type" data={payload}>
      <HeroBlood data={payload} />
    </ResultCardFrame>
  );
}

export function OndoZodiacAnimalResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="zodiac-animal" data={payload}>
      <HeroZodiac data={payload} />
    </ResultCardFrame>
  );
}

export function OndoMbtiResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="mbti" data={payload}>
      <HeroMbti data={payload} />
    </ResultCardFrame>
  );
}

export function OndoLoveResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="love" data={payload}>
      <HeroLove data={payload} />
    </ResultCardFrame>
  );
}

export function OndoNewYearResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="new-year" data={payload}>
      <HeroNewYear data={payload} />
    </ResultCardFrame>
  );
}

export function OndoGameEnhanceResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="game-enhance" data={payload}>
      <HeroGauge data={payload} color="#FFC86B" label="SUCCESS" defaultRate={68} />
    </ResultCardFrame>
  );
}

export function OndoMatchInsightResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="match-insight" data={payload}>
      <HeroGauge data={payload} color="#FF8FB1" label="MATCH" defaultRate={74} />
    </ResultCardFrame>
  );
}

export function OndoOotdResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="ootd-evaluation" data={payload}>
      <HeroOotd data={payload} />
    </ResultCardFrame>
  );
}

export function OndoDreamResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="dream" data={payload}>
      <HeroDream data={payload} />
    </ResultCardFrame>
  );
}

export function OndoBlindDateResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="blind-date" data={payload}>
      <HeroDate data={payload} />
    </ResultCardFrame>
  );
}

export function OndoPastLifeResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="past-life" data={payload}>
      <HeroPast data={payload} />
    </ResultCardFrame>
  );
}

export function OndoExerciseResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="exercise" data={payload}>
      <HeroExercise data={payload} />
    </ResultCardFrame>
  );
}

export function OndoDailyReviewResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="daily-review" data={payload}>
      <HeroReview data={payload} />
    </ResultCardFrame>
  );
}

export function OndoAvoidPeopleResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="avoid-people" data={payload}>
      <HeroAvoid data={payload} />
    </ResultCardFrame>
  );
}

export function OndoWishResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="wish" data={payload}>
      <HeroWish data={payload} />
    </ResultCardFrame>
  );
}

export function OndoFamilyResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="family" data={payload}>
      <HeroFamily />
    </ResultCardFrame>
  );
}

export function OndoCoachingResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="coaching" data={payload}>
      <HeroCoach data={payload} />
    </ResultCardFrame>
  );
}

export function OndoTarotResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="tarot" data={payload}>
      <HeroTarot data={payload} />
    </ResultCardFrame>
  );
}

export function OndoTraditionalSajuResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="traditional-saju" data={payload}>
      <HeroSaju data={payload} progress={1} />
    </ResultCardFrame>
  );
}

export function OndoDailyCalendarResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="daily-calendar" data={payload}>
      <HeroCalendar data={payload} progress={1} />
    </ResultCardFrame>
  );
}

export function OndoCareerResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="career" data={payload}>
      <HeroLine data={payload} color="#8FB8FF" />
    </ResultCardFrame>
  );
}

export function OndoWealthResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="wealth" data={payload}>
      <HeroLine data={payload} color="#E0A76B" />
    </ResultCardFrame>
  );
}

export function OndoTalentResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="talent" data={payload}>
      <HeroRadar data={payload} progress={1} color="#68B593" />
    </ResultCardFrame>
  );
}

export function OndoHealthResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="health" data={payload}>
      <HeroHealth data={payload} />
    </ResultCardFrame>
  );
}

export function OndoPersonalityDnaResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="personality-dna" data={payload}>
      <HeroRadar data={payload} progress={1} color="#8B7BE8" />
    </ResultCardFrame>
  );
}

export function OndoExamResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="exam" data={payload}>
      <HeroExam data={payload} />
    </ResultCardFrame>
  );
}

export function OndoCompatibilityResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="compatibility" data={payload}>
      <HeroCompat data={payload} progress={1} />
    </ResultCardFrame>
  );
}

export function OndoExLoverResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="ex-lover" data={payload}>
      <HeroEx />
    </ResultCardFrame>
  );
}

export function OndoYearlyEncounterResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="yearly-encounter" data={payload}>
      <HeroYearlyEncounter data={payload} />
    </ResultCardFrame>
  );
}

export function OndoFaceReadingResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="face-reading" data={payload}>
      <HeroFace />
    </ResultCardFrame>
  );
}

export function OndoNamingResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="naming" data={payload}>
      <HeroNaming data={payload} />
    </ResultCardFrame>
  );
}

export function OndoBirthstoneResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="birthstone" data={payload}>
      <HeroBirthstone data={payload} />
    </ResultCardFrame>
  );
}

export function OndoCelebrityResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="celebrity" data={payload}>
      <HeroCelebrity data={payload} />
    </ResultCardFrame>
  );
}

export function OndoPetCompatibilityResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="pet-compatibility" data={payload}>
      <HeroPet data={payload} />
    </ResultCardFrame>
  );
}

export function OndoLuckyItemsResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="lucky-items" data={payload}>
      <HeroLucky data={payload} />
    </ResultCardFrame>
  );
}

export function OndoMovingResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="moving" data={payload}>
      <HeroMoving data={payload} />
    </ResultCardFrame>
  );
}

export function OndoDecisionResult({ payload }: FortuneResultComponentProps) {
  if (!payload) return null;
  return (
    <ResultCardFrame kind="decision" data={payload}>
      <HeroDecision data={payload} />
    </ResultCardFrame>
  );
}
