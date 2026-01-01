// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sports_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SportsTeam _$SportsTeamFromJson(Map<String, dynamic> json) {
  return _SportsTeam.fromJson(json);
}

/// @nodoc
mixin _$SportsTeam {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get shortName => throw _privateConstructorUsedError;
  SportType get sport => throw _privateConstructorUsedError;
  String get league => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;
  String? get primaryColor => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;

  /// Serializes this SportsTeam to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SportsTeam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SportsTeamCopyWith<SportsTeam> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SportsTeamCopyWith<$Res> {
  factory $SportsTeamCopyWith(
          SportsTeam value, $Res Function(SportsTeam) then) =
      _$SportsTeamCopyWithImpl<$Res, SportsTeam>;
  @useResult
  $Res call(
      {String id,
      String name,
      String shortName,
      SportType sport,
      String league,
      String? logoUrl,
      String? primaryColor,
      String? city});
}

/// @nodoc
class _$SportsTeamCopyWithImpl<$Res, $Val extends SportsTeam>
    implements $SportsTeamCopyWith<$Res> {
  _$SportsTeamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SportsTeam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? shortName = null,
    Object? sport = null,
    Object? league = null,
    Object? logoUrl = freezed,
    Object? primaryColor = freezed,
    Object? city = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      shortName: null == shortName
          ? _value.shortName
          : shortName // ignore: cast_nullable_to_non_nullable
              as String,
      sport: null == sport
          ? _value.sport
          : sport // ignore: cast_nullable_to_non_nullable
              as SportType,
      league: null == league
          ? _value.league
          : league // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryColor: freezed == primaryColor
          ? _value.primaryColor
          : primaryColor // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SportsTeamImplCopyWith<$Res>
    implements $SportsTeamCopyWith<$Res> {
  factory _$$SportsTeamImplCopyWith(
          _$SportsTeamImpl value, $Res Function(_$SportsTeamImpl) then) =
      __$$SportsTeamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String shortName,
      SportType sport,
      String league,
      String? logoUrl,
      String? primaryColor,
      String? city});
}

/// @nodoc
class __$$SportsTeamImplCopyWithImpl<$Res>
    extends _$SportsTeamCopyWithImpl<$Res, _$SportsTeamImpl>
    implements _$$SportsTeamImplCopyWith<$Res> {
  __$$SportsTeamImplCopyWithImpl(
      _$SportsTeamImpl _value, $Res Function(_$SportsTeamImpl) _then)
      : super(_value, _then);

  /// Create a copy of SportsTeam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? shortName = null,
    Object? sport = null,
    Object? league = null,
    Object? logoUrl = freezed,
    Object? primaryColor = freezed,
    Object? city = freezed,
  }) {
    return _then(_$SportsTeamImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      shortName: null == shortName
          ? _value.shortName
          : shortName // ignore: cast_nullable_to_non_nullable
              as String,
      sport: null == sport
          ? _value.sport
          : sport // ignore: cast_nullable_to_non_nullable
              as SportType,
      league: null == league
          ? _value.league
          : league // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryColor: freezed == primaryColor
          ? _value.primaryColor
          : primaryColor // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SportsTeamImpl implements _SportsTeam {
  const _$SportsTeamImpl(
      {required this.id,
      required this.name,
      required this.shortName,
      required this.sport,
      required this.league,
      this.logoUrl,
      this.primaryColor,
      this.city});

  factory _$SportsTeamImpl.fromJson(Map<String, dynamic> json) =>
      _$$SportsTeamImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String shortName;
  @override
  final SportType sport;
  @override
  final String league;
  @override
  final String? logoUrl;
  @override
  final String? primaryColor;
  @override
  final String? city;

  @override
  String toString() {
    return 'SportsTeam(id: $id, name: $name, shortName: $shortName, sport: $sport, league: $league, logoUrl: $logoUrl, primaryColor: $primaryColor, city: $city)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SportsTeamImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.shortName, shortName) ||
                other.shortName == shortName) &&
            (identical(other.sport, sport) || other.sport == sport) &&
            (identical(other.league, league) || other.league == league) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.primaryColor, primaryColor) ||
                other.primaryColor == primaryColor) &&
            (identical(other.city, city) || other.city == city));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, shortName, sport,
      league, logoUrl, primaryColor, city);

  /// Create a copy of SportsTeam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SportsTeamImplCopyWith<_$SportsTeamImpl> get copyWith =>
      __$$SportsTeamImplCopyWithImpl<_$SportsTeamImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SportsTeamImplToJson(
      this,
    );
  }
}

