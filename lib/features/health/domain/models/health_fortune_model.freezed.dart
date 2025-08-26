// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_fortune_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HealthFortuneResult _$HealthFortuneResultFromJson(Map<String, dynamic> json) {
  return _HealthFortuneResult.fromJson(json);
}

/// @nodoc
mixin _$HealthFortuneResult {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get overallScore => throw _privateConstructorUsedError; // 0-100 전체 건강 점수
  String get mainMessage => throw _privateConstructorUsedError; // 메인 메시지
  List<BodyPartHealth> get bodyPartHealthList =>
      throw _privateConstructorUsedError; // 신체 부위별 상태
  List<HealthRecommendation> get recommendations =>
      throw _privateConstructorUsedError; // 건강 관리 제안
  List<String> get avoidanceList =>
      throw _privateConstructorUsedError; // 피해야 할 것들
  HealthTimeline get timeline => throw _privateConstructorUsedError; // 시간대별 컨디션
  String? get tomorrowPreview =>
      throw _privateConstructorUsedError; // 내일 컨디션 미리보기
  Map<String, dynamic>? get additionalInfo =>
      throw _privateConstructorUsedError;

  /// Serializes this HealthFortuneResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthFortuneResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthFortuneResultCopyWith<HealthFortuneResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthFortuneResultCopyWith<$Res> {
  factory $HealthFortuneResultCopyWith(
          HealthFortuneResult value, $Res Function(HealthFortuneResult) then) =
      _$HealthFortuneResultCopyWithImpl<$Res, HealthFortuneResult>;
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      int overallScore,
      String mainMessage,
      List<BodyPartHealth> bodyPartHealthList,
      List<HealthRecommendation> recommendations,
      List<String> avoidanceList,
      HealthTimeline timeline,
      String? tomorrowPreview,
      Map<String, dynamic>? additionalInfo});

  $HealthTimelineCopyWith<$Res> get timeline;
}

