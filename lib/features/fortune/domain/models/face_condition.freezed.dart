// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'face_condition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FaceCondition _$FaceConditionFromJson(Map<String, dynamic> json) {
  return _FaceCondition.fromJson(json);
}

/// @nodoc
mixin _$FaceCondition {
  /// 혈색 점수 (0-100)
  int get complexionScore => throw _privateConstructorUsedError;

  /// 혈색 상태 설명 ("화사해요", "조금 창백해 보여요" 등)
  String get complexionDescription => throw _privateConstructorUsedError;

  /// 붓기 레벨 (0-100, 낮을수록 좋음)
  int get puffinessLevel => throw _privateConstructorUsedError;

  /// 붓기 상태 설명
  String get puffinessDescription => throw _privateConstructorUsedError;

  /// 피로도 레벨 (0-100, 낮을수록 좋음)
  int get fatigueLevel => throw _privateConstructorUsedError;

  /// 피로도 상태 설명
  String get fatigueDescription => throw _privateConstructorUsedError;

  /// 종합 컨디션 점수 (0-100)
  int get overallScore => throw _privateConstructorUsedError;

  /// 오늘의 얼굴 한줄 요약 ("오늘은 미소 지수가 조금 낮아요" 등)
  String get todaySummary => throw _privateConstructorUsedError;

  /// 컨디션 개선 팁
  List<ConditionTip> get improvementTips => throw _privateConstructorUsedError;

  /// Serializes this FaceCondition to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FaceCondition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FaceConditionCopyWith<FaceCondition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FaceConditionCopyWith<$Res> {
  factory $FaceConditionCopyWith(
          FaceCondition value, $Res Function(FaceCondition) then) =
      _$FaceConditionCopyWithImpl<$Res, FaceCondition>;
  @useResult
  $Res call(
      {int complexionScore,
      String complexionDescription,
      int puffinessLevel,
      String puffinessDescription,
      int fatigueLevel,
      String fatigueDescription,
      int overallScore,
      String todaySummary,
      List<ConditionTip> improvementTips});
}

