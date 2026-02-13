// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'face_reading_result_v2.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PriorityInsight _$PriorityInsightFromJson(Map<String, dynamic> json) {
  return _PriorityInsight.fromJson(json);
}

/// @nodoc
mixin _$PriorityInsight {
  /// 인사이트 제목
  String get title => throw _privateConstructorUsedError;

  /// 인사이트 설명 (친근한 말투)
  String get description => throw _privateConstructorUsedError;

  /// 우선순위 (1: 최고, 2, 3)
  int get priority => throw _privateConstructorUsedError;

  /// 카테고리 (wealth, love, career, health, relationship, personality, first_impression, beauty)
  String get category => throw _privateConstructorUsedError;

  /// 점수 (선택적)
  int? get score => throw _privateConstructorUsedError;

  /// 관련 부위 또는 궁
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
      {String title,
      String description,
      int priority,
      String category,
      int? score,
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
    Object? title = null,
    Object? description = null,
    Object? priority = null,
    Object? category = null,
    Object? score = freezed,
    Object? relatedFeature = freezed,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      score: freezed == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int?,
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
      {String title,
      String description,
      int priority,
      String category,
      int? score,
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
    Object? title = null,
    Object? description = null,
    Object? priority = null,
    Object? category = null,
    Object? score = freezed,
    Object? relatedFeature = freezed,
  }) {
    return _then(_$PriorityInsightImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      score: freezed == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int?,
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
      {required this.title,
      required this.description,
      required this.priority,
      required this.category,
      this.score,
      this.relatedFeature});

  factory _$PriorityInsightImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriorityInsightImplFromJson(json);

  /// 인사이트 제목
  @override
  final String title;

  /// 인사이트 설명 (친근한 말투)
  @override
  final String description;

  /// 우선순위 (1: 최고, 2, 3)
  @override
  final int priority;

  /// 카테고리 (wealth, love, career, health, relationship, personality, first_impression, beauty)
  @override
  final String category;

  /// 점수 (선택적)
  @override
  final int? score;

  /// 관련 부위 또는 궁
  @override
  final String? relatedFeature;

  @override
  String toString() {
    return 'PriorityInsight(title: $title, description: $description, priority: $priority, category: $category, score: $score, relatedFeature: $relatedFeature)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriorityInsightImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.relatedFeature, relatedFeature) ||
                other.relatedFeature == relatedFeature));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, description, priority,
      category, score, relatedFeature);

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
      {required final String title,
      required final String description,
      required final int priority,
      required final String category,
      final int? score,
      final String? relatedFeature}) = _$PriorityInsightImpl;

  factory _PriorityInsight.fromJson(Map<String, dynamic> json) =
      _$PriorityInsightImpl.fromJson;

  /// 인사이트 제목
  @override
  String get title;

  /// 인사이트 설명 (친근한 말투)
  @override
  String get description;

  /// 우선순위 (1: 최고, 2, 3)
  @override
  int get priority;

  /// 카테고리 (wealth, love, career, health, relationship, personality, first_impression, beauty)
  @override
  String get category;

  /// 점수 (선택적)
  @override
  int? get score;

  /// 관련 부위 또는 궁
  @override
  String? get relatedFeature;

  /// Create a copy of PriorityInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriorityInsightImplCopyWith<_$PriorityInsightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FaceReadingResultV2 _$FaceReadingResultV2FromJson(Map<String, dynamic> json) {
  return _FaceReadingResultV2.fromJson(json);
}

/// @nodoc
mixin _$FaceReadingResultV2 {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // === 사용자 정보 ===
  String get gender => throw _privateConstructorUsedError; // 'male' | 'female'
  String? get ageGroup =>
      throw _privateConstructorUsedError; // '20s', '30s', etc.
// === 핵심 요약 (기본 노출) ===
  /// 핵심 포인트 3가지 (성별에 따라 다른 내용)
  List<PriorityInsight> get priorityInsights =>
      throw _privateConstructorUsedError;

  /// 종합 운세 점수 (0-100)
  int get overallScore => throw _privateConstructorUsedError;

  /// 한줄 요약 (친근한 말투)
  String get summaryMessage => throw _privateConstructorUsedError;

  /// 총평 (전체 운세 설명)
  String get overallFortune => throw _privateConstructorUsedError;

  /// 얼굴형 (타원형, 둥근형 등)
  String get faceType => throw _privateConstructorUsedError; // === 신규 분석 요소 ===
  /// 오늘의 얼굴 컨디션 (혈색, 붓기, 피로도)
  FaceCondition? get faceCondition => throw _privateConstructorUsedError;

  /// 감정 인식 분석 (미소, 긴장, 무표정 %)
  EmotionAnalysis? get emotionAnalysis =>
      throw _privateConstructorUsedError; // === 전통 관상 분석 (접히는 섹션) ===
  /// 명궁 분석 (미간 → 명궁으로 순서 변경)
  MyeonggungAnalysis? get myeonggungAnalysis =>
      throw _privateConstructorUsedError;

  /// 미간 분석
  MiganAnalysis? get miganAnalysis => throw _privateConstructorUsedError;

  /// 오관 분석 (요약형)
  SimplifiedOgwan? get simplifiedOgwan => throw _privateConstructorUsedError;

  /// 십이궁 분석 (요약형)
  SimplifiedSibigung? get simplifiedSibigung =>
      throw _privateConstructorUsedError;

  /// 닮은꼴 연예인 목록
  List<CelebrityMatch> get celebrityMatches =>
      throw _privateConstructorUsedError; // === 성별 특화 콘텐츠 ===
  /// 여성 전용: 스타일 추천
  MakeupStyleRecommendations? get makeupRecommendations =>
      throw _privateConstructorUsedError;

  /// 여성 전용: 매력 포인트 강조
  LuckyFeatureEnhancement? get luckyFeatureEnhancement =>
      throw _privateConstructorUsedError;

  /// 남성 전용: 리더십/직업 적합도
  LeadershipAnalysis? get leadershipAnalysis =>
      throw _privateConstructorUsedError; // === Apple Watch 데이터 ===
  WatchFaceReadingData? get watchData =>
      throw _privateConstructorUsedError; // === 공유용 데이터 ===
  ShareableContent? get shareableContent => throw _privateConstructorUsedError;

  /// Serializes this FaceReadingResultV2 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FaceReadingResultV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FaceReadingResultV2CopyWith<FaceReadingResultV2> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FaceReadingResultV2CopyWith<$Res> {
  factory $FaceReadingResultV2CopyWith(
          FaceReadingResultV2 value, $Res Function(FaceReadingResultV2) then) =
      _$FaceReadingResultV2CopyWithImpl<$Res, FaceReadingResultV2>;
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      String gender,
      String? ageGroup,
      List<PriorityInsight> priorityInsights,
      int overallScore,
      String summaryMessage,
      String overallFortune,
      String faceType,
      FaceCondition? faceCondition,
      EmotionAnalysis? emotionAnalysis,
      MyeonggungAnalysis? myeonggungAnalysis,
      MiganAnalysis? miganAnalysis,
      SimplifiedOgwan? simplifiedOgwan,
      SimplifiedSibigung? simplifiedSibigung,
      List<CelebrityMatch> celebrityMatches,
      MakeupStyleRecommendations? makeupRecommendations,
      LuckyFeatureEnhancement? luckyFeatureEnhancement,
      LeadershipAnalysis? leadershipAnalysis,
      WatchFaceReadingData? watchData,
      ShareableContent? shareableContent});

  $FaceConditionCopyWith<$Res>? get faceCondition;
  $EmotionAnalysisCopyWith<$Res>? get emotionAnalysis;
  $MyeonggungAnalysisCopyWith<$Res>? get myeonggungAnalysis;
  $MiganAnalysisCopyWith<$Res>? get miganAnalysis;
  $SimplifiedOgwanCopyWith<$Res>? get simplifiedOgwan;
  $SimplifiedSibigungCopyWith<$Res>? get simplifiedSibigung;
  $MakeupStyleRecommendationsCopyWith<$Res>? get makeupRecommendations;
  $LuckyFeatureEnhancementCopyWith<$Res>? get luckyFeatureEnhancement;
  $LeadershipAnalysisCopyWith<$Res>? get leadershipAnalysis;
  $WatchFaceReadingDataCopyWith<$Res>? get watchData;
  $ShareableContentCopyWith<$Res>? get shareableContent;
}

