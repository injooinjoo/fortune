// User Coach Preferences Model
//
// AI 코칭 개인화 설정을 관리합니다.
// ZPZG Decision Coach Pivot - Phase 1.3

/// AI 톤 설정
enum TonePreference {
  friendly('friendly', '친구 모드', '🤝 편하고 따뜻한 친구처럼 대화해요'),
  professional('professional', '컨설턴트 모드', '📊 전문적이고 객관적으로 분석해요'),
  adaptive('adaptive', '적응형', '✨ 상황에 맞게 톤을 조절해요');

  const TonePreference(this.value, this.label, this.description);
  final String value;
  final String label;
  final String description;

  static TonePreference fromString(String value) {
    return TonePreference.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TonePreference.adaptive,
    );
  }
}

/// 응답 길이 설정
enum ResponseLength {
  concise('concise', '간결하게', '⚡ 핵심만 짧게'),
  balanced('balanced', '적당하게', '📝 적절한 설명 포함'),
  detailed('detailed', '상세하게', '📖 자세한 분석과 예시');

  const ResponseLength(this.value, this.label, this.description);
  final String value;
  final String label;
  final String description;

  static ResponseLength fromString(String value) {
    return ResponseLength.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ResponseLength.balanced,
    );
  }
}

/// 결정 스타일 설정
enum DecisionStyle {
  logic('logic', '논리 중심', '🧠 데이터와 객관적 분석'),
  empathy('empathy', '감정 중심', '💗 감정과 가치관 우선'),
  balanced('balanced', '균형', '⚖️ 논리와 감정 모두 고려');

  const DecisionStyle(this.value, this.label, this.description);
  final String value;
  final String label;
  final String description;

  static DecisionStyle fromString(String value) {
    return DecisionStyle.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DecisionStyle.balanced,
    );
  }
}

/// 관계 상태
enum RelationshipStatus {
  single('single', '싱글'),
  dating('dating', '연애 중'),
  married('married', '기혼'),
  complicated('complicated', '복잡해요'),
  preferNotToSay('prefer_not_to_say', '비공개');

  const RelationshipStatus(this.value, this.label);
  final String value;
  final String label;

  static RelationshipStatus? fromString(String? value) {
    if (value == null) return null;
    return RelationshipStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RelationshipStatus.preferNotToSay,
    );
  }
}

/// 연령대
enum AgeGroup {
  teens('teens', '10대'),
  twenties('20s', '20대'),
  thirties('30s', '30대'),
  forties('40s', '40대'),
  fiftiesPlus('50s_plus', '50대 이상'),
  preferNotToSay('prefer_not_to_say', '비공개');

  const AgeGroup(this.value, this.label);
  final String value;
  final String label;

  static AgeGroup? fromString(String? value) {
    if (value == null) return null;
    return AgeGroup.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AgeGroup.preferNotToSay,
    );
  }
}

/// 익명 ID 프리픽스 유형
enum AnonymousPrefixType {
  animal('animal', '동물', '예: 익명의 고양이 42'),
  color('color', '색상', '예: 익명의 파란 42'),
  random('random', '랜덤', '예: 익명의 용감한 42');

  const AnonymousPrefixType(this.value, this.label, this.example);
  final String value;
  final String label;
  final String example;

  static AnonymousPrefixType fromString(String value) {
    return AnonymousPrefixType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AnonymousPrefixType.animal,
    );
  }
}

/// 상호작용 요약 (AI 학습용)
class InteractionSummary {
  final int totalSessions;
  final double avgConfidence;
  final double positiveOutcomeRate;
  final List<String> mostDiscussedTopics;
  final DateTime? lastUpdated;

  InteractionSummary({
    this.totalSessions = 0,
    this.avgConfidence = 0.0,
    this.positiveOutcomeRate = 0.0,
    this.mostDiscussedTopics = const [],
    this.lastUpdated,
  });

  factory InteractionSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return InteractionSummary();
    return InteractionSummary(
      totalSessions: json['total_sessions'] as int? ?? 0,
      avgConfidence: (json['avg_confidence'] as num?)?.toDouble() ?? 0.0,
      positiveOutcomeRate: (json['positive_outcome_rate'] as num?)?.toDouble() ?? 0.0,
      mostDiscussedTopics: (json['most_discussed_topics'] as List<dynamic>?)?.cast<String>() ?? [],
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_sessions': totalSessions,
    'avg_confidence': avgConfidence,
    'positive_outcome_rate': positiveOutcomeRate,
    'most_discussed_topics': mostDiscussedTopics,
    'last_updated': lastUpdated?.toIso8601String(),
  };
}

