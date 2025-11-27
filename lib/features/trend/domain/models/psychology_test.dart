import 'package:freezed_annotation/freezed_annotation.dart';

part 'psychology_test.freezed.dart';
part 'psychology_test.g.dart';

/// 심리테스트 결과 유형
enum PsychologyResultType {
  @JsonValue('character')
  character,
  @JsonValue('animal')
  animal,
  @JsonValue('food')
  food,
  @JsonValue('color')
  color,
  @JsonValue('celebrity')
  celebrity,
  @JsonValue('mbti')
  mbti,
  @JsonValue('custom')
  custom,
}

extension PsychologyResultTypeExtension on PsychologyResultType {
  String get displayName {
    switch (this) {
      case PsychologyResultType.character:
        return '캐릭터';
      case PsychologyResultType.animal:
        return '동물';
      case PsychologyResultType.food:
        return '음식';
      case PsychologyResultType.color:
        return '색상';
      case PsychologyResultType.celebrity:
        return '연예인';
      case PsychologyResultType.mbti:
        return 'MBTI';
      case PsychologyResultType.custom:
        return '커스텀';
    }
  }

  String get emoji {
    switch (this) {
      case PsychologyResultType.character:
        return '🎭';
      case PsychologyResultType.animal:
        return '🦊';
      case PsychologyResultType.food:
        return '🍕';
      case PsychologyResultType.color:
        return '🎨';
      case PsychologyResultType.celebrity:
        return '⭐';
      case PsychologyResultType.mbti:
        return '🧬';
      case PsychologyResultType.custom:
        return '✨';
    }
  }
}

/// 심리테스트 메인 모델
@freezed
class TrendPsychologyTest with _$TrendPsychologyTest {
  const factory TrendPsychologyTest({
    required String id,
    required String contentId,
    required PsychologyResultType resultType,
    String? description,
    @Default(0) int questionCount,
    @Default(5) int estimatedMinutes,
    @Default(false) bool useLlmAnalysis,
    required List<TrendPsychologyQuestion> questions,
    required List<TrendPsychologyResult> possibleResults,
    DateTime? createdAt,
  }) = _TrendPsychologyTest;

  factory TrendPsychologyTest.fromJson(Map<String, dynamic> json) =>
      _$TrendPsychologyTestFromJson(json);
}

/// 심리테스트 질문
@freezed
class TrendPsychologyQuestion with _$TrendPsychologyQuestion {
  const factory TrendPsychologyQuestion({
    required String id,
    required int questionOrder,
    required String questionText,
    String? imageUrl,
    required List<TrendPsychologyOption> options,
  }) = _TrendPsychologyQuestion;

  factory TrendPsychologyQuestion.fromJson(Map<String, dynamic> json) =>
      _$TrendPsychologyQuestionFromJson(json);
}

/// 심리테스트 선택지
@freezed
class TrendPsychologyOption with _$TrendPsychologyOption {
  const factory TrendPsychologyOption({
    required String id,
    required String label,
    String? imageUrl,
    @Default({}) Map<String, int> scoreMap,
    @Default(0) int optionOrder,
  }) = _TrendPsychologyOption;

  factory TrendPsychologyOption.fromJson(Map<String, dynamic> json) =>
      _$TrendPsychologyOptionFromJson(json);
}

/// 심리테스트 결과 정의
@freezed
class TrendPsychologyResult with _$TrendPsychologyResult {
  const factory TrendPsychologyResult({
    required String id,
    required String resultCode,
    required String title,
    required String description,
    String? imageUrl,
    @Default([]) List<String> characteristics,
    String? compatibleWith,
    String? incompatibleWith,
    @Default({}) Map<String, dynamic> additionalInfo,
    @Default(0) int selectionCount,
  }) = _TrendPsychologyResult;

  factory TrendPsychologyResult.fromJson(Map<String, dynamic> json) =>
      _$TrendPsychologyResultFromJson(json);
}

/// 사용자 심리테스트 참여 결과
@freezed
class UserPsychologyTestResult with _$UserPsychologyTestResult {
  const factory UserPsychologyTestResult({
    required String id,
    required String testId,
    required String resultId,
    required TrendPsychologyResult result,
    required Map<String, String> answers,
    required Map<String, int> scoreBreakdown,
    String? llmAnalysis,
    @Default(false) bool isShared,
    DateTime? completedAt,
  }) = _UserPsychologyTestResult;

  factory UserPsychologyTestResult.fromJson(Map<String, dynamic> json) =>
      _$UserPsychologyTestResultFromJson(json);
}

/// 심리테스트 제출 입력
@freezed
class PsychologyTestSubmission with _$PsychologyTestSubmission {
  const factory PsychologyTestSubmission({
    required String testId,
    required Map<String, String> answers,
  }) = _PsychologyTestSubmission;

  factory PsychologyTestSubmission.fromJson(Map<String, dynamic> json) =>
      _$PsychologyTestSubmissionFromJson(json);
}

/// 심리테스트 결과 통계
@freezed
class PsychologyTestStats with _$PsychologyTestStats {
  const factory PsychologyTestStats({
    required String testId,
    required int totalParticipants,
    required List<ResultDistribution> resultDistribution,
  }) = _PsychologyTestStats;

  factory PsychologyTestStats.fromJson(Map<String, dynamic> json) =>
      _$PsychologyTestStatsFromJson(json);
}

/// 결과 분포
@freezed
class ResultDistribution with _$ResultDistribution {
  const factory ResultDistribution({
    required String resultId,
    required String resultTitle,
    required int count,
    required double percentage,
  }) = _ResultDistribution;

  factory ResultDistribution.fromJson(Map<String, dynamic> json) =>
      _$ResultDistributionFromJson(json);
}
