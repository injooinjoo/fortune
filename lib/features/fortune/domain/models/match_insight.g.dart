// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_insight.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchInsightImpl _$$MatchInsightImplFromJson(Map<String, dynamic> json) =>
    _$MatchInsightImpl(
      id: json['id'] as String,
      fortuneType: json['fortuneType'] as String? ?? 'match-insight',
      score: (json['score'] as num).toInt(),
      content: json['content'] as String,
      summary: json['summary'] as String,
      advice: json['advice'] as String,
      prediction:
          MatchPrediction.fromJson(json['prediction'] as Map<String, dynamic>),
      favoriteTeamAnalysis: TeamAnalysis.fromJson(
          json['favoriteTeamAnalysis'] as Map<String, dynamic>),
      opponentAnalysis: TeamAnalysis.fromJson(
          json['opponentAnalysis'] as Map<String, dynamic>),
      fortuneElements: FortuneElements.fromJson(
          json['fortuneElements'] as Map<String, dynamic>),
      cautionMessage: json['cautionMessage'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      percentile: (json['percentile'] as num?)?.toInt(),
      sport: $enumDecode(_$SportTypeEnumMap, json['sport']),
      homeTeam: json['homeTeam'] as String,
      awayTeam: json['awayTeam'] as String,
      gameDate: DateTime.parse(json['gameDate'] as String),
      favoriteTeam: json['favoriteTeam'] as String?,
    );

Map<String, dynamic> _$$MatchInsightImplToJson(_$MatchInsightImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fortuneType': instance.fortuneType,
      'score': instance.score,
      'content': instance.content,
      'summary': instance.summary,
      'advice': instance.advice,
      'prediction': instance.prediction,
      'favoriteTeamAnalysis': instance.favoriteTeamAnalysis,
      'opponentAnalysis': instance.opponentAnalysis,
      'fortuneElements': instance.fortuneElements,
      'cautionMessage': instance.cautionMessage,
      'timestamp': instance.timestamp.toIso8601String(),
      'percentile': instance.percentile,
      'sport': _$SportTypeEnumMap[instance.sport]!,
      'homeTeam': instance.homeTeam,
      'awayTeam': instance.awayTeam,
      'gameDate': instance.gameDate.toIso8601String(),
      'favoriteTeam': instance.favoriteTeam,
    };

const _$SportTypeEnumMap = {
  SportType.baseball: 'baseball',
  SportType.soccer: 'soccer',
  SportType.basketball: 'basketball',
  SportType.volleyball: 'volleyball',
  SportType.esports: 'esports',
  SportType.americanFootball: 'american_football',
  SportType.fighting: 'fighting',
};

_$MatchPredictionImpl _$$MatchPredictionImplFromJson(
        Map<String, dynamic> json) =>
    _$MatchPredictionImpl(
      winProbability: (json['winProbability'] as num).toInt(),
      confidence: json['confidence'] as String,
      keyFactors: (json['keyFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      predictedScore: json['predictedScore'] as String?,
      mvpCandidate: json['mvpCandidate'] as String?,
    );

Map<String, dynamic> _$$MatchPredictionImplToJson(
        _$MatchPredictionImpl instance) =>
    <String, dynamic>{
      'winProbability': instance.winProbability,
      'confidence': instance.confidence,
      'keyFactors': instance.keyFactors,
      'predictedScore': instance.predictedScore,
      'mvpCandidate': instance.mvpCandidate,
    };

_$TeamAnalysisImpl _$$TeamAnalysisImplFromJson(Map<String, dynamic> json) =>
    _$TeamAnalysisImpl(
      name: json['name'] as String,
      recentForm: json['recentForm'] as String,
      strengths:
          (json['strengths'] as List<dynamic>).map((e) => e as String).toList(),
      concerns:
          (json['concerns'] as List<dynamic>).map((e) => e as String).toList(),
      keyPlayer: json['keyPlayer'] as String?,
      formEmoji: json['formEmoji'] as String?,
    );

Map<String, dynamic> _$$TeamAnalysisImplToJson(_$TeamAnalysisImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'recentForm': instance.recentForm,
      'strengths': instance.strengths,
      'concerns': instance.concerns,
      'keyPlayer': instance.keyPlayer,
      'formEmoji': instance.formEmoji,
    };

_$FortuneElementsImpl _$$FortuneElementsImplFromJson(
        Map<String, dynamic> json) =>
    _$FortuneElementsImpl(
      luckyColor: json['luckyColor'] as String,
      luckyNumber: (json['luckyNumber'] as num).toInt(),
      luckyTime: json['luckyTime'] as String,
      luckyItem: json['luckyItem'] as String,
      luckySection: json['luckySection'] as String?,
      luckyAction: json['luckyAction'] as String?,
    );

Map<String, dynamic> _$$FortuneElementsImplToJson(
        _$FortuneElementsImpl instance) =>
    <String, dynamic>{
      'luckyColor': instance.luckyColor,
      'luckyNumber': instance.luckyNumber,
      'luckyTime': instance.luckyTime,
      'luckyItem': instance.luckyItem,
      'luckySection': instance.luckySection,
      'luckyAction': instance.luckyAction,
    };