/// @nodoc
class _$FaceReadingResultV2CopyWithImpl<$Res, $Val extends FaceReadingResultV2>
    implements $FaceReadingResultV2CopyWith<$Res> {
  _$FaceReadingResultV2CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FaceReadingResultV2
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? createdAt = null,
    Object? gender = null,
    Object? ageGroup = freezed,
    Object? priorityInsights = null,
    Object? overallScore = null,
    Object? summaryMessage = null,
    Object? overallFortune = null,
    Object? faceType = null,
    Object? faceCondition = freezed,
    Object? emotionAnalysis = freezed,
    Object? myeonggungAnalysis = freezed,
    Object? miganAnalysis = freezed,
    Object? simplifiedOgwan = freezed,
    Object? simplifiedSibigung = freezed,
    Object? celebrityMatches = null,
    Object? makeupRecommendations = freezed,
    Object? luckyFeatureEnhancement = freezed,
    Object? leadershipAnalysis = freezed,
    Object? watchData = freezed,
    Object? shareableContent = freezed,
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
      priorityInsights: null == priorityInsights
          ? _value.priorityInsights
          : priorityInsights // ignore: cast_nullable_to_non_nullable
              as List<PriorityInsight>,
      overallScore: null == overallScore
          ? _value.overallScore
          : overallScore // ignore: cast_nullable_to_non_nullable
              as int,
      summaryMessage: null == summaryMessage
          ? _value.summaryMessage
          : summaryMessage // ignore: cast_nullable_to_non_nullable
              as String,
      overallFortune: null == overallFortune
          ? _value.overallFortune
          : overallFortune // ignore: cast_nullable_to_non_nullable
              as String,
      faceType: null == faceType
          ? _value.faceType
          : faceType // ignore: cast_nullable_to_non_nullable
              as String,
      faceCondition: freezed == faceCondition
          ? _value.faceCondition
          : faceCondition // ignore: cast_nullable_to_non_nullable
              as FaceCondition?,
      emotionAnalysis: freezed == emotionAnalysis
          ? _value.emotionAnalysis
          : emotionAnalysis // ignore: cast_nullable_to_non_nullable
              as EmotionAnalysis?,
      myeonggungAnalysis: freezed == myeonggungAnalysis
          ? _value.myeonggungAnalysis
          : myeonggungAnalysis // ignore: cast_nullable_to_non_nullable
              as MyeonggungAnalysis?,
      miganAnalysis: freezed == miganAnalysis
          ? _value.miganAnalysis
          : miganAnalysis // ignore: cast_nullable_to_non_nullable
              as MiganAnalysis?,
      simplifiedOgwan: freezed == simplifiedOgwan
          ? _value.simplifiedOgwan
          : simplifiedOgwan // ignore: cast_nullable_to_non_nullable
              as SimplifiedOgwan?,
      simplifiedSibigung: freezed == simplifiedSibigung
          ? _value.simplifiedSibigung
          : simplifiedSibigung // ignore: cast_nullable_to_non_nullable
              as SimplifiedSibigung?,
      celebrityMatches: null == celebrityMatches
          ? _value.celebrityMatches
          : celebrityMatches // ignore: cast_nullable_to_non_nullable
              as List<CelebrityMatch>,
      makeupRecommendations: freezed == makeupRecommendations
          ? _value.makeupRecommendations
          : makeupRecommendations // ignore: cast_nullable_to_non_nullable
              as MakeupStyleRecommendations?,
      luckyFeatureEnhancement: freezed == luckyFeatureEnhancement
          ? _value.luckyFeatureEnhancement
          : luckyFeatureEnhancement // ignore: cast_nullable_to_non_nullable
              as LuckyFeatureEnhancement?,
      leadershipAnalysis: freezed == leadershipAnalysis
          ? _value.leadershipAnalysis
          : leadershipAnalysis // ignore: cast_nullable_to_non_nullable
              as LeadershipAnalysis?,
      watchData: freezed == watchData
          ? _value.watchData
          : watchData // ignore: cast_nullable_to_non_nullable
              as WatchFaceReadingData?,
      shareableContent: freezed == shareableContent
          ? _value.shareableContent
          : shareableContent // ignore: cast_nullable_to_non_nullable
              as ShareableContent?,
    ) as $Val);
  }

  /// Create a copy of FaceReadingResultV2
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FaceConditionCopyWith<$Res>? get faceCondition {
    if (_value.faceCondition == null) {
      return null;
    }

    return $FaceConditionCopyWith<$Res>(_value.faceCondition!, (value) {
      return _then(_value.copyWith(faceCondition: value) as $Val);
    });
  }

  /// Create a copy of FaceReadingResultV2
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EmotionAnalysisCopyWith<$Res>? get emotionAnalysis {
    if (_value.emotionAnalysis == null) {
      return null;
    }

    return $EmotionAnalysisCopyWith<$Res>(_value.emotionAnalysis!, (value) {
      return _then(_value.copyWith(emotionAnalysis: value) as $Val);
    });
  }

  /// Create a copy of FaceReadingResultV2
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MyeonggungAnalysisCopyWith<$Res>? get myeonggungAnalysis {
    if (_value.myeonggungAnalysis == null) {
      return null;
    }

    return $MyeonggungAnalysisCopyWith<$Res>(_value.myeonggungAnalysis!,
        (value) {
      return _then(_value.copyWith(myeonggungAnalysis: value) as $Val);
    });
  }

  /// Create a copy of FaceReadingResultV2
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MiganAnalysisCopyWith<$Res>? get miganAnalysis {
    if (_value.miganAnalysis == null) {
      return null;
    }

    return $MiganAnalysisCopyWith<$Res>(_value.miganAnalysis!, (value) {
      return _then(_value.copyWith(miganAnalysis: value) as $Val);
    });
  }

  /// Create a copy of FaceReadingResultV2
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SimplifiedOgwanCopyWith<$Res>? get simplifiedOgwan {
    if (_value.simplifiedOgwan == null) {
      return null;
    }

    return $SimplifiedOgwanCopyWith<$Res>(_value.simplifiedOgwan!, (value) {
      return _then(_value.copyWith(simplifiedOgwan: value) as $Val);
    });
  }

  /// Create a copy of FaceReadingResultV2
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SimplifiedSibigungCopyWith<$Res>? get simplifiedSibigung {
    if (_value.simplifiedSibigung == null) {
      return null;
    }

    return $SimplifiedSibigungCopyWith<$Res>(_value.simplifiedSibigung!,
        (value) {
      return _then(_value.copyWith(simplifiedSibigung: value) as $Val);
    });
  }

  /// Create a copy of FaceReadingResultV2
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MakeupStyleRecommendationsCopyWith<$Res>? get makeupRecommendations {
    if (_value.makeupRecommendations == null) {
      return null;
    }

    return $MakeupStyleRecommendationsCopyWith<$Res>(
        _value.makeupRecommendations!, (value) {
      return _then(_value.copyWith(makeupRecommendations: value) as $Val);
    });
  }

  /// Create a copy of FaceReadingResultV2
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LuckyFeatureEnhancementCopyWith<$Res>? get luckyFeatureEnhancement {
    if (_value.luckyFeatureEnhancement == null) {
      return null;
    }

    return $LuckyFeatureEnhancementCopyWith<$Res>(
        _value.luckyFeatureEnhancement!, (value) {
      return _then(_value.copyWith(luckyFeatureEnhancement: value) as $Val);
    });
  }

  /// Create a copy of FaceReadingResultV2
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LeadershipAnalysisCopyWith<$Res>? get leadershipAnalysis {
    if (_value.leadershipAnalysis == null) {
      return null;
    }

    return $LeadershipAnalysisCopyWith<$Res>(_value.leadershipAnalysis!,
        (value) {
      return _then(_value.copyWith(leadershipAnalysis: value) as $Val);
    });
  }

  /// Create a copy of FaceReadingResultV2
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WatchFaceReadingDataCopyWith<$Res>? get watchData {
    if (_value.watchData == null) {
      return null;
    }

    return $WatchFaceReadingDataCopyWith<$Res>(_value.watchData!, (value) {
      return _then(_value.copyWith(watchData: value) as $Val);
    });
  }

  /// Create a copy of FaceReadingResultV2
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ShareableContentCopyWith<$Res>? get shareableContent {
    if (_value.shareableContent == null) {
      return null;
    }

    return $ShareableContentCopyWith<$Res>(_value.shareableContent!, (value) {
      return _then(_value.copyWith(shareableContent: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FaceReadingResultV2ImplCopyWith<$Res>
    implements $FaceReadingResultV2CopyWith<$Res> {
  factory _$$FaceReadingResultV2ImplCopyWith(_$FaceReadingResultV2Impl value,
          $Res Function(_$FaceReadingResultV2Impl) then) =
      __$$FaceReadingResultV2ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      String gender,
      String? ageGroup,
      List<PriorityInsight> priorityInsights,
      int overallScore,
      String summaryMessage,
      String overallFortune,
      String faceType,
      FaceCondition? faceCondition,
      EmotionAnalysis? emotionAnalysis,
      MyeonggungAnalysis? myeonggungAnalysis,
      MiganAnalysis? miganAnalysis,
      SimplifiedOgwan? simplifiedOgwan,
      SimplifiedSibigung? simplifiedSibigung,
      List<CelebrityMatch> celebrityMatches,
      MakeupStyleRecommendations? makeupRecommendations,
      LuckyFeatureEnhancement? luckyFeatureEnhancement,
      LeadershipAnalysis? leadershipAnalysis,
      WatchFaceReadingData? watchData,
      ShareableContent? shareableContent});

  @override
  $FaceConditionCopyWith<$Res>? get faceCondition;
  @override
  $EmotionAnalysisCopyWith<$Res>? get emotionAnalysis;
  @override
  $MyeonggungAnalysisCopyWith<$Res>? get myeonggungAnalysis;
  @override
  $MiganAnalysisCopyWith<$Res>? get miganAnalysis;
  @override
  $SimplifiedOgwanCopyWith<$Res>? get simplifiedOgwan;
  @override
  $SimplifiedSibigungCopyWith<$Res>? get simplifiedSibigung;
  @override
  $MakeupStyleRecommendationsCopyWith<$Res>? get makeupRecommendations;
  @override
  $LuckyFeatureEnhancementCopyWith<$Res>? get luckyFeatureEnhancement;
  @override
  $LeadershipAnalysisCopyWith<$Res>? get leadershipAnalysis;
  @override
  $WatchFaceReadingDataCopyWith<$Res>? get watchData;
  @override
  $ShareableContentCopyWith<$Res>? get shareableContent;
}

/// @nodoc
class __$$FaceReadingResultV2ImplCopyWithImpl<$Res>
    extends _$FaceReadingResultV2CopyWithImpl<$Res, _$FaceReadingResultV2Impl>
    implements _$$FaceReadingResultV2ImplCopyWith<$Res> {
  __$$FaceReadingResultV2ImplCopyWithImpl(_$FaceReadingResultV2Impl _value,
      $Res Function(_$FaceReadingResultV2Impl) _then)
      : super(_value, _then);

  /// Create a copy of FaceReadingResultV2
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? createdAt = null,
    Object? gender = null,
    Object? ageGroup = freezed,
    Object? priorityInsights = null,
    Object? overallScore = null,
    Object? summaryMessage = null,
    Object? overallFortune = null,
    Object? faceType = null,
    Object? faceCondition = freezed,
    Object? emotionAnalysis = freezed,
    Object? myeonggungAnalysis = freezed,
    Object? miganAnalysis = freezed,
    Object? simplifiedOgwan = freezed,
    Object? simplifiedSibigung = freezed,
    Object? celebrityMatches = null,
    Object? makeupRecommendations = freezed,
    Object? luckyFeatureEnhancement = freezed,
    Object? leadershipAnalysis = freezed,
    Object? watchData = freezed,
    Object? shareableContent = freezed,
  }) {
    return _then(_$FaceReadingResultV2Impl(
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
      priorityInsights: null == priorityInsights
          ? _value._priorityInsights
          : priorityInsights // ignore: cast_nullable_to_non_nullable
              as List<PriorityInsight>,
      overallScore: null == overallScore
          ? _value.overallScore
          : overallScore // ignore: cast_nullable_to_non_nullable
              as int,
      summaryMessage: null == summaryMessage
          ? _value.summaryMessage
          : summaryMessage // ignore: cast_nullable_to_non_nullable
              as String,
      overallFortune: null == overallFortune
          ? _value.overallFortune
          : overallFortune // ignore: cast_nullable_to_non_nullable
              as String,
      faceType: null == faceType
          ? _value.faceType
          : faceType // ignore: cast_nullable_to_non_nullable
              as String,
      faceCondition: freezed == faceCondition
          ? _value.faceCondition
          : faceCondition // ignore: cast_nullable_to_non_nullable
              as FaceCondition?,
      emotionAnalysis: freezed == emotionAnalysis
          ? _value.emotionAnalysis
          : emotionAnalysis // ignore: cast_nullable_to_non_nullable
              as EmotionAnalysis?,
      myeonggungAnalysis: freezed == myeonggungAnalysis
          ? _value.myeonggungAnalysis
          : myeonggungAnalysis // ignore: cast_nullable_to_non_nullable
              as MyeonggungAnalysis?,
      miganAnalysis: freezed == miganAnalysis
          ? _value.miganAnalysis
          : miganAnalysis // ignore: cast_nullable_to_non_nullable
              as MiganAnalysis?,
      simplifiedOgwan: freezed == simplifiedOgwan
          ? _value.simplifiedOgwan
          : simplifiedOgwan // ignore: cast_nullable_to_non_nullable
              as SimplifiedOgwan?,
      simplifiedSibigung: freezed == simplifiedSibigung
          ? _value.simplifiedSibigung
          : simplifiedSibigung // ignore: cast_nullable_to_non_nullable
              as SimplifiedSibigung?,
      celebrityMatches: null == celebrityMatches
          ? _value._celebrityMatches
          : celebrityMatches // ignore: cast_nullable_to_non_nullable
              as List<CelebrityMatch>,
      makeupRecommendations: freezed == makeupRecommendations
          ? _value.makeupRecommendations
          : makeupRecommendations // ignore: cast_nullable_to_non_nullable
              as MakeupStyleRecommendations?,
      luckyFeatureEnhancement: freezed == luckyFeatureEnhancement
          ? _value.luckyFeatureEnhancement
          : luckyFeatureEnhancement // ignore: cast_nullable_to_non_nullable
              as LuckyFeatureEnhancement?,
      leadershipAnalysis: freezed == leadershipAnalysis
          ? _value.leadershipAnalysis
          : leadershipAnalysis // ignore: cast_nullable_to_non_nullable
              as LeadershipAnalysis?,
      watchData: freezed == watchData
          ? _value.watchData
          : watchData // ignore: cast_nullable_to_non_nullable
              as WatchFaceReadingData?,
      shareableContent: freezed == shareableContent
          ? _value.shareableContent
          : shareableContent // ignore: cast_nullable_to_non_nullable
              as ShareableContent?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FaceReadingResultV2Impl implements _FaceReadingResultV2 {
  const _$FaceReadingResultV2Impl(
      {required this.id,
      required this.userId,
      required this.createdAt,
      required this.gender,
      this.ageGroup,
      final List<PriorityInsight> priorityInsights = const [],
      required this.overallScore,
      required this.summaryMessage,
      this.overallFortune = '',
      this.faceType = '',
      this.faceCondition,
      this.emotionAnalysis,
      this.myeonggungAnalysis,
      this.miganAnalysis,
      this.simplifiedOgwan,
      this.simplifiedSibigung,
      final List<CelebrityMatch> celebrityMatches = const [],
      this.makeupRecommendations,
      this.luckyFeatureEnhancement,
      this.leadershipAnalysis,
      this.watchData,
      this.shareableContent})
      : _priorityInsights = priorityInsights,
        _celebrityMatches = celebrityMatches;

  factory _$FaceReadingResultV2Impl.fromJson(Map<String, dynamic> json) =>
      _$$FaceReadingResultV2ImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime createdAt;
// === 사용자 정보 ===
  @override
  final String gender;
// 'male' | 'female'
  @override
  final String? ageGroup;
// '20s', '30s', etc.
// === 핵심 요약 (기본 노출) ===
  /// 핵심 포인트 3가지 (성별에 따라 다른 내용)
  final List<PriorityInsight> _priorityInsights;
// '20s', '30s', etc.
// === 핵심 요약 (기본 노출) ===
  /// 핵심 포인트 3가지 (성별에 따라 다른 내용)
  @override
  @JsonKey()
  List<PriorityInsight> get priorityInsights {
    if (_priorityInsights is EqualUnmodifiableListView)
      return _priorityInsights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_priorityInsights);
  }

  /// 종합 운세 점수 (0-100)
  @override
  final int overallScore;

  /// 한줄 요약 (친근한 말투)
  @override
  final String summaryMessage;

  /// 총평 (전체 운세 설명)
  @override
  @JsonKey()
  final String overallFortune;

  /// 얼굴형 (타원형, 둥근형 등)
  @override
  @JsonKey()
  final String faceType;
// === 신규 분석 요소 ===
  /// 오늘의 얼굴 컨디션 (혈색, 붓기, 피로도)
  @override
  final FaceCondition? faceCondition;

  /// 감정 인식 분석 (미소, 긴장, 무표정 %)
  @override
  final EmotionAnalysis? emotionAnalysis;
// === 전통 관상 분석 (접히는 섹션) ===
  /// 명궁 분석 (미간 → 명궁으로 순서 변경)
  @override
  final MyeonggungAnalysis? myeonggungAnalysis;

  /// 미간 분석
  @override
  final MiganAnalysis? miganAnalysis;

  /// 오관 분석 (요약형)
  @override
  final SimplifiedOgwan? simplifiedOgwan;

  /// 십이궁 분석 (요약형)
  @override
  final SimplifiedSibigung? simplifiedSibigung;

  /// 닮은꼴 연예인 목록
  final List<CelebrityMatch> _celebrityMatches;

  /// 닮은꼴 연예인 목록
  @override
  @JsonKey()
  List<CelebrityMatch> get celebrityMatches {
    if (_celebrityMatches is EqualUnmodifiableListView)
      return _celebrityMatches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_celebrityMatches);
  }

// === 성별 특화 콘텐츠 ===
  /// 여성 전용: 스타일 추천
  @override
  final MakeupStyleRecommendations? makeupRecommendations;

  /// 여성 전용: 매력 포인트 강조
  @override
  final LuckyFeatureEnhancement? luckyFeatureEnhancement;

  /// 남성 전용: 리더십/직업 적합도
  @override
  final LeadershipAnalysis? leadershipAnalysis;
// === Apple Watch 데이터 ===
  @override
  final WatchFaceReadingData? watchData;
// === 공유용 데이터 ===
  @override
  final ShareableContent? shareableContent;

  @override
  String toString() {
    return 'FaceReadingResultV2(id: $id, userId: $userId, createdAt: $createdAt, gender: $gender, ageGroup: $ageGroup, priorityInsights: $priorityInsights, overallScore: $overallScore, summaryMessage: $summaryMessage, overallFortune: $overallFortune, faceType: $faceType, faceCondition: $faceCondition, emotionAnalysis: $emotionAnalysis, myeonggungAnalysis: $myeonggungAnalysis, miganAnalysis: $miganAnalysis, simplifiedOgwan: $simplifiedOgwan, simplifiedSibigung: $simplifiedSibigung, celebrityMatches: $celebrityMatches, makeupRecommendations: $makeupRecommendations, luckyFeatureEnhancement: $luckyFeatureEnhancement, leadershipAnalysis: $leadershipAnalysis, watchData: $watchData, shareableContent: $shareableContent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FaceReadingResultV2Impl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.ageGroup, ageGroup) ||
                other.ageGroup == ageGroup) &&
            const DeepCollectionEquality()
                .equals(other._priorityInsights, _priorityInsights) &&
            (identical(other.overallScore, overallScore) ||
                other.overallScore == overallScore) &&
            (identical(other.summaryMessage, summaryMessage) ||
                other.summaryMessage == summaryMessage) &&
            (identical(other.overallFortune, overallFortune) ||
                other.overallFortune == overallFortune) &&
            (identical(other.faceType, faceType) ||
                other.faceType == faceType) &&
            (identical(other.faceCondition, faceCondition) ||
                other.faceCondition == faceCondition) &&
            (identical(other.emotionAnalysis, emotionAnalysis) ||
                other.emotionAnalysis == emotionAnalysis) &&
            (identical(other.myeonggungAnalysis, myeonggungAnalysis) ||
                other.myeonggungAnalysis == myeonggungAnalysis) &&
            (identical(other.miganAnalysis, miganAnalysis) ||
                other.miganAnalysis == miganAnalysis) &&
            (identical(other.simplifiedOgwan, simplifiedOgwan) ||
                other.simplifiedOgwan == simplifiedOgwan) &&
            (identical(other.simplifiedSibigung, simplifiedSibigung) ||
                other.simplifiedSibigung == simplifiedSibigung) &&
            const DeepCollectionEquality()
                .equals(other._celebrityMatches, _celebrityMatches) &&
            (identical(other.makeupRecommendations, makeupRecommendations) ||
                other.makeupRecommendations == makeupRecommendations) &&
            (identical(
                    other.luckyFeatureEnhancement, luckyFeatureEnhancement) ||
                other.luckyFeatureEnhancement == luckyFeatureEnhancement) &&
            (identical(other.leadershipAnalysis, leadershipAnalysis) ||
                other.leadershipAnalysis == leadershipAnalysis) &&
            (identical(other.watchData, watchData) ||
                other.watchData == watchData) &&
            (identical(other.shareableContent, shareableContent) ||
                other.shareableContent == shareableContent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        createdAt,
        gender,
        ageGroup,
        const DeepCollectionEquality().hash(_priorityInsights),
        overallScore,
        summaryMessage,
        overallFortune,
        faceType,
        faceCondition,
        emotionAnalysis,
        myeonggungAnalysis,
        miganAnalysis,
        simplifiedOgwan,
        simplifiedSibigung,
        const DeepCollectionEquality().hash(_celebrityMatches),
        makeupRecommendations,
        luckyFeatureEnhancement,
        leadershipAnalysis,
        watchData,
        shareableContent
      ]);

  /// Create a copy of FaceReadingResultV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FaceReadingResultV2ImplCopyWith<_$FaceReadingResultV2Impl> get copyWith =>
      __$$FaceReadingResultV2ImplCopyWithImpl<_$FaceReadingResultV2Impl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FaceReadingResultV2ImplToJson(
      this,
    );
  }
}

abstract class _FaceReadingResultV2 implements FaceReadingResultV2 {
  const factory _FaceReadingResultV2(
      {required final String id,
      required final String userId,
      required final DateTime createdAt,
      required final String gender,
      final String? ageGroup,
      final List<PriorityInsight> priorityInsights,
      required final int overallScore,
      required final String summaryMessage,
      final String overallFortune,
      final String faceType,
      final FaceCondition? faceCondition,
      final EmotionAnalysis? emotionAnalysis,
      final MyeonggungAnalysis? myeonggungAnalysis,
      final MiganAnalysis? miganAnalysis,
      final SimplifiedOgwan? simplifiedOgwan,
      final SimplifiedSibigung? simplifiedSibigung,
      final List<CelebrityMatch> celebrityMatches,
      final MakeupStyleRecommendations? makeupRecommendations,
      final LuckyFeatureEnhancement? luckyFeatureEnhancement,
      final LeadershipAnalysis? leadershipAnalysis,
      final WatchFaceReadingData? watchData,
      final ShareableContent? shareableContent}) = _$FaceReadingResultV2Impl;

  factory _FaceReadingResultV2.fromJson(Map<String, dynamic> json) =
      _$FaceReadingResultV2Impl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  DateTime get createdAt; // === 사용자 정보 ===
  @override
  String get gender; // 'male' | 'female'
  @override
  String? get ageGroup; // '20s', '30s', etc.
// === 핵심 요약 (기본 노출) ===
  /// 핵심 포인트 3가지 (성별에 따라 다른 내용)
  @override
  List<PriorityInsight> get priorityInsights;

  /// 종합 운세 점수 (0-100)
  @override
  int get overallScore;

  /// 한줄 요약 (친근한 말투)
  @override
  String get summaryMessage;

  /// 총평 (전체 운세 설명)
  @override
  String get overallFortune;

  /// 얼굴형 (타원형, 둥근형 등)
  @override
  String get faceType; // === 신규 분석 요소 ===
  /// 오늘의 얼굴 컨디션 (혈색, 붓기, 피로도)
  @override
  FaceCondition? get faceCondition;

  /// 감정 인식 분석 (미소, 긴장, 무표정 %)
  @override
  EmotionAnalysis? get emotionAnalysis; // === 전통 관상 분석 (접히는 섹션) ===
  /// 명궁 분석 (미간 → 명궁으로 순서 변경)
  @override
  MyeonggungAnalysis? get myeonggungAnalysis;

  /// 미간 분석
  @override
  MiganAnalysis? get miganAnalysis;

  /// 오관 분석 (요약형)
  @override
  SimplifiedOgwan? get simplifiedOgwan;

  /// 십이궁 분석 (요약형)
  @override
  SimplifiedSibigung? get simplifiedSibigung;

  /// 닮은꼴 연예인 목록
  @override
  List<CelebrityMatch> get celebrityMatches; // === 성별 특화 콘텐츠 ===
  /// 여성 전용: 스타일 추천
  @override
  MakeupStyleRecommendations? get makeupRecommendations;

  /// 여성 전용: 매력 포인트 강조
  @override
  LuckyFeatureEnhancement? get luckyFeatureEnhancement;

  /// 남성 전용: 리더십/직업 적합도
  @override
  LeadershipAnalysis? get leadershipAnalysis; // === Apple Watch 데이터 ===
  @override
  WatchFaceReadingData? get watchData; // === 공유용 데이터 ===
  @override
  ShareableContent? get shareableContent;

  /// Create a copy of FaceReadingResultV2
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FaceReadingResultV2ImplCopyWith<_$FaceReadingResultV2Impl> get copyWith =>
      throw _privateConstructorUsedError;
}

CelebrityMatch _$CelebrityMatchFromJson(Map<String, dynamic> json) {
  return _CelebrityMatch.fromJson(json);
}

/// @nodoc
mixin _$CelebrityMatch {
  /// 연예인 이름
  String get name => throw _privateConstructorUsedError;

  /// 유사도 점수 (0-100)
  int get matchScore => throw _privateConstructorUsedError;

  /// 이미지 URL (선택적)
  String? get imageUrl => throw _privateConstructorUsedError;

  /// 닮은 특징 설명
  String? get matchDescription => throw _privateConstructorUsedError;

  /// 공통 특징들
  List<String> get commonTraits => throw _privateConstructorUsedError;

  /// Serializes this CelebrityMatch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CelebrityMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CelebrityMatchCopyWith<CelebrityMatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CelebrityMatchCopyWith<$Res> {
  factory $CelebrityMatchCopyWith(
          CelebrityMatch value, $Res Function(CelebrityMatch) then) =
      _$CelebrityMatchCopyWithImpl<$Res, CelebrityMatch>;
  @useResult
  $Res call(
      {String name,
      int matchScore,
      String? imageUrl,
      String? matchDescription,
      List<String> commonTraits});
}

/// @nodoc
class _$CelebrityMatchCopyWithImpl<$Res, $Val extends CelebrityMatch>
    implements $CelebrityMatchCopyWith<$Res> {
  _$CelebrityMatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CelebrityMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? matchScore = null,
    Object? imageUrl = freezed,
    Object? matchDescription = freezed,
    Object? commonTraits = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      matchScore: null == matchScore
          ? _value.matchScore
          : matchScore // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      matchDescription: freezed == matchDescription
          ? _value.matchDescription
          : matchDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      commonTraits: null == commonTraits
          ? _value.commonTraits
          : commonTraits // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CelebrityMatchImplCopyWith<$Res>
    implements $CelebrityMatchCopyWith<$Res> {
  factory _$$CelebrityMatchImplCopyWith(_$CelebrityMatchImpl value,
          $Res Function(_$CelebrityMatchImpl) then) =
      __$$CelebrityMatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      int matchScore,
      String? imageUrl,
      String? matchDescription,
      List<String> commonTraits});
}

