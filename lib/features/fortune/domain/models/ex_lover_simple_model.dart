// 헤어진 애인 운세 모델 (v2 - 솔직한 조언자)

// ============================================================================
// 상담 목표 (가치 제안)
// ============================================================================
enum PrimaryGoal {
  healing,        // 감정 정리 + 힐링
  reunionStrategy, // 재회 전략 가이드
  readTheirMind,  // 상대방 마음 읽기
  newStart,       // 새 출발 준비도
}

extension PrimaryGoalExtension on PrimaryGoal {
  String get id {
    switch (this) {
      case PrimaryGoal.healing:
        return 'healing';
      case PrimaryGoal.reunionStrategy:
        return 'reunion_strategy';
      case PrimaryGoal.readTheirMind:
        return 'read_their_mind';
      case PrimaryGoal.newStart:
        return 'new_start';
    }
  }

  String get label {
    switch (this) {
      case PrimaryGoal.healing:
        return '감정 정리 + 힐링';
      case PrimaryGoal.reunionStrategy:
        return '재회 전략 가이드';
      case PrimaryGoal.readTheirMind:
        return '상대방 마음 읽기';
      case PrimaryGoal.newStart:
        return '새 출발 준비도';
    }
  }

  String get emoji {
    switch (this) {
      case PrimaryGoal.healing:
        return '🌿';
      case PrimaryGoal.reunionStrategy:
        return '🔄';
      case PrimaryGoal.readTheirMind:
        return '💭';
      case PrimaryGoal.newStart:
        return '🌸';
    }
  }

  static PrimaryGoal fromString(String? value) {
    switch (value) {
      case 'healing':
        return PrimaryGoal.healing;
      case 'reunion_strategy':
        return PrimaryGoal.reunionStrategy;
      case 'read_their_mind':
        return PrimaryGoal.readTheirMind;
      case 'new_start':
        return PrimaryGoal.newStart;
      default:
        return PrimaryGoal.healing;
    }
  }
}

// ============================================================================
// Input 모델 (v2 - 8단계 설문)
// ============================================================================
class ExLoverSimpleInput {
  // 상대방 정보
  final String? exName;
  final String? exMbti;
  final DateTime? exBirthDate;

  // ✅ Step 1: 상담 목표 (가치 제안)
  final PrimaryGoal primaryGoal;

  // ✅ Step 2: 이별 시점 + 통보자
  final String timeSinceBreakup; // very_recent, recent, 1to3months, 3to6months, 6to12months, over_year
  final String breakupInitiator; // me, them, mutual

  // ✅ Step 3: 관계 깊이
  final String relationshipDepth; // casual, moderate, deep, very_deep

  // ✅ Step 4: 핵심 이별 이유
  final String coreReason; // values, communication, trust, cheating, distance, family, feelings_changed, personal_issues, unknown

  // ✅ Step 5: 상세 이야기 (음성/텍스트)
  final String? breakupDetail;

  // ✅ Step 6: 현재 상태 (복수 선택)
  final List<String> currentState; // cant_sleep, checking_sns, crying, angry, regret, miss_them, relieved, confused, moving_on

  // ✅ Step 7: 연락 상태
  final String contactStatus; // blocked, noContact, sometimes, often, stillMeeting

  // ✅ Step 8: 목표별 심화 질문
  final Map<String, dynamic>? goalSpecific;

  // 추가 정보 (선택)
  final String? chatHistory;

  // 하위 호환성 (기존 필드)
  final String? relationshipDuration;
  final String? currentEmotion;
  final String? mainCuriosity;
  final String? breakupReason;

  ExLoverSimpleInput({
    this.exName,
    this.exMbti,
    this.exBirthDate,
    required this.primaryGoal,
    required this.timeSinceBreakup,
    required this.breakupInitiator,
    required this.relationshipDepth,
    required this.coreReason,
    this.breakupDetail,
    required this.currentState,
    required this.contactStatus,
    this.goalSpecific,
    this.chatHistory,
    // 하위 호환성
    this.relationshipDuration,
    this.currentEmotion,
    this.mainCuriosity,
    this.breakupReason,
  });

