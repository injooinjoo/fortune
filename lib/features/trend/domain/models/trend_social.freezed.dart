// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trend_social.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrendLike _$TrendLikeFromJson(Map<String, dynamic> json) {
  return _TrendLike.fromJson(json);
}

/// @nodoc
mixin _$TrendLike {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get contentId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TrendLike to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrendLike
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrendLikeCopyWith<TrendLike> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrendLikeCopyWith<$Res> {
  factory $TrendLikeCopyWith(TrendLike value, $Res Function(TrendLike) then) =
      _$TrendLikeCopyWithImpl<$Res, TrendLike>;
  @useResult
  $Res call({String id, String userId, String contentId, DateTime? createdAt});
}

/// @nodoc
class _$TrendLikeCopyWithImpl<$Res, $Val extends TrendLike>
    implements $TrendLikeCopyWith<$Res> {
  _$TrendLikeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrendLike
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? contentId = null,
    Object? createdAt = freezed,
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
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrendLikeImplCopyWith<$Res>
    implements $TrendLikeCopyWith<$Res> {
  factory _$$TrendLikeImplCopyWith(
          _$TrendLikeImpl value, $Res Function(_$TrendLikeImpl) then) =
      __$$TrendLikeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String userId, String contentId, DateTime? createdAt});
}

/// @nodoc
class __$$TrendLikeImplCopyWithImpl<$Res>
    extends _$TrendLikeCopyWithImpl<$Res, _$TrendLikeImpl>
    implements _$$TrendLikeImplCopyWith<$Res> {
  __$$TrendLikeImplCopyWithImpl(
      _$TrendLikeImpl _value, $Res Function(_$TrendLikeImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrendLike
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? contentId = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$TrendLikeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrendLikeImpl implements _TrendLike {
  const _$TrendLikeImpl(
      {required this.id,
      required this.userId,
      required this.contentId,
      this.createdAt});

  factory _$TrendLikeImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrendLikeImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String contentId;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'TrendLike(id: $id, userId: $userId, contentId: $contentId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrendLikeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.contentId, contentId) ||
                other.contentId == contentId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, contentId, createdAt);

  /// Create a copy of TrendLike
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrendLikeImplCopyWith<_$TrendLikeImpl> get copyWith =>
      __$$TrendLikeImplCopyWithImpl<_$TrendLikeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrendLikeImplToJson(
      this,
    );
  }
}

abstract class _TrendLike implements TrendLike {
  const factory _TrendLike(
      {required final String id,
      required final String userId,
      required final String contentId,
      final DateTime? createdAt}) = _$TrendLikeImpl;

  factory _TrendLike.fromJson(Map<String, dynamic> json) =
      _$TrendLikeImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get contentId;
  @override
  DateTime? get createdAt;

  /// Create a copy of TrendLike
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrendLikeImplCopyWith<_$TrendLikeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrendComment _$TrendCommentFromJson(Map<String, dynamic> json) {
  return _TrendComment.fromJson(json);
}

/// @nodoc
mixin _$TrendComment {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get contentId => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError; // 조인된 데이터
  String? get userName => throw _privateConstructorUsedError;
  String? get userProfileImage => throw _privateConstructorUsedError;
  List<TrendComment> get replies => throw _privateConstructorUsedError;
  bool get isLikedByMe => throw _privateConstructorUsedError;

  /// Serializes this TrendComment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrendComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrendCommentCopyWith<TrendComment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrendCommentCopyWith<$Res> {
  factory $TrendCommentCopyWith(
          TrendComment value, $Res Function(TrendComment) then) =
      _$TrendCommentCopyWithImpl<$Res, TrendComment>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String contentId,
      String? parentId,
      String text,
      int likeCount,
      bool isDeleted,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? userName,
      String? userProfileImage,
      List<TrendComment> replies,
      bool isLikedByMe});
}

