// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sports_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SportsTeamImpl _$$SportsTeamImplFromJson(Map<String, dynamic> json) =>
    _$SportsTeamImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      sport: $enumDecode(_$SportTypeEnumMap, json['sport']),
      league: json['league'] as String,
      logoUrl: json['logoUrl'] as String?,
      primaryColor: json['primaryColor'] as String?,
      city: json['city'] as String?,
    );

Map<String, dynamic> _$$SportsTeamImplToJson(_$SportsTeamImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'shortName': instance.shortName,
      'sport': _$SportTypeEnumMap[instance.sport]!,
      'league': instance.league,
      'logoUrl': instance.logoUrl,
      'primaryColor': instance.primaryColor,
      'city': instance.city,
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

_$SportsGameImpl _$$SportsGameImplFromJson(Map<String, dynamic> json) =>
    _$SportsGameImpl(
      id: json['id'] as String,
      sport: $enumDecode(_$SportTypeEnumMap, json['sport']),
      homeTeam: json['homeTeam'] as String,
      awayTeam: json['awayTeam'] as String,
      gameTime: DateTime.parse(json['gameTime'] as String),
      venue: json['venue'] as String,
      status: $enumDecodeNullable(_$GameStatusEnumMap, json['status']) ??
          GameStatus.scheduled,
      league: json['league'] as String?,
      season: json['season'] as String?,
      homeTeamLogo: json['homeTeamLogo'] as String?,
      awayTeamLogo: json['awayTeamLogo'] as String?,
      homeScore: (json['homeScore'] as num?)?.toInt(),
      awayScore: (json['awayScore'] as num?)?.toInt(),
      stats: json['stats'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$SportsGameImplToJson(_$SportsGameImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sport': _$SportTypeEnumMap[instance.sport]!,
      'homeTeam': instance.homeTeam,
      'awayTeam': instance.awayTeam,
      'gameTime': instance.gameTime.toIso8601String(),
      'venue': instance.venue,
      'status': _$GameStatusEnumMap[instance.status]!,
      'league': instance.league,
      'season': instance.season,
      'homeTeamLogo': instance.homeTeamLogo,
      'awayTeamLogo': instance.awayTeamLogo,
      'homeScore': instance.homeScore,
      'awayScore': instance.awayScore,
      'stats': instance.stats,
    };

const _$GameStatusEnumMap = {
  GameStatus.scheduled: 'scheduled',
  GameStatus.live: 'live',
  GameStatus.finished: 'finished',
  GameStatus.postponed: 'postponed',
  GameStatus.cancelled: 'cancelled',
};
