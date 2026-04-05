export type FortuneTypeId =
  | 'daily'
  | 'daily-calendar'
  | 'new-year'
  | 'traditional-saju'
  | 'face-reading'
  | 'mbti'
  | 'personality-dna'
  | 'love'
  | 'compatibility'
  | 'blind-date'
  | 'ex-lover'
  | 'avoid-people'
  | 'yearly-encounter'
  | 'career'
  | 'wealth'
  | 'talent'
  | 'lucky-items'
  | 'lotto'
  | 'match-insight'
  | 'game-enhance'
  | 'exercise'
  | 'dream'
  | 'tarot'
  | 'past-life'
  | 'health'
  | 'pet-compatibility'
  | 'family'
  | 'naming'
  | 'ootd-evaluation'
  | 'exam'
  | 'moving'
  | 'celebrity'
  | 'biorhythm'
  | 'wish'
  | 'talisman'
  | 'zodiac'
  | 'zodiac-animal'
  | 'constellation'
  | 'birthstone'
  | 'fortune-cookie'
  | 'breathing'
  | 'daily-review'
  | 'weekly-review'
  | 'chat-insight'
  | 'coaching'
  | 'decision'
  | 'view-all'
  | 'profile-creation';

export interface FortuneTypeSpec {
  id: FortuneTypeId;
  labelKey: string;
  endpoint: string | null;
  isLocalOnly?: boolean;
  apiType?: string;
}

export const fortuneTypeSpecs = [
  { id: 'daily', labelKey: 'fortuneDaily', endpoint: '/fortune-daily' },
  {
    id: 'daily-calendar',
    labelKey: 'fortuneDailyCalendar',
    endpoint: '/fortune-time',
  },
  { id: 'new-year', labelKey: 'fortuneNewYear', endpoint: '/fortune-new-year' },
  {
    id: 'traditional-saju',
    labelKey: 'fortuneTraditional',
    endpoint: '/fortune-traditional-saju',
    apiType: 'traditional-saju',
  },
  {
    id: 'face-reading',
    labelKey: 'fortuneFaceReading',
    endpoint: '/fortune-face-reading',
  },
  { id: 'mbti', labelKey: 'fortuneMbti', endpoint: '/fortune-mbti' },
  {
    id: 'personality-dna',
    labelKey: 'fortunePersonalityDna',
    endpoint: '/fortune-mbti',
    apiType: 'mbti',
  },
  { id: 'love', labelKey: 'fortuneLove', endpoint: '/fortune-love' },
  {
    id: 'compatibility',
    labelKey: 'fortuneCompatibility',
    endpoint: '/fortune-compatibility',
  },
  {
    id: 'blind-date',
    labelKey: 'fortuneBlindDate',
    endpoint: '/fortune-blind-date',
  },
  { id: 'ex-lover', labelKey: 'fortuneExLover', endpoint: '/fortune-ex-lover' },
  {
    id: 'avoid-people',
    labelKey: 'fortuneAvoidPeople',
    endpoint: '/fortune-avoid-people',
  },
  {
    id: 'yearly-encounter',
    labelKey: 'fortuneYearlyEncounter',
    endpoint: '/fortune-yearly-encounter',
  },
  { id: 'career', labelKey: 'fortuneCareer', endpoint: '/fortune-career' },
  { id: 'wealth', labelKey: 'fortuneWealth', endpoint: '/fortune-wealth' },
  { id: 'talent', labelKey: 'fortuneTalent', endpoint: '/fortune-talent' },
  {
    id: 'lucky-items',
    labelKey: 'fortuneLuckyItems',
    endpoint: '/fortune-lucky-items',
  },
  {
    id: 'lotto',
    labelKey: 'fortuneLuckyLottery',
    endpoint: '/fortune-lucky-lottery',
    isLocalOnly: true,
  },
  {
    id: 'match-insight',
    labelKey: 'fortuneSportsGame',
    endpoint: '/fortune-match-insight',
  },
  {
    id: 'game-enhance',
    labelKey: 'fortuneGameEnhance',
    endpoint: '/fortune-game-enhance',
  },
  { id: 'exercise', labelKey: 'fortuneExercise', endpoint: '/fortune-exercise' },
  { id: 'dream', labelKey: 'fortuneDream', endpoint: '/fortune-dream' },
  { id: 'tarot', labelKey: 'fortuneTarot', endpoint: '/fortune-tarot' },
  { id: 'past-life', labelKey: 'fortunePastLife', endpoint: '/fortune-past-life' },
  { id: 'health', labelKey: 'fortuneHealth', endpoint: '/fortune-health' },
  {
    id: 'pet-compatibility',
    labelKey: 'fortunePet',
    endpoint: '/fortune-pet-compatibility',
  },
  { id: 'family', labelKey: 'fortuneFamily', endpoint: '/fortune-{apiType}' },
  { id: 'naming', labelKey: 'fortuneNaming', endpoint: '/fortune-naming' },
  {
    id: 'ootd-evaluation',
    labelKey: 'fortuneOotdEvaluation',
    endpoint: '/fortune-ootd',
    apiType: 'ootd',
  },
  { id: 'exam', labelKey: 'fortuneLuckyExam', endpoint: '/fortune-exam' },
  { id: 'moving', labelKey: 'fortuneMoving', endpoint: '/fortune-moving' },
  {
    id: 'celebrity',
    labelKey: 'fortuneCelebrity',
    endpoint: '/fortune-celebrity',
  },
  { id: 'biorhythm', labelKey: 'fortuneBiorhythm', endpoint: '/fortune-biorhythm' },
  {
    id: 'wish',
    labelKey: 'fortuneWish',
    endpoint: '/analyze-wish',
    isLocalOnly: true,
  },
  {
    id: 'talisman',
    labelKey: 'fortuneTalisman',
    endpoint: '/generate-talisman',
  },
  {
    id: 'zodiac',
    labelKey: 'fortuneZodiac',
    endpoint: '/fortune-daily',
    apiType: 'daily',
  },
  {
    id: 'zodiac-animal',
    labelKey: 'fortuneZodiacAnimal',
    endpoint: '/fortune-daily',
    apiType: 'daily',
  },
  {
    id: 'constellation',
    labelKey: 'fortuneConstellation',
    endpoint: '/fortune-daily',
    apiType: 'daily',
  },
  {
    id: 'birthstone',
    labelKey: 'fortuneBirthstone',
    endpoint: '/fortune-daily',
    apiType: 'daily',
  },
  {
    id: 'fortune-cookie',
    labelKey: 'fortuneFortuneCookie',
    endpoint: null,
    isLocalOnly: true,
  },
  {
    id: 'breathing',
    labelKey: 'fortuneBreathing',
    endpoint: null,
    isLocalOnly: true,
  },
  {
    id: 'daily-review',
    labelKey: 'fortuneDailyReview',
    endpoint: null,
    isLocalOnly: true,
  },
  {
    id: 'weekly-review',
    labelKey: 'fortuneWeeklyReview',
    endpoint: null,
    isLocalOnly: true,
  },
  {
    id: 'chat-insight',
    labelKey: 'fortuneChatInsight',
    endpoint: null,
    isLocalOnly: true,
  },
  {
    id: 'coaching',
    labelKey: 'fortuneCoaching',
    endpoint: null,
    isLocalOnly: true,
  },
  {
    id: 'decision',
    labelKey: 'fortuneDecisionHelper',
    endpoint: '/fortune-decision',
    isLocalOnly: true,
  },
  {
    id: 'view-all',
    labelKey: 'chipViewAll',
    endpoint: null,
    isLocalOnly: true,
  },
  {
    id: 'profile-creation',
    labelKey: 'profileSetup',
    endpoint: null,
    isLocalOnly: true,
  },
] as const satisfies readonly FortuneTypeSpec[];

