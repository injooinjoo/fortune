// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'face_reading_history_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FaceReadingHistoryEntryImpl _$$FaceReadingHistoryEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$FaceReadingHistoryEntryImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      gender: json['gender'] as String,
      ageGroup: json['ageGroup'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      resultId: json['resultId'] as String,
      faceCondition:
          FaceCondition.fromJson(json['faceCondition'] as Map<String, dynamic>),
      emotionAnalysis: EmotionAnalysis.fromJson(
          json['emotionAnalysis'] as Map<String, dynamic>),
      priorityInsights: (json['priorityInsights'] as List<dynamic>)
          .map((e) => PriorityInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallFortuneScore: (json['overallFortuneScore'] as num).toInt(),
      categoryScores: CategoryScores.fromJson(
          json['categoryScores'] as Map<String, dynamic>),
      userNote: json['userNote'] as String?,
      missionCompleted: json['missionCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$FaceReadingHistoryEntryImplToJson(
        _$FaceReadingHistoryEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'gender': instance.gender,
      'ageGroup': instance.ageGroup,
      'thumbnailUrl': instance.thumbnailUrl,
      'resultId': instance.resultId,
      'faceCondition': instance.faceCondition,
      'emotionAnalysis': instance.emotionAnalysis,
      'priorityInsights': instance.priorityInsights,
      'overallFortuneScore': instance.overallFortuneScore,
      'categoryScores': instance.categoryScores,
      'userNote': instance.userNote,
      'missionCompleted': instance.missionCompleted,
    };

_$PriorityInsightImpl _$$PriorityInsightImplFromJson(
        Map<String, dynamic> json) =>
    _$PriorityInsightImpl(
      category: json['category'] as String,
      categoryLabel: json['categoryLabel'] as String,
      message: json['message'] as String,
      score: (json['score'] as num).toInt(),
      emoji: json['emoji'] as String? ?? '✨',
      relatedFeature: json['relatedFeature'] as String?,
    );

Map<String, dynamic> _$$PriorityInsightImplToJson(
        _$PriorityInsightImpl instance) =>
    <String, dynamic>{
      'category': instance.category,
      'categoryLabel': instance.categoryLabel,
      'message': instance.message,
      'score': instance.score,
      'emoji': instance.emoji,
      'relatedFeature': instance.relatedFeature,
    };

_$CategoryScoresImpl _$$CategoryScoresImplFromJson(Map<String, dynamic> json) =>
    _$CategoryScoresImpl(
      loveScore: (json['loveScore'] as num).toInt(),
      marriageScore: (json['marriageScore'] as num).toInt(),
      relationshipScore: (json['relationshipScore'] as num).toInt(),
      careerScore: (json['careerScore'] as num).toInt(),
      wealthScore: (json['wealthScore'] as num).toInt(),
      healthScore: (json['healthScore'] as num).toInt(),
      impressionScore: (json['impressionScore'] as num).toInt(),
    );

Map<String, dynamic> _$$CategoryScoresImplToJson(
        _$CategoryScoresImpl instance) =>
    <String, dynamic>{
      'loveScore': instance.loveScore,
      'marriageScore': instance.marriageScore,
      'relationshipScore': instance.relationshipScore,
      'careerScore': instance.careerScore,
      'wealthScore': instance.wealthScore,
      'healthScore': instance.healthScore,
      'impressionScore': instance.impressionScore,
    };

_$HistoryComparisonImpl _$$HistoryComparisonImplFromJson(
        Map<String, dynamic> json) =>
    _$HistoryComparisonImpl(
      date1: DateTime.parse(json['date1'] as String),
      date2: DateTime.parse(json['date2'] as String),
      conditionChange: ConditionChange.fromJson(
          json['conditionChange'] as Map<String, dynamic>),
      emotionChange:
          EmotionChange.fromJson(json['emotionChange'] as Map<String, dynamic>),
      scoreChanges:
          ScoreChanges.fromJson(json['scoreChanges'] as Map<String, dynamic>),
      comparisonInsight: json['comparisonInsight'] as String,
    );

Map<String, dynamic> _$$HistoryComparisonImplToJson(
        _$HistoryComparisonImpl instance) =>
    <String, dynamic>{
      'date1': instance.date1.toIso8601String(),
      'date2': instance.date2.toIso8601String(),
      'conditionChange': instance.conditionChange,
      'emotionChange': instance.emotionChange,
      'scoreChanges': instance.scoreChanges,
      'comparisonInsight': instance.comparisonInsight,
    };

_$ConditionChangeImpl _$$ConditionChangeImplFromJson(
        Map<String, dynamic> json) =>
    _$ConditionChangeImpl(
      complexionChange: (json['complexionChange'] as num).toInt(),
      puffinessChange: (json['puffinessChange'] as num).toInt(),
      fatigueChange: (json['fatigueChange'] as num).toInt(),
      overallChange: (json['overallChange'] as num).toInt(),
      summary: json['summary'] as String,
    );

Map<String, dynamic> _$$ConditionChangeImplToJson(
        _$ConditionChangeImpl instance) =>
    <String, dynamic>{
      'complexionChange': instance.complexionChange,
      'puffinessChange': instance.puffinessChange,
      'fatigueChange': instance.fatigueChange,
      'overallChange': instance.overallChange,
      'summary': instance.summary,
    };

_$EmotionChangeImpl _$$EmotionChangeImplFromJson(Map<String, dynamic> json) =>
    _$EmotionChangeImpl(
      smileChange: (json['smileChange'] as num).toDouble(),
      tensionChange: (json['tensionChange'] as num).toDouble(),
      relaxedChange: (json['relaxedChange'] as num).toDouble(),
      summary: json['summary'] as String,
    );

Map<String, dynamic> _$$EmotionChangeImplToJson(_$EmotionChangeImpl instance) =>
    <String, dynamic>{
      'smileChange': instance.smileChange,
      'tensionChange': instance.tensionChange,
      'relaxedChange': instance.relaxedChange,
      'summary': instance.summary,
    };

_$ScoreChangesImpl _$$ScoreChangesImplFromJson(Map<String, dynamic> json) =>
    _$ScoreChangesImpl(
      loveChange: (json['loveChange'] as num).toInt(),
      marriageChange: (json['marriageChange'] as num).toInt(),
      careerChange: (json['careerChange'] as num).toInt(),
      wealthChange: (json['wealthChange'] as num).toInt(),
      healthChange: (json['healthChange'] as num).toInt(),
      relationshipChange: (json['relationshipChange'] as num).toInt(),
      summary: json['summary'] as String,
    );

Map<String, dynamic> _$$ScoreChangesImplToJson(_$ScoreChangesImpl instance) =>
    <String, dynamic>{
      'loveChange': instance.loveChange,
      'marriageChange': instance.marriageChange,
      'careerChange': instance.careerChange,
      'wealthChange': instance.wealthChange,
      'healthChange': instance.healthChange,
      'relationshipChange': instance.relationshipChange,
      'summary': instance.summary,
    };

_$HistoryStatsImpl _$$HistoryStatsImplFromJson(Map<String, dynamic> json) =>
    _$HistoryStatsImpl(
      totalAnalysisCount: (json['totalAnalysisCount'] as num).toInt(),
      streakDays: (json['streakDays'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      thisMonthCount: (json['thisMonthCount'] as num).toInt(),
      averageConditionScore: (json['averageConditionScore'] as num).toDouble(),
      averageSmilePercentage:
          (json['averageSmilePercentage'] as num).toDouble(),
      bestConditionDate: json['bestConditionDate'] == null
          ? null
          : DateTime.parse(json['bestConditionDate'] as String),
      missionCompletionRate: (json['missionCompletionRate'] as num).toDouble(),
    );

Map<String, dynamic> _$$HistoryStatsImplToJson(_$HistoryStatsImpl instance) =>
    <String, dynamic>{
      'totalAnalysisCount': instance.totalAnalysisCount,
      'streakDays': instance.streakDays,
      'longestStreak': instance.longestStreak,
      'thisMonthCount': instance.thisMonthCount,
      'averageConditionScore': instance.averageConditionScore,
      'averageSmilePercentage': instance.averageSmilePercentage,
      'bestConditionDate': instance.bestConditionDate?.toIso8601String(),
      'missionCompletionRate': instance.missionCompletionRate,
    };