/// @nodoc
class _$FaceConditionCopyWithImpl<$Res, $Val extends FaceCondition>
    implements $FaceConditionCopyWith<$Res> {
  _$FaceConditionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FaceCondition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? complexionScore = null,
    Object? complexionDescription = null,
    Object? puffinessLevel = null,
    Object? puffinessDescription = null,
    Object? fatigueLevel = null,
    Object? fatigueDescription = null,
    Object? overallScore = null,
    Object? todaySummary = null,
    Object? improvementTips = null,
  }) {
    return _then(_value.copyWith(
      complexionScore: null == complexionScore
          ? _value.complexionScore
          : complexionScore // ignore: cast_nullable_to_non_nullable
              as int,
      complexionDescription: null == complexionDescription
          ? _value.complexionDescription
          : complexionDescription // ignore: cast_nullable_to_non_nullable
              as String,
      puffinessLevel: null == puffinessLevel
          ? _value.puffinessLevel
          : puffinessLevel // ignore: cast_nullable_to_non_nullable
              as int,
      puffinessDescription: null == puffinessDescription
          ? _value.puffinessDescription
          : puffinessDescription // ignore: cast_nullable_to_non_nullable
              as String,
      fatigueLevel: null == fatigueLevel
          ? _value.fatigueLevel
          : fatigueLevel // ignore: cast_nullable_to_non_nullable
              as int,
      fatigueDescription: null == fatigueDescription
          ? _value.fatigueDescription
          : fatigueDescription // ignore: cast_nullable_to_non_nullable
              as String,
      overallScore: null == overallScore
          ? _value.overallScore
          : overallScore // ignore: cast_nullable_to_non_nullable
              as int,
      todaySummary: null == todaySummary
          ? _value.todaySummary
          : todaySummary // ignore: cast_nullable_to_non_nullable
              as String,
      improvementTips: null == improvementTips
          ? _value.improvementTips
          : improvementTips // ignore: cast_nullable_to_non_nullable
              as List<ConditionTip>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FaceConditionImplCopyWith<$Res>
    implements $FaceConditionCopyWith<$Res> {
  factory _$$FaceConditionImplCopyWith(
          _$FaceConditionImpl value, $Res Function(_$FaceConditionImpl) then) =
      __$$FaceConditionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int complexionScore,
      String complexionDescription,
      int puffinessLevel,
      String puffinessDescription,
      int fatigueLevel,
      String fatigueDescription,
      int overallScore,
      String todaySummary,
      List<ConditionTip> improvementTips});
}

/// @nodoc
class __$$FaceConditionImplCopyWithImpl<$Res>
    extends _$FaceConditionCopyWithImpl<$Res, _$FaceConditionImpl>
    implements _$$FaceConditionImplCopyWith<$Res> {
  __$$FaceConditionImplCopyWithImpl(
      _$FaceConditionImpl _value, $Res Function(_$FaceConditionImpl) _then)
      : super(_value, _then);

  /// Create a copy of FaceCondition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? complexionScore = null,
    Object? complexionDescription = null,
    Object? puffinessLevel = null,
    Object? puffinessDescription = null,
    Object? fatigueLevel = null,
    Object? fatigueDescription = null,
    Object? overallScore = null,
    Object? todaySummary = null,
    Object? improvementTips = null,
  }) {
    return _then(_$FaceConditionImpl(
      complexionScore: null == complexionScore
          ? _value.complexionScore
          : complexionScore // ignore: cast_nullable_to_non_nullable
              as int,
      complexionDescription: null == complexionDescription
          ? _value.complexionDescription
          : complexionDescription // ignore: cast_nullable_to_non_nullable
              as String,
      puffinessLevel: null == puffinessLevel
          ? _value.puffinessLevel
          : puffinessLevel // ignore: cast_nullable_to_non_nullable
              as int,
      puffinessDescription: null == puffinessDescription
          ? _value.puffinessDescription
          : puffinessDescription // ignore: cast_nullable_to_non_nullable
              as String,
      fatigueLevel: null == fatigueLevel
          ? _value.fatigueLevel
          : fatigueLevel // ignore: cast_nullable_to_non_nullable
              as int,
      fatigueDescription: null == fatigueDescription
          ? _value.fatigueDescription
          : fatigueDescription // ignore: cast_nullable_to_non_nullable
              as String,
      overallScore: null == overallScore
          ? _value.overallScore
          : overallScore // ignore: cast_nullable_to_non_nullable
              as int,
      todaySummary: null == todaySummary
          ? _value.todaySummary
          : todaySummary // ignore: cast_nullable_to_non_nullable
              as String,
      improvementTips: null == improvementTips
          ? _value._improvementTips
          : improvementTips // ignore: cast_nullable_to_non_nullable
              as List<ConditionTip>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FaceConditionImpl implements _FaceCondition {
  const _$FaceConditionImpl(
      {required this.complexionScore,
      required this.complexionDescription,
      required this.puffinessLevel,
      required this.puffinessDescription,
      required this.fatigueLevel,
      required this.fatigueDescription,
      required this.overallScore,
      required this.todaySummary,
      final List<ConditionTip> improvementTips = const []})
      : _improvementTips = improvementTips;

  factory _$FaceConditionImpl.fromJson(Map<String, dynamic> json) =>
      _$$FaceConditionImplFromJson(json);

  /// 혈색 점수 (0-100)
  @override
  final int complexionScore;

  /// 혈색 상태 설명 ("화사해요", "조금 창백해 보여요" 등)
  @override
  final String complexionDescription;

  /// 붓기 레벨 (0-100, 낮을수록 좋음)
  @override
  final int puffinessLevel;

  /// 붓기 상태 설명
  @override
  final String puffinessDescription;

  /// 피로도 레벨 (0-100, 낮을수록 좋음)
  @override
  final int fatigueLevel;

  /// 피로도 상태 설명
  @override
  final String fatigueDescription;

  /// 종합 컨디션 점수 (0-100)
  @override
  final int overallScore;

  /// 오늘의 얼굴 한줄 요약 ("오늘은 미소 지수가 조금 낮아요" 등)
  @override
  final String todaySummary;

  /// 컨디션 개선 팁
  final List<ConditionTip> _improvementTips;

  /// 컨디션 개선 팁
  @override
  @JsonKey()
  List<ConditionTip> get improvementTips {
    if (_improvementTips is EqualUnmodifiableListView) return _improvementTips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_improvementTips);
  }

  @override
  String toString() {
    return 'FaceCondition(complexionScore: $complexionScore, complexionDescription: $complexionDescription, puffinessLevel: $puffinessLevel, puffinessDescription: $puffinessDescription, fatigueLevel: $fatigueLevel, fatigueDescription: $fatigueDescription, overallScore: $overallScore, todaySummary: $todaySummary, improvementTips: $improvementTips)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FaceConditionImpl &&
            (identical(other.complexionScore, complexionScore) ||
                other.complexionScore == complexionScore) &&
            (identical(other.complexionDescription, complexionDescription) ||
                other.complexionDescription == complexionDescription) &&
            (identical(other.puffinessLevel, puffinessLevel) ||
                other.puffinessLevel == puffinessLevel) &&
            (identical(other.puffinessDescription, puffinessDescription) ||
                other.puffinessDescription == puffinessDescription) &&
            (identical(other.fatigueLevel, fatigueLevel) ||
                other.fatigueLevel == fatigueLevel) &&
            (identical(other.fatigueDescription, fatigueDescription) ||
                other.fatigueDescription == fatigueDescription) &&
            (identical(other.overallScore, overallScore) ||
                other.overallScore == overallScore) &&
            (identical(other.todaySummary, todaySummary) ||
                other.todaySummary == todaySummary) &&
            const DeepCollectionEquality()
                .equals(other._improvementTips, _improvementTips));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      complexionScore,
      complexionDescription,
      puffinessLevel,
      puffinessDescription,
      fatigueLevel,
      fatigueDescription,
      overallScore,
      todaySummary,
      const DeepCollectionEquality().hash(_improvementTips));

  /// Create a copy of FaceCondition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FaceConditionImplCopyWith<_$FaceConditionImpl> get copyWith =>
      __$$FaceConditionImplCopyWithImpl<_$FaceConditionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FaceConditionImplToJson(
      this,
    );
  }
}

