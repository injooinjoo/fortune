// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emotion_analysis.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EmotionAnalysis _$EmotionAnalysisFromJson(Map<String, dynamic> json) {
  return _EmotionAnalysis.fromJson(json);
}

/// @nodoc
mixin _$EmotionAnalysis {
  /// 미소 지수 (0-100%)
  double get smilePercentage => throw _privateConstructorUsedError;

  /// 긴장 지수 (0-100%)
  double get tensionPercentage => throw _privateConstructorUsedError;

  /// 무표정 지수 (0-100%)
  double get neutralPercentage => throw _privateConstructorUsedError;

  /// 편안함 지수 (0-100%)
  double get relaxedPercentage => throw _privateConstructorUsedError;

  /// 주요 감정 상태 (smile, tension, neutral, relaxed)
  String get dominantEmotion => throw _privateConstructorUsedError;

  /// 감정 상태 설명 (친근한 말투)
  String get emotionDescription => throw _privateConstructorUsedError;

  /// 인상 분석 - 다른 사람에게 어떻게 보이는지
  ImpressionAnalysis get impressionAnalysis =>
      throw _privateConstructorUsedError;

  /// Serializes this EmotionAnalysis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmotionAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmotionAnalysisCopyWith<EmotionAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmotionAnalysisCopyWith<$Res> {
  factory $EmotionAnalysisCopyWith(
          EmotionAnalysis value, $Res Function(EmotionAnalysis) then) =
      _$EmotionAnalysisCopyWithImpl<$Res, EmotionAnalysis>;
  @useResult
  $Res call(
      {double smilePercentage,
      double tensionPercentage,
      double neutralPercentage,
      double relaxedPercentage,
      String dominantEmotion,
      String emotionDescription,
      ImpressionAnalysis impressionAnalysis});

  $ImpressionAnalysisCopyWith<$Res> get impressionAnalysis;
}