/// @nodoc
class __$$CelebrityMatchImplCopyWithImpl<$Res>
    extends _$CelebrityMatchCopyWithImpl<$Res, _$CelebrityMatchImpl>
    implements _$$CelebrityMatchImplCopyWith<$Res> {
  __$$CelebrityMatchImplCopyWithImpl(
      _$CelebrityMatchImpl _value, $Res Function(_$CelebrityMatchImpl) _then)
      : super(_value, _then);

  /// Create a copy of CelebrityMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? matchScore = null,
    Object? imageUrl = freezed,
    Object? matchDescription = freezed,
    Object? commonTraits = null,
  }) {
    return _then(_$CelebrityMatchImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      matchScore: null == matchScore
          ? _value.matchScore
          : matchScore // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      matchDescription: freezed == matchDescription
          ? _value.matchDescription
          : matchDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      commonTraits: null == commonTraits
          ? _value._commonTraits
          : commonTraits // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CelebrityMatchImpl implements _CelebrityMatch {
  const _$CelebrityMatchImpl(
      {required this.name,
      required this.matchScore,
      this.imageUrl,
      this.matchDescription,
      final List<String> commonTraits = const []})
      : _commonTraits = commonTraits;

  factory _$CelebrityMatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$CelebrityMatchImplFromJson(json);

  /// 연예인 이름
  @override
  final String name;

  /// 유사도 점수 (0-100)
  @override
  final int matchScore;

  /// 이미지 URL (선택적)
  @override
  final String? imageUrl;

  /// 닮은 특징 설명
  @override
  final String? matchDescription;

  /// 공통 특징들
  final List<String> _commonTraits;

  /// 공통 특징들
  @override
  @JsonKey()
  List<String> get commonTraits {
    if (_commonTraits is EqualUnmodifiableListView) return _commonTraits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_commonTraits);
  }

  @override
  String toString() {
    return 'CelebrityMatch(name: $name, matchScore: $matchScore, imageUrl: $imageUrl, matchDescription: $matchDescription, commonTraits: $commonTraits)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CelebrityMatchImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.matchScore, matchScore) ||
                other.matchScore == matchScore) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.matchDescription, matchDescription) ||
                other.matchDescription == matchDescription) &&
            const DeepCollectionEquality()
                .equals(other._commonTraits, _commonTraits));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, matchScore, imageUrl,
      matchDescription, const DeepCollectionEquality().hash(_commonTraits));

  /// Create a copy of CelebrityMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CelebrityMatchImplCopyWith<_$CelebrityMatchImpl> get copyWith =>
      __$$CelebrityMatchImplCopyWithImpl<_$CelebrityMatchImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CelebrityMatchImplToJson(
      this,
    );
  }
}

abstract class _CelebrityMatch implements CelebrityMatch {
  const factory _CelebrityMatch(
      {required final String name,
      required final int matchScore,
      final String? imageUrl,
      final String? matchDescription,
      final List<String> commonTraits}) = _$CelebrityMatchImpl;

  factory _CelebrityMatch.fromJson(Map<String, dynamic> json) =
      _$CelebrityMatchImpl.fromJson;

  /// 연예인 이름
  @override
  String get name;

  /// 유사도 점수 (0-100)
  @override
  int get matchScore;

  /// 이미지 URL (선택적)
  @override
  String? get imageUrl;

  /// 닮은 특징 설명
  @override
  String? get matchDescription;

  /// 공통 특징들
  @override
  List<String> get commonTraits;

  /// Create a copy of CelebrityMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CelebrityMatchImplCopyWith<_$CelebrityMatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MyeonggungAnalysis _$MyeonggungAnalysisFromJson(Map<String, dynamic> json) {
  return _MyeonggungAnalysis.fromJson(json);
}

/// @nodoc
mixin _$MyeonggungAnalysis {
  /// 명궁 상태 설명 (친근한 말투)
  String get description => throw _privateConstructorUsedError;

  /// 인생 전반 운세
  String get lifeFortuneMessage => throw _privateConstructorUsedError;

  /// 점수 (0-100)
  int get score => throw _privateConstructorUsedError;

  /// 한줄 요약 (접힌 상태에서 표시)
  String get summary => throw _privateConstructorUsedError;

  /// 상세 분석 (펼쳤을 때 표시)
  String? get detailedAnalysis => throw _privateConstructorUsedError;

  /// 운명 특성 태그
  List<String> get destinyTraits => throw _privateConstructorUsedError;

  /// 강점
  List<String> get strengths => throw _privateConstructorUsedError;

  /// 약점/주의점
  List<String> get weaknesses => throw _privateConstructorUsedError;

  /// 운을 높이는 조언
  String? get advice => throw _privateConstructorUsedError;

  /// 개선 팁
  List<String> get improvementTips => throw _privateConstructorUsedError;

  /// Serializes this MyeonggungAnalysis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MyeonggungAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MyeonggungAnalysisCopyWith<MyeonggungAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyeonggungAnalysisCopyWith<$Res> {
  factory $MyeonggungAnalysisCopyWith(
          MyeonggungAnalysis value, $Res Function(MyeonggungAnalysis) then) =
      _$MyeonggungAnalysisCopyWithImpl<$Res, MyeonggungAnalysis>;
  @useResult
  $Res call(
      {String description,
      String lifeFortuneMessage,
      int score,
      String summary,
      String? detailedAnalysis,
      List<String> destinyTraits,
      List<String> strengths,
      List<String> weaknesses,
      String? advice,
      List<String> improvementTips});
}

/// @nodoc
class _$MyeonggungAnalysisCopyWithImpl<$Res, $Val extends MyeonggungAnalysis>
    implements $MyeonggungAnalysisCopyWith<$Res> {
  _$MyeonggungAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MyeonggungAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = null,
    Object? lifeFortuneMessage = null,
    Object? score = null,
    Object? summary = null,
    Object? detailedAnalysis = freezed,
    Object? destinyTraits = null,
    Object? strengths = null,
    Object? weaknesses = null,
    Object? advice = freezed,
    Object? improvementTips = null,
  }) {
    return _then(_value.copyWith(
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      lifeFortuneMessage: null == lifeFortuneMessage
          ? _value.lifeFortuneMessage
          : lifeFortuneMessage // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      detailedAnalysis: freezed == detailedAnalysis
          ? _value.detailedAnalysis
          : detailedAnalysis // ignore: cast_nullable_to_non_nullable
              as String?,
      destinyTraits: null == destinyTraits
          ? _value.destinyTraits
          : destinyTraits // ignore: cast_nullable_to_non_nullable
              as List<String>,
      strengths: null == strengths
          ? _value.strengths
          : strengths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      weaknesses: null == weaknesses
          ? _value.weaknesses
          : weaknesses // ignore: cast_nullable_to_non_nullable
              as List<String>,
      advice: freezed == advice
          ? _value.advice
          : advice // ignore: cast_nullable_to_non_nullable
              as String?,
      improvementTips: null == improvementTips
          ? _value.improvementTips
          : improvementTips // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MyeonggungAnalysisImplCopyWith<$Res>
    implements $MyeonggungAnalysisCopyWith<$Res> {
  factory _$$MyeonggungAnalysisImplCopyWith(_$MyeonggungAnalysisImpl value,
          $Res Function(_$MyeonggungAnalysisImpl) then) =
      __$$MyeonggungAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String description,
      String lifeFortuneMessage,
      int score,
      String summary,
      String? detailedAnalysis,
      List<String> destinyTraits,
      List<String> strengths,
      List<String> weaknesses,
      String? advice,
      List<String> improvementTips});
}

/// @nodoc
class __$$MyeonggungAnalysisImplCopyWithImpl<$Res>
    extends _$MyeonggungAnalysisCopyWithImpl<$Res, _$MyeonggungAnalysisImpl>
    implements _$$MyeonggungAnalysisImplCopyWith<$Res> {
  __$$MyeonggungAnalysisImplCopyWithImpl(_$MyeonggungAnalysisImpl _value,
      $Res Function(_$MyeonggungAnalysisImpl) _then)
      : super(_value, _then);

  /// Create a copy of MyeonggungAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = null,
    Object? lifeFortuneMessage = null,
    Object? score = null,
    Object? summary = null,
    Object? detailedAnalysis = freezed,
    Object? destinyTraits = null,
    Object? strengths = null,
    Object? weaknesses = null,
    Object? advice = freezed,
    Object? improvementTips = null,
  }) {
    return _then(_$MyeonggungAnalysisImpl(
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      lifeFortuneMessage: null == lifeFortuneMessage
          ? _value.lifeFortuneMessage
          : lifeFortuneMessage // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      detailedAnalysis: freezed == detailedAnalysis
          ? _value.detailedAnalysis
          : detailedAnalysis // ignore: cast_nullable_to_non_nullable
              as String?,
      destinyTraits: null == destinyTraits
          ? _value._destinyTraits
          : destinyTraits // ignore: cast_nullable_to_non_nullable
              as List<String>,
      strengths: null == strengths
          ? _value._strengths
          : strengths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      weaknesses: null == weaknesses
          ? _value._weaknesses
          : weaknesses // ignore: cast_nullable_to_non_nullable
              as List<String>,
      advice: freezed == advice
          ? _value.advice
          : advice // ignore: cast_nullable_to_non_nullable
              as String?,
      improvementTips: null == improvementTips
          ? _value._improvementTips
          : improvementTips // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MyeonggungAnalysisImpl implements _MyeonggungAnalysis {
  const _$MyeonggungAnalysisImpl(
      {required this.description,
      required this.lifeFortuneMessage,
      required this.score,
      this.summary = '',
      this.detailedAnalysis,
      final List<String> destinyTraits = const [],
      final List<String> strengths = const [],
      final List<String> weaknesses = const [],
      this.advice,
      final List<String> improvementTips = const []})
      : _destinyTraits = destinyTraits,
        _strengths = strengths,
        _weaknesses = weaknesses,
        _improvementTips = improvementTips;

  factory _$MyeonggungAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$MyeonggungAnalysisImplFromJson(json);

  /// 명궁 상태 설명 (친근한 말투)
  @override
  final String description;

  /// 인생 전반 운세
  @override
  final String lifeFortuneMessage;

  /// 점수 (0-100)
  @override
  final int score;

  /// 한줄 요약 (접힌 상태에서 표시)
  @override
  @JsonKey()
  final String summary;

  /// 상세 분석 (펼쳤을 때 표시)
  @override
  final String? detailedAnalysis;

  /// 운명 특성 태그
  final List<String> _destinyTraits;

  /// 운명 특성 태그
  @override
  @JsonKey()
  List<String> get destinyTraits {
    if (_destinyTraits is EqualUnmodifiableListView) return _destinyTraits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_destinyTraits);
  }

  /// 강점
  final List<String> _strengths;

  /// 강점
  @override
  @JsonKey()
  List<String> get strengths {
    if (_strengths is EqualUnmodifiableListView) return _strengths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_strengths);
  }

  /// 약점/주의점
  final List<String> _weaknesses;

  /// 약점/주의점
  @override
  @JsonKey()
  List<String> get weaknesses {
    if (_weaknesses is EqualUnmodifiableListView) return _weaknesses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weaknesses);
  }

  /// 운을 높이는 조언
  @override
  final String? advice;

  /// 개선 팁
  final List<String> _improvementTips;

  /// 개선 팁
  @override
  @JsonKey()
  List<String> get improvementTips {
    if (_improvementTips is EqualUnmodifiableListView) return _improvementTips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_improvementTips);
  }

  @override
  String toString() {
    return 'MyeonggungAnalysis(description: $description, lifeFortuneMessage: $lifeFortuneMessage, score: $score, summary: $summary, detailedAnalysis: $detailedAnalysis, destinyTraits: $destinyTraits, strengths: $strengths, weaknesses: $weaknesses, advice: $advice, improvementTips: $improvementTips)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyeonggungAnalysisImpl &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.lifeFortuneMessage, lifeFortuneMessage) ||
                other.lifeFortuneMessage == lifeFortuneMessage) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.detailedAnalysis, detailedAnalysis) ||
                other.detailedAnalysis == detailedAnalysis) &&
            const DeepCollectionEquality()
                .equals(other._destinyTraits, _destinyTraits) &&
            const DeepCollectionEquality()
                .equals(other._strengths, _strengths) &&
            const DeepCollectionEquality()
                .equals(other._weaknesses, _weaknesses) &&
            (identical(other.advice, advice) || other.advice == advice) &&
            const DeepCollectionEquality()
                .equals(other._improvementTips, _improvementTips));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      description,
      lifeFortuneMessage,
      score,
      summary,
      detailedAnalysis,
      const DeepCollectionEquality().hash(_destinyTraits),
      const DeepCollectionEquality().hash(_strengths),
      const DeepCollectionEquality().hash(_weaknesses),
      advice,
      const DeepCollectionEquality().hash(_improvementTips));

  /// Create a copy of MyeonggungAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MyeonggungAnalysisImplCopyWith<_$MyeonggungAnalysisImpl> get copyWith =>
      __$$MyeonggungAnalysisImplCopyWithImpl<_$MyeonggungAnalysisImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MyeonggungAnalysisImplToJson(
      this,
    );
  }
}

abstract class _MyeonggungAnalysis implements MyeonggungAnalysis {
  const factory _MyeonggungAnalysis(
      {required final String description,
      required final String lifeFortuneMessage,
      required final int score,
      final String summary,
      final String? detailedAnalysis,
      final List<String> destinyTraits,
      final List<String> strengths,
      final List<String> weaknesses,
      final String? advice,
      final List<String> improvementTips}) = _$MyeonggungAnalysisImpl;

  factory _MyeonggungAnalysis.fromJson(Map<String, dynamic> json) =
      _$MyeonggungAnalysisImpl.fromJson;

  /// 명궁 상태 설명 (친근한 말투)
  @override
  String get description;

  /// 인생 전반 운세
  @override
  String get lifeFortuneMessage;

  /// 점수 (0-100)
  @override
  int get score;

  /// 한줄 요약 (접힌 상태에서 표시)
  @override
  String get summary;

  /// 상세 분석 (펼쳤을 때 표시)
  @override
  String? get detailedAnalysis;

  /// 운명 특성 태그
  @override
  List<String> get destinyTraits;

  /// 강점
  @override
  List<String> get strengths;

  /// 약점/주의점
  @override
  List<String> get weaknesses;

  /// 운을 높이는 조언
  @override
  String? get advice;

  /// 개선 팁
  @override
  List<String> get improvementTips;

  /// Create a copy of MyeonggungAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MyeonggungAnalysisImplCopyWith<_$MyeonggungAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MiganAnalysis _$MiganAnalysisFromJson(Map<String, dynamic> json) {
  return _MiganAnalysis.fromJson(json);
}

/// @nodoc
mixin _$MiganAnalysis {
  /// 미간 상태 설명 (친근한 말투)
  String get description => throw _privateConstructorUsedError;

  /// 관련 운세 메시지
  String get fortuneMessage => throw _privateConstructorUsedError;

  /// 점수 (0-100)
  int get score => throw _privateConstructorUsedError;

  /// 한줄 요약 (접힌 상태에서 표시)
  String get summary => throw _privateConstructorUsedError;

  /// 상세 분석 (펼쳤을 때 표시)
  String? get detailedAnalysis => throw _privateConstructorUsedError;

  /// 적성 분야 목록
  List<String> get careerAptitudes => throw _privateConstructorUsedError;

  /// 추천 분야
  List<String> get recommendedFields => throw _privateConstructorUsedError;

  /// 성취 스타일 설명
  String? get achievementStyle => throw _privateConstructorUsedError;

  /// 주의사항
  List<String> get cautions => throw _privateConstructorUsedError;

  /// 조언
  String? get advice => throw _privateConstructorUsedError;

  /// Serializes this MiganAnalysis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MiganAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MiganAnalysisCopyWith<MiganAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MiganAnalysisCopyWith<$Res> {
  factory $MiganAnalysisCopyWith(
          MiganAnalysis value, $Res Function(MiganAnalysis) then) =
      _$MiganAnalysisCopyWithImpl<$Res, MiganAnalysis>;
  @useResult
  $Res call(
      {String description,
      String fortuneMessage,
      int score,
      String summary,
      String? detailedAnalysis,
      List<String> careerAptitudes,
      List<String> recommendedFields,
      String? achievementStyle,
      List<String> cautions,
      String? advice});
}