export const fortuneTypesById = Object.fromEntries(
  fortuneTypeSpecs.map((spec) => [spec.id, spec]),
) as Record<FortuneTypeId, FortuneTypeSpec>;

export interface FortuneAnswerBag {
  concern?: string;
  family_type?: string;
}

export function resolveFamilyApiType(answers: FortuneAnswerBag = {}): string {
  const rawConcern = (answers.concern ?? answers.family_type ?? '').toLowerCase();

  if (rawConcern === 'wealth' || rawConcern === '재물' || rawConcern === '돈') {
    return 'family-wealth';
  }
  if (rawConcern === 'children' || rawConcern === '자녀' || rawConcern === '아이') {
    return 'family-children';
  }
  if (
    rawConcern === 'relationship' ||
    rawConcern === '관계' ||
    rawConcern === '소통'
  ) {
    return 'family-relationship';
  }
  if (rawConcern === 'change' || rawConcern === '변화' || rawConcern === '전환') {
    return 'family-change';
  }

  return 'family-health';
}

export function resolveFortuneApiType(
  typeId: FortuneTypeId,
  answers: FortuneAnswerBag = {},
): string {
  if (typeId === 'family') {
    return resolveFamilyApiType(answers);
  }

  return fortuneTypesById[typeId].apiType ?? typeId;
}

export function resolveFortuneEndpoint(
  typeId: FortuneTypeId,
  answers: FortuneAnswerBag = {},
): string | null {
  const endpoint = fortuneTypesById[typeId].endpoint;

  if (!endpoint) {
    return null;
  }

  return endpoint.replace('{apiType}', resolveFortuneApiType(typeId, answers));
}
