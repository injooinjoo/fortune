// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fortune_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FortuneModelAdapter extends TypeAdapter<FortuneModel> {
  @override
  final int typeId = 0;

  @override
  FortuneModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return FortuneModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      type: fields[2] as String,
      content: fields[3] as String,
      createdAt: fields[4] as DateTime,
      metadata: (fields[5] as Map?)?.cast<String, dynamic>(),
      tokenCost: fields[6] as int,
      rawResponse: fields[7] as String?);
  }

  @override
  void write(BinaryWriter writer, FortuneModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.metadata)
      ..writeByte(6)
      ..write(obj.tokenCost)
      ..writeByte(7)
      ..write(obj.rawResponse);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FortuneModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DailyFortuneModelAdapter extends TypeAdapter<DailyFortuneModel> {
  @override
  final int typeId = 2;

  @override
  DailyFortuneModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return DailyFortuneModel(
      score: fields[0] as int,
      keywords: (fields[1] as List).cast<String>(),
      summary: fields[2] as String,
      luckyColor: fields[3] as String,
      luckyNumber: fields[4] as int,
      energy: fields[5] as int,
      mood: fields[6] as String,
      advice: fields[7] as String,
      caution: fields[8] as String,
      bestTime: fields[9] as String,
      compatibility: fields[10] as String,
      elements: fields[11] as FortuneElementsModel);
  }

  @override
  void write(BinaryWriter writer, DailyFortuneModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.score)
      ..writeByte(1)
      ..write(obj.keywords)
      ..writeByte(2)
      ..write(obj.summary)
      ..writeByte(3)
      ..write(obj.luckyColor)
      ..writeByte(4)
      ..write(obj.luckyNumber)
      ..writeByte(5)
      ..write(obj.energy)
      ..writeByte(6)
      ..write(obj.mood)
      ..writeByte(7)
      ..write(obj.advice)
      ..writeByte(8)
      ..write(obj.caution)
      ..writeByte(9)
      ..write(obj.bestTime)
      ..writeByte(10)
      ..write(obj.compatibility)
      ..writeByte(11)
      ..write(obj.elements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyFortuneModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FortuneElementsModelAdapter extends TypeAdapter<FortuneElementsModel> {
  @override
  final int typeId = 3;

  @override
  FortuneElementsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return FortuneElementsModel(
      love: fields[0] as int,
      career: fields[1] as int,
      money: fields[2] as int,
      health: fields[3] as int);
  }

  @override
  void write(BinaryWriter writer, FortuneElementsModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.love)
      ..writeByte(1)
      ..write(obj.career)
      ..writeByte(2)
      ..write(obj.money)
      ..writeByte(3)
      ..write(obj.health);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FortuneElementsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FortuneModel _$FortuneModelFromJson(Map<String, dynamic> json) => FortuneModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      tokenCost: (json['tokenCost'] as num?)?.toInt() ?? 1,
      rawResponse: json['rawResponse'] as String?);

Map<String, dynamic> _$FortuneModelToJson(FortuneModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'metadata': instance.metadata,
      'tokenCost': instance.tokenCost,
      'rawResponse': instance.rawResponse};

DailyFortuneModel _$DailyFortuneModelFromJson(Map<String, dynamic> json) =>
    DailyFortuneModel(
      score: (json['score'] as num).toInt(),
      keywords:
          (json['keywords'] as List<dynamic>).map((e) => e as String).toList(),
      summary: json['summary'] as String,
      luckyColor: json['luckyColor'] as String,
      luckyNumber: (json['luckyNumber'] as num).toInt(),
      energy: (json['energy'] as num).toInt(),
      mood: json['mood'] as String,
      advice: json['advice'] as String,
      caution: json['caution'] as String,
      bestTime: json['bestTime'] as String,
      compatibility: json['compatibility'] as String,
      elements: FortuneElementsModel.fromJson(
          json['elements'] as Map<String, dynamic>));

Map<String, dynamic> _$DailyFortuneModelToJson(DailyFortuneModel instance) =>
    <String, dynamic>{
      'score': instance.score,
      'keywords': instance.keywords,
      'summary': instance.summary,
      'luckyColor': instance.luckyColor,
      'luckyNumber': instance.luckyNumber,
      'energy': instance.energy,
      'mood': instance.mood,
      'advice': instance.advice,
      'caution': instance.caution,
      'bestTime': instance.bestTime,
      'compatibility': instance.compatibility,
      'elements': instance.elements};

FortuneElementsModel _$FortuneElementsModelFromJson(
        Map<String, dynamic> json) =>
    FortuneElementsModel(
      love: (json['love'] as num).toInt(),
      career: (json['career'] as num).toInt(),
      money: (json['money'] as num).toInt(),
      health: (json['health'] as num).toInt());

Map<String, dynamic> _$FortuneElementsModelToJson(
        FortuneElementsModel instance) =>
    <String, dynamic>{
      'love': instance.love,
      'career': instance.career,
      'money': instance.money,
      'health': instance.health};