/// @nodoc
class _$MiganAnalysisCopyWithImpl<$Res, $Val extends MiganAnalysis>
    implements $MiganAnalysisCopyWith<$Res> {
  _$MiganAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MiganAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = null,
    Object? fortuneMessage = null,
    Object? score = null,
    Object? summary = null,
    Object? detailedAnalysis = freezed,
    Object? careerAptitudes = null,
    Object? recommendedFields = null,
    Object? achievementStyle = freezed,
    Object? cautions = null,
    Object? advice = freezed,
  }) {
    return _then(_value.copyWith(
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      fortuneMessage: null == fortuneMessage
          ? _value.fortuneMessage
          : fortuneMessage // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      detailedAnalysis: freezed == detailedAnalysis
          ? _value.detailedAnalysis
          : detailedAnalysis // ignore: cast_nullable_to_non_nullable
              as String?,
      careerAptitudes: null == careerAptitudes
          ? _value.careerAptitudes
          : careerAptitudes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recommendedFields: null == recommendedFields
          ? _value.recommendedFields
          : recommendedFields // ignore: cast_nullable_to_non_nullable
              as List<String>,
      achievementStyle: freezed == achievementStyle
          ? _value.achievementStyle
          : achievementStyle // ignore: cast_nullable_to_non_nullable
              as String?,
      cautions: null == cautions
          ? _value.cautions
          : cautions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      advice: freezed == advice
          ? _value.advice
          : advice // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MiganAnalysisImplCopyWith<$Res>
    implements $MiganAnalysisCopyWith<$Res> {
  factory _$$MiganAnalysisImplCopyWith(
          _$MiganAnalysisImpl value, $Res Function(_$MiganAnalysisImpl) then) =
      __$$MiganAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String description,
      String fortuneMessage,
      int score,
      String summary,
      String? detailedAnalysis,
      List<String> careerAptitudes,
      List<String> recommendedFields,
      String? achievementStyle,
      List<String> cautions,
      String? advice});
}

/// @nodoc
class __$$MiganAnalysisImplCopyWithImpl<$Res>
    extends _$MiganAnalysisCopyWithImpl<$Res, _$MiganAnalysisImpl>
    implements _$$MiganAnalysisImplCopyWith<$Res> {
  __$$MiganAnalysisImplCopyWithImpl(
      _$MiganAnalysisImpl _value, $Res Function(_$MiganAnalysisImpl) _then)
      : super(_value, _then);

  /// Create a copy of MiganAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = null,
    Object? fortuneMessage = null,
    Object? score = null,
    Object? summary = null,
    Object? detailedAnalysis = freezed,
    Object? careerAptitudes = null,
    Object? recommendedFields = null,
    Object? achievementStyle = freezed,
    Object? cautions = null,
    Object? advice = freezed,
  }) {
    return _then(_$MiganAnalysisImpl(
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      fortuneMessage: null == fortuneMessage
          ? _value.fortuneMessage
          : fortuneMessage // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      detailedAnalysis: freezed == detailedAnalysis
          ? _value.detailedAnalysis
          : detailedAnalysis // ignore: cast_nullable_to_non_nullable
              as String?,
      careerAptitudes: null == careerAptitudes
          ? _value._careerAptitudes
          : careerAptitudes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recommendedFields: null == recommendedFields
          ? _value._recommendedFields
          : recommendedFields // ignore: cast_nullable_to_non_nullable
              as List<String>,
      achievementStyle: freezed == achievementStyle
          ? _value.achievementStyle
          : achievementStyle // ignore: cast_nullable_to_non_nullable
              as String?,
      cautions: null == cautions
          ? _value._cautions
          : cautions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      advice: freezed == advice
          ? _value.advice
          : advice // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MiganAnalysisImpl implements _MiganAnalysis {
  const _$MiganAnalysisImpl(
      {required this.description,
      required this.fortuneMessage,
      required this.score,
      this.summary = '',
      this.detailedAnalysis,
      final List<String> careerAptitudes = const [],
      final List<String> recommendedFields = const [],
      this.achievementStyle,
      final List<String> cautions = const [],
      this.advice})
      : _careerAptitudes = careerAptitudes,
        _recommendedFields = recommendedFields,
        _cautions = cautions;

  factory _$MiganAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$MiganAnalysisImplFromJson(json);

  /// 미간 상태 설명 (친근한 말투)
  @override
  final String description;

  /// 관련 운세 메시지
  @override
  final String fortuneMessage;

  /// 점수 (0-100)
  @override
  final int score;

  /// 한줄 요약 (접힌 상태에서 표시)
  @override
  @JsonKey()
  final String summary;

  /// 상세 분석 (펼쳤을 때 표시)
  @override
  final String? detailedAnalysis;

  /// 적성 분야 목록
  final List<String> _careerAptitudes;

  /// 적성 분야 목록
  @override
  @JsonKey()
  List<String> get careerAptitudes {
    if (_careerAptitudes is EqualUnmodifiableListView) return _careerAptitudes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_careerAptitudes);
  }

  /// 추천 분야
  final List<String> _recommendedFields;

  /// 추천 분야
  @override
  @JsonKey()
  List<String> get recommendedFields {
    if (_recommendedFields is EqualUnmodifiableListView)
      return _recommendedFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendedFields);
  }

  /// 성취 스타일 설명
  @override
  final String? achievementStyle;

  /// 주의사항
  final List<String> _cautions;

  /// 주의사항
  @override
  @JsonKey()
  List<String> get cautions {
    if (_cautions is EqualUnmodifiableListView) return _cautions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cautions);
  }

  /// 조언
  @override
  final String? advice;

  @override
  String toString() {
    return 'MiganAnalysis(description: $description, fortuneMessage: $fortuneMessage, score: $score, summary: $summary, detailedAnalysis: $detailedAnalysis, careerAptitudes: $careerAptitudes, recommendedFields: $recommendedFields, achievementStyle: $achievementStyle, cautions: $cautions, advice: $advice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MiganAnalysisImpl &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.fortuneMessage, fortuneMessage) ||
                other.fortuneMessage == fortuneMessage) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.detailedAnalysis, detailedAnalysis) ||
                other.detailedAnalysis == detailedAnalysis) &&
            const DeepCollectionEquality()
                .equals(other._careerAptitudes, _careerAptitudes) &&
            const DeepCollectionEquality()
                .equals(other._recommendedFields, _recommendedFields) &&
            (identical(other.achievementStyle, achievementStyle) ||
                other.achievementStyle == achievementStyle) &&
            const DeepCollectionEquality().equals(other._cautions, _cautions) &&
            (identical(other.advice, advice) || other.advice == advice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      description,
      fortuneMessage,
      score,
      summary,
      detailedAnalysis,
      const DeepCollectionEquality().hash(_careerAptitudes),
      const DeepCollectionEquality().hash(_recommendedFields),
      achievementStyle,
      const DeepCollectionEquality().hash(_cautions),
      advice);

  /// Create a copy of MiganAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MiganAnalysisImplCopyWith<_$MiganAnalysisImpl> get copyWith =>
      __$$MiganAnalysisImplCopyWithImpl<_$MiganAnalysisImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MiganAnalysisImplToJson(
      this,
    );
  }
}

abstract class _MiganAnalysis implements MiganAnalysis {
  const factory _MiganAnalysis(
      {required final String description,
      required final String fortuneMessage,
      required final int score,
      final String summary,
      final String? detailedAnalysis,
      final List<String> careerAptitudes,
      final List<String> recommendedFields,
      final String? achievementStyle,
      final List<String> cautions,
      final String? advice}) = _$MiganAnalysisImpl;

  factory _MiganAnalysis.fromJson(Map<String, dynamic> json) =
      _$MiganAnalysisImpl.fromJson;

  /// 미간 상태 설명 (친근한 말투)
  @override
  String get description;

  /// 관련 운세 메시지
  @override
  String get fortuneMessage;

  /// 점수 (0-100)
  @override
  int get score;

  /// 한줄 요약 (접힌 상태에서 표시)
  @override
  String get summary;

  /// 상세 분석 (펼쳤을 때 표시)
  @override
  String? get detailedAnalysis;

  /// 적성 분야 목록
  @override
  List<String> get careerAptitudes;

  /// 추천 분야
  @override
  List<String> get recommendedFields;

  /// 성취 스타일 설명
  @override
  String? get achievementStyle;

  /// 주의사항
  @override
  List<String> get cautions;

  /// 조언
  @override
  String? get advice;

  /// Create a copy of MiganAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MiganAnalysisImplCopyWith<_$MiganAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SimplifiedOgwan _$SimplifiedOgwanFromJson(Map<String, dynamic> json) {
  return _SimplifiedOgwan.fromJson(json);
}

/// @nodoc
mixin _$SimplifiedOgwan {
  /// 오관 항목들
  List<SimplifiedOgwanItem> get items => throw _privateConstructorUsedError;

  /// 종합 요약 (친근한 말투)
  String get summary => throw _privateConstructorUsedError;

  /// 가장 좋은 부위
  String get bestFeature => throw _privateConstructorUsedError;

  /// 주의가 필요한 부위
  String? get cautionFeature => throw _privateConstructorUsedError;

  /// Serializes this SimplifiedOgwan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SimplifiedOgwan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SimplifiedOgwanCopyWith<SimplifiedOgwan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimplifiedOgwanCopyWith<$Res> {
  factory $SimplifiedOgwanCopyWith(
          SimplifiedOgwan value, $Res Function(SimplifiedOgwan) then) =
      _$SimplifiedOgwanCopyWithImpl<$Res, SimplifiedOgwan>;
  @useResult
  $Res call(
      {List<SimplifiedOgwanItem> items,
      String summary,
      String bestFeature,
      String? cautionFeature});
}

/// @nodoc
class _$SimplifiedOgwanCopyWithImpl<$Res, $Val extends SimplifiedOgwan>
    implements $SimplifiedOgwanCopyWith<$Res> {
  _$SimplifiedOgwanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimplifiedOgwan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? summary = null,
    Object? bestFeature = null,
    Object? cautionFeature = freezed,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<SimplifiedOgwanItem>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      bestFeature: null == bestFeature
          ? _value.bestFeature
          : bestFeature // ignore: cast_nullable_to_non_nullable
              as String,
      cautionFeature: freezed == cautionFeature
          ? _value.cautionFeature
          : cautionFeature // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SimplifiedOgwanImplCopyWith<$Res>
    implements $SimplifiedOgwanCopyWith<$Res> {
  factory _$$SimplifiedOgwanImplCopyWith(_$SimplifiedOgwanImpl value,
          $Res Function(_$SimplifiedOgwanImpl) then) =
      __$$SimplifiedOgwanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<SimplifiedOgwanItem> items,
      String summary,
      String bestFeature,
      String? cautionFeature});
}

/// @nodoc
class __$$SimplifiedOgwanImplCopyWithImpl<$Res>
    extends _$SimplifiedOgwanCopyWithImpl<$Res, _$SimplifiedOgwanImpl>
    implements _$$SimplifiedOgwanImplCopyWith<$Res> {
  __$$SimplifiedOgwanImplCopyWithImpl(
      _$SimplifiedOgwanImpl _value, $Res Function(_$SimplifiedOgwanImpl) _then)
      : super(_value, _then);

  /// Create a copy of SimplifiedOgwan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? summary = null,
    Object? bestFeature = null,
    Object? cautionFeature = freezed,
  }) {
    return _then(_$SimplifiedOgwanImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<SimplifiedOgwanItem>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      bestFeature: null == bestFeature
          ? _value.bestFeature
          : bestFeature // ignore: cast_nullable_to_non_nullable
              as String,
      cautionFeature: freezed == cautionFeature
          ? _value.cautionFeature
          : cautionFeature // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SimplifiedOgwanImpl implements _SimplifiedOgwan {
  const _$SimplifiedOgwanImpl(
      {required final List<SimplifiedOgwanItem> items,
      required this.summary,
      required this.bestFeature,
      this.cautionFeature})
      : _items = items;

  factory _$SimplifiedOgwanImpl.fromJson(Map<String, dynamic> json) =>
      _$$SimplifiedOgwanImplFromJson(json);

  /// 오관 항목들
  final List<SimplifiedOgwanItem> _items;

  /// 오관 항목들
  @override
  List<SimplifiedOgwanItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// 종합 요약 (친근한 말투)
  @override
  final String summary;

  /// 가장 좋은 부위
  @override
  final String bestFeature;

  /// 주의가 필요한 부위
  @override
  final String? cautionFeature;

  @override
  String toString() {
    return 'SimplifiedOgwan(items: $items, summary: $summary, bestFeature: $bestFeature, cautionFeature: $cautionFeature)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimplifiedOgwanImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.bestFeature, bestFeature) ||
                other.bestFeature == bestFeature) &&
            (identical(other.cautionFeature, cautionFeature) ||
                other.cautionFeature == cautionFeature));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      summary,
      bestFeature,
      cautionFeature);

  /// Create a copy of SimplifiedOgwan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimplifiedOgwanImplCopyWith<_$SimplifiedOgwanImpl> get copyWith =>
      __$$SimplifiedOgwanImplCopyWithImpl<_$SimplifiedOgwanImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SimplifiedOgwanImplToJson(
      this,
    );
  }
}

abstract class _SimplifiedOgwan implements SimplifiedOgwan {
  const factory _SimplifiedOgwan(
      {required final List<SimplifiedOgwanItem> items,
      required final String summary,
      required final String bestFeature,
      final String? cautionFeature}) = _$SimplifiedOgwanImpl;

  factory _SimplifiedOgwan.fromJson(Map<String, dynamic> json) =
      _$SimplifiedOgwanImpl.fromJson;

  /// 오관 항목들
  @override
  List<SimplifiedOgwanItem> get items;

  /// 종합 요약 (친근한 말투)
  @override
  String get summary;

  /// 가장 좋은 부위
  @override
  String get bestFeature;

  /// 주의가 필요한 부위
  @override
  String? get cautionFeature;

  /// Create a copy of SimplifiedOgwan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimplifiedOgwanImplCopyWith<_$SimplifiedOgwanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SimplifiedOgwanItem _$SimplifiedOgwanItemFromJson(Map<String, dynamic> json) {
  return _SimplifiedOgwanItem.fromJson(json);
}

/// @nodoc
mixin _$SimplifiedOgwanItem {
  /// 부위 이름 (눈, 코, 입, 귀, 눈썹)
  String get featureName => throw _privateConstructorUsedError;

  /// 부위 ID (eyes, nose, mouth, ears, eyebrows)
  String get featureId => throw _privateConstructorUsedError;

  /// 관련 운세 카테고리 (인간관계, 재물운, 결혼운 등)
  String get fortuneCategory => throw _privateConstructorUsedError;

  /// 한줄 요약 (친근한 말투)
  String get summary => throw _privateConstructorUsedError;

  /// 점수 (0-100)
  int get score => throw _privateConstructorUsedError;

  /// 상세 분석 (펼쳤을 때)
  String? get detailedAnalysis => throw _privateConstructorUsedError;

  /// 이모지
  String get emoji => throw _privateConstructorUsedError;

  /// Serializes this SimplifiedOgwanItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SimplifiedOgwanItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SimplifiedOgwanItemCopyWith<SimplifiedOgwanItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimplifiedOgwanItemCopyWith<$Res> {
  factory $SimplifiedOgwanItemCopyWith(
          SimplifiedOgwanItem value, $Res Function(SimplifiedOgwanItem) then) =
      _$SimplifiedOgwanItemCopyWithImpl<$Res, SimplifiedOgwanItem>;
  @useResult
  $Res call(
      {String featureName,
      String featureId,
      String fortuneCategory,
      String summary,
      int score,
      String? detailedAnalysis,
      String emoji});
}

/// @nodoc
class _$SimplifiedOgwanItemCopyWithImpl<$Res, $Val extends SimplifiedOgwanItem>
    implements $SimplifiedOgwanItemCopyWith<$Res> {
  _$SimplifiedOgwanItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimplifiedOgwanItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? featureName = null,
    Object? featureId = null,
    Object? fortuneCategory = null,
    Object? summary = null,
    Object? score = null,
    Object? detailedAnalysis = freezed,
    Object? emoji = null,
  }) {
    return _then(_value.copyWith(
      featureName: null == featureName
          ? _value.featureName
          : featureName // ignore: cast_nullable_to_non_nullable
              as String,
      featureId: null == featureId
          ? _value.featureId
          : featureId // ignore: cast_nullable_to_non_nullable
              as String,
      fortuneCategory: null == fortuneCategory
          ? _value.fortuneCategory
          : fortuneCategory // ignore: cast_nullable_to_non_nullable
              as String,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      detailedAnalysis: freezed == detailedAnalysis
          ? _value.detailedAnalysis
          : detailedAnalysis // ignore: cast_nullable_to_non_nullable
              as String?,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SimplifiedOgwanItemImplCopyWith<$Res>
    implements $SimplifiedOgwanItemCopyWith<$Res> {
  factory _$$SimplifiedOgwanItemImplCopyWith(_$SimplifiedOgwanItemImpl value,
          $Res Function(_$SimplifiedOgwanItemImpl) then) =
      __$$SimplifiedOgwanItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String featureName,
      String featureId,
      String fortuneCategory,
      String summary,
      int score,
      String? detailedAnalysis,
      String emoji});
}

/// @nodoc
class __$$SimplifiedOgwanItemImplCopyWithImpl<$Res>
    extends _$SimplifiedOgwanItemCopyWithImpl<$Res, _$SimplifiedOgwanItemImpl>
    implements _$$SimplifiedOgwanItemImplCopyWith<$Res> {
  __$$SimplifiedOgwanItemImplCopyWithImpl(_$SimplifiedOgwanItemImpl _value,
      $Res Function(_$SimplifiedOgwanItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of SimplifiedOgwanItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? featureName = null,
    Object? featureId = null,
    Object? fortuneCategory = null,
    Object? summary = null,
    Object? score = null,
    Object? detailedAnalysis = freezed,
    Object? emoji = null,
  }) {
    return _then(_$SimplifiedOgwanItemImpl(
      featureName: null == featureName
          ? _value.featureName
          : featureName // ignore: cast_nullable_to_non_nullable
              as String,
      featureId: null == featureId
          ? _value.featureId
          : featureId // ignore: cast_nullable_to_non_nullable
              as String,
      fortuneCategory: null == fortuneCategory
          ? _value.fortuneCategory
          : fortuneCategory // ignore: cast_nullable_to_non_nullable
              as String,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      detailedAnalysis: freezed == detailedAnalysis
          ? _value.detailedAnalysis
          : detailedAnalysis // ignore: cast_nullable_to_non_nullable
              as String?,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SimplifiedOgwanItemImpl implements _SimplifiedOgwanItem {
  const _$SimplifiedOgwanItemImpl(
      {required this.featureName,
      required this.featureId,
      required this.fortuneCategory,
      required this.summary,
      required this.score,
      this.detailedAnalysis,
      this.emoji = ''});

  factory _$SimplifiedOgwanItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SimplifiedOgwanItemImplFromJson(json);

  /// 부위 이름 (눈, 코, 입, 귀, 눈썹)
  @override
  final String featureName;

  /// 부위 ID (eyes, nose, mouth, ears, eyebrows)
  @override
  final String featureId;

  /// 관련 운세 카테고리 (인간관계, 재물운, 결혼운 등)
  @override
  final String fortuneCategory;

  /// 한줄 요약 (친근한 말투)
  @override
  final String summary;

  /// 점수 (0-100)
  @override
  final int score;

  /// 상세 분석 (펼쳤을 때)
  @override
  final String? detailedAnalysis;

  /// 이모지
  @override
  @JsonKey()
  final String emoji;

  @override
  String toString() {
    return 'SimplifiedOgwanItem(featureName: $featureName, featureId: $featureId, fortuneCategory: $fortuneCategory, summary: $summary, score: $score, detailedAnalysis: $detailedAnalysis, emoji: $emoji)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimplifiedOgwanItemImpl &&
            (identical(other.featureName, featureName) ||
                other.featureName == featureName) &&
            (identical(other.featureId, featureId) ||
                other.featureId == featureId) &&
            (identical(other.fortuneCategory, fortuneCategory) ||
                other.fortuneCategory == fortuneCategory) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.detailedAnalysis, detailedAnalysis) ||
                other.detailedAnalysis == detailedAnalysis) &&
            (identical(other.emoji, emoji) || other.emoji == emoji));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, featureName, featureId,
      fortuneCategory, summary, score, detailedAnalysis, emoji);

  /// Create a copy of SimplifiedOgwanItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimplifiedOgwanItemImplCopyWith<_$SimplifiedOgwanItemImpl> get copyWith =>
      __$$SimplifiedOgwanItemImplCopyWithImpl<_$SimplifiedOgwanItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SimplifiedOgwanItemImplToJson(
      this,
    );
  }
}

abstract class _SimplifiedOgwanItem implements SimplifiedOgwanItem {
  const factory _SimplifiedOgwanItem(
      {required final String featureName,
      required final String featureId,
      required final String fortuneCategory,
      required final String summary,
      required final int score,
      final String? detailedAnalysis,
      final String emoji}) = _$SimplifiedOgwanItemImpl;

  factory _SimplifiedOgwanItem.fromJson(Map<String, dynamic> json) =
      _$SimplifiedOgwanItemImpl.fromJson;

  /// 부위 이름 (눈, 코, 입, 귀, 눈썹)
  @override
  String get featureName;

  /// 부위 ID (eyes, nose, mouth, ears, eyebrows)
  @override
  String get featureId;

  /// 관련 운세 카테고리 (인간관계, 재물운, 결혼운 등)
  @override
  String get fortuneCategory;

  /// 한줄 요약 (친근한 말투)
  @override
  String get summary;

  /// 점수 (0-100)
  @override
  int get score;

  /// 상세 분석 (펼쳤을 때)
  @override
  String? get detailedAnalysis;

  /// 이모지
  @override
  String get emoji;

  /// Create a copy of SimplifiedOgwanItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimplifiedOgwanItemImplCopyWith<_$SimplifiedOgwanItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SimplifiedSibigung _$SimplifiedSibigungFromJson(Map<String, dynamic> json) {
  return _SimplifiedSibigung.fromJson(json);
}

/// @nodoc
mixin _$SimplifiedSibigung {
  /// 십이궁 항목들
  List<SimplifiedSibigungItem> get items => throw _privateConstructorUsedError;

  /// 종합 요약 (친근한 말투)
  String get summary => throw _privateConstructorUsedError;

  /// 가장 강한 궁
  String get strongestPalace => throw _privateConstructorUsedError;

  /// 주의가 필요한 궁
  String? get cautionPalace => throw _privateConstructorUsedError;

  /// Serializes this SimplifiedSibigung to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SimplifiedSibigung
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SimplifiedSibigungCopyWith<SimplifiedSibigung> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimplifiedSibigungCopyWith<$Res> {
  factory $SimplifiedSibigungCopyWith(
          SimplifiedSibigung value, $Res Function(SimplifiedSibigung) then) =
      _$SimplifiedSibigungCopyWithImpl<$Res, SimplifiedSibigung>;
  @useResult
  $Res call(
      {List<SimplifiedSibigungItem> items,
      String summary,
      String strongestPalace,
      String? cautionPalace});
}

/// @nodoc
class _$SimplifiedSibigungCopyWithImpl<$Res, $Val extends SimplifiedSibigung>
    implements $SimplifiedSibigungCopyWith<$Res> {
  _$SimplifiedSibigungCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimplifiedSibigung
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? summary = null,
    Object? strongestPalace = null,
    Object? cautionPalace = freezed,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<SimplifiedSibigungItem>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      strongestPalace: null == strongestPalace
          ? _value.strongestPalace
          : strongestPalace // ignore: cast_nullable_to_non_nullable
              as String,
      cautionPalace: freezed == cautionPalace
          ? _value.cautionPalace
          : cautionPalace // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SimplifiedSibigungImplCopyWith<$Res>
    implements $SimplifiedSibigungCopyWith<$Res> {
  factory _$$SimplifiedSibigungImplCopyWith(_$SimplifiedSibigungImpl value,
          $Res Function(_$SimplifiedSibigungImpl) then) =
      __$$SimplifiedSibigungImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<SimplifiedSibigungItem> items,
      String summary,
      String strongestPalace,
      String? cautionPalace});
}

/// @nodoc
class __$$SimplifiedSibigungImplCopyWithImpl<$Res>
    extends _$SimplifiedSibigungCopyWithImpl<$Res, _$SimplifiedSibigungImpl>
    implements _$$SimplifiedSibigungImplCopyWith<$Res> {
  __$$SimplifiedSibigungImplCopyWithImpl(_$SimplifiedSibigungImpl _value,
      $Res Function(_$SimplifiedSibigungImpl) _then)
      : super(_value, _then);

  /// Create a copy of SimplifiedSibigung
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? summary = null,
    Object? strongestPalace = null,
    Object? cautionPalace = freezed,
  }) {
    return _then(_$SimplifiedSibigungImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<SimplifiedSibigungItem>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      strongestPalace: null == strongestPalace
          ? _value.strongestPalace
          : strongestPalace // ignore: cast_nullable_to_non_nullable
              as String,
      cautionPalace: freezed == cautionPalace
          ? _value.cautionPalace
          : cautionPalace // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SimplifiedSibigungImpl implements _SimplifiedSibigung {
  const _$SimplifiedSibigungImpl(
      {required final List<SimplifiedSibigungItem> items,
      required this.summary,
      required this.strongestPalace,
      this.cautionPalace})
      : _items = items;

  factory _$SimplifiedSibigungImpl.fromJson(Map<String, dynamic> json) =>
      _$$SimplifiedSibigungImplFromJson(json);

  /// 십이궁 항목들
  final List<SimplifiedSibigungItem> _items;

  /// 십이궁 항목들
  @override
  List<SimplifiedSibigungItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// 종합 요약 (친근한 말투)
  @override
  final String summary;

  /// 가장 강한 궁
  @override
  final String strongestPalace;

  /// 주의가 필요한 궁
  @override
  final String? cautionPalace;

  @override
  String toString() {
    return 'SimplifiedSibigung(items: $items, summary: $summary, strongestPalace: $strongestPalace, cautionPalace: $cautionPalace)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimplifiedSibigungImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.strongestPalace, strongestPalace) ||
                other.strongestPalace == strongestPalace) &&
            (identical(other.cautionPalace, cautionPalace) ||
                other.cautionPalace == cautionPalace));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      summary,
      strongestPalace,
      cautionPalace);

  /// Create a copy of SimplifiedSibigung
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimplifiedSibigungImplCopyWith<_$SimplifiedSibigungImpl> get copyWith =>
      __$$SimplifiedSibigungImplCopyWithImpl<_$SimplifiedSibigungImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SimplifiedSibigungImplToJson(
      this,
    );
  }
}

