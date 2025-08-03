import 'package:hive/hive.dart';
import 'package:fortune/domain/entities/fortune.dart';

part 'cached_fortune.g.dart';

@HiveType(typeId: 0)
class CachedFortune extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final Map<String, dynamic>? metadata;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime expiresAt;

  @HiveField(7)
  final int tokenCost;

  @HiveField(8)
  final String? category;

  @HiveField(9)
  final int? overallScore;

  @HiveField(10)
  final String? description;

  @HiveField(11)
  final Map<String, dynamic>? scoreBreakdown;

  @HiveField(12)
  final Map<String, dynamic>? luckyItems;

  @HiveField(13)
  final List<String>? recommendations;

  @HiveField(14)
  final String? summary;

  @HiveField(15)
  final Map<String, dynamic>? additionalInfo;

  CachedFortune({
    required this.id,
    required this.type,
    required this.userId,
    required this.content,
    this.metadata,
    required this.createdAt,
    required this.expiresAt,
    this.tokenCost = 1,
    this.category,
    this.overallScore,
    this.description,
    this.scoreBreakdown,
    this.luckyItems,
    this.recommendations,
    this.summary,
    this.additionalInfo,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Fortune toFortune() {
    return Fortune(
      id: id,
      type: type,
      userId: userId,
      content: content,
      metadata: metadata,
      createdAt: createdAt,
      tokenCost: tokenCost,
      category: category,
      overallScore: overallScore,
      description: description,
      scoreBreakdown: scoreBreakdown,
      luckyItems: luckyItems,
      recommendations: recommendations,
      summary: summary,
      additionalInfo: additionalInfo,
    );
  }

  factory CachedFortune.fromFortune(Fortune fortune, {Duration ttl = const Duration(hours: 24)}) {
    return CachedFortune(
      id: fortune.id,
      type: fortune.type,
      userId: fortune.userId,
      content: fortune.content,
      metadata: fortune.metadata,
      createdAt: fortune.createdAt,
      expiresAt: DateTime.now().add(ttl),
      tokenCost: fortune.tokenCost,
      category: fortune.category,
      overallScore: fortune.overallScore,
      description: fortune.description,
      scoreBreakdown: fortune.scoreBreakdown,
      luckyItems: fortune.luckyItems,
      recommendations: fortune.recommendations,
      summary: fortune.summary,
      additionalInfo: fortune.additionalInfo,
    );
  }
}