// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'holiday_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HolidayInfo _$HolidayInfoFromJson(Map<String, dynamic> json) {
  return _HolidayInfo.fromJson(json);
}

/// @nodoc
mixin _$HolidayInfo {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // 'holiday', 'special', 'memorial'
  bool get isLunar => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this HolidayInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HolidayInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HolidayInfoCopyWith<HolidayInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HolidayInfoCopyWith<$Res> {
  factory $HolidayInfoCopyWith(
          HolidayInfo value, $Res Function(HolidayInfo) then) =
      _$HolidayInfoCopyWithImpl<$Res, HolidayInfo>;
  @useResult
  $Res call(
      {String id,
      DateTime date,
      String name,
      String type,
      bool isLunar,
      String? description,
      DateTime? createdAt});
}

/// @nodoc
class _$HolidayInfoCopyWithImpl<$Res, $Val extends HolidayInfo>
    implements $HolidayInfoCopyWith<$Res> {
  _$HolidayInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HolidayInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? name = null,
    Object? type = null,
    Object? isLunar = null,
    Object? description = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      isLunar: null == isLunar
          ? _value.isLunar
          : isLunar // ignore: cast_nullable_to_non_nullable
              as bool,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HolidayInfoImplCopyWith<$Res>
    implements $HolidayInfoCopyWith<$Res> {
  factory _$$HolidayInfoImplCopyWith(
          _$HolidayInfoImpl value, $Res Function(_$HolidayInfoImpl) then) =
      __$$HolidayInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime date,
      String name,
      String type,
      bool isLunar,
      String? description,
      DateTime? createdAt});
}