/// @nodoc
class _$EmotionAnalysisCopyWithImpl<$Res, $Val extends EmotionAnalysis>
    implements $EmotionAnalysisCopyWith<$Res> {
  _$EmotionAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmotionAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? smilePercentage = null,
    Object? tensionPercentage = null,
    Object? neutralPercentage = null,
    Object? relaxedPercentage = null,
    Object? dominantEmotion = null,
    Object? emotionDescription = null,
    Object? impressionAnalysis = null,
  }) {
    return _then(_value.copyWith(
      smilePercentage: null == smilePercentage
          ? _value.smilePercentage
          : smilePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      tensionPercentage: null == tensionPercentage
          ? _value.tensionPercentage
          : tensionPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      neutralPercentage: null == neutralPercentage
          ? _value.neutralPercentage
          : neutralPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      relaxedPercentage: null == relaxedPercentage
          ? _value.relaxedPercentage
          : relaxedPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      dominantEmotion: null == dominantEmotion
          ? _value.dominantEmotion
          : dominantEmotion // ignore: cast_nullable_to_non_nullable
              as String,
      emotionDescription: null == emotionDescription
          ? _value.emotionDescription
          : emotionDescription // ignore: cast_nullable_to_non_nullable
              as String,
      impressionAnalysis: null == impressionAnalysis
          ? _value.impressionAnalysis
          : impressionAnalysis // ignore: cast_nullable_to_non_nullable
              as ImpressionAnalysis,
    ) as $Val);
  }

  /// Create a copy of EmotionAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ImpressionAnalysisCopyWith<$Res> get impressionAnalysis {
    return $ImpressionAnalysisCopyWith<$Res>(_value.impressionAnalysis,
        (value) {
      return _then(_value.copyWith(impressionAnalysis: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EmotionAnalysisImplCopyWith<$Res>
    implements $EmotionAnalysisCopyWith<$Res> {
  factory _$$EmotionAnalysisImplCopyWith(_$EmotionAnalysisImpl value,
          $Res Function(_$EmotionAnalysisImpl) then) =
      __$$EmotionAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double smilePercentage,
      double tensionPercentage,
      double neutralPercentage,
      double relaxedPercentage,
      String dominantEmotion,
      String emotionDescription,
      ImpressionAnalysis impressionAnalysis});

  @override
  $ImpressionAnalysisCopyWith<$Res> get impressionAnalysis;
}

/// @nodoc
class __$$EmotionAnalysisImplCopyWithImpl<$Res>
    extends _$EmotionAnalysisCopyWithImpl<$Res, _$EmotionAnalysisImpl>
    implements _$$EmotionAnalysisImplCopyWith<$Res> {
  __$$EmotionAnalysisImplCopyWithImpl(
      _$EmotionAnalysisImpl _value, $Res Function(_$EmotionAnalysisImpl) _then)
      : super(_value, _then);

  /// Create a copy of EmotionAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? smilePercentage = null,
    Object? tensionPercentage = null,
    Object? neutralPercentage = null,
    Object? relaxedPercentage = null,
    Object? dominantEmotion = null,
    Object? emotionDescription = null,
    Object? impressionAnalysis = null,
  }) {
    return _then(_$EmotionAnalysisImpl(
      smilePercentage: null == smilePercentage
          ? _value.smilePercentage
          : smilePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      tensionPercentage: null == tensionPercentage
          ? _value.tensionPercentage
          : tensionPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      neutralPercentage: null == neutralPercentage
          ? _value.neutralPercentage
          : neutralPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      relaxedPercentage: null == relaxedPercentage
          ? _value.relaxedPercentage
          : relaxedPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      dominantEmotion: null == dominantEmotion
          ? _value.dominantEmotion
          : dominantEmotion // ignore: cast_nullable_to_non_nullable
              as String,
      emotionDescription: null == emotionDescription
          ? _value.emotionDescription
          : emotionDescription // ignore: cast_nullable_to_non_nullable
              as String,
      impressionAnalysis: null == impressionAnalysis
          ? _value.impressionAnalysis
          : impressionAnalysis // ignore: cast_nullable_to_non_nullable
              as ImpressionAnalysis,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EmotionAnalysisImpl implements _EmotionAnalysis {
  const _$EmotionAnalysisImpl(
      {required this.smilePercentage,
      required this.tensionPercentage,
      required this.neutralPercentage,
      required this.relaxedPercentage,
      required this.dominantEmotion,
      required this.emotionDescription,
      required this.impressionAnalysis});

  factory _$EmotionAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmotionAnalysisImplFromJson(json);

  /// 미소 지수 (0-100%)
  @override
  final double smilePercentage;

  /// 긴장 지수 (0-100%)
  @override
  final double tensionPercentage;

  /// 무표정 지수 (0-100%)
  @override
  final double neutralPercentage;

  /// 편안함 지수 (0-100%)
  @override
  final double relaxedPercentage;

  /// 주요 감정 상태 (smile, tension, neutral, relaxed)
  @override
  final String dominantEmotion;

  /// 감정 상태 설명 (친근한 말투)
  @override
  final String emotionDescription;

  /// 인상 분석 - 다른 사람에게 어떻게 보이는지
  @override
  final ImpressionAnalysis impressionAnalysis;

  @override
  String toString() {
    return 'EmotionAnalysis(smilePercentage: $smilePercentage, tensionPercentage: $tensionPercentage, neutralPercentage: $neutralPercentage, relaxedPercentage: $relaxedPercentage, dominantEmotion: $dominantEmotion, emotionDescription: $emotionDescription, impressionAnalysis: $impressionAnalysis)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmotionAnalysisImpl &&
            (identical(other.smilePercentage, smilePercentage) ||
                other.smilePercentage == smilePercentage) &&
            (identical(other.tensionPercentage, tensionPercentage) ||
                other.tensionPercentage == tensionPercentage) &&
            (identical(other.neutralPercentage, neutralPercentage) ||
                other.neutralPercentage == neutralPercentage) &&
            (identical(other.relaxedPercentage, relaxedPercentage) ||
                other.relaxedPercentage == relaxedPercentage) &&
            (identical(other.dominantEmotion, dominantEmotion) ||
                other.dominantEmotion == dominantEmotion) &&
            (identical(other.emotionDescription, emotionDescription) ||
                other.emotionDescription == emotionDescription) &&
            (identical(other.impressionAnalysis, impressionAnalysis) ||
                other.impressionAnalysis == impressionAnalysis));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      smilePercentage,
      tensionPercentage,
      neutralPercentage,
      relaxedPercentage,
      dominantEmotion,
      emotionDescription,
      impressionAnalysis);

  /// Create a copy of EmotionAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmotionAnalysisImplCopyWith<_$EmotionAnalysisImpl> get copyWith =>
      __$$EmotionAnalysisImplCopyWithImpl<_$EmotionAnalysisImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmotionAnalysisImplToJson(
      this,
    );
  }
}

abstract class _EmotionAnalysis implements EmotionAnalysis {
  const factory _EmotionAnalysis(
          {required final double smilePercentage,
          required final double tensionPercentage,
          required final double neutralPercentage,
          required final double relaxedPercentage,
          required final String dominantEmotion,
          required final String emotionDescription,
          required final ImpressionAnalysis impressionAnalysis}) =
      _$EmotionAnalysisImpl;

  factory _EmotionAnalysis.fromJson(Map<String, dynamic> json) =
      _$EmotionAnalysisImpl.fromJson;

  /// 미소 지수 (0-100%)
  @override
  double get smilePercentage;

  /// 긴장 지수 (0-100%)
  @override
  double get tensionPercentage;

  /// 무표정 지수 (0-100%)
  @override
  double get neutralPercentage;

  /// 편안함 지수 (0-100%)
  @override
  double get relaxedPercentage;

  /// 주요 감정 상태 (smile, tension, neutral, relaxed)
  @override
  String get dominantEmotion;

  /// 감정 상태 설명 (친근한 말투)
  @override
  String get emotionDescription;

  /// 인상 분석 - 다른 사람에게 어떻게 보이는지
  @override
  ImpressionAnalysis get impressionAnalysis;

  /// Create a copy of EmotionAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmotionAnalysisImplCopyWith<_$EmotionAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ImpressionAnalysis _$ImpressionAnalysisFromJson(Map<String, dynamic> json) {
  return _ImpressionAnalysis.fromJson(json);
}

/// @nodoc
mixin _$ImpressionAnalysis {
  /// 첫인상 키워드 (["따뜻한", "신뢰가 가는", "차분한"])
  List<String> get firstImpressionKeywords =>
      throw _privateConstructorUsedError;

  /// 관계에서의 인상 ("친구들에게 편안한 분위기를 주는 편이에요")
  String get relationshipImpression => throw _privateConstructorUsedError;

  /// 직장/학교에서의 인상 ("면접관에게 진지한 인상을 줄 수 있어요")
  String get professionalImpression => throw _privateConstructorUsedError;

  /// 연애에서의 인상 (여성용: 배우자운, 연애운 관련)
  String? get romanticImpression => throw _privateConstructorUsedError;

  /// 인상 개선 팁
  List<String> get improvementSuggestions => throw _privateConstructorUsedError;

  /// 신뢰감 점수 (0-100)
  int get trustScore => throw _privateConstructorUsedError;

  /// 친근감 점수 (0-100)
  int get approachabilityScore => throw _privateConstructorUsedError;

  /// 카리스마 점수 (0-100)
  int get charismaScore => throw _privateConstructorUsedError;

  /// 종합 인상 코멘트
  String? get overallImpression => throw _privateConstructorUsedError;

  /// Serializes this ImpressionAnalysis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImpressionAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImpressionAnalysisCopyWith<ImpressionAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImpressionAnalysisCopyWith<$Res> {
  factory $ImpressionAnalysisCopyWith(
          ImpressionAnalysis value, $Res Function(ImpressionAnalysis) then) =
      _$ImpressionAnalysisCopyWithImpl<$Res, ImpressionAnalysis>;
  @useResult
  $Res call(
      {List<String> firstImpressionKeywords,
      String relationshipImpression,
      String professionalImpression,
      String? romanticImpression,
      List<String> improvementSuggestions,
      int trustScore,
      int approachabilityScore,
      int charismaScore,
      String? overallImpression});
}

/// @nodoc
class _$ImpressionAnalysisCopyWithImpl<$Res, $Val extends ImpressionAnalysis>
    implements $ImpressionAnalysisCopyWith<$Res> {
  _$ImpressionAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImpressionAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstImpressionKeywords = null,
    Object? relationshipImpression = null,
    Object? professionalImpression = null,
    Object? romanticImpression = freezed,
    Object? improvementSuggestions = null,
    Object? trustScore = null,
    Object? approachabilityScore = null,
    Object? charismaScore = null,
    Object? overallImpression = freezed,
  }) {
    return _then(_value.copyWith(
      firstImpressionKeywords: null == firstImpressionKeywords
          ? _value.firstImpressionKeywords
          : firstImpressionKeywords // ignore: cast_nullable_to_non_nullable
              as List<String>,
      relationshipImpression: null == relationshipImpression
          ? _value.relationshipImpression
          : relationshipImpression // ignore: cast_nullable_to_non_nullable
              as String,
      professionalImpression: null == professionalImpression
          ? _value.professionalImpression
          : professionalImpression // ignore: cast_nullable_to_non_nullable
              as String,
      romanticImpression: freezed == romanticImpression
          ? _value.romanticImpression
          : romanticImpression // ignore: cast_nullable_to_non_nullable
              as String?,
      improvementSuggestions: null == improvementSuggestions
          ? _value.improvementSuggestions
          : improvementSuggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      trustScore: null == trustScore
          ? _value.trustScore
          : trustScore // ignore: cast_nullable_to_non_nullable
              as int,
      approachabilityScore: null == approachabilityScore
          ? _value.approachabilityScore
          : approachabilityScore // ignore: cast_nullable_to_non_nullable
              as int,
      charismaScore: null == charismaScore
          ? _value.charismaScore
          : charismaScore // ignore: cast_nullable_to_non_nullable
              as int,
      overallImpression: freezed == overallImpression
          ? _value.overallImpression
          : overallImpression // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImpressionAnalysisImplCopyWith<$Res>
    implements $ImpressionAnalysisCopyWith<$Res> {
  factory _$$ImpressionAnalysisImplCopyWith(_$ImpressionAnalysisImpl value,
          $Res Function(_$ImpressionAnalysisImpl) then) =
      __$$ImpressionAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> firstImpressionKeywords,
      String relationshipImpression,
      String professionalImpression,
      String? romanticImpression,
      List<String> improvementSuggestions,
      int trustScore,
      int approachabilityScore,
      int charismaScore,
      String? overallImpression});
}

/// @nodoc
class __$$ImpressionAnalysisImplCopyWithImpl<$Res>
    extends _$ImpressionAnalysisCopyWithImpl<$Res, _$ImpressionAnalysisImpl>
    implements _$$ImpressionAnalysisImplCopyWith<$Res> {
  __$$ImpressionAnalysisImplCopyWithImpl(_$ImpressionAnalysisImpl _value,
      $Res Function(_$ImpressionAnalysisImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImpressionAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstImpressionKeywords = null,
    Object? relationshipImpression = null,
    Object? professionalImpression = null,
    Object? romanticImpression = freezed,
    Object? improvementSuggestions = null,
    Object? trustScore = null,
    Object? approachabilityScore = null,
    Object? charismaScore = null,
    Object? overallImpression = freezed,
  }) {
    return _then(_$ImpressionAnalysisImpl(
      firstImpressionKeywords: null == firstImpressionKeywords
          ? _value._firstImpressionKeywords
          : firstImpressionKeywords // ignore: cast_nullable_to_non_nullable
              as List<String>,
      relationshipImpression: null == relationshipImpression
          ? _value.relationshipImpression
          : relationshipImpression // ignore: cast_nullable_to_non_nullable
              as String,
      professionalImpression: null == professionalImpression
          ? _value.professionalImpression
          : professionalImpression // ignore: cast_nullable_to_non_nullable
              as String,
      romanticImpression: freezed == romanticImpression
          ? _value.romanticImpression
          : romanticImpression // ignore: cast_nullable_to_non_nullable
              as String?,
      improvementSuggestions: null == improvementSuggestions
          ? _value._improvementSuggestions
          : improvementSuggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      trustScore: null == trustScore
          ? _value.trustScore
          : trustScore // ignore: cast_nullable_to_non_nullable
              as int,
      approachabilityScore: null == approachabilityScore
          ? _value.approachabilityScore
          : approachabilityScore // ignore: cast_nullable_to_non_nullable
              as int,
      charismaScore: null == charismaScore
          ? _value.charismaScore
          : charismaScore // ignore: cast_nullable_to_non_nullable
              as int,
      overallImpression: freezed == overallImpression
          ? _value.overallImpression
          : overallImpression // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ImpressionAnalysisImpl implements _ImpressionAnalysis {
  const _$ImpressionAnalysisImpl(
      {required final List<String> firstImpressionKeywords,
      required this.relationshipImpression,
      required this.professionalImpression,
      this.romanticImpression,
      final List<String> improvementSuggestions = const [],
      this.trustScore = 50,
      this.approachabilityScore = 50,
      this.charismaScore = 50,
      this.overallImpression})
      : _firstImpressionKeywords = firstImpressionKeywords,
        _improvementSuggestions = improvementSuggestions;

  factory _$ImpressionAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImpressionAnalysisImplFromJson(json);

  /// 첫인상 키워드 (["따뜻한", "신뢰가 가는", "차분한"])
  final List<String> _firstImpressionKeywords;

  /// 첫인상 키워드 (["따뜻한", "신뢰가 가는", "차분한"])
  @override
  List<String> get firstImpressionKeywords {
    if (_firstImpressionKeywords is EqualUnmodifiableListView)
      return _firstImpressionKeywords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_firstImpressionKeywords);
  }

  /// 관계에서의 인상 ("친구들에게 편안한 분위기를 주는 편이에요")
  @override
  final String relationshipImpression;

  /// 직장/학교에서의 인상 ("면접관에게 진지한 인상을 줄 수 있어요")
  @override
  final String professionalImpression;

  /// 연애에서의 인상 (여성용: 배우자운, 연애운 관련)
  @override
  final String? romanticImpression;

  /// 인상 개선 팁
  final List<String> _improvementSuggestions;

  /// 인상 개선 팁
  @override
  @JsonKey()
  List<String> get improvementSuggestions {
    if (_improvementSuggestions is EqualUnmodifiableListView)
      return _improvementSuggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_improvementSuggestions);
  }

  /// 신뢰감 점수 (0-100)
  @override
  @JsonKey()
  final int trustScore;

  /// 친근감 점수 (0-100)
  @override
  @JsonKey()
  final int approachabilityScore;

  /// 카리스마 점수 (0-100)
  @override
  @JsonKey()
  final int charismaScore;

  /// 종합 인상 코멘트
  @override
  final String? overallImpression;

  @override
  String toString() {
    return 'ImpressionAnalysis(firstImpressionKeywords: $firstImpressionKeywords, relationshipImpression: $relationshipImpression, professionalImpression: $professionalImpression, romanticImpression: $romanticImpression, improvementSuggestions: $improvementSuggestions, trustScore: $trustScore, approachabilityScore: $approachabilityScore, charismaScore: $charismaScore, overallImpression: $overallImpression)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImpressionAnalysisImpl &&
            const DeepCollectionEquality().equals(
                other._firstImpressionKeywords, _firstImpressionKeywords) &&
            (identical(other.relationshipImpression, relationshipImpression) ||
                other.relationshipImpression == relationshipImpression) &&
            (identical(other.professionalImpression, professionalImpression) ||
                other.professionalImpression == professionalImpression) &&
            (identical(other.romanticImpression, romanticImpression) ||
                other.romanticImpression == romanticImpression) &&
            const DeepCollectionEquality().equals(
                other._improvementSuggestions, _improvementSuggestions) &&
            (identical(other.trustScore, trustScore) ||
                other.trustScore == trustScore) &&
            (identical(other.approachabilityScore, approachabilityScore) ||
                other.approachabilityScore == approachabilityScore) &&
            (identical(other.charismaScore, charismaScore) ||
                other.charismaScore == charismaScore) &&
            (identical(other.overallImpression, overallImpression) ||
                other.overallImpression == overallImpression));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_firstImpressionKeywords),
      relationshipImpression,
      professionalImpression,
      romanticImpression,
      const DeepCollectionEquality().hash(_improvementSuggestions),
      trustScore,
      approachabilityScore,
      charismaScore,
      overallImpression);

  /// Create a copy of ImpressionAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImpressionAnalysisImplCopyWith<_$ImpressionAnalysisImpl> get copyWith =>
      __$$ImpressionAnalysisImplCopyWithImpl<_$ImpressionAnalysisImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImpressionAnalysisImplToJson(
      this,
    );
  }
}

