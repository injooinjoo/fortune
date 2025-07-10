import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../domain/entities/fortune.dart';

part 'fortune_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class FortuneModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String type;
  
  @HiveField(3)
  final String content;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final Map<String, dynamic>? metadata;
  
  @HiveField(6)
  final int tokenCost;
  
  @HiveField(7)
  final String? rawResponse;

  FortuneModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.content,
    required this.createdAt,
    this.metadata,
    this.tokenCost = 1,
    this.rawResponse,
  });

  factory FortuneModel.fromJson(Map<String, dynamic> json) => 
      _$FortuneModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$FortuneModelToJson(this);

  Fortune toEntity() => Fortune(
    id: id,
    userId: userId,
    type: type,
    content: content,
    createdAt: createdAt,
    metadata: metadata,
    tokenCost: tokenCost,
  );

  factory FortuneModel.fromEntity(Fortune fortune) => FortuneModel(
    id: fortune.id,
    userId: fortune.userId,
    type: fortune.type,
    content: fortune.content,
    createdAt: fortune.createdAt,
    metadata: fortune.metadata,
    tokenCost: fortune.tokenCost,
  );
}

@HiveType(typeId: 2)
@JsonSerializable()
class DailyFortuneModel extends HiveObject {
  @HiveField(0)
  final int score;
  
  @HiveField(1)
  final List<String> keywords;
  
  @HiveField(2)
  final String summary;
  
  @HiveField(3)
  final String luckyColor;
  
  @HiveField(4)
  final int luckyNumber;
  
  @HiveField(5)
  final int energy;
  
  @HiveField(6)
  final String mood;
  
  @HiveField(7)
  final String advice;
  
  @HiveField(8)
  final String caution;
  
  @HiveField(9)
  final String bestTime;
  
  @HiveField(10)
  final String compatibility;
  
  @HiveField(11)
  final FortuneElementsModel elements;

  DailyFortuneModel({
    required this.score,
    required this.keywords,
    required this.summary,
    required this.luckyColor,
    required this.luckyNumber,
    required this.energy,
    required this.mood,
    required this.advice,
    required this.caution,
    required this.bestTime,
    required this.compatibility,
    required this.elements,
  });

  factory DailyFortuneModel.fromJson(Map<String, dynamic> json) => 
      _$DailyFortuneModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$DailyFortuneModelToJson(this);

  DailyFortune toEntity() => DailyFortune(
    score: score,
    keywords: keywords,
    summary: summary,
    luckyColor: luckyColor,
    luckyNumber: luckyNumber,
    energy: energy,
    mood: mood,
    advice: advice,
    caution: caution,
    bestTime: bestTime,
    compatibility: compatibility,
    elements: elements.toEntity(),
  );
}

@HiveType(typeId: 3)
@JsonSerializable()
class FortuneElementsModel extends HiveObject {
  @HiveField(0)
  final int love;
  
  @HiveField(1)
  final int career;
  
  @HiveField(2)
  final int money;
  
  @HiveField(3)
  final int health;

  FortuneElementsModel({
    required this.love,
    required this.career,
    required this.money,
    required this.health,
  });

  factory FortuneElementsModel.fromJson(Map<String, dynamic> json) => 
      _$FortuneElementsModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$FortuneElementsModelToJson(this);

  FortuneElements toEntity() => FortuneElements(
    love: love,
    career: career,
    money: money,
    health: health,
  );
}