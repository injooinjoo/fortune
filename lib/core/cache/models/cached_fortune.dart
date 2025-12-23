import 'package:hive/hive.dart';
import 'package:fortune/domain/entities/fortune.dart';

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

  CachedFortune(
      {required this.id,
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
      this.additionalInfo});

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
        additionalInfo: additionalInfo);
  }

  factory CachedFortune.fromFortune(Fortune fortune,
      {Duration ttl = const Duration(hours: 24)}) {
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
        additionalInfo: fortune.additionalInfo);
  }
}

class CachedFortuneAdapter extends TypeAdapter<CachedFortune> {
  @override
  final int typeId = 0;

  @override
  CachedFortune read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedFortune(
      id: fields[0] as String,
      type: fields[1] as String,
      userId: fields[2] as String,
      content: fields[3] as String,
      metadata: (fields[4] as Map?)?.cast<String, dynamic>(),
      createdAt: fields[5] as DateTime,
      expiresAt: fields[6] as DateTime,
      tokenCost: fields[7] as int,
      category: fields[8] as String?,
      overallScore: fields[9] as int?,
      description: fields[10] as String?,
      scoreBreakdown: (fields[11] as Map?)?.cast<String, dynamic>(),
      luckyItems: (fields[12] as Map?)?.cast<String, dynamic>(),
      recommendations: (fields[13] as List?)?.cast<String>(),
      summary: fields[14] as String?,
      additionalInfo: (fields[15] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, CachedFortune obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.metadata)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.expiresAt)
      ..writeByte(7)
      ..write(obj.tokenCost)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.overallScore)
      ..writeByte(10)
      ..write(obj.description)
      ..writeByte(11)
      ..write(obj.scoreBreakdown)
      ..writeByte(12)
      ..write(obj.luckyItems)
      ..writeByte(13)
      ..write(obj.recommendations)
      ..writeByte(14)
      ..write(obj.summary)
      ..writeByte(15)
      ..write(obj.additionalInfo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedFortuneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