abstract class _SimplifiedSibigung implements SimplifiedSibigung {
  const factory _SimplifiedSibigung(
      {required final List<SimplifiedSibigungItem> items,
      required final String summary,
      required final String strongestPalace,
      final String? cautionPalace}) = _$SimplifiedSibigungImpl;

  factory _SimplifiedSibigung.fromJson(Map<String, dynamic> json) =
      _$SimplifiedSibigungImpl.fromJson;

  /// 십이궁 항목들
  @override
  List<SimplifiedSibigungItem> get items;

  /// 종합 요약 (친근한 말투)
  @override
  String get summary;

  /// 가장 강한 궁
  @override
  String get strongestPalace;

  /// 주의가 필요한 궁
  @override
  String? get cautionPalace;

  /// Create a copy of SimplifiedSibigung
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimplifiedSibigungImplCopyWith<_$SimplifiedSibigungImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SimplifiedSibigungItem _$SimplifiedSibigungItemFromJson(
    Map<String, dynamic> json) {
  return _SimplifiedSibigungItem.fromJson(json);
}

/// @nodoc
mixin _$SimplifiedSibigungItem {
  /// 궁 이름 (명궁, 재백궁, 형제궁 등)
  String get palaceName => throw _privateConstructorUsedError;

  /// 궁 ID
  String get palaceId => throw _privateConstructorUsedError;

  /// 관련 분야 (인생 전반, 재물, 형제 관계 등)
  String get relatedArea => throw _privateConstructorUsedError;

  /// 한줄 요약 (친근한 말투)
  String get summary => throw _privateConstructorUsedError;

  /// 점수 (0-100)
  int get score => throw _privateConstructorUsedError;

  /// 상세 분석 (펼쳤을 때)
  String? get detailedAnalysis => throw _privateConstructorUsedError;

  /// 이모지
  String get emoji => throw _privateConstructorUsedError;

  /// Serializes this SimplifiedSibigungItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SimplifiedSibigungItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SimplifiedSibigungItemCopyWith<SimplifiedSibigungItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimplifiedSibigungItemCopyWith<$Res> {
  factory $SimplifiedSibigungItemCopyWith(SimplifiedSibigungItem value,
          $Res Function(SimplifiedSibigungItem) then) =
      _$SimplifiedSibigungItemCopyWithImpl<$Res, SimplifiedSibigungItem>;
  @useResult
  $Res call(
      {String palaceName,
      String palaceId,
      String relatedArea,
      String summary,
      int score,
      String? detailedAnalysis,
      String emoji});
}

/// @nodoc
class _$SimplifiedSibigungItemCopyWithImpl<$Res,
        $Val extends SimplifiedSibigungItem>
    implements $SimplifiedSibigungItemCopyWith<$Res> {
  _$SimplifiedSibigungItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimplifiedSibigungItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? palaceName = null,
    Object? palaceId = null,
    Object? relatedArea = null,
    Object? summary = null,
    Object? score = null,
    Object? detailedAnalysis = freezed,
    Object? emoji = null,
  }) {
    return _then(_value.copyWith(
      palaceName: null == palaceName
          ? _value.palaceName
          : palaceName // ignore: cast_nullable_to_non_nullable
              as String,
      palaceId: null == palaceId
          ? _value.palaceId
          : palaceId // ignore: cast_nullable_to_non_nullable
              as String,
      relatedArea: null == relatedArea
          ? _value.relatedArea
          : relatedArea // ignore: cast_nullable_to_non_nullable
              as String,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      detailedAnalysis: freezed == detailedAnalysis
          ? _value.detailedAnalysis
          : detailedAnalysis // ignore: cast_nullable_to_non_nullable
              as String?,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SimplifiedSibigungItemImplCopyWith<$Res>
    implements $SimplifiedSibigungItemCopyWith<$Res> {
  factory _$$SimplifiedSibigungItemImplCopyWith(
          _$SimplifiedSibigungItemImpl value,
          $Res Function(_$SimplifiedSibigungItemImpl) then) =
      __$$SimplifiedSibigungItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String palaceName,
      String palaceId,
      String relatedArea,
      String summary,
      int score,
      String? detailedAnalysis,
      String emoji});
}

/// @nodoc
class __$$SimplifiedSibigungItemImplCopyWithImpl<$Res>
    extends _$SimplifiedSibigungItemCopyWithImpl<$Res,
        _$SimplifiedSibigungItemImpl>
    implements _$$SimplifiedSibigungItemImplCopyWith<$Res> {
  __$$SimplifiedSibigungItemImplCopyWithImpl(
      _$SimplifiedSibigungItemImpl _value,
      $Res Function(_$SimplifiedSibigungItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of SimplifiedSibigungItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? palaceName = null,
    Object? palaceId = null,
    Object? relatedArea = null,
    Object? summary = null,
    Object? score = null,
    Object? detailedAnalysis = freezed,
    Object? emoji = null,
  }) {
    return _then(_$SimplifiedSibigungItemImpl(
      palaceName: null == palaceName
          ? _value.palaceName
          : palaceName // ignore: cast_nullable_to_non_nullable
              as String,
      palaceId: null == palaceId
          ? _value.palaceId
          : palaceId // ignore: cast_nullable_to_non_nullable
              as String,
      relatedArea: null == relatedArea
          ? _value.relatedArea
          : relatedArea // ignore: cast_nullable_to_non_nullable
              as String,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      detailedAnalysis: freezed == detailedAnalysis
          ? _value.detailedAnalysis
          : detailedAnalysis // ignore: cast_nullable_to_non_nullable
              as String?,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SimplifiedSibigungItemImpl implements _SimplifiedSibigungItem {
  const _$SimplifiedSibigungItemImpl(
      {required this.palaceName,
      required this.palaceId,
      required this.relatedArea,
      required this.summary,
      required this.score,
      this.detailedAnalysis,
      this.emoji = ''});

  factory _$SimplifiedSibigungItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SimplifiedSibigungItemImplFromJson(json);

  /// 궁 이름 (명궁, 재백궁, 형제궁 등)
  @override
  final String palaceName;

  /// 궁 ID
  @override
  final String palaceId;

  /// 관련 분야 (인생 전반, 재물, 형제 관계 등)
  @override
  final String relatedArea;

  /// 한줄 요약 (친근한 말투)
  @override
  final String summary;

  /// 점수 (0-100)
  @override
  final int score;

  /// 상세 분석 (펼쳤을 때)
  @override
  final String? detailedAnalysis;

  /// 이모지
  @override
  @JsonKey()
  final String emoji;

  @override
  String toString() {
    return 'SimplifiedSibigungItem(palaceName: $palaceName, palaceId: $palaceId, relatedArea: $relatedArea, summary: $summary, score: $score, detailedAnalysis: $detailedAnalysis, emoji: $emoji)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimplifiedSibigungItemImpl &&
            (identical(other.palaceName, palaceName) ||
                other.palaceName == palaceName) &&
            (identical(other.palaceId, palaceId) ||
                other.palaceId == palaceId) &&
            (identical(other.relatedArea, relatedArea) ||
                other.relatedArea == relatedArea) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.detailedAnalysis, detailedAnalysis) ||
                other.detailedAnalysis == detailedAnalysis) &&
            (identical(other.emoji, emoji) || other.emoji == emoji));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, palaceName, palaceId,
      relatedArea, summary, score, detailedAnalysis, emoji);

  /// Create a copy of SimplifiedSibigungItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimplifiedSibigungItemImplCopyWith<_$SimplifiedSibigungItemImpl>
      get copyWith => __$$SimplifiedSibigungItemImplCopyWithImpl<
          _$SimplifiedSibigungItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SimplifiedSibigungItemImplToJson(
      this,
    );
  }
}

abstract class _SimplifiedSibigungItem implements SimplifiedSibigungItem {
  const factory _SimplifiedSibigungItem(
      {required final String palaceName,
      required final String palaceId,
      required final String relatedArea,
      required final String summary,
      required final int score,
      final String? detailedAnalysis,
      final String emoji}) = _$SimplifiedSibigungItemImpl;

  factory _SimplifiedSibigungItem.fromJson(Map<String, dynamic> json) =
      _$SimplifiedSibigungItemImpl.fromJson;

  /// 궁 이름 (명궁, 재백궁, 형제궁 등)
  @override
  String get palaceName;

  /// 궁 ID
  @override
  String get palaceId;

  /// 관련 분야 (인생 전반, 재물, 형제 관계 등)
  @override
  String get relatedArea;

  /// 한줄 요약 (친근한 말투)
  @override
  String get summary;

  /// 점수 (0-100)
  @override
  int get score;

  /// 상세 분석 (펼쳤을 때)
  @override
  String? get detailedAnalysis;

  /// 이모지
  @override
  String get emoji;

  /// Create a copy of SimplifiedSibigungItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimplifiedSibigungItemImplCopyWith<_$SimplifiedSibigungItemImpl>
      get copyWith => throw _privateConstructorUsedError;
}

MakeupStyleRecommendations _$MakeupStyleRecommendationsFromJson(
    Map<String, dynamic> json) {
  return _MakeupStyleRecommendations.fromJson(json);
}

/// @nodoc
mixin _$MakeupStyleRecommendations {
  /// 가장 매력적인 부위
  String get mostAttractiveFeature => throw _privateConstructorUsedError;

  /// 매력 부위 강조 팁
  String get enhancementTip => throw _privateConstructorUsedError;

  /// 추천 메이크업 스타일
  List<MakeupStyle> get recommendedStyles => throw _privateConstructorUsedError;

  /// 행운 색상 (메이크업용)
  LuckyColorForMakeup get luckyColor => throw _privateConstructorUsedError;

  /// 피해야 할 스타일
  String? get styleToAvoid => throw _privateConstructorUsedError;

  /// Serializes this MakeupStyleRecommendations to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MakeupStyleRecommendations
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MakeupStyleRecommendationsCopyWith<MakeupStyleRecommendations>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MakeupStyleRecommendationsCopyWith<$Res> {
  factory $MakeupStyleRecommendationsCopyWith(MakeupStyleRecommendations value,
          $Res Function(MakeupStyleRecommendations) then) =
      _$MakeupStyleRecommendationsCopyWithImpl<$Res,
          MakeupStyleRecommendations>;
  @useResult
  $Res call(
      {String mostAttractiveFeature,
      String enhancementTip,
      List<MakeupStyle> recommendedStyles,
      LuckyColorForMakeup luckyColor,
      String? styleToAvoid});

  $LuckyColorForMakeupCopyWith<$Res> get luckyColor;
}

/// @nodoc
class _$MakeupStyleRecommendationsCopyWithImpl<$Res,
        $Val extends MakeupStyleRecommendations>
    implements $MakeupStyleRecommendationsCopyWith<$Res> {
  _$MakeupStyleRecommendationsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MakeupStyleRecommendations
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mostAttractiveFeature = null,
    Object? enhancementTip = null,
    Object? recommendedStyles = null,
    Object? luckyColor = null,
    Object? styleToAvoid = freezed,
  }) {
    return _then(_value.copyWith(
      mostAttractiveFeature: null == mostAttractiveFeature
          ? _value.mostAttractiveFeature
          : mostAttractiveFeature // ignore: cast_nullable_to_non_nullable
              as String,
      enhancementTip: null == enhancementTip
          ? _value.enhancementTip
          : enhancementTip // ignore: cast_nullable_to_non_nullable
              as String,
      recommendedStyles: null == recommendedStyles
          ? _value.recommendedStyles
          : recommendedStyles // ignore: cast_nullable_to_non_nullable
              as List<MakeupStyle>,
      luckyColor: null == luckyColor
          ? _value.luckyColor
          : luckyColor // ignore: cast_nullable_to_non_nullable
              as LuckyColorForMakeup,
      styleToAvoid: freezed == styleToAvoid
          ? _value.styleToAvoid
          : styleToAvoid // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of MakeupStyleRecommendations
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LuckyColorForMakeupCopyWith<$Res> get luckyColor {
    return $LuckyColorForMakeupCopyWith<$Res>(_value.luckyColor, (value) {
      return _then(_value.copyWith(luckyColor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MakeupStyleRecommendationsImplCopyWith<$Res>
    implements $MakeupStyleRecommendationsCopyWith<$Res> {
  factory _$$MakeupStyleRecommendationsImplCopyWith(
          _$MakeupStyleRecommendationsImpl value,
          $Res Function(_$MakeupStyleRecommendationsImpl) then) =
      __$$MakeupStyleRecommendationsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String mostAttractiveFeature,
      String enhancementTip,
      List<MakeupStyle> recommendedStyles,
      LuckyColorForMakeup luckyColor,
      String? styleToAvoid});

  @override
  $LuckyColorForMakeupCopyWith<$Res> get luckyColor;
}

/// @nodoc
class __$$MakeupStyleRecommendationsImplCopyWithImpl<$Res>
    extends _$MakeupStyleRecommendationsCopyWithImpl<$Res,
        _$MakeupStyleRecommendationsImpl>
    implements _$$MakeupStyleRecommendationsImplCopyWith<$Res> {
  __$$MakeupStyleRecommendationsImplCopyWithImpl(
      _$MakeupStyleRecommendationsImpl _value,
      $Res Function(_$MakeupStyleRecommendationsImpl) _then)
      : super(_value, _then);

  /// Create a copy of MakeupStyleRecommendations
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mostAttractiveFeature = null,
    Object? enhancementTip = null,
    Object? recommendedStyles = null,
    Object? luckyColor = null,
    Object? styleToAvoid = freezed,
  }) {
    return _then(_$MakeupStyleRecommendationsImpl(
      mostAttractiveFeature: null == mostAttractiveFeature
          ? _value.mostAttractiveFeature
          : mostAttractiveFeature // ignore: cast_nullable_to_non_nullable
              as String,
      enhancementTip: null == enhancementTip
          ? _value.enhancementTip
          : enhancementTip // ignore: cast_nullable_to_non_nullable
              as String,
      recommendedStyles: null == recommendedStyles
          ? _value._recommendedStyles
          : recommendedStyles // ignore: cast_nullable_to_non_nullable
              as List<MakeupStyle>,
      luckyColor: null == luckyColor
          ? _value.luckyColor
          : luckyColor // ignore: cast_nullable_to_non_nullable
              as LuckyColorForMakeup,
      styleToAvoid: freezed == styleToAvoid
          ? _value.styleToAvoid
          : styleToAvoid // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MakeupStyleRecommendationsImpl implements _MakeupStyleRecommendations {
  const _$MakeupStyleRecommendationsImpl(
      {required this.mostAttractiveFeature,
      required this.enhancementTip,
      required final List<MakeupStyle> recommendedStyles,
      required this.luckyColor,
      this.styleToAvoid})
      : _recommendedStyles = recommendedStyles;

  factory _$MakeupStyleRecommendationsImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$MakeupStyleRecommendationsImplFromJson(json);

  /// 가장 매력적인 부위
  @override
  final String mostAttractiveFeature;

  /// 매력 부위 강조 팁
  @override
  final String enhancementTip;

  /// 추천 메이크업 스타일
  final List<MakeupStyle> _recommendedStyles;

  /// 추천 메이크업 스타일
  @override
  List<MakeupStyle> get recommendedStyles {
    if (_recommendedStyles is EqualUnmodifiableListView)
      return _recommendedStyles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendedStyles);
  }

  /// 행운 색상 (메이크업용)
  @override
  final LuckyColorForMakeup luckyColor;

  /// 피해야 할 스타일
  @override
  final String? styleToAvoid;

  @override
  String toString() {
    return 'MakeupStyleRecommendations(mostAttractiveFeature: $mostAttractiveFeature, enhancementTip: $enhancementTip, recommendedStyles: $recommendedStyles, luckyColor: $luckyColor, styleToAvoid: $styleToAvoid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MakeupStyleRecommendationsImpl &&
            (identical(other.mostAttractiveFeature, mostAttractiveFeature) ||
                other.mostAttractiveFeature == mostAttractiveFeature) &&
            (identical(other.enhancementTip, enhancementTip) ||
                other.enhancementTip == enhancementTip) &&
            const DeepCollectionEquality()
                .equals(other._recommendedStyles, _recommendedStyles) &&
            (identical(other.luckyColor, luckyColor) ||
                other.luckyColor == luckyColor) &&
            (identical(other.styleToAvoid, styleToAvoid) ||
                other.styleToAvoid == styleToAvoid));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      mostAttractiveFeature,
      enhancementTip,
      const DeepCollectionEquality().hash(_recommendedStyles),
      luckyColor,
      styleToAvoid);

  /// Create a copy of MakeupStyleRecommendations
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MakeupStyleRecommendationsImplCopyWith<_$MakeupStyleRecommendationsImpl>
      get copyWith => __$$MakeupStyleRecommendationsImplCopyWithImpl<
          _$MakeupStyleRecommendationsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MakeupStyleRecommendationsImplToJson(
      this,
    );
  }
}

abstract class _MakeupStyleRecommendations
    implements MakeupStyleRecommendations {
  const factory _MakeupStyleRecommendations(
      {required final String mostAttractiveFeature,
      required final String enhancementTip,
      required final List<MakeupStyle> recommendedStyles,
      required final LuckyColorForMakeup luckyColor,
      final String? styleToAvoid}) = _$MakeupStyleRecommendationsImpl;

  factory _MakeupStyleRecommendations.fromJson(Map<String, dynamic> json) =
      _$MakeupStyleRecommendationsImpl.fromJson;

  /// 가장 매력적인 부위
  @override
  String get mostAttractiveFeature;

  /// 매력 부위 강조 팁
  @override
  String get enhancementTip;

  /// 추천 메이크업 스타일
  @override
  List<MakeupStyle> get recommendedStyles;

  /// 행운 색상 (메이크업용)
  @override
  LuckyColorForMakeup get luckyColor;

  /// 피해야 할 스타일
  @override
  String? get styleToAvoid;

  /// Create a copy of MakeupStyleRecommendations
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MakeupStyleRecommendationsImplCopyWith<_$MakeupStyleRecommendationsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

MakeupStyle _$MakeupStyleFromJson(Map<String, dynamic> json) {
  return _MakeupStyle.fromJson(json);
}

/// @nodoc
mixin _$MakeupStyle {
  /// 스타일 이름 (청순, 시크, 내추럴 등)
  String get styleName => throw _privateConstructorUsedError;

  /// 스타일 설명
  String get description => throw _privateConstructorUsedError;

  /// 어울리는 상황
  String get suitableOccasion => throw _privateConstructorUsedError;

  /// 이모지
  String get emoji => throw _privateConstructorUsedError;

  /// Serializes this MakeupStyle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MakeupStyle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MakeupStyleCopyWith<MakeupStyle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MakeupStyleCopyWith<$Res> {
  factory $MakeupStyleCopyWith(
          MakeupStyle value, $Res Function(MakeupStyle) then) =
      _$MakeupStyleCopyWithImpl<$Res, MakeupStyle>;
  @useResult
  $Res call(
      {String styleName,
      String description,
      String suitableOccasion,
      String emoji});
}

/// @nodoc
class _$MakeupStyleCopyWithImpl<$Res, $Val extends MakeupStyle>
    implements $MakeupStyleCopyWith<$Res> {
  _$MakeupStyleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MakeupStyle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? styleName = null,
    Object? description = null,
    Object? suitableOccasion = null,
    Object? emoji = null,
  }) {
    return _then(_value.copyWith(
      styleName: null == styleName
          ? _value.styleName
          : styleName // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      suitableOccasion: null == suitableOccasion
          ? _value.suitableOccasion
          : suitableOccasion // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MakeupStyleImplCopyWith<$Res>
    implements $MakeupStyleCopyWith<$Res> {
  factory _$$MakeupStyleImplCopyWith(
          _$MakeupStyleImpl value, $Res Function(_$MakeupStyleImpl) then) =
      __$$MakeupStyleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String styleName,
      String description,
      String suitableOccasion,
      String emoji});
}

/// @nodoc
class __$$MakeupStyleImplCopyWithImpl<$Res>
    extends _$MakeupStyleCopyWithImpl<$Res, _$MakeupStyleImpl>
    implements _$$MakeupStyleImplCopyWith<$Res> {
  __$$MakeupStyleImplCopyWithImpl(
      _$MakeupStyleImpl _value, $Res Function(_$MakeupStyleImpl) _then)
      : super(_value, _then);

  /// Create a copy of MakeupStyle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? styleName = null,
    Object? description = null,
    Object? suitableOccasion = null,
    Object? emoji = null,
  }) {
    return _then(_$MakeupStyleImpl(
      styleName: null == styleName
          ? _value.styleName
          : styleName // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      suitableOccasion: null == suitableOccasion
          ? _value.suitableOccasion
          : suitableOccasion // ignore: cast_nullable_to_non_nullable
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
class _$MakeupStyleImpl implements _MakeupStyle {
  const _$MakeupStyleImpl(
      {required this.styleName,
      required this.description,
      required this.suitableOccasion,
      this.emoji = '💄'});

  factory _$MakeupStyleImpl.fromJson(Map<String, dynamic> json) =>
      _$$MakeupStyleImplFromJson(json);

  /// 스타일 이름 (청순, 시크, 내추럴 등)
  @override
  final String styleName;

  /// 스타일 설명
  @override
  final String description;

  /// 어울리는 상황
  @override
  final String suitableOccasion;

  /// 이모지
  @override
  @JsonKey()
  final String emoji;

  @override
  String toString() {
    return 'MakeupStyle(styleName: $styleName, description: $description, suitableOccasion: $suitableOccasion, emoji: $emoji)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MakeupStyleImpl &&
            (identical(other.styleName, styleName) ||
                other.styleName == styleName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.suitableOccasion, suitableOccasion) ||
                other.suitableOccasion == suitableOccasion) &&
            (identical(other.emoji, emoji) || other.emoji == emoji));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, styleName, description, suitableOccasion, emoji);

  /// Create a copy of MakeupStyle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MakeupStyleImplCopyWith<_$MakeupStyleImpl> get copyWith =>
      __$$MakeupStyleImplCopyWithImpl<_$MakeupStyleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MakeupStyleImplToJson(
      this,
    );
  }
}

abstract class _MakeupStyle implements MakeupStyle {
  const factory _MakeupStyle(
      {required final String styleName,
      required final String description,
      required final String suitableOccasion,
      final String emoji}) = _$MakeupStyleImpl;

  factory _MakeupStyle.fromJson(Map<String, dynamic> json) =
      _$MakeupStyleImpl.fromJson;

  /// 스타일 이름 (청순, 시크, 내추럴 등)
  @override
  String get styleName;

  /// 스타일 설명
  @override
  String get description;

  /// 어울리는 상황
  @override
  String get suitableOccasion;

  /// 이모지
  @override
  String get emoji;

  /// Create a copy of MakeupStyle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MakeupStyleImplCopyWith<_$MakeupStyleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LuckyColorForMakeup _$LuckyColorForMakeupFromJson(Map<String, dynamic> json) {
  return _LuckyColorForMakeup.fromJson(json);
}

/// @nodoc
mixin _$LuckyColorForMakeup {
  /// 색상 이름 (한국어)
  String get colorName => throw _privateConstructorUsedError;

  /// 색상 코드
  String get colorCode => throw _privateConstructorUsedError;

  /// 적용 부위 (립, 아이섀도우, 블러셔)
  String get applicationArea => throw _privateConstructorUsedError;

  /// 이유 설명
  String get reason => throw _privateConstructorUsedError;

  /// Serializes this LuckyColorForMakeup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LuckyColorForMakeup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LuckyColorForMakeupCopyWith<LuckyColorForMakeup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LuckyColorForMakeupCopyWith<$Res> {
  factory $LuckyColorForMakeupCopyWith(
          LuckyColorForMakeup value, $Res Function(LuckyColorForMakeup) then) =
      _$LuckyColorForMakeupCopyWithImpl<$Res, LuckyColorForMakeup>;
  @useResult
  $Res call(
      {String colorName,
      String colorCode,
      String applicationArea,
      String reason});
}

/// @nodoc
class _$LuckyColorForMakeupCopyWithImpl<$Res, $Val extends LuckyColorForMakeup>
    implements $LuckyColorForMakeupCopyWith<$Res> {
  _$LuckyColorForMakeupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LuckyColorForMakeup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? colorName = null,
    Object? colorCode = null,
    Object? applicationArea = null,
    Object? reason = null,
  }) {
    return _then(_value.copyWith(
      colorName: null == colorName
          ? _value.colorName
          : colorName // ignore: cast_nullable_to_non_nullable
              as String,
      colorCode: null == colorCode
          ? _value.colorCode
          : colorCode // ignore: cast_nullable_to_non_nullable
              as String,
      applicationArea: null == applicationArea
          ? _value.applicationArea
          : applicationArea // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LuckyColorForMakeupImplCopyWith<$Res>
    implements $LuckyColorForMakeupCopyWith<$Res> {
  factory _$$LuckyColorForMakeupImplCopyWith(_$LuckyColorForMakeupImpl value,
          $Res Function(_$LuckyColorForMakeupImpl) then) =
      __$$LuckyColorForMakeupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String colorName,
      String colorCode,
      String applicationArea,
      String reason});
}

/// @nodoc
class __$$LuckyColorForMakeupImplCopyWithImpl<$Res>
    extends _$LuckyColorForMakeupCopyWithImpl<$Res, _$LuckyColorForMakeupImpl>
    implements _$$LuckyColorForMakeupImplCopyWith<$Res> {
  __$$LuckyColorForMakeupImplCopyWithImpl(_$LuckyColorForMakeupImpl _value,
      $Res Function(_$LuckyColorForMakeupImpl) _then)
      : super(_value, _then);

  /// Create a copy of LuckyColorForMakeup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? colorName = null,
    Object? colorCode = null,
    Object? applicationArea = null,
    Object? reason = null,
  }) {
    return _then(_$LuckyColorForMakeupImpl(
      colorName: null == colorName
          ? _value.colorName
          : colorName // ignore: cast_nullable_to_non_nullable
              as String,
      colorCode: null == colorCode
          ? _value.colorCode
          : colorCode // ignore: cast_nullable_to_non_nullable
              as String,
      applicationArea: null == applicationArea
          ? _value.applicationArea
          : applicationArea // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LuckyColorForMakeupImpl implements _LuckyColorForMakeup {
  const _$LuckyColorForMakeupImpl(
      {required this.colorName,
      required this.colorCode,
      required this.applicationArea,
      required this.reason});

  factory _$LuckyColorForMakeupImpl.fromJson(Map<String, dynamic> json) =>
      _$$LuckyColorForMakeupImplFromJson(json);

  /// 색상 이름 (한국어)
  @override
  final String colorName;

  /// 색상 코드
  @override
  final String colorCode;

  /// 적용 부위 (립, 아이섀도우, 블러셔)
  @override
  final String applicationArea;

  /// 이유 설명
  @override
  final String reason;

  @override
  String toString() {
    return 'LuckyColorForMakeup(colorName: $colorName, colorCode: $colorCode, applicationArea: $applicationArea, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LuckyColorForMakeupImpl &&
            (identical(other.colorName, colorName) ||
                other.colorName == colorName) &&
            (identical(other.colorCode, colorCode) ||
                other.colorCode == colorCode) &&
            (identical(other.applicationArea, applicationArea) ||
                other.applicationArea == applicationArea) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, colorName, colorCode, applicationArea, reason);

  /// Create a copy of LuckyColorForMakeup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LuckyColorForMakeupImplCopyWith<_$LuckyColorForMakeupImpl> get copyWith =>
      __$$LuckyColorForMakeupImplCopyWithImpl<_$LuckyColorForMakeupImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LuckyColorForMakeupImplToJson(
      this,
    );
  }
}

abstract class _LuckyColorForMakeup implements LuckyColorForMakeup {
  const factory _LuckyColorForMakeup(
      {required final String colorName,
      required final String colorCode,
      required final String applicationArea,
      required final String reason}) = _$LuckyColorForMakeupImpl;

  factory _LuckyColorForMakeup.fromJson(Map<String, dynamic> json) =
      _$LuckyColorForMakeupImpl.fromJson;

  /// 색상 이름 (한국어)
  @override
  String get colorName;

  /// 색상 코드
  @override
  String get colorCode;

  /// 적용 부위 (립, 아이섀도우, 블러셔)
  @override
  String get applicationArea;

  /// 이유 설명
  @override
  String get reason;

  /// Create a copy of LuckyColorForMakeup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LuckyColorForMakeupImplCopyWith<_$LuckyColorForMakeupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LuckyFeatureEnhancement _$LuckyFeatureEnhancementFromJson(
    Map<String, dynamic> json) {
  return _LuckyFeatureEnhancement.fromJson(json);
}

/// @nodoc
mixin _$LuckyFeatureEnhancement {
  /// 가장 매력적인 부위
  String get featureName => throw _privateConstructorUsedError;

  /// 매력 포인트 설명
  String get description => throw _privateConstructorUsedError;

  /// 강조 방법
  List<String> get enhancementMethods => throw _privateConstructorUsedError;

  /// 관련 운세 (이 부위로 인해 좋아지는 운)
  String get relatedFortune => throw _privateConstructorUsedError;

  /// Serializes this LuckyFeatureEnhancement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LuckyFeatureEnhancement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LuckyFeatureEnhancementCopyWith<LuckyFeatureEnhancement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LuckyFeatureEnhancementCopyWith<$Res> {
  factory $LuckyFeatureEnhancementCopyWith(LuckyFeatureEnhancement value,
          $Res Function(LuckyFeatureEnhancement) then) =
      _$LuckyFeatureEnhancementCopyWithImpl<$Res, LuckyFeatureEnhancement>;
  @useResult
  $Res call(
      {String featureName,
      String description,
      List<String> enhancementMethods,
      String relatedFortune});
}

/// @nodoc
class _$LuckyFeatureEnhancementCopyWithImpl<$Res,
        $Val extends LuckyFeatureEnhancement>
    implements $LuckyFeatureEnhancementCopyWith<$Res> {
  _$LuckyFeatureEnhancementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LuckyFeatureEnhancement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? featureName = null,
    Object? description = null,
    Object? enhancementMethods = null,
    Object? relatedFortune = null,
  }) {
    return _then(_value.copyWith(
      featureName: null == featureName
          ? _value.featureName
          : featureName // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      enhancementMethods: null == enhancementMethods
          ? _value.enhancementMethods
          : enhancementMethods // ignore: cast_nullable_to_non_nullable
              as List<String>,
      relatedFortune: null == relatedFortune
          ? _value.relatedFortune
          : relatedFortune // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LuckyFeatureEnhancementImplCopyWith<$Res>
    implements $LuckyFeatureEnhancementCopyWith<$Res> {
  factory _$$LuckyFeatureEnhancementImplCopyWith(
          _$LuckyFeatureEnhancementImpl value,
          $Res Function(_$LuckyFeatureEnhancementImpl) then) =
      __$$LuckyFeatureEnhancementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String featureName,
      String description,
      List<String> enhancementMethods,
      String relatedFortune});
}

/// @nodoc
class __$$LuckyFeatureEnhancementImplCopyWithImpl<$Res>
    extends _$LuckyFeatureEnhancementCopyWithImpl<$Res,
        _$LuckyFeatureEnhancementImpl>
    implements _$$LuckyFeatureEnhancementImplCopyWith<$Res> {
  __$$LuckyFeatureEnhancementImplCopyWithImpl(
      _$LuckyFeatureEnhancementImpl _value,
      $Res Function(_$LuckyFeatureEnhancementImpl) _then)
      : super(_value, _then);

  /// Create a copy of LuckyFeatureEnhancement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? featureName = null,
    Object? description = null,
    Object? enhancementMethods = null,
    Object? relatedFortune = null,
  }) {
    return _then(_$LuckyFeatureEnhancementImpl(
      featureName: null == featureName
          ? _value.featureName
          : featureName // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      enhancementMethods: null == enhancementMethods
          ? _value._enhancementMethods
          : enhancementMethods // ignore: cast_nullable_to_non_nullable
              as List<String>,
      relatedFortune: null == relatedFortune
          ? _value.relatedFortune
          : relatedFortune // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LuckyFeatureEnhancementImpl implements _LuckyFeatureEnhancement {
  const _$LuckyFeatureEnhancementImpl(
      {required this.featureName,
      required this.description,
      final List<String> enhancementMethods = const [],
      required this.relatedFortune})
      : _enhancementMethods = enhancementMethods;

  factory _$LuckyFeatureEnhancementImpl.fromJson(Map<String, dynamic> json) =>
      _$$LuckyFeatureEnhancementImplFromJson(json);

  /// 가장 매력적인 부위
  @override
  final String featureName;

  /// 매력 포인트 설명
  @override
  final String description;

  /// 강조 방법
  final List<String> _enhancementMethods;

  /// 강조 방법
  @override
  @JsonKey()
  List<String> get enhancementMethods {
    if (_enhancementMethods is EqualUnmodifiableListView)
      return _enhancementMethods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_enhancementMethods);
  }

  /// 관련 운세 (이 부위로 인해 좋아지는 운)
  @override
  final String relatedFortune;

  @override
  String toString() {
    return 'LuckyFeatureEnhancement(featureName: $featureName, description: $description, enhancementMethods: $enhancementMethods, relatedFortune: $relatedFortune)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LuckyFeatureEnhancementImpl &&
            (identical(other.featureName, featureName) ||
                other.featureName == featureName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._enhancementMethods, _enhancementMethods) &&
            (identical(other.relatedFortune, relatedFortune) ||
                other.relatedFortune == relatedFortune));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, featureName, description,
      const DeepCollectionEquality().hash(_enhancementMethods), relatedFortune);

  /// Create a copy of LuckyFeatureEnhancement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LuckyFeatureEnhancementImplCopyWith<_$LuckyFeatureEnhancementImpl>
      get copyWith => __$$LuckyFeatureEnhancementImplCopyWithImpl<
          _$LuckyFeatureEnhancementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LuckyFeatureEnhancementImplToJson(
      this,
    );
  }
}

abstract class _LuckyFeatureEnhancement implements LuckyFeatureEnhancement {
  const factory _LuckyFeatureEnhancement(
      {required final String featureName,
      required final String description,
      final List<String> enhancementMethods,
      required final String relatedFortune}) = _$LuckyFeatureEnhancementImpl;

  factory _LuckyFeatureEnhancement.fromJson(Map<String, dynamic> json) =
      _$LuckyFeatureEnhancementImpl.fromJson;

  /// 가장 매력적인 부위
  @override
  String get featureName;

  /// 매력 포인트 설명
  @override
  String get description;

  /// 강조 방법
  @override
  List<String> get enhancementMethods;

  /// 관련 운세 (이 부위로 인해 좋아지는 운)
  @override
  String get relatedFortune;

  /// Create a copy of LuckyFeatureEnhancement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LuckyFeatureEnhancementImplCopyWith<_$LuckyFeatureEnhancementImpl>
      get copyWith => throw _privateConstructorUsedError;
}

LeadershipAnalysis _$LeadershipAnalysisFromJson(Map<String, dynamic> json) {
  return _LeadershipAnalysis.fromJson(json);
}

/// @nodoc
mixin _$LeadershipAnalysis {
  /// 리더십 스타일 (카리스마형, 민주적, 섬김형 등)
  String get leadershipStyle => throw _privateConstructorUsedError;

  /// 리더십 점수 (0-100)
  int get leadershipScore => throw _privateConstructorUsedError;

  /// 적합한 직업군
  List<String> get suitableCareers => throw _privateConstructorUsedError;

  /// 리더십 강점
  String get strength => throw _privateConstructorUsedError;

  /// 개선 포인트
  String? get improvementPoint => throw _privateConstructorUsedError;

  /// 비즈니스 운세
  String get businessFortune => throw _privateConstructorUsedError;

  /// Serializes this LeadershipAnalysis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeadershipAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeadershipAnalysisCopyWith<LeadershipAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeadershipAnalysisCopyWith<$Res> {
  factory $LeadershipAnalysisCopyWith(
          LeadershipAnalysis value, $Res Function(LeadershipAnalysis) then) =
      _$LeadershipAnalysisCopyWithImpl<$Res, LeadershipAnalysis>;
  @useResult
  $Res call(
      {String leadershipStyle,
      int leadershipScore,
      List<String> suitableCareers,
      String strength,
      String? improvementPoint,
      String businessFortune});
}

/// @nodoc
class _$LeadershipAnalysisCopyWithImpl<$Res, $Val extends LeadershipAnalysis>
    implements $LeadershipAnalysisCopyWith<$Res> {
  _$LeadershipAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeadershipAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? leadershipStyle = null,
    Object? leadershipScore = null,
    Object? suitableCareers = null,
    Object? strength = null,
    Object? improvementPoint = freezed,
    Object? businessFortune = null,
  }) {
    return _then(_value.copyWith(
      leadershipStyle: null == leadershipStyle
          ? _value.leadershipStyle
          : leadershipStyle // ignore: cast_nullable_to_non_nullable
              as String,
      leadershipScore: null == leadershipScore
          ? _value.leadershipScore
          : leadershipScore // ignore: cast_nullable_to_non_nullable
              as int,
      suitableCareers: null == suitableCareers
          ? _value.suitableCareers
          : suitableCareers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      strength: null == strength
          ? _value.strength
          : strength // ignore: cast_nullable_to_non_nullable
              as String,
      improvementPoint: freezed == improvementPoint
          ? _value.improvementPoint
          : improvementPoint // ignore: cast_nullable_to_non_nullable
              as String?,
      businessFortune: null == businessFortune
          ? _value.businessFortune
          : businessFortune // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LeadershipAnalysisImplCopyWith<$Res>
    implements $LeadershipAnalysisCopyWith<$Res> {
  factory _$$LeadershipAnalysisImplCopyWith(_$LeadershipAnalysisImpl value,
          $Res Function(_$LeadershipAnalysisImpl) then) =
      __$$LeadershipAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String leadershipStyle,
      int leadershipScore,
      List<String> suitableCareers,
      String strength,
      String? improvementPoint,
      String businessFortune});
}

/// @nodoc
class __$$LeadershipAnalysisImplCopyWithImpl<$Res>
    extends _$LeadershipAnalysisCopyWithImpl<$Res, _$LeadershipAnalysisImpl>
    implements _$$LeadershipAnalysisImplCopyWith<$Res> {
  __$$LeadershipAnalysisImplCopyWithImpl(_$LeadershipAnalysisImpl _value,
      $Res Function(_$LeadershipAnalysisImpl) _then)
      : super(_value, _then);

  /// Create a copy of LeadershipAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? leadershipStyle = null,
    Object? leadershipScore = null,
    Object? suitableCareers = null,
    Object? strength = null,
    Object? improvementPoint = freezed,
    Object? businessFortune = null,
  }) {
    return _then(_$LeadershipAnalysisImpl(
      leadershipStyle: null == leadershipStyle
          ? _value.leadershipStyle
          : leadershipStyle // ignore: cast_nullable_to_non_nullable
              as String,
      leadershipScore: null == leadershipScore
          ? _value.leadershipScore
          : leadershipScore // ignore: cast_nullable_to_non_nullable
              as int,
      suitableCareers: null == suitableCareers
          ? _value._suitableCareers
          : suitableCareers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      strength: null == strength
          ? _value.strength
          : strength // ignore: cast_nullable_to_non_nullable
              as String,
      improvementPoint: freezed == improvementPoint
          ? _value.improvementPoint
          : improvementPoint // ignore: cast_nullable_to_non_nullable
              as String?,
      businessFortune: null == businessFortune
          ? _value.businessFortune
          : businessFortune // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeadershipAnalysisImpl implements _LeadershipAnalysis {
  const _$LeadershipAnalysisImpl(
      {required this.leadershipStyle,
      required this.leadershipScore,
      required final List<String> suitableCareers,
      required this.strength,
      this.improvementPoint,
      required this.businessFortune})
      : _suitableCareers = suitableCareers;

  factory _$LeadershipAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeadershipAnalysisImplFromJson(json);

  /// 리더십 스타일 (카리스마형, 민주적, 섬김형 등)
  @override
  final String leadershipStyle;

  /// 리더십 점수 (0-100)
  @override
  final int leadershipScore;

  /// 적합한 직업군
  final List<String> _suitableCareers;

  /// 적합한 직업군
  @override
  List<String> get suitableCareers {
    if (_suitableCareers is EqualUnmodifiableListView) return _suitableCareers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suitableCareers);
  }

  /// 리더십 강점
  @override
  final String strength;

  /// 개선 포인트
  @override
  final String? improvementPoint;

  /// 비즈니스 운세
  @override
  final String businessFortune;

  @override
  String toString() {
    return 'LeadershipAnalysis(leadershipStyle: $leadershipStyle, leadershipScore: $leadershipScore, suitableCareers: $suitableCareers, strength: $strength, improvementPoint: $improvementPoint, businessFortune: $businessFortune)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeadershipAnalysisImpl &&
            (identical(other.leadershipStyle, leadershipStyle) ||
                other.leadershipStyle == leadershipStyle) &&
            (identical(other.leadershipScore, leadershipScore) ||
                other.leadershipScore == leadershipScore) &&
            const DeepCollectionEquality()
                .equals(other._suitableCareers, _suitableCareers) &&
            (identical(other.strength, strength) ||
                other.strength == strength) &&
            (identical(other.improvementPoint, improvementPoint) ||
                other.improvementPoint == improvementPoint) &&
            (identical(other.businessFortune, businessFortune) ||
                other.businessFortune == businessFortune));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      leadershipStyle,
      leadershipScore,
      const DeepCollectionEquality().hash(_suitableCareers),
      strength,
      improvementPoint,
      businessFortune);

  /// Create a copy of LeadershipAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeadershipAnalysisImplCopyWith<_$LeadershipAnalysisImpl> get copyWith =>
      __$$LeadershipAnalysisImplCopyWithImpl<_$LeadershipAnalysisImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeadershipAnalysisImplToJson(
      this,
    );
  }
}

abstract class _LeadershipAnalysis implements LeadershipAnalysis {
  const factory _LeadershipAnalysis(
      {required final String leadershipStyle,
      required final int leadershipScore,
      required final List<String> suitableCareers,
      required final String strength,
      final String? improvementPoint,
      required final String businessFortune}) = _$LeadershipAnalysisImpl;

  factory _LeadershipAnalysis.fromJson(Map<String, dynamic> json) =
      _$LeadershipAnalysisImpl.fromJson;

  /// 리더십 스타일 (카리스마형, 민주적, 섬김형 등)
  @override
  String get leadershipStyle;

  /// 리더십 점수 (0-100)
  @override
  int get leadershipScore;

  /// 적합한 직업군
  @override
  List<String> get suitableCareers;

  /// 리더십 강점
  @override
  String get strength;

  /// 개선 포인트
  @override
  String? get improvementPoint;

  /// 비즈니스 운세
  @override
  String get businessFortune;

  /// Create a copy of LeadershipAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeadershipAnalysisImplCopyWith<_$LeadershipAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WatchFaceReadingData _$WatchFaceReadingDataFromJson(Map<String, dynamic> json) {
  return _WatchFaceReadingData.fromJson(json);
}

/// @nodoc
mixin _$WatchFaceReadingData {
  /// 오늘의 행운 방향
  String get luckyDirection => throw _privateConstructorUsedError;

  /// 행운 색상
  WatchLuckyColor get luckyColor => throw _privateConstructorUsedError;

  /// 행운 시간대
  List<String> get luckyTimePeriods => throw _privateConstructorUsedError;

  /// 일일 리마인더 메시지 ("지금 1분만 숨을 고르세요")
  String get dailyReminderMessage => throw _privateConstructorUsedError;

  /// 간단한 오늘의 운세
  String get briefFortune => throw _privateConstructorUsedError;

  /// 컨디션 점수
  int get conditionScore => throw _privateConstructorUsedError;

  /// 미소 지수
  int get smileScore => throw _privateConstructorUsedError;

  /// Serializes this WatchFaceReadingData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WatchFaceReadingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WatchFaceReadingDataCopyWith<WatchFaceReadingData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WatchFaceReadingDataCopyWith<$Res> {
  factory $WatchFaceReadingDataCopyWith(WatchFaceReadingData value,
          $Res Function(WatchFaceReadingData) then) =
      _$WatchFaceReadingDataCopyWithImpl<$Res, WatchFaceReadingData>;
  @useResult
  $Res call(
      {String luckyDirection,
      WatchLuckyColor luckyColor,
      List<String> luckyTimePeriods,
      String dailyReminderMessage,
      String briefFortune,
      int conditionScore,
      int smileScore});

  $WatchLuckyColorCopyWith<$Res> get luckyColor;
}

/// @nodoc
class _$WatchFaceReadingDataCopyWithImpl<$Res,
        $Val extends WatchFaceReadingData>
    implements $WatchFaceReadingDataCopyWith<$Res> {
  _$WatchFaceReadingDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WatchFaceReadingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? luckyDirection = null,
    Object? luckyColor = null,
    Object? luckyTimePeriods = null,
    Object? dailyReminderMessage = null,
    Object? briefFortune = null,
    Object? conditionScore = null,
    Object? smileScore = null,
  }) {
    return _then(_value.copyWith(
      luckyDirection: null == luckyDirection
          ? _value.luckyDirection
          : luckyDirection // ignore: cast_nullable_to_non_nullable
              as String,
      luckyColor: null == luckyColor
          ? _value.luckyColor
          : luckyColor // ignore: cast_nullable_to_non_nullable
              as WatchLuckyColor,
      luckyTimePeriods: null == luckyTimePeriods
          ? _value.luckyTimePeriods
          : luckyTimePeriods // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dailyReminderMessage: null == dailyReminderMessage
          ? _value.dailyReminderMessage
          : dailyReminderMessage // ignore: cast_nullable_to_non_nullable
              as String,
      briefFortune: null == briefFortune
          ? _value.briefFortune
          : briefFortune // ignore: cast_nullable_to_non_nullable
              as String,
      conditionScore: null == conditionScore
          ? _value.conditionScore
          : conditionScore // ignore: cast_nullable_to_non_nullable
              as int,
      smileScore: null == smileScore
          ? _value.smileScore
          : smileScore // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of WatchFaceReadingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WatchLuckyColorCopyWith<$Res> get luckyColor {
    return $WatchLuckyColorCopyWith<$Res>(_value.luckyColor, (value) {
      return _then(_value.copyWith(luckyColor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WatchFaceReadingDataImplCopyWith<$Res>
    implements $WatchFaceReadingDataCopyWith<$Res> {
  factory _$$WatchFaceReadingDataImplCopyWith(_$WatchFaceReadingDataImpl value,
          $Res Function(_$WatchFaceReadingDataImpl) then) =
      __$$WatchFaceReadingDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String luckyDirection,
      WatchLuckyColor luckyColor,
      List<String> luckyTimePeriods,
      String dailyReminderMessage,
      String briefFortune,
      int conditionScore,
      int smileScore});

  @override
  $WatchLuckyColorCopyWith<$Res> get luckyColor;
}

/// @nodoc
class __$$WatchFaceReadingDataImplCopyWithImpl<$Res>
    extends _$WatchFaceReadingDataCopyWithImpl<$Res, _$WatchFaceReadingDataImpl>
    implements _$$WatchFaceReadingDataImplCopyWith<$Res> {
  __$$WatchFaceReadingDataImplCopyWithImpl(_$WatchFaceReadingDataImpl _value,
      $Res Function(_$WatchFaceReadingDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of WatchFaceReadingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? luckyDirection = null,
    Object? luckyColor = null,
    Object? luckyTimePeriods = null,
    Object? dailyReminderMessage = null,
    Object? briefFortune = null,
    Object? conditionScore = null,
    Object? smileScore = null,
  }) {
    return _then(_$WatchFaceReadingDataImpl(
      luckyDirection: null == luckyDirection
          ? _value.luckyDirection
          : luckyDirection // ignore: cast_nullable_to_non_nullable
              as String,
      luckyColor: null == luckyColor
          ? _value.luckyColor
          : luckyColor // ignore: cast_nullable_to_non_nullable
              as WatchLuckyColor,
      luckyTimePeriods: null == luckyTimePeriods
          ? _value._luckyTimePeriods
          : luckyTimePeriods // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dailyReminderMessage: null == dailyReminderMessage
          ? _value.dailyReminderMessage
          : dailyReminderMessage // ignore: cast_nullable_to_non_nullable
              as String,
      briefFortune: null == briefFortune
          ? _value.briefFortune
          : briefFortune // ignore: cast_nullable_to_non_nullable
              as String,
      conditionScore: null == conditionScore
          ? _value.conditionScore
          : conditionScore // ignore: cast_nullable_to_non_nullable
              as int,
      smileScore: null == smileScore
          ? _value.smileScore
          : smileScore // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WatchFaceReadingDataImpl implements _WatchFaceReadingData {
  const _$WatchFaceReadingDataImpl(
      {required this.luckyDirection,
      required this.luckyColor,
      required final List<String> luckyTimePeriods,
      required this.dailyReminderMessage,
      required this.briefFortune,
      required this.conditionScore,
      required this.smileScore})
      : _luckyTimePeriods = luckyTimePeriods;

  factory _$WatchFaceReadingDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$WatchFaceReadingDataImplFromJson(json);

  /// 오늘의 행운 방향
  @override
  final String luckyDirection;

  /// 행운 색상
  @override
  final WatchLuckyColor luckyColor;

  /// 행운 시간대
  final List<String> _luckyTimePeriods;

  /// 행운 시간대
  @override
  List<String> get luckyTimePeriods {
    if (_luckyTimePeriods is EqualUnmodifiableListView)
      return _luckyTimePeriods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_luckyTimePeriods);
  }

  /// 일일 리마인더 메시지 ("지금 1분만 숨을 고르세요")
  @override
  final String dailyReminderMessage;

  /// 간단한 오늘의 운세
  @override
  final String briefFortune;

  /// 컨디션 점수
  @override
  final int conditionScore;

  /// 미소 지수
  @override
  final int smileScore;

  @override
  String toString() {
    return 'WatchFaceReadingData(luckyDirection: $luckyDirection, luckyColor: $luckyColor, luckyTimePeriods: $luckyTimePeriods, dailyReminderMessage: $dailyReminderMessage, briefFortune: $briefFortune, conditionScore: $conditionScore, smileScore: $smileScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WatchFaceReadingDataImpl &&
            (identical(other.luckyDirection, luckyDirection) ||
                other.luckyDirection == luckyDirection) &&
            (identical(other.luckyColor, luckyColor) ||
                other.luckyColor == luckyColor) &&
            const DeepCollectionEquality()
                .equals(other._luckyTimePeriods, _luckyTimePeriods) &&
            (identical(other.dailyReminderMessage, dailyReminderMessage) ||
                other.dailyReminderMessage == dailyReminderMessage) &&
            (identical(other.briefFortune, briefFortune) ||
                other.briefFortune == briefFortune) &&
            (identical(other.conditionScore, conditionScore) ||
                other.conditionScore == conditionScore) &&
            (identical(other.smileScore, smileScore) ||
                other.smileScore == smileScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      luckyDirection,
      luckyColor,
      const DeepCollectionEquality().hash(_luckyTimePeriods),
      dailyReminderMessage,
      briefFortune,
      conditionScore,
      smileScore);

  /// Create a copy of WatchFaceReadingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WatchFaceReadingDataImplCopyWith<_$WatchFaceReadingDataImpl>
      get copyWith =>
          __$$WatchFaceReadingDataImplCopyWithImpl<_$WatchFaceReadingDataImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WatchFaceReadingDataImplToJson(
      this,
    );
  }
}

abstract class _WatchFaceReadingData implements WatchFaceReadingData {
  const factory _WatchFaceReadingData(
      {required final String luckyDirection,
      required final WatchLuckyColor luckyColor,
      required final List<String> luckyTimePeriods,
      required final String dailyReminderMessage,
      required final String briefFortune,
      required final int conditionScore,
      required final int smileScore}) = _$WatchFaceReadingDataImpl;

  factory _WatchFaceReadingData.fromJson(Map<String, dynamic> json) =
      _$WatchFaceReadingDataImpl.fromJson;

  /// 오늘의 행운 방향
  @override
  String get luckyDirection;

  /// 행운 색상
  @override
  WatchLuckyColor get luckyColor;

  /// 행운 시간대
  @override
  List<String> get luckyTimePeriods;

  /// 일일 리마인더 메시지 ("지금 1분만 숨을 고르세요")
  @override
  String get dailyReminderMessage;

  /// 간단한 오늘의 운세
  @override
  String get briefFortune;

  /// 컨디션 점수
  @override
  int get conditionScore;

  /// 미소 지수
  @override
  int get smileScore;

  /// Create a copy of WatchFaceReadingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WatchFaceReadingDataImplCopyWith<_$WatchFaceReadingDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

WatchLuckyColor _$WatchLuckyColorFromJson(Map<String, dynamic> json) {
  return _WatchLuckyColor.fromJson(json);
}

/// @nodoc
mixin _$WatchLuckyColor {
  String get colorName => throw _privateConstructorUsedError;
  String get colorCode => throw _privateConstructorUsedError;

  /// Serializes this WatchLuckyColor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WatchLuckyColor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WatchLuckyColorCopyWith<WatchLuckyColor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WatchLuckyColorCopyWith<$Res> {
  factory $WatchLuckyColorCopyWith(
          WatchLuckyColor value, $Res Function(WatchLuckyColor) then) =
      _$WatchLuckyColorCopyWithImpl<$Res, WatchLuckyColor>;
  @useResult
  $Res call({String colorName, String colorCode});
}

/// @nodoc
class _$WatchLuckyColorCopyWithImpl<$Res, $Val extends WatchLuckyColor>
    implements $WatchLuckyColorCopyWith<$Res> {
  _$WatchLuckyColorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WatchLuckyColor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? colorName = null,
    Object? colorCode = null,
  }) {
    return _then(_value.copyWith(
      colorName: null == colorName
          ? _value.colorName
          : colorName // ignore: cast_nullable_to_non_nullable
              as String,
      colorCode: null == colorCode
          ? _value.colorCode
          : colorCode // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WatchLuckyColorImplCopyWith<$Res>
    implements $WatchLuckyColorCopyWith<$Res> {
  factory _$$WatchLuckyColorImplCopyWith(_$WatchLuckyColorImpl value,
          $Res Function(_$WatchLuckyColorImpl) then) =
      __$$WatchLuckyColorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String colorName, String colorCode});
}

/// @nodoc
class __$$WatchLuckyColorImplCopyWithImpl<$Res>
    extends _$WatchLuckyColorCopyWithImpl<$Res, _$WatchLuckyColorImpl>
    implements _$$WatchLuckyColorImplCopyWith<$Res> {
  __$$WatchLuckyColorImplCopyWithImpl(
      _$WatchLuckyColorImpl _value, $Res Function(_$WatchLuckyColorImpl) _then)
      : super(_value, _then);

  /// Create a copy of WatchLuckyColor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? colorName = null,
    Object? colorCode = null,
  }) {
    return _then(_$WatchLuckyColorImpl(
      colorName: null == colorName
          ? _value.colorName
          : colorName // ignore: cast_nullable_to_non_nullable
              as String,
      colorCode: null == colorCode
          ? _value.colorCode
          : colorCode // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WatchLuckyColorImpl implements _WatchLuckyColor {
  const _$WatchLuckyColorImpl(
      {required this.colorName, required this.colorCode});

  factory _$WatchLuckyColorImpl.fromJson(Map<String, dynamic> json) =>
      _$$WatchLuckyColorImplFromJson(json);

  @override
  final String colorName;
  @override
  final String colorCode;

  @override
  String toString() {
    return 'WatchLuckyColor(colorName: $colorName, colorCode: $colorCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WatchLuckyColorImpl &&
            (identical(other.colorName, colorName) ||
                other.colorName == colorName) &&
            (identical(other.colorCode, colorCode) ||
                other.colorCode == colorCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, colorName, colorCode);

  /// Create a copy of WatchLuckyColor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WatchLuckyColorImplCopyWith<_$WatchLuckyColorImpl> get copyWith =>
      __$$WatchLuckyColorImplCopyWithImpl<_$WatchLuckyColorImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WatchLuckyColorImplToJson(
      this,
    );
  }
}

abstract class _WatchLuckyColor implements WatchLuckyColor {
  const factory _WatchLuckyColor(
      {required final String colorName,
      required final String colorCode}) = _$WatchLuckyColorImpl;

  factory _WatchLuckyColor.fromJson(Map<String, dynamic> json) =
      _$WatchLuckyColorImpl.fromJson;

  @override
  String get colorName;
  @override
  String get colorCode;

  /// Create a copy of WatchLuckyColor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WatchLuckyColorImplCopyWith<_$WatchLuckyColorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShareableContent _$ShareableContentFromJson(Map<String, dynamic> json) {
  return _ShareableContent.fromJson(json);
}

/// @nodoc
mixin _$ShareableContent {
  /// 공유 제목 ("오늘의 얼굴 운세")
  String get title => throw _privateConstructorUsedError;

  /// 감성 문구
  String get emotionalQuote => throw _privateConstructorUsedError;

  /// 하이라이트 포인트 (3가지)
  List<String> get highlights => throw _privateConstructorUsedError;

  /// 공유 이미지 URL (생성된)
  String? get shareImageUrl => throw _privateConstructorUsedError;

  /// Instagram 스토리용 데이터
  InstagramShareData? get instagramData => throw _privateConstructorUsedError;

  /// Serializes this ShareableContent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShareableContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShareableContentCopyWith<ShareableContent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShareableContentCopyWith<$Res> {
  factory $ShareableContentCopyWith(
          ShareableContent value, $Res Function(ShareableContent) then) =
      _$ShareableContentCopyWithImpl<$Res, ShareableContent>;
  @useResult
  $Res call(
      {String title,
      String emotionalQuote,
      List<String> highlights,
      String? shareImageUrl,
      InstagramShareData? instagramData});

  $InstagramShareDataCopyWith<$Res>? get instagramData;
}

/// @nodoc
class _$ShareableContentCopyWithImpl<$Res, $Val extends ShareableContent>
    implements $ShareableContentCopyWith<$Res> {
  _$ShareableContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShareableContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? emotionalQuote = null,
    Object? highlights = null,
    Object? shareImageUrl = freezed,
    Object? instagramData = freezed,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      emotionalQuote: null == emotionalQuote
          ? _value.emotionalQuote
          : emotionalQuote // ignore: cast_nullable_to_non_nullable
              as String,
      highlights: null == highlights
          ? _value.highlights
          : highlights // ignore: cast_nullable_to_non_nullable
              as List<String>,
      shareImageUrl: freezed == shareImageUrl
          ? _value.shareImageUrl
          : shareImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      instagramData: freezed == instagramData
          ? _value.instagramData
          : instagramData // ignore: cast_nullable_to_non_nullable
              as InstagramShareData?,
    ) as $Val);
  }

  /// Create a copy of ShareableContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InstagramShareDataCopyWith<$Res>? get instagramData {
    if (_value.instagramData == null) {
      return null;
    }

    return $InstagramShareDataCopyWith<$Res>(_value.instagramData!, (value) {
      return _then(_value.copyWith(instagramData: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ShareableContentImplCopyWith<$Res>
    implements $ShareableContentCopyWith<$Res> {
  factory _$$ShareableContentImplCopyWith(_$ShareableContentImpl value,
          $Res Function(_$ShareableContentImpl) then) =
      __$$ShareableContentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String emotionalQuote,
      List<String> highlights,
      String? shareImageUrl,
      InstagramShareData? instagramData});

  @override
  $InstagramShareDataCopyWith<$Res>? get instagramData;
}

/// @nodoc
class __$$ShareableContentImplCopyWithImpl<$Res>
    extends _$ShareableContentCopyWithImpl<$Res, _$ShareableContentImpl>
    implements _$$ShareableContentImplCopyWith<$Res> {
  __$$ShareableContentImplCopyWithImpl(_$ShareableContentImpl _value,
      $Res Function(_$ShareableContentImpl) _then)
      : super(_value, _then);

  /// Create a copy of ShareableContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? emotionalQuote = null,
    Object? highlights = null,
    Object? shareImageUrl = freezed,
    Object? instagramData = freezed,
  }) {
    return _then(_$ShareableContentImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      emotionalQuote: null == emotionalQuote
          ? _value.emotionalQuote
          : emotionalQuote // ignore: cast_nullable_to_non_nullable
              as String,
      highlights: null == highlights
          ? _value._highlights
          : highlights // ignore: cast_nullable_to_non_nullable
              as List<String>,
      shareImageUrl: freezed == shareImageUrl
          ? _value.shareImageUrl
          : shareImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      instagramData: freezed == instagramData
          ? _value.instagramData
          : instagramData // ignore: cast_nullable_to_non_nullable
              as InstagramShareData?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShareableContentImpl implements _ShareableContent {
  const _$ShareableContentImpl(
      {required this.title,
      required this.emotionalQuote,
      required final List<String> highlights,
      this.shareImageUrl,
      this.instagramData})
      : _highlights = highlights;

  factory _$ShareableContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShareableContentImplFromJson(json);

  /// 공유 제목 ("오늘의 얼굴 운세")
  @override
  final String title;

  /// 감성 문구
  @override
  final String emotionalQuote;

  /// 하이라이트 포인트 (3가지)
  final List<String> _highlights;

  /// 하이라이트 포인트 (3가지)
  @override
  List<String> get highlights {
    if (_highlights is EqualUnmodifiableListView) return _highlights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_highlights);
  }

  /// 공유 이미지 URL (생성된)
  @override
  final String? shareImageUrl;

  /// Instagram 스토리용 데이터
  @override
  final InstagramShareData? instagramData;

  @override
  String toString() {
    return 'ShareableContent(title: $title, emotionalQuote: $emotionalQuote, highlights: $highlights, shareImageUrl: $shareImageUrl, instagramData: $instagramData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShareableContentImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.emotionalQuote, emotionalQuote) ||
                other.emotionalQuote == emotionalQuote) &&
            const DeepCollectionEquality()
                .equals(other._highlights, _highlights) &&
            (identical(other.shareImageUrl, shareImageUrl) ||
                other.shareImageUrl == shareImageUrl) &&
            (identical(other.instagramData, instagramData) ||
                other.instagramData == instagramData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      emotionalQuote,
      const DeepCollectionEquality().hash(_highlights),
      shareImageUrl,
      instagramData);

  /// Create a copy of ShareableContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShareableContentImplCopyWith<_$ShareableContentImpl> get copyWith =>
      __$$ShareableContentImplCopyWithImpl<_$ShareableContentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShareableContentImplToJson(
      this,
    );
  }
}

abstract class _ShareableContent implements ShareableContent {
  const factory _ShareableContent(
      {required final String title,
      required final String emotionalQuote,
      required final List<String> highlights,
      final String? shareImageUrl,
      final InstagramShareData? instagramData}) = _$ShareableContentImpl;

  factory _ShareableContent.fromJson(Map<String, dynamic> json) =
      _$ShareableContentImpl.fromJson;

  /// 공유 제목 ("오늘의 얼굴 운세")
  @override
  String get title;

  /// 감성 문구
  @override
  String get emotionalQuote;

  /// 하이라이트 포인트 (3가지)
  @override
  List<String> get highlights;

  /// 공유 이미지 URL (생성된)
  @override
  String? get shareImageUrl;

  /// Instagram 스토리용 데이터
  @override
  InstagramShareData? get instagramData;

  /// Create a copy of ShareableContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShareableContentImplCopyWith<_$ShareableContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InstagramShareData _$InstagramShareDataFromJson(Map<String, dynamic> json) {
  return _InstagramShareData.fromJson(json);
}

/// @nodoc
mixin _$InstagramShareData {
  /// 배경 색상 그라데이션
  List<String> get backgroundGradient => throw _privateConstructorUsedError;

  /// 메인 텍스트
  String get mainText => throw _privateConstructorUsedError;

  /// 서브 텍스트
  String get subText => throw _privateConstructorUsedError;

  /// 해시태그 추천
  List<String> get suggestedHashtags => throw _privateConstructorUsedError;

  /// Serializes this InstagramShareData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InstagramShareData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InstagramShareDataCopyWith<InstagramShareData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InstagramShareDataCopyWith<$Res> {
  factory $InstagramShareDataCopyWith(
          InstagramShareData value, $Res Function(InstagramShareData) then) =
      _$InstagramShareDataCopyWithImpl<$Res, InstagramShareData>;
  @useResult
  $Res call(
      {List<String> backgroundGradient,
      String mainText,
      String subText,
      List<String> suggestedHashtags});
}

/// @nodoc
class _$InstagramShareDataCopyWithImpl<$Res, $Val extends InstagramShareData>
    implements $InstagramShareDataCopyWith<$Res> {
  _$InstagramShareDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InstagramShareData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? backgroundGradient = null,
    Object? mainText = null,
    Object? subText = null,
    Object? suggestedHashtags = null,
  }) {
    return _then(_value.copyWith(
      backgroundGradient: null == backgroundGradient
          ? _value.backgroundGradient
          : backgroundGradient // ignore: cast_nullable_to_non_nullable
              as List<String>,
      mainText: null == mainText
          ? _value.mainText
          : mainText // ignore: cast_nullable_to_non_nullable
              as String,
      subText: null == subText
          ? _value.subText
          : subText // ignore: cast_nullable_to_non_nullable
              as String,
      suggestedHashtags: null == suggestedHashtags
          ? _value.suggestedHashtags
          : suggestedHashtags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InstagramShareDataImplCopyWith<$Res>
    implements $InstagramShareDataCopyWith<$Res> {
  factory _$$InstagramShareDataImplCopyWith(_$InstagramShareDataImpl value,
          $Res Function(_$InstagramShareDataImpl) then) =
      __$$InstagramShareDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> backgroundGradient,
      String mainText,
      String subText,
      List<String> suggestedHashtags});
}

/// @nodoc
class __$$InstagramShareDataImplCopyWithImpl<$Res>
    extends _$InstagramShareDataCopyWithImpl<$Res, _$InstagramShareDataImpl>
    implements _$$InstagramShareDataImplCopyWith<$Res> {
  __$$InstagramShareDataImplCopyWithImpl(_$InstagramShareDataImpl _value,
      $Res Function(_$InstagramShareDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of InstagramShareData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? backgroundGradient = null,
    Object? mainText = null,
    Object? subText = null,
    Object? suggestedHashtags = null,
  }) {
    return _then(_$InstagramShareDataImpl(
      backgroundGradient: null == backgroundGradient
          ? _value._backgroundGradient
          : backgroundGradient // ignore: cast_nullable_to_non_nullable
              as List<String>,
      mainText: null == mainText
          ? _value.mainText
          : mainText // ignore: cast_nullable_to_non_nullable
              as String,
      subText: null == subText
          ? _value.subText
          : subText // ignore: cast_nullable_to_non_nullable
              as String,
      suggestedHashtags: null == suggestedHashtags
          ? _value._suggestedHashtags
          : suggestedHashtags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InstagramShareDataImpl implements _InstagramShareData {
  const _$InstagramShareDataImpl(
      {required final List<String> backgroundGradient,
      required this.mainText,
      required this.subText,
      required final List<String> suggestedHashtags})
      : _backgroundGradient = backgroundGradient,
        _suggestedHashtags = suggestedHashtags;

  factory _$InstagramShareDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$InstagramShareDataImplFromJson(json);

  /// 배경 색상 그라데이션
  final List<String> _backgroundGradient;

  /// 배경 색상 그라데이션
  @override
  List<String> get backgroundGradient {
    if (_backgroundGradient is EqualUnmodifiableListView)
      return _backgroundGradient;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_backgroundGradient);
  }

  /// 메인 텍스트
  @override
  final String mainText;

  /// 서브 텍스트
  @override
  final String subText;

  /// 해시태그 추천
  final List<String> _suggestedHashtags;

  /// 해시태그 추천
  @override
  List<String> get suggestedHashtags {
    if (_suggestedHashtags is EqualUnmodifiableListView)
      return _suggestedHashtags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestedHashtags);
  }

  @override
  String toString() {
    return 'InstagramShareData(backgroundGradient: $backgroundGradient, mainText: $mainText, subText: $subText, suggestedHashtags: $suggestedHashtags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InstagramShareDataImpl &&
            const DeepCollectionEquality()
                .equals(other._backgroundGradient, _backgroundGradient) &&
            (identical(other.mainText, mainText) ||
                other.mainText == mainText) &&
            (identical(other.subText, subText) || other.subText == subText) &&
            const DeepCollectionEquality()
                .equals(other._suggestedHashtags, _suggestedHashtags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_backgroundGradient),
      mainText,
      subText,
      const DeepCollectionEquality().hash(_suggestedHashtags));

  /// Create a copy of InstagramShareData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InstagramShareDataImplCopyWith<_$InstagramShareDataImpl> get copyWith =>
      __$$InstagramShareDataImplCopyWithImpl<_$InstagramShareDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InstagramShareDataImplToJson(
      this,
    );
  }
}

abstract class _InstagramShareData implements InstagramShareData {
  const factory _InstagramShareData(
          {required final List<String> backgroundGradient,
          required final String mainText,
          required final String subText,
          required final List<String> suggestedHashtags}) =
      _$InstagramShareDataImpl;

  factory _InstagramShareData.fromJson(Map<String, dynamic> json) =
      _$InstagramShareDataImpl.fromJson;

  /// 배경 색상 그라데이션
  @override
  List<String> get backgroundGradient;

  /// 메인 텍스트
  @override
  String get mainText;

  /// 서브 텍스트
  @override
  String get subText;

  /// 해시태그 추천
  @override
  List<String> get suggestedHashtags;

  /// Create a copy of InstagramShareData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InstagramShareDataImplCopyWith<_$InstagramShareDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
