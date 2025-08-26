// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'talisman_wish.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TalismanWish _$TalismanWishFromJson(Map<String, dynamic> json) {
  return _TalismanWish.fromJson(json);
}

/// @nodoc
mixin _$TalismanWish {
  String get id => throw _privateConstructorUsedError;
  TalismanCategory get category => throw _privateConstructorUsedError;
  String get specificWish => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;

  /// Serializes this TalismanWish to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TalismanWish
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TalismanWishCopyWith<TalismanWish> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TalismanWishCopyWith<$Res> {
  factory $TalismanWishCopyWith(
          TalismanWish value, $Res Function(TalismanWish) then) =
      _$TalismanWishCopyWithImpl<$Res, TalismanWish>;
  @useResult
  $Res call(
      {String id,
      TalismanCategory category,
      String specificWish,
      DateTime createdAt,
      String? userId});
}

/// @nodoc
class _$TalismanWishCopyWithImpl<$Res, $Val extends TalismanWish>
    implements $TalismanWishCopyWith<$Res> {
  _$TalismanWishCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TalismanWish
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? specificWish = null,
    Object? createdAt = null,
    Object? userId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as TalismanCategory,
      specificWish: null == specificWish
          ? _value.specificWish
          : specificWish // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TalismanWishImplCopyWith<$Res>
    implements $TalismanWishCopyWith<$Res> {
  factory _$$TalismanWishImplCopyWith(
          _$TalismanWishImpl value, $Res Function(_$TalismanWishImpl) then) =
      __$$TalismanWishImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      TalismanCategory category,
      String specificWish,
      DateTime createdAt,
      String? userId});
}

/// @nodoc
class __$$TalismanWishImplCopyWithImpl<$Res>
    extends _$TalismanWishCopyWithImpl<$Res, _$TalismanWishImpl>
    implements _$$TalismanWishImplCopyWith<$Res> {
  __$$TalismanWishImplCopyWithImpl(
      _$TalismanWishImpl _value, $Res Function(_$TalismanWishImpl) _then)
      : super(_value, _then);

  /// Create a copy of TalismanWish
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? specificWish = null,
    Object? createdAt = null,
    Object? userId = freezed,
  }) {
    return _then(_$TalismanWishImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as TalismanCategory,
      specificWish: null == specificWish
          ? _value.specificWish
          : specificWish // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TalismanWishImpl implements _TalismanWish {
  const _$TalismanWishImpl(
      {required this.id,
      required this.category,
      required this.specificWish,
      required this.createdAt,
      this.userId});

  factory _$TalismanWishImpl.fromJson(Map<String, dynamic> json) =>
      _$$TalismanWishImplFromJson(json);

  @override
  final String id;
  @override
  final TalismanCategory category;
  @override
  final String specificWish;
  @override
  final DateTime createdAt;
  @override
  final String? userId;

  @override
  String toString() {
    return 'TalismanWish(id: $id, category: $category, specificWish: $specificWish, createdAt: $createdAt, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TalismanWishImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.specificWish, specificWish) ||
                other.specificWish == specificWish) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, category, specificWish, createdAt, userId);

  /// Create a copy of TalismanWish
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TalismanWishImplCopyWith<_$TalismanWishImpl> get copyWith =>
      __$$TalismanWishImplCopyWithImpl<_$TalismanWishImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TalismanWishImplToJson(
      this,
    );
  }
}

abstract class _TalismanWish implements TalismanWish {
  const factory _TalismanWish(
      {required final String id,
      required final TalismanCategory category,
      required final String specificWish,
      required final DateTime createdAt,
      final String? userId}) = _$TalismanWishImpl;

  factory _TalismanWish.fromJson(Map<String, dynamic> json) =
      _$TalismanWishImpl.fromJson;

  @override
  String get id;
  @override
  TalismanCategory get category;
  @override
  String get specificWish;
  @override
  DateTime get createdAt;
  @override
  String? get userId;

  /// Create a copy of TalismanWish
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TalismanWishImplCopyWith<_$TalismanWishImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