/// 설정 설명
class PreferenceDescriptions {
  final String tone;
  final String responseLength;
  final String decisionStyle;

  PreferenceDescriptions({
    required this.tone,
    required this.responseLength,
    required this.decisionStyle,
  });

  factory PreferenceDescriptions.fromJson(Map<String, dynamic> json) {
    return PreferenceDescriptions(
      tone: json['tone'] as String? ?? '',
      responseLength: json['responseLength'] as String? ?? '',
      decisionStyle: json['decisionStyle'] as String? ?? '',
    );
  }
}

/// 사용자 코치 설정 모델
class UserCoachPreferences {
  final String userId;

  // AI 설정
  final TonePreference tonePreference;
  final ResponseLength responseLength;
  final DecisionStyle decisionStyle;

  // 사용자 컨텍스트
  final RelationshipStatus? relationshipStatus;
  final AgeGroup? ageGroup;
  final String? occupationType;
  final List<String> preferredCategories;

  // 알림 설정
  final bool followUpReminderEnabled;
  final int followUpDays;
  final bool pushNotificationEnabled;

  // 커뮤니티 설정
  final AnonymousPrefixType communityAnonymousPrefix;
  final bool communityParticipationEnabled;

  // AI 학습 데이터
  final InteractionSummary interactionSummary;

  // 메타데이터
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // 설명 (API 응답에서)
  final PreferenceDescriptions? descriptions;
  final bool isNew;

  UserCoachPreferences({
    required this.userId,
    this.tonePreference = TonePreference.adaptive,
    this.responseLength = ResponseLength.balanced,
    this.decisionStyle = DecisionStyle.balanced,
    this.relationshipStatus,
    this.ageGroup,
    this.occupationType,
    this.preferredCategories = const ['dating', 'career', 'lifestyle'],
    this.followUpReminderEnabled = true,
    this.followUpDays = 7,
    this.pushNotificationEnabled = true,
    this.communityAnonymousPrefix = AnonymousPrefixType.animal,
    this.communityParticipationEnabled = true,
    InteractionSummary? interactionSummary,
    this.metadata,
    DateTime? createdAt,
    this.updatedAt,
    this.descriptions,
    this.isNew = false,
  }) : interactionSummary = interactionSummary ?? InteractionSummary(),
       createdAt = createdAt ?? DateTime.now();