abstract class _ImpressionAnalysis implements ImpressionAnalysis {
  const factory _ImpressionAnalysis(
      {required final List<String> firstImpressionKeywords,
      required final String relationshipImpression,
      required final String professionalImpression,
      final String? romanticImpression,
      final List<String> improvementSuggestions,
      final int trustScore,
      final int approachabilityScore,
      final int charismaScore,
      final String? overallImpression}) = _$ImpressionAnalysisImpl;

  factory _ImpressionAnalysis.fromJson(Map<String, dynamic> json) =
      _$ImpressionAnalysisImpl.fromJson;

  /// 첫인상 키워드 (["따뜻한", "신뢰가 가는", "차분한"])
  @override
  List<String> get firstImpressionKeywords;

  /// 관계에서의 인상 ("친구들에게 편안한 분위기를 주는 편이에요")
  @override
  String get relationshipImpression;

  /// 직장/학교에서의 인상 ("면접관에게 진지한 인상을 줄 수 있어요")
  @override
  String get professionalImpression;

  /// 연애에서의 인상 (여성용: 배우자운, 연애운 관련)
  @override
  String? get romanticImpression;

  /// 인상 개선 팁
  @override
  List<String> get improvementSuggestions;

  /// 신뢰감 점수 (0-100)
  @override
  int get trustScore;