abstract class _FaceCondition implements FaceCondition {
  const factory _FaceCondition(
      {required final int complexionScore,
      required final String complexionDescription,
      required final int puffinessLevel,
      required final String puffinessDescription,
      required final int fatigueLevel,
      required final String fatigueDescription,
      required final int overallScore,
      required final String todaySummary,
      final List<ConditionTip> improvementTips}) = _$FaceConditionImpl;

  factory _FaceCondition.fromJson(Map<String, dynamic> json) =
      _$FaceConditionImpl.fromJson;

  /// 혈색 점수 (0-100)
  @override
  int get complexionScore;

  /// 혈색 상태 설명 ("화사해요", "조금 창백해 보여요" 등)
  @override
  String get complexionDescription;

  /// 붓기 레벨 (0-100, 낮을수록 좋음)
  @override
  int get puffinessLevel;

  /// 붓기 상태 설명
  @override
  String get puffinessDescription;

  /// 피로도 레벨 (0-100, 낮을수록 좋음)
  @override
  int get fatigueLevel;

  /// 피로도 상태 설명
  @override
  String get fatigueDescription;

  /// 종합 컨디션 점수 (0-100)
  @override
  int get overallScore;

  /// 오늘의 얼굴 한줄 요약 ("오늘은 미소 지수가 조금 낮아요" 등)
  @override
  String get todaySummary;

  /// 컨디션 개선 팁
  @override
  List<ConditionTip> get improvementTips;

  /// Create a copy of FaceCondition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FaceConditionImplCopyWith<_$FaceConditionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConditionTip _$ConditionTipFromJson(Map<String, dynamic> json) {
  return _ConditionTip.fromJson(json);
}

