// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trend_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrendContent _$TrendContentFromJson(Map<String, dynamic> json) {
  return _TrendContent.fromJson(json);
}

/// @nodoc
mixin _$TrendContent {
  String get id => throw _privateConstructorUsedError;
  TrendContentType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get subtitle => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  TrendCategory get category => throw _privateConstructorUsedError;
  int get viewCount => throw _privateConstructorUsedError;
  int get participantCount => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  int get shareCount => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isPremium => throw _privateConstructorUsedError;
  int get tokenCost => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TrendContent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrendContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrendContentCopyWith<TrendContent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrendContentCopyWith<$Res> {
  factory $TrendContentCopyWith(
          TrendContent value, $Res Function(TrendContent) then) =
      _$TrendContentCopyWithImpl<$Res, TrendContent>;
  @useResult
  $Res call(
      {String id,
      TrendContentType type,
      String title,
      String? subtitle,
      String? thumbnailUrl,
      TrendCategory category,
      int viewCount,
      int participantCount,
      int likeCount,
      int shareCount,
      bool isActive,
      bool isPremium,
      int tokenCost,
      DateTime? startDate,
      DateTime? endDate,
      int sortOrder,
      Map<String, dynamic> metadata,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$TrendContentCopyWithImpl<$Res, $Val extends TrendContent>
    implements $TrendContentCopyWith<$Res> {
  _$TrendContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrendContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? subtitle = freezed,
    Object? thumbnailUrl = freezed,
    Object? category = null,
    Object? viewCount = null,
    Object? participantCount = null,
    Object? likeCount = null,
    Object? shareCount = null,
    Object? isActive = null,
    Object? isPremium = null,
    Object? tokenCost = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? sortOrder = null,
    Object? metadata = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TrendContentType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: freezed == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as TrendCategory,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      participantCount: null == participantCount
          ? _value.participantCount
          : participantCount // ignore: cast_nullable_to_non_nullable
              as int,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      shareCount: null == shareCount
          ? _value.shareCount
          : shareCount // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      tokenCost: null == tokenCost
          ? _value.tokenCost
          : tokenCost // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrendContentImplCopyWith<$Res>
    implements $TrendContentCopyWith<$Res> {
  factory _$$TrendContentImplCopyWith(
          _$TrendContentImpl value, $Res Function(_$TrendContentImpl) then) =
      __$$TrendContentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      TrendContentType type,
      String title,
      String? subtitle,
      String? thumbnailUrl,
      TrendCategory category,
      int viewCount,
      int participantCount,
      int likeCount,
      int shareCount,
      bool isActive,
      bool isPremium,
      int tokenCost,
      DateTime? startDate,
      DateTime? endDate,
      int sortOrder,
      Map<String, dynamic> metadata,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$TrendContentImplCopyWithImpl<$Res>
    extends _$TrendContentCopyWithImpl<$Res, _$TrendContentImpl>
    implements _$$TrendContentImplCopyWith<$Res> {
  __$$TrendContentImplCopyWithImpl(
      _$TrendContentImpl _value, $Res Function(_$TrendContentImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrendContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? subtitle = freezed,
    Object? thumbnailUrl = freezed,
    Object? category = null,
    Object? viewCount = null,
    Object? participantCount = null,
    Object? likeCount = null,
    Object? shareCount = null,
    Object? isActive = null,
    Object? isPremium = null,
    Object? tokenCost = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? sortOrder = null,
    Object? metadata = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$TrendContentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TrendContentType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: freezed == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as TrendCategory,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      participantCount: null == participantCount
          ? _value.participantCount
          : participantCount // ignore: cast_nullable_to_non_nullable
              as int,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      shareCount: null == shareCount
          ? _value.shareCount
          : shareCount // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      tokenCost: null == tokenCost
          ? _value.tokenCost
          : tokenCost // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrendContentImpl implements _TrendContent {
  const _$TrendContentImpl(
      {required this.id,
      required this.type,
      required this.title,
      this.subtitle,
      this.thumbnailUrl,
      required this.category,
      this.viewCount = 0,
      this.participantCount = 0,
      this.likeCount = 0,
      this.shareCount = 0,
      this.isActive = true,
      this.isPremium = false,
      this.tokenCost = 0,
      this.startDate,
      this.endDate,
      this.sortOrder = 0,
      final Map<String, dynamic> metadata = const {},
      this.createdAt,
      this.updatedAt})
      : _metadata = metadata;

  factory _$TrendContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrendContentImplFromJson(json);

  @override
  final String id;
  @override
  final TrendContentType type;
  @override
  final String title;
  @override
  final String? subtitle;
  @override
  final String? thumbnailUrl;
  @override
  final TrendCategory category;
  @override
  @JsonKey()
  final int viewCount;
  @override
  @JsonKey()
  final int participantCount;
  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final int shareCount;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isPremium;
  @override
  @JsonKey()
  final int tokenCost;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  @override
  @JsonKey()
  final int sortOrder;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'TrendContent(id: $id, type: $type, title: $title, subtitle: $subtitle, thumbnailUrl: $thumbnailUrl, category: $category, viewCount: $viewCount, participantCount: $participantCount, likeCount: $likeCount, shareCount: $shareCount, isActive: $isActive, isPremium: $isPremium, tokenCost: $tokenCost, startDate: $startDate, endDate: $endDate, sortOrder: $sortOrder, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrendContentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.participantCount, participantCount) ||
                other.participantCount == participantCount) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.shareCount, shareCount) ||
                other.shareCount == shareCount) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.tokenCost, tokenCost) ||
                other.tokenCost == tokenCost) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        type,
        title,
        subtitle,
        thumbnailUrl,
        category,
        viewCount,
        participantCount,
        likeCount,
        shareCount,
        isActive,
        isPremium,
        tokenCost,
        startDate,
        endDate,
        sortOrder,
        const DeepCollectionEquality().hash(_metadata),
        createdAt,
        updatedAt
      ]);

  /// Create a copy of TrendContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrendContentImplCopyWith<_$TrendContentImpl> get copyWith =>
      __$$TrendContentImplCopyWithImpl<_$TrendContentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrendContentImplToJson(
      this,
    );
  }
}

