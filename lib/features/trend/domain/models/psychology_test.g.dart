// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'psychology_test.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrendPsychologyTestImpl _$$TrendPsychologyTestImplFromJson(
        Map<String, dynamic> json) =>
    _$TrendPsychologyTestImpl(
      id: json['id'] as String,
      contentId: json['contentId'] as String,
      resultType:
          $enumDecode(_$PsychologyResultTypeEnumMap, json['resultType']),
      description: json['description'] as String?,
      questionCount: (json['questionCount'] as num?)?.toInt() ?? 0,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 5,
      useLlmAnalysis: json['useLlmAnalysis'] as bool? ?? false,
      questions: (json['questions'] as List<dynamic>)
          .map((e) =>
              TrendPsychologyQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      possibleResults: (json['possibleResults'] as List<dynamic>)
          .map((e) => TrendPsychologyResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TrendPsychologyTestImplToJson(
        _$TrendPsychologyTestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contentId': instance.contentId,
      'resultType': _$PsychologyResultTypeEnumMap[instance.resultType]!,
      'description': instance.description,
      'questionCount': instance.questionCount,
      'estimatedMinutes': instance.estimatedMinutes,
      'useLlmAnalysis': instance.useLlmAnalysis,
      'questions': instance.questions,
      'possibleResults': instance.possibleResults,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$PsychologyResultTypeEnumMap = {
  PsychologyResultType.character: 'character',
  PsychologyResultType.animal: 'animal',
  PsychologyResultType.food: 'food',
  PsychologyResultType.color: 'color',
  PsychologyResultType.celebrity: 'celebrity',
  PsychologyResultType.mbti: 'mbti',
  PsychologyResultType.custom: 'custom',
};

_$TrendPsychologyQuestionImpl _$$TrendPsychologyQuestionImplFromJson(
        Map<String, dynamic> json) =>
    _$TrendPsychologyQuestionImpl(
      id: json['id'] as String,
      questionOrder: (json['questionOrder'] as num).toInt(),
      questionText: json['questionText'] as String,
      imageUrl: json['imageUrl'] as String?,
      options: (json['options'] as List<dynamic>)
          .map((e) => TrendPsychologyOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$TrendPsychologyQuestionImplToJson(
        _$TrendPsychologyQuestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'questionOrder': instance.questionOrder,
      'questionText': instance.questionText,
      'imageUrl': instance.imageUrl,
      'options': instance.options,
    };

_$TrendPsychologyOptionImpl _$$TrendPsychologyOptionImplFromJson(
        Map<String, dynamic> json) =>
    _$TrendPsychologyOptionImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      imageUrl: json['imageUrl'] as String?,
      scoreMap: (json['scoreMap'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      optionOrder: (json['optionOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TrendPsychologyOptionImplToJson(
        _$TrendPsychologyOptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'imageUrl': instance.imageUrl,
      'scoreMap': instance.scoreMap,
      'optionOrder': instance.optionOrder,
    };

_$TrendPsychologyResultImpl _$$TrendPsychologyResultImplFromJson(
        Map<String, dynamic> json) =>
    _$TrendPsychologyResultImpl(
      id: json['id'] as String,
      resultCode: json['resultCode'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      characteristics: (json['characteristics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      compatibleWith: json['compatibleWith'] as String?,
      incompatibleWith: json['incompatibleWith'] as String?,
      additionalInfo:
          json['additionalInfo'] as Map<String, dynamic>? ?? const {},
      selectionCount: (json['selectionCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TrendPsychologyResultImplToJson(
        _$TrendPsychologyResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resultCode': instance.resultCode,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'characteristics': instance.characteristics,
      'compatibleWith': instance.compatibleWith,
      'incompatibleWith': instance.incompatibleWith,
      'additionalInfo': instance.additionalInfo,
      'selectionCount': instance.selectionCount,
    };

_$UserPsychologyTestResultImpl _$$UserPsychologyTestResultImplFromJson(
        Map<String, dynamic> json) =>
    _$UserPsychologyTestResultImpl(
      id: json['id'] as String,
      testId: json['testId'] as String,
      resultId: json['resultId'] as String,
      result: TrendPsychologyResult.fromJson(
          json['result'] as Map<String, dynamic>),
      answers: Map<String, String>.from(json['answers'] as Map),
      scoreBreakdown: Map<String, int>.from(json['scoreBreakdown'] as Map),
      llmAnalysis: json['llmAnalysis'] as String?,
      isShared: json['isShared'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$UserPsychologyTestResultImplToJson(
        _$UserPsychologyTestResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'testId': instance.testId,
      'resultId': instance.resultId,
      'result': instance.result,
      'answers': instance.answers,
      'scoreBreakdown': instance.scoreBreakdown,
      'llmAnalysis': instance.llmAnalysis,
      'isShared': instance.isShared,
      'completedAt': instance.completedAt?.toIso8601String(),
    };

_$PsychologyTestSubmissionImpl _$$PsychologyTestSubmissionImplFromJson(
        Map<String, dynamic> json) =>
    _$PsychologyTestSubmissionImpl(
      testId: json['testId'] as String,
      answers: Map<String, String>.from(json['answers'] as Map),
    );

Map<String, dynamic> _$$PsychologyTestSubmissionImplToJson(
        _$PsychologyTestSubmissionImpl instance) =>
    <String, dynamic>{
      'testId': instance.testId,
      'answers': instance.answers,
    };

_$PsychologyTestStatsImpl _$$PsychologyTestStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$PsychologyTestStatsImpl(
      testId: json['testId'] as String,
      totalParticipants: (json['totalParticipants'] as num).toInt(),
      resultDistribution: (json['resultDistribution'] as List<dynamic>)
          .map((e) => ResultDistribution.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PsychologyTestStatsImplToJson(
        _$PsychologyTestStatsImpl instance) =>
    <String, dynamic>{
      'testId': instance.testId,
      'totalParticipants': instance.totalParticipants,
      'resultDistribution': instance.resultDistribution,
    };

_$ResultDistributionImpl _$$ResultDistributionImplFromJson(
        Map<String, dynamic> json) =>
    _$ResultDistributionImpl(
      resultId: json['resultId'] as String,
      resultTitle: json['resultTitle'] as String,
      count: (json['count'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$$ResultDistributionImplToJson(
        _$ResultDistributionImpl instance) =>
    <String, dynamic>{
      'resultId': instance.resultId,
      'resultTitle': instance.resultTitle,
      'count': instance.count,
      'percentage': instance.percentage,
    };