  /// 친근감 점수 (0-100)
  @override
  int get approachabilityScore;

  /// 카리스마 점수 (0-100)
  @override
  int get charismaScore;

  /// 종합 인상 코멘트
  @override
  String? get overallImpression;

  /// Create a copy of ImpressionAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImpressionAnalysisImplCopyWith<_$ImpressionAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EmotionTrend _$EmotionTrendFromJson(Map<String, dynamic> json) {
  return _EmotionTrend.fromJson(json);
}

/// @nodoc
mixin _$EmotionTrend {
  /// 최근 7일간 평균 미소 지수
  double get weeklySmileAverage => throw _privateConstructorUsedError;

  /// 이전 주 대비 미소 변화
  double get smileChange => throw _privateConstructorUsedError;

  /// 가장 많이 나타난 감정 상태
  String get dominantWeeklyEmotion => throw _privateConstructorUsedError;

  /// 감정 트렌드 인사이트
  String get emotionInsight => throw _privateConstructorUsedError;

  /// 일별 감정 데이터
  List<DailyEmotion> get dailyEmotions => throw _privateConstructorUsedError;

  /// Serializes this EmotionTrend to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmotionTrend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmotionTrendCopyWith<EmotionTrend> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmotionTrendCopyWith<$Res> {
  factory $EmotionTrendCopyWith(
          EmotionTrend value, $Res Function(EmotionTrend) then) =
      _$EmotionTrendCopyWithImpl<$Res, EmotionTrend>;
  @useResult
  $Res call(
      {double weeklySmileAverage,
      double smileChange,
      String dominantWeeklyEmotion,
      String emotionInsight,
      List<DailyEmotion> dailyEmotions});
}

