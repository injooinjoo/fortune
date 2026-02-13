import '../../core/constants/fortune_detailed_metadata.dart';
import 'fortune.dart';

// 상세 운세 엔티티 (UI에서 사용하는 확장된 Fortune)
class DetailedFortune extends Fortune {
  const DetailedFortune({
    required super.id,
    required super.userId,
    required super.type,
    required super.content,
    required super.createdAt,
    super.metadata,
    super.tokenCost = 1,
    required String super.category,
    required int super.overallScore,
    required String super.description,
    required Map<String, dynamic> super.scoreBreakdown,
    required Map<String, dynamic> super.luckyItems,
    required List<String> super.recommendations,
  });

  factory DetailedFortune.fromFortune(
    Fortune fortune, {
    required String category,
    required int overallScore,
    required String description,
    required Map<String, dynamic> scoreBreakdown,
    required Map<String, dynamic> luckyItems,
    required List<String> recommendations,
  }) {
    return DetailedFortune(
      id: fortune.id,
      userId: fortune.userId,
      type: fortune.type,
      content: fortune.content,
      createdAt: fortune.createdAt,
      metadata: fortune.metadata,
      tokenCost: fortune.tokenCost,
      category: category,
      overallScore: overallScore,
      description: description,
      scoreBreakdown: scoreBreakdown,
      luckyItems: luckyItems,
      recommendations: recommendations,
    );
  }

  @override
  DetailedFortune copyWith({
    String? id,
    String? userId,
    String? type,
    String? content,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    int? tokenCost,
    String? category,
    int? overallScore,
    String? description,
    Map<String, dynamic>? scoreBreakdown,
    Map<String, dynamic>? luckyItems,
    List<String>? recommendations,
    // ✅ Percentile fields
    int? percentile,
    int? totalTodayViewers,
    bool? isPercentileValid,
    // Parent parameters that might be needed for full compatibility
    List<String>? warnings,
    String? summary,
    Map<String, dynamic>? additionalInfo,
    Map<String, List<DetailedLuckyItem>>? detailedLuckyItems,
    String? greeting,
    Map<String, int>? hexagonScores,
    List<TimeSpecificFortune>? timeSpecificFortunes,
    List<BirthYearFortune>? birthYearFortunes,
    Map<String, dynamic>? fiveElements,
    String? specialTip,
    String? period,
    Map<String, dynamic>? meta,
    Map<String, dynamic>? weatherSummary,
    Map<String, dynamic>? overall,
    Map<String, dynamic>? categories,
    Map<String, dynamic>? sajuInsight,
    List<Map<String, dynamic>>? personalActions,
    Map<String, dynamic>? notification,
    Map<String, dynamic>? shareCard,
    List<String>? uiBlocks,
    Map<String, dynamic>? explain,
  }) {
    return DetailedFortune(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      tokenCost: tokenCost ?? this.tokenCost,
      category: category ?? this.category ?? '',
      overallScore: overallScore ?? this.overallScore ?? 0,
      description: description ?? this.description ?? '',
      scoreBreakdown: scoreBreakdown ?? this.scoreBreakdown ?? {},
      luckyItems: luckyItems ?? this.luckyItems ?? {},
      recommendations: recommendations ?? this.recommendations ?? [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
      'tokenCost': tokenCost,
      'category': category,
      'overallScore': overallScore,
      'description': description,
      'scoreBreakdown': scoreBreakdown,
      'luckyItems': luckyItems,
      'recommendations': recommendations,
    };
  }

  factory DetailedFortune.fromJson(Map<String, dynamic> json) {
    return DetailedFortune(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      tokenCost: json['tokenCost'] as int? ?? 1,
      category: json['category'] as String,
      overallScore: json['overallScore'] as int,
      description: json['description'] as String,
      scoreBreakdown: Map<String, dynamic>.from(json['scoreBreakdown'] as Map),
      luckyItems: Map<String, dynamic>.from(json['luckyItems'] as Map),
      recommendations: List<String>.from(json['recommendations'] as List),
    );
  }
}