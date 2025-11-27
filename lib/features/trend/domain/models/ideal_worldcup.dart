import 'package:freezed_annotation/freezed_annotation.dart';

part 'ideal_worldcup.freezed.dart';
part 'ideal_worldcup.g.dart';

/// 월드컵 카테고리
enum WorldcupCategory {
  @JsonValue('celebrity')
  celebrity,
  @JsonValue('food')
  food,
  @JsonValue('travel')
  travel,
  @JsonValue('animal')
  animal,
  @JsonValue('movie')
  movie,
  @JsonValue('character')
  character,
  @JsonValue('custom')
  custom,
}

extension WorldcupCategoryExtension on WorldcupCategory {
  String get displayName {
    switch (this) {
      case WorldcupCategory.celebrity:
        return '연예인';
      case WorldcupCategory.food:
        return '음식';
      case WorldcupCategory.travel:
        return '여행지';
      case WorldcupCategory.animal:
        return '동물';
      case WorldcupCategory.movie:
        return '영화';
      case WorldcupCategory.character:
        return '캐릭터';
      case WorldcupCategory.custom:
        return '커스텀';
    }
  }

  String get emoji {
    switch (this) {
      case WorldcupCategory.celebrity:
        return '⭐';
      case WorldcupCategory.food:
        return '🍔';
      case WorldcupCategory.travel:
        return '✈️';
      case WorldcupCategory.animal:
        return '🐶';
      case WorldcupCategory.movie:
        return '🎬';
      case WorldcupCategory.character:
        return '🎭';
      case WorldcupCategory.custom:
        return '✨';
    }
  }
}

/// 이상형 월드컵 메인 모델
@freezed
class IdealWorldcup with _$IdealWorldcup {
  const factory IdealWorldcup({
    required String id,
    required String contentId,
    String? description,
    required WorldcupCategory worldcupCategory,
    @Default(16) int totalRounds,
    required List<WorldcupCandidate> candidates,
    DateTime? createdAt,
  }) = _IdealWorldcup;

  factory IdealWorldcup.fromJson(Map<String, dynamic> json) =>
      _$IdealWorldcupFromJson(json);
}

/// 월드컵 후보
@freezed
class WorldcupCandidate with _$WorldcupCandidate {
  const factory WorldcupCandidate({
    required String id,
    required String name,
    required String imageUrl,
    String? description,
    @Default(0) int winCount,
    @Default(0) int loseCount,
    @Default(0) int finalWinCount,
    DateTime? createdAt,
  }) = _WorldcupCandidate;

  factory WorldcupCandidate.fromJson(Map<String, dynamic> json) =>
      _$WorldcupCandidateFromJson(json);
}

/// 월드컵 매치 결과 (진행 중 기록)
@freezed
class WorldcupMatchResult with _$WorldcupMatchResult {
  const factory WorldcupMatchResult({
    required int round,
    required String winnerId,
    required String loserId,
  }) = _WorldcupMatchResult;

  factory WorldcupMatchResult.fromJson(Map<String, dynamic> json) =>
      _$WorldcupMatchResultFromJson(json);
}

/// 사용자 월드컵 결과
@freezed
class UserWorldcupResult with _$UserWorldcupResult {
  const factory UserWorldcupResult({
    required String id,
    required String worldcupId,
    required String winnerId,
    String? secondPlaceId,
    String? thirdPlaceId,
    String? fourthPlaceId,
    required WorldcupCandidate winner,
    WorldcupCandidate? secondPlace,
    WorldcupCandidate? thirdPlace,
    WorldcupCandidate? fourthPlace,
    required List<WorldcupMatchResult> matchHistory,
    @Default(false) bool isShared,
    DateTime? completedAt,
  }) = _UserWorldcupResult;

  factory UserWorldcupResult.fromJson(Map<String, dynamic> json) =>
      _$UserWorldcupResultFromJson(json);
}

/// 월드컵 랭킹 아이템
@freezed
class WorldcupRanking with _$WorldcupRanking {
  const factory WorldcupRanking({
    required String worldcupId,
    required String candidateId,
    required String candidateName,
    required String candidateImage,
    required int winCount,
    required int loseCount,
    required int finalWinCount,
    required double winRate,
    required int rank,
  }) = _WorldcupRanking;

  factory WorldcupRanking.fromJson(Map<String, dynamic> json) =>
      _$WorldcupRankingFromJson(json);
}

/// 월드컵 진행 상태 (로컬)
@freezed
class WorldcupGameState with _$WorldcupGameState {
  const factory WorldcupGameState({
    required String worldcupId,
    required int currentRound,
    required int matchIndex,
    required List<WorldcupCandidate> remainingCandidates,
    required List<WorldcupMatchResult> matchHistory,
    WorldcupCandidate? currentMatchLeft,
    WorldcupCandidate? currentMatchRight,
    @Default(false) bool isCompleted,
    WorldcupCandidate? winner,
    WorldcupCandidate? secondPlace,
    WorldcupCandidate? thirdPlace,
    WorldcupCandidate? fourthPlace,
  }) = _WorldcupGameState;

  factory WorldcupGameState.fromJson(Map<String, dynamic> json) =>
      _$WorldcupGameStateFromJson(json);
}

/// 월드컵 제출 입력
@freezed
class WorldcupSubmission with _$WorldcupSubmission {
  const factory WorldcupSubmission({
    required String worldcupId,
    required String winnerId,
    String? secondPlaceId,
    String? thirdPlaceId,
    String? fourthPlaceId,
    required List<WorldcupMatchResult> matchHistory,
  }) = _WorldcupSubmission;

  factory WorldcupSubmission.fromJson(Map<String, dynamic> json) =>
      _$WorldcupSubmissionFromJson(json);
}
