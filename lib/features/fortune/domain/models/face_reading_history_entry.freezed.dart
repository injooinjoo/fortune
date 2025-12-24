// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'face_reading_history_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FaceReadingHistoryEntry _$FaceReadingHistoryEntryFromJson(
    Map<String, dynamic> json) {
  return _FaceReadingHistoryEntry.fromJson(json);
}

/// @nodoc
mixin _$FaceReadingHistoryEntry {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// 분석 당시 사용자 정보
  String get gender => throw _privateConstructorUsedError; // 'male' | 'female'
  String? get ageGroup =>
      throw _privateConstructorUsedError; // '20s', '30s', etc.
  /// 썸네일 이미지 URL (선택적 - 사용자 동의 시에만)
  String? get thumbnailUrl => throw _privateConstructorUsedError;

  /// 분석 결과 ID (상세 결과 조회용)
  String get resultId => throw _privateConstructorUsedError;

  /// 얼굴 컨디션 스냅샷
  FaceCondition get faceCondition => throw _privateConstructorUsedError;

  /// 감정 분석 스냅샷
  EmotionAnalysis get emotionAnalysis => throw _privateConstructorUsedError;

  /// 핵심 포인트 요약 (3가지)
  List<PriorityInsight> get priorityInsights =>
      throw _privateConstructorUsedError;

  /// 종합 운세 점수 (0-100)
  int get overallFortuneScore => throw _privateConstructorUsedError;

  /// 카테고리별 점수
  CategoryScores get categoryScores => throw _privateConstructorUsedError;

  /// 메모 (사용자가 추가한)
  String? get userNote => throw _privateConstructorUsedError;

  /// 미션 완료 여부
  bool get missionCompleted => throw _privateConstructorUsedError;

  /// Serializes this FaceReadingHistoryEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FaceReadingHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FaceReadingHistoryEntryCopyWith<FaceReadingHistoryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FaceReadingHistoryEntryCopyWith<$Res> {
  factory $FaceReadingHistoryEntryCopyWith(FaceReadingHistoryEntry value,
          $Res Function(FaceReadingHistoryEntry) then) =
      _$FaceReadingHistoryEntryCopyWithImpl<$Res, FaceReadingHistoryEntry>;
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      String gender,
      String? ageGroup,
      String? thumbnailUrl,
      String resultId,
      FaceCondition faceCondition,
      EmotionAnalysis emotionAnalysis,
      List<PriorityInsight> priorityInsights,
      int overallFortuneScore,
      CategoryScores categoryScores,
      String? userNote,
      bool missionCompleted});

  $FaceConditionCopyWith<$Res> get faceCondition;
  $EmotionAnalysisCopyWith<$Res> get emotionAnalysis;
  $CategoryScoresCopyWith<$Res> get categoryScores;
}

