// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shared_widget_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SharedWidgetData _$SharedWidgetDataFromJson(Map<String, dynamic> json) {
  return _SharedWidgetData.fromJson(json);
}

/// @nodoc
mixin _$SharedWidgetData {
  /// 총운 데이터
  WidgetOverallData get overall => throw _privateConstructorUsedError;

  /// 카테고리별 운세 (연애/금전/직장/학업/건강)
  Map<String, WidgetCategoryData> get categories =>
      throw _privateConstructorUsedError;

  /// 시간대별 운세 (아침/오후/저녁)
  List<WidgetTimeSlotData> get timeSlots => throw _privateConstructorUsedError;

  /// 로또 번호 (상위 5개)
  List<int> get lottoNumbers => throw _privateConstructorUsedError;

  /// 데이터 갱신 시각
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// 데이터 유효 날짜 (YYYY-MM-DD)
  String get validDate => throw _privateConstructorUsedError;

  /// 위젯 표시 상태 (today/yesterday/empty)
  WidgetDisplayState get displayState => throw _privateConstructorUsedError;

  /// Engagement 유도 메시지 (앱 미접속 시)
  String? get engagementMessage => throw _privateConstructorUsedError;

  /// Serializes this SharedWidgetData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SharedWidgetData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SharedWidgetDataCopyWith<SharedWidgetData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SharedWidgetDataCopyWith<$Res> {
  factory $SharedWidgetDataCopyWith(
          SharedWidgetData value, $Res Function(SharedWidgetData) then) =
      _$SharedWidgetDataCopyWithImpl<$Res, SharedWidgetData>;
  @useResult
  $Res call(
      {WidgetOverallData overall,
      Map<String, WidgetCategoryData> categories,
      List<WidgetTimeSlotData> timeSlots,
      List<int> lottoNumbers,
      DateTime updatedAt,
      String validDate,
      WidgetDisplayState displayState,
      String? engagementMessage});

  $WidgetOverallDataCopyWith<$Res> get overall;
}