  Map<String, dynamic> toJson() => {
        'ex_name': exName,
        'ex_mbti': exMbti,
        'ex_birth_date': exBirthDate?.toIso8601String(),
        'primaryGoal': primaryGoal.id,
        'time_since_breakup': timeSinceBreakup,
        'breakup_initiator': breakupInitiator,
        'relationshipDepth': relationshipDepth,
        'coreReason': coreReason,
        'breakup_detail': breakupDetail,
        'currentState': currentState,
        'contact_status': contactStatus,
        'goalSpecific': goalSpecific,
        'chat_history': chatHistory,
        // 하위 호환성
        'relationship_duration': relationshipDuration ?? timeSinceBreakup,
        'current_emotion': currentEmotion,
        'main_curiosity': mainCuriosity,
        'breakup_reason': breakupReason ?? coreReason,
      };
}

// ============================================================================
// Hard Truth 섹션 (v2 핵심!)
// ============================================================================
class HardTruth {
  final String headline; // "냉정하게 말하면..."
  final String diagnosis; // 현재 상황 진단
  final List<String> realityCheck; // 현실 체크 포인트
  final String mostImportantAdvice; // 가장 중요한 조언

  HardTruth({
    required this.headline,
    required this.diagnosis,
    required this.realityCheck,
    required this.mostImportantAdvice,
  });

  factory HardTruth.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return HardTruth(
        headline: '솔직하게 말해줄게요.',
        diagnosis: '현재 상황을 분석 중입니다.',
        realityCheck: ['분석 중...'],
        mostImportantAdvice: '지금은 자신에게 집중하세요.',
      );
    }
    return HardTruth(
      headline: json['headline'] as String? ?? '솔직하게 말해줄게요.',
      diagnosis: json['diagnosis'] as String? ?? '',
      realityCheck: (json['realityCheck'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      mostImportantAdvice: json['mostImportantAdvice'] as String? ?? '',
    );
  }
}

// ============================================================================
// 재회 평가 (v2 - 현실적 기준)
// ============================================================================
class ReunionAssessment {
  final int score; // 재회 가능성 (0-reunionCap)
  final List<String> keyFactors; // 핵심 요인
  final String timing; // 적절한 시기
  final String approach; // 접근 방법
  final List<String> neverDo; // 절대 하면 안 되는 것

  ReunionAssessment({
    required this.score,
    required this.keyFactors,
    required this.timing,
    required this.approach,
    required this.neverDo,
  });

  factory ReunionAssessment.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ReunionAssessment(
        score: 50,
        keyFactors: ['분석 중...'],
        timing: '적절한 시기 분석 중',
        approach: '접근 방법 분석 중',
        neverDo: ['연락 폭탄 금지', 'SNS 스토킹 금지'],
      );
    }
    return ReunionAssessment(
      score: json['score'] as int? ?? 50,
      keyFactors: (json['keyFactors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      timing: json['timing'] as String? ?? '',
      approach: json['approach'] as String? ?? '',
      neverDo: (json['neverDo'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['연락 폭탄 금지', 'SNS 스토킹 금지', '술 먹고 연락 금지'],
    );
  }
}

// ============================================================================
// 감정 처방 (v2)
// ============================================================================
class EmotionalPrescriptionV2 {
  final String currentStateAnalysis; // 현재 감정 상태 분석
  final String healingFocus; // 치유 집중 포인트
  final List<String> weeklyActions; // 이번 주 실천 사항
  final String monthlyMilestone; // 한 달 후 목표

  EmotionalPrescriptionV2({
    required this.currentStateAnalysis,
    required this.healingFocus,
    required this.weeklyActions,
    required this.monthlyMilestone,
  });

  factory EmotionalPrescriptionV2.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EmotionalPrescriptionV2(
        currentStateAnalysis: '감정 상태 분석 중',
        healingFocus: '치유 포인트 분석 중',
        weeklyActions: ['자기 돌봄에 집중하기'],
        monthlyMilestone: '한 달 후 목표 설정 중',
      );
    }
    return EmotionalPrescriptionV2(
      currentStateAnalysis: json['currentStateAnalysis'] as String? ?? '',
      healingFocus: json['healingFocus'] as String? ?? '',
      weeklyActions: (json['weeklyActions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      monthlyMilestone: json['monthlyMilestone'] as String? ?? '',
    );
  }
}

// ============================================================================
// 상대방 관점 (v2)
// ============================================================================
class TheirPerspective {
  final String likelyThoughts; // 상대방 감정 추측
  final String doTheyThinkOfYou; // 그 사람도 나를 생각할까?
  final String whatTheyNeed; // 상대방에게 필요한 것

  TheirPerspective({
    required this.likelyThoughts,
    required this.doTheyThinkOfYou,
    required this.whatTheyNeed,
  });

  factory TheirPerspective.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return TheirPerspective(
        likelyThoughts: '상대방 감정 분석 중',
        doTheyThinkOfYou: '솔직한 분석을 준비 중입니다',
        whatTheyNeed: '분석 중',
      );
    }
    return TheirPerspective(
      likelyThoughts: json['likelyThoughts'] as String? ?? '',
      doTheyThinkOfYou: json['doTheyThinkOfYou'] as String? ?? '',
      whatTheyNeed: json['whatTheyNeed'] as String? ?? '',
    );
  }
}

