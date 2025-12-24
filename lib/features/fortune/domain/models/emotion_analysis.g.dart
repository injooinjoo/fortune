// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emotion_analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EmotionAnalysisImpl _$$EmotionAnalysisImplFromJson(
        Map<String, dynamic> json) =>
    _$EmotionAnalysisImpl(
      smilePercentage: (json['smilePercentage'] as num).toDouble(),
      tensionPercentage: (json['tensionPercentage'] as num).toDouble(),
      neutralPercentage: (json['neutralPercentage'] as num).toDouble(),
      relaxedPercentage: (json['relaxedPercentage'] as num).toDouble(),
      dominantEmotion: json['dominantEmotion'] as String,
      emotionDescription: json['emotionDescription'] as String,
      impressionAnalysis: ImpressionAnalysis.fromJson(
          json['impressionAnalysis'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$EmotionAnalysisImplToJson(
        _$EmotionAnalysisImpl instance) =>
    <String, dynamic>{
      'smilePercentage': instance.smilePercentage,
      'tensionPercentage': instance.tensionPercentage,
      'neutralPercentage': instance.neutralPercentage,
      'relaxedPercentage': instance.relaxedPercentage,
      'dominantEmotion': instance.dominantEmotion,
      'emotionDescription': instance.emotionDescription,
      'impressionAnalysis': instance.impressionAnalysis,
    };

_$ImpressionAnalysisImpl _$$ImpressionAnalysisImplFromJson(
        Map<String, dynamic> json) =>
    _$ImpressionAnalysisImpl(
      firstImpressionKeywords:
          (json['firstImpressionKeywords'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      relationshipImpression: json['relationshipImpression'] as String,
      professionalImpression: json['professionalImpression'] as String,
      romanticImpression: json['romanticImpression'] as String?,
      improvementSuggestions: (json['improvementSuggestions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      trustScore: (json['trustScore'] as num?)?.toInt() ?? 50,
      approachabilityScore:
          (json['approachabilityScore'] as num?)?.toInt() ?? 50,
      charismaScore: (json['charismaScore'] as num?)?.toInt() ?? 50,
      overallImpression: json['overallImpression'] as String?,
    );

Map<String, dynamic> _$$ImpressionAnalysisImplToJson(
        _$ImpressionAnalysisImpl instance) =>
    <String, dynamic>{
      'firstImpressionKeywords': instance.firstImpressionKeywords,
      'relationshipImpression': instance.relationshipImpression,
      'professionalImpression': instance.professionalImpression,
      'romanticImpression': instance.romanticImpression,
      'improvementSuggestions': instance.improvementSuggestions,
      'trustScore': instance.trustScore,
      'approachabilityScore': instance.approachabilityScore,
      'charismaScore': instance.charismaScore,
      'overallImpression': instance.overallImpression,
    };

_$EmotionTrendImpl _$$EmotionTrendImplFromJson(Map<String, dynamic> json) =>
    _$EmotionTrendImpl(
      weeklySmileAverage: (json['weeklySmileAverage'] as num).toDouble(),
      smileChange: (json['smileChange'] as num).toDouble(),
      dominantWeeklyEmotion: json['dominantWeeklyEmotion'] as String,
      emotionInsight: json['emotionInsight'] as String,
      dailyEmotions: (json['dailyEmotions'] as List<dynamic>?)
              ?.map((e) => DailyEmotion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$EmotionTrendImplToJson(_$EmotionTrendImpl instance) =>
    <String, dynamic>{
      'weeklySmileAverage': instance.weeklySmileAverage,
      'smileChange': instance.smileChange,
      'dominantWeeklyEmotion': instance.dominantWeeklyEmotion,
      'emotionInsight': instance.emotionInsight,
      'dailyEmotions': instance.dailyEmotions,
    };

_$DailyEmotionImpl _$$DailyEmotionImplFromJson(Map<String, dynamic> json) =>
    _$DailyEmotionImpl(
      date: DateTime.parse(json['date'] as String),
      smilePercentage: (json['smilePercentage'] as num).toDouble(),
      tensionPercentage: (json['tensionPercentage'] as num).toDouble(),
      neutralPercentage: (json['neutralPercentage'] as num).toDouble(),
      relaxedPercentage: (json['relaxedPercentage'] as num).toDouble(),
      dominantEmotion: json['dominantEmotion'] as String,
    );

Map<String, dynamic> _$$DailyEmotionImplToJson(_$DailyEmotionImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'smilePercentage': instance.smilePercentage,
      'tensionPercentage': instance.tensionPercentage,
      'neutralPercentage': instance.neutralPercentage,
      'relaxedPercentage': instance.relaxedPercentage,
      'dominantEmotion': instance.dominantEmotion,
    };