  factory UserCoachPreferences.fromJson(Map<String, dynamic> json) {
    return UserCoachPreferences(
      userId: json['user_id'] as String,
      tonePreference: TonePreference.fromString(json['tone_preference'] as String? ?? 'adaptive'),
      responseLength: ResponseLength.fromString(json['response_length'] as String? ?? 'balanced'),
      decisionStyle: DecisionStyle.fromString(json['decision_style'] as String? ?? 'balanced'),
      relationshipStatus: RelationshipStatus.fromString(json['relationship_status'] as String?),
      ageGroup: AgeGroup.fromString(json['age_group'] as String?),
      occupationType: json['occupation_type'] as String?,
      preferredCategories: (json['preferred_categories'] as List<dynamic>?)?.cast<String>() ?? ['dating', 'career', 'lifestyle'],
      followUpReminderEnabled: json['follow_up_reminder_enabled'] as bool? ?? true,
      followUpDays: json['follow_up_days'] as int? ?? 7,
      pushNotificationEnabled: json['push_notification_enabled'] as bool? ?? true,
      communityAnonymousPrefix: AnonymousPrefixType.fromString(json['community_anonymous_prefix'] as String? ?? 'animal'),
      communityParticipationEnabled: json['community_participation_enabled'] as bool? ?? true,
      interactionSummary: InteractionSummary.fromJson(json['interaction_summary'] as Map<String, dynamic>?),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      descriptions: json['descriptions'] != null
          ? PreferenceDescriptions.fromJson(json['descriptions'] as Map<String, dynamic>)
          : null,
      isNew: json['isNew'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'tone_preference': tonePreference.value,
    'response_length': responseLength.value,
    'decision_style': decisionStyle.value,
    'relationship_status': relationshipStatus?.value,
    'age_group': ageGroup?.value,
    'occupation_type': occupationType,
    'preferred_categories': preferredCategories,
    'follow_up_reminder_enabled': followUpReminderEnabled,
    'follow_up_days': followUpDays,
    'push_notification_enabled': pushNotificationEnabled,
    'community_anonymous_prefix': communityAnonymousPrefix.value,
    'community_participation_enabled': communityParticipationEnabled,
    'interaction_summary': interactionSummary.toJson(),
    'metadata': metadata,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  /// 업데이트용 JSON (변경된 필드만)
  Map<String, dynamic> toUpdateJson() => {
    'tone_preference': tonePreference.value,
    'response_length': responseLength.value,
    'decision_style': decisionStyle.value,
    if (relationshipStatus != null) 'relationship_status': relationshipStatus!.value,
    if (ageGroup != null) 'age_group': ageGroup!.value,
    if (occupationType != null) 'occupation_type': occupationType,
    'preferred_categories': preferredCategories,
    'follow_up_reminder_enabled': followUpReminderEnabled,
    'follow_up_days': followUpDays,
    'push_notification_enabled': pushNotificationEnabled,
    'community_anonymous_prefix': communityAnonymousPrefix.value,
    'community_participation_enabled': communityParticipationEnabled,
  };

  UserCoachPreferences copyWith({
    String? userId,
    TonePreference? tonePreference,
    ResponseLength? responseLength,
    DecisionStyle? decisionStyle,
    RelationshipStatus? relationshipStatus,
    AgeGroup? ageGroup,
    String? occupationType,
    List<String>? preferredCategories,
    bool? followUpReminderEnabled,
    int? followUpDays,
    bool? pushNotificationEnabled,
    AnonymousPrefixType? communityAnonymousPrefix,
    bool? communityParticipationEnabled,
    InteractionSummary? interactionSummary,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    PreferenceDescriptions? descriptions,
    bool? isNew,
  }) {
    return UserCoachPreferences(
      userId: userId ?? this.userId,
      tonePreference: tonePreference ?? this.tonePreference,
      responseLength: responseLength ?? this.responseLength,
      decisionStyle: decisionStyle ?? this.decisionStyle,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      ageGroup: ageGroup ?? this.ageGroup,
      occupationType: occupationType ?? this.occupationType,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      followUpReminderEnabled: followUpReminderEnabled ?? this.followUpReminderEnabled,
      followUpDays: followUpDays ?? this.followUpDays,
      pushNotificationEnabled: pushNotificationEnabled ?? this.pushNotificationEnabled,
      communityAnonymousPrefix: communityAnonymousPrefix ?? this.communityAnonymousPrefix,
      communityParticipationEnabled: communityParticipationEnabled ?? this.communityParticipationEnabled,
      interactionSummary: interactionSummary ?? this.interactionSummary,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      descriptions: descriptions ?? this.descriptions,
      isNew: isNew ?? this.isNew,
    );
  }

  /// 기본 설정인지 확인
  bool get isDefaultSettings {
    return tonePreference == TonePreference.adaptive &&
        responseLength == ResponseLength.balanced &&
        decisionStyle == DecisionStyle.balanced;
  }
}

/// AI 프롬프트 컨텍스트 (내부용)
class AIPromptContext {
  final String tone;
  final String responseLength;
  final String decisionStyle;
  final Map<String, dynamic> userContext;
  final Map<String, dynamic> interactionHistory;

  AIPromptContext({
    required this.tone,
    required this.responseLength,
    required this.decisionStyle,
    required this.userContext,
    required this.interactionHistory,
  });

  factory AIPromptContext.fromJson(Map<String, dynamic> json) {
    return AIPromptContext(
      tone: json['tone'] as String? ?? 'adaptive',
      responseLength: json['response_length'] as String? ?? 'balanced',
      decisionStyle: json['decision_style'] as String? ?? 'balanced',
      userContext: json['user_context'] as Map<String, dynamic>? ?? {},
      interactionHistory: json['interaction_history'] as Map<String, dynamic>? ?? {},
    );
  }
}