// ============================================================================
// 전략적 조언 (v2)
// ============================================================================
class StrategicAdvice {
  final String shortTerm; // 1주일 내 액션
  final String midTerm; // 1개월 내 목표
  final String longTerm; // 3개월 후 체크포인트

  StrategicAdvice({
    required this.shortTerm,
    required this.midTerm,
    required this.longTerm,
  });

  factory StrategicAdvice.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StrategicAdvice(
        shortTerm: '1주일 내 해야 할 것 분석 중',
        midTerm: '1개월 내 목표 설정 중',
        longTerm: '3개월 후 체크포인트 설정 중',
      );
    }
    return StrategicAdvice(
      shortTerm: json['shortTerm'] as String? ?? '',
      midTerm: json['midTerm'] as String? ?? '',
      longTerm: json['longTerm'] as String? ?? '',
    );
  }
}

// ============================================================================
// 새 출발 (v2)
// ============================================================================
class NewBeginningV2 {
  final int readinessScore; // 새 출발 준비도 (0-100)
  final List<String> unresolvedIssues; // 미해결 감정/문제
  final List<String> growthPoints; // 성장 포인트
  final String newLoveTiming; // 새 인연 가능 시기

  NewBeginningV2({
    required this.readinessScore,
    required this.unresolvedIssues,
    required this.growthPoints,
    required this.newLoveTiming,
  });

