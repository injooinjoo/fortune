// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'premium_saju_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PremiumSajuResult _$PremiumSajuResultFromJson(Map<String, dynamic> json) {
  return _PremiumSajuResult.fromJson(json);
}

/// @nodoc
mixin _$PremiumSajuResult {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError; // 생년월일시 정보
  DateTime get birthDateTime => throw _privateConstructorUsedError;
  bool get isLunar => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError; // 'male' | 'female'
// 사주 기초 데이터 (계산된 값)
  SajuPillars get pillars => throw _privateConstructorUsedError;
  ElementDistribution get elements => throw _privateConstructorUsedError;
  FormatAnalysis get formatAnalysis => throw _privateConstructorUsedError;
  YongshinAnalysis get yongshinAnalysis =>
      throw _privateConstructorUsedError; // 콘텐츠 챕터
  List<PremiumChapter> get chapters =>
      throw _privateConstructorUsedError; // 구매 정보
  PurchaseInfo get purchaseInfo => throw _privateConstructorUsedError; // 상태
  GenerationStatus get generationStatus => throw _privateConstructorUsedError;
  ReadingProgress? get readingProgress => throw _privateConstructorUsedError;
  List<Bookmark> get bookmarks => throw _privateConstructorUsedError;

  /// Serializes this PremiumSajuResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PremiumSajuResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PremiumSajuResultCopyWith<PremiumSajuResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PremiumSajuResultCopyWith<$Res> {
  factory $PremiumSajuResultCopyWith(
          PremiumSajuResult value, $Res Function(PremiumSajuResult) then) =
      _$PremiumSajuResultCopyWithImpl<$Res, PremiumSajuResult>;
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      DateTime birthDateTime,
      bool isLunar,
      String gender,
      SajuPillars pillars,
      ElementDistribution elements,
      FormatAnalysis formatAnalysis,
      YongshinAnalysis yongshinAnalysis,
      List<PremiumChapter> chapters,
      PurchaseInfo purchaseInfo,
      GenerationStatus generationStatus,
      ReadingProgress? readingProgress,
      List<Bookmark> bookmarks});

  $SajuPillarsCopyWith<$Res> get pillars;
  $ElementDistributionCopyWith<$Res> get elements;
  $FormatAnalysisCopyWith<$Res> get formatAnalysis;
  $YongshinAnalysisCopyWith<$Res> get yongshinAnalysis;
  $PurchaseInfoCopyWith<$Res> get purchaseInfo;
  $GenerationStatusCopyWith<$Res> get generationStatus;
  $ReadingProgressCopyWith<$Res>? get readingProgress;
}

/// @nodoc
class _$PremiumSajuResultCopyWithImpl<$Res, $Val extends PremiumSajuResult>
    implements $PremiumSajuResultCopyWith<$Res> {
  _$PremiumSajuResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PremiumSajuResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? createdAt = null,
    Object? birthDateTime = null,
    Object? isLunar = null,
    Object? gender = null,
    Object? pillars = null,
    Object? elements = null,
    Object? formatAnalysis = null,
    Object? yongshinAnalysis = null,
    Object? chapters = null,
    Object? purchaseInfo = null,
    Object? generationStatus = null,
    Object? readingProgress = freezed,
    Object? bookmarks = null,
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
      birthDateTime: null == birthDateTime
          ? _value.birthDateTime
          : birthDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isLunar: null == isLunar
          ? _value.isLunar
          : isLunar // ignore: cast_nullable_to_non_nullable
              as bool,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      pillars: null == pillars
          ? _value.pillars
          : pillars // ignore: cast_nullable_to_non_nullable
              as SajuPillars,
      elements: null == elements
          ? _value.elements
          : elements // ignore: cast_nullable_to_non_nullable
              as ElementDistribution,
      formatAnalysis: null == formatAnalysis
          ? _value.formatAnalysis
          : formatAnalysis // ignore: cast_nullable_to_non_nullable
              as FormatAnalysis,
      yongshinAnalysis: null == yongshinAnalysis
          ? _value.yongshinAnalysis
          : yongshinAnalysis // ignore: cast_nullable_to_non_nullable
              as YongshinAnalysis,
      chapters: null == chapters
          ? _value.chapters
          : chapters // ignore: cast_nullable_to_non_nullable
              as List<PremiumChapter>,
      purchaseInfo: null == purchaseInfo
          ? _value.purchaseInfo
          : purchaseInfo // ignore: cast_nullable_to_non_nullable
              as PurchaseInfo,
      generationStatus: null == generationStatus
          ? _value.generationStatus
          : generationStatus // ignore: cast_nullable_to_non_nullable
              as GenerationStatus,
      readingProgress: freezed == readingProgress
          ? _value.readingProgress
          : readingProgress // ignore: cast_nullable_to_non_nullable
              as ReadingProgress?,
      bookmarks: null == bookmarks
          ? _value.bookmarks
          : bookmarks // ignore: cast_nullable_to_non_nullable
              as List<Bookmark>,
    ) as $Val);
  }

  /// Create a copy of PremiumSajuResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SajuPillarsCopyWith<$Res> get pillars {
    return $SajuPillarsCopyWith<$Res>(_value.pillars, (value) {
      return _then(_value.copyWith(pillars: value) as $Val);
    });
  }

  /// Create a copy of PremiumSajuResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ElementDistributionCopyWith<$Res> get elements {
    return $ElementDistributionCopyWith<$Res>(_value.elements, (value) {
      return _then(_value.copyWith(elements: value) as $Val);
    });
  }

  /// Create a copy of PremiumSajuResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FormatAnalysisCopyWith<$Res> get formatAnalysis {
    return $FormatAnalysisCopyWith<$Res>(_value.formatAnalysis, (value) {
      return _then(_value.copyWith(formatAnalysis: value) as $Val);
    });
  }

  /// Create a copy of PremiumSajuResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $YongshinAnalysisCopyWith<$Res> get yongshinAnalysis {
    return $YongshinAnalysisCopyWith<$Res>(_value.yongshinAnalysis, (value) {
      return _then(_value.copyWith(yongshinAnalysis: value) as $Val);
    });
  }

  /// Create a copy of PremiumSajuResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PurchaseInfoCopyWith<$Res> get purchaseInfo {
    return $PurchaseInfoCopyWith<$Res>(_value.purchaseInfo, (value) {
      return _then(_value.copyWith(purchaseInfo: value) as $Val);
    });
  }

  /// Create a copy of PremiumSajuResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GenerationStatusCopyWith<$Res> get generationStatus {
    return $GenerationStatusCopyWith<$Res>(_value.generationStatus, (value) {
      return _then(_value.copyWith(generationStatus: value) as $Val);
    });
  }

  /// Create a copy of PremiumSajuResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReadingProgressCopyWith<$Res>? get readingProgress {
    if (_value.readingProgress == null) {
      return null;
    }

    return $ReadingProgressCopyWith<$Res>(_value.readingProgress!, (value) {
      return _then(_value.copyWith(readingProgress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PremiumSajuResultImplCopyWith<$Res>
    implements $PremiumSajuResultCopyWith<$Res> {
  factory _$$PremiumSajuResultImplCopyWith(_$PremiumSajuResultImpl value,
          $Res Function(_$PremiumSajuResultImpl) then) =
      __$$PremiumSajuResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      DateTime birthDateTime,
      bool isLunar,
      String gender,
      SajuPillars pillars,
      ElementDistribution elements,
      FormatAnalysis formatAnalysis,
      YongshinAnalysis yongshinAnalysis,
      List<PremiumChapter> chapters,
      PurchaseInfo purchaseInfo,
      GenerationStatus generationStatus,
      ReadingProgress? readingProgress,
      List<Bookmark> bookmarks});

  @override
  $SajuPillarsCopyWith<$Res> get pillars;
  @override
  $ElementDistributionCopyWith<$Res> get elements;
  @override
  $FormatAnalysisCopyWith<$Res> get formatAnalysis;
  @override
  $YongshinAnalysisCopyWith<$Res> get yongshinAnalysis;
  @override
  $PurchaseInfoCopyWith<$Res> get purchaseInfo;
  @override
  $GenerationStatusCopyWith<$Res> get generationStatus;
  @override
  $ReadingProgressCopyWith<$Res>? get readingProgress;
}

/// @nodoc
class __$$PremiumSajuResultImplCopyWithImpl<$Res>
    extends _$PremiumSajuResultCopyWithImpl<$Res, _$PremiumSajuResultImpl>
    implements _$$PremiumSajuResultImplCopyWith<$Res> {
  __$$PremiumSajuResultImplCopyWithImpl(_$PremiumSajuResultImpl _value,
      $Res Function(_$PremiumSajuResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of PremiumSajuResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? createdAt = null,
    Object? birthDateTime = null,
    Object? isLunar = null,
    Object? gender = null,
    Object? pillars = null,
    Object? elements = null,
    Object? formatAnalysis = null,
    Object? yongshinAnalysis = null,
    Object? chapters = null,
    Object? purchaseInfo = null,
    Object? generationStatus = null,
    Object? readingProgress = freezed,
    Object? bookmarks = null,
  }) {
    return _then(_$PremiumSajuResultImpl(
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
      birthDateTime: null == birthDateTime
          ? _value.birthDateTime
          : birthDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isLunar: null == isLunar
          ? _value.isLunar
          : isLunar // ignore: cast_nullable_to_non_nullable
              as bool,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      pillars: null == pillars
          ? _value.pillars
          : pillars // ignore: cast_nullable_to_non_nullable
              as SajuPillars,
      elements: null == elements
          ? _value.elements
          : elements // ignore: cast_nullable_to_non_nullable
              as ElementDistribution,
      formatAnalysis: null == formatAnalysis
          ? _value.formatAnalysis
          : formatAnalysis // ignore: cast_nullable_to_non_nullable
              as FormatAnalysis,
      yongshinAnalysis: null == yongshinAnalysis
          ? _value.yongshinAnalysis
          : yongshinAnalysis // ignore: cast_nullable_to_non_nullable
              as YongshinAnalysis,
      chapters: null == chapters
          ? _value._chapters
          : chapters // ignore: cast_nullable_to_non_nullable
              as List<PremiumChapter>,
      purchaseInfo: null == purchaseInfo
          ? _value.purchaseInfo
          : purchaseInfo // ignore: cast_nullable_to_non_nullable
              as PurchaseInfo,
      generationStatus: null == generationStatus
          ? _value.generationStatus
          : generationStatus // ignore: cast_nullable_to_non_nullable
              as GenerationStatus,
      readingProgress: freezed == readingProgress
          ? _value.readingProgress
          : readingProgress // ignore: cast_nullable_to_non_nullable
              as ReadingProgress?,
      bookmarks: null == bookmarks
          ? _value._bookmarks
          : bookmarks // ignore: cast_nullable_to_non_nullable
              as List<Bookmark>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PremiumSajuResultImpl implements _PremiumSajuResult {
  const _$PremiumSajuResultImpl(
      {required this.id,
      required this.userId,
      required this.createdAt,
      required this.birthDateTime,
      this.isLunar = false,
      required this.gender,
      required this.pillars,
      required this.elements,
      required this.formatAnalysis,
      required this.yongshinAnalysis,
      final List<PremiumChapter> chapters = const [],
      required this.purchaseInfo,
      required this.generationStatus,
      this.readingProgress = null,
      final List<Bookmark> bookmarks = const []})
      : _chapters = chapters,
        _bookmarks = bookmarks;

  factory _$PremiumSajuResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PremiumSajuResultImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime createdAt;
// 생년월일시 정보
  @override
  final DateTime birthDateTime;
  @override
  @JsonKey()
  final bool isLunar;
  @override
  final String gender;
// 'male' | 'female'
// 사주 기초 데이터 (계산된 값)
  @override
  final SajuPillars pillars;
  @override
  final ElementDistribution elements;
  @override
  final FormatAnalysis formatAnalysis;
  @override
  final YongshinAnalysis yongshinAnalysis;
// 콘텐츠 챕터
  final List<PremiumChapter> _chapters;
// 콘텐츠 챕터
  @override
  @JsonKey()
  List<PremiumChapter> get chapters {
    if (_chapters is EqualUnmodifiableListView) return _chapters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chapters);
  }

// 구매 정보
  @override
  final PurchaseInfo purchaseInfo;
// 상태
  @override
  final GenerationStatus generationStatus;
  @override
  @JsonKey()
  final ReadingProgress? readingProgress;
  final List<Bookmark> _bookmarks;
  @override
  @JsonKey()
  List<Bookmark> get bookmarks {
    if (_bookmarks is EqualUnmodifiableListView) return _bookmarks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bookmarks);
  }

  @override
  String toString() {
    return 'PremiumSajuResult(id: $id, userId: $userId, createdAt: $createdAt, birthDateTime: $birthDateTime, isLunar: $isLunar, gender: $gender, pillars: $pillars, elements: $elements, formatAnalysis: $formatAnalysis, yongshinAnalysis: $yongshinAnalysis, chapters: $chapters, purchaseInfo: $purchaseInfo, generationStatus: $generationStatus, readingProgress: $readingProgress, bookmarks: $bookmarks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PremiumSajuResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.birthDateTime, birthDateTime) ||
                other.birthDateTime == birthDateTime) &&
            (identical(other.isLunar, isLunar) || other.isLunar == isLunar) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.pillars, pillars) || other.pillars == pillars) &&
            (identical(other.elements, elements) ||
                other.elements == elements) &&
            (identical(other.formatAnalysis, formatAnalysis) ||
                other.formatAnalysis == formatAnalysis) &&
            (identical(other.yongshinAnalysis, yongshinAnalysis) ||
                other.yongshinAnalysis == yongshinAnalysis) &&
            const DeepCollectionEquality().equals(other._chapters, _chapters) &&
            (identical(other.purchaseInfo, purchaseInfo) ||
                other.purchaseInfo == purchaseInfo) &&
            (identical(other.generationStatus, generationStatus) ||
                other.generationStatus == generationStatus) &&
            (identical(other.readingProgress, readingProgress) ||
                other.readingProgress == readingProgress) &&
            const DeepCollectionEquality()
                .equals(other._bookmarks, _bookmarks));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      createdAt,
      birthDateTime,
      isLunar,
      gender,
      pillars,
      elements,
      formatAnalysis,
      yongshinAnalysis,
      const DeepCollectionEquality().hash(_chapters),
      purchaseInfo,
      generationStatus,
      readingProgress,
      const DeepCollectionEquality().hash(_bookmarks));

  /// Create a copy of PremiumSajuResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PremiumSajuResultImplCopyWith<_$PremiumSajuResultImpl> get copyWith =>
      __$$PremiumSajuResultImplCopyWithImpl<_$PremiumSajuResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PremiumSajuResultImplToJson(
      this,
    );
  }
}

