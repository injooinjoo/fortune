// Decision Receipt Model
//
// 사용자의 결정 기록을 저장하고 팔로업을 관리합니다.
// ZPZG Decision Coach Pivot - Phase 1.3

/// 결정 유형
enum DecisionType {
  dating('dating', '연애'),
  career('career', '커리어'),
  money('money', '재정'),
  wellness('wellness', '건강'),
  lifestyle('lifestyle', '라이프스타일'),
  relationship('relationship', '관계');

  const DecisionType(this.value, this.label);
  final String value;
  final String label;

  static DecisionType fromString(String value) {
    return DecisionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DecisionType.lifestyle,
    );
  }
}

/// 결과 상태
enum OutcomeStatus {
  pending('pending', '대기 중'),
  positive('positive', '긍정적'),
  negative('negative', '부정적'),
  neutral('neutral', '중립'),
  mixed('mixed', '복합적');

  const OutcomeStatus(this.value, this.label);
  final String value;
  final String label;

  static OutcomeStatus fromString(String value) {
    return OutcomeStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OutcomeStatus.pending,
    );
  }
}

/// 선택지 분석 결과
class OptionAnalysis {
  final String option;
  final List<String> pros;
  final List<String> cons;

  OptionAnalysis({
    required this.option,
    required this.pros,
    required this.cons,
  });