abstract class _TrendContent implements TrendContent {
  const factory _TrendContent(
      {required final String id,
      required final TrendContentType type,
      required final String title,
      final String? subtitle,
      final String? thumbnailUrl,
      required final TrendCategory category,
      final int viewCount,
      final int participantCount,
      final int likeCount,
      final int shareCount,
      final bool isActive,
      final bool isPremium,
      final int tokenCost,
      final DateTime? startDate,
      final DateTime? endDate,
      final int sortOrder,
      final Map<String, dynamic> metadata,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$TrendContentImpl;

  factory _TrendContent.fromJson(Map<String, dynamic> json) =
      _$TrendContentImpl.fromJson;

  @override
  String get id;
  @override
  TrendContentType get type;
  @override
  String get title;
  @override
  String? get subtitle;
  @override
  String? get thumbnailUrl;
  @override
  TrendCategory get category;
  @override
  int get viewCount;
  @override
  int get participantCount;
  @override
  int get likeCount;
  @override
  int get shareCount;
  @override
  bool get isActive;
  @override
  bool get isPremium;
  @override
  int get tokenCost;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  int get sortOrder;
  @override
  Map<String, dynamic> get metadata;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of TrendContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrendContentImplCopyWith<_$TrendContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrendContentListResponse _$TrendContentListResponseFromJson(
    Map<String, dynamic> json) {
  return _TrendContentListResponse.fromJson(json);
}

/// @nodoc
mixin _$TrendContentListResponse {
  List<TrendContent> get contents => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;

  /// Serializes this TrendContentListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrendContentListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrendContentListResponseCopyWith<TrendContentListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrendContentListResponseCopyWith<$Res> {
  factory $TrendContentListResponseCopyWith(TrendContentListResponse value,
          $Res Function(TrendContentListResponse) then) =
      _$TrendContentListResponseCopyWithImpl<$Res, TrendContentListResponse>;
  @useResult
  $Res call({List<TrendContent> contents, int totalCount, bool hasMore});
}

/// @nodoc
class _$TrendContentListResponseCopyWithImpl<$Res,
        $Val extends TrendContentListResponse>
    implements $TrendContentListResponseCopyWith<$Res> {
  _$TrendContentListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrendContentListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contents = null,
    Object? totalCount = null,
    Object? hasMore = null,
  }) {
    return _then(_value.copyWith(
      contents: null == contents
          ? _value.contents
          : contents // ignore: cast_nullable_to_non_nullable
              as List<TrendContent>,
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
abstract class _$$TrendContentListResponseImplCopyWith<$Res>
    implements $TrendContentListResponseCopyWith<$Res> {
  factory _$$TrendContentListResponseImplCopyWith(
          _$TrendContentListResponseImpl value,
          $Res Function(_$TrendContentListResponseImpl) then) =
      __$$TrendContentListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<TrendContent> contents, int totalCount, bool hasMore});
}

/// @nodoc
class __$$TrendContentListResponseImplCopyWithImpl<$Res>
    extends _$TrendContentListResponseCopyWithImpl<$Res,
        _$TrendContentListResponseImpl>
    implements _$$TrendContentListResponseImplCopyWith<$Res> {
  __$$TrendContentListResponseImplCopyWithImpl(
      _$TrendContentListResponseImpl _value,
      $Res Function(_$TrendContentListResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrendContentListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contents = null,
    Object? totalCount = null,
    Object? hasMore = null,
  }) {
    return _then(_$TrendContentListResponseImpl(
      contents: null == contents
          ? _value._contents
          : contents // ignore: cast_nullable_to_non_nullable
              as List<TrendContent>,
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
class _$TrendContentListResponseImpl implements _TrendContentListResponse {
  const _$TrendContentListResponseImpl(
      {required final List<TrendContent> contents,
      this.totalCount = 0,
      this.hasMore = false})
      : _contents = contents;

  factory _$TrendContentListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrendContentListResponseImplFromJson(json);

  final List<TrendContent> _contents;
  @override
  List<TrendContent> get contents {
    if (_contents is EqualUnmodifiableListView) return _contents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contents);
  }

  @override
  @JsonKey()
  final int totalCount;
  @override
  @JsonKey()
  final bool hasMore;

  @override
  String toString() {
    return 'TrendContentListResponse(contents: $contents, totalCount: $totalCount, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrendContentListResponseImpl &&
            const DeepCollectionEquality().equals(other._contents, _contents) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_contents), totalCount, hasMore);

  /// Create a copy of TrendContentListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrendContentListResponseImplCopyWith<_$TrendContentListResponseImpl>
      get copyWith => __$$TrendContentListResponseImplCopyWithImpl<
          _$TrendContentListResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrendContentListResponseImplToJson(
      this,
    );
  }
}

abstract class _TrendContentListResponse implements TrendContentListResponse {
  const factory _TrendContentListResponse(
      {required final List<TrendContent> contents,
      final int totalCount,
      final bool hasMore}) = _$TrendContentListResponseImpl;

  factory _TrendContentListResponse.fromJson(Map<String, dynamic> json) =
      _$TrendContentListResponseImpl.fromJson;

  @override
  List<TrendContent> get contents;
  @override
  int get totalCount;
  @override
  bool get hasMore;

  /// Create a copy of TrendContentListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrendContentListResponseImplCopyWith<_$TrendContentListResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