abstract class _PremiumSajuResult implements PremiumSajuResult {
  const factory _PremiumSajuResult(
      {required final String id,
      required final String userId,
      required final DateTime createdAt,
      required final DateTime birthDateTime,
      final bool isLunar,
      required final String gender,
      required final SajuPillars pillars,
      required final ElementDistribution elements,
      required final FormatAnalysis formatAnalysis,
      required final YongshinAnalysis yongshinAnalysis,
      final List<PremiumChapter> chapters,
      required final PurchaseInfo purchaseInfo,
      required final GenerationStatus generationStatus,
      final ReadingProgress? readingProgress,
      final List<Bookmark> bookmarks}) = _$PremiumSajuResultImpl;

  factory _PremiumSajuResult.fromJson(Map<String, dynamic> json) =
      _$PremiumSajuResultImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  DateTime get createdAt; // 생년월일시 정보
  @override
  DateTime get birthDateTime;
  @override
  bool get isLunar;
  @override
  String get gender; // 'male' | 'female'
// 사주 기초 데이터 (계산된 값)
  @override
  SajuPillars get pillars;
  @override
  ElementDistribution get elements;
  @override
  FormatAnalysis get formatAnalysis;
  @override
  YongshinAnalysis get yongshinAnalysis; // 콘텐츠 챕터
  @override
  List<PremiumChapter> get chapters; // 구매 정보
  @override
  PurchaseInfo get purchaseInfo; // 상태
  @override
  GenerationStatus get generationStatus;
  @override
  ReadingProgress? get readingProgress;
  @override
  List<Bookmark> get bookmarks;

  /// Create a copy of PremiumSajuResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PremiumSajuResultImplCopyWith<_$PremiumSajuResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SajuPillars _$SajuPillarsFromJson(Map<String, dynamic> json) {
  return _SajuPillars.fromJson(json);
}

