// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ideal_worldcup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IdealWorldcupImpl _$$IdealWorldcupImplFromJson(Map<String, dynamic> json) =>
    _$IdealWorldcupImpl(
      id: json['id'] as String,
      contentId: json['contentId'] as String,
      description: json['description'] as String?,
      worldcupCategory:
          $enumDecode(_$WorldcupCategoryEnumMap, json['worldcupCategory']),
      totalRounds: (json['totalRounds'] as num?)?.toInt() ?? 16,
      candidates: (json['candidates'] as List<dynamic>)
          .map((e) => WorldcupCandidate.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$IdealWorldcupImplToJson(_$IdealWorldcupImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contentId': instance.contentId,
      'description': instance.description,
      'worldcupCategory': _$WorldcupCategoryEnumMap[instance.worldcupCategory]!,
      'totalRounds': instance.totalRounds,
      'candidates': instance.candidates,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$WorldcupCategoryEnumMap = {
  WorldcupCategory.celebrity: 'celebrity',
  WorldcupCategory.food: 'food',
  WorldcupCategory.travel: 'travel',
  WorldcupCategory.animal: 'animal',
  WorldcupCategory.movie: 'movie',
  WorldcupCategory.character: 'character',
  WorldcupCategory.custom: 'custom',
};

_$WorldcupCandidateImpl _$$WorldcupCandidateImplFromJson(
        Map<String, dynamic> json) =>
    _$WorldcupCandidateImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String?,
      winCount: (json['winCount'] as num?)?.toInt() ?? 0,
      loseCount: (json['loseCount'] as num?)?.toInt() ?? 0,
      finalWinCount: (json['finalWinCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$WorldcupCandidateImplToJson(
        _$WorldcupCandidateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'winCount': instance.winCount,
      'loseCount': instance.loseCount,
      'finalWinCount': instance.finalWinCount,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$WorldcupMatchResultImpl _$$WorldcupMatchResultImplFromJson(
        Map<String, dynamic> json) =>
    _$WorldcupMatchResultImpl(
      round: (json['round'] as num).toInt(),
      winnerId: json['winnerId'] as String,
      loserId: json['loserId'] as String,
    );

Map<String, dynamic> _$$WorldcupMatchResultImplToJson(
        _$WorldcupMatchResultImpl instance) =>
    <String, dynamic>{
      'round': instance.round,
      'winnerId': instance.winnerId,
      'loserId': instance.loserId,
    };

_$UserWorldcupResultImpl _$$UserWorldcupResultImplFromJson(
        Map<String, dynamic> json) =>
    _$UserWorldcupResultImpl(
      id: json['id'] as String,
      worldcupId: json['worldcupId'] as String,
      winnerId: json['winnerId'] as String,
      secondPlaceId: json['secondPlaceId'] as String?,
      thirdPlaceId: json['thirdPlaceId'] as String?,
      fourthPlaceId: json['fourthPlaceId'] as String?,
      winner:
          WorldcupCandidate.fromJson(json['winner'] as Map<String, dynamic>),
      secondPlace: json['secondPlace'] == null
          ? null
          : WorldcupCandidate.fromJson(
              json['secondPlace'] as Map<String, dynamic>),
      thirdPlace: json['thirdPlace'] == null
          ? null
          : WorldcupCandidate.fromJson(
              json['thirdPlace'] as Map<String, dynamic>),
      fourthPlace: json['fourthPlace'] == null
          ? null
          : WorldcupCandidate.fromJson(
              json['fourthPlace'] as Map<String, dynamic>),
      matchHistory: (json['matchHistory'] as List<dynamic>)
          .map((e) => WorldcupMatchResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      isShared: json['isShared'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$UserWorldcupResultImplToJson(
        _$UserWorldcupResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'worldcupId': instance.worldcupId,
      'winnerId': instance.winnerId,
      'secondPlaceId': instance.secondPlaceId,
      'thirdPlaceId': instance.thirdPlaceId,
      'fourthPlaceId': instance.fourthPlaceId,
      'winner': instance.winner,
      'secondPlace': instance.secondPlace,
      'thirdPlace': instance.thirdPlace,
      'fourthPlace': instance.fourthPlace,
      'matchHistory': instance.matchHistory,
      'isShared': instance.isShared,
      'completedAt': instance.completedAt?.toIso8601String(),
    };

_$WorldcupRankingImpl _$$WorldcupRankingImplFromJson(
        Map<String, dynamic> json) =>
    _$WorldcupRankingImpl(
      worldcupId: json['worldcupId'] as String,
      candidateId: json['candidateId'] as String,
      candidateName: json['candidateName'] as String,
      candidateImage: json['candidateImage'] as String,
      winCount: (json['winCount'] as num).toInt(),
      loseCount: (json['loseCount'] as num).toInt(),
      finalWinCount: (json['finalWinCount'] as num).toInt(),
      winRate: (json['winRate'] as num).toDouble(),
      rank: (json['rank'] as num).toInt(),
    );

Map<String, dynamic> _$$WorldcupRankingImplToJson(
        _$WorldcupRankingImpl instance) =>
    <String, dynamic>{
      'worldcupId': instance.worldcupId,
      'candidateId': instance.candidateId,
      'candidateName': instance.candidateName,
      'candidateImage': instance.candidateImage,
      'winCount': instance.winCount,
      'loseCount': instance.loseCount,
      'finalWinCount': instance.finalWinCount,
      'winRate': instance.winRate,
      'rank': instance.rank,
    };

_$WorldcupGameStateImpl _$$WorldcupGameStateImplFromJson(
        Map<String, dynamic> json) =>
    _$WorldcupGameStateImpl(
      worldcupId: json['worldcupId'] as String,
      currentRound: (json['currentRound'] as num).toInt(),
      matchIndex: (json['matchIndex'] as num).toInt(),
      remainingCandidates: (json['remainingCandidates'] as List<dynamic>)
          .map((e) => WorldcupCandidate.fromJson(e as Map<String, dynamic>))
          .toList(),
      matchHistory: (json['matchHistory'] as List<dynamic>)
          .map((e) => WorldcupMatchResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentMatchLeft: json['currentMatchLeft'] == null
          ? null
          : WorldcupCandidate.fromJson(
              json['currentMatchLeft'] as Map<String, dynamic>),
      currentMatchRight: json['currentMatchRight'] == null
          ? null
          : WorldcupCandidate.fromJson(
              json['currentMatchRight'] as Map<String, dynamic>),
      isCompleted: json['isCompleted'] as bool? ?? false,
      winner: json['winner'] == null
          ? null
          : WorldcupCandidate.fromJson(json['winner'] as Map<String, dynamic>),
      secondPlace: json['secondPlace'] == null
          ? null
          : WorldcupCandidate.fromJson(
              json['secondPlace'] as Map<String, dynamic>),
      thirdPlace: json['thirdPlace'] == null
          ? null
          : WorldcupCandidate.fromJson(
              json['thirdPlace'] as Map<String, dynamic>),
      fourthPlace: json['fourthPlace'] == null
          ? null
          : WorldcupCandidate.fromJson(
              json['fourthPlace'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$WorldcupGameStateImplToJson(
        _$WorldcupGameStateImpl instance) =>
    <String, dynamic>{
      'worldcupId': instance.worldcupId,
      'currentRound': instance.currentRound,
      'matchIndex': instance.matchIndex,
      'remainingCandidates': instance.remainingCandidates,
      'matchHistory': instance.matchHistory,
      'currentMatchLeft': instance.currentMatchLeft,
      'currentMatchRight': instance.currentMatchRight,
      'isCompleted': instance.isCompleted,
      'winner': instance.winner,
      'secondPlace': instance.secondPlace,
      'thirdPlace': instance.thirdPlace,
      'fourthPlace': instance.fourthPlace,
    };

_$WorldcupSubmissionImpl _$$WorldcupSubmissionImplFromJson(
        Map<String, dynamic> json) =>
    _$WorldcupSubmissionImpl(
      worldcupId: json['worldcupId'] as String,
      winnerId: json['winnerId'] as String,
      secondPlaceId: json['secondPlaceId'] as String?,
      thirdPlaceId: json['thirdPlaceId'] as String?,
      fourthPlaceId: json['fourthPlaceId'] as String?,
      matchHistory: (json['matchHistory'] as List<dynamic>)
          .map((e) => WorldcupMatchResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$WorldcupSubmissionImplToJson(
        _$WorldcupSubmissionImpl instance) =>
    <String, dynamic>{
      'worldcupId': instance.worldcupId,
      'winnerId': instance.winnerId,
      'secondPlaceId': instance.secondPlaceId,
      'thirdPlaceId': instance.thirdPlaceId,
      'fourthPlaceId': instance.fourthPlaceId,
      'matchHistory': instance.matchHistory,
    };
