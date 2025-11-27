import 'package:freezed_annotation/freezed_annotation.dart';

part 'balance_game.freezed.dart';
part 'balance_game.g.dart';

/// 밸런스 게임 세트
@freezed
class BalanceGameSet with _$BalanceGameSet {
  const factory BalanceGameSet({
    required String id,
    required String contentId,
    String? description,
    @Default(10) int questionCount,
    required List<BalanceGameQuestion> questions,
    DateTime? createdAt,
  }) = _BalanceGameSet;

  factory BalanceGameSet.fromJson(Map<String, dynamic> json) =>
      _$BalanceGameSetFromJson(json);
}

/// 밸런스 게임 질문
@freezed
class BalanceGameQuestion with _$BalanceGameQuestion {
  const factory BalanceGameQuestion({
    required String id,
    required int questionOrder,
    required BalanceGameChoice choiceA,
    required BalanceGameChoice choiceB,
    @Default(0) int totalVotes,
    @Default(0) int votesA,
    @Default(0) int votesB,
    DateTime? createdAt,
  }) = _BalanceGameQuestion;

  factory BalanceGameQuestion.fromJson(Map<String, dynamic> json) =>
      _$BalanceGameQuestionFromJson(json);
}

/// 밸런스 게임 선택지
@freezed
class BalanceGameChoice with _$BalanceGameChoice {
  const factory BalanceGameChoice({
    required String text,
    String? imageUrl,
    String? emoji,
  }) = _BalanceGameChoice;

  factory BalanceGameChoice.fromJson(Map<String, dynamic> json) =>
      _$BalanceGameChoiceFromJson(json);
}

/// 밸런스 게임 질문별 통계
@freezed
class BalanceQuestionStats with _$BalanceQuestionStats {
  const BalanceQuestionStats._();

  const factory BalanceQuestionStats({
    required String questionId,
    required int totalVotes,
    required int votesA,
    required int votesB,
  }) = _BalanceQuestionStats;

  factory BalanceQuestionStats.fromJson(Map<String, dynamic> json) =>
      _$BalanceQuestionStatsFromJson(json);

  double get percentageA =>
      totalVotes > 0 ? (votesA / totalVotes) * 100 : 50.0;
  double get percentageB =>
      totalVotes > 0 ? (votesB / totalVotes) * 100 : 50.0;
  String get majorityChoice => votesA >= votesB ? 'A' : 'B';
}

/// 사용자 밸런스 게임 결과
@freezed
class UserBalanceResult with _$UserBalanceResult {
  const factory UserBalanceResult({
    required String id,
    required String gameSetId,
    required Map<String, String> answers,
    @Default(0) int majorityMatchCount,
    @Default(false) bool isShared,
    DateTime? completedAt,
  }) = _UserBalanceResult;

  factory UserBalanceResult.fromJson(Map<String, dynamic> json) =>
      _$UserBalanceResultFromJson(json);
}

/// 밸런스 게임 진행 상태 (로컬)
@freezed
class BalanceGameState with _$BalanceGameState {
  const factory BalanceGameState({
    required String gameSetId,
    required int currentQuestionIndex,
    required int totalQuestions,
    required Map<String, String> answers,
    BalanceGameQuestion? currentQuestion,
    @Default(false) bool showStats,
    @Default(false) bool isCompleted,
  }) = _BalanceGameState;

  factory BalanceGameState.fromJson(Map<String, dynamic> json) =>
      _$BalanceGameStateFromJson(json);
}

/// 밸런스 게임 결과 요약
@freezed
class BalanceGameSummary with _$BalanceGameSummary {
  const BalanceGameSummary._();

  const factory BalanceGameSummary({
    required String gameSetId,
    required int totalQuestions,
    required int majorityMatchCount,
    required int minorityCount,
    required List<BalanceQuestionSummary> questionSummaries,
    String? personalityType,
    String? analysis,
  }) = _BalanceGameSummary;

  factory BalanceGameSummary.fromJson(Map<String, dynamic> json) =>
      _$BalanceGameSummaryFromJson(json);

  double get majorityPercentage =>
      totalQuestions > 0 ? (majorityMatchCount / totalQuestions) * 100 : 0;
  double get minorityPercentage =>
      totalQuestions > 0 ? (minorityCount / totalQuestions) * 100 : 0;

  String get tendencyType {
    if (majorityPercentage >= 80) return '대세 추종자';
    if (majorityPercentage >= 60) return '균형잡힌 선택자';
    if (majorityPercentage >= 40) return '독립적인 사고형';
    return '소수 의견 리더';
  }

  String get tendencyEmoji {
    if (majorityPercentage >= 80) return '🐑';
    if (majorityPercentage >= 60) return '⚖️';
    if (majorityPercentage >= 40) return '🦊';
    return '🦄';
  }
}

/// 개별 질문 요약
@freezed
class BalanceQuestionSummary with _$BalanceQuestionSummary {
  const factory BalanceQuestionSummary({
    required String questionId,
    required String userChoice,
    required String majorityChoice,
    required bool isMajority,
    required double userChoicePercentage,
    required String choiceAText,
    required String choiceBText,
    required double percentageA,
    required double percentageB,
  }) = _BalanceQuestionSummary;

  factory BalanceQuestionSummary.fromJson(Map<String, dynamic> json) =>
      _$BalanceQuestionSummaryFromJson(json);
}

/// 밸런스 게임 제출 입력
@freezed
class BalanceGameSubmission with _$BalanceGameSubmission {
  const factory BalanceGameSubmission({
    required String gameSetId,
    required Map<String, String> answers,
  }) = _BalanceGameSubmission;

  factory BalanceGameSubmission.fromJson(Map<String, dynamic> json) =>
      _$BalanceGameSubmissionFromJson(json);
}