/// @nodoc
class _$TrendCommentCopyWithImpl<$Res, $Val extends TrendComment>
    implements $TrendCommentCopyWith<$Res> {
  _$TrendCommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrendComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? contentId = null,
    Object? parentId = freezed,
    Object? text = null,
    Object? likeCount = null,
    Object? isDeleted = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? userName = freezed,
    Object? userProfileImage = freezed,
    Object? replies = null,
    Object? isLikedByMe = null,
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
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      userProfileImage: freezed == userProfileImage
          ? _value.userProfileImage
          : userProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      replies: null == replies
          ? _value.replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<TrendComment>,
      isLikedByMe: null == isLikedByMe
          ? _value.isLikedByMe
          : isLikedByMe // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrendCommentImplCopyWith<$Res>
    implements $TrendCommentCopyWith<$Res> {
  factory _$$TrendCommentImplCopyWith(
          _$TrendCommentImpl value, $Res Function(_$TrendCommentImpl) then) =
      __$$TrendCommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String contentId,
      String? parentId,
      String text,
      int likeCount,
      bool isDeleted,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? userName,
      String? userProfileImage,
      List<TrendComment> replies,
      bool isLikedByMe});
}

/// @nodoc
class __$$TrendCommentImplCopyWithImpl<$Res>
    extends _$TrendCommentCopyWithImpl<$Res, _$TrendCommentImpl>
    implements _$$TrendCommentImplCopyWith<$Res> {
  __$$TrendCommentImplCopyWithImpl(
      _$TrendCommentImpl _value, $Res Function(_$TrendCommentImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrendComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? contentId = null,
    Object? parentId = freezed,
    Object? text = null,
    Object? likeCount = null,
    Object? isDeleted = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? userName = freezed,
    Object? userProfileImage = freezed,
    Object? replies = null,
    Object? isLikedByMe = null,
  }) {
    return _then(_$TrendCommentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      userProfileImage: freezed == userProfileImage
          ? _value.userProfileImage
          : userProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      replies: null == replies
          ? _value._replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<TrendComment>,
      isLikedByMe: null == isLikedByMe
          ? _value.isLikedByMe
          : isLikedByMe // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrendCommentImpl implements _TrendComment {
  const _$TrendCommentImpl(
      {required this.id,
      required this.userId,
      required this.contentId,
      this.parentId,
      required this.text,
      this.likeCount = 0,
      this.isDeleted = false,
      this.createdAt,
      this.updatedAt,
      this.userName,
      this.userProfileImage,
      final List<TrendComment> replies = const [],
      this.isLikedByMe = false})
      : _replies = replies;

  factory _$TrendCommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrendCommentImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String contentId;
  @override
  final String? parentId;
  @override
  final String text;
  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final bool isDeleted;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
// 조인된 데이터
  @override
  final String? userName;
  @override
  final String? userProfileImage;
  final List<TrendComment> _replies;
  @override
  @JsonKey()
  List<TrendComment> get replies {
    if (_replies is EqualUnmodifiableListView) return _replies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_replies);
  }

  @override
  @JsonKey()
  final bool isLikedByMe;

  @override
  String toString() {
    return 'TrendComment(id: $id, userId: $userId, contentId: $contentId, parentId: $parentId, text: $text, likeCount: $likeCount, isDeleted: $isDeleted, createdAt: $createdAt, updatedAt: $updatedAt, userName: $userName, userProfileImage: $userProfileImage, replies: $replies, isLikedByMe: $isLikedByMe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrendCommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.contentId, contentId) ||
                other.contentId == contentId) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userProfileImage, userProfileImage) ||
                other.userProfileImage == userProfileImage) &&
            const DeepCollectionEquality().equals(other._replies, _replies) &&
            (identical(other.isLikedByMe, isLikedByMe) ||
                other.isLikedByMe == isLikedByMe));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      contentId,
      parentId,
      text,
      likeCount,
      isDeleted,
      createdAt,
      updatedAt,
      userName,
      userProfileImage,
      const DeepCollectionEquality().hash(_replies),
      isLikedByMe);

  /// Create a copy of TrendComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrendCommentImplCopyWith<_$TrendCommentImpl> get copyWith =>
      __$$TrendCommentImplCopyWithImpl<_$TrendCommentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrendCommentImplToJson(
      this,
    );
  }
}