/// @nodoc
mixin _$SajuPillars {
  Pillar get yearPillar => throw _privateConstructorUsedError; // 년주
  Pillar get monthPillar => throw _privateConstructorUsedError; // 월주
  Pillar get dayPillar => throw _privateConstructorUsedError; // 일주
  Pillar get hourPillar => throw _privateConstructorUsedError;

  /// Serializes this SajuPillars to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SajuPillars
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SajuPillarsCopyWith<SajuPillars> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SajuPillarsCopyWith<$Res> {
  factory $SajuPillarsCopyWith(
          SajuPillars value, $Res Function(SajuPillars) then) =
      _$SajuPillarsCopyWithImpl<$Res, SajuPillars>;
  @useResult
  $Res call(
      {Pillar yearPillar,
      Pillar monthPillar,
      Pillar dayPillar,
      Pillar hourPillar});

  $PillarCopyWith<$Res> get yearPillar;
  $PillarCopyWith<$Res> get monthPillar;
  $PillarCopyWith<$Res> get dayPillar;
  $PillarCopyWith<$Res> get hourPillar;
}

/// @nodoc
class _$SajuPillarsCopyWithImpl<$Res, $Val extends SajuPillars>
    implements $SajuPillarsCopyWith<$Res> {
  _$SajuPillarsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SajuPillars
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? yearPillar = null,
    Object? monthPillar = null,
    Object? dayPillar = null,
    Object? hourPillar = null,
  }) {
    return _then(_value.copyWith(
      yearPillar: null == yearPillar
          ? _value.yearPillar
          : yearPillar // ignore: cast_nullable_to_non_nullable
              as Pillar,
      monthPillar: null == monthPillar
          ? _value.monthPillar
          : monthPillar // ignore: cast_nullable_to_non_nullable
              as Pillar,
      dayPillar: null == dayPillar
          ? _value.dayPillar
          : dayPillar // ignore: cast_nullable_to_non_nullable
              as Pillar,
      hourPillar: null == hourPillar
          ? _value.hourPillar
          : hourPillar // ignore: cast_nullable_to_non_nullable
              as Pillar,
    ) as $Val);
  }

  /// Create a copy of SajuPillars
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PillarCopyWith<$Res> get yearPillar {
    return $PillarCopyWith<$Res>(_value.yearPillar, (value) {
      return _then(_value.copyWith(yearPillar: value) as $Val);
    });
  }

  /// Create a copy of SajuPillars
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PillarCopyWith<$Res> get monthPillar {
    return $PillarCopyWith<$Res>(_value.monthPillar, (value) {
      return _then(_value.copyWith(monthPillar: value) as $Val);
    });
  }

  /// Create a copy of SajuPillars
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PillarCopyWith<$Res> get dayPillar {
    return $PillarCopyWith<$Res>(_value.dayPillar, (value) {
      return _then(_value.copyWith(dayPillar: value) as $Val);
    });
  }

  /// Create a copy of SajuPillars
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PillarCopyWith<$Res> get hourPillar {
    return $PillarCopyWith<$Res>(_value.hourPillar, (value) {
      return _then(_value.copyWith(hourPillar: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SajuPillarsImplCopyWith<$Res>
    implements $SajuPillarsCopyWith<$Res> {
  factory _$$SajuPillarsImplCopyWith(
          _$SajuPillarsImpl value, $Res Function(_$SajuPillarsImpl) then) =
      __$$SajuPillarsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Pillar yearPillar,
      Pillar monthPillar,
      Pillar dayPillar,
      Pillar hourPillar});

  @override
  $PillarCopyWith<$Res> get yearPillar;
  @override
  $PillarCopyWith<$Res> get monthPillar;
  @override
  $PillarCopyWith<$Res> get dayPillar;
  @override
  $PillarCopyWith<$Res> get hourPillar;
}

/// @nodoc
class __$$SajuPillarsImplCopyWithImpl<$Res>
    extends _$SajuPillarsCopyWithImpl<$Res, _$SajuPillarsImpl>
    implements _$$SajuPillarsImplCopyWith<$Res> {
  __$$SajuPillarsImplCopyWithImpl(
      _$SajuPillarsImpl _value, $Res Function(_$SajuPillarsImpl) _then)
      : super(_value, _then);

  /// Create a copy of SajuPillars
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? yearPillar = null,
    Object? monthPillar = null,
    Object? dayPillar = null,
    Object? hourPillar = null,
  }) {
    return _then(_$SajuPillarsImpl(
      yearPillar: null == yearPillar
          ? _value.yearPillar
          : yearPillar // ignore: cast_nullable_to_non_nullable
              as Pillar,
      monthPillar: null == monthPillar
          ? _value.monthPillar
          : monthPillar // ignore: cast_nullable_to_non_nullable
              as Pillar,
      dayPillar: null == dayPillar
          ? _value.dayPillar
          : dayPillar // ignore: cast_nullable_to_non_nullable
              as Pillar,
      hourPillar: null == hourPillar
          ? _value.hourPillar
          : hourPillar // ignore: cast_nullable_to_non_nullable
              as Pillar,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SajuPillarsImpl implements _SajuPillars {
  const _$SajuPillarsImpl(
      {required this.yearPillar,
      required this.monthPillar,
      required this.dayPillar,
      required this.hourPillar});

  factory _$SajuPillarsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SajuPillarsImplFromJson(json);

  @override
  final Pillar yearPillar;
// 년주
  @override
  final Pillar monthPillar;
// 월주
  @override
  final Pillar dayPillar;
// 일주
  @override
  final Pillar hourPillar;

  @override
  String toString() {
    return 'SajuPillars(yearPillar: $yearPillar, monthPillar: $monthPillar, dayPillar: $dayPillar, hourPillar: $hourPillar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SajuPillarsImpl &&
            (identical(other.yearPillar, yearPillar) ||
                other.yearPillar == yearPillar) &&
            (identical(other.monthPillar, monthPillar) ||
                other.monthPillar == monthPillar) &&
            (identical(other.dayPillar, dayPillar) ||
                other.dayPillar == dayPillar) &&
            (identical(other.hourPillar, hourPillar) ||
                other.hourPillar == hourPillar));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, yearPillar, monthPillar, dayPillar, hourPillar);

  /// Create a copy of SajuPillars
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SajuPillarsImplCopyWith<_$SajuPillarsImpl> get copyWith =>
      __$$SajuPillarsImplCopyWithImpl<_$SajuPillarsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SajuPillarsImplToJson(
      this,
    );
  }
}

abstract class _SajuPillars implements SajuPillars {
  const factory _SajuPillars(
      {required final Pillar yearPillar,
      required final Pillar monthPillar,
      required final Pillar dayPillar,
      required final Pillar hourPillar}) = _$SajuPillarsImpl;

  factory _SajuPillars.fromJson(Map<String, dynamic> json) =
      _$SajuPillarsImpl.fromJson;

  @override
  Pillar get yearPillar; // 년주
  @override
  Pillar get monthPillar; // 월주
  @override
  Pillar get dayPillar; // 일주
  @override
  Pillar get hourPillar;

  /// Create a copy of SajuPillars
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SajuPillarsImplCopyWith<_$SajuPillarsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Pillar _$PillarFromJson(Map<String, dynamic> json) {
  return _Pillar.fromJson(json);
}

/// @nodoc
mixin _$Pillar {
  String get heavenlyStem => throw _privateConstructorUsedError; // 천간 (갑을병정...)
  String get earthlyBranch =>
      throw _privateConstructorUsedError; // 지지 (자축인묘...)
  String get element => throw _privateConstructorUsedError; // 오행 (목화토금수)
  String get yinYang => throw _privateConstructorUsedError; // 음양
  String? get hiddenStems => throw _privateConstructorUsedError;

  /// Serializes this Pillar to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Pillar
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PillarCopyWith<Pillar> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PillarCopyWith<$Res> {
  factory $PillarCopyWith(Pillar value, $Res Function(Pillar) then) =
      _$PillarCopyWithImpl<$Res, Pillar>;
  @useResult
  $Res call(
      {String heavenlyStem,
      String earthlyBranch,
      String element,
      String yinYang,
      String? hiddenStems});
}

/// @nodoc
class _$PillarCopyWithImpl<$Res, $Val extends Pillar>
    implements $PillarCopyWith<$Res> {
  _$PillarCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Pillar
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? heavenlyStem = null,
    Object? earthlyBranch = null,
    Object? element = null,
    Object? yinYang = null,
    Object? hiddenStems = freezed,
  }) {
    return _then(_value.copyWith(
      heavenlyStem: null == heavenlyStem
          ? _value.heavenlyStem
          : heavenlyStem // ignore: cast_nullable_to_non_nullable
              as String,
      earthlyBranch: null == earthlyBranch
          ? _value.earthlyBranch
          : earthlyBranch // ignore: cast_nullable_to_non_nullable
              as String,
      element: null == element
          ? _value.element
          : element // ignore: cast_nullable_to_non_nullable
              as String,
      yinYang: null == yinYang
          ? _value.yinYang
          : yinYang // ignore: cast_nullable_to_non_nullable
              as String,
      hiddenStems: freezed == hiddenStems
          ? _value.hiddenStems
          : hiddenStems // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PillarImplCopyWith<$Res> implements $PillarCopyWith<$Res> {
  factory _$$PillarImplCopyWith(
          _$PillarImpl value, $Res Function(_$PillarImpl) then) =
      __$$PillarImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String heavenlyStem,
      String earthlyBranch,
      String element,
      String yinYang,
      String? hiddenStems});
}

/// @nodoc
class __$$PillarImplCopyWithImpl<$Res>
    extends _$PillarCopyWithImpl<$Res, _$PillarImpl>
    implements _$$PillarImplCopyWith<$Res> {
  __$$PillarImplCopyWithImpl(
      _$PillarImpl _value, $Res Function(_$PillarImpl) _then)
      : super(_value, _then);

  /// Create a copy of Pillar
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? heavenlyStem = null,
    Object? earthlyBranch = null,
    Object? element = null,
    Object? yinYang = null,
    Object? hiddenStems = freezed,
  }) {
    return _then(_$PillarImpl(
      heavenlyStem: null == heavenlyStem
          ? _value.heavenlyStem
          : heavenlyStem // ignore: cast_nullable_to_non_nullable
              as String,
      earthlyBranch: null == earthlyBranch
          ? _value.earthlyBranch
          : earthlyBranch // ignore: cast_nullable_to_non_nullable
              as String,
      element: null == element
          ? _value.element
          : element // ignore: cast_nullable_to_non_nullable
              as String,
      yinYang: null == yinYang
          ? _value.yinYang
          : yinYang // ignore: cast_nullable_to_non_nullable
              as String,
      hiddenStems: freezed == hiddenStems
          ? _value.hiddenStems
          : hiddenStems // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PillarImpl implements _Pillar {
  const _$PillarImpl(
      {required this.heavenlyStem,
      required this.earthlyBranch,
      required this.element,
      required this.yinYang,
      this.hiddenStems});

  factory _$PillarImpl.fromJson(Map<String, dynamic> json) =>
      _$$PillarImplFromJson(json);

  @override
  final String heavenlyStem;
// 천간 (갑을병정...)
  @override
  final String earthlyBranch;
// 지지 (자축인묘...)
  @override
  final String element;
// 오행 (목화토금수)
  @override
  final String yinYang;
// 음양
  @override
  final String? hiddenStems;

  @override
  String toString() {
    return 'Pillar(heavenlyStem: $heavenlyStem, earthlyBranch: $earthlyBranch, element: $element, yinYang: $yinYang, hiddenStems: $hiddenStems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PillarImpl &&
            (identical(other.heavenlyStem, heavenlyStem) ||
                other.heavenlyStem == heavenlyStem) &&
            (identical(other.earthlyBranch, earthlyBranch) ||
                other.earthlyBranch == earthlyBranch) &&
            (identical(other.element, element) || other.element == element) &&
            (identical(other.yinYang, yinYang) || other.yinYang == yinYang) &&
            (identical(other.hiddenStems, hiddenStems) ||
                other.hiddenStems == hiddenStems));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, heavenlyStem, earthlyBranch, element, yinYang, hiddenStems);

  /// Create a copy of Pillar
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PillarImplCopyWith<_$PillarImpl> get copyWith =>
      __$$PillarImplCopyWithImpl<_$PillarImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PillarImplToJson(
      this,
    );
  }
}

abstract class _Pillar implements Pillar {
  const factory _Pillar(
      {required final String heavenlyStem,
      required final String earthlyBranch,
      required final String element,
      required final String yinYang,
      final String? hiddenStems}) = _$PillarImpl;

  factory _Pillar.fromJson(Map<String, dynamic> json) = _$PillarImpl.fromJson;

  @override
  String get heavenlyStem; // 천간 (갑을병정...)
  @override
  String get earthlyBranch; // 지지 (자축인묘...)
  @override
  String get element; // 오행 (목화토금수)
  @override
  String get yinYang; // 음양
  @override
  String? get hiddenStems;

  /// Create a copy of Pillar
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PillarImplCopyWith<_$PillarImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ElementDistribution _$ElementDistributionFromJson(Map<String, dynamic> json) {
  return _ElementDistribution.fromJson(json);
}

/// @nodoc
mixin _$ElementDistribution {
  int get wood => throw _privateConstructorUsedError; // 목
  int get fire => throw _privateConstructorUsedError; // 화
  int get earth => throw _privateConstructorUsedError; // 토
  int get metal => throw _privateConstructorUsedError; // 금
  int get water => throw _privateConstructorUsedError; // 수
  String get dominant => throw _privateConstructorUsedError; // 가장 강한 오행
  String get lacking => throw _privateConstructorUsedError;

  /// Serializes this ElementDistribution to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ElementDistribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ElementDistributionCopyWith<ElementDistribution> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ElementDistributionCopyWith<$Res> {
  factory $ElementDistributionCopyWith(
          ElementDistribution value, $Res Function(ElementDistribution) then) =
      _$ElementDistributionCopyWithImpl<$Res, ElementDistribution>;
  @useResult
  $Res call(
      {int wood,
      int fire,
      int earth,
      int metal,
      int water,
      String dominant,
      String lacking});
}

/// @nodoc
class _$ElementDistributionCopyWithImpl<$Res, $Val extends ElementDistribution>
    implements $ElementDistributionCopyWith<$Res> {
  _$ElementDistributionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ElementDistribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wood = null,
    Object? fire = null,
    Object? earth = null,
    Object? metal = null,
    Object? water = null,
    Object? dominant = null,
    Object? lacking = null,
  }) {
    return _then(_value.copyWith(
      wood: null == wood
          ? _value.wood
          : wood // ignore: cast_nullable_to_non_nullable
              as int,
      fire: null == fire
          ? _value.fire
          : fire // ignore: cast_nullable_to_non_nullable
              as int,
      earth: null == earth
          ? _value.earth
          : earth // ignore: cast_nullable_to_non_nullable
              as int,
      metal: null == metal
          ? _value.metal
          : metal // ignore: cast_nullable_to_non_nullable
              as int,
      water: null == water
          ? _value.water
          : water // ignore: cast_nullable_to_non_nullable
              as int,
      dominant: null == dominant
          ? _value.dominant
          : dominant // ignore: cast_nullable_to_non_nullable
              as String,
      lacking: null == lacking
          ? _value.lacking
          : lacking // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ElementDistributionImplCopyWith<$Res>
    implements $ElementDistributionCopyWith<$Res> {
  factory _$$ElementDistributionImplCopyWith(_$ElementDistributionImpl value,
          $Res Function(_$ElementDistributionImpl) then) =
      __$$ElementDistributionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int wood,
      int fire,
      int earth,
      int metal,
      int water,
      String dominant,
      String lacking});
}

/// @nodoc
class __$$ElementDistributionImplCopyWithImpl<$Res>
    extends _$ElementDistributionCopyWithImpl<$Res, _$ElementDistributionImpl>
    implements _$$ElementDistributionImplCopyWith<$Res> {
  __$$ElementDistributionImplCopyWithImpl(_$ElementDistributionImpl _value,
      $Res Function(_$ElementDistributionImpl) _then)
      : super(_value, _then);

  /// Create a copy of ElementDistribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wood = null,
    Object? fire = null,
    Object? earth = null,
    Object? metal = null,
    Object? water = null,
    Object? dominant = null,
    Object? lacking = null,
  }) {
    return _then(_$ElementDistributionImpl(
      wood: null == wood
          ? _value.wood
          : wood // ignore: cast_nullable_to_non_nullable
              as int,
      fire: null == fire
          ? _value.fire
          : fire // ignore: cast_nullable_to_non_nullable
              as int,
      earth: null == earth
          ? _value.earth
          : earth // ignore: cast_nullable_to_non_nullable
              as int,
      metal: null == metal
          ? _value.metal
          : metal // ignore: cast_nullable_to_non_nullable
              as int,
      water: null == water
          ? _value.water
          : water // ignore: cast_nullable_to_non_nullable
              as int,
      dominant: null == dominant
          ? _value.dominant
          : dominant // ignore: cast_nullable_to_non_nullable
              as String,
      lacking: null == lacking
          ? _value.lacking
          : lacking // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ElementDistributionImpl implements _ElementDistribution {
  const _$ElementDistributionImpl(
      {required this.wood,
      required this.fire,
      required this.earth,
      required this.metal,
      required this.water,
      required this.dominant,
      required this.lacking});

  factory _$ElementDistributionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ElementDistributionImplFromJson(json);

  @override
  final int wood;
// 목
  @override
  final int fire;
// 화
  @override
  final int earth;
// 토
  @override
  final int metal;
// 금
  @override
  final int water;
// 수
  @override
  final String dominant;
// 가장 강한 오행
  @override
  final String lacking;

  @override
  String toString() {
    return 'ElementDistribution(wood: $wood, fire: $fire, earth: $earth, metal: $metal, water: $water, dominant: $dominant, lacking: $lacking)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ElementDistributionImpl &&
            (identical(other.wood, wood) || other.wood == wood) &&
            (identical(other.fire, fire) || other.fire == fire) &&
            (identical(other.earth, earth) || other.earth == earth) &&
            (identical(other.metal, metal) || other.metal == metal) &&
            (identical(other.water, water) || other.water == water) &&
            (identical(other.dominant, dominant) ||
                other.dominant == dominant) &&
            (identical(other.lacking, lacking) || other.lacking == lacking));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, wood, fire, earth, metal, water, dominant, lacking);

  /// Create a copy of ElementDistribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ElementDistributionImplCopyWith<_$ElementDistributionImpl> get copyWith =>
      __$$ElementDistributionImplCopyWithImpl<_$ElementDistributionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ElementDistributionImplToJson(
      this,
    );
  }
}

abstract class _ElementDistribution implements ElementDistribution {
  const factory _ElementDistribution(
      {required final int wood,
      required final int fire,
      required final int earth,
      required final int metal,
      required final int water,
      required final String dominant,
      required final String lacking}) = _$ElementDistributionImpl;

  factory _ElementDistribution.fromJson(Map<String, dynamic> json) =
      _$ElementDistributionImpl.fromJson;

  @override
  int get wood; // 목
  @override
  int get fire; // 화
  @override
  int get earth; // 토
  @override
  int get metal; // 금
  @override
  int get water; // 수
  @override
  String get dominant; // 가장 강한 오행
  @override
  String get lacking;

  /// Create a copy of ElementDistribution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ElementDistributionImplCopyWith<_$ElementDistributionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FormatAnalysis _$FormatAnalysisFromJson(Map<String, dynamic> json) {
  return _FormatAnalysis.fromJson(json);
}

/// @nodoc
mixin _$FormatAnalysis {
  String get format => throw _privateConstructorUsedError; // 격국명 (정재격, 편재격 등)
  String get formatType => throw _privateConstructorUsedError; // 정격/종격/잡격
  String get strength => throw _privateConstructorUsedError; // 신강/신약
  String get description => throw _privateConstructorUsedError;

  /// Serializes this FormatAnalysis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FormatAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FormatAnalysisCopyWith<FormatAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FormatAnalysisCopyWith<$Res> {
  factory $FormatAnalysisCopyWith(
          FormatAnalysis value, $Res Function(FormatAnalysis) then) =
      _$FormatAnalysisCopyWithImpl<$Res, FormatAnalysis>;
  @useResult
  $Res call(
      {String format, String formatType, String strength, String description});
}

/// @nodoc
class _$FormatAnalysisCopyWithImpl<$Res, $Val extends FormatAnalysis>
    implements $FormatAnalysisCopyWith<$Res> {
  _$FormatAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FormatAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? format = null,
    Object? formatType = null,
    Object? strength = null,
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String,
      formatType: null == formatType
          ? _value.formatType
          : formatType // ignore: cast_nullable_to_non_nullable
              as String,
      strength: null == strength
          ? _value.strength
          : strength // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FormatAnalysisImplCopyWith<$Res>
    implements $FormatAnalysisCopyWith<$Res> {
  factory _$$FormatAnalysisImplCopyWith(_$FormatAnalysisImpl value,
          $Res Function(_$FormatAnalysisImpl) then) =
      __$$FormatAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String format, String formatType, String strength, String description});
}

/// @nodoc
class __$$FormatAnalysisImplCopyWithImpl<$Res>
    extends _$FormatAnalysisCopyWithImpl<$Res, _$FormatAnalysisImpl>
    implements _$$FormatAnalysisImplCopyWith<$Res> {
  __$$FormatAnalysisImplCopyWithImpl(
      _$FormatAnalysisImpl _value, $Res Function(_$FormatAnalysisImpl) _then)
      : super(_value, _then);

  /// Create a copy of FormatAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? format = null,
    Object? formatType = null,
    Object? strength = null,
    Object? description = null,
  }) {
    return _then(_$FormatAnalysisImpl(
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String,
      formatType: null == formatType
          ? _value.formatType
          : formatType // ignore: cast_nullable_to_non_nullable
              as String,
      strength: null == strength
          ? _value.strength
          : strength // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FormatAnalysisImpl implements _FormatAnalysis {
  const _$FormatAnalysisImpl(
      {required this.format,
      required this.formatType,
      required this.strength,
      required this.description});

  factory _$FormatAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$FormatAnalysisImplFromJson(json);

  @override
  final String format;
// 격국명 (정재격, 편재격 등)
  @override
  final String formatType;
// 정격/종격/잡격
  @override
  final String strength;
// 신강/신약
  @override
  final String description;

  @override
  String toString() {
    return 'FormatAnalysis(format: $format, formatType: $formatType, strength: $strength, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FormatAnalysisImpl &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.formatType, formatType) ||
                other.formatType == formatType) &&
            (identical(other.strength, strength) ||
                other.strength == strength) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, format, formatType, strength, description);

  /// Create a copy of FormatAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FormatAnalysisImplCopyWith<_$FormatAnalysisImpl> get copyWith =>
      __$$FormatAnalysisImplCopyWithImpl<_$FormatAnalysisImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FormatAnalysisImplToJson(
      this,
    );
  }
}

abstract class _FormatAnalysis implements FormatAnalysis {
  const factory _FormatAnalysis(
      {required final String format,
      required final String formatType,
      required final String strength,
      required final String description}) = _$FormatAnalysisImpl;

  factory _FormatAnalysis.fromJson(Map<String, dynamic> json) =
      _$FormatAnalysisImpl.fromJson;

  @override
  String get format; // 격국명 (정재격, 편재격 등)
  @override
  String get formatType; // 정격/종격/잡격
  @override
  String get strength; // 신강/신약
  @override
  String get description;

  /// Create a copy of FormatAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FormatAnalysisImplCopyWith<_$FormatAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

YongshinAnalysis _$YongshinAnalysisFromJson(Map<String, dynamic> json) {
  return _YongshinAnalysis.fromJson(json);
}

/// @nodoc
mixin _$YongshinAnalysis {
  String get yongshin => throw _privateConstructorUsedError; // 용신 (필요한 오행)
  String get heeshin => throw _privateConstructorUsedError; // 희신 (도움되는 오행)
  String get gishin => throw _privateConstructorUsedError; // 기신 (해로운 오행)
  String get chousin => throw _privateConstructorUsedError; // 구신 (나쁜 오행)
  String get method => throw _privateConstructorUsedError; // 판단 방법 (억부법, 조후법 등)
  String get description => throw _privateConstructorUsedError;

  /// Serializes this YongshinAnalysis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of YongshinAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $YongshinAnalysisCopyWith<YongshinAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YongshinAnalysisCopyWith<$Res> {
  factory $YongshinAnalysisCopyWith(
          YongshinAnalysis value, $Res Function(YongshinAnalysis) then) =
      _$YongshinAnalysisCopyWithImpl<$Res, YongshinAnalysis>;
  @useResult
  $Res call(
      {String yongshin,
      String heeshin,
      String gishin,
      String chousin,
      String method,
      String description});
}

/// @nodoc
class _$YongshinAnalysisCopyWithImpl<$Res, $Val extends YongshinAnalysis>
    implements $YongshinAnalysisCopyWith<$Res> {
  _$YongshinAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of YongshinAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? yongshin = null,
    Object? heeshin = null,
    Object? gishin = null,
    Object? chousin = null,
    Object? method = null,
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      yongshin: null == yongshin
          ? _value.yongshin
          : yongshin // ignore: cast_nullable_to_non_nullable
              as String,
      heeshin: null == heeshin
          ? _value.heeshin
          : heeshin // ignore: cast_nullable_to_non_nullable
              as String,
      gishin: null == gishin
          ? _value.gishin
          : gishin // ignore: cast_nullable_to_non_nullable
              as String,
      chousin: null == chousin
          ? _value.chousin
          : chousin // ignore: cast_nullable_to_non_nullable
              as String,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$YongshinAnalysisImplCopyWith<$Res>
    implements $YongshinAnalysisCopyWith<$Res> {
  factory _$$YongshinAnalysisImplCopyWith(_$YongshinAnalysisImpl value,
          $Res Function(_$YongshinAnalysisImpl) then) =
      __$$YongshinAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String yongshin,
      String heeshin,
      String gishin,
      String chousin,
      String method,
      String description});
}

/// @nodoc
class __$$YongshinAnalysisImplCopyWithImpl<$Res>
    extends _$YongshinAnalysisCopyWithImpl<$Res, _$YongshinAnalysisImpl>
    implements _$$YongshinAnalysisImplCopyWith<$Res> {
  __$$YongshinAnalysisImplCopyWithImpl(_$YongshinAnalysisImpl _value,
      $Res Function(_$YongshinAnalysisImpl) _then)
      : super(_value, _then);

  /// Create a copy of YongshinAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? yongshin = null,
    Object? heeshin = null,
    Object? gishin = null,
    Object? chousin = null,
    Object? method = null,
    Object? description = null,
  }) {
    return _then(_$YongshinAnalysisImpl(
      yongshin: null == yongshin
          ? _value.yongshin
          : yongshin // ignore: cast_nullable_to_non_nullable
              as String,
      heeshin: null == heeshin
          ? _value.heeshin
          : heeshin // ignore: cast_nullable_to_non_nullable
              as String,
      gishin: null == gishin
          ? _value.gishin
          : gishin // ignore: cast_nullable_to_non_nullable
              as String,
      chousin: null == chousin
          ? _value.chousin
          : chousin // ignore: cast_nullable_to_non_nullable
              as String,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$YongshinAnalysisImpl implements _YongshinAnalysis {
  const _$YongshinAnalysisImpl(
      {required this.yongshin,
      required this.heeshin,
      required this.gishin,
      required this.chousin,
      required this.method,
      required this.description});

  factory _$YongshinAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$YongshinAnalysisImplFromJson(json);

  @override
  final String yongshin;
// 용신 (필요한 오행)
  @override
  final String heeshin;
// 희신 (도움되는 오행)
  @override
  final String gishin;
// 기신 (해로운 오행)
  @override
  final String chousin;
// 구신 (나쁜 오행)
  @override
  final String method;
// 판단 방법 (억부법, 조후법 등)
  @override
  final String description;

  @override
  String toString() {
    return 'YongshinAnalysis(yongshin: $yongshin, heeshin: $heeshin, gishin: $gishin, chousin: $chousin, method: $method, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YongshinAnalysisImpl &&
            (identical(other.yongshin, yongshin) ||
                other.yongshin == yongshin) &&
            (identical(other.heeshin, heeshin) || other.heeshin == heeshin) &&
            (identical(other.gishin, gishin) || other.gishin == gishin) &&
            (identical(other.chousin, chousin) || other.chousin == chousin) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, yongshin, heeshin, gishin, chousin, method, description);

  /// Create a copy of YongshinAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$YongshinAnalysisImplCopyWith<_$YongshinAnalysisImpl> get copyWith =>
      __$$YongshinAnalysisImplCopyWithImpl<_$YongshinAnalysisImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$YongshinAnalysisImplToJson(
      this,
    );
  }
}

abstract class _YongshinAnalysis implements YongshinAnalysis {
  const factory _YongshinAnalysis(
      {required final String yongshin,
      required final String heeshin,
      required final String gishin,
      required final String chousin,
      required final String method,
      required final String description}) = _$YongshinAnalysisImpl;

  factory _YongshinAnalysis.fromJson(Map<String, dynamic> json) =
      _$YongshinAnalysisImpl.fromJson;

  @override
  String get yongshin; // 용신 (필요한 오행)
  @override
  String get heeshin; // 희신 (도움되는 오행)
  @override
  String get gishin; // 기신 (해로운 오행)
  @override
  String get chousin; // 구신 (나쁜 오행)
  @override
  String get method; // 판단 방법 (억부법, 조후법 등)
  @override
  String get description;

  /// Create a copy of YongshinAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$YongshinAnalysisImplCopyWith<_$YongshinAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PremiumChapter _$PremiumChapterFromJson(Map<String, dynamic> json) {
  return _PremiumChapter.fromJson(json);
}

/// @nodoc
mixin _$PremiumChapter {
  String get id => throw _privateConstructorUsedError;
  int get partNumber => throw _privateConstructorUsedError; // 1-6
  int get chapterNumber =>
      throw _privateConstructorUsedError; // 1.1, 1.2 등의 소수점 아래
  String get title => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  ChapterStatus get status => throw _privateConstructorUsedError;
  List<PremiumSection> get sections => throw _privateConstructorUsedError;
  int get estimatedPages => throw _privateConstructorUsedError;
  int get actualWordCount => throw _privateConstructorUsedError;
  DateTime? get generatedAt => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this PremiumChapter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PremiumChapter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PremiumChapterCopyWith<PremiumChapter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PremiumChapterCopyWith<$Res> {
  factory $PremiumChapterCopyWith(
          PremiumChapter value, $Res Function(PremiumChapter) then) =
      _$PremiumChapterCopyWithImpl<$Res, PremiumChapter>;
  @useResult
  $Res call(
      {String id,
      int partNumber,
      int chapterNumber,
      String title,
      String emoji,
      ChapterStatus status,
      List<PremiumSection> sections,
      int estimatedPages,
      int actualWordCount,
      DateTime? generatedAt,
      String? errorMessage});
}

/// @nodoc
class _$PremiumChapterCopyWithImpl<$Res, $Val extends PremiumChapter>
    implements $PremiumChapterCopyWith<$Res> {
  _$PremiumChapterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PremiumChapter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? partNumber = null,
    Object? chapterNumber = null,
    Object? title = null,
    Object? emoji = null,
    Object? status = null,
    Object? sections = null,
    Object? estimatedPages = null,
    Object? actualWordCount = null,
    Object? generatedAt = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      partNumber: null == partNumber
          ? _value.partNumber
          : partNumber // ignore: cast_nullable_to_non_nullable
              as int,
      chapterNumber: null == chapterNumber
          ? _value.chapterNumber
          : chapterNumber // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ChapterStatus,
      sections: null == sections
          ? _value.sections
          : sections // ignore: cast_nullable_to_non_nullable
              as List<PremiumSection>,
      estimatedPages: null == estimatedPages
          ? _value.estimatedPages
          : estimatedPages // ignore: cast_nullable_to_non_nullable
              as int,
      actualWordCount: null == actualWordCount
          ? _value.actualWordCount
          : actualWordCount // ignore: cast_nullable_to_non_nullable
              as int,
      generatedAt: freezed == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PremiumChapterImplCopyWith<$Res>
    implements $PremiumChapterCopyWith<$Res> {
  factory _$$PremiumChapterImplCopyWith(_$PremiumChapterImpl value,
          $Res Function(_$PremiumChapterImpl) then) =
      __$$PremiumChapterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int partNumber,
      int chapterNumber,
      String title,
      String emoji,
      ChapterStatus status,
      List<PremiumSection> sections,
      int estimatedPages,
      int actualWordCount,
      DateTime? generatedAt,
      String? errorMessage});
}

/// @nodoc
class __$$PremiumChapterImplCopyWithImpl<$Res>
    extends _$PremiumChapterCopyWithImpl<$Res, _$PremiumChapterImpl>
    implements _$$PremiumChapterImplCopyWith<$Res> {
  __$$PremiumChapterImplCopyWithImpl(
      _$PremiumChapterImpl _value, $Res Function(_$PremiumChapterImpl) _then)
      : super(_value, _then);

  /// Create a copy of PremiumChapter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? partNumber = null,
    Object? chapterNumber = null,
    Object? title = null,
    Object? emoji = null,
    Object? status = null,
    Object? sections = null,
    Object? estimatedPages = null,
    Object? actualWordCount = null,
    Object? generatedAt = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$PremiumChapterImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      partNumber: null == partNumber
          ? _value.partNumber
          : partNumber // ignore: cast_nullable_to_non_nullable
              as int,
      chapterNumber: null == chapterNumber
          ? _value.chapterNumber
          : chapterNumber // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ChapterStatus,
      sections: null == sections
          ? _value._sections
          : sections // ignore: cast_nullable_to_non_nullable
              as List<PremiumSection>,
      estimatedPages: null == estimatedPages
          ? _value.estimatedPages
          : estimatedPages // ignore: cast_nullable_to_non_nullable
              as int,
      actualWordCount: null == actualWordCount
          ? _value.actualWordCount
          : actualWordCount // ignore: cast_nullable_to_non_nullable
              as int,
      generatedAt: freezed == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PremiumChapterImpl implements _PremiumChapter {
  const _$PremiumChapterImpl(
      {required this.id,
      required this.partNumber,
      required this.chapterNumber,
      required this.title,
      this.emoji = '',
      required this.status,
      final List<PremiumSection> sections = const [],
      this.estimatedPages = 0,
      this.actualWordCount = 0,
      this.generatedAt,
      this.errorMessage})
      : _sections = sections;

  factory _$PremiumChapterImpl.fromJson(Map<String, dynamic> json) =>
      _$$PremiumChapterImplFromJson(json);

  @override
  final String id;
  @override
  final int partNumber;
// 1-6
  @override
  final int chapterNumber;
// 1.1, 1.2 등의 소수점 아래
  @override
  final String title;
  @override
  @JsonKey()
  final String emoji;
  @override
  final ChapterStatus status;
  final List<PremiumSection> _sections;
  @override
  @JsonKey()
  List<PremiumSection> get sections {
    if (_sections is EqualUnmodifiableListView) return _sections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sections);
  }

  @override
  @JsonKey()
  final int estimatedPages;
  @override
  @JsonKey()
  final int actualWordCount;
  @override
  final DateTime? generatedAt;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'PremiumChapter(id: $id, partNumber: $partNumber, chapterNumber: $chapterNumber, title: $title, emoji: $emoji, status: $status, sections: $sections, estimatedPages: $estimatedPages, actualWordCount: $actualWordCount, generatedAt: $generatedAt, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PremiumChapterImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.partNumber, partNumber) ||
                other.partNumber == partNumber) &&
            (identical(other.chapterNumber, chapterNumber) ||
                other.chapterNumber == chapterNumber) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._sections, _sections) &&
            (identical(other.estimatedPages, estimatedPages) ||
                other.estimatedPages == estimatedPages) &&
            (identical(other.actualWordCount, actualWordCount) ||
                other.actualWordCount == actualWordCount) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      partNumber,
      chapterNumber,
      title,
      emoji,
      status,
      const DeepCollectionEquality().hash(_sections),
      estimatedPages,
      actualWordCount,
      generatedAt,
      errorMessage);

  /// Create a copy of PremiumChapter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PremiumChapterImplCopyWith<_$PremiumChapterImpl> get copyWith =>
      __$$PremiumChapterImplCopyWithImpl<_$PremiumChapterImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PremiumChapterImplToJson(
      this,
    );
  }
}

