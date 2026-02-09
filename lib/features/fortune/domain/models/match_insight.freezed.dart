// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_insight.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MatchInsight _$MatchInsightFromJson(Map<String, dynamic> json) {
  return _MatchInsight.fromJson(json);
}

/// @nodoc
mixin _$MatchInsight {
  String get id => throw _privateConstructorUsedError;
  String get fortuneType => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;
  String get advice => throw _privateConstructorUsedError;
  MatchPrediction get prediction => throw _privateConstructorUsedError;
  TeamAnalysis get favoriteTeamAnalysis => throw _privateConstructorUsedError;
  TeamAnalysis get opponentAnalysis => throw _privateConstructorUsedError;
  FortuneElements get fortuneElements => throw _privateConstructorUsedError;
  String get cautionMessage => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  int? get percentile => throw _privateConstructorUsedError; // 경기 정보
  SportType get sport => throw _privateConstructorUsedError;
  String get homeTeam => throw _privateConstructorUsedError;
  String get awayTeam => throw _privateConstructorUsedError;
  DateTime get gameDate => throw _privateConstructorUsedError;
  String? get favoriteTeam => throw _privateConstructorUsedError;

  /// Serializes this MatchInsight to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchInsightCopyWith<MatchInsight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchInsightCopyWith<$Res> {
  factory $MatchInsightCopyWith(
          MatchInsight value, $Res Function(MatchInsight) then) =
      _$MatchInsightCopyWithImpl<$Res, MatchInsight>;
  @useResult
  $Res call(
      {String id,
      String fortuneType,
      int score,
      String content,
      String summary,
      String advice,
      MatchPrediction prediction,
      TeamAnalysis favoriteTeamAnalysis,
      TeamAnalysis opponentAnalysis,
      FortuneElements fortuneElements,
      String cautionMessage,
      DateTime timestamp,
      int? percentile,
      SportType sport,
      String homeTeam,
      String awayTeam,
      DateTime gameDate,
      String? favoriteTeam});

  $MatchPredictionCopyWith<$Res> get prediction;
  $TeamAnalysisCopyWith<$Res> get favoriteTeamAnalysis;
  $TeamAnalysisCopyWith<$Res> get opponentAnalysis;
  $FortuneElementsCopyWith<$Res> get fortuneElements;
}