/// @nodoc
class _$FaceReadingHistoryEntryCopyWithImpl<$Res,
        $Val extends FaceReadingHistoryEntry>
    implements $FaceReadingHistoryEntryCopyWith<$Res> {
  _$FaceReadingHistoryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FaceReadingHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? createdAt = null,
    Object? gender = null,
    Object? ageGroup = freezed,
    Object? thumbnailUrl = freezed,
    Object? resultId = null,
    Object? faceCondition = null,
    Object? emotionAnalysis = null,
    Object? priorityInsights = null,
    Object? overallFortuneScore = null,
    Object? categoryScores = null,
    Object? userNote = freezed,
    Object? missionCompleted = null,
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
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      ageGroup: freezed == ageGroup
          ? _value.ageGroup
          : ageGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      resultId: null == resultId
          ? _value.resultId
          : resultId // ignore: cast_nullable_to_non_nullable
              as String,
      faceCondition: null == faceCondition
          ? _value.faceCondition
          : faceCondition // ignore: cast_nullable_to_non_nullable
              as FaceCondition,
      emotionAnalysis: null == emotionAnalysis
          ? _value.emotionAnalysis
          : emotionAnalysis // ignore: cast_nullable_to_non_nullable
              as EmotionAnalysis,
      priorityInsights: null == priorityInsights
          ? _value.priorityInsights
          : priorityInsights // ignore: cast_nullable_to_non_nullable
              as List<PriorityInsight>,
      overallFortuneScore: null == overallFortuneScore
          ? _value.overallFortuneScore
          : overallFortuneScore // ignore: cast_nullable_to_non_nullable
              as int,
      categoryScores: null == categoryScores
          ? _value.categoryScores
          : categoryScores // ignore: cast_nullable_to_non_nullable
              as CategoryScores,
      userNote: freezed == userNote
          ? _value.userNote
          : userNote // ignore: cast_nullable_to_non_nullable
              as String?,
      missionCompleted: null == missionCompleted
          ? _value.missionCompleted
          : missionCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of FaceReadingHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FaceConditionCopyWith<$Res> get faceCondition {
    return $FaceConditionCopyWith<$Res>(_value.faceCondition, (value) {
      return _then(_value.copyWith(faceCondition: value) as $Val);
    });
  }

  /// Create a copy of FaceReadingHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EmotionAnalysisCopyWith<$Res> get emotionAnalysis {
    return $EmotionAnalysisCopyWith<$Res>(_value.emotionAnalysis, (value) {
      return _then(_value.copyWith(emotionAnalysis: value) as $Val);
    });
  }

  /// Create a copy of FaceReadingHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryScoresCopyWith<$Res> get categoryScores {
    return $CategoryScoresCopyWith<$Res>(_value.categoryScores, (value) {
      return _then(_value.copyWith(categoryScores: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FaceReadingHistoryEntryImplCopyWith<$Res>
    implements $FaceReadingHistoryEntryCopyWith<$Res> {
  factory _$$FaceReadingHistoryEntryImplCopyWith(
          _$FaceReadingHistoryEntryImpl value,
          $Res Function(_$FaceReadingHistoryEntryImpl) then) =
      __$$FaceReadingHistoryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      String gender,
      String? ageGroup,
      String? thumbnailUrl,
      String resultId,
      FaceCondition faceCondition,
      EmotionAnalysis emotionAnalysis,
      List<PriorityInsight> priorityInsights,
      int overallFortuneScore,
      CategoryScores categoryScores,
      String? userNote,
      bool missionCompleted});

  @override
  $FaceConditionCopyWith<$Res> get faceCondition;
  @override
  $EmotionAnalysisCopyWith<$Res> get emotionAnalysis;
  @override
  $CategoryScoresCopyWith<$Res> get categoryScores;
}

/// @nodoc
class __$$FaceReadingHistoryEntryImplCopyWithImpl<$Res>
    extends _$FaceReadingHistoryEntryCopyWithImpl<$Res,
        _$FaceReadingHistoryEntryImpl>
    implements _$$FaceReadingHistoryEntryImplCopyWith<$Res> {
  __$$FaceReadingHistoryEntryImplCopyWithImpl(
      _$FaceReadingHistoryEntryImpl _value,
      $Res Function(_$FaceReadingHistoryEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of FaceReadingHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? createdAt = null,
    Object? gender = null,
    Object? ageGroup = freezed,
    Object? thumbnailUrl = freezed,
    Object? resultId = null,
    Object? faceCondition = null,
    Object? emotionAnalysis = null,
    Object? priorityInsights = null,
    Object? overallFortuneScore = null,
    Object? categoryScores = null,
    Object? userNote = freezed,
    Object? missionCompleted = null,
  }) {
    return _then(_$FaceReadingHistoryEntryImpl(
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
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      ageGroup: freezed == ageGroup
          ? _value.ageGroup
          : ageGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      resultId: null == resultId
          ? _value.resultId
          : resultId // ignore: cast_nullable_to_non_nullable
              as String,
      faceCondition: null == faceCondition
          ? _value.faceCondition
          : faceCondition // ignore: cast_nullable_to_non_nullable
              as FaceCondition,
      emotionAnalysis: null == emotionAnalysis
          ? _value.emotionAnalysis
          : emotionAnalysis // ignore: cast_nullable_to_non_nullable
              as EmotionAnalysis,
      priorityInsights: null == priorityInsights
          ? _value._priorityInsights
          : priorityInsights // ignore: cast_nullable_to_non_nullable
              as List<PriorityInsight>,
      overallFortuneScore: null == overallFortuneScore
          ? _value.overallFortuneScore
          : overallFortuneScore // ignore: cast_nullable_to_non_nullable
              as int,
      categoryScores: null == categoryScores
          ? _value.categoryScores
          : categoryScores // ignore: cast_nullable_to_non_nullable
              as CategoryScores,
      userNote: freezed == userNote
          ? _value.userNote
          : userNote // ignore: cast_nullable_to_non_nullable
              as String?,
      missionCompleted: null == missionCompleted
          ? _value.missionCompleted
          : missionCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FaceReadingHistoryEntryImpl implements _FaceReadingHistoryEntry {
  const _$FaceReadingHistoryEntryImpl(
      {required this.id,
      required this.userId,
      required this.createdAt,
      required this.gender,
      this.ageGroup,
      this.thumbnailUrl,
      required this.resultId,
      required this.faceCondition,
      required this.emotionAnalysis,
      required final List<PriorityInsight> priorityInsights,
      required this.overallFortuneScore,
      required this.categoryScores,
      this.userNote,
      this.missionCompleted = false})
      : _priorityInsights = priorityInsights;

  factory _$FaceReadingHistoryEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$FaceReadingHistoryEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime createdAt;

  /// 분석 당시 사용자 정보
  @override
  final String gender;
// 'male' | 'female'
  @override
  final String? ageGroup;
// '20s', '30s', etc.
  /// 썸네일 이미지 URL (선택적 - 사용자 동의 시에만)
  @override
  final String? thumbnailUrl;

  /// 분석 결과 ID (상세 결과 조회용)
  @override
  final String resultId;

  /// 얼굴 컨디션 스냅샷
  @override
  final FaceCondition faceCondition;

  /// 감정 분석 스냅샷
  @override
  final EmotionAnalysis emotionAnalysis;

  /// 핵심 포인트 요약 (3가지)
  final List<PriorityInsight> _priorityInsights;

  /// 핵심 포인트 요약 (3가지)
  @override
  List<PriorityInsight> get priorityInsights {
    if (_priorityInsights is EqualUnmodifiableListView)
      return _priorityInsights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_priorityInsights);
  }

  /// 종합 운세 점수 (0-100)
  @override
  final int overallFortuneScore;

  /// 카테고리별 점수
  @override
  final CategoryScores categoryScores;

  /// 메모 (사용자가 추가한)
  @override
  final String? userNote;

  /// 미션 완료 여부
  @override
  @JsonKey()
  final bool missionCompleted;

  @override
  String toString() {
    return 'FaceReadingHistoryEntry(id: $id, userId: $userId, createdAt: $createdAt, gender: $gender, ageGroup: $ageGroup, thumbnailUrl: $thumbnailUrl, resultId: $resultId, faceCondition: $faceCondition, emotionAnalysis: $emotionAnalysis, priorityInsights: $priorityInsights, overallFortuneScore: $overallFortuneScore, categoryScores: $categoryScores, userNote: $userNote, missionCompleted: $missionCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FaceReadingHistoryEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.ageGroup, ageGroup) ||
                other.ageGroup == ageGroup) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.resultId, resultId) ||
                other.resultId == resultId) &&
            (identical(other.faceCondition, faceCondition) ||
                other.faceCondition == faceCondition) &&
            (identical(other.emotionAnalysis, emotionAnalysis) ||
                other.emotionAnalysis == emotionAnalysis) &&
            const DeepCollectionEquality()
                .equals(other._priorityInsights, _priorityInsights) &&
            (identical(other.overallFortuneScore, overallFortuneScore) ||
                other.overallFortuneScore == overallFortuneScore) &&
            (identical(other.categoryScores, categoryScores) ||
                other.categoryScores == categoryScores) &&
            (identical(other.userNote, userNote) ||
                other.userNote == userNote) &&
            (identical(other.missionCompleted, missionCompleted) ||
                other.missionCompleted == missionCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      createdAt,
      gender,
      ageGroup,
      thumbnailUrl,
      resultId,
      faceCondition,
      emotionAnalysis,
      const DeepCollectionEquality().hash(_priorityInsights),
      overallFortuneScore,
      categoryScores,
      userNote,
      missionCompleted);

  /// Create a copy of FaceReadingHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FaceReadingHistoryEntryImplCopyWith<_$FaceReadingHistoryEntryImpl>
      get copyWith => __$$FaceReadingHistoryEntryImplCopyWithImpl<
          _$FaceReadingHistoryEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FaceReadingHistoryEntryImplToJson(
      this,
    );
  }
}

abstract class _FaceReadingHistoryEntry implements FaceReadingHistoryEntry {
  const factory _FaceReadingHistoryEntry(
      {required final String id,
      required final String userId,
      required final DateTime createdAt,
      required final String gender,
      final String? ageGroup,
      final String? thumbnailUrl,
      required final String resultId,
      required final FaceCondition faceCondition,
      required final EmotionAnalysis emotionAnalysis,
      required final List<PriorityInsight> priorityInsights,
      required final int overallFortuneScore,
      required final CategoryScores categoryScores,
      final String? userNote,
      final bool missionCompleted}) = _$FaceReadingHistoryEntryImpl;

  factory _FaceReadingHistoryEntry.fromJson(Map<String, dynamic> json) =
      _$FaceReadingHistoryEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  DateTime get createdAt;

  /// 분석 당시 사용자 정보
  @override
  String get gender; // 'male' | 'female'
  @override
  String? get ageGroup; // '20s', '30s', etc.
  /// 썸네일 이미지 URL (선택적 - 사용자 동의 시에만)
  @override
  String? get thumbnailUrl;

  /// 분석 결과 ID (상세 결과 조회용)
  @override
  String get resultId;

  /// 얼굴 컨디션 스냅샷
  @override
  FaceCondition get faceCondition;

  /// 감정 분석 스냅샷
  @override
  EmotionAnalysis get emotionAnalysis;

  /// 핵심 포인트 요약 (3가지)
  @override
  List<PriorityInsight> get priorityInsights;

  /// 종합 운세 점수 (0-100)
  @override
  int get overallFortuneScore;

  /// 카테고리별 점수
  @override
  CategoryScores get categoryScores;

  /// 메모 (사용자가 추가한)
  @override
  String? get userNote;

  /// 미션 완료 여부
  @override
  bool get missionCompleted;

  /// Create a copy of FaceReadingHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FaceReadingHistoryEntryImplCopyWith<_$FaceReadingHistoryEntryImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PriorityInsight _$PriorityInsightFromJson(Map<String, dynamic> json) {
  return _PriorityInsight.fromJson(json);
}

/// @nodoc
mixin _$PriorityInsight {
  /// 인사이트 카테고리 (love, career, relationship, health, wealth)
  String get category => throw _privateConstructorUsedError;

  /// 카테고리 라벨 (연애운, 직업운, 인간관계, 건강, 재물)
  String get categoryLabel => throw _privateConstructorUsedError;

  /// 핵심 메시지 (친근한 말투)
  String get message => throw _privateConstructorUsedError;

  /// 점수 (0-100)
  int get score => throw _privateConstructorUsedError;

  /// 아이콘 이모지
  String get emoji => throw _privateConstructorUsedError;

  /// 관련 얼굴 부위 (눈, 코, 입술 등)
  String? get relatedFeature => throw _privateConstructorUsedError;

  /// Serializes this PriorityInsight to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PriorityInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriorityInsightCopyWith<PriorityInsight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriorityInsightCopyWith<$Res> {
  factory $PriorityInsightCopyWith(
          PriorityInsight value, $Res Function(PriorityInsight) then) =
      _$PriorityInsightCopyWithImpl<$Res, PriorityInsight>;
  @useResult
  $Res call(
      {String category,
      String categoryLabel,
      String message,
      int score,
      String emoji,
      String? relatedFeature});
}

/// @nodoc
class _$PriorityInsightCopyWithImpl<$Res, $Val extends PriorityInsight>
    implements $PriorityInsightCopyWith<$Res> {
  _$PriorityInsightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriorityInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? categoryLabel = null,
    Object? message = null,
    Object? score = null,
    Object? emoji = null,
    Object? relatedFeature = freezed,
  }) {
    return _then(_value.copyWith(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      categoryLabel: null == categoryLabel
          ? _value.categoryLabel
          : categoryLabel // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      relatedFeature: freezed == relatedFeature
          ? _value.relatedFeature
          : relatedFeature // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PriorityInsightImplCopyWith<$Res>
    implements $PriorityInsightCopyWith<$Res> {
  factory _$$PriorityInsightImplCopyWith(_$PriorityInsightImpl value,
          $Res Function(_$PriorityInsightImpl) then) =
      __$$PriorityInsightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String category,
      String categoryLabel,
      String message,
      int score,
      String emoji,
      String? relatedFeature});
}

/// @nodoc
class __$$PriorityInsightImplCopyWithImpl<$Res>
    extends _$PriorityInsightCopyWithImpl<$Res, _$PriorityInsightImpl>
    implements _$$PriorityInsightImplCopyWith<$Res> {
  __$$PriorityInsightImplCopyWithImpl(
      _$PriorityInsightImpl _value, $Res Function(_$PriorityInsightImpl) _then)
      : super(_value, _then);

  /// Create a copy of PriorityInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? categoryLabel = null,
    Object? message = null,
    Object? score = null,
    Object? emoji = null,
    Object? relatedFeature = freezed,
  }) {
    return _then(_$PriorityInsightImpl(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      categoryLabel: null == categoryLabel
          ? _value.categoryLabel
          : categoryLabel // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      relatedFeature: freezed == relatedFeature
          ? _value.relatedFeature
          : relatedFeature // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PriorityInsightImpl implements _PriorityInsight {
  const _$PriorityInsightImpl(
      {required this.category,
      required this.categoryLabel,
      required this.message,
      required this.score,
      this.emoji = '✨',
      this.relatedFeature});

  factory _$PriorityInsightImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriorityInsightImplFromJson(json);

  /// 인사이트 카테고리 (love, career, relationship, health, wealth)
  @override
  final String category;

  /// 카테고리 라벨 (연애운, 직업운, 인간관계, 건강, 재물)
  @override
  final String categoryLabel;

  /// 핵심 메시지 (친근한 말투)
  @override
  final String message;

  /// 점수 (0-100)
  @override
  final int score;

  /// 아이콘 이모지
  @override
  @JsonKey()
  final String emoji;

  /// 관련 얼굴 부위 (눈, 코, 입술 등)
  @override
  final String? relatedFeature;

  @override
  String toString() {
    return 'PriorityInsight(category: $category, categoryLabel: $categoryLabel, message: $message, score: $score, emoji: $emoji, relatedFeature: $relatedFeature)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriorityInsightImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.categoryLabel, categoryLabel) ||
                other.categoryLabel == categoryLabel) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.relatedFeature, relatedFeature) ||
                other.relatedFeature == relatedFeature));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, category, categoryLabel, message,
      score, emoji, relatedFeature);

  /// Create a copy of PriorityInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriorityInsightImplCopyWith<_$PriorityInsightImpl> get copyWith =>
      __$$PriorityInsightImplCopyWithImpl<_$PriorityInsightImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PriorityInsightImplToJson(
      this,
    );
  }
}