/// @nodoc
class _$EmotionTrendCopyWithImpl<$Res, $Val extends EmotionTrend>
    implements $EmotionTrendCopyWith<$Res> {
  _$EmotionTrendCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmotionTrend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weeklySmileAverage = null,
    Object? smileChange = null,
    Object? dominantWeeklyEmotion = null,
    Object? emotionInsight = null,
    Object? dailyEmotions = null,
  }) {
    return _then(_value.copyWith(
      weeklySmileAverage: null == weeklySmileAverage
          ? _value.weeklySmileAverage
          : weeklySmileAverage // ignore: cast_nullable_to_non_nullable
              as double,
      smileChange: null == smileChange
          ? _value.smileChange
          : smileChange // ignore: cast_nullable_to_non_nullable
              as double,
      dominantWeeklyEmotion: null == dominantWeeklyEmotion
          ? _value.dominantWeeklyEmotion
          : dominantWeeklyEmotion // ignore: cast_nullable_to_non_nullable
              as String,
      emotionInsight: null == emotionInsight
          ? _value.emotionInsight
          : emotionInsight // ignore: cast_nullable_to_non_nullable
              as String,
      dailyEmotions: null == dailyEmotions
          ? _value.dailyEmotions
          : dailyEmotions // ignore: cast_nullable_to_non_nullable
              as List<DailyEmotion>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EmotionTrendImplCopyWith<$Res>
    implements $EmotionTrendCopyWith<$Res> {
  factory _$$EmotionTrendImplCopyWith(
          _$EmotionTrendImpl value, $Res Function(_$EmotionTrendImpl) then) =
      __$$EmotionTrendImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double weeklySmileAverage,
      double smileChange,
      String dominantWeeklyEmotion,
      String emotionInsight,
      List<DailyEmotion> dailyEmotions});
}

/// @nodoc
class __$$EmotionTrendImplCopyWithImpl<$Res>
    extends _$EmotionTrendCopyWithImpl<$Res, _$EmotionTrendImpl>
    implements _$$EmotionTrendImplCopyWith<$Res> {
  __$$EmotionTrendImplCopyWithImpl(
      _$EmotionTrendImpl _value, $Res Function(_$EmotionTrendImpl) _then)
      : super(_value, _then);

  /// Create a copy of EmotionTrend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weeklySmileAverage = null,
    Object? smileChange = null,
    Object? dominantWeeklyEmotion = null,
    Object? emotionInsight = null,
    Object? dailyEmotions = null,
  }) {
    return _then(_$EmotionTrendImpl(
      weeklySmileAverage: null == weeklySmileAverage
          ? _value.weeklySmileAverage
          : weeklySmileAverage // ignore: cast_nullable_to_non_nullable
              as double,
      smileChange: null == smileChange
          ? _value.smileChange
          : smileChange // ignore: cast_nullable_to_non_nullable
              as double,
      dominantWeeklyEmotion: null == dominantWeeklyEmotion
          ? _value.dominantWeeklyEmotion
          : dominantWeeklyEmotion // ignore: cast_nullable_to_non_nullable
              as String,
      emotionInsight: null == emotionInsight
          ? _value.emotionInsight
          : emotionInsight // ignore: cast_nullable_to_non_nullable
              as String,
      dailyEmotions: null == dailyEmotions
          ? _value._dailyEmotions
          : dailyEmotions // ignore: cast_nullable_to_non_nullable
              as List<DailyEmotion>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EmotionTrendImpl implements _EmotionTrend {
  const _$EmotionTrendImpl(
      {required this.weeklySmileAverage,
      required this.smileChange,
      required this.dominantWeeklyEmotion,
      required this.emotionInsight,
      final List<DailyEmotion> dailyEmotions = const []})
      : _dailyEmotions = dailyEmotions;

  factory _$EmotionTrendImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmotionTrendImplFromJson(json);

  /// 최근 7일간 평균 미소 지수
  @override
  final double weeklySmileAverage;

  /// 이전 주 대비 미소 변화
  @override
  final double smileChange;

  /// 가장 많이 나타난 감정 상태
  @override
  final String dominantWeeklyEmotion;

  /// 감정 트렌드 인사이트
  @override
  final String emotionInsight;

  /// 일별 감정 데이터
  final List<DailyEmotion> _dailyEmotions;

  /// 일별 감정 데이터
  @override
  @JsonKey()
  List<DailyEmotion> get dailyEmotions {
    if (_dailyEmotions is EqualUnmodifiableListView) return _dailyEmotions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyEmotions);
  }

  @override
  String toString() {
    return 'EmotionTrend(weeklySmileAverage: $weeklySmileAverage, smileChange: $smileChange, dominantWeeklyEmotion: $dominantWeeklyEmotion, emotionInsight: $emotionInsight, dailyEmotions: $dailyEmotions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmotionTrendImpl &&
            (identical(other.weeklySmileAverage, weeklySmileAverage) ||
                other.weeklySmileAverage == weeklySmileAverage) &&
            (identical(other.smileChange, smileChange) ||
                other.smileChange == smileChange) &&
            (identical(other.dominantWeeklyEmotion, dominantWeeklyEmotion) ||
                other.dominantWeeklyEmotion == dominantWeeklyEmotion) &&
            (identical(other.emotionInsight, emotionInsight) ||
                other.emotionInsight == emotionInsight) &&
            const DeepCollectionEquality()
                .equals(other._dailyEmotions, _dailyEmotions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      weeklySmileAverage,
      smileChange,
      dominantWeeklyEmotion,
      emotionInsight,
      const DeepCollectionEquality().hash(_dailyEmotions));

  /// Create a copy of EmotionTrend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmotionTrendImplCopyWith<_$EmotionTrendImpl> get copyWith =>
      __$$EmotionTrendImplCopyWithImpl<_$EmotionTrendImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmotionTrendImplToJson(
      this,
    );
  }
}

abstract class _EmotionTrend implements EmotionTrend {
  const factory _EmotionTrend(
      {required final double weeklySmileAverage,
      required final double smileChange,
      required final String dominantWeeklyEmotion,
      required final String emotionInsight,
      final List<DailyEmotion> dailyEmotions}) = _$EmotionTrendImpl;

  factory _EmotionTrend.fromJson(Map<String, dynamic> json) =
      _$EmotionTrendImpl.fromJson;

  /// 최근 7일간 평균 미소 지수
  @override
  double get weeklySmileAverage;

  /// 이전 주 대비 미소 변화
  @override
  double get smileChange;

  /// 가장 많이 나타난 감정 상태
  @override
  String get dominantWeeklyEmotion;

  /// 감정 트렌드 인사이트
  @override
  String get emotionInsight;

  /// 일별 감정 데이터
  @override
  List<DailyEmotion> get dailyEmotions;

  /// Create a copy of EmotionTrend
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmotionTrendImplCopyWith<_$EmotionTrendImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyEmotion _$DailyEmotionFromJson(Map<String, dynamic> json) {
  return _DailyEmotion.fromJson(json);
}

/// @nodoc
mixin _$DailyEmotion {
  DateTime get date => throw _privateConstructorUsedError;
  double get smilePercentage => throw _privateConstructorUsedError;
  double get tensionPercentage => throw _privateConstructorUsedError;
  double get neutralPercentage => throw _privateConstructorUsedError;
  double get relaxedPercentage => throw _privateConstructorUsedError;
  String get dominantEmotion => throw _privateConstructorUsedError;

  /// Serializes this DailyEmotion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyEmotion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyEmotionCopyWith<DailyEmotion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyEmotionCopyWith<$Res> {
  factory $DailyEmotionCopyWith(
          DailyEmotion value, $Res Function(DailyEmotion) then) =
      _$DailyEmotionCopyWithImpl<$Res, DailyEmotion>;
  @useResult
  $Res call(
      {DateTime date,
      double smilePercentage,
      double tensionPercentage,
      double neutralPercentage,
      double relaxedPercentage,
      String dominantEmotion});
}

/// @nodoc
class _$DailyEmotionCopyWithImpl<$Res, $Val extends DailyEmotion>
    implements $DailyEmotionCopyWith<$Res> {
  _$DailyEmotionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyEmotion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? smilePercentage = null,
    Object? tensionPercentage = null,
    Object? neutralPercentage = null,
    Object? relaxedPercentage = null,
    Object? dominantEmotion = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      smilePercentage: null == smilePercentage
          ? _value.smilePercentage
          : smilePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      tensionPercentage: null == tensionPercentage
          ? _value.tensionPercentage
          : tensionPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      neutralPercentage: null == neutralPercentage
          ? _value.neutralPercentage
          : neutralPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      relaxedPercentage: null == relaxedPercentage
          ? _value.relaxedPercentage
          : relaxedPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      dominantEmotion: null == dominantEmotion
          ? _value.dominantEmotion
          : dominantEmotion // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyEmotionImplCopyWith<$Res>
    implements $DailyEmotionCopyWith<$Res> {
  factory _$$DailyEmotionImplCopyWith(
          _$DailyEmotionImpl value, $Res Function(_$DailyEmotionImpl) then) =
      __$$DailyEmotionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      double smilePercentage,
      double tensionPercentage,
      double neutralPercentage,
      double relaxedPercentage,
      String dominantEmotion});
}

/// @nodoc
class __$$DailyEmotionImplCopyWithImpl<$Res>
    extends _$DailyEmotionCopyWithImpl<$Res, _$DailyEmotionImpl>
    implements _$$DailyEmotionImplCopyWith<$Res> {
  __$$DailyEmotionImplCopyWithImpl(
      _$DailyEmotionImpl _value, $Res Function(_$DailyEmotionImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyEmotion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? smilePercentage = null,
    Object? tensionPercentage = null,
    Object? neutralPercentage = null,
    Object? relaxedPercentage = null,
    Object? dominantEmotion = null,
  }) {
    return _then(_$DailyEmotionImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      smilePercentage: null == smilePercentage
          ? _value.smilePercentage
          : smilePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      tensionPercentage: null == tensionPercentage
          ? _value.tensionPercentage
          : tensionPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      neutralPercentage: null == neutralPercentage
          ? _value.neutralPercentage
          : neutralPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      relaxedPercentage: null == relaxedPercentage
          ? _value.relaxedPercentage
          : relaxedPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      dominantEmotion: null == dominantEmotion
          ? _value.dominantEmotion
          : dominantEmotion // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyEmotionImpl implements _DailyEmotion {
  const _$DailyEmotionImpl(
      {required this.date,
      required this.smilePercentage,
      required this.tensionPercentage,
      required this.neutralPercentage,
      required this.relaxedPercentage,
      required this.dominantEmotion});

  factory _$DailyEmotionImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyEmotionImplFromJson(json);

  @override
  final DateTime date;
  @override
  final double smilePercentage;
  @override
  final double tensionPercentage;
  @override
  final double neutralPercentage;
  @override
  final double relaxedPercentage;
  @override
  final String dominantEmotion;

  @override
  String toString() {
    return 'DailyEmotion(date: $date, smilePercentage: $smilePercentage, tensionPercentage: $tensionPercentage, neutralPercentage: $neutralPercentage, relaxedPercentage: $relaxedPercentage, dominantEmotion: $dominantEmotion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyEmotionImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.smilePercentage, smilePercentage) ||
                other.smilePercentage == smilePercentage) &&
            (identical(other.tensionPercentage, tensionPercentage) ||
                other.tensionPercentage == tensionPercentage) &&
            (identical(other.neutralPercentage, neutralPercentage) ||
                other.neutralPercentage == neutralPercentage) &&
            (identical(other.relaxedPercentage, relaxedPercentage) ||
                other.relaxedPercentage == relaxedPercentage) &&
            (identical(other.dominantEmotion, dominantEmotion) ||
                other.dominantEmotion == dominantEmotion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, smilePercentage,
      tensionPercentage, neutralPercentage, relaxedPercentage, dominantEmotion);

  /// Create a copy of DailyEmotion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyEmotionImplCopyWith<_$DailyEmotionImpl> get copyWith =>
      __$$DailyEmotionImplCopyWithImpl<_$DailyEmotionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyEmotionImplToJson(
      this,
    );
  }
}

abstract class _DailyEmotion implements DailyEmotion {
  const factory _DailyEmotion(
      {required final DateTime date,
      required final double smilePercentage,
      required final double tensionPercentage,
      required final double neutralPercentage,
      required final double relaxedPercentage,
      required final String dominantEmotion}) = _$DailyEmotionImpl;

  factory _DailyEmotion.fromJson(Map<String, dynamic> json) =
      _$DailyEmotionImpl.fromJson;

  @override
  DateTime get date;
  @override
  double get smilePercentage;
  @override
  double get tensionPercentage;
  @override
  double get neutralPercentage;
  @override
  double get relaxedPercentage;
  @override
  String get dominantEmotion;

  /// Create a copy of DailyEmotion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyEmotionImplCopyWith<_$DailyEmotionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