abstract class _TrendComment implements TrendComment {
  const factory _TrendComment(
      {required final String id,
      required final String userId,
      required final String contentId,
      final String? parentId,
      required final String text,
      final int likeCount,
      final bool isDeleted,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final String? userName,
      final String? userProfileImage,
      final List<TrendComment> replies,
      final bool isLikedByMe}) = _$TrendCommentImpl;

  factory _TrendComment.fromJson(Map<String, dynamic> json) =
      _$TrendCommentImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get contentId;
  @override
  String? get parentId;
  @override
  String get text;
  @override
  int get likeCount;
  @override
  bool get isDeleted;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt; // 조인된 데이터
  @override
  String? get userName;
  @override
  String? get userProfileImage;
  @override
  List<TrendComment> get replies;
  @override
  bool get isLikedByMe;

  /// Create a copy of TrendComment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrendCommentImplCopyWith<_$TrendCommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrendCommentLike _$TrendCommentLikeFromJson(Map<String, dynamic> json) {
  return _TrendCommentLike.fromJson(json);
}

/// @nodoc
mixin _$TrendCommentLike {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get commentId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TrendCommentLike to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrendCommentLike
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrendCommentLikeCopyWith<TrendCommentLike> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrendCommentLikeCopyWith<$Res> {
  factory $TrendCommentLikeCopyWith(
          TrendCommentLike value, $Res Function(TrendCommentLike) then) =
      _$TrendCommentLikeCopyWithImpl<$Res, TrendCommentLike>;
  @useResult
  $Res call({String id, String userId, String commentId, DateTime? createdAt});
}

/// @nodoc
class _$TrendCommentLikeCopyWithImpl<$Res, $Val extends TrendCommentLike>
    implements $TrendCommentLikeCopyWith<$Res> {
  _$TrendCommentLikeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrendCommentLike
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? commentId = null,
    Object? createdAt = freezed,
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
      commentId: null == commentId
          ? _value.commentId
          : commentId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrendCommentLikeImplCopyWith<$Res>
    implements $TrendCommentLikeCopyWith<$Res> {
  factory _$$TrendCommentLikeImplCopyWith(_$TrendCommentLikeImpl value,
          $Res Function(_$TrendCommentLikeImpl) then) =
      __$$TrendCommentLikeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String userId, String commentId, DateTime? createdAt});
}