/// @nodoc
class _$MatchInsightCopyWithImpl<$Res, $Val extends MatchInsight>
    implements $MatchInsightCopyWith<$Res> {
  _$MatchInsightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fortuneType = null,
    Object? score = null,
    Object? content = null,
    Object? summary = null,
    Object? advice = null,
    Object? prediction = null,
    Object? favoriteTeamAnalysis = null,
    Object? opponentAnalysis = null,
    Object? fortuneElements = null,
    Object? cautionMessage = null,
    Object? timestamp = null,
    Object? percentile = freezed,
    Object? sport = null,
    Object? homeTeam = null,
    Object? awayTeam = null,
    Object? gameDate = null,
    Object? favoriteTeam = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fortuneType: null == fortuneType
          ? _value.fortuneType
          : fortuneType // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      advice: null == advice
          ? _value.advice
          : advice // ignore: cast_nullable_to_non_nullable
              as String,
      prediction: null == prediction
          ? _value.prediction
          : prediction // ignore: cast_nullable_to_non_nullable
              as MatchPrediction,
      favoriteTeamAnalysis: null == favoriteTeamAnalysis
          ? _value.favoriteTeamAnalysis
          : favoriteTeamAnalysis // ignore: cast_nullable_to_non_nullable
              as TeamAnalysis,
      opponentAnalysis: null == opponentAnalysis
          ? _value.opponentAnalysis
          : opponentAnalysis // ignore: cast_nullable_to_non_nullable
              as TeamAnalysis,
      fortuneElements: null == fortuneElements
          ? _value.fortuneElements
          : fortuneElements // ignore: cast_nullable_to_non_nullable
              as FortuneElements,
      cautionMessage: null == cautionMessage
          ? _value.cautionMessage
          : cautionMessage // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      percentile: freezed == percentile
          ? _value.percentile
          : percentile // ignore: cast_nullable_to_non_nullable
              as int?,
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
      gameDate: null == gameDate
          ? _value.gameDate
          : gameDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      favoriteTeam: freezed == favoriteTeam
          ? _value.favoriteTeam
          : favoriteTeam // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of MatchInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchPredictionCopyWith<$Res> get prediction {
    return $MatchPredictionCopyWith<$Res>(_value.prediction, (value) {
      return _then(_value.copyWith(prediction: value) as $Val);
    });
  }

  /// Create a copy of MatchInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamAnalysisCopyWith<$Res> get favoriteTeamAnalysis {
    return $TeamAnalysisCopyWith<$Res>(_value.favoriteTeamAnalysis, (value) {
      return _then(_value.copyWith(favoriteTeamAnalysis: value) as $Val);
    });
  }

  /// Create a copy of MatchInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamAnalysisCopyWith<$Res> get opponentAnalysis {
    return $TeamAnalysisCopyWith<$Res>(_value.opponentAnalysis, (value) {
      return _then(_value.copyWith(opponentAnalysis: value) as $Val);
    });
  }

  /// Create a copy of MatchInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FortuneElementsCopyWith<$Res> get fortuneElements {
    return $FortuneElementsCopyWith<$Res>(_value.fortuneElements, (value) {
      return _then(_value.copyWith(fortuneElements: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchInsightImplCopyWith<$Res>
    implements $MatchInsightCopyWith<$Res> {
  factory _$$MatchInsightImplCopyWith(
          _$MatchInsightImpl value, $Res Function(_$MatchInsightImpl) then) =
      __$$MatchInsightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String fortuneType,
      int score,
      String content,
      String summary,
      String advice,
      MatchPrediction prediction,
      TeamAnalysis favoriteTeamAnalysis,
      TeamAnalysis opponentAnalysis,
      FortuneElements fortuneElements,
      String cautionMessage,
      DateTime timestamp,
      int? percentile,
      SportType sport,
      String homeTeam,
      String awayTeam,
      DateTime gameDate,
      String? favoriteTeam});

  @override
  $MatchPredictionCopyWith<$Res> get prediction;
  @override
  $TeamAnalysisCopyWith<$Res> get favoriteTeamAnalysis;
  @override
  $TeamAnalysisCopyWith<$Res> get opponentAnalysis;
  @override
  $FortuneElementsCopyWith<$Res> get fortuneElements;
}

/// @nodoc
class __$$MatchInsightImplCopyWithImpl<$Res>
    extends _$MatchInsightCopyWithImpl<$Res, _$MatchInsightImpl>
    implements _$$MatchInsightImplCopyWith<$Res> {
  __$$MatchInsightImplCopyWithImpl(
      _$MatchInsightImpl _value, $Res Function(_$MatchInsightImpl) _then)
      : super(_value, _then);

  /// Create a copy of MatchInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fortuneType = null,
    Object? score = null,
    Object? content = null,
    Object? summary = null,
    Object? advice = null,
    Object? prediction = null,
    Object? favoriteTeamAnalysis = null,
    Object? opponentAnalysis = null,
    Object? fortuneElements = null,
    Object? cautionMessage = null,
    Object? timestamp = null,
    Object? percentile = freezed,
    Object? sport = null,
    Object? homeTeam = null,
    Object? awayTeam = null,
    Object? gameDate = null,
    Object? favoriteTeam = freezed,
  }) {
    return _then(_$MatchInsightImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fortuneType: null == fortuneType
          ? _value.fortuneType
          : fortuneType // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      advice: null == advice
          ? _value.advice
          : advice // ignore: cast_nullable_to_non_nullable
              as String,
      prediction: null == prediction
          ? _value.prediction
          : prediction // ignore: cast_nullable_to_non_nullable
              as MatchPrediction,
      favoriteTeamAnalysis: null == favoriteTeamAnalysis
          ? _value.favoriteTeamAnalysis
          : favoriteTeamAnalysis // ignore: cast_nullable_to_non_nullable
              as TeamAnalysis,
      opponentAnalysis: null == opponentAnalysis
          ? _value.opponentAnalysis
          : opponentAnalysis // ignore: cast_nullable_to_non_nullable
              as TeamAnalysis,
      fortuneElements: null == fortuneElements
          ? _value.fortuneElements
          : fortuneElements // ignore: cast_nullable_to_non_nullable
              as FortuneElements,
      cautionMessage: null == cautionMessage
          ? _value.cautionMessage
          : cautionMessage // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      percentile: freezed == percentile
          ? _value.percentile
          : percentile // ignore: cast_nullable_to_non_nullable
              as int?,
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
      gameDate: null == gameDate
          ? _value.gameDate
          : gameDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      favoriteTeam: freezed == favoriteTeam
          ? _value.favoriteTeam
          : favoriteTeam // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchInsightImpl implements _MatchInsight {
  const _$MatchInsightImpl(
      {required this.id,
      this.fortuneType = 'match-insight',
      required this.score,
      required this.content,
      required this.summary,
      required this.advice,
      required this.prediction,
      required this.favoriteTeamAnalysis,
      required this.opponentAnalysis,
      required this.fortuneElements,
      required this.cautionMessage,
      required this.timestamp,
      this.percentile,
      required this.sport,
      required this.homeTeam,
      required this.awayTeam,
      required this.gameDate,
      this.favoriteTeam});

  factory _$MatchInsightImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchInsightImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String fortuneType;
  @override
  final int score;
  @override
  final String content;
  @override
  final String summary;
  @override
  final String advice;
  @override
  final MatchPrediction prediction;
  @override
  final TeamAnalysis favoriteTeamAnalysis;
  @override
  final TeamAnalysis opponentAnalysis;
  @override
  final FortuneElements fortuneElements;
  @override
  final String cautionMessage;
  @override
  final DateTime timestamp;
  @override
  final int? percentile;
// 경기 정보
  @override
  final SportType sport;
  @override
  final String homeTeam;
  @override
  final String awayTeam;
  @override
  final DateTime gameDate;
  @override
  final String? favoriteTeam;

  @override
  String toString() {
    return 'MatchInsight(id: $id, fortuneType: $fortuneType, score: $score, content: $content, summary: $summary, advice: $advice, prediction: $prediction, favoriteTeamAnalysis: $favoriteTeamAnalysis, opponentAnalysis: $opponentAnalysis, fortuneElements: $fortuneElements, cautionMessage: $cautionMessage, timestamp: $timestamp, percentile: $percentile, sport: $sport, homeTeam: $homeTeam, awayTeam: $awayTeam, gameDate: $gameDate, favoriteTeam: $favoriteTeam)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchInsightImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fortuneType, fortuneType) ||
                other.fortuneType == fortuneType) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.advice, advice) || other.advice == advice) &&
            (identical(other.prediction, prediction) ||
                other.prediction == prediction) &&
            (identical(other.favoriteTeamAnalysis, favoriteTeamAnalysis) ||
                other.favoriteTeamAnalysis == favoriteTeamAnalysis) &&
            (identical(other.opponentAnalysis, opponentAnalysis) ||
                other.opponentAnalysis == opponentAnalysis) &&
            (identical(other.fortuneElements, fortuneElements) ||
                other.fortuneElements == fortuneElements) &&
            (identical(other.cautionMessage, cautionMessage) ||
                other.cautionMessage == cautionMessage) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.percentile, percentile) ||
                other.percentile == percentile) &&
            (identical(other.sport, sport) || other.sport == sport) &&
            (identical(other.homeTeam, homeTeam) ||
                other.homeTeam == homeTeam) &&
            (identical(other.awayTeam, awayTeam) ||
                other.awayTeam == awayTeam) &&
            (identical(other.gameDate, gameDate) ||
                other.gameDate == gameDate) &&
            (identical(other.favoriteTeam, favoriteTeam) ||
                other.favoriteTeam == favoriteTeam));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      fortuneType,
      score,
      content,
      summary,
      advice,
      prediction,
      favoriteTeamAnalysis,
      opponentAnalysis,
      fortuneElements,
      cautionMessage,
      timestamp,
      percentile,
      sport,
      homeTeam,
      awayTeam,
      gameDate,
      favoriteTeam);

  /// Create a copy of MatchInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchInsightImplCopyWith<_$MatchInsightImpl> get copyWith =>
      __$$MatchInsightImplCopyWithImpl<_$MatchInsightImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchInsightImplToJson(
      this,
    );
  }
}