abstract class _SportsTeam implements SportsTeam {
  const factory _SportsTeam(
      {required final String id,
      required final String name,
      required final String shortName,
      required final SportType sport,
      required final String league,
      final String? logoUrl,
      final String? primaryColor,
      final String? city}) = _$SportsTeamImpl;

  factory _SportsTeam.fromJson(Map<String, dynamic> json) =
      _$SportsTeamImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get shortName;
  @override
  SportType get sport;
  @override
  String get league;
  @override
  String? get logoUrl;
  @override
  String? get primaryColor;
  @override
  String? get city;

  /// Create a copy of SportsTeam
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SportsTeamImplCopyWith<_$SportsTeamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SportsGame _$SportsGameFromJson(Map<String, dynamic> json) {
  return _SportsGame.fromJson(json);
}

/// @nodoc
mixin _$SportsGame {
  String get id => throw _privateConstructorUsedError;
  SportType get sport => throw _privateConstructorUsedError;
  String get homeTeam => throw _privateConstructorUsedError;
  String get awayTeam => throw _privateConstructorUsedError;
  DateTime get gameTime => throw _privateConstructorUsedError;
  String get venue => throw _privateConstructorUsedError;
  GameStatus get status => throw _privateConstructorUsedError;
  String? get league => throw _privateConstructorUsedError;
  String? get season => throw _privateConstructorUsedError;
  String? get homeTeamLogo => throw _privateConstructorUsedError;
  String? get awayTeamLogo => throw _privateConstructorUsedError;
  int? get homeScore => throw _privateConstructorUsedError;
  int? get awayScore => throw _privateConstructorUsedError;
  Map<String, dynamic>? get stats => throw _privateConstructorUsedError;

  /// Serializes this SportsGame to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SportsGame
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SportsGameCopyWith<SportsGame> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SportsGameCopyWith<$Res> {
  factory $SportsGameCopyWith(
          SportsGame value, $Res Function(SportsGame) then) =
      _$SportsGameCopyWithImpl<$Res, SportsGame>;
  @useResult
  $Res call(
      {String id,
      SportType sport,
      String homeTeam,
      String awayTeam,
      DateTime gameTime,
      String venue,
      GameStatus status,
      String? league,
      String? season,
      String? homeTeamLogo,
      String? awayTeamLogo,
      int? homeScore,
      int? awayScore,
      Map<String, dynamic>? stats});
}

/// @nodoc
class _$SportsGameCopyWithImpl<$Res, $Val extends SportsGame>
    implements $SportsGameCopyWith<$Res> {
  _$SportsGameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SportsGame
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sport = null,
    Object? homeTeam = null,
    Object? awayTeam = null,
    Object? gameTime = null,
    Object? venue = null,
    Object? status = null,
    Object? league = freezed,
    Object? season = freezed,
    Object? homeTeamLogo = freezed,
    Object? awayTeamLogo = freezed,
    Object? homeScore = freezed,
    Object? awayScore = freezed,
    Object? stats = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sport: null == sport
          ? _value.sport
          : sport // ignore: cast_nullable_to_non_nullable
              as SportType,
      homeTeam: null == homeTeam
          ? _value.homeTeam
          : homeTeam // ignore: cast_nullable_to_non_nullable
              as String,
      awayTeam: null == awayTeam
          ? _value.awayTeam
          : awayTeam // ignore: cast_nullable_to_non_nullable
              as String,
      gameTime: null == gameTime
          ? _value.gameTime
          : gameTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      venue: null == venue
          ? _value.venue
          : venue // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GameStatus,
      league: freezed == league
          ? _value.league
          : league // ignore: cast_nullable_to_non_nullable
              as String?,
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as String?,
      homeTeamLogo: freezed == homeTeamLogo
          ? _value.homeTeamLogo
          : homeTeamLogo // ignore: cast_nullable_to_non_nullable
              as String?,
      awayTeamLogo: freezed == awayTeamLogo
          ? _value.awayTeamLogo
          : awayTeamLogo // ignore: cast_nullable_to_non_nullable
              as String?,
      homeScore: freezed == homeScore
          ? _value.homeScore
          : homeScore // ignore: cast_nullable_to_non_nullable
              as int?,
      awayScore: freezed == awayScore
          ? _value.awayScore
          : awayScore // ignore: cast_nullable_to_non_nullable
              as int?,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SportsGameImplCopyWith<$Res>
    implements $SportsGameCopyWith<$Res> {
  factory _$$SportsGameImplCopyWith(
          _$SportsGameImpl value, $Res Function(_$SportsGameImpl) then) =
      __$$SportsGameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      SportType sport,
      String homeTeam,
      String awayTeam,
      DateTime gameTime,
      String venue,
      GameStatus status,
      String? league,
      String? season,
      String? homeTeamLogo,
      String? awayTeamLogo,
      int? homeScore,
      int? awayScore,
      Map<String, dynamic>? stats});
}

/// @nodoc
class __$$SportsGameImplCopyWithImpl<$Res>
    extends _$SportsGameCopyWithImpl<$Res, _$SportsGameImpl>
    implements _$$SportsGameImplCopyWith<$Res> {
  __$$SportsGameImplCopyWithImpl(
      _$SportsGameImpl _value, $Res Function(_$SportsGameImpl) _then)
      : super(_value, _then);

  /// Create a copy of SportsGame
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sport = null,
    Object? homeTeam = null,
    Object? awayTeam = null,
    Object? gameTime = null,
    Object? venue = null,
    Object? status = null,
    Object? league = freezed,
    Object? season = freezed,
    Object? homeTeamLogo = freezed,
    Object? awayTeamLogo = freezed,
    Object? homeScore = freezed,
    Object? awayScore = freezed,
    Object? stats = freezed,
  }) {
    return _then(_$SportsGameImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sport: null == sport
          ? _value.sport
          : sport // ignore: cast_nullable_to_non_nullable
              as SportType,
      homeTeam: null == homeTeam
          ? _value.homeTeam
          : homeTeam // ignore: cast_nullable_to_non_nullable
              as String,
      awayTeam: null == awayTeam
          ? _value.awayTeam
          : awayTeam // ignore: cast_nullable_to_non_nullable
              as String,
      gameTime: null == gameTime
          ? _value.gameTime
          : gameTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      venue: null == venue
          ? _value.venue
          : venue // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GameStatus,
      league: freezed == league
          ? _value.league
          : league // ignore: cast_nullable_to_non_nullable
              as String?,
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as String?,
      homeTeamLogo: freezed == homeTeamLogo
          ? _value.homeTeamLogo
          : homeTeamLogo // ignore: cast_nullable_to_non_nullable
              as String?,
      awayTeamLogo: freezed == awayTeamLogo
          ? _value.awayTeamLogo
          : awayTeamLogo // ignore: cast_nullable_to_non_nullable
              as String?,
      homeScore: freezed == homeScore
          ? _value.homeScore
          : homeScore // ignore: cast_nullable_to_non_nullable
              as int?,
      awayScore: freezed == awayScore
          ? _value.awayScore
          : awayScore // ignore: cast_nullable_to_non_nullable
              as int?,
      stats: freezed == stats
          ? _value._stats
          : stats // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SportsGameImpl implements _SportsGame {
  const _$SportsGameImpl(
      {required this.id,
      required this.sport,
      required this.homeTeam,
      required this.awayTeam,
      required this.gameTime,
      required this.venue,
      this.status = GameStatus.scheduled,
      this.league,
      this.season,
      this.homeTeamLogo,
      this.awayTeamLogo,
      this.homeScore,
      this.awayScore,
      final Map<String, dynamic>? stats})
      : _stats = stats;

  factory _$SportsGameImpl.fromJson(Map<String, dynamic> json) =>
      _$$SportsGameImplFromJson(json);

  @override
  final String id;
  @override
  final SportType sport;
  @override
  final String homeTeam;
  @override
  final String awayTeam;
  @override
  final DateTime gameTime;
  @override
  final String venue;
  @override
  @JsonKey()
  final GameStatus status;
  @override
  final String? league;
  @override
  final String? season;
  @override
  final String? homeTeamLogo;
  @override
  final String? awayTeamLogo;
  @override
  final int? homeScore;
  @override
  final int? awayScore;
  final Map<String, dynamic>? _stats;
  @override
  Map<String, dynamic>? get stats {
    final value = _stats;
    if (value == null) return null;
    if (_stats is EqualUnmodifiableMapView) return _stats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'SportsGame(id: $id, sport: $sport, homeTeam: $homeTeam, awayTeam: $awayTeam, gameTime: $gameTime, venue: $venue, status: $status, league: $league, season: $season, homeTeamLogo: $homeTeamLogo, awayTeamLogo: $awayTeamLogo, homeScore: $homeScore, awayScore: $awayScore, stats: $stats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SportsGameImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sport, sport) || other.sport == sport) &&
            (identical(other.homeTeam, homeTeam) ||
                other.homeTeam == homeTeam) &&
            (identical(other.awayTeam, awayTeam) ||
                other.awayTeam == awayTeam) &&
            (identical(other.gameTime, gameTime) ||
                other.gameTime == gameTime) &&
            (identical(other.venue, venue) || other.venue == venue) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.league, league) || other.league == league) &&
            (identical(other.season, season) || other.season == season) &&
            (identical(other.homeTeamLogo, homeTeamLogo) ||
                other.homeTeamLogo == homeTeamLogo) &&
            (identical(other.awayTeamLogo, awayTeamLogo) ||
                other.awayTeamLogo == awayTeamLogo) &&
            (identical(other.homeScore, homeScore) ||
                other.homeScore == homeScore) &&
            (identical(other.awayScore, awayScore) ||
                other.awayScore == awayScore) &&
            const DeepCollectionEquality().equals(other._stats, _stats));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      sport,
      homeTeam,
      awayTeam,
      gameTime,
      venue,
      status,
      league,
      season,
      homeTeamLogo,
      awayTeamLogo,
      homeScore,
      awayScore,
      const DeepCollectionEquality().hash(_stats));

  /// Create a copy of SportsGame
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SportsGameImplCopyWith<_$SportsGameImpl> get copyWith =>
      __$$SportsGameImplCopyWithImpl<_$SportsGameImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SportsGameImplToJson(
      this,
    );
  }
}

abstract class _SportsGame implements SportsGame {
  const factory _SportsGame(
      {required final String id,
      required final SportType sport,
      required final String homeTeam,
      required final String awayTeam,
      required final DateTime gameTime,
      required final String venue,
      final GameStatus status,
      final String? league,
      final String? season,
      final String? homeTeamLogo,
      final String? awayTeamLogo,
      final int? homeScore,
      final int? awayScore,
      final Map<String, dynamic>? stats}) = _$SportsGameImpl;

  factory _SportsGame.fromJson(Map<String, dynamic> json) =
      _$SportsGameImpl.fromJson;

  @override
  String get id;
  @override
  SportType get sport;
  @override
  String get homeTeam;
  @override
  String get awayTeam;
  @override
  DateTime get gameTime;
  @override
  String get venue;
  @override
  GameStatus get status;
  @override
  String? get league;
  @override
  String? get season;
  @override
  String? get homeTeamLogo;
  @override
  String? get awayTeamLogo;
  @override
  int? get homeScore;
  @override
  int? get awayScore;
  @override
  Map<String, dynamic>? get stats;

  /// Create a copy of SportsGame
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SportsGameImplCopyWith<_$SportsGameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
