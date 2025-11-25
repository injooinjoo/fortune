/// 헤어진 애인 운세 간소화 모델
class ExLoverSimpleInput {
  // Step 1: 핵심 질문
  final String timeSinceBreakup; // recent(1개월 미만), short(1-3개월), medium(3-6개월), long(6개월-1년), verylong(1년 이상)
  final String currentEmotion; // miss(그리움), anger(분노), sadness(슬픔), relief(안도), acceptance(받아들임)
  final String mainCuriosity; // theirFeelings(상대방 마음), reunionChance(재회 가능성), newLove(새로운 사랑), healing(치유 방법)
  
  // Step 2: 선택 정보
  final DateTime? exBirthDate;
  final String? breakupReason; // differentValues(가치관), timing(시기), communication(소통), trust(신뢰), other(기타)
  
  ExLoverSimpleInput({
    required this.timeSinceBreakup,
    required this.currentEmotion,
    required this.mainCuriosity,
    this.exBirthDate,
    this.breakupReason,
  });
}

/// 감정 중심 결과 모델
class ExLoverEmotionalResult {
  // 오늘의 감정 처방
  final EmotionalPrescription emotionalPrescription;

  // 그 사람과의 인연
  final RelationshipInsight relationshipInsight;

  // 새로운 시작
  final NewBeginning newBeginning;

  // 전체 운세 점수
  final int overallScore;

  // 특별 메시지
  final String specialMessage;

  ExLoverEmotionalResult({
    required this.emotionalPrescription,
    required this.relationshipInsight,
    required this.newBeginning,
    required this.overallScore,
    required this.specialMessage,
  });

  factory ExLoverEmotionalResult.fromJson(Map<String, dynamic> json) {
    return ExLoverEmotionalResult(
      emotionalPrescription: EmotionalPrescription.fromJson(
        json['emotional_prescription'] as Map<String, dynamic>,
      ),
      relationshipInsight: RelationshipInsight.fromJson(
        json['relationship_insight'] as Map<String, dynamic>,
      ),
      newBeginning: NewBeginning.fromJson(
        json['new_beginning'] as Map<String, dynamic>,
      ),
      overallScore: json['overall_score'] as int? ?? 50,
      specialMessage: json['special_message'] as String? ?? '',
    );
  }
}

/// 오늘의 감정 처방
class EmotionalPrescription {
  final String currentState; // 현재 감정 상태 분석
  final List<String> recommendedActivities; // 추천 활동
  final List<String> thingsToAvoid; // 피해야 할 것들
  final String healingAdvice; // 치유 조언
  final int healingProgress; // 치유 진행도 (0-100)

  EmotionalPrescription({
    required this.currentState,
    required this.recommendedActivities,
    required this.thingsToAvoid,
    required this.healingAdvice,
    required this.healingProgress,
  });

  factory EmotionalPrescription.fromJson(Map<String, dynamic> json) {
    return EmotionalPrescription(
      currentState: json['current_state'] as String? ?? '',
      recommendedActivities: (json['recommended_activities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      thingsToAvoid: (json['things_to_avoid'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      healingAdvice: json['healing_advice'] as String? ?? '',
      healingProgress: json['healing_progress'] as int? ?? 50,
    );
  }
}

/// 그 사람과의 인연
class RelationshipInsight {
  final int reunionPossibility; // 재회 가능성 (0-100)
  final String theirCurrentFeelings; // 상대방 현재 마음
  final String contactTiming; // 연락 타이밍 조언
  final String karmicLesson; // 이 관계에서 배울 점
  final bool isThinkingOfYou; // 상대방도 생각하고 있을까

  RelationshipInsight({
    required this.reunionPossibility,
    required this.theirCurrentFeelings,
    required this.contactTiming,
    required this.karmicLesson,
    required this.isThinkingOfYou,
  });

  factory RelationshipInsight.fromJson(Map<String, dynamic> json) {
    return RelationshipInsight(
      reunionPossibility: json['reunion_possibility'] as int? ?? 50,
      theirCurrentFeelings: json['their_current_feelings'] as String? ?? '',
      contactTiming: json['contact_timing'] as String? ?? '',
      karmicLesson: json['karmic_lesson'] as String? ?? '',
      isThinkingOfYou: json['is_thinking_of_you'] as bool? ?? false,
    );
  }
}

/// 새로운 시작
class NewBeginning {
  final String readinessLevel; // 준비 정도 (not_ready, preparing, almost_ready, ready)
  final String expectedTiming; // 새로운 인연 시기
  final List<String> growthPoints; // 성장 포인트
  final String newLoveAdvice; // 새로운 사랑 조언
  final int readinessScore; // 준비도 점수 (0-100)

  NewBeginning({
    required this.readinessLevel,
    required this.expectedTiming,
    required this.growthPoints,
    required this.newLoveAdvice,
    required this.readinessScore,
  });

  factory NewBeginning.fromJson(Map<String, dynamic> json) {
    return NewBeginning(
      readinessLevel: json['readiness_level'] as String? ?? 'preparing',
      expectedTiming: json['expected_timing'] as String? ?? '',
      growthPoints: (json['growth_points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      newLoveAdvice: json['new_love_advice'] as String? ?? '',
      readinessScore: json['readiness_score'] as int? ?? 50,
    );
  }
}

/// 감정 카드 데이터
class EmotionCard {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final List<int> gradientColors;
  
  const EmotionCard({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.gradientColors,
  });
}

/// 미리 정의된 감정 카드들
const List<EmotionCard> emotionCards = [
  EmotionCard(
    id: 'miss',
    title: '그리움',
    emoji: '💙',
    description: '아직도 그 사람이 보고 싶어요',
    gradientColors: [0xFF5B8DEE, 0xFF3F51B5],
  ),
  EmotionCard(
    id: 'anger',
    title: '분노',
    emoji: '🔥',
    description: '배신감과 분노를 느껴요',
    gradientColors: [0xFFE91E63, 0xFFF44336],
  ),
  EmotionCard(
    id: 'sadness',
    title: '슬픔',
    emoji: '💧',
    description: '너무 슬프고 외로워요',
    gradientColors: [0xFF3F51B5, 0xFF303F9F],
  ),
  EmotionCard(
    id: 'relief',
    title: '안도',
    emoji: '🌿',
    description: '헤어진 게 다행이라고 생각해요',
    gradientColors: [0xFF4CAF50, 0xFF66BB6A],
  ),
  EmotionCard(
    id: 'acceptance',
    title: '받아들임',
    emoji: '🕊️',
    description: '이제는 받아들일 수 있어요',
    gradientColors: [0xFF9C27B0, 0xFFBA68C8],
  ),
];

/// 주요 궁금증 카드
class CuriosityCard {
  final String id;
  final String title;
  final String icon;
  final String description;
  
  const CuriosityCard({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
  });
}

const List<CuriosityCard> curiosityCards = [
  CuriosityCard(
    id: 'theirFeelings',
    title: '상대방 마음',
    icon: '💭',
    description: '그 사람도 나를 생각할까?',
  ),
  CuriosityCard(
    id: 'reunionChance',
    title: '재회 가능성',
    icon: '🔄',
    description: '우리 다시 만날 수 있을까?',
  ),
  CuriosityCard(
    id: 'newLove',
    title: '새로운 사랑',
    icon: '🌸',
    description: '언제 새로운 사랑을 시작할까?',
  ),
  CuriosityCard(
    id: 'healing',
    title: '치유 방법',
    icon: '🌱',
    description: '어떻게 마음을 치유할까?',
  ),
];