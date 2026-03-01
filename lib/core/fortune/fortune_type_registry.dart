typedef FortuneApiTypeResolver = String Function(Map<String, dynamic> answers);

/// Canonical fortune type definition.
///
/// `id` must be kebab-case.
class FortuneTypeSpec {
  final String id;
  final String labelKey;
  final String? endpoint;
  final bool isLocalOnly;
  final String? apiType;
  final FortuneApiTypeResolver? resolveApiType;

  const FortuneTypeSpec({
    required this.id,
    required this.labelKey,
    required this.endpoint,
    this.isLocalOnly = false,
    this.apiType,
    this.resolveApiType,
  });

  String apiTypeOf(Map<String, dynamic> answers) {
    if (resolveApiType != null) {
      return resolveApiType!(answers);
    }
    return apiType ?? id;
  }
}

class FortuneTypeRegistry {
  FortuneTypeRegistry._();

  static const Map<String, FortuneTypeSpec> _specs = {
    // Core API-backed fortune types
    'daily': FortuneTypeSpec(
      id: 'daily',
      labelKey: 'fortuneDaily',
      endpoint: '/fortune-daily',
    ),
    'daily-calendar': FortuneTypeSpec(
      id: 'daily-calendar',
      labelKey: 'fortuneDailyCalendar',
      endpoint: '/fortune-time',
    ),
    'new-year': FortuneTypeSpec(
      id: 'new-year',
      labelKey: 'fortuneNewYear',
      endpoint: '/fortune-new-year',
    ),
    'traditional-saju': FortuneTypeSpec(
      id: 'traditional-saju',
      labelKey: 'fortuneTraditional',
      endpoint: '/fortune-traditional-saju',
      apiType: 'traditional-saju',
    ),
    'face-reading': FortuneTypeSpec(
      id: 'face-reading',
      labelKey: 'fortuneFaceReading',
      endpoint: '/fortune-face-reading',
    ),
    'mbti': FortuneTypeSpec(
      id: 'mbti',
      labelKey: 'fortuneMbti',
      endpoint: '/fortune-mbti',
    ),
    'personality-dna': FortuneTypeSpec(
      id: 'personality-dna',
      labelKey: 'fortunePersonalityDna',
      endpoint: '/fortune-mbti',
      apiType: 'mbti',
    ),
    'love': FortuneTypeSpec(
      id: 'love',
      labelKey: 'fortuneLove',
      endpoint: '/fortune-love',
    ),
    'compatibility': FortuneTypeSpec(
      id: 'compatibility',
      labelKey: 'fortuneCompatibility',
      endpoint: '/fortune-compatibility',
    ),
    'blind-date': FortuneTypeSpec(
      id: 'blind-date',
      labelKey: 'fortuneBlindDate',
      endpoint: '/fortune-blind-date',
    ),
    'ex-lover': FortuneTypeSpec(
      id: 'ex-lover',
      labelKey: 'fortuneExLover',
      endpoint: '/fortune-ex-lover',
    ),
    'avoid-people': FortuneTypeSpec(
      id: 'avoid-people',
      labelKey: 'fortuneAvoidPeople',
      endpoint: '/fortune-avoid-people',
    ),
    'yearly-encounter': FortuneTypeSpec(
      id: 'yearly-encounter',
      labelKey: 'fortuneYearlyEncounter',
      endpoint: '/fortune-yearly-encounter',
    ),
    'career': FortuneTypeSpec(
      id: 'career',
      labelKey: 'fortuneCareer',
      endpoint: '/fortune-career',
    ),
    'wealth': FortuneTypeSpec(
      id: 'wealth',
      labelKey: 'fortuneWealth',
      endpoint: '/fortune-wealth',
    ),
    'talent': FortuneTypeSpec(
      id: 'talent',
      labelKey: 'fortuneTalent',
      endpoint: '/fortune-talent',
    ),
    'lucky-items': FortuneTypeSpec(
      id: 'lucky-items',
      labelKey: 'fortuneLuckyItems',
      endpoint: '/fortune-lucky-items',
    ),
    'lotto': FortuneTypeSpec(
      id: 'lotto',
      labelKey: 'fortuneLuckyLottery',
      endpoint: '/fortune-lucky-lottery',
      isLocalOnly: true,
    ),
    'match-insight': FortuneTypeSpec(
      id: 'match-insight',
      labelKey: 'fortuneSportsGame',
      endpoint: '/fortune-match-insight',
    ),
    'game-enhance': FortuneTypeSpec(
      id: 'game-enhance',
      labelKey: 'fortuneGameEnhance',
      endpoint: '/fortune-game-enhance',
    ),
    'exercise': FortuneTypeSpec(
      id: 'exercise',
      labelKey: 'fortuneExercise',
      endpoint: '/fortune-exercise',
    ),
    'dream': FortuneTypeSpec(
      id: 'dream',
      labelKey: 'fortuneDream',
      endpoint: '/fortune-dream',
    ),
    'tarot': FortuneTypeSpec(
      id: 'tarot',
      labelKey: 'fortuneTarot',
      endpoint: '/fortune-tarot',
    ),
    'past-life': FortuneTypeSpec(
      id: 'past-life',
      labelKey: 'fortunePastLife',
      endpoint: '/fortune-past-life',
    ),
    'health': FortuneTypeSpec(
      id: 'health',
      labelKey: 'fortuneHealth',
      endpoint: '/fortune-health',
    ),
    'pet-compatibility': FortuneTypeSpec(
      id: 'pet-compatibility',
      labelKey: 'fortunePet',
      endpoint: '/fortune-pet-compatibility',
    ),
    'family': FortuneTypeSpec(
      id: 'family',
      labelKey: 'fortuneFamily',
      endpoint: '/fortune-{apiType}',
      resolveApiType: _resolveFamilyApiType,
    ),
    'naming': FortuneTypeSpec(
      id: 'naming',
      labelKey: 'fortuneNaming',
      endpoint: '/fortune-naming',
    ),
    'baby-nickname': FortuneTypeSpec(
      id: 'baby-nickname',
      labelKey: 'fortuneBabyNickname',
      endpoint: '/fortune-baby-nickname',
    ),
    'ootd-evaluation': FortuneTypeSpec(
      id: 'ootd-evaluation',
      labelKey: 'fortuneOotdEvaluation',
      endpoint: '/fortune-ootd',
      apiType: 'ootd',
    ),
    'exam': FortuneTypeSpec(
      id: 'exam',
      labelKey: 'fortuneLuckyExam',
      endpoint: '/fortune-exam',
    ),
    'moving': FortuneTypeSpec(
      id: 'moving',
      labelKey: 'fortuneMoving',
      endpoint: '/fortune-moving',
    ),
    'celebrity': FortuneTypeSpec(
      id: 'celebrity',
      labelKey: 'fortuneCelebrity',
      endpoint: '/fortune-celebrity',
    ),
    'biorhythm': FortuneTypeSpec(
      id: 'biorhythm',
      labelKey: 'fortuneBiorhythm',
      endpoint: '/fortune-biorhythm',
    ),
    'wish': FortuneTypeSpec(
      id: 'wish',
      labelKey: 'fortuneWish',
      endpoint: '/analyze-wish',
      isLocalOnly: true,
    ),
    'talisman': FortuneTypeSpec(
      id: 'talisman',
      labelKey: 'fortuneTalisman',
      endpoint: '/generate-talisman',
    ),

    // Character-only category entries (currently routed to daily)
    'zodiac': FortuneTypeSpec(
      id: 'zodiac',
      labelKey: 'fortuneZodiac',
      endpoint: '/fortune-daily',
      apiType: 'daily',
    ),
    'zodiac-animal': FortuneTypeSpec(
      id: 'zodiac-animal',
      labelKey: 'fortuneZodiacAnimal',
      endpoint: '/fortune-daily',
      apiType: 'daily',
    ),
    'constellation': FortuneTypeSpec(
      id: 'constellation',
      labelKey: 'fortuneConstellation',
      endpoint: '/fortune-daily',
      apiType: 'daily',
    ),
    'birthstone': FortuneTypeSpec(
      id: 'birthstone',
      labelKey: 'fortuneBirthstone',
      endpoint: '/fortune-daily',
      apiType: 'daily',
    ),

    // Local-only interaction types
    'fortune-cookie': FortuneTypeSpec(
      id: 'fortune-cookie',
      labelKey: 'fortuneFortuneCookie',
      endpoint: null,
      isLocalOnly: true,
    ),
    'breathing': FortuneTypeSpec(
      id: 'breathing',
      labelKey: 'fortuneBreathing',
      endpoint: null,
      isLocalOnly: true,
    ),
    'daily-review': FortuneTypeSpec(
      id: 'daily-review',
      labelKey: 'fortuneDailyReview',
      endpoint: null,
      isLocalOnly: true,
    ),
    'weekly-review': FortuneTypeSpec(
      id: 'weekly-review',
      labelKey: 'fortuneWeeklyReview',
      endpoint: null,
      isLocalOnly: true,
    ),
    'chat-insight': FortuneTypeSpec(
      id: 'chat-insight',
      labelKey: 'fortuneChatInsight',
      endpoint: null,
      isLocalOnly: true,
    ),
    'coaching': FortuneTypeSpec(
      id: 'coaching',
      labelKey: 'fortuneCoaching',
      endpoint: null,
      isLocalOnly: true,
    ),
    'decision': FortuneTypeSpec(
      id: 'decision',
      labelKey: 'fortuneDecisionHelper',
      endpoint: '/fortune-decision',
      isLocalOnly: true,
    ),
    'view-all': FortuneTypeSpec(
      id: 'view-all',
      labelKey: 'chipViewAll',
      endpoint: null,
      isLocalOnly: true,
    ),
    'profile-creation': FortuneTypeSpec(
      id: 'profile-creation',
      labelKey: 'profileSetup',
      endpoint: null,
      isLocalOnly: true,
    ),
  };