/// @nodoc
class _$HealthFortuneResultCopyWithImpl<$Res, $Val extends HealthFortuneResult>
    implements $HealthFortuneResultCopyWith<$Res> {
  _$HealthFortuneResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthFortuneResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? createdAt = null,
    Object? overallScore = null,
    Object? mainMessage = null,
    Object? bodyPartHealthList = null,
    Object? recommendations = null,
    Object? avoidanceList = null,
    Object? timeline = null,
    Object? tomorrowPreview = freezed,
    Object? additionalInfo = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      overallScore: null == overallScore
          ? _value.overallScore
          : overallScore // ignore: cast_nullable_to_non_nullable
              as int,
      mainMessage: null == mainMessage
          ? _value.mainMessage
          : mainMessage // ignore: cast_nullable_to_non_nullable
              as String,
      bodyPartHealthList: null == bodyPartHealthList
          ? _value.bodyPartHealthList
          : bodyPartHealthList // ignore: cast_nullable_to_non_nullable
              as List<BodyPartHealth>,
      recommendations: null == recommendations
          ? _value.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<HealthRecommendation>,
      avoidanceList: null == avoidanceList
          ? _value.avoidanceList
          : avoidanceList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      timeline: null == timeline
          ? _value.timeline
          : timeline // ignore: cast_nullable_to_non_nullable
              as HealthTimeline,
      tomorrowPreview: freezed == tomorrowPreview
          ? _value.tomorrowPreview
          : tomorrowPreview // ignore: cast_nullable_to_non_nullable
              as String?,
      additionalInfo: freezed == additionalInfo
          ? _value.additionalInfo
          : additionalInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  /// Create a copy of HealthFortuneResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HealthTimelineCopyWith<$Res> get timeline {
    return $HealthTimelineCopyWith<$Res>(_value.timeline, (value) {
      return _then(_value.copyWith(timeline: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HealthFortuneResultImplCopyWith<$Res>
    implements $HealthFortuneResultCopyWith<$Res> {
  factory _$$HealthFortuneResultImplCopyWith(_$HealthFortuneResultImpl value,
          $Res Function(_$HealthFortuneResultImpl) then) =
      __$$HealthFortuneResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      int overallScore,
      String mainMessage,
      List<BodyPartHealth> bodyPartHealthList,
      List<HealthRecommendation> recommendations,
      List<String> avoidanceList,
      HealthTimeline timeline,
      String? tomorrowPreview,
      Map<String, dynamic>? additionalInfo});

  @override
  $HealthTimelineCopyWith<$Res> get timeline;
}

/// @nodoc
class __$$HealthFortuneResultImplCopyWithImpl<$Res>
    extends _$HealthFortuneResultCopyWithImpl<$Res, _$HealthFortuneResultImpl>
    implements _$$HealthFortuneResultImplCopyWith<$Res> {
  __$$HealthFortuneResultImplCopyWithImpl(_$HealthFortuneResultImpl _value,
      $Res Function(_$HealthFortuneResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthFortuneResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? createdAt = null,
    Object? overallScore = null,
    Object? mainMessage = null,
    Object? bodyPartHealthList = null,
    Object? recommendations = null,
    Object? avoidanceList = null,
    Object? timeline = null,
    Object? tomorrowPreview = freezed,
    Object? additionalInfo = freezed,
  }) {
    return _then(_$HealthFortuneResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      overallScore: null == overallScore
          ? _value.overallScore
          : overallScore // ignore: cast_nullable_to_non_nullable
              as int,
      mainMessage: null == mainMessage
          ? _value.mainMessage
          : mainMessage // ignore: cast_nullable_to_non_nullable
              as String,
      bodyPartHealthList: null == bodyPartHealthList
          ? _value._bodyPartHealthList
          : bodyPartHealthList // ignore: cast_nullable_to_non_nullable
              as List<BodyPartHealth>,
      recommendations: null == recommendations
          ? _value._recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<HealthRecommendation>,
      avoidanceList: null == avoidanceList
          ? _value._avoidanceList
          : avoidanceList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      timeline: null == timeline
          ? _value.timeline
          : timeline // ignore: cast_nullable_to_non_nullable
              as HealthTimeline,
      tomorrowPreview: freezed == tomorrowPreview
          ? _value.tomorrowPreview
          : tomorrowPreview // ignore: cast_nullable_to_non_nullable
              as String?,
      additionalInfo: freezed == additionalInfo
          ? _value._additionalInfo
          : additionalInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthFortuneResultImpl implements _HealthFortuneResult {
  const _$HealthFortuneResultImpl(
      {required this.id,
      required this.userId,
      required this.createdAt,
      required this.overallScore,
      required this.mainMessage,
      required final List<BodyPartHealth> bodyPartHealthList,
      required final List<HealthRecommendation> recommendations,
      required final List<String> avoidanceList,
      required this.timeline,
      this.tomorrowPreview,
      final Map<String, dynamic>? additionalInfo})
      : _bodyPartHealthList = bodyPartHealthList,
        _recommendations = recommendations,
        _avoidanceList = avoidanceList,
        _additionalInfo = additionalInfo;

  factory _$HealthFortuneResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthFortuneResultImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime createdAt;
  @override
  final int overallScore;
// 0-100 전체 건강 점수
  @override
  final String mainMessage;
// 메인 메시지
  final List<BodyPartHealth> _bodyPartHealthList;
// 메인 메시지
  @override
  List<BodyPartHealth> get bodyPartHealthList {
    if (_bodyPartHealthList is EqualUnmodifiableListView)
      return _bodyPartHealthList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bodyPartHealthList);
  }

// 신체 부위별 상태
  final List<HealthRecommendation> _recommendations;
// 신체 부위별 상태
  @override
  List<HealthRecommendation> get recommendations {
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendations);
  }

// 건강 관리 제안
  final List<String> _avoidanceList;
// 건강 관리 제안
  @override
  List<String> get avoidanceList {
    if (_avoidanceList is EqualUnmodifiableListView) return _avoidanceList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_avoidanceList);
  }

// 피해야 할 것들
  @override
  final HealthTimeline timeline;
// 시간대별 컨디션
  @override
  final String? tomorrowPreview;
// 내일 컨디션 미리보기
  final Map<String, dynamic>? _additionalInfo;
// 내일 컨디션 미리보기
  @override
  Map<String, dynamic>? get additionalInfo {
    final value = _additionalInfo;
    if (value == null) return null;
    if (_additionalInfo is EqualUnmodifiableMapView) return _additionalInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'HealthFortuneResult(id: $id, userId: $userId, createdAt: $createdAt, overallScore: $overallScore, mainMessage: $mainMessage, bodyPartHealthList: $bodyPartHealthList, recommendations: $recommendations, avoidanceList: $avoidanceList, timeline: $timeline, tomorrowPreview: $tomorrowPreview, additionalInfo: $additionalInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthFortuneResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.overallScore, overallScore) ||
                other.overallScore == overallScore) &&
            (identical(other.mainMessage, mainMessage) ||
                other.mainMessage == mainMessage) &&
            const DeepCollectionEquality()
                .equals(other._bodyPartHealthList, _bodyPartHealthList) &&
            const DeepCollectionEquality()
                .equals(other._recommendations, _recommendations) &&
            const DeepCollectionEquality()
                .equals(other._avoidanceList, _avoidanceList) &&
            (identical(other.timeline, timeline) ||
                other.timeline == timeline) &&
            (identical(other.tomorrowPreview, tomorrowPreview) ||
                other.tomorrowPreview == tomorrowPreview) &&
            const DeepCollectionEquality()
                .equals(other._additionalInfo, _additionalInfo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      createdAt,
      overallScore,
      mainMessage,
      const DeepCollectionEquality().hash(_bodyPartHealthList),
      const DeepCollectionEquality().hash(_recommendations),
      const DeepCollectionEquality().hash(_avoidanceList),
      timeline,
      tomorrowPreview,
      const DeepCollectionEquality().hash(_additionalInfo));

  /// Create a copy of HealthFortuneResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthFortuneResultImplCopyWith<_$HealthFortuneResultImpl> get copyWith =>
      __$$HealthFortuneResultImplCopyWithImpl<_$HealthFortuneResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthFortuneResultImplToJson(
      this,
    );
  }
}

abstract class _HealthFortuneResult implements HealthFortuneResult {
  const factory _HealthFortuneResult(
      {required final String id,
      required final String userId,
      required final DateTime createdAt,
      required final int overallScore,
      required final String mainMessage,
      required final List<BodyPartHealth> bodyPartHealthList,
      required final List<HealthRecommendation> recommendations,
      required final List<String> avoidanceList,
      required final HealthTimeline timeline,
      final String? tomorrowPreview,
      final Map<String, dynamic>? additionalInfo}) = _$HealthFortuneResultImpl;

  factory _HealthFortuneResult.fromJson(Map<String, dynamic> json) =
      _$HealthFortuneResultImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  DateTime get createdAt;
  @override
  int get overallScore; // 0-100 전체 건강 점수
  @override
  String get mainMessage; // 메인 메시지
  @override
  List<BodyPartHealth> get bodyPartHealthList; // 신체 부위별 상태
  @override
  List<HealthRecommendation> get recommendations; // 건강 관리 제안
  @override
  List<String> get avoidanceList; // 피해야 할 것들
  @override
  HealthTimeline get timeline; // 시간대별 컨디션
  @override
  String? get tomorrowPreview; // 내일 컨디션 미리보기
  @override
  Map<String, dynamic>? get additionalInfo;

  /// Create a copy of HealthFortuneResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthFortuneResultImplCopyWith<_$HealthFortuneResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BodyPartHealth _$BodyPartHealthFromJson(Map<String, dynamic> json) {
  return _BodyPartHealth.fromJson(json);
}

/// @nodoc
mixin _$BodyPartHealth {
  BodyPart get bodyPart => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError; // 0-100 점수
  HealthLevel get level => throw _privateConstructorUsedError; // 위험도 레벨
  String get description => throw _privateConstructorUsedError; // 해당 부위 상태 설명
  List<String>? get specificTips => throw _privateConstructorUsedError;

  /// Serializes this BodyPartHealth to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BodyPartHealth
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BodyPartHealthCopyWith<BodyPartHealth> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BodyPartHealthCopyWith<$Res> {
  factory $BodyPartHealthCopyWith(
          BodyPartHealth value, $Res Function(BodyPartHealth) then) =
      _$BodyPartHealthCopyWithImpl<$Res, BodyPartHealth>;
  @useResult
  $Res call(
      {BodyPart bodyPart,
      int score,
      HealthLevel level,
      String description,
      List<String>? specificTips});
}

/// @nodoc
class _$BodyPartHealthCopyWithImpl<$Res, $Val extends BodyPartHealth>
    implements $BodyPartHealthCopyWith<$Res> {
  _$BodyPartHealthCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BodyPartHealth
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bodyPart = null,
    Object? score = null,
    Object? level = null,
    Object? description = null,
    Object? specificTips = freezed,
  }) {
    return _then(_value.copyWith(
      bodyPart: null == bodyPart
          ? _value.bodyPart
          : bodyPart // ignore: cast_nullable_to_non_nullable
              as BodyPart,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as HealthLevel,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      specificTips: freezed == specificTips
          ? _value.specificTips
          : specificTips // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BodyPartHealthImplCopyWith<$Res>
    implements $BodyPartHealthCopyWith<$Res> {
  factory _$$BodyPartHealthImplCopyWith(_$BodyPartHealthImpl value,
          $Res Function(_$BodyPartHealthImpl) then) =
      __$$BodyPartHealthImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {BodyPart bodyPart,
      int score,
      HealthLevel level,
      String description,
      List<String>? specificTips});
}

/// @nodoc
class __$$BodyPartHealthImplCopyWithImpl<$Res>
    extends _$BodyPartHealthCopyWithImpl<$Res, _$BodyPartHealthImpl>
    implements _$$BodyPartHealthImplCopyWith<$Res> {
  __$$BodyPartHealthImplCopyWithImpl(
      _$BodyPartHealthImpl _value, $Res Function(_$BodyPartHealthImpl) _then)
      : super(_value, _then);

  /// Create a copy of BodyPartHealth
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bodyPart = null,
    Object? score = null,
    Object? level = null,
    Object? description = null,
    Object? specificTips = freezed,
  }) {
    return _then(_$BodyPartHealthImpl(
      bodyPart: null == bodyPart
          ? _value.bodyPart
          : bodyPart // ignore: cast_nullable_to_non_nullable
              as BodyPart,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as HealthLevel,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      specificTips: freezed == specificTips
          ? _value._specificTips
          : specificTips // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BodyPartHealthImpl implements _BodyPartHealth {
  const _$BodyPartHealthImpl(
      {required this.bodyPart,
      required this.score,
      required this.level,
      required this.description,
      final List<String>? specificTips})
      : _specificTips = specificTips;

  factory _$BodyPartHealthImpl.fromJson(Map<String, dynamic> json) =>
      _$$BodyPartHealthImplFromJson(json);

  @override
  final BodyPart bodyPart;
  @override
  final int score;
// 0-100 점수
  @override
  final HealthLevel level;
// 위험도 레벨
  @override
  final String description;
// 해당 부위 상태 설명
  final List<String>? _specificTips;
// 해당 부위 상태 설명
  @override
  List<String>? get specificTips {
    final value = _specificTips;
    if (value == null) return null;
    if (_specificTips is EqualUnmodifiableListView) return _specificTips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'BodyPartHealth(bodyPart: $bodyPart, score: $score, level: $level, description: $description, specificTips: $specificTips)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BodyPartHealthImpl &&
            (identical(other.bodyPart, bodyPart) ||
                other.bodyPart == bodyPart) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._specificTips, _specificTips));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, bodyPart, score, level,
      description, const DeepCollectionEquality().hash(_specificTips));

  /// Create a copy of BodyPartHealth
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BodyPartHealthImplCopyWith<_$BodyPartHealthImpl> get copyWith =>
      __$$BodyPartHealthImplCopyWithImpl<_$BodyPartHealthImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BodyPartHealthImplToJson(
      this,
    );
  }
}

abstract class _BodyPartHealth implements BodyPartHealth {
  const factory _BodyPartHealth(
      {required final BodyPart bodyPart,
      required final int score,
      required final HealthLevel level,
      required final String description,
      final List<String>? specificTips}) = _$BodyPartHealthImpl;

  factory _BodyPartHealth.fromJson(Map<String, dynamic> json) =
      _$BodyPartHealthImpl.fromJson;

  @override
  BodyPart get bodyPart;
  @override
  int get score; // 0-100 점수
  @override
  HealthLevel get level; // 위험도 레벨
  @override
  String get description; // 해당 부위 상태 설명
  @override
  List<String>? get specificTips;

  /// Create a copy of BodyPartHealth
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BodyPartHealthImplCopyWith<_$BodyPartHealthImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HealthRecommendation _$HealthRecommendationFromJson(Map<String, dynamic> json) {
  return _HealthRecommendation.fromJson(json);
}

/// @nodoc
mixin _$HealthRecommendation {
  HealthRecommendationType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError; // 아이콘 이름
  int? get priority => throw _privateConstructorUsedError;

  /// Serializes this HealthRecommendation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthRecommendationCopyWith<HealthRecommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthRecommendationCopyWith<$Res> {
  factory $HealthRecommendationCopyWith(HealthRecommendation value,
          $Res Function(HealthRecommendation) then) =
      _$HealthRecommendationCopyWithImpl<$Res, HealthRecommendation>;
  @useResult
  $Res call(
      {HealthRecommendationType type,
      String title,
      String description,
      String? icon,
      int? priority});
}

/// @nodoc
class _$HealthRecommendationCopyWithImpl<$Res,
        $Val extends HealthRecommendation>
    implements $HealthRecommendationCopyWith<$Res> {
  _$HealthRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? icon = freezed,
    Object? priority = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as HealthRecommendationType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: freezed == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthRecommendationImplCopyWith<$Res>
    implements $HealthRecommendationCopyWith<$Res> {
  factory _$$HealthRecommendationImplCopyWith(_$HealthRecommendationImpl value,
          $Res Function(_$HealthRecommendationImpl) then) =
      __$$HealthRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {HealthRecommendationType type,
      String title,
      String description,
      String? icon,
      int? priority});
}

/// @nodoc
class __$$HealthRecommendationImplCopyWithImpl<$Res>
    extends _$HealthRecommendationCopyWithImpl<$Res, _$HealthRecommendationImpl>
    implements _$$HealthRecommendationImplCopyWith<$Res> {
  __$$HealthRecommendationImplCopyWithImpl(_$HealthRecommendationImpl _value,
      $Res Function(_$HealthRecommendationImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? icon = freezed,
    Object? priority = freezed,
  }) {
    return _then(_$HealthRecommendationImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as HealthRecommendationType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: freezed == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthRecommendationImpl implements _HealthRecommendation {
  const _$HealthRecommendationImpl(
      {required this.type,
      required this.title,
      required this.description,
      this.icon,
      this.priority});

  factory _$HealthRecommendationImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthRecommendationImplFromJson(json);

  @override
  final HealthRecommendationType type;
  @override
  final String title;
  @override
  final String description;
  @override
  final String? icon;
// 아이콘 이름
  @override
  final int? priority;

  @override
  String toString() {
    return 'HealthRecommendation(type: $type, title: $title, description: $description, icon: $icon, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthRecommendationImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.priority, priority) ||
                other.priority == priority));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, title, description, icon, priority);

  /// Create a copy of HealthRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthRecommendationImplCopyWith<_$HealthRecommendationImpl>
      get copyWith =>
          __$$HealthRecommendationImplCopyWithImpl<_$HealthRecommendationImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthRecommendationImplToJson(
      this,
    );
  }
}

abstract class _HealthRecommendation implements HealthRecommendation {
  const factory _HealthRecommendation(
      {required final HealthRecommendationType type,
      required final String title,
      required final String description,
      final String? icon,
      final int? priority}) = _$HealthRecommendationImpl;

  factory _HealthRecommendation.fromJson(Map<String, dynamic> json) =
      _$HealthRecommendationImpl.fromJson;

  @override
  HealthRecommendationType get type;
  @override
  String get title;
  @override
  String get description;
  @override
  String? get icon; // 아이콘 이름
  @override
  int? get priority;

  /// Create a copy of HealthRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthRecommendationImplCopyWith<_$HealthRecommendationImpl>
      get copyWith => throw _privateConstructorUsedError;
}

HealthTimeline _$HealthTimelineFromJson(Map<String, dynamic> json) {
  return _HealthTimeline.fromJson(json);
}

/// @nodoc
mixin _$HealthTimeline {
  HealthTimeSlot get morning =>
      throw _privateConstructorUsedError; // 오전 (06-12시)
  HealthTimeSlot get afternoon =>
      throw _privateConstructorUsedError; // 오후 (12-18시)
  HealthTimeSlot get evening =>
      throw _privateConstructorUsedError; // 저녁 (18-24시)
  String? get bestTimeActivity => throw _privateConstructorUsedError;

  /// Serializes this HealthTimeline to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthTimeline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthTimelineCopyWith<HealthTimeline> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthTimelineCopyWith<$Res> {
  factory $HealthTimelineCopyWith(
          HealthTimeline value, $Res Function(HealthTimeline) then) =
      _$HealthTimelineCopyWithImpl<$Res, HealthTimeline>;
  @useResult
  $Res call(
      {HealthTimeSlot morning,
      HealthTimeSlot afternoon,
      HealthTimeSlot evening,
      String? bestTimeActivity});

  $HealthTimeSlotCopyWith<$Res> get morning;
  $HealthTimeSlotCopyWith<$Res> get afternoon;
  $HealthTimeSlotCopyWith<$Res> get evening;
}

/// @nodoc
class _$HealthTimelineCopyWithImpl<$Res, $Val extends HealthTimeline>
    implements $HealthTimelineCopyWith<$Res> {
  _$HealthTimelineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthTimeline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? morning = null,
    Object? afternoon = null,
    Object? evening = null,
    Object? bestTimeActivity = freezed,
  }) {
    return _then(_value.copyWith(
      morning: null == morning
          ? _value.morning
          : morning // ignore: cast_nullable_to_non_nullable
              as HealthTimeSlot,
      afternoon: null == afternoon
          ? _value.afternoon
          : afternoon // ignore: cast_nullable_to_non_nullable
              as HealthTimeSlot,
      evening: null == evening
          ? _value.evening
          : evening // ignore: cast_nullable_to_non_nullable
              as HealthTimeSlot,
      bestTimeActivity: freezed == bestTimeActivity
          ? _value.bestTimeActivity
          : bestTimeActivity // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of HealthTimeline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HealthTimeSlotCopyWith<$Res> get morning {
    return $HealthTimeSlotCopyWith<$Res>(_value.morning, (value) {
      return _then(_value.copyWith(morning: value) as $Val);
    });
  }

  /// Create a copy of HealthTimeline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HealthTimeSlotCopyWith<$Res> get afternoon {
    return $HealthTimeSlotCopyWith<$Res>(_value.afternoon, (value) {
      return _then(_value.copyWith(afternoon: value) as $Val);
    });
  }

  /// Create a copy of HealthTimeline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HealthTimeSlotCopyWith<$Res> get evening {
    return $HealthTimeSlotCopyWith<$Res>(_value.evening, (value) {
      return _then(_value.copyWith(evening: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HealthTimelineImplCopyWith<$Res>
    implements $HealthTimelineCopyWith<$Res> {
  factory _$$HealthTimelineImplCopyWith(_$HealthTimelineImpl value,
          $Res Function(_$HealthTimelineImpl) then) =
      __$$HealthTimelineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {HealthTimeSlot morning,
      HealthTimeSlot afternoon,
      HealthTimeSlot evening,
      String? bestTimeActivity});

  @override
  $HealthTimeSlotCopyWith<$Res> get morning;
  @override
  $HealthTimeSlotCopyWith<$Res> get afternoon;
  @override
  $HealthTimeSlotCopyWith<$Res> get evening;
}

/// @nodoc
class __$$HealthTimelineImplCopyWithImpl<$Res>
    extends _$HealthTimelineCopyWithImpl<$Res, _$HealthTimelineImpl>
    implements _$$HealthTimelineImplCopyWith<$Res> {
  __$$HealthTimelineImplCopyWithImpl(
      _$HealthTimelineImpl _value, $Res Function(_$HealthTimelineImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthTimeline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? morning = null,
    Object? afternoon = null,
    Object? evening = null,
    Object? bestTimeActivity = freezed,
  }) {
    return _then(_$HealthTimelineImpl(
      morning: null == morning
          ? _value.morning
          : morning // ignore: cast_nullable_to_non_nullable
              as HealthTimeSlot,
      afternoon: null == afternoon
          ? _value.afternoon
          : afternoon // ignore: cast_nullable_to_non_nullable
              as HealthTimeSlot,
      evening: null == evening
          ? _value.evening
          : evening // ignore: cast_nullable_to_non_nullable
              as HealthTimeSlot,
      bestTimeActivity: freezed == bestTimeActivity
          ? _value.bestTimeActivity
          : bestTimeActivity // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthTimelineImpl implements _HealthTimeline {
  const _$HealthTimelineImpl(
      {required this.morning,
      required this.afternoon,
      required this.evening,
      this.bestTimeActivity});

  factory _$HealthTimelineImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthTimelineImplFromJson(json);

  @override
  final HealthTimeSlot morning;
// 오전 (06-12시)
  @override
  final HealthTimeSlot afternoon;
// 오후 (12-18시)
  @override
  final HealthTimeSlot evening;
// 저녁 (18-24시)
  @override
  final String? bestTimeActivity;

  @override
  String toString() {
    return 'HealthTimeline(morning: $morning, afternoon: $afternoon, evening: $evening, bestTimeActivity: $bestTimeActivity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthTimelineImpl &&
            (identical(other.morning, morning) || other.morning == morning) &&
            (identical(other.afternoon, afternoon) ||
                other.afternoon == afternoon) &&
            (identical(other.evening, evening) || other.evening == evening) &&
            (identical(other.bestTimeActivity, bestTimeActivity) ||
                other.bestTimeActivity == bestTimeActivity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, morning, afternoon, evening, bestTimeActivity);

  /// Create a copy of HealthTimeline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthTimelineImplCopyWith<_$HealthTimelineImpl> get copyWith =>
      __$$HealthTimelineImplCopyWithImpl<_$HealthTimelineImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthTimelineImplToJson(
      this,
    );
  }
}

abstract class _HealthTimeline implements HealthTimeline {
  const factory _HealthTimeline(
      {required final HealthTimeSlot morning,
      required final HealthTimeSlot afternoon,
      required final HealthTimeSlot evening,
      final String? bestTimeActivity}) = _$HealthTimelineImpl;

  factory _HealthTimeline.fromJson(Map<String, dynamic> json) =
      _$HealthTimelineImpl.fromJson;

  @override
  HealthTimeSlot get morning; // 오전 (06-12시)
  @override
  HealthTimeSlot get afternoon; // 오후 (12-18시)
  @override
  HealthTimeSlot get evening; // 저녁 (18-24시)
  @override
  String? get bestTimeActivity;

  /// Create a copy of HealthTimeline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthTimelineImplCopyWith<_$HealthTimelineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HealthTimeSlot _$HealthTimeSlotFromJson(Map<String, dynamic> json) {
  return _HealthTimeSlot.fromJson(json);
}

/// @nodoc
mixin _$HealthTimeSlot {
  String get timeLabel =>
      throw _privateConstructorUsedError; // "오전", "오후", "저녁"
  int get conditionScore => throw _privateConstructorUsedError; // 0-100 컨디션 점수
  String get description => throw _privateConstructorUsedError; // 해당 시간대 설명
  List<String>? get recommendations => throw _privateConstructorUsedError;

  /// Serializes this HealthTimeSlot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthTimeSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthTimeSlotCopyWith<HealthTimeSlot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthTimeSlotCopyWith<$Res> {
  factory $HealthTimeSlotCopyWith(
          HealthTimeSlot value, $Res Function(HealthTimeSlot) then) =
      _$HealthTimeSlotCopyWithImpl<$Res, HealthTimeSlot>;
  @useResult
  $Res call(
      {String timeLabel,
      int conditionScore,
      String description,
      List<String>? recommendations});
}

/// @nodoc
class _$HealthTimeSlotCopyWithImpl<$Res, $Val extends HealthTimeSlot>
    implements $HealthTimeSlotCopyWith<$Res> {
  _$HealthTimeSlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthTimeSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timeLabel = null,
    Object? conditionScore = null,
    Object? description = null,
    Object? recommendations = freezed,
  }) {
    return _then(_value.copyWith(
      timeLabel: null == timeLabel
          ? _value.timeLabel
          : timeLabel // ignore: cast_nullable_to_non_nullable
              as String,
      conditionScore: null == conditionScore
          ? _value.conditionScore
          : conditionScore // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      recommendations: freezed == recommendations
          ? _value.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthTimeSlotImplCopyWith<$Res>
    implements $HealthTimeSlotCopyWith<$Res> {
  factory _$$HealthTimeSlotImplCopyWith(_$HealthTimeSlotImpl value,
          $Res Function(_$HealthTimeSlotImpl) then) =
      __$$HealthTimeSlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String timeLabel,
      int conditionScore,
      String description,
      List<String>? recommendations});
}

/// @nodoc
class __$$HealthTimeSlotImplCopyWithImpl<$Res>
    extends _$HealthTimeSlotCopyWithImpl<$Res, _$HealthTimeSlotImpl>
    implements _$$HealthTimeSlotImplCopyWith<$Res> {
  __$$HealthTimeSlotImplCopyWithImpl(
      _$HealthTimeSlotImpl _value, $Res Function(_$HealthTimeSlotImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthTimeSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timeLabel = null,
    Object? conditionScore = null,
    Object? description = null,
    Object? recommendations = freezed,
  }) {
    return _then(_$HealthTimeSlotImpl(
      timeLabel: null == timeLabel
          ? _value.timeLabel
          : timeLabel // ignore: cast_nullable_to_non_nullable
              as String,
      conditionScore: null == conditionScore
          ? _value.conditionScore
          : conditionScore // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      recommendations: freezed == recommendations
          ? _value._recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthTimeSlotImpl implements _HealthTimeSlot {
  const _$HealthTimeSlotImpl(
      {required this.timeLabel,
      required this.conditionScore,
      required this.description,
      final List<String>? recommendations})
      : _recommendations = recommendations;

  factory _$HealthTimeSlotImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthTimeSlotImplFromJson(json);

  @override
  final String timeLabel;
// "오전", "오후", "저녁"
  @override
  final int conditionScore;
// 0-100 컨디션 점수
  @override
  final String description;
// 해당 시간대 설명
  final List<String>? _recommendations;
// 해당 시간대 설명
  @override
  List<String>? get recommendations {
    final value = _recommendations;
    if (value == null) return null;
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'HealthTimeSlot(timeLabel: $timeLabel, conditionScore: $conditionScore, description: $description, recommendations: $recommendations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthTimeSlotImpl &&
            (identical(other.timeLabel, timeLabel) ||
                other.timeLabel == timeLabel) &&
            (identical(other.conditionScore, conditionScore) ||
                other.conditionScore == conditionScore) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._recommendations, _recommendations));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, timeLabel, conditionScore,
      description, const DeepCollectionEquality().hash(_recommendations));

  /// Create a copy of HealthTimeSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthTimeSlotImplCopyWith<_$HealthTimeSlotImpl> get copyWith =>
      __$$HealthTimeSlotImplCopyWithImpl<_$HealthTimeSlotImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthTimeSlotImplToJson(
      this,
    );
  }
}

abstract class _HealthTimeSlot implements HealthTimeSlot {
  const factory _HealthTimeSlot(
      {required final String timeLabel,
      required final int conditionScore,
      required final String description,
      final List<String>? recommendations}) = _$HealthTimeSlotImpl;

  factory _HealthTimeSlot.fromJson(Map<String, dynamic> json) =
      _$HealthTimeSlotImpl.fromJson;

  @override
  String get timeLabel; // "오전", "오후", "저녁"
  @override
  int get conditionScore; // 0-100 컨디션 점수
  @override
  String get description; // 해당 시간대 설명
  @override
  List<String>? get recommendations;

  /// Create a copy of HealthTimeSlot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthTimeSlotImplCopyWith<_$HealthTimeSlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HealthFortuneInput _$HealthFortuneInputFromJson(Map<String, dynamic> json) {
  return _HealthFortuneInput.fromJson(json);
}

/// @nodoc
mixin _$HealthFortuneInput {
  String get userId => throw _privateConstructorUsedError;
  ConditionState? get currentCondition =>
      throw _privateConstructorUsedError; // 현재 컨디션
  List<BodyPart>? get concernedBodyParts =>
      throw _privateConstructorUsedError; // 신경쓰이는 부위들
  String? get specificSymptoms => throw _privateConstructorUsedError; // 구체적인 증상
  bool? get hasChronicCondition =>
      throw _privateConstructorUsedError; // 만성질환 여부
  Map<String, dynamic>? get additionalInfo =>
      throw _privateConstructorUsedError;

  /// Serializes this HealthFortuneInput to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthFortuneInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthFortuneInputCopyWith<HealthFortuneInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthFortuneInputCopyWith<$Res> {
  factory $HealthFortuneInputCopyWith(
          HealthFortuneInput value, $Res Function(HealthFortuneInput) then) =
      _$HealthFortuneInputCopyWithImpl<$Res, HealthFortuneInput>;
  @useResult
  $Res call(
      {String userId,
      ConditionState? currentCondition,
      List<BodyPart>? concernedBodyParts,
      String? specificSymptoms,
      bool? hasChronicCondition,
      Map<String, dynamic>? additionalInfo});
}

/// @nodoc
class _$HealthFortuneInputCopyWithImpl<$Res, $Val extends HealthFortuneInput>
    implements $HealthFortuneInputCopyWith<$Res> {
  _$HealthFortuneInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthFortuneInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? currentCondition = freezed,
    Object? concernedBodyParts = freezed,
    Object? specificSymptoms = freezed,
    Object? hasChronicCondition = freezed,
    Object? additionalInfo = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      currentCondition: freezed == currentCondition
          ? _value.currentCondition
          : currentCondition // ignore: cast_nullable_to_non_nullable
              as ConditionState?,
      concernedBodyParts: freezed == concernedBodyParts
          ? _value.concernedBodyParts
          : concernedBodyParts // ignore: cast_nullable_to_non_nullable
              as List<BodyPart>?,
      specificSymptoms: freezed == specificSymptoms
          ? _value.specificSymptoms
          : specificSymptoms // ignore: cast_nullable_to_non_nullable
              as String?,
      hasChronicCondition: freezed == hasChronicCondition
          ? _value.hasChronicCondition
          : hasChronicCondition // ignore: cast_nullable_to_non_nullable
              as bool?,
      additionalInfo: freezed == additionalInfo
          ? _value.additionalInfo
          : additionalInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthFortuneInputImplCopyWith<$Res>
    implements $HealthFortuneInputCopyWith<$Res> {
  factory _$$HealthFortuneInputImplCopyWith(_$HealthFortuneInputImpl value,
          $Res Function(_$HealthFortuneInputImpl) then) =
      __$$HealthFortuneInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      ConditionState? currentCondition,
      List<BodyPart>? concernedBodyParts,
      String? specificSymptoms,
      bool? hasChronicCondition,
      Map<String, dynamic>? additionalInfo});
}

/// @nodoc
class __$$HealthFortuneInputImplCopyWithImpl<$Res>
    extends _$HealthFortuneInputCopyWithImpl<$Res, _$HealthFortuneInputImpl>
    implements _$$HealthFortuneInputImplCopyWith<$Res> {
  __$$HealthFortuneInputImplCopyWithImpl(_$HealthFortuneInputImpl _value,
      $Res Function(_$HealthFortuneInputImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthFortuneInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? currentCondition = freezed,
    Object? concernedBodyParts = freezed,
    Object? specificSymptoms = freezed,
    Object? hasChronicCondition = freezed,
    Object? additionalInfo = freezed,
  }) {
    return _then(_$HealthFortuneInputImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      currentCondition: freezed == currentCondition
          ? _value.currentCondition
          : currentCondition // ignore: cast_nullable_to_non_nullable
              as ConditionState?,
      concernedBodyParts: freezed == concernedBodyParts
          ? _value._concernedBodyParts
          : concernedBodyParts // ignore: cast_nullable_to_non_nullable
              as List<BodyPart>?,
      specificSymptoms: freezed == specificSymptoms
          ? _value.specificSymptoms
          : specificSymptoms // ignore: cast_nullable_to_non_nullable
              as String?,
      hasChronicCondition: freezed == hasChronicCondition
          ? _value.hasChronicCondition
          : hasChronicCondition // ignore: cast_nullable_to_non_nullable
              as bool?,
      additionalInfo: freezed == additionalInfo
          ? _value._additionalInfo
          : additionalInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthFortuneInputImpl implements _HealthFortuneInput {
  const _$HealthFortuneInputImpl(
      {required this.userId,
      this.currentCondition,
      final List<BodyPart>? concernedBodyParts,
      this.specificSymptoms,
      this.hasChronicCondition,
      final Map<String, dynamic>? additionalInfo})
      : _concernedBodyParts = concernedBodyParts,
        _additionalInfo = additionalInfo;

  factory _$HealthFortuneInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthFortuneInputImplFromJson(json);

  @override
  final String userId;
  @override
  final ConditionState? currentCondition;
// 현재 컨디션
  final List<BodyPart>? _concernedBodyParts;
// 현재 컨디션
  @override
  List<BodyPart>? get concernedBodyParts {
    final value = _concernedBodyParts;
    if (value == null) return null;
    if (_concernedBodyParts is EqualUnmodifiableListView)
      return _concernedBodyParts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

// 신경쓰이는 부위들
  @override
  final String? specificSymptoms;
// 구체적인 증상
  @override
  final bool? hasChronicCondition;
// 만성질환 여부
  final Map<String, dynamic>? _additionalInfo;
// 만성질환 여부
  @override
  Map<String, dynamic>? get additionalInfo {
    final value = _additionalInfo;
    if (value == null) return null;
    if (_additionalInfo is EqualUnmodifiableMapView) return _additionalInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'HealthFortuneInput(userId: $userId, currentCondition: $currentCondition, concernedBodyParts: $concernedBodyParts, specificSymptoms: $specificSymptoms, hasChronicCondition: $hasChronicCondition, additionalInfo: $additionalInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthFortuneInputImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.currentCondition, currentCondition) ||
                other.currentCondition == currentCondition) &&
            const DeepCollectionEquality()
                .equals(other._concernedBodyParts, _concernedBodyParts) &&
            (identical(other.specificSymptoms, specificSymptoms) ||
                other.specificSymptoms == specificSymptoms) &&
            (identical(other.hasChronicCondition, hasChronicCondition) ||
                other.hasChronicCondition == hasChronicCondition) &&
            const DeepCollectionEquality()
                .equals(other._additionalInfo, _additionalInfo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      currentCondition,
      const DeepCollectionEquality().hash(_concernedBodyParts),
      specificSymptoms,
      hasChronicCondition,
      const DeepCollectionEquality().hash(_additionalInfo));

  /// Create a copy of HealthFortuneInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthFortuneInputImplCopyWith<_$HealthFortuneInputImpl> get copyWith =>
      __$$HealthFortuneInputImplCopyWithImpl<_$HealthFortuneInputImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthFortuneInputImplToJson(
      this,
    );
  }
}

abstract class _HealthFortuneInput implements HealthFortuneInput {
  const factory _HealthFortuneInput(
      {required final String userId,
      final ConditionState? currentCondition,
      final List<BodyPart>? concernedBodyParts,
      final String? specificSymptoms,
      final bool? hasChronicCondition,
      final Map<String, dynamic>? additionalInfo}) = _$HealthFortuneInputImpl;

  factory _HealthFortuneInput.fromJson(Map<String, dynamic> json) =
      _$HealthFortuneInputImpl.fromJson;

  @override
  String get userId;
  @override
  ConditionState? get currentCondition; // 현재 컨디션
  @override
  List<BodyPart>? get concernedBodyParts; // 신경쓰이는 부위들
  @override
  String? get specificSymptoms; // 구체적인 증상
  @override
  bool? get hasChronicCondition; // 만성질환 여부
  @override
  Map<String, dynamic>? get additionalInfo;

  /// Create a copy of HealthFortuneInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthFortuneInputImplCopyWith<_$HealthFortuneInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