abstract class _MatchInsight implements MatchInsight {
  const factory _MatchInsight(
      {required final String id,
      final String fortuneType,
      required final int score,
      required final String content,
      required final String summary,
      required final String advice,
      required final MatchPrediction prediction,
      required final TeamAnalysis favoriteTeamAnalysis,
      required final TeamAnalysis opponentAnalysis,
      required final FortuneElements fortuneElements,
      required final String cautionMessage,
      required final DateTime timestamp,
      final int? percentile,
      required final SportType sport,
      required final String homeTeam,
      required final String awayTeam,
      required final DateTime gameDate,
      final String? favoriteTeam}) = _$MatchInsightImpl;

  factory _MatchInsight.fromJson(Map<String, dynamic> json) =
      _$MatchInsightImpl.fromJson;

  @override
  String get id;
  @override
  String get fortuneType;
  @override
  int get score;
  @override
  String get content;
  @override
  String get summary;
  @override
  String get advice;
  @override
  MatchPrediction get prediction;
  @override
  TeamAnalysis get favoriteTeamAnalysis;
  @override
  TeamAnalysis get opponentAnalysis;
  @override
  FortuneElements get fortuneElements;
  @override
  String get cautionMessage;
  @override
  DateTime get timestamp;
  @override
  int? get percentile; // 경기 정보
  @override
  SportType get sport;
  @override
  String get homeTeam;
  @override
  String get awayTeam;
  @override
  DateTime get gameDate;
  @override
  String? get favoriteTeam;

