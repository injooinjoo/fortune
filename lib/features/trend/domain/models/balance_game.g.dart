// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BalanceGameSetImpl _$$BalanceGameSetImplFromJson(Map<String, dynamic> json) =>
    _$BalanceGameSetImpl(
      id: json['id'] as String,
      contentId: json['contentId'] as String,
      description: json['description'] as String?,
      questionCount: (json['questionCount'] as num?)?.toInt() ?? 10,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => BalanceGameQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$BalanceGameSetImplToJson(
        _$BalanceGameSetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contentId': instance.contentId,
      'description': instance.description,
      'questionCount': instance.questionCount,
      'questions': instance.questions,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$BalanceGameQuestionImpl _$$BalanceGameQuestionImplFromJson(
        Map<String, dynamic> json) =>
    _$BalanceGameQuestionImpl(
      id: json['id'] as String,
      questionOrder: (json['questionOrder'] as num).toInt(),
      choiceA:
          BalanceGameChoice.fromJson(json['choiceA'] as Map<String, dynamic>),
      choiceB:
          BalanceGameChoice.fromJson(json['choiceB'] as Map<String, dynamic>),
      totalVotes: (json['totalVotes'] as num?)?.toInt() ?? 0,
      votesA: (json['votesA'] as num?)?.toInt() ?? 0,
      votesB: (json['votesB'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$BalanceGameQuestionImplToJson(
        _$BalanceGameQuestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'questionOrder': instance.questionOrder,
      'choiceA': instance.choiceA,
      'choiceB': instance.choiceB,
      'totalVotes': instance.totalVotes,
      'votesA': instance.votesA,
      'votesB': instance.votesB,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$BalanceGameChoiceImpl _$$BalanceGameChoiceImplFromJson(
        Map<String, dynamic> json) =>
    _$BalanceGameChoiceImpl(
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String?,
      emoji: json['emoji'] as String?,
    );

Map<String, dynamic> _$$BalanceGameChoiceImplToJson(
        _$BalanceGameChoiceImpl instance) =>
    <String, dynamic>{
      'text': instance.text,
      'imageUrl': instance.imageUrl,
      'emoji': instance.emoji,
    };

_$BalanceQuestionStatsImpl _$$BalanceQuestionStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$BalanceQuestionStatsImpl(
      questionId: json['questionId'] as String,
      totalVotes: (json['totalVotes'] as num).toInt(),
      votesA: (json['votesA'] as num).toInt(),
      votesB: (json['votesB'] as num).toInt(),
    );

Map<String, dynamic> _$$BalanceQuestionStatsImplToJson(
        _$BalanceQuestionStatsImpl instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'totalVotes': instance.totalVotes,
      'votesA': instance.votesA,
      'votesB': instance.votesB,
    };

_$UserBalanceResultImpl _$$UserBalanceResultImplFromJson(
        Map<String, dynamic> json) =>
    _$UserBalanceResultImpl(
      id: json['id'] as String,
      gameSetId: json['gameSetId'] as String,
      answers: Map<String, String>.from(json['answers'] as Map),
      majorityMatchCount: (json['majorityMatchCount'] as num?)?.toInt() ?? 0,
      isShared: json['isShared'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$UserBalanceResultImplToJson(
        _$UserBalanceResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gameSetId': instance.gameSetId,
      'answers': instance.answers,
      'majorityMatchCount': instance.majorityMatchCount,
      'isShared': instance.isShared,
      'completedAt': instance.completedAt?.toIso8601String(),
    };

_$BalanceGameStateImpl _$$BalanceGameStateImplFromJson(
        Map<String, dynamic> json) =>
    _$BalanceGameStateImpl(
      gameSetId: json['gameSetId'] as String,
      currentQuestionIndex: (json['currentQuestionIndex'] as num).toInt(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      answers: Map<String, String>.from(json['answers'] as Map),
      currentQuestion: json['currentQuestion'] == null
          ? null
          : BalanceGameQuestion.fromJson(
              json['currentQuestion'] as Map<String, dynamic>),
      showStats: json['showStats'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$BalanceGameStateImplToJson(
        _$BalanceGameStateImpl instance) =>
    <String, dynamic>{
      'gameSetId': instance.gameSetId,
      'currentQuestionIndex': instance.currentQuestionIndex,
      'totalQuestions': instance.totalQuestions,
      'answers': instance.answers,
      'currentQuestion': instance.currentQuestion,
      'showStats': instance.showStats,
      'isCompleted': instance.isCompleted,
    };

_$BalanceGameSummaryImpl _$$BalanceGameSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$BalanceGameSummaryImpl(
      gameSetId: json['gameSetId'] as String,
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      majorityMatchCount: (json['majorityMatchCount'] as num).toInt(),
      minorityCount: (json['minorityCount'] as num).toInt(),
      questionSummaries: (json['questionSummaries'] as List<dynamic>)
          .map(
              (e) => BalanceQuestionSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      personalityType: json['personalityType'] as String?,
      analysis: json['analysis'] as String?,
    );

Map<String, dynamic> _$$BalanceGameSummaryImplToJson(
        _$BalanceGameSummaryImpl instance) =>
    <String, dynamic>{
      'gameSetId': instance.gameSetId,
      'totalQuestions': instance.totalQuestions,
      'majorityMatchCount': instance.majorityMatchCount,
      'minorityCount': instance.minorityCount,
      'questionSummaries': instance.questionSummaries,
      'personalityType': instance.personalityType,
      'analysis': instance.analysis,
    };

_$BalanceQuestionSummaryImpl _$$BalanceQuestionSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$BalanceQuestionSummaryImpl(
      questionId: json['questionId'] as String,
      userChoice: json['userChoice'] as String,
      majorityChoice: json['majorityChoice'] as String,
      isMajority: json['isMajority'] as bool,
      userChoicePercentage: (json['userChoicePercentage'] as num).toDouble(),
      choiceAText: json['choiceAText'] as String,
      choiceBText: json['choiceBText'] as String,
      percentageA: (json['percentageA'] as num).toDouble(),
      percentageB: (json['percentageB'] as num).toDouble(),
    );

Map<String, dynamic> _$$BalanceQuestionSummaryImplToJson(
        _$BalanceQuestionSummaryImpl instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'userChoice': instance.userChoice,
      'majorityChoice': instance.majorityChoice,
      'isMajority': instance.isMajority,
      'userChoicePercentage': instance.userChoicePercentage,
      'choiceAText': instance.choiceAText,
      'choiceBText': instance.choiceBText,
      'percentageA': instance.percentageA,
      'percentageB': instance.percentageB,
    };

_$BalanceGameSubmissionImpl _$$BalanceGameSubmissionImplFromJson(
        Map<String, dynamic> json) =>
    _$BalanceGameSubmissionImpl(
      gameSetId: json['gameSetId'] as String,
      answers: Map<String, String>.from(json['answers'] as Map),
    );

Map<String, dynamic> _$$BalanceGameSubmissionImplToJson(
        _$BalanceGameSubmissionImpl instance) =>
    <String, dynamic>{
      'gameSetId': instance.gameSetId,
      'answers': instance.answers,
    };