  static Iterable<String> get ids => _specs.keys;

  static FortuneTypeSpec? tryGet(String typeId) => _specs[typeId];

  static bool contains(String typeId) => _specs.containsKey(typeId);

  static bool isLocalOnly(String typeId) =>
      _specs[typeId]?.isLocalOnly ?? false;

  static String labelKeyOf(String typeId) => _specs[typeId]?.labelKey ?? typeId;

  static String resolveApiType(
    String typeId, {
    Map<String, dynamic> answers = const {},
  }) {
    final spec = _specs[typeId];
    if (spec == null) return typeId;
    return spec.apiTypeOf(answers);
  }

  static String? endpointOf(
    String typeId, {
    Map<String, dynamic> answers = const {},
  }) {
    final spec = _specs[typeId];
    if (spec == null || spec.endpoint == null) return null;

    final resolvedApiType = spec.apiTypeOf(answers);
    return spec.endpoint!.replaceAll('{apiType}', resolvedApiType);
  }

  static String _resolveFamilyApiType(Map<String, dynamic> answers) {
    final rawConcern = (answers['concern'] ?? answers['family_type'] ?? '')
        .toString()
        .toLowerCase();

    if (rawConcern == 'wealth' || rawConcern == '재물' || rawConcern == '돈') {
      return 'family-wealth';
    }
    if (rawConcern == 'children' || rawConcern == '자녀' || rawConcern == '아이') {
      return 'family-children';
    }
    if (rawConcern == 'relationship' ||
        rawConcern == '관계' ||
        rawConcern == '소통') {
      return 'family-relationship';
    }
    if (rawConcern == 'change' || rawConcern == '변화' || rawConcern == '전환') {
      return 'family-change';
    }
    return 'family-health';
  }
}