/// @nodoc
class __$$TrendCommentLikeImplCopyWithImpl<$Res>
    extends _$TrendCommentLikeCopyWithImpl<$Res, _$TrendCommentLikeImpl>
    implements _$$TrendCommentLikeImplCopyWith<$Res> {
  __$$TrendCommentLikeImplCopyWithImpl(_$TrendCommentLikeImpl _value,
      $Res Function(_$TrendCommentLikeImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrendCommentLike
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? commentId = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$TrendCommentLikeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      commentId: null == commentId
          ? _value.commentId
          : commentId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrendCommentLikeImpl implements _TrendCommentLike {
  const _$TrendCommentLikeImpl(
      {required this.id,
      required this.userId,
      required this.commentId,
      this.createdAt});

  factory _$TrendCommentLikeImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrendCommentLikeImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String commentId;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'TrendCommentLike(id: $id, userId: $userId, commentId: $commentId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrendCommentLikeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.commentId, commentId) ||
                other.commentId == commentId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, commentId, createdAt);

  /// Create a copy of TrendCommentLike
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrendCommentLikeImplCopyWith<_$TrendCommentLikeImpl> get copyWith =>
      __$$TrendCommentLikeImplCopyWithImpl<_$TrendCommentLikeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrendCommentLikeImplToJson(
      this,
    );
  }
}

abstract class _TrendCommentLike implements TrendCommentLike {
  const factory _TrendCommentLike(
      {required final String id,
      required final String userId,
      required final String commentId,
      final DateTime? createdAt}) = _$TrendCommentLikeImpl;

  factory _TrendCommentLike.fromJson(Map<String, dynamic> json) =
      _$TrendCommentLikeImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get commentId;
  @override
  DateTime? get createdAt;

  /// Create a copy of TrendCommentLike
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrendCommentLikeImplCopyWith<_$TrendCommentLikeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommentInput _$CommentInputFromJson(Map<String, dynamic> json) {
  return _CommentInput.fromJson(json);
}

/// @nodoc
mixin _$CommentInput {
  String get contentId => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;

  /// Serializes this CommentInput to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommentInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentInputCopyWith<CommentInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentInputCopyWith<$Res> {
  factory $CommentInputCopyWith(
          CommentInput value, $Res Function(CommentInput) then) =
      _$CommentInputCopyWithImpl<$Res, CommentInput>;
  @useResult
  $Res call({String contentId, String text, String? parentId});
}

/// @nodoc
class _$CommentInputCopyWithImpl<$Res, $Val extends CommentInput>
    implements $CommentInputCopyWith<$Res> {
  _$CommentInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommentInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contentId = null,
    Object? text = null,
    Object? parentId = freezed,
  }) {
    return _then(_value.copyWith(
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentInputImplCopyWith<$Res>
    implements $CommentInputCopyWith<$Res> {
  factory _$$CommentInputImplCopyWith(
          _$CommentInputImpl value, $Res Function(_$CommentInputImpl) then) =
      __$$CommentInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String contentId, String text, String? parentId});
}

/// @nodoc
class __$$CommentInputImplCopyWithImpl<$Res>
    extends _$CommentInputCopyWithImpl<$Res, _$CommentInputImpl>
    implements _$$CommentInputImplCopyWith<$Res> {
  __$$CommentInputImplCopyWithImpl(
      _$CommentInputImpl _value, $Res Function(_$CommentInputImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommentInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contentId = null,
    Object? text = null,
    Object? parentId = freezed,
  }) {
    return _then(_$CommentInputImpl(
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentInputImpl implements _CommentInput {
  const _$CommentInputImpl(
      {required this.contentId, required this.text, this.parentId});

  factory _$CommentInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentInputImplFromJson(json);

  @override
  final String contentId;
  @override
  final String text;
  @override
  final String? parentId;

  @override
  String toString() {
    return 'CommentInput(contentId: $contentId, text: $text, parentId: $parentId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentInputImpl &&
            (identical(other.contentId, contentId) ||
                other.contentId == contentId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, contentId, text, parentId);

  /// Create a copy of CommentInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentInputImplCopyWith<_$CommentInputImpl> get copyWith =>
      __$$CommentInputImplCopyWithImpl<_$CommentInputImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentInputImplToJson(
      this,
    );
  }
}

abstract class _CommentInput implements CommentInput {
  const factory _CommentInput(
      {required final String contentId,
      required final String text,
      final String? parentId}) = _$CommentInputImpl;

  factory _CommentInput.fromJson(Map<String, dynamic> json) =
      _$CommentInputImpl.fromJson;

  @override
  String get contentId;
  @override
  String get text;
  @override
  String? get parentId;

  /// Create a copy of CommentInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentInputImplCopyWith<_$CommentInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommentListResponse _$CommentListResponseFromJson(Map<String, dynamic> json) {
  return _CommentListResponse.fromJson(json);
}

/// @nodoc
mixin _$CommentListResponse {
  List<TrendComment> get comments => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;

  /// Serializes this CommentListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommentListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentListResponseCopyWith<CommentListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentListResponseCopyWith<$Res> {
  factory $CommentListResponseCopyWith(
          CommentListResponse value, $Res Function(CommentListResponse) then) =
      _$CommentListResponseCopyWithImpl<$Res, CommentListResponse>;
  @useResult
  $Res call({List<TrendComment> comments, int totalCount, bool hasMore});
}

/// @nodoc
class _$CommentListResponseCopyWithImpl<$Res, $Val extends CommentListResponse>
    implements $CommentListResponseCopyWith<$Res> {
  _$CommentListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommentListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? comments = null,
    Object? totalCount = null,
    Object? hasMore = null,
  }) {
    return _then(_value.copyWith(
      comments: null == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<TrendComment>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentListResponseImplCopyWith<$Res>
    implements $CommentListResponseCopyWith<$Res> {
  factory _$$CommentListResponseImplCopyWith(_$CommentListResponseImpl value,
          $Res Function(_$CommentListResponseImpl) then) =
      __$$CommentListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<TrendComment> comments, int totalCount, bool hasMore});
}

/// @nodoc
class __$$CommentListResponseImplCopyWithImpl<$Res>
    extends _$CommentListResponseCopyWithImpl<$Res, _$CommentListResponseImpl>
    implements _$$CommentListResponseImplCopyWith<$Res> {
  __$$CommentListResponseImplCopyWithImpl(_$CommentListResponseImpl _value,
      $Res Function(_$CommentListResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommentListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? comments = null,
    Object? totalCount = null,
    Object? hasMore = null,
  }) {
    return _then(_$CommentListResponseImpl(
      comments: null == comments
          ? _value._comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<TrendComment>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentListResponseImpl implements _CommentListResponse {
  const _$CommentListResponseImpl(
      {required final List<TrendComment> comments,
      this.totalCount = 0,
      this.hasMore = false})
      : _comments = comments;

  factory _$CommentListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentListResponseImplFromJson(json);

  final List<TrendComment> _comments;
  @override
  List<TrendComment> get comments {
    if (_comments is EqualUnmodifiableListView) return _comments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_comments);
  }

  @override
  @JsonKey()
  final int totalCount;
  @override
  @JsonKey()
  final bool hasMore;

  @override
  String toString() {
    return 'CommentListResponse(comments: $comments, totalCount: $totalCount, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentListResponseImpl &&
            const DeepCollectionEquality().equals(other._comments, _comments) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_comments), totalCount, hasMore);

  /// Create a copy of CommentListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentListResponseImplCopyWith<_$CommentListResponseImpl> get copyWith =>
      __$$CommentListResponseImplCopyWithImpl<_$CommentListResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentListResponseImplToJson(
      this,
    );
  }
}

abstract class _CommentListResponse implements CommentListResponse {
  const factory _CommentListResponse(
      {required final List<TrendComment> comments,
      final int totalCount,
      final bool hasMore}) = _$CommentListResponseImpl;

  factory _CommentListResponse.fromJson(Map<String, dynamic> json) =
      _$CommentListResponseImpl.fromJson;

  @override
  List<TrendComment> get comments;
  @override
  int get totalCount;
  @override
  bool get hasMore;

  /// Create a copy of CommentListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentListResponseImplCopyWith<_$CommentListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LikeState _$LikeStateFromJson(Map<String, dynamic> json) {
  return _LikeState.fromJson(json);
}

/// @nodoc
mixin _$LikeState {
  String get contentId => throw _privateConstructorUsedError;
  bool get isLiked => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;

  /// Serializes this LikeState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LikeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LikeStateCopyWith<LikeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LikeStateCopyWith<$Res> {
  factory $LikeStateCopyWith(LikeState value, $Res Function(LikeState) then) =
      _$LikeStateCopyWithImpl<$Res, LikeState>;
  @useResult
  $Res call({String contentId, bool isLiked, int likeCount});
}

/// @nodoc
class _$LikeStateCopyWithImpl<$Res, $Val extends LikeState>
    implements $LikeStateCopyWith<$Res> {
  _$LikeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LikeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contentId = null,
    Object? isLiked = null,
    Object? likeCount = null,
  }) {
    return _then(_value.copyWith(
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LikeStateImplCopyWith<$Res>
    implements $LikeStateCopyWith<$Res> {
  factory _$$LikeStateImplCopyWith(
          _$LikeStateImpl value, $Res Function(_$LikeStateImpl) then) =
      __$$LikeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String contentId, bool isLiked, int likeCount});
}

/// @nodoc
class __$$LikeStateImplCopyWithImpl<$Res>
    extends _$LikeStateCopyWithImpl<$Res, _$LikeStateImpl>
    implements _$$LikeStateImplCopyWith<$Res> {
  __$$LikeStateImplCopyWithImpl(
      _$LikeStateImpl _value, $Res Function(_$LikeStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of LikeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contentId = null,
    Object? isLiked = null,
    Object? likeCount = null,
  }) {
    return _then(_$LikeStateImpl(
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LikeStateImpl implements _LikeState {
  const _$LikeStateImpl(
      {required this.contentId,
      required this.isLiked,
      required this.likeCount});

  factory _$LikeStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$LikeStateImplFromJson(json);

  @override
  final String contentId;
  @override
  final bool isLiked;
  @override
  final int likeCount;

  @override
  String toString() {
    return 'LikeState(contentId: $contentId, isLiked: $isLiked, likeCount: $likeCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LikeStateImpl &&
            (identical(other.contentId, contentId) ||
                other.contentId == contentId) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, contentId, isLiked, likeCount);

  /// Create a copy of LikeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LikeStateImplCopyWith<_$LikeStateImpl> get copyWith =>
      __$$LikeStateImplCopyWithImpl<_$LikeStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LikeStateImplToJson(
      this,
    );
  }
}

abstract class _LikeState implements LikeState {
  const factory _LikeState(
      {required final String contentId,
      required final bool isLiked,
      required final int likeCount}) = _$LikeStateImpl;

  factory _LikeState.fromJson(Map<String, dynamic> json) =
      _$LikeStateImpl.fromJson;

  @override
  String get contentId;
  @override
  bool get isLiked;
  @override
  int get likeCount;

  /// Create a copy of LikeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LikeStateImplCopyWith<_$LikeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShareData _$ShareDataFromJson(Map<String, dynamic> json) {
  return _ShareData.fromJson(json);
}

/// @nodoc
mixin _$ShareData {
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this ShareData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShareData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShareDataCopyWith<ShareData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShareDataCopyWith<$Res> {
  factory $ShareDataCopyWith(ShareData value, $Res Function(ShareData) then) =
      _$ShareDataCopyWithImpl<$Res, ShareData>;
  @useResult
  $Res call(
      {String title,
      String description,
      String? imageUrl,
      String? url,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$ShareDataCopyWithImpl<$Res, $Val extends ShareData>
    implements $ShareDataCopyWith<$Res> {
  _$ShareDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShareData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? imageUrl = freezed,
    Object? url = freezed,
    Object? metadata = null,
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
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShareDataImplCopyWith<$Res>
    implements $ShareDataCopyWith<$Res> {
  factory _$$ShareDataImplCopyWith(
          _$ShareDataImpl value, $Res Function(_$ShareDataImpl) then) =
      __$$ShareDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String description,
      String? imageUrl,
      String? url,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$ShareDataImplCopyWithImpl<$Res>
    extends _$ShareDataCopyWithImpl<$Res, _$ShareDataImpl>
    implements _$$ShareDataImplCopyWith<$Res> {
  __$$ShareDataImplCopyWithImpl(
      _$ShareDataImpl _value, $Res Function(_$ShareDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of ShareData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? imageUrl = freezed,
    Object? url = freezed,
    Object? metadata = null,
  }) {
    return _then(_$ShareDataImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShareDataImpl implements _ShareData {
  const _$ShareDataImpl(
      {required this.title,
      required this.description,
      this.imageUrl,
      this.url,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  factory _$ShareDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShareDataImplFromJson(json);

  @override
  final String title;
  @override
  final String description;
  @override
  final String? imageUrl;
  @override
  final String? url;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'ShareData(title: $title, description: $description, imageUrl: $imageUrl, url: $url, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShareDataImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.url, url) || other.url == url) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, description, imageUrl,
      url, const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of ShareData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShareDataImplCopyWith<_$ShareDataImpl> get copyWith =>
      __$$ShareDataImplCopyWithImpl<_$ShareDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShareDataImplToJson(
      this,
    );
  }
}

abstract class _ShareData implements ShareData {
  const factory _ShareData(
      {required final String title,
      required final String description,
      final String? imageUrl,
      final String? url,
      final Map<String, dynamic> metadata}) = _$ShareDataImpl;

  factory _ShareData.fromJson(Map<String, dynamic> json) =
      _$ShareDataImpl.fromJson;

  @override
  String get title;
  @override
  String get description;
  @override
  String? get imageUrl;
  @override
  String? get url;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of ShareData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShareDataImplCopyWith<_$ShareDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