abstract class _PremiumChapter implements PremiumChapter {
  const factory _PremiumChapter(
      {required final String id,
      required final int partNumber,
      required final int chapterNumber,
      required final String title,
      final String emoji,
      required final ChapterStatus status,
      final List<PremiumSection> sections,
      final int estimatedPages,
      final int actualWordCount,
      final DateTime? generatedAt,
      final String? errorMessage}) = _$PremiumChapterImpl;

  factory _PremiumChapter.fromJson(Map<String, dynamic> json) =
      _$PremiumChapterImpl.fromJson;

  @override
  String get id;
  @override
  int get partNumber; // 1-6
  @override
  int get chapterNumber; // 1.1, 1.2 등의 소수점 아래
  @override
  String get title;
  @override
  String get emoji;
  @override
  ChapterStatus get status;
  @override
  List<PremiumSection> get sections;
  @override
  int get estimatedPages;
  @override
  int get actualWordCount;
  @override
  DateTime? get generatedAt;
  @override
  String? get errorMessage;

  /// Create a copy of PremiumChapter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PremiumChapterImplCopyWith<_$PremiumChapterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PremiumSection _$PremiumSectionFromJson(Map<String, dynamic> json) {
  return _PremiumSection.fromJson(json);
}

/// @nodoc
mixin _$PremiumSection {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  SectionType get type => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError; // 마크다운 콘텐츠
  List<String> get subsectionTitles => throw _privateConstructorUsedError;
  bool get isGenerated => throw _privateConstructorUsedError;
  DateTime? get generatedAt => throw _privateConstructorUsedError;

  /// Serializes this PremiumSection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PremiumSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PremiumSectionCopyWith<PremiumSection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PremiumSectionCopyWith<$Res> {
  factory $PremiumSectionCopyWith(
          PremiumSection value, $Res Function(PremiumSection) then) =
      _$PremiumSectionCopyWithImpl<$Res, PremiumSection>;
  @useResult
  $Res call(
      {String id,
      String title,
      SectionType type,
      String content,
      List<String> subsectionTitles,
      bool isGenerated,
      DateTime? generatedAt});
}

