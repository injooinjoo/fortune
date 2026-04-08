import type { ComponentType } from 'react';
import { View } from 'react-native';

import { AppText } from '../../components/app-text';
import { Card } from '../../components/card';
import { fortuneTheme } from '../../lib/theme';
import { ResultBatchA } from './screens/batch-a';
import { ResultBatchB } from './screens/batch-b';
import { ResultBatchC } from './screens/batch-c';
import { ResultBatchD } from './screens/batch-d';
import { ResultBatchE } from './screens/batch-e';
import { type ResultKind } from './types';

const registry: Record<ResultKind, ComponentType> = {
  'traditional-saju': ResultBatchA.TraditionalSajuResult,
  'daily-calendar': ResultBatchA.DailyCalendarResult,
  mbti: ResultBatchA.MbtiResult,
  'blood-type': ResultBatchA.BloodTypeResult,
  'zodiac-animal': ResultBatchA.ZodiacAnimalResult,
  constellation: ResultBatchA.ConstellationResult,
  career: ResultBatchB.CareerResult,
  love: ResultBatchB.LoveResult,
  health: ResultBatchB.HealthResult,
  coaching: ResultBatchB.CoachingResult,
  family: ResultBatchC.FamilyResult,
  'past-life': ResultBatchC.PastLifeResult,
  wish: ResultBatchC.WishResult,
  'personality-dna': ResultBatchC.PersonalityDnaResult,
  wealth: ResultBatchD.WealthResult,
  talent: ResultBatchD.TalentResult,
  exercise: ResultBatchD.ExerciseResult,
  tarot: ResultBatchD.TarotResult,
  'game-enhance': ResultBatchD.GameEnhanceResult,
  'ootd-evaluation': ResultBatchD.OotdEvaluationResult,
  exam: ResultBatchE.ExamResult,
  compatibility: ResultBatchE.CompatibilityResult,
  'blind-date': ResultBatchE.BlindDateResult,
  'avoid-people': ResultBatchE.AvoidPeopleResult,
  'ex-lover': ResultBatchE.ExLoverResult,
  'yearly-encounter': ResultBatchE.YearlyEncounterResult,
  decision: ResultBatchE.DecisionResult,
  'daily-review': ResultBatchE.DailyReviewResult,
};

export function RenderFortuneResult({ resultKind }: { resultKind: ResultKind }) {
  const Component = registry[resultKind];

  if (!Component) {
    return (
      <Card>
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          <AppText variant="heading4">결과를 찾지 못했습니다.</AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            등록되지 않은 결과 타입입니다.
          </AppText>
        </View>
      </Card>
    );
  }

  return <Component />;
}