  /// Create a copy of MatchInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchInsightImplCopyWith<_$MatchInsightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchPrediction _$MatchPredictionFromJson(Map<String, dynamic> json) {
  return _MatchPrediction.fromJson(json);
}

/// @nodoc
mixin _$MatchPrediction {
  int get winProbability => throw _privateConstructorUsedError;
  String get confidence =>
      throw _privateConstructorUsedError; // 'high' | 'medium' | 'low'
  List<String> get keyFactors => throw _privateConstructorUsedError;
  String? get predictedScore => throw _privateConstructorUsedError;
  String? get mvpCandidate => throw _privateConstructorUsedError;

  /// Serializes this MatchPrediction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchPrediction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchPredictionCopyWith<MatchPrediction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchPredictionCopyWith<$Res> {
  factory $MatchPredictionCopyWith(
          MatchPrediction value, $Res Function(MatchPrediction) then) =
      _$MatchPredictionCopyWithImpl<$Res, MatchPrediction>;
  @useResult
  $Res call(
      {int winProbability,
      String confidence,
      List<String> keyFactors,
      String? predictedScore,
      String? mvpCandidate});
}

/// @nodoc
class _$MatchPredictionCopyWithImpl<$Res, $Val extends MatchPrediction>
    implements $MatchPredictionCopyWith<$Res> {
  _$MatchPredictionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchPrediction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? winProbability = null,
    Object? confidence = null,
    Object? keyFactors = null,
    Object? predictedScore = freezed,
    Object? mvpCandidate = freezed,
  }) {
    return _then(_value.copyWith(
      winProbability: null == winProbability
          ? _value.winProbability
          : winProbability // ignore: cast_nullable_to_non_nullable
              as int,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as String,
      keyFactors: null == keyFactors
          ? _value.keyFactors
          : keyFactors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      predictedScore: freezed == predictedScore
          ? _value.predictedScore
          : predictedScore // ignore: cast_nullable_to_non_nullable
              as String?,
      mvpCandidate: freezed == mvpCandidate
          ? _value.mvpCandidate
          : mvpCandidate // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MatchPredictionImplCopyWith<$Res>
    implements $MatchPredictionCopyWith<$Res> {
  factory _$$MatchPredictionImplCopyWith(_$MatchPredictionImpl value,
          $Res Function(_$MatchPredictionImpl) then) =
      __$$MatchPredictionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int winProbability,
      String confidence,
      List<String> keyFactors,
      String? predictedScore,
      String? mvpCandidate});
}

/// @nodoc
class __$$MatchPredictionImplCopyWithImpl<$Res>
    extends _$MatchPredictionCopyWithImpl<$Res, _$MatchPredictionImpl>
    implements _$$MatchPredictionImplCopyWith<$Res> {
  __$$MatchPredictionImplCopyWithImpl(
      _$MatchPredictionImpl _value, $Res Function(_$MatchPredictionImpl) _then)
      : super(_value, _then);

  /// Create a copy of MatchPrediction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? winProbability = null,
    Object? confidence = null,
    Object? keyFactors = null,
    Object? predictedScore = freezed,
    Object? mvpCandidate = freezed,
  }) {
    return _then(_$MatchPredictionImpl(
      winProbability: null == winProbability
          ? _value.winProbability
          : winProbability // ignore: cast_nullable_to_non_nullable
              as int,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as String,
      keyFactors: null == keyFactors
          ? _value._keyFactors
          : keyFactors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      predictedScore: freezed == predictedScore
          ? _value.predictedScore
          : predictedScore // ignore: cast_nullable_to_non_nullable
              as String?,
      mvpCandidate: freezed == mvpCandidate
          ? _value.mvpCandidate
          : mvpCandidate // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchPredictionImpl implements _MatchPrediction {
  const _$MatchPredictionImpl(
      {required this.winProbability,
      required this.confidence,
      required final List<String> keyFactors,
      this.predictedScore,
      this.mvpCandidate})
      : _keyFactors = keyFactors;

  factory _$MatchPredictionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchPredictionImplFromJson(json);

  @override
  final int winProbability;
  @override
  final String confidence;
// 'high' | 'medium' | 'low'
  final List<String> _keyFactors;
// 'high' | 'medium' | 'low'
  @override
  List<String> get keyFactors {
    if (_keyFactors is EqualUnmodifiableListView) return _keyFactors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keyFactors);
  }

  @override
  final String? predictedScore;
  @override
  final String? mvpCandidate;

  @override
  String toString() {
    return 'MatchPrediction(winProbability: $winProbability, confidence: $confidence, keyFactors: $keyFactors, predictedScore: $predictedScore, mvpCandidate: $mvpCandidate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchPredictionImpl &&
            (identical(other.winProbability, winProbability) ||
                other.winProbability == winProbability) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            const DeepCollectionEquality()
                .equals(other._keyFactors, _keyFactors) &&
            (identical(other.predictedScore, predictedScore) ||
                other.predictedScore == predictedScore) &&
            (identical(other.mvpCandidate, mvpCandidate) ||
                other.mvpCandidate == mvpCandidate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      winProbability,
      confidence,
      const DeepCollectionEquality().hash(_keyFactors),
      predictedScore,
      mvpCandidate);

  /// Create a copy of MatchPrediction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchPredictionImplCopyWith<_$MatchPredictionImpl> get copyWith =>
      __$$MatchPredictionImplCopyWithImpl<_$MatchPredictionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchPredictionImplToJson(
      this,
    );
  }
}

abstract class _MatchPrediction implements MatchPrediction {
  const factory _MatchPrediction(
      {required final int winProbability,
      required final String confidence,
      required final List<String> keyFactors,
      final String? predictedScore,
      final String? mvpCandidate}) = _$MatchPredictionImpl;

  factory _MatchPrediction.fromJson(Map<String, dynamic> json) =
      _$MatchPredictionImpl.fromJson;

  @override
  int get winProbability;
  @override
  String get confidence; // 'high' | 'medium' | 'low'
  @override
  List<String> get keyFactors;
  @override
  String? get predictedScore;
  @override
  String? get mvpCandidate;

  /// Create a copy of MatchPrediction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchPredictionImplCopyWith<_$MatchPredictionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TeamAnalysis _$TeamAnalysisFromJson(Map<String, dynamic> json) {
  return _TeamAnalysis.fromJson(json);
}

/// @nodoc
mixin _$TeamAnalysis {
  String get name => throw _privateConstructorUsedError;
  String get recentForm => throw _privateConstructorUsedError;
  List<String> get strengths => throw _privateConstructorUsedError;
  List<String> get concerns => throw _privateConstructorUsedError;
  String? get keyPlayer => throw _privateConstructorUsedError;
  String? get formEmoji => throw _privateConstructorUsedError;

  /// Serializes this TeamAnalysis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamAnalysisCopyWith<TeamAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamAnalysisCopyWith<$Res> {
  factory $TeamAnalysisCopyWith(
          TeamAnalysis value, $Res Function(TeamAnalysis) then) =
      _$TeamAnalysisCopyWithImpl<$Res, TeamAnalysis>;
  @useResult
  $Res call(
      {String name,
      String recentForm,
      List<String> strengths,
      List<String> concerns,
      String? keyPlayer,
      String? formEmoji});
}

/// @nodoc
class _$TeamAnalysisCopyWithImpl<$Res, $Val extends TeamAnalysis>
    implements $TeamAnalysisCopyWith<$Res> {
  _$TeamAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? recentForm = null,
    Object? strengths = null,
    Object? concerns = null,
    Object? keyPlayer = freezed,
    Object? formEmoji = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      recentForm: null == recentForm
          ? _value.recentForm
          : recentForm // ignore: cast_nullable_to_non_nullable
              as String,
      strengths: null == strengths
          ? _value.strengths
          : strengths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      concerns: null == concerns
          ? _value.concerns
          : concerns // ignore: cast_nullable_to_non_nullable
              as List<String>,
      keyPlayer: freezed == keyPlayer
          ? _value.keyPlayer
          : keyPlayer // ignore: cast_nullable_to_non_nullable
              as String?,
      formEmoji: freezed == formEmoji
          ? _value.formEmoji
          : formEmoji // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TeamAnalysisImplCopyWith<$Res>
    implements $TeamAnalysisCopyWith<$Res> {
  factory _$$TeamAnalysisImplCopyWith(
          _$TeamAnalysisImpl value, $Res Function(_$TeamAnalysisImpl) then) =
      __$$TeamAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String recentForm,
      List<String> strengths,
      List<String> concerns,
      String? keyPlayer,
      String? formEmoji});
}

