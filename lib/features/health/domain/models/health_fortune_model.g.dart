// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_fortune_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthFortuneResultImpl _$$HealthFortuneResultImplFromJson(
        Map<String, dynamic> json) =>
    _$HealthFortuneResultImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      overallScore: (json['overallScore'] as num).toInt(),
      mainMessage: json['mainMessage'] as String,
      bodyPartHealthList: (json['bodyPartHealthList'] as List<dynamic>)
          .map((e) => BodyPartHealth.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => HealthRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      avoidanceList: (json['avoidanceList'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      timeline:
          HealthTimeline.fromJson(json['timeline'] as Map<String, dynamic>),
      tomorrowPreview: json['tomorrowPreview'] as String?,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$HealthFortuneResultImplToJson(
        _$HealthFortuneResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'overallScore': instance.overallScore,
      'mainMessage': instance.mainMessage,
      'bodyPartHealthList': instance.bodyPartHealthList,
      'recommendations': instance.recommendations,
      'avoidanceList': instance.avoidanceList,
      'timeline': instance.timeline,
      'tomorrowPreview': instance.tomorrowPreview,
      'additionalInfo': instance.additionalInfo,
    };

_$BodyPartHealthImpl _$$BodyPartHealthImplFromJson(Map<String, dynamic> json) =>
    _$BodyPartHealthImpl(
      bodyPart: $enumDecode(_$BodyPartEnumMap, json['bodyPart']),
      score: (json['score'] as num).toInt(),
      level: $enumDecode(_$HealthLevelEnumMap, json['level']),
      description: json['description'] as String,
      specificTips: (json['specificTips'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$BodyPartHealthImplToJson(
        _$BodyPartHealthImpl instance) =>
    <String, dynamic>{
      'bodyPart': _$BodyPartEnumMap[instance.bodyPart]!,
      'score': instance.score,
      'level': _$HealthLevelEnumMap[instance.level]!,
      'description': instance.description,
      'specificTips': instance.specificTips,
    };

const _$BodyPartEnumMap = {
  BodyPart.head: 'head',
  BodyPart.neck: 'neck',
  BodyPart.shoulders: 'shoulders',
  BodyPart.chest: 'chest',
  BodyPart.stomach: 'stomach',
  BodyPart.back: 'back',
  BodyPart.arms: 'arms',
  BodyPart.legs: 'legs',
  BodyPart.whole: 'whole',
};

const _$HealthLevelEnumMap = {
  HealthLevel.excellent: 'excellent',
  HealthLevel.good: 'good',
  HealthLevel.caution: 'caution',
  HealthLevel.warning: 'warning',
};

_$HealthRecommendationImpl _$$HealthRecommendationImplFromJson(
        Map<String, dynamic> json) =>
    _$HealthRecommendationImpl(
      type: $enumDecode(_$HealthRecommendationTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String?,
      priority: (json['priority'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$HealthRecommendationImplToJson(
        _$HealthRecommendationImpl instance) =>
    <String, dynamic>{
      'type': _$HealthRecommendationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'icon': instance.icon,
      'priority': instance.priority,
    };

const _$HealthRecommendationTypeEnumMap = {
  HealthRecommendationType.food: 'food',
  HealthRecommendationType.exercise: 'exercise',
  HealthRecommendationType.rest: 'rest',
  HealthRecommendationType.lifestyle: 'lifestyle',
  HealthRecommendationType.medical: 'medical',
};

_$HealthTimelineImpl _$$HealthTimelineImplFromJson(Map<String, dynamic> json) =>
    _$HealthTimelineImpl(
      morning: HealthTimeSlot.fromJson(json['morning'] as Map<String, dynamic>),
      afternoon:
          HealthTimeSlot.fromJson(json['afternoon'] as Map<String, dynamic>),
      evening: HealthTimeSlot.fromJson(json['evening'] as Map<String, dynamic>),
      bestTimeActivity: json['bestTimeActivity'] as String?,
    );

Map<String, dynamic> _$$HealthTimelineImplToJson(
        _$HealthTimelineImpl instance) =>
    <String, dynamic>{
      'morning': instance.morning,
      'afternoon': instance.afternoon,
      'evening': instance.evening,
      'bestTimeActivity': instance.bestTimeActivity,
    };

_$HealthTimeSlotImpl _$$HealthTimeSlotImplFromJson(Map<String, dynamic> json) =>
    _$HealthTimeSlotImpl(
      timeLabel: json['timeLabel'] as String,
      conditionScore: (json['conditionScore'] as num).toInt(),
      description: json['description'] as String,
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$HealthTimeSlotImplToJson(
        _$HealthTimeSlotImpl instance) =>
    <String, dynamic>{
      'timeLabel': instance.timeLabel,
      'conditionScore': instance.conditionScore,
      'description': instance.description,
      'recommendations': instance.recommendations,
    };

_$HealthFortuneInputImpl _$$HealthFortuneInputImplFromJson(
        Map<String, dynamic> json) =>
    _$HealthFortuneInputImpl(
      userId: json['userId'] as String,
      currentCondition: $enumDecodeNullable(
          _$ConditionStateEnumMap, json['currentCondition']),
      concernedBodyParts: (json['concernedBodyParts'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$BodyPartEnumMap, e))
          .toList(),
      specificSymptoms: json['specificSymptoms'] as String?,
      hasChronicCondition: json['hasChronicCondition'] as bool?,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$HealthFortuneInputImplToJson(
        _$HealthFortuneInputImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'currentCondition': _$ConditionStateEnumMap[instance.currentCondition],
      'concernedBodyParts': instance.concernedBodyParts
          ?.map((e) => _$BodyPartEnumMap[e]!)
          .toList(),
      'specificSymptoms': instance.specificSymptoms,
      'hasChronicCondition': instance.hasChronicCondition,
      'additionalInfo': instance.additionalInfo,
    };

const _$ConditionStateEnumMap = {
  ConditionState.excellent: 'excellent',
  ConditionState.good: 'good',
  ConditionState.normal: 'normal',
  ConditionState.tired: 'tired',
  ConditionState.sick: 'sick',
};