/// @nodoc
class _$PremiumSectionCopyWithImpl<$Res, $Val extends PremiumSection>
    implements $PremiumSectionCopyWith<$Res> {
  _$PremiumSectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PremiumSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? type = null,
    Object? content = null,
    Object? subsectionTitles = null,
    Object? isGenerated = null,
    Object? generatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SectionType,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      subsectionTitles: null == subsectionTitles
          ? _value.subsectionTitles
          : subsectionTitles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isGenerated: null == isGenerated
          ? _value.isGenerated
          : isGenerated // ignore: cast_nullable_to_non_nullable
              as bool,
      generatedAt: freezed == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PremiumSectionImplCopyWith<$Res>
    implements $PremiumSectionCopyWith<$Res> {
  factory _$$PremiumSectionImplCopyWith(_$PremiumSectionImpl value,
          $Res Function(_$PremiumSectionImpl) then) =
      __$$PremiumSectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      SectionType type,
      String content,
      List<String> subsectionTitles,
      bool isGenerated,
      DateTime? generatedAt});
}

/// @nodoc
class __$$PremiumSectionImplCopyWithImpl<$Res>
    extends _$PremiumSectionCopyWithImpl<$Res, _$PremiumSectionImpl>
    implements _$$PremiumSectionImplCopyWith<$Res> {
  __$$PremiumSectionImplCopyWithImpl(
      _$PremiumSectionImpl _value, $Res Function(_$PremiumSectionImpl) _then)
      : super(_value, _then);

  /// Create a copy of PremiumSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? type = null,
    Object? content = null,
    Object? subsectionTitles = null,
    Object? isGenerated = null,
    Object? generatedAt = freezed,
  }) {
    return _then(_$PremiumSectionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SectionType,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      subsectionTitles: null == subsectionTitles
          ? _value._subsectionTitles
          : subsectionTitles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isGenerated: null == isGenerated
          ? _value.isGenerated
          : isGenerated // ignore: cast_nullable_to_non_nullable
              as bool,
      generatedAt: freezed == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PremiumSectionImpl implements _PremiumSection {
  const _$PremiumSectionImpl(
      {required this.id,
      required this.title,
      required this.type,
      this.content = '',
      final List<String> subsectionTitles = const [],
      this.isGenerated = false,
      this.generatedAt})
      : _subsectionTitles = subsectionTitles;

  factory _$PremiumSectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PremiumSectionImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final SectionType type;
  @override
  @JsonKey()
  final String content;
// 마크다운 콘텐츠
  final List<String> _subsectionTitles;
// 마크다운 콘텐츠
  @override
  @JsonKey()
  List<String> get subsectionTitles {
    if (_subsectionTitles is EqualUnmodifiableListView)
      return _subsectionTitles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subsectionTitles);
  }

  @override
  @JsonKey()
  final bool isGenerated;
  @override
  final DateTime? generatedAt;

  @override
  String toString() {
    return 'PremiumSection(id: $id, title: $title, type: $type, content: $content, subsectionTitles: $subsectionTitles, isGenerated: $isGenerated, generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PremiumSectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality()
                .equals(other._subsectionTitles, _subsectionTitles) &&
            (identical(other.isGenerated, isGenerated) ||
                other.isGenerated == isGenerated) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      type,
      content,
      const DeepCollectionEquality().hash(_subsectionTitles),
      isGenerated,
      generatedAt);

  /// Create a copy of PremiumSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PremiumSectionImplCopyWith<_$PremiumSectionImpl> get copyWith =>
      __$$PremiumSectionImplCopyWithImpl<_$PremiumSectionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PremiumSectionImplToJson(
      this,
    );
  }
}