/// @nodoc
class __$$TeamAnalysisImplCopyWithImpl<$Res>
    extends _$TeamAnalysisCopyWithImpl<$Res, _$TeamAnalysisImpl>
    implements _$$TeamAnalysisImplCopyWith<$Res> {
  __$$TeamAnalysisImplCopyWithImpl(
      _$TeamAnalysisImpl _value, $Res Function(_$TeamAnalysisImpl) _then)
      : super(_value, _then);

  /// Create a copy of TeamAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? recentForm = null,
    Object? strengths = null,
    Object? concerns = null,
    Object? keyPlayer = freezed,
    Object? formEmoji = freezed,
  }) {
    return _then(_$TeamAnalysisImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      recentForm: null == recentForm
          ? _value.recentForm
          : recentForm // ignore: cast_nullable_to_non_nullable
              as String,
      strengths: null == strengths
          ? _value._strengths
          : strengths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      concerns: null == concerns
          ? _value._concerns
          : concerns // ignore: cast_nullable_to_non_nullable
              as List<String>,
      keyPlayer: freezed == keyPlayer
          ? _value.keyPlayer
          : keyPlayer // ignore: cast_nullable_to_non_nullable
              as String?,
      formEmoji: freezed == formEmoji
          ? _value.formEmoji
          : formEmoji // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamAnalysisImpl implements _TeamAnalysis {
  const _$TeamAnalysisImpl(
      {required this.name,
      required this.recentForm,
      required final List<String> strengths,
      required final List<String> concerns,
      this.keyPlayer,
      this.formEmoji})
      : _strengths = strengths,
        _concerns = concerns;

  factory _$TeamAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamAnalysisImplFromJson(json);

  @override
  final String name;
  @override
  final String recentForm;
  final List<String> _strengths;
  @override
  List<String> get strengths {
    if (_strengths is EqualUnmodifiableListView) return _strengths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_strengths);
  }

  final List<String> _concerns;
  @override
  List<String> get concerns {
    if (_concerns is EqualUnmodifiableListView) return _concerns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_concerns);
  }

  @override
  final String? keyPlayer;
  @override
  final String? formEmoji;

  @override
  String toString() {
    return 'TeamAnalysis(name: $name, recentForm: $recentForm, strengths: $strengths, concerns: $concerns, keyPlayer: $keyPlayer, formEmoji: $formEmoji)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamAnalysisImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.recentForm, recentForm) ||
                other.recentForm == recentForm) &&
            const DeepCollectionEquality()
                .equals(other._strengths, _strengths) &&
            const DeepCollectionEquality().equals(other._concerns, _concerns) &&
            (identical(other.keyPlayer, keyPlayer) ||
                other.keyPlayer == keyPlayer) &&
            (identical(other.formEmoji, formEmoji) ||
                other.formEmoji == formEmoji));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      recentForm,
      const DeepCollectionEquality().hash(_strengths),
      const DeepCollectionEquality().hash(_concerns),
      keyPlayer,
      formEmoji);

  /// Create a copy of TeamAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamAnalysisImplCopyWith<_$TeamAnalysisImpl> get copyWith =>
      __$$TeamAnalysisImplCopyWithImpl<_$TeamAnalysisImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamAnalysisImplToJson(
      this,
    );
  }
}