  factory OptionAnalysis.fromJson(Map<String, dynamic> json) {
    return OptionAnalysis(
      option: json['option'] as String? ?? '',
      pros: (json['pros'] as List<dynamic>?)?.cast<String>() ?? [],
      cons: (json['cons'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'option': option,
    'pros': pros,
    'cons': cons,
  };
}

/// 결정 기록 모델
class DecisionReceipt {
  final String id;
  final String userId;
  final DecisionType decisionType;
  final String question;
  final String chosenOption;
  final String? reasoning;
  final List<OptionAnalysis>? optionsAnalyzed;
  final String? aiRecommendation;
  final int? confidenceLevel; // 1-5
  final String? emotionalState;
  final OutcomeStatus outcomeStatus;
  final String? outcomeNotes;
  final int? outcomeRating; // 1-5
  final DateTime? outcomeRecordedAt;
  final DateTime? followUpDate;
  final bool followUpSent;
  final int followUpCount;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DecisionReceipt({
    required this.id,
    required this.userId,
    required this.decisionType,
    required this.question,
    required this.chosenOption,
    this.reasoning,
    this.optionsAnalyzed,
    this.aiRecommendation,
    this.confidenceLevel,
    this.emotionalState,
    this.outcomeStatus = OutcomeStatus.pending,
    this.outcomeNotes,
    this.outcomeRating,
    this.outcomeRecordedAt,
    this.followUpDate,
    this.followUpSent = false,
    this.followUpCount = 0,
    this.tags = const [],
    this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  factory DecisionReceipt.fromJson(Map<String, dynamic> json) {
    return DecisionReceipt(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      decisionType: DecisionType.fromString(json['decision_type'] as String? ?? 'lifestyle'),
      question: json['question'] as String? ?? '',
      chosenOption: json['chosen_option'] as String? ?? '',
      reasoning: json['reasoning'] as String?,
      optionsAnalyzed: (json['options_analyzed'] as List<dynamic>?)
          ?.map((e) => OptionAnalysis.fromJson(e as Map<String, dynamic>))
          .toList(),
      aiRecommendation: json['ai_recommendation'] as String?,
      confidenceLevel: json['confidence_level'] as int?,
      emotionalState: json['emotional_state'] as String?,
      outcomeStatus: OutcomeStatus.fromString(json['outcome_status'] as String? ?? 'pending'),
      outcomeNotes: json['outcome_notes'] as String?,
      outcomeRating: json['outcome_rating'] as int?,
      outcomeRecordedAt: json['outcome_recorded_at'] != null
          ? DateTime.parse(json['outcome_recorded_at'] as String)
          : null,
      followUpDate: json['follow_up_date'] != null
          ? DateTime.parse(json['follow_up_date'] as String)
          : null,
      followUpSent: json['follow_up_sent'] as bool? ?? false,
      followUpCount: json['follow_up_count'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'decision_type': decisionType.value,
    'question': question,
    'chosen_option': chosenOption,
    'reasoning': reasoning,
    'options_analyzed': optionsAnalyzed?.map((e) => e.toJson()).toList(),
    'ai_recommendation': aiRecommendation,
    'confidence_level': confidenceLevel,
    'emotional_state': emotionalState,
    'outcome_status': outcomeStatus.value,
    'outcome_notes': outcomeNotes,
    'outcome_rating': outcomeRating,
    'outcome_recorded_at': outcomeRecordedAt?.toIso8601String(),
    'follow_up_date': followUpDate?.toIso8601String(),
    'follow_up_sent': followUpSent,
    'follow_up_count': followUpCount,
    'tags': tags,
    'metadata': metadata,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  DecisionReceipt copyWith({
    String? id,
    String? userId,
    DecisionType? decisionType,
    String? question,
    String? chosenOption,
    String? reasoning,
    List<OptionAnalysis>? optionsAnalyzed,
    String? aiRecommendation,
    int? confidenceLevel,
    String? emotionalState,
    OutcomeStatus? outcomeStatus,
    String? outcomeNotes,
    int? outcomeRating,
    DateTime? outcomeRecordedAt,
    DateTime? followUpDate,
    bool? followUpSent,
    int? followUpCount,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DecisionReceipt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      decisionType: decisionType ?? this.decisionType,
      question: question ?? this.question,
      chosenOption: chosenOption ?? this.chosenOption,
      reasoning: reasoning ?? this.reasoning,
      optionsAnalyzed: optionsAnalyzed ?? this.optionsAnalyzed,
      aiRecommendation: aiRecommendation ?? this.aiRecommendation,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      emotionalState: emotionalState ?? this.emotionalState,
      outcomeStatus: outcomeStatus ?? this.outcomeStatus,
      outcomeNotes: outcomeNotes ?? this.outcomeNotes,
      outcomeRating: outcomeRating ?? this.outcomeRating,
      outcomeRecordedAt: outcomeRecordedAt ?? this.outcomeRecordedAt,
      followUpDate: followUpDate ?? this.followUpDate,
      followUpSent: followUpSent ?? this.followUpSent,
      followUpCount: followUpCount ?? this.followUpCount,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 팔로업이 필요한지 확인
  bool get needsFollowUp {
    return outcomeStatus == OutcomeStatus.pending &&
        !followUpSent &&
        followUpDate != null &&
        followUpDate!.isBefore(DateTime.now());
  }

  /// 결정 후 경과 일수
  int get daysAgo {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// 팔로업까지 남은 일수 (음수면 연체)
  int? get daysUntilFollowUp {
    if (followUpDate == null) return null;
    return followUpDate!.difference(DateTime.now()).inDays;
  }
}

/// 결정 패턴 분석 결과
class DecisionPatternAnalysis {
  final int totalDecisions;
  final int completedOutcomes;
  final int positiveRate; // 0-100
  final double avgConfidence;
  final String? mostCommonType;
  final List<String> insights;

  DecisionPatternAnalysis({
    required this.totalDecisions,
    required this.completedOutcomes,
    required this.positiveRate,
    required this.avgConfidence,
    this.mostCommonType,
    required this.insights,
  });

  factory DecisionPatternAnalysis.fromJson(Map<String, dynamic> json) {
    return DecisionPatternAnalysis(
      totalDecisions: json['totalDecisions'] as int? ?? 0,
      completedOutcomes: json['completedOutcomes'] as int? ?? 0,
      positiveRate: json['positiveRate'] as int? ?? 0,
      avgConfidence: (json['avgConfidence'] as num?)?.toDouble() ?? 0.0,
      mostCommonType: json['mostCommonType'] as String?,
      insights: (json['insights'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

/// 결정 통계
class DecisionStats {
  final int totalDecisions;
  final int positiveOutcomes;
  final int negativeOutcomes;
  final int pendingOutcomes;
  final double? avgConfidence;
  final double? avgOutcomeRating;
  final String? mostCommonType;
  final Map<String, int> decisionsByType;

  DecisionStats({
    required this.totalDecisions,
    required this.positiveOutcomes,
    required this.negativeOutcomes,
    required this.pendingOutcomes,
    this.avgConfidence,
    this.avgOutcomeRating,
    this.mostCommonType,
    required this.decisionsByType,
  });

  factory DecisionStats.fromJson(Map<String, dynamic> json) {
    return DecisionStats(
      totalDecisions: json['total_decisions'] as int? ?? 0,
      positiveOutcomes: json['positive_outcomes'] as int? ?? 0,
      negativeOutcomes: json['negative_outcomes'] as int? ?? 0,
      pendingOutcomes: json['pending_outcomes'] as int? ?? 0,
      avgConfidence: (json['avg_confidence'] as num?)?.toDouble(),
      avgOutcomeRating: (json['avg_outcome_rating'] as num?)?.toDouble(),
      mostCommonType: json['most_common_type'] as String?,
      decisionsByType: (json['decisions_by_type'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as int)) ?? {},
    );
  }
}