abstract class _PremiumSection implements PremiumSection {
  const factory _PremiumSection(
      {required final String id,
      required final String title,
      required final SectionType type,
      final String content,
      final List<String> subsectionTitles,
      final bool isGenerated,
      final DateTime? generatedAt}) = _$PremiumSectionImpl;

  factory _PremiumSection.fromJson(Map<String, dynamic> json) =
      _$PremiumSectionImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  SectionType get type;
  @override
  String get content; // 마크다운 콘텐츠
  @override
  List<String> get subsectionTitles;
  @override
  bool get isGenerated;
  @override
  DateTime? get generatedAt;

  /// Create a copy of PremiumSection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PremiumSectionImplCopyWith<_$PremiumSectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GenerationStatus _$GenerationStatusFromJson(Map<String, dynamic> json) {
  return _GenerationStatus.fromJson(json);
}

/// @nodoc
mixin _$GenerationStatus {
  int get totalChapters => throw _privateConstructorUsedError;
  int get completedChapters => throw _privateConstructorUsedError;
  int get currentChapterIndex => throw _privateConstructorUsedError;
  bool get isComplete => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this GenerationStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GenerationStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GenerationStatusCopyWith<GenerationStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GenerationStatusCopyWith<$Res> {
  factory $GenerationStatusCopyWith(
          GenerationStatus value, $Res Function(GenerationStatus) then) =
      _$GenerationStatusCopyWithImpl<$Res, GenerationStatus>;
  @useResult
  $Res call(
      {int totalChapters,
      int completedChapters,
      int currentChapterIndex,
      bool isComplete,
      DateTime? startedAt,
      DateTime? completedAt,
      String? errorMessage});
}

/// @nodoc
class _$GenerationStatusCopyWithImpl<$Res, $Val extends GenerationStatus>
    implements $GenerationStatusCopyWith<$Res> {
  _$GenerationStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GenerationStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalChapters = null,
    Object? completedChapters = null,
    Object? currentChapterIndex = null,
    Object? isComplete = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      totalChapters: null == totalChapters
          ? _value.totalChapters
          : totalChapters // ignore: cast_nullable_to_non_nullable
              as int,
      completedChapters: null == completedChapters
          ? _value.completedChapters
          : completedChapters // ignore: cast_nullable_to_non_nullable
              as int,
      currentChapterIndex: null == currentChapterIndex
          ? _value.currentChapterIndex
          : currentChapterIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isComplete: null == isComplete
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GenerationStatusImplCopyWith<$Res>
    implements $GenerationStatusCopyWith<$Res> {
  factory _$$GenerationStatusImplCopyWith(_$GenerationStatusImpl value,
          $Res Function(_$GenerationStatusImpl) then) =
      __$$GenerationStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalChapters,
      int completedChapters,
      int currentChapterIndex,
      bool isComplete,
      DateTime? startedAt,
      DateTime? completedAt,
      String? errorMessage});
}

/// @nodoc
class __$$GenerationStatusImplCopyWithImpl<$Res>
    extends _$GenerationStatusCopyWithImpl<$Res, _$GenerationStatusImpl>
    implements _$$GenerationStatusImplCopyWith<$Res> {
  __$$GenerationStatusImplCopyWithImpl(_$GenerationStatusImpl _value,
      $Res Function(_$GenerationStatusImpl) _then)
      : super(_value, _then);

  /// Create a copy of GenerationStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalChapters = null,
    Object? completedChapters = null,
    Object? currentChapterIndex = null,
    Object? isComplete = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$GenerationStatusImpl(
      totalChapters: null == totalChapters
          ? _value.totalChapters
          : totalChapters // ignore: cast_nullable_to_non_nullable
              as int,
      completedChapters: null == completedChapters
          ? _value.completedChapters
          : completedChapters // ignore: cast_nullable_to_non_nullable
              as int,
      currentChapterIndex: null == currentChapterIndex
          ? _value.currentChapterIndex
          : currentChapterIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isComplete: null == isComplete
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GenerationStatusImpl implements _GenerationStatus {
  const _$GenerationStatusImpl(
      {required this.totalChapters,
      this.completedChapters = 0,
      this.currentChapterIndex = 0,
      this.isComplete = false,
      this.startedAt,
      this.completedAt,
      this.errorMessage});

  factory _$GenerationStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$GenerationStatusImplFromJson(json);

  @override
  final int totalChapters;
  @override
  @JsonKey()
  final int completedChapters;
  @override
  @JsonKey()
  final int currentChapterIndex;
  @override
  @JsonKey()
  final bool isComplete;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'GenerationStatus(totalChapters: $totalChapters, completedChapters: $completedChapters, currentChapterIndex: $currentChapterIndex, isComplete: $isComplete, startedAt: $startedAt, completedAt: $completedAt, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GenerationStatusImpl &&
            (identical(other.totalChapters, totalChapters) ||
                other.totalChapters == totalChapters) &&
            (identical(other.completedChapters, completedChapters) ||
                other.completedChapters == completedChapters) &&
            (identical(other.currentChapterIndex, currentChapterIndex) ||
                other.currentChapterIndex == currentChapterIndex) &&
            (identical(other.isComplete, isComplete) ||
                other.isComplete == isComplete) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, totalChapters, completedChapters,
      currentChapterIndex, isComplete, startedAt, completedAt, errorMessage);

  /// Create a copy of GenerationStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GenerationStatusImplCopyWith<_$GenerationStatusImpl> get copyWith =>
      __$$GenerationStatusImplCopyWithImpl<_$GenerationStatusImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GenerationStatusImplToJson(
      this,
    );
  }
}

abstract class _GenerationStatus implements GenerationStatus {
  const factory _GenerationStatus(
      {required final int totalChapters,
      final int completedChapters,
      final int currentChapterIndex,
      final bool isComplete,
      final DateTime? startedAt,
      final DateTime? completedAt,
      final String? errorMessage}) = _$GenerationStatusImpl;

  factory _GenerationStatus.fromJson(Map<String, dynamic> json) =
      _$GenerationStatusImpl.fromJson;

  @override
  int get totalChapters;
  @override
  int get completedChapters;
  @override
  int get currentChapterIndex;
  @override
  bool get isComplete;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  String? get errorMessage;

  /// Create a copy of GenerationStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GenerationStatusImplCopyWith<_$GenerationStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReadingProgress _$ReadingProgressFromJson(Map<String, dynamic> json) {
  return _ReadingProgress.fromJson(json);
}

/// @nodoc
mixin _$ReadingProgress {
  int get currentChapter => throw _privateConstructorUsedError;
  int get currentSection => throw _privateConstructorUsedError;
  double get scrollPosition => throw _privateConstructorUsedError;
  int get totalReadingTimeSeconds => throw _privateConstructorUsedError;
  DateTime get lastReadAt => throw _privateConstructorUsedError;

  /// Serializes this ReadingProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReadingProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReadingProgressCopyWith<ReadingProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReadingProgressCopyWith<$Res> {
  factory $ReadingProgressCopyWith(
          ReadingProgress value, $Res Function(ReadingProgress) then) =
      _$ReadingProgressCopyWithImpl<$Res, ReadingProgress>;
  @useResult
  $Res call(
      {int currentChapter,
      int currentSection,
      double scrollPosition,
      int totalReadingTimeSeconds,
      DateTime lastReadAt});
}