/// @nodoc
mixin _$ConditionTip {
  /// 팁 카테고리 (hydration, rest, exercise, skincare)
  String get category => throw _privateConstructorUsedError;

  /// 팁 내용 (친근한 말투로)
  String get content => throw _privateConstructorUsedError;

  /// 아이콘 이모지
  String get emoji => throw _privateConstructorUsedError;

  /// Serializes this ConditionTip to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConditionTip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConditionTipCopyWith<ConditionTip> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConditionTipCopyWith<$Res> {
  factory $ConditionTipCopyWith(
          ConditionTip value, $Res Function(ConditionTip) then) =
      _$ConditionTipCopyWithImpl<$Res, ConditionTip>;
  @useResult
  $Res call({String category, String content, String emoji});
}

/// @nodoc
class _$ConditionTipCopyWithImpl<$Res, $Val extends ConditionTip>
    implements $ConditionTipCopyWith<$Res> {
  _$ConditionTipCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConditionTip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? content = null,
    Object? emoji = null,
  }) {
    return _then(_value.copyWith(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConditionTipImplCopyWith<$Res>
    implements $ConditionTipCopyWith<$Res> {
  factory _$$ConditionTipImplCopyWith(
          _$ConditionTipImpl value, $Res Function(_$ConditionTipImpl) then) =
      __$$ConditionTipImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String category, String content, String emoji});
}

/// @nodoc
class __$$ConditionTipImplCopyWithImpl<$Res>
    extends _$ConditionTipCopyWithImpl<$Res, _$ConditionTipImpl>
    implements _$$ConditionTipImplCopyWith<$Res> {
  __$$ConditionTipImplCopyWithImpl(
      _$ConditionTipImpl _value, $Res Function(_$ConditionTipImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConditionTip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? content = null,
    Object? emoji = null,
  }) {
    return _then(_$ConditionTipImpl(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConditionTipImpl implements _ConditionTip {
  const _$ConditionTipImpl(
      {required this.category, required this.content, this.emoji = '💡'});

  factory _$ConditionTipImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConditionTipImplFromJson(json);

  /// 팁 카테고리 (hydration, rest, exercise, skincare)
  @override
  final String category;

  /// 팁 내용 (친근한 말투로)
  @override
  final String content;

  /// 아이콘 이모지
  @override
  @JsonKey()
  final String emoji;

  @override
  String toString() {
    return 'ConditionTip(category: $category, content: $content, emoji: $emoji)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConditionTipImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.emoji, emoji) || other.emoji == emoji));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, category, content, emoji);

  /// Create a copy of ConditionTip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConditionTipImplCopyWith<_$ConditionTipImpl> get copyWith =>
      __$$ConditionTipImplCopyWithImpl<_$ConditionTipImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConditionTipImplToJson(
      this,
    );
  }
}

abstract class _ConditionTip implements ConditionTip {
  const factory _ConditionTip(
      {required final String category,
      required final String content,
      final String emoji}) = _$ConditionTipImpl;

  factory _ConditionTip.fromJson(Map<String, dynamic> json) =
      _$ConditionTipImpl.fromJson;

  /// 팁 카테고리 (hydration, rest, exercise, skincare)
  @override
  String get category;

  /// 팁 내용 (친근한 말투로)
  @override
  String get content;

  /// 아이콘 이모지
  @override
  String get emoji;

  /// Create a copy of ConditionTip
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConditionTipImplCopyWith<_$ConditionTipImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConditionTrend _$ConditionTrendFromJson(Map<String, dynamic> json) {
  return _ConditionTrend.fromJson(json);
}

/// @nodoc
mixin _$ConditionTrend {
  /// 최근 7일간 평균 컨디션
  double get weeklyAverage => throw _privateConstructorUsedError;

  /// 이전 주 대비 변화 (-100 ~ +100)
  double get weeklyChange => throw _privateConstructorUsedError;

  /// 트렌드 방향 (improving, stable, declining)
  String get trendDirection => throw _privateConstructorUsedError;

  /// 트렌드 인사이트 ("요즘 표정이 점점 부드러워지고 있어요")
  String get trendInsight => throw _privateConstructorUsedError;

  /// 일별 컨디션 데이터
  List<DailyCondition> get dailyConditions =>
      throw _privateConstructorUsedError;

  /// Serializes this ConditionTrend to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConditionTrend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConditionTrendCopyWith<ConditionTrend> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConditionTrendCopyWith<$Res> {
  factory $ConditionTrendCopyWith(
          ConditionTrend value, $Res Function(ConditionTrend) then) =
      _$ConditionTrendCopyWithImpl<$Res, ConditionTrend>;
  @useResult
  $Res call(
      {double weeklyAverage,
      double weeklyChange,
      String trendDirection,
      String trendInsight,
      List<DailyCondition> dailyConditions});
}

/// @nodoc
class _$ConditionTrendCopyWithImpl<$Res, $Val extends ConditionTrend>
    implements $ConditionTrendCopyWith<$Res> {
  _$ConditionTrendCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConditionTrend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weeklyAverage = null,
    Object? weeklyChange = null,
    Object? trendDirection = null,
    Object? trendInsight = null,
    Object? dailyConditions = null,
  }) {
    return _then(_value.copyWith(
      weeklyAverage: null == weeklyAverage
          ? _value.weeklyAverage
          : weeklyAverage // ignore: cast_nullable_to_non_nullable
              as double,
      weeklyChange: null == weeklyChange
          ? _value.weeklyChange
          : weeklyChange // ignore: cast_nullable_to_non_nullable
              as double,
      trendDirection: null == trendDirection
          ? _value.trendDirection
          : trendDirection // ignore: cast_nullable_to_non_nullable
              as String,
      trendInsight: null == trendInsight
          ? _value.trendInsight
          : trendInsight // ignore: cast_nullable_to_non_nullable
              as String,
      dailyConditions: null == dailyConditions
          ? _value.dailyConditions
          : dailyConditions // ignore: cast_nullable_to_non_nullable
              as List<DailyCondition>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConditionTrendImplCopyWith<$Res>
    implements $ConditionTrendCopyWith<$Res> {
  factory _$$ConditionTrendImplCopyWith(_$ConditionTrendImpl value,
          $Res Function(_$ConditionTrendImpl) then) =
      __$$ConditionTrendImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double weeklyAverage,
      double weeklyChange,
      String trendDirection,
      String trendInsight,
      List<DailyCondition> dailyConditions});
}

/// @nodoc
class __$$ConditionTrendImplCopyWithImpl<$Res>
    extends _$ConditionTrendCopyWithImpl<$Res, _$ConditionTrendImpl>
    implements _$$ConditionTrendImplCopyWith<$Res> {
  __$$ConditionTrendImplCopyWithImpl(
      _$ConditionTrendImpl _value, $Res Function(_$ConditionTrendImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConditionTrend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weeklyAverage = null,
    Object? weeklyChange = null,
    Object? trendDirection = null,
    Object? trendInsight = null,
    Object? dailyConditions = null,
  }) {
    return _then(_$ConditionTrendImpl(
      weeklyAverage: null == weeklyAverage
          ? _value.weeklyAverage
          : weeklyAverage // ignore: cast_nullable_to_non_nullable
              as double,
      weeklyChange: null == weeklyChange
          ? _value.weeklyChange
          : weeklyChange // ignore: cast_nullable_to_non_nullable
              as double,
      trendDirection: null == trendDirection
          ? _value.trendDirection
          : trendDirection // ignore: cast_nullable_to_non_nullable
              as String,
      trendInsight: null == trendInsight
          ? _value.trendInsight
          : trendInsight // ignore: cast_nullable_to_non_nullable
              as String,
      dailyConditions: null == dailyConditions
          ? _value._dailyConditions
          : dailyConditions // ignore: cast_nullable_to_non_nullable
              as List<DailyCondition>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConditionTrendImpl implements _ConditionTrend {
  const _$ConditionTrendImpl(
      {required this.weeklyAverage,
      required this.weeklyChange,
      required this.trendDirection,
      required this.trendInsight,
      final List<DailyCondition> dailyConditions = const []})
      : _dailyConditions = dailyConditions;

  factory _$ConditionTrendImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConditionTrendImplFromJson(json);

  /// 최근 7일간 평균 컨디션
  @override
  final double weeklyAverage;

  /// 이전 주 대비 변화 (-100 ~ +100)
  @override
  final double weeklyChange;

  /// 트렌드 방향 (improving, stable, declining)
  @override
  final String trendDirection;

  /// 트렌드 인사이트 ("요즘 표정이 점점 부드러워지고 있어요")
  @override
  final String trendInsight;

  /// 일별 컨디션 데이터
  final List<DailyCondition> _dailyConditions;

  /// 일별 컨디션 데이터
  @override
  @JsonKey()
  List<DailyCondition> get dailyConditions {
    if (_dailyConditions is EqualUnmodifiableListView) return _dailyConditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyConditions);
  }

  @override
  String toString() {
    return 'ConditionTrend(weeklyAverage: $weeklyAverage, weeklyChange: $weeklyChange, trendDirection: $trendDirection, trendInsight: $trendInsight, dailyConditions: $dailyConditions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConditionTrendImpl &&
            (identical(other.weeklyAverage, weeklyAverage) ||
                other.weeklyAverage == weeklyAverage) &&
            (identical(other.weeklyChange, weeklyChange) ||
                other.weeklyChange == weeklyChange) &&
            (identical(other.trendDirection, trendDirection) ||
                other.trendDirection == trendDirection) &&
            (identical(other.trendInsight, trendInsight) ||
                other.trendInsight == trendInsight) &&
            const DeepCollectionEquality()
                .equals(other._dailyConditions, _dailyConditions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      weeklyAverage,
      weeklyChange,
      trendDirection,
      trendInsight,
      const DeepCollectionEquality().hash(_dailyConditions));

  /// Create a copy of ConditionTrend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConditionTrendImplCopyWith<_$ConditionTrendImpl> get copyWith =>
      __$$ConditionTrendImplCopyWithImpl<_$ConditionTrendImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConditionTrendImplToJson(
      this,
    );
  }
}

abstract class _ConditionTrend implements ConditionTrend {
  const factory _ConditionTrend(
      {required final double weeklyAverage,
      required final double weeklyChange,
      required final String trendDirection,
      required final String trendInsight,
      final List<DailyCondition> dailyConditions}) = _$ConditionTrendImpl;

  factory _ConditionTrend.fromJson(Map<String, dynamic> json) =
      _$ConditionTrendImpl.fromJson;

  /// 최근 7일간 평균 컨디션
  @override
  double get weeklyAverage;

  /// 이전 주 대비 변화 (-100 ~ +100)
  @override
  double get weeklyChange;

  /// 트렌드 방향 (improving, stable, declining)
  @override
  String get trendDirection;

  /// 트렌드 인사이트 ("요즘 표정이 점점 부드러워지고 있어요")
  @override
  String get trendInsight;

  /// 일별 컨디션 데이터
  @override
  List<DailyCondition> get dailyConditions;

  /// Create a copy of ConditionTrend
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConditionTrendImplCopyWith<_$ConditionTrendImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyCondition _$DailyConditionFromJson(Map<String, dynamic> json) {
  return _DailyCondition.fromJson(json);
}

/// @nodoc
mixin _$DailyCondition {
  DateTime get date => throw _privateConstructorUsedError;
  int get overallScore => throw _privateConstructorUsedError;
  int get complexionScore => throw _privateConstructorUsedError;
  int get puffinessLevel => throw _privateConstructorUsedError;
  int get fatigueLevel => throw _privateConstructorUsedError;

  /// Serializes this DailyCondition to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyCondition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyConditionCopyWith<DailyCondition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyConditionCopyWith<$Res> {
  factory $DailyConditionCopyWith(
          DailyCondition value, $Res Function(DailyCondition) then) =
      _$DailyConditionCopyWithImpl<$Res, DailyCondition>;
  @useResult
  $Res call(
      {DateTime date,
      int overallScore,
      int complexionScore,
      int puffinessLevel,
      int fatigueLevel});
}

/// @nodoc
class _$DailyConditionCopyWithImpl<$Res, $Val extends DailyCondition>
    implements $DailyConditionCopyWith<$Res> {
  _$DailyConditionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyCondition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? overallScore = null,
    Object? complexionScore = null,
    Object? puffinessLevel = null,
    Object? fatigueLevel = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      overallScore: null == overallScore
          ? _value.overallScore
          : overallScore // ignore: cast_nullable_to_non_nullable
              as int,
      complexionScore: null == complexionScore
          ? _value.complexionScore
          : complexionScore // ignore: cast_nullable_to_non_nullable
              as int,
      puffinessLevel: null == puffinessLevel
          ? _value.puffinessLevel
          : puffinessLevel // ignore: cast_nullable_to_non_nullable
              as int,
      fatigueLevel: null == fatigueLevel
          ? _value.fatigueLevel
          : fatigueLevel // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyConditionImplCopyWith<$Res>
    implements $DailyConditionCopyWith<$Res> {
  factory _$$DailyConditionImplCopyWith(_$DailyConditionImpl value,
          $Res Function(_$DailyConditionImpl) then) =
      __$$DailyConditionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      int overallScore,
      int complexionScore,
      int puffinessLevel,
      int fatigueLevel});
}

/// @nodoc
class __$$DailyConditionImplCopyWithImpl<$Res>
    extends _$DailyConditionCopyWithImpl<$Res, _$DailyConditionImpl>
    implements _$$DailyConditionImplCopyWith<$Res> {
  __$$DailyConditionImplCopyWithImpl(
      _$DailyConditionImpl _value, $Res Function(_$DailyConditionImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyCondition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? overallScore = null,
    Object? complexionScore = null,
    Object? puffinessLevel = null,
    Object? fatigueLevel = null,
  }) {
    return _then(_$DailyConditionImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      overallScore: null == overallScore
          ? _value.overallScore
          : overallScore // ignore: cast_nullable_to_non_nullable
              as int,
      complexionScore: null == complexionScore
          ? _value.complexionScore
          : complexionScore // ignore: cast_nullable_to_non_nullable
              as int,
      puffinessLevel: null == puffinessLevel
          ? _value.puffinessLevel
          : puffinessLevel // ignore: cast_nullable_to_non_nullable
              as int,
      fatigueLevel: null == fatigueLevel
          ? _value.fatigueLevel
          : fatigueLevel // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyConditionImpl implements _DailyCondition {
  const _$DailyConditionImpl(
      {required this.date,
      required this.overallScore,
      required this.complexionScore,
      required this.puffinessLevel,
      required this.fatigueLevel});

  factory _$DailyConditionImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyConditionImplFromJson(json);

  @override
  final DateTime date;
  @override
  final int overallScore;
  @override
  final int complexionScore;
  @override
  final int puffinessLevel;
  @override
  final int fatigueLevel;

  @override
  String toString() {
    return 'DailyCondition(date: $date, overallScore: $overallScore, complexionScore: $complexionScore, puffinessLevel: $puffinessLevel, fatigueLevel: $fatigueLevel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyConditionImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.overallScore, overallScore) ||
                other.overallScore == overallScore) &&
            (identical(other.complexionScore, complexionScore) ||
                other.complexionScore == complexionScore) &&
            (identical(other.puffinessLevel, puffinessLevel) ||
                other.puffinessLevel == puffinessLevel) &&
            (identical(other.fatigueLevel, fatigueLevel) ||
                other.fatigueLevel == fatigueLevel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, overallScore,
      complexionScore, puffinessLevel, fatigueLevel);

  /// Create a copy of DailyCondition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyConditionImplCopyWith<_$DailyConditionImpl> get copyWith =>
      __$$DailyConditionImplCopyWithImpl<_$DailyConditionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyConditionImplToJson(
      this,
    );
  }
}

abstract class _DailyCondition implements DailyCondition {
  const factory _DailyCondition(
      {required final DateTime date,
      required final int overallScore,
      required final int complexionScore,
      required final int puffinessLevel,
      required final int fatigueLevel}) = _$DailyConditionImpl;

  factory _DailyCondition.fromJson(Map<String, dynamic> json) =
      _$DailyConditionImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get overallScore;
  @override
  int get complexionScore;
  @override
  int get puffinessLevel;
  @override
  int get fatigueLevel;

  /// Create a copy of DailyCondition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyConditionImplCopyWith<_$DailyConditionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
