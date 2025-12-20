// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fortune_model.dart';

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
      rawResponse: json['rawResponse'] as String?,
    );

Map<String, dynamic> _$FortuneModelToJson(FortuneModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'metadata': instance.metadata,
      'tokenCost': instance.tokenCost,
      'rawResponse': instance.rawResponse,
    };

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
          json['elements'] as Map<String, dynamic>),
      partnerRecommendations: json['partnerRecommendations'] == null
          ? null
          : PartnerRecommendationsModel.fromJson(
              json['partnerRecommendations'] as Map<String, dynamic>),
    );

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
      'elements': instance.elements,
      'partnerRecommendations': instance.partnerRecommendations,
    };

FortuneElementsModel _$FortuneElementsModelFromJson(
        Map<String, dynamic> json) =>
    FortuneElementsModel(
      love: (json['love'] as num).toInt(),
      career: (json['career'] as num).toInt(),
      money: (json['money'] as num).toInt(),
      health: (json['health'] as num).toInt(),
    );

Map<String, dynamic> _$FortuneElementsModelToJson(
        FortuneElementsModel instance) =>
    <String, dynamic>{
      'love': instance.love,
      'career': instance.career,
      'money': instance.money,
      'health': instance.health,
    };
