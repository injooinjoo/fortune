export interface OnboardingInterestOption {
  id: string;
  label: string;
  subtitle: string;
  defaultFortuneType?: string;
}

export const onboardingInterestOptions: readonly OnboardingInterestOption[] = [
  {
    id: 'story',
    label: '상황극',
    subtitle: '캐릭터 대화부터 가볍게 둘러보기',
  },
  {
    id: 'lifestyle',
    label: '오늘 흐름',
    subtitle: '하루 컨디션과 일상 인사이트',
    defaultFortuneType: 'daily',
  },
  {
    id: 'traditional',
    label: '사주/전통',
    subtitle: '사주와 전통 명리학 해석',
    defaultFortuneType: 'traditional-saju',
  },
  {
    id: 'zodiac',
    label: '별자리/띠',
    subtitle: '별과 계절의 흐름으로 보는 해석',
    defaultFortuneType: 'zodiac',
  },
  {
    id: 'personality',
    label: '자기이해',
    subtitle: '성격, 재능, 강점 탐색',
    defaultFortuneType: 'personality-dna',
  },
  {
    id: 'love',
    label: '연애/관계',
    subtitle: '관계 흐름과 감정선 보기',
    defaultFortuneType: 'love',
  },
  {
    id: 'career',
    label: '커리어/재물',
    subtitle: '일, 돈, 성장 방향성 점검',
    defaultFortuneType: 'career',
  },
  {
    id: 'lucky',
    label: '행운 아이템',
    subtitle: '오늘의 럭키 포인트 찾기',
    defaultFortuneType: 'lucky-items',
  },
  {
    id: 'sports',
    label: '운동/활동',
    subtitle: '몸의 리듬과 퍼포먼스 체크',
    defaultFortuneType: 'exercise',
  },
  {
    id: 'special',
    label: '타로/무의식',
    subtitle: '꿈, 카드, 감각적인 해석',
    defaultFortuneType: 'tarot',
  },
] as const;

const onboardingInterestIdSet = new Set(
  onboardingInterestOptions.map((option) => option.id),
);

export function buildOnboardingInterestWeights(selectedIds: readonly string[]) {
  const weights: Record<string, number> = {};

  selectedIds.forEach((id, index) => {
    if (!onboardingInterestIdSet.has(id)) {
      return;
    }

    const nextWeight = Math.max(0.5, 1 - index * 0.08);
    weights[id] = Number(nextWeight.toFixed(2));
  });

  return weights;
}

export function selectedOnboardingInterestIds(categoryWeights: unknown): string[] {
  if (!categoryWeights || typeof categoryWeights !== 'object') {
    return [];
  }

  return Object.entries(categoryWeights as Record<string, unknown>)
    .filter(
      (entry): entry is [string, number] =>
        onboardingInterestIdSet.has(entry[0]) &&
        typeof entry[1] === 'number' &&
        Number.isFinite(entry[1]),
    )
    .sort((a, b) => b[1] - a[1])
    .map(([id]) => id);
}