abstract class _TeamAnalysis implements TeamAnalysis {
  const factory _TeamAnalysis(
      {required final String name,
      required final String recentForm,
      required final List<String> strengths,
      required final List<String> concerns,
      final String? keyPlayer,
      final String? formEmoji}) = _$TeamAnalysisImpl;

  factory _TeamAnalysis.fromJson(Map<String, dynamic> json) =
      _$TeamAnalysisImpl.fromJson;

  @override
  String get name;
  @override
  String get recentForm;
  @override
  List<String> get strengths;
  @override
  List<String> get concerns;
  @override
  String? get keyPlayer;
  @override
  String? get formEmoji;

  /// Create a copy of TeamAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamAnalysisImplCopyWith<_$TeamAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FortuneElements _$FortuneElementsFromJson(Map<String, dynamic> json) {
  return _FortuneElements.fromJson(json);
}

/// @nodoc
mixin _$FortuneElements {
  String get luckyColor => throw _privateConstructorUsedError;
  int get luckyNumber => throw _privateConstructorUsedError;
  String get luckyTime => throw _privateConstructorUsedError;
  String get luckyItem => throw _privateConstructorUsedError;
  String? get luckySection =>
      throw _privateConstructorUsedError; // 야구: "3회", 축구: "전반", e스포츠: "1세트"
  String? get luckyAction => throw _privateConstructorUsedError;

  /// Serializes this FortuneElements to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FortuneElements
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FortuneElementsCopyWith<FortuneElements> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FortuneElementsCopyWith<$Res> {
  factory $FortuneElementsCopyWith(
          FortuneElements value, $Res Function(FortuneElements) then) =
      _$FortuneElementsCopyWithImpl<$Res, FortuneElements>;
  @useResult
  $Res call(
      {String luckyColor,
      int luckyNumber,
      String luckyTime,
      String luckyItem,
      String? luckySection,
      String? luckyAction});
}

/// @nodoc
class _$FortuneElementsCopyWithImpl<$Res, $Val extends FortuneElements>
    implements $FortuneElementsCopyWith<$Res> {
  _$FortuneElementsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FortuneElements
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? luckyColor = null,
    Object? luckyNumber = null,
    Object? luckyTime = null,
    Object? luckyItem = null,
    Object? luckySection = freezed,
    Object? luckyAction = freezed,
  }) {
    return _then(_value.copyWith(
      luckyColor: null == luckyColor
          ? _value.luckyColor
          : luckyColor // ignore: cast_nullable_to_non_nullable
              as String,
      luckyNumber: null == luckyNumber
          ? _value.luckyNumber
          : luckyNumber // ignore: cast_nullable_to_non_nullable
              as int,
      luckyTime: null == luckyTime
          ? _value.luckyTime
          : luckyTime // ignore: cast_nullable_to_non_nullable
              as String,
      luckyItem: null == luckyItem
          ? _value.luckyItem
          : luckyItem // ignore: cast_nullable_to_non_nullable
              as String,
      luckySection: freezed == luckySection
          ? _value.luckySection
          : luckySection // ignore: cast_nullable_to_non_nullable
              as String?,
      luckyAction: freezed == luckyAction
          ? _value.luckyAction
          : luckyAction // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FortuneElementsImplCopyWith<$Res>
    implements $FortuneElementsCopyWith<$Res> {
  factory _$$FortuneElementsImplCopyWith(_$FortuneElementsImpl value,
          $Res Function(_$FortuneElementsImpl) then) =
      __$$FortuneElementsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String luckyColor,
      int luckyNumber,
      String luckyTime,
      String luckyItem,
      String? luckySection,
      String? luckyAction});
}

/// @nodoc
class __$$FortuneElementsImplCopyWithImpl<$Res>
    extends _$FortuneElementsCopyWithImpl<$Res, _$FortuneElementsImpl>
    implements _$$FortuneElementsImplCopyWith<$Res> {
  __$$FortuneElementsImplCopyWithImpl(
      _$FortuneElementsImpl _value, $Res Function(_$FortuneElementsImpl) _then)
      : super(_value, _then);

  /// Create a copy of FortuneElements
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? luckyColor = null,
    Object? luckyNumber = null,
    Object? luckyTime = null,
    Object? luckyItem = null,
    Object? luckySection = freezed,
    Object? luckyAction = freezed,
  }) {
    return _then(_$FortuneElementsImpl(
      luckyColor: null == luckyColor
          ? _value.luckyColor
          : luckyColor // ignore: cast_nullable_to_non_nullable
              as String,
      luckyNumber: null == luckyNumber
          ? _value.luckyNumber
          : luckyNumber // ignore: cast_nullable_to_non_nullable
              as int,
      luckyTime: null == luckyTime
          ? _value.luckyTime
          : luckyTime // ignore: cast_nullable_to_non_nullable
              as String,
      luckyItem: null == luckyItem
          ? _value.luckyItem
          : luckyItem // ignore: cast_nullable_to_non_nullable
              as String,
      luckySection: freezed == luckySection
          ? _value.luckySection
          : luckySection // ignore: cast_nullable_to_non_nullable
              as String?,
      luckyAction: freezed == luckyAction
          ? _value.luckyAction
          : luckyAction // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FortuneElementsImpl implements _FortuneElements {
  const _$FortuneElementsImpl(
      {required this.luckyColor,
      required this.luckyNumber,
      required this.luckyTime,
      required this.luckyItem,
      this.luckySection,
      this.luckyAction});

  factory _$FortuneElementsImpl.fromJson(Map<String, dynamic> json) =>
      _$$FortuneElementsImplFromJson(json);

  @override
  final String luckyColor;
  @override
  final int luckyNumber;
  @override
  final String luckyTime;
  @override
  final String luckyItem;
  @override
  final String? luckySection;
// 야구: "3회", 축구: "전반", e스포츠: "1세트"
  @override
  final String? luckyAction;

  @override
  String toString() {
    return 'FortuneElements(luckyColor: $luckyColor, luckyNumber: $luckyNumber, luckyTime: $luckyTime, luckyItem: $luckyItem, luckySection: $luckySection, luckyAction: $luckyAction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FortuneElementsImpl &&
            (identical(other.luckyColor, luckyColor) ||
                other.luckyColor == luckyColor) &&
            (identical(other.luckyNumber, luckyNumber) ||
                other.luckyNumber == luckyNumber) &&
            (identical(other.luckyTime, luckyTime) ||
                other.luckyTime == luckyTime) &&
            (identical(other.luckyItem, luckyItem) ||
                other.luckyItem == luckyItem) &&
            (identical(other.luckySection, luckySection) ||
                other.luckySection == luckySection) &&
            (identical(other.luckyAction, luckyAction) ||
                other.luckyAction == luckyAction));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, luckyColor, luckyNumber,
      luckyTime, luckyItem, luckySection, luckyAction);

  /// Create a copy of FortuneElements
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FortuneElementsImplCopyWith<_$FortuneElementsImpl> get copyWith =>
      __$$FortuneElementsImplCopyWithImpl<_$FortuneElementsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FortuneElementsImplToJson(
      this,
    );
  }
}

abstract class _FortuneElements implements FortuneElements {
  const factory _FortuneElements(
      {required final String luckyColor,
      required final int luckyNumber,
      required final String luckyTime,
      required final String luckyItem,
      final String? luckySection,
      final String? luckyAction}) = _$FortuneElementsImpl;

  factory _FortuneElements.fromJson(Map<String, dynamic> json) =
      _$FortuneElementsImpl.fromJson;

  @override
  String get luckyColor;
  @override
  int get luckyNumber;
  @override
  String get luckyTime;
  @override
  String get luckyItem;
  @override
  String? get luckySection; // 야구: "3회", 축구: "전반", e스포츠: "1세트"
  @override
  String? get luckyAction;

  /// Create a copy of FortuneElements
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FortuneElementsImplCopyWith<_$FortuneElementsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