/// @nodoc
class _$ReadingProgressCopyWithImpl<$Res, $Val extends ReadingProgress>
    implements $ReadingProgressCopyWith<$Res> {
  _$ReadingProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReadingProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentChapter = null,
    Object? currentSection = null,
    Object? scrollPosition = null,
    Object? totalReadingTimeSeconds = null,
    Object? lastReadAt = null,
  }) {
    return _then(_value.copyWith(
      currentChapter: null == currentChapter
          ? _value.currentChapter
          : currentChapter // ignore: cast_nullable_to_non_nullable
              as int,
      currentSection: null == currentSection
          ? _value.currentSection
          : currentSection // ignore: cast_nullable_to_non_nullable
              as int,
      scrollPosition: null == scrollPosition
          ? _value.scrollPosition
          : scrollPosition // ignore: cast_nullable_to_non_nullable
              as double,
      totalReadingTimeSeconds: null == totalReadingTimeSeconds
          ? _value.totalReadingTimeSeconds
          : totalReadingTimeSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      lastReadAt: null == lastReadAt
          ? _value.lastReadAt
          : lastReadAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReadingProgressImplCopyWith<$Res>
    implements $ReadingProgressCopyWith<$Res> {
  factory _$$ReadingProgressImplCopyWith(_$ReadingProgressImpl value,
          $Res Function(_$ReadingProgressImpl) then) =
      __$$ReadingProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int currentChapter,
      int currentSection,
      double scrollPosition,
      int totalReadingTimeSeconds,
      DateTime lastReadAt});
}

/// @nodoc
class __$$ReadingProgressImplCopyWithImpl<$Res>
    extends _$ReadingProgressCopyWithImpl<$Res, _$ReadingProgressImpl>
    implements _$$ReadingProgressImplCopyWith<$Res> {
  __$$ReadingProgressImplCopyWithImpl(
      _$ReadingProgressImpl _value, $Res Function(_$ReadingProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReadingProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentChapter = null,
    Object? currentSection = null,
    Object? scrollPosition = null,
    Object? totalReadingTimeSeconds = null,
    Object? lastReadAt = null,
  }) {
    return _then(_$ReadingProgressImpl(
      currentChapter: null == currentChapter
          ? _value.currentChapter
          : currentChapter // ignore: cast_nullable_to_non_nullable
              as int,
      currentSection: null == currentSection
          ? _value.currentSection
          : currentSection // ignore: cast_nullable_to_non_nullable
              as int,
      scrollPosition: null == scrollPosition
          ? _value.scrollPosition
          : scrollPosition // ignore: cast_nullable_to_non_nullable
              as double,
      totalReadingTimeSeconds: null == totalReadingTimeSeconds
          ? _value.totalReadingTimeSeconds
          : totalReadingTimeSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      lastReadAt: null == lastReadAt
          ? _value.lastReadAt
          : lastReadAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReadingProgressImpl implements _ReadingProgress {
  const _$ReadingProgressImpl(
      {this.currentChapter = 0,
      this.currentSection = 0,
      this.scrollPosition = 0.0,
      this.totalReadingTimeSeconds = 0,
      required this.lastReadAt});

  factory _$ReadingProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReadingProgressImplFromJson(json);

  @override
  @JsonKey()
  final int currentChapter;
  @override
  @JsonKey()
  final int currentSection;
  @override
  @JsonKey()
  final double scrollPosition;
  @override
  @JsonKey()
  final int totalReadingTimeSeconds;
  @override
  final DateTime lastReadAt;

  @override
  String toString() {
    return 'ReadingProgress(currentChapter: $currentChapter, currentSection: $currentSection, scrollPosition: $scrollPosition, totalReadingTimeSeconds: $totalReadingTimeSeconds, lastReadAt: $lastReadAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadingProgressImpl &&
            (identical(other.currentChapter, currentChapter) ||
                other.currentChapter == currentChapter) &&
            (identical(other.currentSection, currentSection) ||
                other.currentSection == currentSection) &&
            (identical(other.scrollPosition, scrollPosition) ||
                other.scrollPosition == scrollPosition) &&
            (identical(
                    other.totalReadingTimeSeconds, totalReadingTimeSeconds) ||
                other.totalReadingTimeSeconds == totalReadingTimeSeconds) &&
            (identical(other.lastReadAt, lastReadAt) ||
                other.lastReadAt == lastReadAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, currentChapter, currentSection,
      scrollPosition, totalReadingTimeSeconds, lastReadAt);

  /// Create a copy of ReadingProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadingProgressImplCopyWith<_$ReadingProgressImpl> get copyWith =>
      __$$ReadingProgressImplCopyWithImpl<_$ReadingProgressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReadingProgressImplToJson(
      this,
    );
  }
}

abstract class _ReadingProgress implements ReadingProgress {
  const factory _ReadingProgress(
      {final int currentChapter,
      final int currentSection,
      final double scrollPosition,
      final int totalReadingTimeSeconds,
      required final DateTime lastReadAt}) = _$ReadingProgressImpl;

  factory _ReadingProgress.fromJson(Map<String, dynamic> json) =
      _$ReadingProgressImpl.fromJson;

  @override
  int get currentChapter;
  @override
  int get currentSection;
  @override
  double get scrollPosition;
  @override
  int get totalReadingTimeSeconds;
  @override
  DateTime get lastReadAt;

  /// Create a copy of ReadingProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReadingProgressImplCopyWith<_$ReadingProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Bookmark _$BookmarkFromJson(Map<String, dynamic> json) {
  return _Bookmark.fromJson(json);
}

/// @nodoc
mixin _$Bookmark {
  String get id => throw _privateConstructorUsedError;
  int get chapterIndex => throw _privateConstructorUsedError;
  int get sectionIndex => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  /// Serializes this Bookmark to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Bookmark
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookmarkCopyWith<Bookmark> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookmarkCopyWith<$Res> {
  factory $BookmarkCopyWith(Bookmark value, $Res Function(Bookmark) then) =
      _$BookmarkCopyWithImpl<$Res, Bookmark>;
  @useResult
  $Res call(
      {String id,
      int chapterIndex,
      int sectionIndex,
      String title,
      DateTime createdAt,
      String? note});
}

/// @nodoc
class _$BookmarkCopyWithImpl<$Res, $Val extends Bookmark>
    implements $BookmarkCopyWith<$Res> {
  _$BookmarkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Bookmark
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chapterIndex = null,
    Object? sectionIndex = null,
    Object? title = null,
    Object? createdAt = null,
    Object? note = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chapterIndex: null == chapterIndex
          ? _value.chapterIndex
          : chapterIndex // ignore: cast_nullable_to_non_nullable
              as int,
      sectionIndex: null == sectionIndex
          ? _value.sectionIndex
          : sectionIndex // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookmarkImplCopyWith<$Res>
    implements $BookmarkCopyWith<$Res> {
  factory _$$BookmarkImplCopyWith(
          _$BookmarkImpl value, $Res Function(_$BookmarkImpl) then) =
      __$$BookmarkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int chapterIndex,
      int sectionIndex,
      String title,
      DateTime createdAt,
      String? note});
}

/// @nodoc
class __$$BookmarkImplCopyWithImpl<$Res>
    extends _$BookmarkCopyWithImpl<$Res, _$BookmarkImpl>
    implements _$$BookmarkImplCopyWith<$Res> {
  __$$BookmarkImplCopyWithImpl(
      _$BookmarkImpl _value, $Res Function(_$BookmarkImpl) _then)
      : super(_value, _then);

  /// Create a copy of Bookmark
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chapterIndex = null,
    Object? sectionIndex = null,
    Object? title = null,
    Object? createdAt = null,
    Object? note = freezed,
  }) {
    return _then(_$BookmarkImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chapterIndex: null == chapterIndex
          ? _value.chapterIndex
          : chapterIndex // ignore: cast_nullable_to_non_nullable
              as int,
      sectionIndex: null == sectionIndex
          ? _value.sectionIndex
          : sectionIndex // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookmarkImpl implements _Bookmark {
  const _$BookmarkImpl(
      {required this.id,
      required this.chapterIndex,
      required this.sectionIndex,
      required this.title,
      required this.createdAt,
      this.note});

  factory _$BookmarkImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookmarkImplFromJson(json);

  @override
  final String id;
  @override
  final int chapterIndex;
  @override
  final int sectionIndex;
  @override
  final String title;
  @override
  final DateTime createdAt;
  @override
  final String? note;

  @override
  String toString() {
    return 'Bookmark(id: $id, chapterIndex: $chapterIndex, sectionIndex: $sectionIndex, title: $title, createdAt: $createdAt, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookmarkImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chapterIndex, chapterIndex) ||
                other.chapterIndex == chapterIndex) &&
            (identical(other.sectionIndex, sectionIndex) ||
                other.sectionIndex == sectionIndex) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, chapterIndex, sectionIndex, title, createdAt, note);

  /// Create a copy of Bookmark
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookmarkImplCopyWith<_$BookmarkImpl> get copyWith =>
      __$$BookmarkImplCopyWithImpl<_$BookmarkImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookmarkImplToJson(
      this,
    );
  }
}

abstract class _Bookmark implements Bookmark {
  const factory _Bookmark(
      {required final String id,
      required final int chapterIndex,
      required final int sectionIndex,
      required final String title,
      required final DateTime createdAt,
      final String? note}) = _$BookmarkImpl;

  factory _Bookmark.fromJson(Map<String, dynamic> json) =
      _$BookmarkImpl.fromJson;

  @override
  String get id;
  @override
  int get chapterIndex;
  @override
  int get sectionIndex;
  @override
  String get title;
  @override
  DateTime get createdAt;
  @override
  String? get note;

  /// Create a copy of Bookmark
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookmarkImplCopyWith<_$BookmarkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PurchaseInfo _$PurchaseInfoFromJson(Map<String, dynamic> json) {
  return _PurchaseInfo.fromJson(json);
}

/// @nodoc
mixin _$PurchaseInfo {
  String get transactionId => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  DateTime get purchasedAt => throw _privateConstructorUsedError;
  bool get isLifetimeOwnership => throw _privateConstructorUsedError;

  /// Serializes this PurchaseInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PurchaseInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PurchaseInfoCopyWith<PurchaseInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseInfoCopyWith<$Res> {
  factory $PurchaseInfoCopyWith(
          PurchaseInfo value, $Res Function(PurchaseInfo) then) =
      _$PurchaseInfoCopyWithImpl<$Res, PurchaseInfo>;
  @useResult
  $Res call(
      {String transactionId,
      String productId,
      double price,
      String currency,
      DateTime purchasedAt,
      bool isLifetimeOwnership});
}

/// @nodoc
class _$PurchaseInfoCopyWithImpl<$Res, $Val extends PurchaseInfo>
    implements $PurchaseInfoCopyWith<$Res> {
  _$PurchaseInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PurchaseInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionId = null,
    Object? productId = null,
    Object? price = null,
    Object? currency = null,
    Object? purchasedAt = null,
    Object? isLifetimeOwnership = null,
  }) {
    return _then(_value.copyWith(
      transactionId: null == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      purchasedAt: null == purchasedAt
          ? _value.purchasedAt
          : purchasedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isLifetimeOwnership: null == isLifetimeOwnership
          ? _value.isLifetimeOwnership
          : isLifetimeOwnership // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PurchaseInfoImplCopyWith<$Res>
    implements $PurchaseInfoCopyWith<$Res> {
  factory _$$PurchaseInfoImplCopyWith(
          _$PurchaseInfoImpl value, $Res Function(_$PurchaseInfoImpl) then) =
      __$$PurchaseInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String transactionId,
      String productId,
      double price,
      String currency,
      DateTime purchasedAt,
      bool isLifetimeOwnership});
}

/// @nodoc
class __$$PurchaseInfoImplCopyWithImpl<$Res>
    extends _$PurchaseInfoCopyWithImpl<$Res, _$PurchaseInfoImpl>
    implements _$$PurchaseInfoImplCopyWith<$Res> {
  __$$PurchaseInfoImplCopyWithImpl(
      _$PurchaseInfoImpl _value, $Res Function(_$PurchaseInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of PurchaseInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionId = null,
    Object? productId = null,
    Object? price = null,
    Object? currency = null,
    Object? purchasedAt = null,
    Object? isLifetimeOwnership = null,
  }) {
    return _then(_$PurchaseInfoImpl(
      transactionId: null == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      purchasedAt: null == purchasedAt
          ? _value.purchasedAt
          : purchasedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isLifetimeOwnership: null == isLifetimeOwnership
          ? _value.isLifetimeOwnership
          : isLifetimeOwnership // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PurchaseInfoImpl implements _PurchaseInfo {
  const _$PurchaseInfoImpl(
      {required this.transactionId,
      required this.productId,
      required this.price,
      this.currency = 'KRW',
      required this.purchasedAt,
      this.isLifetimeOwnership = true});

  factory _$PurchaseInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchaseInfoImplFromJson(json);

  @override
  final String transactionId;
  @override
  final String productId;
  @override
  final double price;
  @override
  @JsonKey()
  final String currency;
  @override
  final DateTime purchasedAt;
  @override
  @JsonKey()
  final bool isLifetimeOwnership;

  @override
  String toString() {
    return 'PurchaseInfo(transactionId: $transactionId, productId: $productId, price: $price, currency: $currency, purchasedAt: $purchasedAt, isLifetimeOwnership: $isLifetimeOwnership)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseInfoImpl &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.purchasedAt, purchasedAt) ||
                other.purchasedAt == purchasedAt) &&
            (identical(other.isLifetimeOwnership, isLifetimeOwnership) ||
                other.isLifetimeOwnership == isLifetimeOwnership));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, transactionId, productId, price,
      currency, purchasedAt, isLifetimeOwnership);

  /// Create a copy of PurchaseInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseInfoImplCopyWith<_$PurchaseInfoImpl> get copyWith =>
      __$$PurchaseInfoImplCopyWithImpl<_$PurchaseInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseInfoImplToJson(
      this,
    );
  }
}

abstract class _PurchaseInfo implements PurchaseInfo {
  const factory _PurchaseInfo(
      {required final String transactionId,
      required final String productId,
      required final double price,
      final String currency,
      required final DateTime purchasedAt,
      final bool isLifetimeOwnership}) = _$PurchaseInfoImpl;

  factory _PurchaseInfo.fromJson(Map<String, dynamic> json) =
      _$PurchaseInfoImpl.fromJson;

  @override
  String get transactionId;
  @override
  String get productId;
  @override
  double get price;
  @override
  String get currency;
  @override
  DateTime get purchasedAt;
  @override
  bool get isLifetimeOwnership;

  /// Create a copy of PurchaseInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PurchaseInfoImplCopyWith<_$PurchaseInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GrandLuck _$GrandLuckFromJson(Map<String, dynamic> json) {
  return _GrandLuck.fromJson(json);
}

/// @nodoc
mixin _$GrandLuck {
  int get order => throw _privateConstructorUsedError; // 1~8대운
  int get startAge => throw _privateConstructorUsedError; // 시작 나이
  int get endAge => throw _privateConstructorUsedError; // 끝 나이
  String get heavenlyStem => throw _privateConstructorUsedError; // 대운 천간
  String get earthlyBranch => throw _privateConstructorUsedError; // 대운 지지
  String get element => throw _privateConstructorUsedError; // 오행
  String get summary => throw _privateConstructorUsedError; // 대운 요약
  String get detailedAnalysis => throw _privateConstructorUsedError; // 상세 분석
  List<String> get keyEvents => throw _privateConstructorUsedError; // 주요 이벤트
  Map<String, int> get fortuneScores => throw _privateConstructorUsedError;

  /// Serializes this GrandLuck to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GrandLuck
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GrandLuckCopyWith<GrandLuck> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GrandLuckCopyWith<$Res> {
  factory $GrandLuckCopyWith(GrandLuck value, $Res Function(GrandLuck) then) =
      _$GrandLuckCopyWithImpl<$Res, GrandLuck>;
  @useResult
  $Res call(
      {int order,
      int startAge,
      int endAge,
      String heavenlyStem,
      String earthlyBranch,
      String element,
      String summary,
      String detailedAnalysis,
      List<String> keyEvents,
      Map<String, int> fortuneScores});
}

/// @nodoc
class _$GrandLuckCopyWithImpl<$Res, $Val extends GrandLuck>
    implements $GrandLuckCopyWith<$Res> {
  _$GrandLuckCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GrandLuck
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? order = null,
    Object? startAge = null,
    Object? endAge = null,
    Object? heavenlyStem = null,
    Object? earthlyBranch = null,
    Object? element = null,
    Object? summary = null,
    Object? detailedAnalysis = null,
    Object? keyEvents = null,
    Object? fortuneScores = null,
  }) {
    return _then(_value.copyWith(
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      startAge: null == startAge
          ? _value.startAge
          : startAge // ignore: cast_nullable_to_non_nullable
              as int,
      endAge: null == endAge
          ? _value.endAge
          : endAge // ignore: cast_nullable_to_non_nullable
              as int,
      heavenlyStem: null == heavenlyStem
          ? _value.heavenlyStem
          : heavenlyStem // ignore: cast_nullable_to_non_nullable
              as String,
      earthlyBranch: null == earthlyBranch
          ? _value.earthlyBranch
          : earthlyBranch // ignore: cast_nullable_to_non_nullable
              as String,
      element: null == element
          ? _value.element
          : element // ignore: cast_nullable_to_non_nullable
              as String,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      detailedAnalysis: null == detailedAnalysis
          ? _value.detailedAnalysis
          : detailedAnalysis // ignore: cast_nullable_to_non_nullable
              as String,
      keyEvents: null == keyEvents
          ? _value.keyEvents
          : keyEvents // ignore: cast_nullable_to_non_nullable
              as List<String>,
      fortuneScores: null == fortuneScores
          ? _value.fortuneScores
          : fortuneScores // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GrandLuckImplCopyWith<$Res>
    implements $GrandLuckCopyWith<$Res> {
  factory _$$GrandLuckImplCopyWith(
          _$GrandLuckImpl value, $Res Function(_$GrandLuckImpl) then) =
      __$$GrandLuckImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int order,
      int startAge,
      int endAge,
      String heavenlyStem,
      String earthlyBranch,
      String element,
      String summary,
      String detailedAnalysis,
      List<String> keyEvents,
      Map<String, int> fortuneScores});
}

/// @nodoc
class __$$GrandLuckImplCopyWithImpl<$Res>
    extends _$GrandLuckCopyWithImpl<$Res, _$GrandLuckImpl>
    implements _$$GrandLuckImplCopyWith<$Res> {
  __$$GrandLuckImplCopyWithImpl(
      _$GrandLuckImpl _value, $Res Function(_$GrandLuckImpl) _then)
      : super(_value, _then);

  /// Create a copy of GrandLuck
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? order = null,
    Object? startAge = null,
    Object? endAge = null,
    Object? heavenlyStem = null,
    Object? earthlyBranch = null,
    Object? element = null,
    Object? summary = null,
    Object? detailedAnalysis = null,
    Object? keyEvents = null,
    Object? fortuneScores = null,
  }) {
    return _then(_$GrandLuckImpl(
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      startAge: null == startAge
          ? _value.startAge
          : startAge // ignore: cast_nullable_to_non_nullable
              as int,
      endAge: null == endAge
          ? _value.endAge
          : endAge // ignore: cast_nullable_to_non_nullable
              as int,
      heavenlyStem: null == heavenlyStem
          ? _value.heavenlyStem
          : heavenlyStem // ignore: cast_nullable_to_non_nullable
              as String,
      earthlyBranch: null == earthlyBranch
          ? _value.earthlyBranch
          : earthlyBranch // ignore: cast_nullable_to_non_nullable
              as String,
      element: null == element
          ? _value.element
          : element // ignore: cast_nullable_to_non_nullable
              as String,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      detailedAnalysis: null == detailedAnalysis
          ? _value.detailedAnalysis
          : detailedAnalysis // ignore: cast_nullable_to_non_nullable
              as String,
      keyEvents: null == keyEvents
          ? _value._keyEvents
          : keyEvents // ignore: cast_nullable_to_non_nullable
              as List<String>,
      fortuneScores: null == fortuneScores
          ? _value._fortuneScores
          : fortuneScores // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GrandLuckImpl implements _GrandLuck {
  const _$GrandLuckImpl(
      {required this.order,
      required this.startAge,
      required this.endAge,
      required this.heavenlyStem,
      required this.earthlyBranch,
      required this.element,
      required this.summary,
      required this.detailedAnalysis,
      final List<String> keyEvents = const [],
      final Map<String, int> fortuneScores = const {}})
      : _keyEvents = keyEvents,
        _fortuneScores = fortuneScores;

  factory _$GrandLuckImpl.fromJson(Map<String, dynamic> json) =>
      _$$GrandLuckImplFromJson(json);

  @override
  final int order;
// 1~8대운
  @override
  final int startAge;
// 시작 나이
  @override
  final int endAge;
// 끝 나이
  @override
  final String heavenlyStem;
// 대운 천간
  @override
  final String earthlyBranch;
// 대운 지지
  @override
  final String element;
// 오행
  @override
  final String summary;
// 대운 요약
  @override
  final String detailedAnalysis;
// 상세 분석
  final List<String> _keyEvents;
// 상세 분석
  @override
  @JsonKey()
  List<String> get keyEvents {
    if (_keyEvents is EqualUnmodifiableListView) return _keyEvents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keyEvents);
  }

// 주요 이벤트
  final Map<String, int> _fortuneScores;
// 주요 이벤트
  @override
  @JsonKey()
  Map<String, int> get fortuneScores {
    if (_fortuneScores is EqualUnmodifiableMapView) return _fortuneScores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_fortuneScores);
  }

  @override
  String toString() {
    return 'GrandLuck(order: $order, startAge: $startAge, endAge: $endAge, heavenlyStem: $heavenlyStem, earthlyBranch: $earthlyBranch, element: $element, summary: $summary, detailedAnalysis: $detailedAnalysis, keyEvents: $keyEvents, fortuneScores: $fortuneScores)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GrandLuckImpl &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.startAge, startAge) ||
                other.startAge == startAge) &&
            (identical(other.endAge, endAge) || other.endAge == endAge) &&
            (identical(other.heavenlyStem, heavenlyStem) ||
                other.heavenlyStem == heavenlyStem) &&
            (identical(other.earthlyBranch, earthlyBranch) ||
                other.earthlyBranch == earthlyBranch) &&
            (identical(other.element, element) || other.element == element) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.detailedAnalysis, detailedAnalysis) ||
                other.detailedAnalysis == detailedAnalysis) &&
            const DeepCollectionEquality()
                .equals(other._keyEvents, _keyEvents) &&
            const DeepCollectionEquality()
                .equals(other._fortuneScores, _fortuneScores));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      order,
      startAge,
      endAge,
      heavenlyStem,
      earthlyBranch,
      element,
      summary,
      detailedAnalysis,
      const DeepCollectionEquality().hash(_keyEvents),
      const DeepCollectionEquality().hash(_fortuneScores));

  /// Create a copy of GrandLuck
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GrandLuckImplCopyWith<_$GrandLuckImpl> get copyWith =>
      __$$GrandLuckImplCopyWithImpl<_$GrandLuckImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GrandLuckImplToJson(
      this,
    );
  }
}

