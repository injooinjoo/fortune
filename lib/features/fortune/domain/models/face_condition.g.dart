// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'face_condition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FaceConditionImpl _$$FaceConditionImplFromJson(Map<String, dynamic> json) =>
    _$FaceConditionImpl(
      complexionScore: (json['complexionScore'] as num).toInt(),
      complexionDescription: json['complexionDescription'] as String,
      puffinessLevel: (json['puffinessLevel'] as num).toInt(),
      puffinessDescription: json['puffinessDescription'] as String,
      fatigueLevel: (json['fatigueLevel'] as num).toInt(),
      fatigueDescription: json['fatigueDescription'] as String,
      overallScore: (json['overallScore'] as num).toInt(),
      todaySummary: json['todaySummary'] as String,
      improvementTips: (json['improvementTips'] as List<dynamic>?)
              ?.map((e) => ConditionTip.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$FaceConditionImplToJson(_$FaceConditionImpl instance) =>
    <String, dynamic>{
      'complexionScore': instance.complexionScore,
      'complexionDescription': instance.complexionDescription,
      'puffinessLevel': instance.puffinessLevel,
      'puffinessDescription': instance.puffinessDescription,
      'fatigueLevel': instance.fatigueLevel,
      'fatigueDescription': instance.fatigueDescription,
      'overallScore': instance.overallScore,
      'todaySummary': instance.todaySummary,
      'improvementTips': instance.improvementTips,
    };

_$ConditionTipImpl _$$ConditionTipImplFromJson(Map<String, dynamic> json) =>
    _$ConditionTipImpl(
      category: json['category'] as String,
      content: json['content'] as String,
      emoji: json['emoji'] as String? ?? '💡',
    );

Map<String, dynamic> _$$ConditionTipImplToJson(_$ConditionTipImpl instance) =>
    <String, dynamic>{
      'category': instance.category,
      'content': instance.content,
      'emoji': instance.emoji,
    };

_$ConditionTrendImpl _$$ConditionTrendImplFromJson(Map<String, dynamic> json) =>
    _$ConditionTrendImpl(
      weeklyAverage: (json['weeklyAverage'] as num).toDouble(),
      weeklyChange: (json['weeklyChange'] as num).toDouble(),
      trendDirection: json['trendDirection'] as String,
      trendInsight: json['trendInsight'] as String,
      dailyConditions: (json['dailyConditions'] as List<dynamic>?)
              ?.map((e) => DailyCondition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ConditionTrendImplToJson(
        _$ConditionTrendImpl instance) =>
    <String, dynamic>{
      'weeklyAverage': instance.weeklyAverage,
      'weeklyChange': instance.weeklyChange,
      'trendDirection': instance.trendDirection,
      'trendInsight': instance.trendInsight,
      'dailyConditions': instance.dailyConditions,
    };

_$DailyConditionImpl _$$DailyConditionImplFromJson(Map<String, dynamic> json) =>
    _$DailyConditionImpl(
      date: DateTime.parse(json['date'] as String),
      overallScore: (json['overallScore'] as num).toInt(),
      complexionScore: (json['complexionScore'] as num).toInt(),
      puffinessLevel: (json['puffinessLevel'] as num).toInt(),
      fatigueLevel: (json['fatigueLevel'] as num).toInt(),
    );

Map<String, dynamic> _$$DailyConditionImplToJson(
        _$DailyConditionImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'overallScore': instance.overallScore,
      'complexionScore': instance.complexionScore,
      'puffinessLevel': instance.puffinessLevel,
      'fatigueLevel': instance.fatigueLevel,
    };
