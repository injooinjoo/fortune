import type { ComponentType } from 'react';
import { View } from 'react-native';

import { AppText } from '../../components/app-text';
import { Card } from '../../components/card';
import type { EmbeddedResultPayload } from '../chat-results/types';
import { fortuneTheme } from '../../lib/theme';
import {
  OndoAvoidPeopleResult,
  OndoBirthstoneResult,
  OndoBlindDateResult,
  OndoBloodTypeResult,
  OndoCareerResult,
  OndoCelebrityResult,
  OndoCoachingResult,
  OndoCompatibilityResult,
  OndoDailyCalendarResult,
  OndoDailyReviewResult,
  OndoDecisionResult,
  OndoExLoverResult,
  OndoExamResult,
  OndoExerciseResult,
  OndoFaceReadingResult,
  OndoFamilyResult,
  OndoGameEnhanceResult,
  OndoHealthResult,
  OndoLoveResult,
  OndoLuckyItemsResult,
  OndoMatchInsightResult,
  OndoMbtiResult,
  OndoMovingResult,
  OndoNamingResult,
  OndoNewYearResult,
  OndoOotdResult,
  OndoPastLifeResult,
  OndoPersonalityDnaResult,
  OndoPetCompatibilityResult,
  OndoTalentResult,
  OndoTarotResult,
  OndoTraditionalSajuResult,
  OndoWealthResult,
  OndoWishResult,
  OndoYearlyEncounterResult,
  OndoZodiacAnimalResult,
} from './screens/ondo-batch';
import { type FortuneResultComponentProps, type ResultKind } from './types';

const registry: Record<ResultKind, ComponentType<FortuneResultComponentProps>> = {
  'traditional-saju': OndoTraditionalSajuResult,
  'daily-calendar': OndoDailyCalendarResult,
  mbti: OndoMbtiResult,
  'blood-type': OndoBloodTypeResult,
  'zodiac-animal': OndoZodiacAnimalResult,
  career: OndoCareerResult,
  love: OndoLoveResult,
  health: OndoHealthResult,
  coaching: OndoCoachingResult,
  family: OndoFamilyResult,
  'past-life': OndoPastLifeResult,
  wish: OndoWishResult,
  'personality-dna': OndoPersonalityDnaResult,
  wealth: OndoWealthResult,
  talent: OndoTalentResult,
  exercise: OndoExerciseResult,
  tarot: OndoTarotResult,
  'game-enhance': OndoGameEnhanceResult,
  'match-insight': OndoMatchInsightResult,
  'ootd-evaluation': OndoOotdResult,
  exam: OndoExamResult,
  compatibility: OndoCompatibilityResult,
  'blind-date': OndoBlindDateResult,
  'avoid-people': OndoAvoidPeopleResult,
  'ex-lover': OndoExLoverResult,
  'yearly-encounter': OndoYearlyEncounterResult,
  decision: OndoDecisionResult,
  'daily-review': OndoDailyReviewResult,
  'face-reading': OndoFaceReadingResult,
  naming: OndoNamingResult,
  birthstone: OndoBirthstoneResult,
  celebrity: OndoCelebrityResult,
  'pet-compatibility': OndoPetCompatibilityResult,
  'lucky-items': OndoLuckyItemsResult,
  moving: OndoMovingResult,
  'new-year': OndoNewYearResult,
};

export function RenderFortuneResult({
  resultKind,
  payload,
}: {
  resultKind: ResultKind;
  payload?: EmbeddedResultPayload;
}) {
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

  return <Component payload={payload} />;
}