abstract class _PriorityInsight implements PriorityInsight {
  const factory _PriorityInsight(
      {required final String category,
      required final String categoryLabel,
      required final String message,
      required final int score,
      final String emoji,
      final String? relatedFeature}) = _$PriorityInsightImpl;

  factory _PriorityInsight.fromJson(Map<String, dynamic> json) =
      _$PriorityInsightImpl.fromJson;

  /// 인사이트 카테고리 (love, career, relationship, health, wealth)
  @override
  String get category;

  /// 카테고리 라벨 (연애운, 직업운, 인간관계, 건강, 재물)
  @override
  String get categoryLabel;

  /// 핵심 메시지 (친근한 말투)
  @override
  String get message;

  /// 점수 (0-100)
  @override
  int get score;

  /// 아이콘 이모지
  @override
  String get emoji;

  /// 관련 얼굴 부위 (눈, 코, 입술 등)
  @override
  String? get relatedFeature;

  /// Create a copy of PriorityInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriorityInsightImplCopyWith<_$PriorityInsightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CategoryScores _$CategoryScoresFromJson(Map<String, dynamic> json) {
  return _CategoryScores.fromJson(json);
}

/// @nodoc
mixin _$CategoryScores {
  /// 연애운 (여성 중점)
  int get loveScore => throw _privateConstructorUsedError;

  /// 결혼운/배우자운 (여성 중점)
  int get marriageScore => throw _privateConstructorUsedError;

  /// 인간관계
  int get relationshipScore => throw _privateConstructorUsedError;

  /// 직업운/리더십 (남성 중점)
  int get careerScore => throw _privateConstructorUsedError;

  /// 재물운
  int get wealthScore => throw _privateConstructorUsedError;

  /// 건강운
  int get healthScore => throw _privateConstructorUsedError;

  /// 첫인상/면접 운
  int get impressionScore => throw _privateConstructorUsedError;

  /// Serializes this CategoryScores to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategoryScores
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryScoresCopyWith<CategoryScores> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryScoresCopyWith<$Res> {
  factory $CategoryScoresCopyWith(
          CategoryScores value, $Res Function(CategoryScores) then) =
      _$CategoryScoresCopyWithImpl<$Res, CategoryScores>;
  @useResult
  $Res call(
      {int loveScore,
      int marriageScore,
      int relationshipScore,
      int careerScore,
      int wealthScore,
      int healthScore,
      int impressionScore});
}

/// @nodoc
class _$CategoryScoresCopyWithImpl<$Res, $Val extends CategoryScores>
    implements $CategoryScoresCopyWith<$Res> {
  _$CategoryScoresCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategoryScores
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loveScore = null,
    Object? marriageScore = null,
    Object? relationshipScore = null,
    Object? careerScore = null,
    Object? wealthScore = null,
    Object? healthScore = null,
    Object? impressionScore = null,
  }) {
    return _then(_value.copyWith(
      loveScore: null == loveScore
          ? _value.loveScore
          : loveScore // ignore: cast_nullable_to_non_nullable
              as int,
      marriageScore: null == marriageScore
          ? _value.marriageScore
          : marriageScore // ignore: cast_nullable_to_non_nullable
              as int,
      relationshipScore: null == relationshipScore
          ? _value.relationshipScore
          : relationshipScore // ignore: cast_nullable_to_non_nullable
              as int,
      careerScore: null == careerScore
          ? _value.careerScore
          : careerScore // ignore: cast_nullable_to_non_nullable
              as int,
      wealthScore: null == wealthScore
          ? _value.wealthScore
          : wealthScore // ignore: cast_nullable_to_non_nullable
              as int,
      healthScore: null == healthScore
          ? _value.healthScore
          : healthScore // ignore: cast_nullable_to_non_nullable
              as int,
      impressionScore: null == impressionScore
          ? _value.impressionScore
          : impressionScore // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategoryScoresImplCopyWith<$Res>
    implements $CategoryScoresCopyWith<$Res> {
  factory _$$CategoryScoresImplCopyWith(_$CategoryScoresImpl value,
          $Res Function(_$CategoryScoresImpl) then) =
      __$$CategoryScoresImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int loveScore,
      int marriageScore,
      int relationshipScore,
      int careerScore,
      int wealthScore,
      int healthScore,
      int impressionScore});
}

/// @nodoc
class __$$CategoryScoresImplCopyWithImpl<$Res>
    extends _$CategoryScoresCopyWithImpl<$Res, _$CategoryScoresImpl>
    implements _$$CategoryScoresImplCopyWith<$Res> {
  __$$CategoryScoresImplCopyWithImpl(
      _$CategoryScoresImpl _value, $Res Function(_$CategoryScoresImpl) _then)
      : super(_value, _then);

  /// Create a copy of CategoryScores
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loveScore = null,
    Object? marriageScore = null,
    Object? relationshipScore = null,
    Object? careerScore = null,
    Object? wealthScore = null,
    Object? healthScore = null,
    Object? impressionScore = null,
  }) {
    return _then(_$CategoryScoresImpl(
      loveScore: null == loveScore
          ? _value.loveScore
          : loveScore // ignore: cast_nullable_to_non_nullable
              as int,
      marriageScore: null == marriageScore
          ? _value.marriageScore
          : marriageScore // ignore: cast_nullable_to_non_nullable
              as int,
      relationshipScore: null == relationshipScore
          ? _value.relationshipScore
          : relationshipScore // ignore: cast_nullable_to_non_nullable
              as int,
      careerScore: null == careerScore
          ? _value.careerScore
          : careerScore // ignore: cast_nullable_to_non_nullable
              as int,
      wealthScore: null == wealthScore
          ? _value.wealthScore
          : wealthScore // ignore: cast_nullable_to_non_nullable
              as int,
      healthScore: null == healthScore
          ? _value.healthScore
          : healthScore // ignore: cast_nullable_to_non_nullable
              as int,
      impressionScore: null == impressionScore
          ? _value.impressionScore
          : impressionScore // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryScoresImpl implements _CategoryScores {
  const _$CategoryScoresImpl(
      {required this.loveScore,
      required this.marriageScore,
      required this.relationshipScore,
      required this.careerScore,
      required this.wealthScore,
      required this.healthScore,
      required this.impressionScore});

  factory _$CategoryScoresImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryScoresImplFromJson(json);

  /// 연애운 (여성 중점)
  @override
  final int loveScore;

  /// 결혼운/배우자운 (여성 중점)
  @override
  final int marriageScore;

  /// 인간관계
  @override
  final int relationshipScore;

  /// 직업운/리더십 (남성 중점)
  @override
  final int careerScore;

  /// 재물운
  @override
  final int wealthScore;

  /// 건강운
  @override
  final int healthScore;

  /// 첫인상/면접 운
  @override
  final int impressionScore;

  @override
  String toString() {
    return 'CategoryScores(loveScore: $loveScore, marriageScore: $marriageScore, relationshipScore: $relationshipScore, careerScore: $careerScore, wealthScore: $wealthScore, healthScore: $healthScore, impressionScore: $impressionScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryScoresImpl &&
            (identical(other.loveScore, loveScore) ||
                other.loveScore == loveScore) &&
            (identical(other.marriageScore, marriageScore) ||
                other.marriageScore == marriageScore) &&
            (identical(other.relationshipScore, relationshipScore) ||
                other.relationshipScore == relationshipScore) &&
            (identical(other.careerScore, careerScore) ||
                other.careerScore == careerScore) &&
            (identical(other.wealthScore, wealthScore) ||
                other.wealthScore == wealthScore) &&
            (identical(other.healthScore, healthScore) ||
                other.healthScore == healthScore) &&
            (identical(other.impressionScore, impressionScore) ||
                other.impressionScore == impressionScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      loveScore,
      marriageScore,
      relationshipScore,
      careerScore,
      wealthScore,
      healthScore,
      impressionScore);

  /// Create a copy of CategoryScores
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryScoresImplCopyWith<_$CategoryScoresImpl> get copyWith =>
      __$$CategoryScoresImplCopyWithImpl<_$CategoryScoresImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryScoresImplToJson(
      this,
    );
  }
}

abstract class _CategoryScores implements CategoryScores {
  const factory _CategoryScores(
      {required final int loveScore,
      required final int marriageScore,
      required final int relationshipScore,
      required final int careerScore,
      required final int wealthScore,
      required final int healthScore,
      required final int impressionScore}) = _$CategoryScoresImpl;

  factory _CategoryScores.fromJson(Map<String, dynamic> json) =
      _$CategoryScoresImpl.fromJson;

  /// 연애운 (여성 중점)
  @override
  int get loveScore;

  /// 결혼운/배우자운 (여성 중점)
  @override
  int get marriageScore;

  /// 인간관계
  @override
  int get relationshipScore;

  /// 직업운/리더십 (남성 중점)
  @override
  int get careerScore;

  /// 재물운
  @override
  int get wealthScore;

  /// 건강운
  @override
  int get healthScore;

  /// 첫인상/면접 운
  @override
  int get impressionScore;

  /// Create a copy of CategoryScores
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryScoresImplCopyWith<_$CategoryScoresImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HistoryComparison _$HistoryComparisonFromJson(Map<String, dynamic> json) {
  return _HistoryComparison.fromJson(json);
}

/// @nodoc
mixin _$HistoryComparison {
  /// 비교 대상 날짜 1
  DateTime get date1 => throw _privateConstructorUsedError;

  /// 비교 대상 날짜 2
  DateTime get date2 => throw _privateConstructorUsedError;

  /// 컨디션 변화
  ConditionChange get conditionChange => throw _privateConstructorUsedError;

  /// 감정 변화
  EmotionChange get emotionChange => throw _privateConstructorUsedError;

  /// 카테고리별 점수 변화
  ScoreChanges get scoreChanges => throw _privateConstructorUsedError;

  /// 비교 인사이트 ("지난달보다 미소가 더 자연스러워졌어요")
  String get comparisonInsight => throw _privateConstructorUsedError;

  /// Serializes this HistoryComparison to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HistoryComparison
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HistoryComparisonCopyWith<HistoryComparison> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HistoryComparisonCopyWith<$Res> {
  factory $HistoryComparisonCopyWith(
          HistoryComparison value, $Res Function(HistoryComparison) then) =
      _$HistoryComparisonCopyWithImpl<$Res, HistoryComparison>;
  @useResult
  $Res call(
      {DateTime date1,
      DateTime date2,
      ConditionChange conditionChange,
      EmotionChange emotionChange,
      ScoreChanges scoreChanges,
      String comparisonInsight});

  $ConditionChangeCopyWith<$Res> get conditionChange;
  $EmotionChangeCopyWith<$Res> get emotionChange;
  $ScoreChangesCopyWith<$Res> get scoreChanges;
}

/// @nodoc
class _$HistoryComparisonCopyWithImpl<$Res, $Val extends HistoryComparison>
    implements $HistoryComparisonCopyWith<$Res> {
  _$HistoryComparisonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HistoryComparison
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date1 = null,
    Object? date2 = null,
    Object? conditionChange = null,
    Object? emotionChange = null,
    Object? scoreChanges = null,
    Object? comparisonInsight = null,
  }) {
    return _then(_value.copyWith(
      date1: null == date1
          ? _value.date1
          : date1 // ignore: cast_nullable_to_non_nullable
              as DateTime,
      date2: null == date2
          ? _value.date2
          : date2 // ignore: cast_nullable_to_non_nullable
              as DateTime,
      conditionChange: null == conditionChange
          ? _value.conditionChange
          : conditionChange // ignore: cast_nullable_to_non_nullable
              as ConditionChange,
      emotionChange: null == emotionChange
          ? _value.emotionChange
          : emotionChange // ignore: cast_nullable_to_non_nullable
              as EmotionChange,
      scoreChanges: null == scoreChanges
          ? _value.scoreChanges
          : scoreChanges // ignore: cast_nullable_to_non_nullable
              as ScoreChanges,
      comparisonInsight: null == comparisonInsight
          ? _value.comparisonInsight
          : comparisonInsight // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  /// Create a copy of HistoryComparison
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConditionChangeCopyWith<$Res> get conditionChange {
    return $ConditionChangeCopyWith<$Res>(_value.conditionChange, (value) {
      return _then(_value.copyWith(conditionChange: value) as $Val);
    });
  }

  /// Create a copy of HistoryComparison
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EmotionChangeCopyWith<$Res> get emotionChange {
    return $EmotionChangeCopyWith<$Res>(_value.emotionChange, (value) {
      return _then(_value.copyWith(emotionChange: value) as $Val);
    });
  }

  /// Create a copy of HistoryComparison
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScoreChangesCopyWith<$Res> get scoreChanges {
    return $ScoreChangesCopyWith<$Res>(_value.scoreChanges, (value) {
      return _then(_value.copyWith(scoreChanges: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HistoryComparisonImplCopyWith<$Res>
    implements $HistoryComparisonCopyWith<$Res> {
  factory _$$HistoryComparisonImplCopyWith(_$HistoryComparisonImpl value,
          $Res Function(_$HistoryComparisonImpl) then) =
      __$$HistoryComparisonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date1,
      DateTime date2,
      ConditionChange conditionChange,
      EmotionChange emotionChange,
      ScoreChanges scoreChanges,
      String comparisonInsight});

  @override
  $ConditionChangeCopyWith<$Res> get conditionChange;
  @override
  $EmotionChangeCopyWith<$Res> get emotionChange;
  @override
  $ScoreChangesCopyWith<$Res> get scoreChanges;
}

/// @nodoc
class __$$HistoryComparisonImplCopyWithImpl<$Res>
    extends _$HistoryComparisonCopyWithImpl<$Res, _$HistoryComparisonImpl>
    implements _$$HistoryComparisonImplCopyWith<$Res> {
  __$$HistoryComparisonImplCopyWithImpl(_$HistoryComparisonImpl _value,
      $Res Function(_$HistoryComparisonImpl) _then)
      : super(_value, _then);

  /// Create a copy of HistoryComparison
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date1 = null,
    Object? date2 = null,
    Object? conditionChange = null,
    Object? emotionChange = null,
    Object? scoreChanges = null,
    Object? comparisonInsight = null,
  }) {
    return _then(_$HistoryComparisonImpl(
      date1: null == date1
          ? _value.date1
          : date1 // ignore: cast_nullable_to_non_nullable
              as DateTime,
      date2: null == date2
          ? _value.date2
          : date2 // ignore: cast_nullable_to_non_nullable
              as DateTime,
      conditionChange: null == conditionChange
          ? _value.conditionChange
          : conditionChange // ignore: cast_nullable_to_non_nullable
              as ConditionChange,
      emotionChange: null == emotionChange
          ? _value.emotionChange
          : emotionChange // ignore: cast_nullable_to_non_nullable
              as EmotionChange,
      scoreChanges: null == scoreChanges
          ? _value.scoreChanges
          : scoreChanges // ignore: cast_nullable_to_non_nullable
              as ScoreChanges,
      comparisonInsight: null == comparisonInsight
          ? _value.comparisonInsight
          : comparisonInsight // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HistoryComparisonImpl implements _HistoryComparison {
  const _$HistoryComparisonImpl(
      {required this.date1,
      required this.date2,
      required this.conditionChange,
      required this.emotionChange,
      required this.scoreChanges,
      required this.comparisonInsight});

  factory _$HistoryComparisonImpl.fromJson(Map<String, dynamic> json) =>
      _$$HistoryComparisonImplFromJson(json);

  /// 비교 대상 날짜 1
  @override
  final DateTime date1;

  /// 비교 대상 날짜 2
  @override
  final DateTime date2;

  /// 컨디션 변화
  @override
  final ConditionChange conditionChange;

  /// 감정 변화
  @override
  final EmotionChange emotionChange;

  /// 카테고리별 점수 변화
  @override
  final ScoreChanges scoreChanges;

  /// 비교 인사이트 ("지난달보다 미소가 더 자연스러워졌어요")
  @override
  final String comparisonInsight;

  @override
  String toString() {
    return 'HistoryComparison(date1: $date1, date2: $date2, conditionChange: $conditionChange, emotionChange: $emotionChange, scoreChanges: $scoreChanges, comparisonInsight: $comparisonInsight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HistoryComparisonImpl &&
            (identical(other.date1, date1) || other.date1 == date1) &&
            (identical(other.date2, date2) || other.date2 == date2) &&
            (identical(other.conditionChange, conditionChange) ||
                other.conditionChange == conditionChange) &&
            (identical(other.emotionChange, emotionChange) ||
                other.emotionChange == emotionChange) &&
            (identical(other.scoreChanges, scoreChanges) ||
                other.scoreChanges == scoreChanges) &&
            (identical(other.comparisonInsight, comparisonInsight) ||
                other.comparisonInsight == comparisonInsight));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date1, date2, conditionChange,
      emotionChange, scoreChanges, comparisonInsight);

  /// Create a copy of HistoryComparison
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HistoryComparisonImplCopyWith<_$HistoryComparisonImpl> get copyWith =>
      __$$HistoryComparisonImplCopyWithImpl<_$HistoryComparisonImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HistoryComparisonImplToJson(
      this,
    );
  }
}

abstract class _HistoryComparison implements HistoryComparison {
  const factory _HistoryComparison(
      {required final DateTime date1,
      required final DateTime date2,
      required final ConditionChange conditionChange,
      required final EmotionChange emotionChange,
      required final ScoreChanges scoreChanges,
      required final String comparisonInsight}) = _$HistoryComparisonImpl;

  factory _HistoryComparison.fromJson(Map<String, dynamic> json) =
      _$HistoryComparisonImpl.fromJson;

  /// 비교 대상 날짜 1
  @override
  DateTime get date1;

  /// 비교 대상 날짜 2
  @override
  DateTime get date2;

  /// 컨디션 변화
  @override
  ConditionChange get conditionChange;

  /// 감정 변화
  @override
  EmotionChange get emotionChange;

  /// 카테고리별 점수 변화
  @override
  ScoreChanges get scoreChanges;

  /// 비교 인사이트 ("지난달보다 미소가 더 자연스러워졌어요")
  @override
  String get comparisonInsight;

  /// Create a copy of HistoryComparison
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HistoryComparisonImplCopyWith<_$HistoryComparisonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConditionChange _$ConditionChangeFromJson(Map<String, dynamic> json) {
  return _ConditionChange.fromJson(json);
}

/// @nodoc
mixin _$ConditionChange {
  int get complexionChange => throw _privateConstructorUsedError;
  int get puffinessChange => throw _privateConstructorUsedError;
  int get fatigueChange => throw _privateConstructorUsedError;
  int get overallChange => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;

  /// Serializes this ConditionChange to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConditionChange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConditionChangeCopyWith<ConditionChange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConditionChangeCopyWith<$Res> {
  factory $ConditionChangeCopyWith(
          ConditionChange value, $Res Function(ConditionChange) then) =
      _$ConditionChangeCopyWithImpl<$Res, ConditionChange>;
  @useResult
  $Res call(
      {int complexionChange,
      int puffinessChange,
      int fatigueChange,
      int overallChange,
      String summary});
}

/// @nodoc
class _$ConditionChangeCopyWithImpl<$Res, $Val extends ConditionChange>
    implements $ConditionChangeCopyWith<$Res> {
  _$ConditionChangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConditionChange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? complexionChange = null,
    Object? puffinessChange = null,
    Object? fatigueChange = null,
    Object? overallChange = null,
    Object? summary = null,
  }) {
    return _then(_value.copyWith(
      complexionChange: null == complexionChange
          ? _value.complexionChange
          : complexionChange // ignore: cast_nullable_to_non_nullable
              as int,
      puffinessChange: null == puffinessChange
          ? _value.puffinessChange
          : puffinessChange // ignore: cast_nullable_to_non_nullable
              as int,
      fatigueChange: null == fatigueChange
          ? _value.fatigueChange
          : fatigueChange // ignore: cast_nullable_to_non_nullable
              as int,
      overallChange: null == overallChange
          ? _value.overallChange
          : overallChange // ignore: cast_nullable_to_non_nullable
              as int,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConditionChangeImplCopyWith<$Res>
    implements $ConditionChangeCopyWith<$Res> {
  factory _$$ConditionChangeImplCopyWith(_$ConditionChangeImpl value,
          $Res Function(_$ConditionChangeImpl) then) =
      __$$ConditionChangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int complexionChange,
      int puffinessChange,
      int fatigueChange,
      int overallChange,
      String summary});
}

/// @nodoc
class __$$ConditionChangeImplCopyWithImpl<$Res>
    extends _$ConditionChangeCopyWithImpl<$Res, _$ConditionChangeImpl>
    implements _$$ConditionChangeImplCopyWith<$Res> {
  __$$ConditionChangeImplCopyWithImpl(
      _$ConditionChangeImpl _value, $Res Function(_$ConditionChangeImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConditionChange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? complexionChange = null,
    Object? puffinessChange = null,
    Object? fatigueChange = null,
    Object? overallChange = null,
    Object? summary = null,
  }) {
    return _then(_$ConditionChangeImpl(
      complexionChange: null == complexionChange
          ? _value.complexionChange
          : complexionChange // ignore: cast_nullable_to_non_nullable
              as int,
      puffinessChange: null == puffinessChange
          ? _value.puffinessChange
          : puffinessChange // ignore: cast_nullable_to_non_nullable
              as int,
      fatigueChange: null == fatigueChange
          ? _value.fatigueChange
          : fatigueChange // ignore: cast_nullable_to_non_nullable
              as int,
      overallChange: null == overallChange
          ? _value.overallChange
          : overallChange // ignore: cast_nullable_to_non_nullable
              as int,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConditionChangeImpl implements _ConditionChange {
  const _$ConditionChangeImpl(
      {required this.complexionChange,
      required this.puffinessChange,
      required this.fatigueChange,
      required this.overallChange,
      required this.summary});

  factory _$ConditionChangeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConditionChangeImplFromJson(json);

  @override
  final int complexionChange;
  @override
  final int puffinessChange;
  @override
  final int fatigueChange;
  @override
  final int overallChange;
  @override
  final String summary;

  @override
  String toString() {
    return 'ConditionChange(complexionChange: $complexionChange, puffinessChange: $puffinessChange, fatigueChange: $fatigueChange, overallChange: $overallChange, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConditionChangeImpl &&
            (identical(other.complexionChange, complexionChange) ||
                other.complexionChange == complexionChange) &&
            (identical(other.puffinessChange, puffinessChange) ||
                other.puffinessChange == puffinessChange) &&
            (identical(other.fatigueChange, fatigueChange) ||
                other.fatigueChange == fatigueChange) &&
            (identical(other.overallChange, overallChange) ||
                other.overallChange == overallChange) &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, complexionChange,
      puffinessChange, fatigueChange, overallChange, summary);

  /// Create a copy of ConditionChange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConditionChangeImplCopyWith<_$ConditionChangeImpl> get copyWith =>
      __$$ConditionChangeImplCopyWithImpl<_$ConditionChangeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConditionChangeImplToJson(
      this,
    );
  }
}

abstract class _ConditionChange implements ConditionChange {
  const factory _ConditionChange(
      {required final int complexionChange,
      required final int puffinessChange,
      required final int fatigueChange,
      required final int overallChange,
      required final String summary}) = _$ConditionChangeImpl;

  factory _ConditionChange.fromJson(Map<String, dynamic> json) =
      _$ConditionChangeImpl.fromJson;

  @override
  int get complexionChange;
  @override
  int get puffinessChange;
  @override
  int get fatigueChange;
  @override
  int get overallChange;
  @override
  String get summary;

  /// Create a copy of ConditionChange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConditionChangeImplCopyWith<_$ConditionChangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EmotionChange _$EmotionChangeFromJson(Map<String, dynamic> json) {
  return _EmotionChange.fromJson(json);
}

/// @nodoc
mixin _$EmotionChange {
  double get smileChange => throw _privateConstructorUsedError;
  double get tensionChange => throw _privateConstructorUsedError;
  double get relaxedChange => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;

  /// Serializes this EmotionChange to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmotionChange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmotionChangeCopyWith<EmotionChange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmotionChangeCopyWith<$Res> {
  factory $EmotionChangeCopyWith(
          EmotionChange value, $Res Function(EmotionChange) then) =
      _$EmotionChangeCopyWithImpl<$Res, EmotionChange>;
  @useResult
  $Res call(
      {double smileChange,
      double tensionChange,
      double relaxedChange,
      String summary});
}

/// @nodoc
class _$EmotionChangeCopyWithImpl<$Res, $Val extends EmotionChange>
    implements $EmotionChangeCopyWith<$Res> {
  _$EmotionChangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmotionChange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? smileChange = null,
    Object? tensionChange = null,
    Object? relaxedChange = null,
    Object? summary = null,
  }) {
    return _then(_value.copyWith(
      smileChange: null == smileChange
          ? _value.smileChange
          : smileChange // ignore: cast_nullable_to_non_nullable
              as double,
      tensionChange: null == tensionChange
          ? _value.tensionChange
          : tensionChange // ignore: cast_nullable_to_non_nullable
              as double,
      relaxedChange: null == relaxedChange
          ? _value.relaxedChange
          : relaxedChange // ignore: cast_nullable_to_non_nullable
              as double,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EmotionChangeImplCopyWith<$Res>
    implements $EmotionChangeCopyWith<$Res> {
  factory _$$EmotionChangeImplCopyWith(
          _$EmotionChangeImpl value, $Res Function(_$EmotionChangeImpl) then) =
      __$$EmotionChangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double smileChange,
      double tensionChange,
      double relaxedChange,
      String summary});
}

/// @nodoc
class __$$EmotionChangeImplCopyWithImpl<$Res>
    extends _$EmotionChangeCopyWithImpl<$Res, _$EmotionChangeImpl>
    implements _$$EmotionChangeImplCopyWith<$Res> {
  __$$EmotionChangeImplCopyWithImpl(
      _$EmotionChangeImpl _value, $Res Function(_$EmotionChangeImpl) _then)
      : super(_value, _then);

  /// Create a copy of EmotionChange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? smileChange = null,
    Object? tensionChange = null,
    Object? relaxedChange = null,
    Object? summary = null,
  }) {
    return _then(_$EmotionChangeImpl(
      smileChange: null == smileChange
          ? _value.smileChange
          : smileChange // ignore: cast_nullable_to_non_nullable
              as double,
      tensionChange: null == tensionChange
          ? _value.tensionChange
          : tensionChange // ignore: cast_nullable_to_non_nullable
              as double,
      relaxedChange: null == relaxedChange
          ? _value.relaxedChange
          : relaxedChange // ignore: cast_nullable_to_non_nullable
              as double,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EmotionChangeImpl implements _EmotionChange {
  const _$EmotionChangeImpl(
      {required this.smileChange,
      required this.tensionChange,
      required this.relaxedChange,
      required this.summary});

  factory _$EmotionChangeImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmotionChangeImplFromJson(json);

  @override
  final double smileChange;
  @override
  final double tensionChange;
  @override
  final double relaxedChange;
  @override
  final String summary;

  @override
  String toString() {
    return 'EmotionChange(smileChange: $smileChange, tensionChange: $tensionChange, relaxedChange: $relaxedChange, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmotionChangeImpl &&
            (identical(other.smileChange, smileChange) ||
                other.smileChange == smileChange) &&
            (identical(other.tensionChange, tensionChange) ||
                other.tensionChange == tensionChange) &&
            (identical(other.relaxedChange, relaxedChange) ||
                other.relaxedChange == relaxedChange) &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, smileChange, tensionChange, relaxedChange, summary);

  /// Create a copy of EmotionChange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmotionChangeImplCopyWith<_$EmotionChangeImpl> get copyWith =>
      __$$EmotionChangeImplCopyWithImpl<_$EmotionChangeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmotionChangeImplToJson(
      this,
    );
  }
}

abstract class _EmotionChange implements EmotionChange {
  const factory _EmotionChange(
      {required final double smileChange,
      required final double tensionChange,
      required final double relaxedChange,
      required final String summary}) = _$EmotionChangeImpl;

  factory _EmotionChange.fromJson(Map<String, dynamic> json) =
      _$EmotionChangeImpl.fromJson;

  @override
  double get smileChange;
  @override
  double get tensionChange;
  @override
  double get relaxedChange;
  @override
  String get summary;

  /// Create a copy of EmotionChange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmotionChangeImplCopyWith<_$EmotionChangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScoreChanges _$ScoreChangesFromJson(Map<String, dynamic> json) {
  return _ScoreChanges.fromJson(json);
}

/// @nodoc
mixin _$ScoreChanges {
  int get loveChange => throw _privateConstructorUsedError;
  int get marriageChange => throw _privateConstructorUsedError;
  int get careerChange => throw _privateConstructorUsedError;
  int get wealthChange => throw _privateConstructorUsedError;
  int get healthChange => throw _privateConstructorUsedError;
  int get relationshipChange => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;

  /// Serializes this ScoreChanges to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScoreChanges
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoreChangesCopyWith<ScoreChanges> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoreChangesCopyWith<$Res> {
  factory $ScoreChangesCopyWith(
          ScoreChanges value, $Res Function(ScoreChanges) then) =
      _$ScoreChangesCopyWithImpl<$Res, ScoreChanges>;
  @useResult
  $Res call(
      {int loveChange,
      int marriageChange,
      int careerChange,
      int wealthChange,
      int healthChange,
      int relationshipChange,
      String summary});
}

/// @nodoc
class _$ScoreChangesCopyWithImpl<$Res, $Val extends ScoreChanges>
    implements $ScoreChangesCopyWith<$Res> {
  _$ScoreChangesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoreChanges
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loveChange = null,
    Object? marriageChange = null,
    Object? careerChange = null,
    Object? wealthChange = null,
    Object? healthChange = null,
    Object? relationshipChange = null,
    Object? summary = null,
  }) {
    return _then(_value.copyWith(
      loveChange: null == loveChange
          ? _value.loveChange
          : loveChange // ignore: cast_nullable_to_non_nullable
              as int,
      marriageChange: null == marriageChange
          ? _value.marriageChange
          : marriageChange // ignore: cast_nullable_to_non_nullable
              as int,
      careerChange: null == careerChange
          ? _value.careerChange
          : careerChange // ignore: cast_nullable_to_non_nullable
              as int,
      wealthChange: null == wealthChange
          ? _value.wealthChange
          : wealthChange // ignore: cast_nullable_to_non_nullable
              as int,
      healthChange: null == healthChange
          ? _value.healthChange
          : healthChange // ignore: cast_nullable_to_non_nullable
              as int,
      relationshipChange: null == relationshipChange
          ? _value.relationshipChange
          : relationshipChange // ignore: cast_nullable_to_non_nullable
              as int,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScoreChangesImplCopyWith<$Res>
    implements $ScoreChangesCopyWith<$Res> {
  factory _$$ScoreChangesImplCopyWith(
          _$ScoreChangesImpl value, $Res Function(_$ScoreChangesImpl) then) =
      __$$ScoreChangesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int loveChange,
      int marriageChange,
      int careerChange,
      int wealthChange,
      int healthChange,
      int relationshipChange,
      String summary});
}

/// @nodoc
class __$$ScoreChangesImplCopyWithImpl<$Res>
    extends _$ScoreChangesCopyWithImpl<$Res, _$ScoreChangesImpl>
    implements _$$ScoreChangesImplCopyWith<$Res> {
  __$$ScoreChangesImplCopyWithImpl(
      _$ScoreChangesImpl _value, $Res Function(_$ScoreChangesImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScoreChanges
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loveChange = null,
    Object? marriageChange = null,
    Object? careerChange = null,
    Object? wealthChange = null,
    Object? healthChange = null,
    Object? relationshipChange = null,
    Object? summary = null,
  }) {
    return _then(_$ScoreChangesImpl(
      loveChange: null == loveChange
          ? _value.loveChange
          : loveChange // ignore: cast_nullable_to_non_nullable
              as int,
      marriageChange: null == marriageChange
          ? _value.marriageChange
          : marriageChange // ignore: cast_nullable_to_non_nullable
              as int,
      careerChange: null == careerChange
          ? _value.careerChange
          : careerChange // ignore: cast_nullable_to_non_nullable
              as int,
      wealthChange: null == wealthChange
          ? _value.wealthChange
          : wealthChange // ignore: cast_nullable_to_non_nullable
              as int,
      healthChange: null == healthChange
          ? _value.healthChange
          : healthChange // ignore: cast_nullable_to_non_nullable
              as int,
      relationshipChange: null == relationshipChange
          ? _value.relationshipChange
          : relationshipChange // ignore: cast_nullable_to_non_nullable
              as int,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScoreChangesImpl implements _ScoreChanges {
  const _$ScoreChangesImpl(
      {required this.loveChange,
      required this.marriageChange,
      required this.careerChange,
      required this.wealthChange,
      required this.healthChange,
      required this.relationshipChange,
      required this.summary});

  factory _$ScoreChangesImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScoreChangesImplFromJson(json);

  @override
  final int loveChange;
  @override
  final int marriageChange;
  @override
  final int careerChange;
  @override
  final int wealthChange;
  @override
  final int healthChange;
  @override
  final int relationshipChange;
  @override
  final String summary;

  @override
  String toString() {
    return 'ScoreChanges(loveChange: $loveChange, marriageChange: $marriageChange, careerChange: $careerChange, wealthChange: $wealthChange, healthChange: $healthChange, relationshipChange: $relationshipChange, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoreChangesImpl &&
            (identical(other.loveChange, loveChange) ||
                other.loveChange == loveChange) &&
            (identical(other.marriageChange, marriageChange) ||
                other.marriageChange == marriageChange) &&
            (identical(other.careerChange, careerChange) ||
                other.careerChange == careerChange) &&
            (identical(other.wealthChange, wealthChange) ||
                other.wealthChange == wealthChange) &&
            (identical(other.healthChange, healthChange) ||
                other.healthChange == healthChange) &&
            (identical(other.relationshipChange, relationshipChange) ||
                other.relationshipChange == relationshipChange) &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, loveChange, marriageChange,
      careerChange, wealthChange, healthChange, relationshipChange, summary);

  /// Create a copy of ScoreChanges
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoreChangesImplCopyWith<_$ScoreChangesImpl> get copyWith =>
      __$$ScoreChangesImplCopyWithImpl<_$ScoreChangesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoreChangesImplToJson(
      this,
    );
  }
}

abstract class _ScoreChanges implements ScoreChanges {
  const factory _ScoreChanges(
      {required final int loveChange,
      required final int marriageChange,
      required final int careerChange,
      required final int wealthChange,
      required final int healthChange,
      required final int relationshipChange,
      required final String summary}) = _$ScoreChangesImpl;

  factory _ScoreChanges.fromJson(Map<String, dynamic> json) =
      _$ScoreChangesImpl.fromJson;

  @override
  int get loveChange;
  @override
  int get marriageChange;
  @override
  int get careerChange;
  @override
  int get wealthChange;
  @override
  int get healthChange;
  @override
  int get relationshipChange;
  @override
  String get summary;

  /// Create a copy of ScoreChanges
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoreChangesImplCopyWith<_$ScoreChangesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HistoryStats _$HistoryStatsFromJson(Map<String, dynamic> json) {
  return _HistoryStats.fromJson(json);
}

/// @nodoc
mixin _$HistoryStats {
  /// 총 분석 횟수
  int get totalAnalysisCount => throw _privateConstructorUsedError;

  /// 연속 기록 일수
  int get streakDays => throw _privateConstructorUsedError;

  /// 최장 연속 기록 일수
  int get longestStreak => throw _privateConstructorUsedError;

  /// 이번 달 분석 횟수
  int get thisMonthCount => throw _privateConstructorUsedError;

  /// 평균 컨디션 점수
  double get averageConditionScore => throw _privateConstructorUsedError;

  /// 평균 미소 지수
  double get averageSmilePercentage => throw _privateConstructorUsedError;

  /// 가장 좋았던 날
  DateTime? get bestConditionDate => throw _privateConstructorUsedError;

  /// 미션 완료율
  double get missionCompletionRate => throw _privateConstructorUsedError;

  /// Serializes this HistoryStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HistoryStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HistoryStatsCopyWith<HistoryStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HistoryStatsCopyWith<$Res> {
  factory $HistoryStatsCopyWith(
          HistoryStats value, $Res Function(HistoryStats) then) =
      _$HistoryStatsCopyWithImpl<$Res, HistoryStats>;
  @useResult
  $Res call(
      {int totalAnalysisCount,
      int streakDays,
      int longestStreak,
      int thisMonthCount,
      double averageConditionScore,
      double averageSmilePercentage,
      DateTime? bestConditionDate,
      double missionCompletionRate});
}

/// @nodoc
class _$HistoryStatsCopyWithImpl<$Res, $Val extends HistoryStats>
    implements $HistoryStatsCopyWith<$Res> {
  _$HistoryStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HistoryStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalAnalysisCount = null,
    Object? streakDays = null,
    Object? longestStreak = null,
    Object? thisMonthCount = null,
    Object? averageConditionScore = null,
    Object? averageSmilePercentage = null,
    Object? bestConditionDate = freezed,
    Object? missionCompletionRate = null,
  }) {
    return _then(_value.copyWith(
      totalAnalysisCount: null == totalAnalysisCount
          ? _value.totalAnalysisCount
          : totalAnalysisCount // ignore: cast_nullable_to_non_nullable
              as int,
      streakDays: null == streakDays
          ? _value.streakDays
          : streakDays // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      thisMonthCount: null == thisMonthCount
          ? _value.thisMonthCount
          : thisMonthCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageConditionScore: null == averageConditionScore
          ? _value.averageConditionScore
          : averageConditionScore // ignore: cast_nullable_to_non_nullable
              as double,
      averageSmilePercentage: null == averageSmilePercentage
          ? _value.averageSmilePercentage
          : averageSmilePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      bestConditionDate: freezed == bestConditionDate
          ? _value.bestConditionDate
          : bestConditionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      missionCompletionRate: null == missionCompletionRate
          ? _value.missionCompletionRate
          : missionCompletionRate // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HistoryStatsImplCopyWith<$Res>
    implements $HistoryStatsCopyWith<$Res> {
  factory _$$HistoryStatsImplCopyWith(
          _$HistoryStatsImpl value, $Res Function(_$HistoryStatsImpl) then) =
      __$$HistoryStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalAnalysisCount,
      int streakDays,
      int longestStreak,
      int thisMonthCount,
      double averageConditionScore,
      double averageSmilePercentage,
      DateTime? bestConditionDate,
      double missionCompletionRate});
}

/// @nodoc
class __$$HistoryStatsImplCopyWithImpl<$Res>
    extends _$HistoryStatsCopyWithImpl<$Res, _$HistoryStatsImpl>
    implements _$$HistoryStatsImplCopyWith<$Res> {
  __$$HistoryStatsImplCopyWithImpl(
      _$HistoryStatsImpl _value, $Res Function(_$HistoryStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of HistoryStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalAnalysisCount = null,
    Object? streakDays = null,
    Object? longestStreak = null,
    Object? thisMonthCount = null,
    Object? averageConditionScore = null,
    Object? averageSmilePercentage = null,
    Object? bestConditionDate = freezed,
    Object? missionCompletionRate = null,
  }) {
    return _then(_$HistoryStatsImpl(
      totalAnalysisCount: null == totalAnalysisCount
          ? _value.totalAnalysisCount
          : totalAnalysisCount // ignore: cast_nullable_to_non_nullable
              as int,
      streakDays: null == streakDays
          ? _value.streakDays
          : streakDays // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      thisMonthCount: null == thisMonthCount
          ? _value.thisMonthCount
          : thisMonthCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageConditionScore: null == averageConditionScore
          ? _value.averageConditionScore
          : averageConditionScore // ignore: cast_nullable_to_non_nullable
              as double,
      averageSmilePercentage: null == averageSmilePercentage
          ? _value.averageSmilePercentage
          : averageSmilePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      bestConditionDate: freezed == bestConditionDate
          ? _value.bestConditionDate
          : bestConditionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      missionCompletionRate: null == missionCompletionRate
          ? _value.missionCompletionRate
          : missionCompletionRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HistoryStatsImpl implements _HistoryStats {
  const _$HistoryStatsImpl(
      {required this.totalAnalysisCount,
      required this.streakDays,
      required this.longestStreak,
      required this.thisMonthCount,
      required this.averageConditionScore,
      required this.averageSmilePercentage,
      this.bestConditionDate,
      required this.missionCompletionRate});

  factory _$HistoryStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$HistoryStatsImplFromJson(json);

  /// 총 분석 횟수
  @override
  final int totalAnalysisCount;

  /// 연속 기록 일수
  @override
  final int streakDays;

  /// 최장 연속 기록 일수
  @override
  final int longestStreak;

  /// 이번 달 분석 횟수
  @override
  final int thisMonthCount;

  /// 평균 컨디션 점수
  @override
  final double averageConditionScore;

  /// 평균 미소 지수
  @override
  final double averageSmilePercentage;

  /// 가장 좋았던 날
  @override
  final DateTime? bestConditionDate;

  /// 미션 완료율
  @override
  final double missionCompletionRate;

  @override
  String toString() {
    return 'HistoryStats(totalAnalysisCount: $totalAnalysisCount, streakDays: $streakDays, longestStreak: $longestStreak, thisMonthCount: $thisMonthCount, averageConditionScore: $averageConditionScore, averageSmilePercentage: $averageSmilePercentage, bestConditionDate: $bestConditionDate, missionCompletionRate: $missionCompletionRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HistoryStatsImpl &&
            (identical(other.totalAnalysisCount, totalAnalysisCount) ||
                other.totalAnalysisCount == totalAnalysisCount) &&
            (identical(other.streakDays, streakDays) ||
                other.streakDays == streakDays) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.thisMonthCount, thisMonthCount) ||
                other.thisMonthCount == thisMonthCount) &&
            (identical(other.averageConditionScore, averageConditionScore) ||
                other.averageConditionScore == averageConditionScore) &&
            (identical(other.averageSmilePercentage, averageSmilePercentage) ||
                other.averageSmilePercentage == averageSmilePercentage) &&
            (identical(other.bestConditionDate, bestConditionDate) ||
                other.bestConditionDate == bestConditionDate) &&
            (identical(other.missionCompletionRate, missionCompletionRate) ||
                other.missionCompletionRate == missionCompletionRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalAnalysisCount,
      streakDays,
      longestStreak,
      thisMonthCount,
      averageConditionScore,
      averageSmilePercentage,
      bestConditionDate,
      missionCompletionRate);

  /// Create a copy of HistoryStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HistoryStatsImplCopyWith<_$HistoryStatsImpl> get copyWith =>
      __$$HistoryStatsImplCopyWithImpl<_$HistoryStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HistoryStatsImplToJson(
      this,
    );
  }
}

abstract class _HistoryStats implements HistoryStats {
  const factory _HistoryStats(
      {required final int totalAnalysisCount,
      required final int streakDays,
      required final int longestStreak,
      required final int thisMonthCount,
      required final double averageConditionScore,
      required final double averageSmilePercentage,
      final DateTime? bestConditionDate,
      required final double missionCompletionRate}) = _$HistoryStatsImpl;

  factory _HistoryStats.fromJson(Map<String, dynamic> json) =
      _$HistoryStatsImpl.fromJson;

  /// 총 분석 횟수
  @override
  int get totalAnalysisCount;

  /// 연속 기록 일수
  @override
  int get streakDays;

  /// 최장 연속 기록 일수
  @override
  int get longestStreak;

  /// 이번 달 분석 횟수
  @override
  int get thisMonthCount;

  /// 평균 컨디션 점수
  @override
  double get averageConditionScore;

  /// 평균 미소 지수
  @override
  double get averageSmilePercentage;

  /// 가장 좋았던 날
  @override
  DateTime? get bestConditionDate;

  /// 미션 완료율
  @override
  double get missionCompletionRate;

  /// Create a copy of HistoryStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HistoryStatsImplCopyWith<_$HistoryStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