abstract class _GrandLuck implements GrandLuck {
  const factory _GrandLuck(
      {required final int order,
      required final int startAge,
      required final int endAge,
      required final String heavenlyStem,
      required final String earthlyBranch,
      required final String element,
      required final String summary,
      required final String detailedAnalysis,
      final List<String> keyEvents,
      final Map<String, int> fortuneScores}) = _$GrandLuckImpl;

  factory _GrandLuck.fromJson(Map<String, dynamic> json) =
      _$GrandLuckImpl.fromJson;

  @override
  int get order; // 1~8대운
  @override
  int get startAge; // 시작 나이
  @override
  int get endAge; // 끝 나이
  @override
  String get heavenlyStem; // 대운 천간
  @override
  String get earthlyBranch; // 대운 지지
  @override
  String get element; // 오행
  @override
  String get summary; // 대운 요약
  @override
  String get detailedAnalysis; // 상세 분석
  @override
  List<String> get keyEvents; // 주요 이벤트
  @override
  Map<String, int> get fortuneScores;

  /// Create a copy of GrandLuck
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GrandLuckImplCopyWith<_$GrandLuckImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShinSal _$ShinSalFromJson(Map<String, dynamic> json) {
  return _ShinSal.fromJson(json);
}

/// @nodoc
mixin _$ShinSal {
  String get name => throw _privateConstructorUsedError; // 신살명 (천을귀인, 문창귀인 등)
  String get type => throw _privateConstructorUsedError; // 길신/흉신
  String get position => throw _privateConstructorUsedError; // 위치 (년주, 월주 등)
  String get description => throw _privateConstructorUsedError; // 설명
  String get effect => throw _privateConstructorUsedError;

  /// Serializes this ShinSal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShinSal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShinSalCopyWith<ShinSal> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShinSalCopyWith<$Res> {
  factory $ShinSalCopyWith(ShinSal value, $Res Function(ShinSal) then) =
      _$ShinSalCopyWithImpl<$Res, ShinSal>;
  @useResult
  $Res call(
      {String name,
      String type,
      String position,
      String description,
      String effect});
}

/// @nodoc
class _$ShinSalCopyWithImpl<$Res, $Val extends ShinSal>
    implements $ShinSalCopyWith<$Res> {
  _$ShinSalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShinSal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? position = null,
    Object? description = null,
    Object? effect = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShinSalImplCopyWith<$Res> implements $ShinSalCopyWith<$Res> {
  factory _$$ShinSalImplCopyWith(
          _$ShinSalImpl value, $Res Function(_$ShinSalImpl) then) =
      __$$ShinSalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String type,
      String position,
      String description,
      String effect});
}

/// @nodoc
class __$$ShinSalImplCopyWithImpl<$Res>
    extends _$ShinSalCopyWithImpl<$Res, _$ShinSalImpl>
    implements _$$ShinSalImplCopyWith<$Res> {
  __$$ShinSalImplCopyWithImpl(
      _$ShinSalImpl _value, $Res Function(_$ShinSalImpl) _then)
      : super(_value, _then);

  /// Create a copy of ShinSal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? position = null,
    Object? description = null,
    Object? effect = null,
  }) {
    return _then(_$ShinSalImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShinSalImpl implements _ShinSal {
  const _$ShinSalImpl(
      {required this.name,
      required this.type,
      required this.position,
      required this.description,
      required this.effect});

  factory _$ShinSalImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShinSalImplFromJson(json);

  @override
  final String name;
// 신살명 (천을귀인, 문창귀인 등)
  @override
  final String type;
// 길신/흉신
  @override
  final String position;
// 위치 (년주, 월주 등)
  @override
  final String description;
// 설명
  @override
  final String effect;

  @override
  String toString() {
    return 'ShinSal(name: $name, type: $type, position: $position, description: $description, effect: $effect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShinSalImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.effect, effect) || other.effect == effect));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, type, position, description, effect);

  /// Create a copy of ShinSal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShinSalImplCopyWith<_$ShinSalImpl> get copyWith =>
      __$$ShinSalImplCopyWithImpl<_$ShinSalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShinSalImplToJson(
      this,
    );
  }
}

abstract class _ShinSal implements ShinSal {
  const factory _ShinSal(
      {required final String name,
      required final String type,
      required final String position,
      required final String description,
      required final String effect}) = _$ShinSalImpl;

  factory _ShinSal.fromJson(Map<String, dynamic> json) = _$ShinSalImpl.fromJson;

  @override
  String get name; // 신살명 (천을귀인, 문창귀인 등)
  @override
  String get type; // 길신/흉신
  @override
  String get position; // 위치 (년주, 월주 등)
  @override
  String get description; // 설명
  @override
  String get effect;

  /// Create a copy of ShinSal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShinSalImplCopyWith<_$ShinSalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