/// @nodoc
class _$SharedWidgetDataCopyWithImpl<$Res, $Val extends SharedWidgetData>
    implements $SharedWidgetDataCopyWith<$Res> {
  _$SharedWidgetDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SharedWidgetData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? overall = null,
    Object? categories = null,
    Object? timeSlots = null,
    Object? lottoNumbers = null,
    Object? updatedAt = null,
    Object? validDate = null,
    Object? displayState = null,
    Object? engagementMessage = freezed,
  }) {
    return _then(_value.copyWith(
      overall: null == overall
          ? _value.overall
          : overall // ignore: cast_nullable_to_non_nullable
              as WidgetOverallData,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as Map<String, WidgetCategoryData>,
      timeSlots: null == timeSlots
          ? _value.timeSlots
          : timeSlots // ignore: cast_nullable_to_non_nullable
              as List<WidgetTimeSlotData>,
      lottoNumbers: null == lottoNumbers
          ? _value.lottoNumbers
          : lottoNumbers // ignore: cast_nullable_to_non_nullable
              as List<int>,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      validDate: null == validDate
          ? _value.validDate
          : validDate // ignore: cast_nullable_to_non_nullable
              as String,
      displayState: null == displayState
          ? _value.displayState
          : displayState // ignore: cast_nullable_to_non_nullable
              as WidgetDisplayState,
      engagementMessage: freezed == engagementMessage
          ? _value.engagementMessage
          : engagementMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of SharedWidgetData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WidgetOverallDataCopyWith<$Res> get overall {
    return $WidgetOverallDataCopyWith<$Res>(_value.overall, (value) {
      return _then(_value.copyWith(overall: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SharedWidgetDataImplCopyWith<$Res>
    implements $SharedWidgetDataCopyWith<$Res> {
  factory _$$SharedWidgetDataImplCopyWith(_$SharedWidgetDataImpl value,
          $Res Function(_$SharedWidgetDataImpl) then) =
      __$$SharedWidgetDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {WidgetOverallData overall,
      Map<String, WidgetCategoryData> categories,
      List<WidgetTimeSlotData> timeSlots,
      List<int> lottoNumbers,
      DateTime updatedAt,
      String validDate,
      WidgetDisplayState displayState,
      String? engagementMessage});

  @override
  $WidgetOverallDataCopyWith<$Res> get overall;
}

/// @nodoc
class __$$SharedWidgetDataImplCopyWithImpl<$Res>
    extends _$SharedWidgetDataCopyWithImpl<$Res, _$SharedWidgetDataImpl>
    implements _$$SharedWidgetDataImplCopyWith<$Res> {
  __$$SharedWidgetDataImplCopyWithImpl(_$SharedWidgetDataImpl _value,
      $Res Function(_$SharedWidgetDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of SharedWidgetData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? overall = null,
    Object? categories = null,
    Object? timeSlots = null,
    Object? lottoNumbers = null,
    Object? updatedAt = null,
    Object? validDate = null,
    Object? displayState = null,
    Object? engagementMessage = freezed,
  }) {
    return _then(_$SharedWidgetDataImpl(
      overall: null == overall
          ? _value.overall
          : overall // ignore: cast_nullable_to_non_nullable
              as WidgetOverallData,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as Map<String, WidgetCategoryData>,
      timeSlots: null == timeSlots
          ? _value._timeSlots
          : timeSlots // ignore: cast_nullable_to_non_nullable
              as List<WidgetTimeSlotData>,
      lottoNumbers: null == lottoNumbers
          ? _value._lottoNumbers
          : lottoNumbers // ignore: cast_nullable_to_non_nullable
              as List<int>,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      validDate: null == validDate
          ? _value.validDate
          : validDate // ignore: cast_nullable_to_non_nullable
              as String,
      displayState: null == displayState
          ? _value.displayState
          : displayState // ignore: cast_nullable_to_non_nullable
              as WidgetDisplayState,
      engagementMessage: freezed == engagementMessage
          ? _value.engagementMessage
          : engagementMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SharedWidgetDataImpl implements _SharedWidgetData {
  const _$SharedWidgetDataImpl(
      {required this.overall,
      required final Map<String, WidgetCategoryData> categories,
      required final List<WidgetTimeSlotData> timeSlots,
      required final List<int> lottoNumbers,
      required this.updatedAt,
      required this.validDate,
      this.displayState = WidgetDisplayState.today,
      this.engagementMessage})
      : _categories = categories,
        _timeSlots = timeSlots,
        _lottoNumbers = lottoNumbers;

  factory _$SharedWidgetDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$SharedWidgetDataImplFromJson(json);

  /// 총운 데이터
  @override
  final WidgetOverallData overall;

  /// 카테고리별 운세 (연애/금전/직장/학업/건강)
  final Map<String, WidgetCategoryData> _categories;

  /// 카테고리별 운세 (연애/금전/직장/학업/건강)
  @override
  Map<String, WidgetCategoryData> get categories {
    if (_categories is EqualUnmodifiableMapView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_categories);
  }

  /// 시간대별 운세 (아침/오후/저녁)
  final List<WidgetTimeSlotData> _timeSlots;

  /// 시간대별 운세 (아침/오후/저녁)
  @override
  List<WidgetTimeSlotData> get timeSlots {
    if (_timeSlots is EqualUnmodifiableListView) return _timeSlots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timeSlots);
  }

  /// 로또 번호 (상위 5개)
  final List<int> _lottoNumbers;

  /// 로또 번호 (상위 5개)
  @override
  List<int> get lottoNumbers {
    if (_lottoNumbers is EqualUnmodifiableListView) return _lottoNumbers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lottoNumbers);
  }

  /// 데이터 갱신 시각
  @override
  final DateTime updatedAt;

  /// 데이터 유효 날짜 (YYYY-MM-DD)
  @override
  final String validDate;

  /// 위젯 표시 상태 (today/yesterday/empty)
  @override
  @JsonKey()
  final WidgetDisplayState displayState;

  /// Engagement 유도 메시지 (앱 미접속 시)
  @override
  final String? engagementMessage;

  @override
  String toString() {
    return 'SharedWidgetData(overall: $overall, categories: $categories, timeSlots: $timeSlots, lottoNumbers: $lottoNumbers, updatedAt: $updatedAt, validDate: $validDate, displayState: $displayState, engagementMessage: $engagementMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SharedWidgetDataImpl &&
            (identical(other.overall, overall) || other.overall == overall) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            const DeepCollectionEquality()
                .equals(other._timeSlots, _timeSlots) &&
            const DeepCollectionEquality()
                .equals(other._lottoNumbers, _lottoNumbers) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.validDate, validDate) ||
                other.validDate == validDate) &&
            (identical(other.displayState, displayState) ||
                other.displayState == displayState) &&
            (identical(other.engagementMessage, engagementMessage) ||
                other.engagementMessage == engagementMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      overall,
      const DeepCollectionEquality().hash(_categories),
      const DeepCollectionEquality().hash(_timeSlots),
      const DeepCollectionEquality().hash(_lottoNumbers),
      updatedAt,
      validDate,
      displayState,
      engagementMessage);

  /// Create a copy of SharedWidgetData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SharedWidgetDataImplCopyWith<_$SharedWidgetDataImpl> get copyWith =>
      __$$SharedWidgetDataImplCopyWithImpl<_$SharedWidgetDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SharedWidgetDataImplToJson(
      this,
    );
  }
}

abstract class _SharedWidgetData implements SharedWidgetData {
  const factory _SharedWidgetData(
      {required final WidgetOverallData overall,
      required final Map<String, WidgetCategoryData> categories,
      required final List<WidgetTimeSlotData> timeSlots,
      required final List<int> lottoNumbers,
      required final DateTime updatedAt,
      required final String validDate,
      final WidgetDisplayState displayState,
      final String? engagementMessage}) = _$SharedWidgetDataImpl;

  factory _SharedWidgetData.fromJson(Map<String, dynamic> json) =
      _$SharedWidgetDataImpl.fromJson;

  /// 총운 데이터
  @override
  WidgetOverallData get overall;

  /// 카테고리별 운세 (연애/금전/직장/학업/건강)
  @override
  Map<String, WidgetCategoryData> get categories;

  /// 시간대별 운세 (아침/오후/저녁)
  @override
  List<WidgetTimeSlotData> get timeSlots;

  /// 로또 번호 (상위 5개)
  @override
  List<int> get lottoNumbers;

  /// 데이터 갱신 시각
  @override
  DateTime get updatedAt;

  /// 데이터 유효 날짜 (YYYY-MM-DD)
  @override
  String get validDate;

  /// 위젯 표시 상태 (today/yesterday/empty)
  @override
  WidgetDisplayState get displayState;

  /// Engagement 유도 메시지 (앱 미접속 시)
  @override
  String? get engagementMessage;

  /// Create a copy of SharedWidgetData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SharedWidgetDataImplCopyWith<_$SharedWidgetDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WidgetOverallData _$WidgetOverallDataFromJson(Map<String, dynamic> json) {
  return _WidgetOverallData.fromJson(json);
}

/// @nodoc
mixin _$WidgetOverallData {
  /// 총점 (0-100)
  int get score => throw _privateConstructorUsedError;

  /// 등급 (대길, 길, 평, 흉, 대흉)
  String get grade => throw _privateConstructorUsedError;

  /// 한줄 메시지
  String get message => throw _privateConstructorUsedError;

  /// 상세 설명 (Medium 위젯용)
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this WidgetOverallData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WidgetOverallData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WidgetOverallDataCopyWith<WidgetOverallData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WidgetOverallDataCopyWith<$Res> {
  factory $WidgetOverallDataCopyWith(
          WidgetOverallData value, $Res Function(WidgetOverallData) then) =
      _$WidgetOverallDataCopyWithImpl<$Res, WidgetOverallData>;
  @useResult
  $Res call({int score, String grade, String message, String? description});
}

/// @nodoc
class _$WidgetOverallDataCopyWithImpl<$Res, $Val extends WidgetOverallData>
    implements $WidgetOverallDataCopyWith<$Res> {
  _$WidgetOverallDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WidgetOverallData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? grade = null,
    Object? message = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      grade: null == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WidgetOverallDataImplCopyWith<$Res>
    implements $WidgetOverallDataCopyWith<$Res> {
  factory _$$WidgetOverallDataImplCopyWith(_$WidgetOverallDataImpl value,
          $Res Function(_$WidgetOverallDataImpl) then) =
      __$$WidgetOverallDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int score, String grade, String message, String? description});
}

/// @nodoc
class __$$WidgetOverallDataImplCopyWithImpl<$Res>
    extends _$WidgetOverallDataCopyWithImpl<$Res, _$WidgetOverallDataImpl>
    implements _$$WidgetOverallDataImplCopyWith<$Res> {
  __$$WidgetOverallDataImplCopyWithImpl(_$WidgetOverallDataImpl _value,
      $Res Function(_$WidgetOverallDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of WidgetOverallData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? grade = null,
    Object? message = null,
    Object? description = freezed,
  }) {
    return _then(_$WidgetOverallDataImpl(
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      grade: null == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WidgetOverallDataImpl implements _WidgetOverallData {
  const _$WidgetOverallDataImpl(
      {required this.score,
      required this.grade,
      required this.message,
      this.description});

  factory _$WidgetOverallDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$WidgetOverallDataImplFromJson(json);

  /// 총점 (0-100)
  @override
  final int score;

  /// 등급 (대길, 길, 평, 흉, 대흉)
  @override
  final String grade;

  /// 한줄 메시지
  @override
  final String message;

  /// 상세 설명 (Medium 위젯용)
  @override
  final String? description;

  @override
  String toString() {
    return 'WidgetOverallData(score: $score, grade: $grade, message: $message, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WidgetOverallDataImpl &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, score, grade, message, description);

  /// Create a copy of WidgetOverallData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WidgetOverallDataImplCopyWith<_$WidgetOverallDataImpl> get copyWith =>
      __$$WidgetOverallDataImplCopyWithImpl<_$WidgetOverallDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WidgetOverallDataImplToJson(
      this,
    );
  }
}

abstract class _WidgetOverallData implements WidgetOverallData {
  const factory _WidgetOverallData(
      {required final int score,
      required final String grade,
      required final String message,
      final String? description}) = _$WidgetOverallDataImpl;

  factory _WidgetOverallData.fromJson(Map<String, dynamic> json) =
      _$WidgetOverallDataImpl.fromJson;

  /// 총점 (0-100)
  @override
  int get score;

  /// 등급 (대길, 길, 평, 흉, 대흉)
  @override
  String get grade;

  /// 한줄 메시지
  @override
  String get message;

  /// 상세 설명 (Medium 위젯용)
  @override
  String? get description;

  /// Create a copy of WidgetOverallData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WidgetOverallDataImplCopyWith<_$WidgetOverallDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WidgetCategoryData _$WidgetCategoryDataFromJson(Map<String, dynamic> json) {
  return _WidgetCategoryData.fromJson(json);
}

/// @nodoc
mixin _$WidgetCategoryData {
  /// 카테고리 키 (love, money, work, study, health)
  String get key => throw _privateConstructorUsedError;

  /// 카테고리 이름 (연애운, 금전운, 직장운, 학업운, 건강운)
  String get name => throw _privateConstructorUsedError;

  /// 점수 (0-100)
  int get score => throw _privateConstructorUsedError;

  /// 한줄 메시지
  String get message => throw _privateConstructorUsedError;

  /// 아이콘 이모지
  String get icon => throw _privateConstructorUsedError;

  /// Serializes this WidgetCategoryData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WidgetCategoryData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WidgetCategoryDataCopyWith<WidgetCategoryData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WidgetCategoryDataCopyWith<$Res> {
  factory $WidgetCategoryDataCopyWith(
          WidgetCategoryData value, $Res Function(WidgetCategoryData) then) =
      _$WidgetCategoryDataCopyWithImpl<$Res, WidgetCategoryData>;
  @useResult
  $Res call({String key, String name, int score, String message, String icon});
}

/// @nodoc
class _$WidgetCategoryDataCopyWithImpl<$Res, $Val extends WidgetCategoryData>
    implements $WidgetCategoryDataCopyWith<$Res> {
  _$WidgetCategoryDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WidgetCategoryData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
    Object? score = null,
    Object? message = null,
    Object? icon = null,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WidgetCategoryDataImplCopyWith<$Res>
    implements $WidgetCategoryDataCopyWith<$Res> {
  factory _$$WidgetCategoryDataImplCopyWith(_$WidgetCategoryDataImpl value,
          $Res Function(_$WidgetCategoryDataImpl) then) =
      __$$WidgetCategoryDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, String name, int score, String message, String icon});
}

/// @nodoc
class __$$WidgetCategoryDataImplCopyWithImpl<$Res>
    extends _$WidgetCategoryDataCopyWithImpl<$Res, _$WidgetCategoryDataImpl>
    implements _$$WidgetCategoryDataImplCopyWith<$Res> {
  __$$WidgetCategoryDataImplCopyWithImpl(_$WidgetCategoryDataImpl _value,
      $Res Function(_$WidgetCategoryDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of WidgetCategoryData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
    Object? score = null,
    Object? message = null,
    Object? icon = null,
  }) {
    return _then(_$WidgetCategoryDataImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WidgetCategoryDataImpl implements _WidgetCategoryData {
  const _$WidgetCategoryDataImpl(
      {required this.key,
      required this.name,
      required this.score,
      required this.message,
      required this.icon});

  factory _$WidgetCategoryDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$WidgetCategoryDataImplFromJson(json);

  /// 카테고리 키 (love, money, work, study, health)
  @override
  final String key;

  /// 카테고리 이름 (연애운, 금전운, 직장운, 학업운, 건강운)
  @override
  final String name;

  /// 점수 (0-100)
  @override
  final int score;

  /// 한줄 메시지
  @override
  final String message;

  /// 아이콘 이모지
  @override
  final String icon;

  @override
  String toString() {
    return 'WidgetCategoryData(key: $key, name: $name, score: $score, message: $message, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WidgetCategoryDataImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, key, name, score, message, icon);

  /// Create a copy of WidgetCategoryData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WidgetCategoryDataImplCopyWith<_$WidgetCategoryDataImpl> get copyWith =>
      __$$WidgetCategoryDataImplCopyWithImpl<_$WidgetCategoryDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WidgetCategoryDataImplToJson(
      this,
    );
  }
}

abstract class _WidgetCategoryData implements WidgetCategoryData {
  const factory _WidgetCategoryData(
      {required final String key,
      required final String name,
      required final int score,
      required final String message,
      required final String icon}) = _$WidgetCategoryDataImpl;

  factory _WidgetCategoryData.fromJson(Map<String, dynamic> json) =
      _$WidgetCategoryDataImpl.fromJson;

  /// 카테고리 키 (love, money, work, study, health)
  @override
  String get key;

  /// 카테고리 이름 (연애운, 금전운, 직장운, 학업운, 건강운)
  @override
  String get name;

  /// 점수 (0-100)
  @override
  int get score;

  /// 한줄 메시지
  @override
  String get message;

  /// 아이콘 이모지
  @override
  String get icon;

  /// Create a copy of WidgetCategoryData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WidgetCategoryDataImplCopyWith<_$WidgetCategoryDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WidgetTimeSlotData _$WidgetTimeSlotDataFromJson(Map<String, dynamic> json) {
  return _WidgetTimeSlotData.fromJson(json);
}

/// @nodoc
mixin _$WidgetTimeSlotData {
  /// 시간대 키 (morning, afternoon, evening)
  String get key => throw _privateConstructorUsedError;

  /// 시간대 이름 (오전, 오후, 저녁)
  String get name => throw _privateConstructorUsedError;

  /// 시간 범위 (예: "06:00-12:00")
  String get timeRange => throw _privateConstructorUsedError;

  /// 점수 (0-100)
  int get score => throw _privateConstructorUsedError;

  /// 한줄 메시지
  String get message => throw _privateConstructorUsedError;

  /// 아이콘 이모지
  String get icon => throw _privateConstructorUsedError;

  /// Serializes this WidgetTimeSlotData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WidgetTimeSlotData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WidgetTimeSlotDataCopyWith<WidgetTimeSlotData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WidgetTimeSlotDataCopyWith<$Res> {
  factory $WidgetTimeSlotDataCopyWith(
          WidgetTimeSlotData value, $Res Function(WidgetTimeSlotData) then) =
      _$WidgetTimeSlotDataCopyWithImpl<$Res, WidgetTimeSlotData>;
  @useResult
  $Res call(
      {String key,
      String name,
      String timeRange,
      int score,
      String message,
      String icon});
}

/// @nodoc
class _$WidgetTimeSlotDataCopyWithImpl<$Res, $Val extends WidgetTimeSlotData>
    implements $WidgetTimeSlotDataCopyWith<$Res> {
  _$WidgetTimeSlotDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WidgetTimeSlotData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
    Object? timeRange = null,
    Object? score = null,
    Object? message = null,
    Object? icon = null,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      timeRange: null == timeRange
          ? _value.timeRange
          : timeRange // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WidgetTimeSlotDataImplCopyWith<$Res>
    implements $WidgetTimeSlotDataCopyWith<$Res> {
  factory _$$WidgetTimeSlotDataImplCopyWith(_$WidgetTimeSlotDataImpl value,
          $Res Function(_$WidgetTimeSlotDataImpl) then) =
      __$$WidgetTimeSlotDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String key,
      String name,
      String timeRange,
      int score,
      String message,
      String icon});
}

/// @nodoc
class __$$WidgetTimeSlotDataImplCopyWithImpl<$Res>
    extends _$WidgetTimeSlotDataCopyWithImpl<$Res, _$WidgetTimeSlotDataImpl>
    implements _$$WidgetTimeSlotDataImplCopyWith<$Res> {
  __$$WidgetTimeSlotDataImplCopyWithImpl(_$WidgetTimeSlotDataImpl _value,
      $Res Function(_$WidgetTimeSlotDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of WidgetTimeSlotData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
    Object? timeRange = null,
    Object? score = null,
    Object? message = null,
    Object? icon = null,
  }) {
    return _then(_$WidgetTimeSlotDataImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      timeRange: null == timeRange
          ? _value.timeRange
          : timeRange // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WidgetTimeSlotDataImpl implements _WidgetTimeSlotData {
  const _$WidgetTimeSlotDataImpl(
      {required this.key,
      required this.name,
      required this.timeRange,
      required this.score,
      required this.message,
      required this.icon});

  factory _$WidgetTimeSlotDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$WidgetTimeSlotDataImplFromJson(json);

  /// 시간대 키 (morning, afternoon, evening)
  @override
  final String key;

  /// 시간대 이름 (오전, 오후, 저녁)
  @override
  final String name;

  /// 시간 범위 (예: "06:00-12:00")
  @override
  final String timeRange;

  /// 점수 (0-100)
  @override
  final int score;

  /// 한줄 메시지
  @override
  final String message;

  /// 아이콘 이모지
  @override
  final String icon;

  @override
  String toString() {
    return 'WidgetTimeSlotData(key: $key, name: $name, timeRange: $timeRange, score: $score, message: $message, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WidgetTimeSlotDataImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.timeRange, timeRange) ||
                other.timeRange == timeRange) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, key, name, timeRange, score, message, icon);

  /// Create a copy of WidgetTimeSlotData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WidgetTimeSlotDataImplCopyWith<_$WidgetTimeSlotDataImpl> get copyWith =>
      __$$WidgetTimeSlotDataImplCopyWithImpl<_$WidgetTimeSlotDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WidgetTimeSlotDataImplToJson(
      this,
    );
  }
}

abstract class _WidgetTimeSlotData implements WidgetTimeSlotData {
  const factory _WidgetTimeSlotData(
      {required final String key,
      required final String name,
      required final String timeRange,
      required final int score,
      required final String message,
      required final String icon}) = _$WidgetTimeSlotDataImpl;

  factory _WidgetTimeSlotData.fromJson(Map<String, dynamic> json) =
      _$WidgetTimeSlotDataImpl.fromJson;

  /// 시간대 키 (morning, afternoon, evening)
  @override
  String get key;

  /// 시간대 이름 (오전, 오후, 저녁)
  @override
  String get name;

  /// 시간 범위 (예: "06:00-12:00")
  @override
  String get timeRange;

  /// 점수 (0-100)
  @override
  int get score;

  /// 한줄 메시지
  @override
  String get message;

  /// 아이콘 이모지
  @override
  String get icon;

  /// Create a copy of WidgetTimeSlotData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WidgetTimeSlotDataImplCopyWith<_$WidgetTimeSlotDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
