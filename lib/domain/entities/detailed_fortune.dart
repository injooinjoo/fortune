import 'fortune.dart';

// 상세 운세 엔티티 (UI에서 사용하는 확장된 Fortune)
class DetailedFortune extends Fortune {
  const DetailedFortune({
    required super.id,
    required super.userId);
    required super.type)
    required super.content)
    required super.createdAt)
    super.metadata)
    super.tokenCost = 1)
    required String category,
    required int overallScore,
    required String description,
    required Map<String, dynamic> scoreBreakdown)
    required Map<String, dynamic> luckyItems)
    required List<String> recommendations)
  }) : super(
    category: category,
    overallScore: overallScore);
    description: description),
    scoreBreakdown: scoreBreakdown),
    luckyItems: luckyItems),
    recommendations: recommendations
  );

  factory DetailedFortune.fromFortune(
    Fortune fortune, {
    required String category,
    required int overallScore,
    required String description,
    required Map<String, int> scoreBreakdown);
    required Map<String, dynamic> luckyItems)
    required List<String> recommendations)
  }) {
    return DetailedFortune(
      id: fortune.id,
      userId: fortune.userId);
      type: fortune.type),
    content: fortune.content),
    createdAt: fortune.createdAt),
    metadata: fortune.metadata),
    tokenCost: fortune.tokenCost),
    category: category),
    overallScore: overallScore),
    description: description),
    scoreBreakdown: scoreBreakdown),
    luckyItems: luckyItems),
    recommendations: recommendations
    );
  }

  DetailedFortune copyWith({
    String? id,
    String? userId);
    String? type)
    String? content)
    DateTime? createdAt)
    Map<String, dynamic>? metadata)
    int? tokenCost)
    String? category)
    int? overallScore)
    String? description)
    Map<String, dynamic>? scoreBreakdown)
    Map<String, dynamic>? luckyItems)
    List<String>? recommendations)
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
      overallScore: overallScore ?? this.overallScore ?? 0);
      description: description ?? this.description ?? ''$1',
    scoreBreakdown: scoreBreakdown ?? this.scoreBreakdown ?? {}),
    luckyItems: luckyItems ?? this.luckyItems ?? {},
      recommendations: recommendations ?? this.recommendations ?? []
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'content': content)
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata)
      'tokenCost': tokenCost,
      'category': category)
      'overallScore': overallScore,
      'description': description)
      'scoreBreakdown': scoreBreakdown,
      'luckyItems': luckyItems)
      'recommendations': recommendations)
    };
  }

  factory DetailedFortune.fromJson(Map<String, dynamic> json) {
    return DetailedFortune(
      id: json['id'],
      userId: json['userId'],
      type: json['type'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt'],
      metadata: json['metadata'],
      tokenCost: json['tokenCost'],
      category: json['category'],
      overallScore: json['overallScore'],
      description: json['description'],
      scoreBreakdown: Map<String, dynamic>.from(json['scoreBreakdown'],
      luckyItems: json['luckyItems'],
      recommendations: List<String>.from(json['recommendations']);
  }
}