/// @nodoc
class __$$HolidayInfoImplCopyWithImpl<$Res>
    extends _$HolidayInfoCopyWithImpl<$Res, _$HolidayInfoImpl>
    implements _$$HolidayInfoImplCopyWith<$Res> {
  __$$HolidayInfoImplCopyWithImpl(
      _$HolidayInfoImpl _value, $Res Function(_$HolidayInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of HolidayInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? name = null,
    Object? type = null,
    Object? isLunar = null,
    Object? description = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$HolidayInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      isLunar: null == isLunar
          ? _value.isLunar
          : isLunar // ignore: cast_nullable_to_non_nullable
              as bool,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HolidayInfoImpl implements _HolidayInfo {
  const _$HolidayInfoImpl(
      {required this.id,
      required this.date,
      required this.name,
      required this.type,
      this.isLunar = false,
      this.description,
      this.createdAt});

  factory _$HolidayInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$HolidayInfoImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime date;
  @override
  final String name;
  @override
  final String type;
// 'holiday', 'special', 'memorial'
  @override
  @JsonKey()
  final bool isLunar;
  @override
  final String? description;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'HolidayInfo(id: $id, date: $date, name: $name, type: $type, isLunar: $isLunar, description: $description, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HolidayInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isLunar, isLunar) || other.isLunar == isLunar) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, date, name, type, isLunar, description, createdAt);

  /// Create a copy of HolidayInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HolidayInfoImplCopyWith<_$HolidayInfoImpl> get copyWith =>
      __$$HolidayInfoImplCopyWithImpl<_$HolidayInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HolidayInfoImplToJson(
      this,
    );
  }
}

abstract class _HolidayInfo implements HolidayInfo {
  const factory _HolidayInfo(
      {required final String id,
      required final DateTime date,
      required final String name,
      required final String type,
      final bool isLunar,
      final String? description,
      final DateTime? createdAt}) = _$HolidayInfoImpl;

  factory _HolidayInfo.fromJson(Map<String, dynamic> json) =
      _$HolidayInfoImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  String get name;
  @override
  String get type; // 'holiday', 'special', 'memorial'
  @override
  bool get isLunar;
  @override
  String? get description;
  @override
  DateTime? get createdAt;

  /// Create a copy of HolidayInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HolidayInfoImplCopyWith<_$HolidayInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuspiciousDayInfo _$AuspiciousDayInfoFromJson(Map<String, dynamic> json) {
  return _AuspiciousDayInfo.fromJson(json);
}

/// @nodoc
mixin _$AuspiciousDayInfo {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // 'moving', 'wedding', 'opening', 'travel'
  int get score => throw _privateConstructorUsedError; // 0-100
  String? get description => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AuspiciousDayInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuspiciousDayInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuspiciousDayInfoCopyWith<AuspiciousDayInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuspiciousDayInfoCopyWith<$Res> {
  factory $AuspiciousDayInfoCopyWith(
          AuspiciousDayInfo value, $Res Function(AuspiciousDayInfo) then) =
      _$AuspiciousDayInfoCopyWithImpl<$Res, AuspiciousDayInfo>;
  @useResult
  $Res call(
      {String id,
      DateTime date,
      String type,
      int score,
      String? description,
      DateTime? createdAt});
}

/// @nodoc
class _$AuspiciousDayInfoCopyWithImpl<$Res, $Val extends AuspiciousDayInfo>
    implements $AuspiciousDayInfoCopyWith<$Res> {
  _$AuspiciousDayInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuspiciousDayInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? type = null,
    Object? score = null,
    Object? description = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuspiciousDayInfoImplCopyWith<$Res>
    implements $AuspiciousDayInfoCopyWith<$Res> {
  factory _$$AuspiciousDayInfoImplCopyWith(_$AuspiciousDayInfoImpl value,
          $Res Function(_$AuspiciousDayInfoImpl) then) =
      __$$AuspiciousDayInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime date,
      String type,
      int score,
      String? description,
      DateTime? createdAt});
}

/// @nodoc
class __$$AuspiciousDayInfoImplCopyWithImpl<$Res>
    extends _$AuspiciousDayInfoCopyWithImpl<$Res, _$AuspiciousDayInfoImpl>
    implements _$$AuspiciousDayInfoImplCopyWith<$Res> {
  __$$AuspiciousDayInfoImplCopyWithImpl(_$AuspiciousDayInfoImpl _value,
      $Res Function(_$AuspiciousDayInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuspiciousDayInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? type = null,
    Object? score = null,
    Object? description = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$AuspiciousDayInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuspiciousDayInfoImpl implements _AuspiciousDayInfo {
  const _$AuspiciousDayInfoImpl(
      {required this.id,
      required this.date,
      required this.type,
      required this.score,
      this.description,
      this.createdAt});

  factory _$AuspiciousDayInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuspiciousDayInfoImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime date;
  @override
  final String type;
// 'moving', 'wedding', 'opening', 'travel'
  @override
  final int score;
// 0-100
  @override
  final String? description;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'AuspiciousDayInfo(id: $id, date: $date, type: $type, score: $score, description: $description, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuspiciousDayInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, date, type, score, description, createdAt);

  /// Create a copy of AuspiciousDayInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuspiciousDayInfoImplCopyWith<_$AuspiciousDayInfoImpl> get copyWith =>
      __$$AuspiciousDayInfoImplCopyWithImpl<_$AuspiciousDayInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuspiciousDayInfoImplToJson(
      this,
    );
  }
}

abstract class _AuspiciousDayInfo implements AuspiciousDayInfo {
  const factory _AuspiciousDayInfo(
      {required final String id,
      required final DateTime date,
      required final String type,
      required final int score,
      final String? description,
      final DateTime? createdAt}) = _$AuspiciousDayInfoImpl;

  factory _AuspiciousDayInfo.fromJson(Map<String, dynamic> json) =
      _$AuspiciousDayInfoImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  String get type; // 'moving', 'wedding', 'opening', 'travel'
  @override
  int get score; // 0-100
  @override
  String? get description;
  @override
  DateTime? get createdAt;

  /// Create a copy of AuspiciousDayInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuspiciousDayInfoImplCopyWith<_$AuspiciousDayInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CalendarEventInfo _$CalendarEventInfoFromJson(Map<String, dynamic> json) {
  return _CalendarEventInfo.fromJson(json);
}

/// @nodoc
mixin _$CalendarEventInfo {
  DateTime get date => throw _privateConstructorUsedError;
  String? get holidayName => throw _privateConstructorUsedError;
  String? get specialName => throw _privateConstructorUsedError;
  String? get auspiciousName => throw _privateConstructorUsedError;
  bool get isHoliday => throw _privateConstructorUsedError;
  bool get isSpecial => throw _privateConstructorUsedError;
  bool get isAuspicious => throw _privateConstructorUsedError;
  int? get auspiciousScore => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this CalendarEventInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CalendarEventInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalendarEventInfoCopyWith<CalendarEventInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarEventInfoCopyWith<$Res> {
  factory $CalendarEventInfoCopyWith(
          CalendarEventInfo value, $Res Function(CalendarEventInfo) then) =
      _$CalendarEventInfoCopyWithImpl<$Res, CalendarEventInfo>;
  @useResult
  $Res call(
      {DateTime date,
      String? holidayName,
      String? specialName,
      String? auspiciousName,
      bool isHoliday,
      bool isSpecial,
      bool isAuspicious,
      int? auspiciousScore,
      String? description});
}

/// @nodoc
class _$CalendarEventInfoCopyWithImpl<$Res, $Val extends CalendarEventInfo>
    implements $CalendarEventInfoCopyWith<$Res> {
  _$CalendarEventInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalendarEventInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? holidayName = freezed,
    Object? specialName = freezed,
    Object? auspiciousName = freezed,
    Object? isHoliday = null,
    Object? isSpecial = null,
    Object? isAuspicious = null,
    Object? auspiciousScore = freezed,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      holidayName: freezed == holidayName
          ? _value.holidayName
          : holidayName // ignore: cast_nullable_to_non_nullable
              as String?,
      specialName: freezed == specialName
          ? _value.specialName
          : specialName // ignore: cast_nullable_to_non_nullable
              as String?,
      auspiciousName: freezed == auspiciousName
          ? _value.auspiciousName
          : auspiciousName // ignore: cast_nullable_to_non_nullable
              as String?,
      isHoliday: null == isHoliday
          ? _value.isHoliday
          : isHoliday // ignore: cast_nullable_to_non_nullable
              as bool,
      isSpecial: null == isSpecial
          ? _value.isSpecial
          : isSpecial // ignore: cast_nullable_to_non_nullable
              as bool,
      isAuspicious: null == isAuspicious
          ? _value.isAuspicious
          : isAuspicious // ignore: cast_nullable_to_non_nullable
              as bool,
      auspiciousScore: freezed == auspiciousScore
          ? _value.auspiciousScore
          : auspiciousScore // ignore: cast_nullable_to_non_nullable
              as int?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalendarEventInfoImplCopyWith<$Res>
    implements $CalendarEventInfoCopyWith<$Res> {
  factory _$$CalendarEventInfoImplCopyWith(_$CalendarEventInfoImpl value,
          $Res Function(_$CalendarEventInfoImpl) then) =
      __$$CalendarEventInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      String? holidayName,
      String? specialName,
      String? auspiciousName,
      bool isHoliday,
      bool isSpecial,
      bool isAuspicious,
      int? auspiciousScore,
      String? description});
}

/// @nodoc
class __$$CalendarEventInfoImplCopyWithImpl<$Res>
    extends _$CalendarEventInfoCopyWithImpl<$Res, _$CalendarEventInfoImpl>
    implements _$$CalendarEventInfoImplCopyWith<$Res> {
  __$$CalendarEventInfoImplCopyWithImpl(_$CalendarEventInfoImpl _value,
      $Res Function(_$CalendarEventInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of CalendarEventInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? holidayName = freezed,
    Object? specialName = freezed,
    Object? auspiciousName = freezed,
    Object? isHoliday = null,
    Object? isSpecial = null,
    Object? isAuspicious = null,
    Object? auspiciousScore = freezed,
    Object? description = freezed,
  }) {
    return _then(_$CalendarEventInfoImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      holidayName: freezed == holidayName
          ? _value.holidayName
          : holidayName // ignore: cast_nullable_to_non_nullable
              as String?,
      specialName: freezed == specialName
          ? _value.specialName
          : specialName // ignore: cast_nullable_to_non_nullable
              as String?,
      auspiciousName: freezed == auspiciousName
          ? _value.auspiciousName
          : auspiciousName // ignore: cast_nullable_to_non_nullable
              as String?,
      isHoliday: null == isHoliday
          ? _value.isHoliday
          : isHoliday // ignore: cast_nullable_to_non_nullable
              as bool,
      isSpecial: null == isSpecial
          ? _value.isSpecial
          : isSpecial // ignore: cast_nullable_to_non_nullable
              as bool,
      isAuspicious: null == isAuspicious
          ? _value.isAuspicious
          : isAuspicious // ignore: cast_nullable_to_non_nullable
              as bool,
      auspiciousScore: freezed == auspiciousScore
          ? _value.auspiciousScore
          : auspiciousScore // ignore: cast_nullable_to_non_nullable
              as int?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalendarEventInfoImpl implements _CalendarEventInfo {
  const _$CalendarEventInfoImpl(
      {required this.date,
      this.holidayName,
      this.specialName,
      this.auspiciousName,
      this.isHoliday = false,
      this.isSpecial = false,
      this.isAuspicious = false,
      this.auspiciousScore,
      this.description});

  factory _$CalendarEventInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarEventInfoImplFromJson(json);

  @override
  final DateTime date;
  @override
  final String? holidayName;
  @override
  final String? specialName;
  @override
  final String? auspiciousName;
  @override
  @JsonKey()
  final bool isHoliday;
  @override
  @JsonKey()
  final bool isSpecial;
  @override
  @JsonKey()
  final bool isAuspicious;
  @override
  final int? auspiciousScore;
  @override
  final String? description;

  @override
  String toString() {
    return 'CalendarEventInfo(date: $date, holidayName: $holidayName, specialName: $specialName, auspiciousName: $auspiciousName, isHoliday: $isHoliday, isSpecial: $isSpecial, isAuspicious: $isAuspicious, auspiciousScore: $auspiciousScore, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarEventInfoImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.holidayName, holidayName) ||
                other.holidayName == holidayName) &&
            (identical(other.specialName, specialName) ||
                other.specialName == specialName) &&
            (identical(other.auspiciousName, auspiciousName) ||
                other.auspiciousName == auspiciousName) &&
            (identical(other.isHoliday, isHoliday) ||
                other.isHoliday == isHoliday) &&
            (identical(other.isSpecial, isSpecial) ||
                other.isSpecial == isSpecial) &&
            (identical(other.isAuspicious, isAuspicious) ||
                other.isAuspicious == isAuspicious) &&
            (identical(other.auspiciousScore, auspiciousScore) ||
                other.auspiciousScore == auspiciousScore) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      holidayName,
      specialName,
      auspiciousName,
      isHoliday,
      isSpecial,
      isAuspicious,
      auspiciousScore,
      description);

  /// Create a copy of CalendarEventInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarEventInfoImplCopyWith<_$CalendarEventInfoImpl> get copyWith =>
      __$$CalendarEventInfoImplCopyWithImpl<_$CalendarEventInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarEventInfoImplToJson(
      this,
    );
  }
}

abstract class _CalendarEventInfo implements CalendarEventInfo {
  const factory _CalendarEventInfo(
      {required final DateTime date,
      final String? holidayName,
      final String? specialName,
      final String? auspiciousName,
      final bool isHoliday,
      final bool isSpecial,
      final bool isAuspicious,
      final int? auspiciousScore,
      final String? description}) = _$CalendarEventInfoImpl;

  factory _CalendarEventInfo.fromJson(Map<String, dynamic> json) =
      _$CalendarEventInfoImpl.fromJson;

  @override
  DateTime get date;
  @override
  String? get holidayName;
  @override
  String? get specialName;
  @override
  String? get auspiciousName;
  @override
  bool get isHoliday;
  @override
  bool get isSpecial;
  @override
  bool get isAuspicious;
  @override
  int? get auspiciousScore;
  @override
  String? get description;

  /// Create a copy of CalendarEventInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalendarEventInfoImplCopyWith<_$CalendarEventInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
