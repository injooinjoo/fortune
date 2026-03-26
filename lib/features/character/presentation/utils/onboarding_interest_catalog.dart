import 'dart:collection';

import '../providers/character_provider.dart';

class OnboardingInterestOption {
  final String id;
  final String label;
  final String subtitle;
  final CharacterListTab targetTab;
  final String? expertId;
  final String? specialtyCategory;
  final String? defaultFortuneType;

  const OnboardingInterestOption({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.targetTab,
    this.expertId,
    this.specialtyCategory,
    this.defaultFortuneType,
  });
}

const List<OnboardingInterestOption> onboardingInterestOptions = [
  OnboardingInterestOption(
    id: 'story',
    label: '상황극',
    subtitle: '캐릭터 대화부터 가볍게 둘러보기',
    targetTab: CharacterListTab.story,
  ),
  OnboardingInterestOption(
    id: 'lifestyle',
    label: '오늘 흐름',
    subtitle: '하루 컨디션과 일상 인사이트',
    targetTab: CharacterListTab.fortune,
    expertId: 'fortune_haneul',
    specialtyCategory: 'lifestyle',
    defaultFortuneType: 'daily',
  ),
  OnboardingInterestOption(
    id: 'traditional',
    label: '사주/전통',
    subtitle: '사주와 전통 명리학 해석',
    targetTab: CharacterListTab.fortune,
    expertId: 'fortune_muhyeon',
    specialtyCategory: 'traditional',
    defaultFortuneType: 'traditional-saju',
  ),
  OnboardingInterestOption(
    id: 'zodiac',
    label: '별자리/띠',
    subtitle: '별과 계절의 흐름으로 보는 해석',
    targetTab: CharacterListTab.fortune,
    expertId: 'fortune_stella',
    specialtyCategory: 'zodiac',
    defaultFortuneType: 'zodiac',
  ),
  OnboardingInterestOption(
    id: 'personality',
    label: '자기이해',
    subtitle: '성격, 재능, 강점 탐색',
    targetTab: CharacterListTab.fortune,
    expertId: 'fortune_dr_mind',
    specialtyCategory: 'personality',
    defaultFortuneType: 'personality-dna',
  ),
  OnboardingInterestOption(
    id: 'love',
    label: '연애/관계',
    subtitle: '관계 흐름과 감정선 보기',
    targetTab: CharacterListTab.fortune,
    expertId: 'fortune_rose',
    specialtyCategory: 'love',
    defaultFortuneType: 'love',
  ),
  OnboardingInterestOption(
    id: 'career',
    label: '커리어/재물',
    subtitle: '일, 돈, 성장 방향성 점검',
    targetTab: CharacterListTab.fortune,
    expertId: 'fortune_james_kim',
    specialtyCategory: 'career',
    defaultFortuneType: 'career',
  ),
  OnboardingInterestOption(
    id: 'lucky',
    label: '행운 아이템',
    subtitle: '오늘의 럭키 포인트 찾기',
    targetTab: CharacterListTab.fortune,
    expertId: 'fortune_lucky',
    specialtyCategory: 'lucky',
    defaultFortuneType: 'lucky-items',
  ),
  OnboardingInterestOption(
    id: 'sports',
    label: '운동/활동',
    subtitle: '몸의 리듬과 퍼포먼스 체크',
    targetTab: CharacterListTab.fortune,
    expertId: 'fortune_marco',
    specialtyCategory: 'sports',
    defaultFortuneType: 'exercise',
  ),
  OnboardingInterestOption(
    id: 'special',
    label: '타로/무의식',
    subtitle: '꿈, 카드, 감각적인 해석',
    targetTab: CharacterListTab.fortune,
    expertId: 'fortune_luna',
    specialtyCategory: 'special',
    defaultFortuneType: 'tarot',
  ),
];

final Map<String, OnboardingInterestOption> onboardingInterestById = {
  for (final option in onboardingInterestOptions) option.id: option,
};

List<String> selectedOnboardingInterestIds(
  Map<String, double>? categoryWeights,
) {
  if (categoryWeights == null || categoryWeights.isEmpty) {
    return const [];
  }

  final filteredEntries = categoryWeights.entries
      .where((entry) => onboardingInterestById.containsKey(entry.key))
      .toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return filteredEntries.map((entry) => entry.key).toList(growable: false);
}

Map<String, double> buildOnboardingInterestWeights(List<String> selectedIds) {
  final weights = <String, double>{};
  for (var index = 0; index < selectedIds.length; index++) {
    final id = selectedIds[index];
    if (!onboardingInterestById.containsKey(id)) {
      continue;
    }
    weights[id] = (1 - (index * 0.08)).clamp(0.5, 1.0);
  }
  return LinkedHashMap<String, double>.from(weights);
}