  factory NewBeginningV2.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return NewBeginningV2(
        readinessScore: 50,
        unresolvedIssues: ['미해결 감정 분석 중'],
        growthPoints: ['성장 포인트 분석 중'],
        newLoveTiming: '새 인연 시기 분석 중',
      );
    }
    return NewBeginningV2(
      readinessScore: json['readinessScore'] as int? ?? 50,
      unresolvedIssues: (json['unresolvedIssues'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      growthPoints: (json['growthPoints'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      newLoveTiming: json['newLoveTiming'] as String? ?? '',
    );
  }
}

// ============================================================================
// 마일스톤 (v2)
// ============================================================================
class Milestones {
  final List<String> oneWeek; // 1주일 후 체크
  final List<String> oneMonth; // 1개월 후 체크
  final List<String> threeMonths; // 3개월 후 체크

  Milestones({
    required this.oneWeek,
    required this.oneMonth,
    required this.threeMonths,
  });

  factory Milestones.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Milestones(
        oneWeek: ['감정 일기 쓰기', '자기 돌봄 시간 갖기'],
        oneMonth: ['새로운 취미 시작', '자기 성장 점검'],
        threeMonths: ['관계 복기 완료', '미래 계획 세우기'],
      );
    }
    return Milestones(
      oneWeek: (json['oneWeek'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      oneMonth: (json['oneMonth'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      threeMonths: (json['threeMonths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

// ============================================================================
// 마무리 메시지 (v2)
// ============================================================================
class ClosingMessage {
  final String empathy; // 공감 메시지
  final String todayAction; // 오늘 당장 할 것

  ClosingMessage({
    required this.empathy,
    required this.todayAction,
  });

  factory ClosingMessage.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClosingMessage(
        empathy: '힘들지... 괜찮아질 거야.',
        todayAction: '오늘은 좋아하는 음악 한 곡 들으며 쉬어요.',
      );
    }
    return ClosingMessage(
      empathy: json['empathy'] as String? ?? '힘들지...',
      todayAction: json['todayAction'] as String? ?? '',
    );
  }
}

// ============================================================================
// 결과 모델 (v2 - 솔직한 조언자)
// ============================================================================
class ExLoverEmotionalResultV2 {
  // 메타 정보
  final String title;
  final int score;
  final PrimaryGoal primaryGoal;
  final String coreReason;
  final int reunionCap; // 재회 가능성 최대값

  // ✅ 핵심 섹션: Hard Truth (항상 첫 번째)
  final HardTruth hardTruth;

  // 목표별 섹션
  final ReunionAssessment reunionAssessment;
  final EmotionalPrescriptionV2 emotionalPrescription;
  final TheirPerspective theirPerspective;
  final StrategicAdvice strategicAdvice;
  final NewBeginningV2 newBeginning;
  final Milestones milestones;
  final ClosingMessage closingMessage;

  // 블러 정보
  final bool isBlurred;
  final List<String> blurredSections;

  ExLoverEmotionalResultV2({
    required this.title,
    required this.score,
    required this.primaryGoal,
    required this.coreReason,
    required this.reunionCap,
    required this.hardTruth,
    required this.reunionAssessment,
    required this.emotionalPrescription,
    required this.theirPerspective,
    required this.strategicAdvice,
    required this.newBeginning,
    required this.milestones,
    required this.closingMessage,
    this.isBlurred = false,
    this.blurredSections = const [],
  });

  factory ExLoverEmotionalResultV2.fromJson(Map<String, dynamic> json) {
    return ExLoverEmotionalResultV2(
      title: json['title'] as String? ?? '솔직한 조언자',
      score: json['score'] as int? ?? 70,
      primaryGoal: PrimaryGoalExtension.fromString(json['primaryGoal'] as String?),
      coreReason: json['coreReason'] as String? ?? 'unknown',
      reunionCap: json['reunionCap'] as int? ?? 100,
      hardTruth: HardTruth.fromJson(json['hardTruth'] as Map<String, dynamic>?),
      reunionAssessment: ReunionAssessment.fromJson(
          json['reunionAssessment'] as Map<String, dynamic>?),
      emotionalPrescription: EmotionalPrescriptionV2.fromJson(
          json['emotionalPrescription'] as Map<String, dynamic>?),
      theirPerspective: TheirPerspective.fromJson(
          json['theirPerspective'] as Map<String, dynamic>?),
      strategicAdvice: StrategicAdvice.fromJson(
          json['strategicAdvice'] as Map<String, dynamic>?),
      newBeginning: NewBeginningV2.fromJson(
          json['newBeginning'] as Map<String, dynamic>?),
      milestones:
          Milestones.fromJson(json['milestones'] as Map<String, dynamic>?),
      closingMessage: ClosingMessage.fromJson(
          json['closingMessage'] as Map<String, dynamic>?),
      isBlurred: json['isBlurred'] as bool? ?? false,
      blurredSections: (json['blurredSections'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// 목표별 섹션 우선순위 반환
  List<String> getSectionPriority() {
    switch (primaryGoal) {
      case PrimaryGoal.healing:
        return ['hardTruth', 'emotionalPrescription', 'theirPerspective', 'reunionAssessment'];
      case PrimaryGoal.reunionStrategy:
        return ['hardTruth', 'reunionAssessment', 'strategicAdvice', 'emotionalPrescription'];
      case PrimaryGoal.readTheirMind:
        return ['hardTruth', 'theirPerspective', 'reunionAssessment', 'emotionalPrescription'];
      case PrimaryGoal.newStart:
        return ['hardTruth', 'newBeginning', 'emotionalPrescription', 'theirPerspective'];
    }
  }
}

// ============================================================================
// 하위 호환성: 기존 모델들 유지
// ============================================================================

/// 감정 중심 결과 모델 (v1 - 하위 호환성)
class ExLoverEmotionalResult {
  final EmotionalPrescription emotionalPrescription;
  final RelationshipInsight relationshipInsight;
  final NewBeginning newBeginning;
  final int overallScore;
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
        json['emotional_prescription'] as Map<String, dynamic>?,
      ),
      relationshipInsight: RelationshipInsight.fromJson(
        json['relationship_insight'] as Map<String, dynamic>?,
      ),
      newBeginning: NewBeginning.fromJson(
        json['new_beginning'] as Map<String, dynamic>?,
      ),
      overallScore: json['overall_score'] as int? ?? 50,
      specialMessage: json['special_message'] as String? ?? '',
    );
  }
}

/// 오늘의 감정 처방 (v1)
class EmotionalPrescription {
  final String currentState;
  final List<String> recommendedActivities;
  final List<String> thingsToAvoid;
  final String healingAdvice;
  final int healingProgress;

  EmotionalPrescription({
    required this.currentState,
    required this.recommendedActivities,
    required this.thingsToAvoid,
    required this.healingAdvice,
    required this.healingProgress,
  });

  factory EmotionalPrescription.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EmotionalPrescription(
        currentState: '',
        recommendedActivities: [],
        thingsToAvoid: [],
        healingAdvice: '',
        healingProgress: 50,
      );
    }
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

/// 그 사람과의 인연 (v1)
class RelationshipInsight {
  final int reunionPossibility;
  final String theirCurrentFeelings;
  final String contactTiming;
  final String karmicLesson;
  final bool isThinkingOfYou;

  RelationshipInsight({
    required this.reunionPossibility,
    required this.theirCurrentFeelings,
    required this.contactTiming,
    required this.karmicLesson,
    required this.isThinkingOfYou,
  });

  factory RelationshipInsight.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RelationshipInsight(
        reunionPossibility: 50,
        theirCurrentFeelings: '',
        contactTiming: '',
        karmicLesson: '',
        isThinkingOfYou: false,
      );
    }
    return RelationshipInsight(
      reunionPossibility: json['reunion_possibility'] as int? ?? 50,
      theirCurrentFeelings: json['their_current_feelings'] as String? ?? '',
      contactTiming: json['contact_timing'] as String? ?? '',
      karmicLesson: json['karmic_lesson'] as String? ?? '',
      isThinkingOfYou: json['is_thinking_of_you'] as bool? ?? false,
    );
  }
}

/// 새로운 시작 (v1)
class NewBeginning {
  final String readinessLevel;
  final String expectedTiming;
  final List<String> growthPoints;
  final String newLoveAdvice;
  final int readinessScore;

  NewBeginning({
    required this.readinessLevel,
    required this.expectedTiming,
    required this.growthPoints,
    required this.newLoveAdvice,
    required this.readinessScore,
  });

  factory NewBeginning.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return NewBeginning(
        readinessLevel: 'preparing',
        expectedTiming: '',
        growthPoints: [],
        newLoveAdvice: '',
        readinessScore: 50,
      );
    }
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

// ============================================================================
// UI 카드 데이터 (하위 호환성)
// ============================================================================

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

class BreakupInitiatorCard {
  final String id;
  final String title;
  final String emoji;
  final String description;

  const BreakupInitiatorCard({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
  });
}

const List<BreakupInitiatorCard> breakupInitiatorCards = [
  BreakupInitiatorCard(
    id: 'me',
    title: '내가 먼저',
    emoji: '💔',
    description: '내가 먼저 이별을 말했어요',
  ),
  BreakupInitiatorCard(
    id: 'them',
    title: '상대가 먼저',
    emoji: '😢',
    description: '상대가 먼저 이별을 말했어요',
  ),
  BreakupInitiatorCard(
    id: 'mutual',
    title: '서로 합의',
    emoji: '🤝',
    description: '서로 합의해서 헤어졌어요',
  ),
];

class RelationshipDurationOption {
  final String id;
  final String label;

  const RelationshipDurationOption({
    required this.id,
    required this.label,
  });
}

const List<RelationshipDurationOption> relationshipDurationOptions = [
  RelationshipDurationOption(id: 'lessThan1Month', label: '1개월 미만'),
  RelationshipDurationOption(id: '1to3Months', label: '1-3개월'),
  RelationshipDurationOption(id: '3to6Months', label: '3-6개월'),
  RelationshipDurationOption(id: '6to12Months', label: '6개월-1년'),
  RelationshipDurationOption(id: '1to2Years', label: '1-2년'),
  RelationshipDurationOption(id: '2to3Years', label: '2-3년'),
  RelationshipDurationOption(id: 'moreThan3Years', label: '3년 이상'),
];

class ContactStatusOption {
  final String id;
  final String label;

  const ContactStatusOption({
    required this.id,
    required this.label,
  });
}

const List<ContactStatusOption> contactStatusOptions = [
  ContactStatusOption(id: 'blocked', label: '완전 차단'),
  ContactStatusOption(id: 'noContact', label: '연락 안 함'),
  ContactStatusOption(id: 'sometimes', label: '가끔 연락'),
  ContactStatusOption(id: 'often', label: '자주 연락'),
  ContactStatusOption(id: 'stillMeeting', label: '아직 만남'),
];

const List<String> mbtiOptions = [
  'ISTJ', 'ISFJ', 'INFJ', 'INTJ',
  'ISTP', 'ISFP', 'INFP', 'INTP',
  'ESTP', 'ESFP', 'ENFP', 'ENTP',
  'ESTJ', 'ESFJ', 'ENFJ', 'ENTJ',
  'unknown',
];
