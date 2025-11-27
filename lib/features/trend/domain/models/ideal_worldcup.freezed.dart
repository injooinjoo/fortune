// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ideal_worldcup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IdealWorldcup _$IdealWorldcupFromJson(Map<String, dynamic> json) {
  return _IdealWorldcup.fromJson(json);
}

/// @nodoc
mixin _$IdealWorldcup {
  String get id => throw _privateConstructorUsedError;
  String get contentId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  WorldcupCategory get worldcupCategory => throw _privateConstructorUsedError;
  int get totalRounds => throw _privateConstructorUsedError;
  List<WorldcupCandidate> get candidates => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this IdealWorldcup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IdealWorldcup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IdealWorldcupCopyWith<IdealWorldcup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdealWorldcupCopyWith<$Res> {
  factory $IdealWorldcupCopyWith(
          IdealWorldcup value, $Res Function(IdealWorldcup) then) =
      _$IdealWorldcupCopyWithImpl<$Res, IdealWorldcup>;
  @useResult
  $Res call(
      {String id,
      String contentId,
      String? description,
      WorldcupCategory worldcupCategory,
      int totalRounds,
      List<WorldcupCandidate> candidates,
      DateTime? createdAt});
}

/// @nodoc
class _$IdealWorldcupCopyWithImpl<$Res, $Val extends IdealWorldcup>
    implements $IdealWorldcupCopyWith<$Res> {
  _$IdealWorldcupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IdealWorldcup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? contentId = null,
    Object? description = freezed,
    Object? worldcupCategory = null,
    Object? totalRounds = null,
    Object? candidates = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      worldcupCategory: null == worldcupCategory
          ? _value.worldcupCategory
          : worldcupCategory // ignore: cast_nullable_to_non_nullable
              as WorldcupCategory,
      totalRounds: null == totalRounds
          ? _value.totalRounds
          : totalRounds // ignore: cast_nullable_to_non_nullable
              as int,
      candidates: null == candidates
          ? _value.candidates
          : candidates // ignore: cast_nullable_to_non_nullable
              as List<WorldcupCandidate>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IdealWorldcupImplCopyWith<$Res>
    implements $IdealWorldcupCopyWith<$Res> {
  factory _$$IdealWorldcupImplCopyWith(
          _$IdealWorldcupImpl value, $Res Function(_$IdealWorldcupImpl) then) =
      __$$IdealWorldcupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String contentId,
      String? description,
      WorldcupCategory worldcupCategory,
      int totalRounds,
      List<WorldcupCandidate> candidates,
      DateTime? createdAt});
}

/// @nodoc
class __$$IdealWorldcupImplCopyWithImpl<$Res>
    extends _$IdealWorldcupCopyWithImpl<$Res, _$IdealWorldcupImpl>
    implements _$$IdealWorldcupImplCopyWith<$Res> {
  __$$IdealWorldcupImplCopyWithImpl(
      _$IdealWorldcupImpl _value, $Res Function(_$IdealWorldcupImpl) _then)
      : super(_value, _then);

  /// Create a copy of IdealWorldcup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? contentId = null,
    Object? description = freezed,
    Object? worldcupCategory = null,
    Object? totalRounds = null,
    Object? candidates = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$IdealWorldcupImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      worldcupCategory: null == worldcupCategory
          ? _value.worldcupCategory
          : worldcupCategory // ignore: cast_nullable_to_non_nullable
              as WorldcupCategory,
      totalRounds: null == totalRounds
          ? _value.totalRounds
          : totalRounds // ignore: cast_nullable_to_non_nullable
              as int,
      candidates: null == candidates
          ? _value._candidates
          : candidates // ignore: cast_nullable_to_non_nullable
              as List<WorldcupCandidate>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IdealWorldcupImpl implements _IdealWorldcup {
  const _$IdealWorldcupImpl(
      {required this.id,
      required this.contentId,
      this.description,
      required this.worldcupCategory,
      this.totalRounds = 16,
      required final List<WorldcupCandidate> candidates,
      this.createdAt})
      : _candidates = candidates;

  factory _$IdealWorldcupImpl.fromJson(Map<String, dynamic> json) =>
      _$$IdealWorldcupImplFromJson(json);

  @override
  final String id;
  @override
  final String contentId;
  @override
  final String? description;
  @override
  final WorldcupCategory worldcupCategory;
  @override
  @JsonKey()
  final int totalRounds;
  final List<WorldcupCandidate> _candidates;
  @override
  List<WorldcupCandidate> get candidates {
    if (_candidates is EqualUnmodifiableListView) return _candidates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_candidates);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'IdealWorldcup(id: $id, contentId: $contentId, description: $description, worldcupCategory: $worldcupCategory, totalRounds: $totalRounds, candidates: $candidates, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdealWorldcupImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.contentId, contentId) ||
                other.contentId == contentId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.worldcupCategory, worldcupCategory) ||
                other.worldcupCategory == worldcupCategory) &&
            (identical(other.totalRounds, totalRounds) ||
                other.totalRounds == totalRounds) &&
            const DeepCollectionEquality()
                .equals(other._candidates, _candidates) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      contentId,
      description,
      worldcupCategory,
      totalRounds,
      const DeepCollectionEquality().hash(_candidates),
      createdAt);

  /// Create a copy of IdealWorldcup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IdealWorldcupImplCopyWith<_$IdealWorldcupImpl> get copyWith =>
      __$$IdealWorldcupImplCopyWithImpl<_$IdealWorldcupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IdealWorldcupImplToJson(
      this,
    );
  }
}

abstract class _IdealWorldcup implements IdealWorldcup {
  const factory _IdealWorldcup(
      {required final String id,
      required final String contentId,
      final String? description,
      required final WorldcupCategory worldcupCategory,
      final int totalRounds,
      required final List<WorldcupCandidate> candidates,
      final DateTime? createdAt}) = _$IdealWorldcupImpl;

  factory _IdealWorldcup.fromJson(Map<String, dynamic> json) =
      _$IdealWorldcupImpl.fromJson;

  @override
  String get id;
  @override
  String get contentId;
  @override
  String? get description;
  @override
  WorldcupCategory get worldcupCategory;
  @override
  int get totalRounds;
  @override
  List<WorldcupCandidate> get candidates;
  @override
  DateTime? get createdAt;

  /// Create a copy of IdealWorldcup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IdealWorldcupImplCopyWith<_$IdealWorldcupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorldcupCandidate _$WorldcupCandidateFromJson(Map<String, dynamic> json) {
  return _WorldcupCandidate.fromJson(json);
}

/// @nodoc
mixin _$WorldcupCandidate {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get winCount => throw _privateConstructorUsedError;
  int get loseCount => throw _privateConstructorUsedError;
  int get finalWinCount => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this WorldcupCandidate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorldcupCandidate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorldcupCandidateCopyWith<WorldcupCandidate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorldcupCandidateCopyWith<$Res> {
  factory $WorldcupCandidateCopyWith(
          WorldcupCandidate value, $Res Function(WorldcupCandidate) then) =
      _$WorldcupCandidateCopyWithImpl<$Res, WorldcupCandidate>;
  @useResult
  $Res call(
      {String id,
      String name,
      String imageUrl,
      String? description,
      int winCount,
      int loseCount,
      int finalWinCount,
      DateTime? createdAt});
}

/// @nodoc
class _$WorldcupCandidateCopyWithImpl<$Res, $Val extends WorldcupCandidate>
    implements $WorldcupCandidateCopyWith<$Res> {
  _$WorldcupCandidateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorldcupCandidate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? imageUrl = null,
    Object? description = freezed,
    Object? winCount = null,
    Object? loseCount = null,
    Object? finalWinCount = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      winCount: null == winCount
          ? _value.winCount
          : winCount // ignore: cast_nullable_to_non_nullable
              as int,
      loseCount: null == loseCount
          ? _value.loseCount
          : loseCount // ignore: cast_nullable_to_non_nullable
              as int,
      finalWinCount: null == finalWinCount
          ? _value.finalWinCount
          : finalWinCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorldcupCandidateImplCopyWith<$Res>
    implements $WorldcupCandidateCopyWith<$Res> {
  factory _$$WorldcupCandidateImplCopyWith(_$WorldcupCandidateImpl value,
          $Res Function(_$WorldcupCandidateImpl) then) =
      __$$WorldcupCandidateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String imageUrl,
      String? description,
      int winCount,
      int loseCount,
      int finalWinCount,
      DateTime? createdAt});
}

/// @nodoc
class __$$WorldcupCandidateImplCopyWithImpl<$Res>
    extends _$WorldcupCandidateCopyWithImpl<$Res, _$WorldcupCandidateImpl>
    implements _$$WorldcupCandidateImplCopyWith<$Res> {
  __$$WorldcupCandidateImplCopyWithImpl(_$WorldcupCandidateImpl _value,
      $Res Function(_$WorldcupCandidateImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorldcupCandidate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? imageUrl = null,
    Object? description = freezed,
    Object? winCount = null,
    Object? loseCount = null,
    Object? finalWinCount = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$WorldcupCandidateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      winCount: null == winCount
          ? _value.winCount
          : winCount // ignore: cast_nullable_to_non_nullable
              as int,
      loseCount: null == loseCount
          ? _value.loseCount
          : loseCount // ignore: cast_nullable_to_non_nullable
              as int,
      finalWinCount: null == finalWinCount
          ? _value.finalWinCount
          : finalWinCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorldcupCandidateImpl implements _WorldcupCandidate {
  const _$WorldcupCandidateImpl(
      {required this.id,
      required this.name,
      required this.imageUrl,
      this.description,
      this.winCount = 0,
      this.loseCount = 0,
      this.finalWinCount = 0,
      this.createdAt});

  factory _$WorldcupCandidateImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorldcupCandidateImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String imageUrl;
  @override
  final String? description;
  @override
  @JsonKey()
  final int winCount;
  @override
  @JsonKey()
  final int loseCount;
  @override
  @JsonKey()
  final int finalWinCount;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'WorldcupCandidate(id: $id, name: $name, imageUrl: $imageUrl, description: $description, winCount: $winCount, loseCount: $loseCount, finalWinCount: $finalWinCount, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorldcupCandidateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.winCount, winCount) ||
                other.winCount == winCount) &&
            (identical(other.loseCount, loseCount) ||
                other.loseCount == loseCount) &&
            (identical(other.finalWinCount, finalWinCount) ||
                other.finalWinCount == finalWinCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, imageUrl, description,
      winCount, loseCount, finalWinCount, createdAt);

  /// Create a copy of WorldcupCandidate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorldcupCandidateImplCopyWith<_$WorldcupCandidateImpl> get copyWith =>
      __$$WorldcupCandidateImplCopyWithImpl<_$WorldcupCandidateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorldcupCandidateImplToJson(
      this,
    );
  }
}

abstract class _WorldcupCandidate implements WorldcupCandidate {
  const factory _WorldcupCandidate(
      {required final String id,
      required final String name,
      required final String imageUrl,
      final String? description,
      final int winCount,
      final int loseCount,
      final int finalWinCount,
      final DateTime? createdAt}) = _$WorldcupCandidateImpl;

  factory _WorldcupCandidate.fromJson(Map<String, dynamic> json) =
      _$WorldcupCandidateImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get imageUrl;
  @override
  String? get description;
  @override
  int get winCount;
  @override
  int get loseCount;
  @override
  int get finalWinCount;
  @override
  DateTime? get createdAt;

  /// Create a copy of WorldcupCandidate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorldcupCandidateImplCopyWith<_$WorldcupCandidateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorldcupMatchResult _$WorldcupMatchResultFromJson(Map<String, dynamic> json) {
  return _WorldcupMatchResult.fromJson(json);
}

/// @nodoc
mixin _$WorldcupMatchResult {
  int get round => throw _privateConstructorUsedError;
  String get winnerId => throw _privateConstructorUsedError;
  String get loserId => throw _privateConstructorUsedError;

  /// Serializes this WorldcupMatchResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorldcupMatchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorldcupMatchResultCopyWith<WorldcupMatchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorldcupMatchResultCopyWith<$Res> {
  factory $WorldcupMatchResultCopyWith(
          WorldcupMatchResult value, $Res Function(WorldcupMatchResult) then) =
      _$WorldcupMatchResultCopyWithImpl<$Res, WorldcupMatchResult>;
  @useResult
  $Res call({int round, String winnerId, String loserId});
}

/// @nodoc
class _$WorldcupMatchResultCopyWithImpl<$Res, $Val extends WorldcupMatchResult>
    implements $WorldcupMatchResultCopyWith<$Res> {
  _$WorldcupMatchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorldcupMatchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? round = null,
    Object? winnerId = null,
    Object? loserId = null,
  }) {
    return _then(_value.copyWith(
      round: null == round
          ? _value.round
          : round // ignore: cast_nullable_to_non_nullable
              as int,
      winnerId: null == winnerId
          ? _value.winnerId
          : winnerId // ignore: cast_nullable_to_non_nullable
              as String,
      loserId: null == loserId
          ? _value.loserId
          : loserId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorldcupMatchResultImplCopyWith<$Res>
    implements $WorldcupMatchResultCopyWith<$Res> {
  factory _$$WorldcupMatchResultImplCopyWith(_$WorldcupMatchResultImpl value,
          $Res Function(_$WorldcupMatchResultImpl) then) =
      __$$WorldcupMatchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int round, String winnerId, String loserId});
}

/// @nodoc
class __$$WorldcupMatchResultImplCopyWithImpl<$Res>
    extends _$WorldcupMatchResultCopyWithImpl<$Res, _$WorldcupMatchResultImpl>
    implements _$$WorldcupMatchResultImplCopyWith<$Res> {
  __$$WorldcupMatchResultImplCopyWithImpl(_$WorldcupMatchResultImpl _value,
      $Res Function(_$WorldcupMatchResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorldcupMatchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? round = null,
    Object? winnerId = null,
    Object? loserId = null,
  }) {
    return _then(_$WorldcupMatchResultImpl(
      round: null == round
          ? _value.round
          : round // ignore: cast_nullable_to_non_nullable
              as int,
      winnerId: null == winnerId
          ? _value.winnerId
          : winnerId // ignore: cast_nullable_to_non_nullable
              as String,
      loserId: null == loserId
          ? _value.loserId
          : loserId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorldcupMatchResultImpl implements _WorldcupMatchResult {
  const _$WorldcupMatchResultImpl(
      {required this.round, required this.winnerId, required this.loserId});

  factory _$WorldcupMatchResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorldcupMatchResultImplFromJson(json);

  @override
  final int round;
  @override
  final String winnerId;
  @override
  final String loserId;

  @override
  String toString() {
    return 'WorldcupMatchResult(round: $round, winnerId: $winnerId, loserId: $loserId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorldcupMatchResultImpl &&
            (identical(other.round, round) || other.round == round) &&
            (identical(other.winnerId, winnerId) ||
                other.winnerId == winnerId) &&
            (identical(other.loserId, loserId) || other.loserId == loserId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, round, winnerId, loserId);

  /// Create a copy of WorldcupMatchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorldcupMatchResultImplCopyWith<_$WorldcupMatchResultImpl> get copyWith =>
      __$$WorldcupMatchResultImplCopyWithImpl<_$WorldcupMatchResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorldcupMatchResultImplToJson(
      this,
    );
  }
}

abstract class _WorldcupMatchResult implements WorldcupMatchResult {
  const factory _WorldcupMatchResult(
      {required final int round,
      required final String winnerId,
      required final String loserId}) = _$WorldcupMatchResultImpl;

  factory _WorldcupMatchResult.fromJson(Map<String, dynamic> json) =
      _$WorldcupMatchResultImpl.fromJson;

  @override
  int get round;
  @override
  String get winnerId;
  @override
  String get loserId;

  /// Create a copy of WorldcupMatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorldcupMatchResultImplCopyWith<_$WorldcupMatchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserWorldcupResult _$UserWorldcupResultFromJson(Map<String, dynamic> json) {
  return _UserWorldcupResult.fromJson(json);
}

/// @nodoc
mixin _$UserWorldcupResult {
  String get id => throw _privateConstructorUsedError;
  String get worldcupId => throw _privateConstructorUsedError;
  String get winnerId => throw _privateConstructorUsedError;
  String? get secondPlaceId => throw _privateConstructorUsedError;
  String? get thirdPlaceId => throw _privateConstructorUsedError;
  String? get fourthPlaceId => throw _privateConstructorUsedError;
  WorldcupCandidate get winner => throw _privateConstructorUsedError;
  WorldcupCandidate? get secondPlace => throw _privateConstructorUsedError;
  WorldcupCandidate? get thirdPlace => throw _privateConstructorUsedError;
  WorldcupCandidate? get fourthPlace => throw _privateConstructorUsedError;
  List<WorldcupMatchResult> get matchHistory =>
      throw _privateConstructorUsedError;
  bool get isShared => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this UserWorldcupResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserWorldcupResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserWorldcupResultCopyWith<UserWorldcupResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserWorldcupResultCopyWith<$Res> {
  factory $UserWorldcupResultCopyWith(
          UserWorldcupResult value, $Res Function(UserWorldcupResult) then) =
      _$UserWorldcupResultCopyWithImpl<$Res, UserWorldcupResult>;
  @useResult
  $Res call(
      {String id,
      String worldcupId,
      String winnerId,
      String? secondPlaceId,
      String? thirdPlaceId,
      String? fourthPlaceId,
      WorldcupCandidate winner,
      WorldcupCandidate? secondPlace,
      WorldcupCandidate? thirdPlace,
      WorldcupCandidate? fourthPlace,
      List<WorldcupMatchResult> matchHistory,
      bool isShared,
      DateTime? completedAt});

  $WorldcupCandidateCopyWith<$Res> get winner;
  $WorldcupCandidateCopyWith<$Res>? get secondPlace;
  $WorldcupCandidateCopyWith<$Res>? get thirdPlace;
  $WorldcupCandidateCopyWith<$Res>? get fourthPlace;
}

/// @nodoc
class _$UserWorldcupResultCopyWithImpl<$Res, $Val extends UserWorldcupResult>
    implements $UserWorldcupResultCopyWith<$Res> {
  _$UserWorldcupResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserWorldcupResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? worldcupId = null,
    Object? winnerId = null,
    Object? secondPlaceId = freezed,
    Object? thirdPlaceId = freezed,
    Object? fourthPlaceId = freezed,
    Object? winner = null,
    Object? secondPlace = freezed,
    Object? thirdPlace = freezed,
    Object? fourthPlace = freezed,
    Object? matchHistory = null,
    Object? isShared = null,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      worldcupId: null == worldcupId
          ? _value.worldcupId
          : worldcupId // ignore: cast_nullable_to_non_nullable
              as String,
      winnerId: null == winnerId
          ? _value.winnerId
          : winnerId // ignore: cast_nullable_to_non_nullable
              as String,
      secondPlaceId: freezed == secondPlaceId
          ? _value.secondPlaceId
          : secondPlaceId // ignore: cast_nullable_to_non_nullable
              as String?,
      thirdPlaceId: freezed == thirdPlaceId
          ? _value.thirdPlaceId
          : thirdPlaceId // ignore: cast_nullable_to_non_nullable
              as String?,
      fourthPlaceId: freezed == fourthPlaceId
          ? _value.fourthPlaceId
          : fourthPlaceId // ignore: cast_nullable_to_non_nullable
              as String?,
      winner: null == winner
          ? _value.winner
          : winner // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate,
      secondPlace: freezed == secondPlace
          ? _value.secondPlace
          : secondPlace // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate?,
      thirdPlace: freezed == thirdPlace
          ? _value.thirdPlace
          : thirdPlace // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate?,
      fourthPlace: freezed == fourthPlace
          ? _value.fourthPlace
          : fourthPlace // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate?,
      matchHistory: null == matchHistory
          ? _value.matchHistory
          : matchHistory // ignore: cast_nullable_to_non_nullable
              as List<WorldcupMatchResult>,
      isShared: null == isShared
          ? _value.isShared
          : isShared // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of UserWorldcupResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorldcupCandidateCopyWith<$Res> get winner {
    return $WorldcupCandidateCopyWith<$Res>(_value.winner, (value) {
      return _then(_value.copyWith(winner: value) as $Val);
    });
  }

  /// Create a copy of UserWorldcupResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorldcupCandidateCopyWith<$Res>? get secondPlace {
    if (_value.secondPlace == null) {
      return null;
    }

    return $WorldcupCandidateCopyWith<$Res>(_value.secondPlace!, (value) {
      return _then(_value.copyWith(secondPlace: value) as $Val);
    });
  }

  /// Create a copy of UserWorldcupResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorldcupCandidateCopyWith<$Res>? get thirdPlace {
    if (_value.thirdPlace == null) {
      return null;
    }

    return $WorldcupCandidateCopyWith<$Res>(_value.thirdPlace!, (value) {
      return _then(_value.copyWith(thirdPlace: value) as $Val);
    });
  }

  /// Create a copy of UserWorldcupResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorldcupCandidateCopyWith<$Res>? get fourthPlace {
    if (_value.fourthPlace == null) {
      return null;
    }

    return $WorldcupCandidateCopyWith<$Res>(_value.fourthPlace!, (value) {
      return _then(_value.copyWith(fourthPlace: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserWorldcupResultImplCopyWith<$Res>
    implements $UserWorldcupResultCopyWith<$Res> {
  factory _$$UserWorldcupResultImplCopyWith(_$UserWorldcupResultImpl value,
          $Res Function(_$UserWorldcupResultImpl) then) =
      __$$UserWorldcupResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String worldcupId,
      String winnerId,
      String? secondPlaceId,
      String? thirdPlaceId,
      String? fourthPlaceId,
      WorldcupCandidate winner,
      WorldcupCandidate? secondPlace,
      WorldcupCandidate? thirdPlace,
      WorldcupCandidate? fourthPlace,
      List<WorldcupMatchResult> matchHistory,
      bool isShared,
      DateTime? completedAt});

  @override
  $WorldcupCandidateCopyWith<$Res> get winner;
  @override
  $WorldcupCandidateCopyWith<$Res>? get secondPlace;
  @override
  $WorldcupCandidateCopyWith<$Res>? get thirdPlace;
  @override
  $WorldcupCandidateCopyWith<$Res>? get fourthPlace;
}

/// @nodoc
class __$$UserWorldcupResultImplCopyWithImpl<$Res>
    extends _$UserWorldcupResultCopyWithImpl<$Res, _$UserWorldcupResultImpl>
    implements _$$UserWorldcupResultImplCopyWith<$Res> {
  __$$UserWorldcupResultImplCopyWithImpl(_$UserWorldcupResultImpl _value,
      $Res Function(_$UserWorldcupResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserWorldcupResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? worldcupId = null,
    Object? winnerId = null,
    Object? secondPlaceId = freezed,
    Object? thirdPlaceId = freezed,
    Object? fourthPlaceId = freezed,
    Object? winner = null,
    Object? secondPlace = freezed,
    Object? thirdPlace = freezed,
    Object? fourthPlace = freezed,
    Object? matchHistory = null,
    Object? isShared = null,
    Object? completedAt = freezed,
  }) {
    return _then(_$UserWorldcupResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      worldcupId: null == worldcupId
          ? _value.worldcupId
          : worldcupId // ignore: cast_nullable_to_non_nullable
              as String,
      winnerId: null == winnerId
          ? _value.winnerId
          : winnerId // ignore: cast_nullable_to_non_nullable
              as String,
      secondPlaceId: freezed == secondPlaceId
          ? _value.secondPlaceId
          : secondPlaceId // ignore: cast_nullable_to_non_nullable
              as String?,
      thirdPlaceId: freezed == thirdPlaceId
          ? _value.thirdPlaceId
          : thirdPlaceId // ignore: cast_nullable_to_non_nullable
              as String?,
      fourthPlaceId: freezed == fourthPlaceId
          ? _value.fourthPlaceId
          : fourthPlaceId // ignore: cast_nullable_to_non_nullable
              as String?,
      winner: null == winner
          ? _value.winner
          : winner // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate,
      secondPlace: freezed == secondPlace
          ? _value.secondPlace
          : secondPlace // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate?,
      thirdPlace: freezed == thirdPlace
          ? _value.thirdPlace
          : thirdPlace // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate?,
      fourthPlace: freezed == fourthPlace
          ? _value.fourthPlace
          : fourthPlace // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate?,
      matchHistory: null == matchHistory
          ? _value._matchHistory
          : matchHistory // ignore: cast_nullable_to_non_nullable
              as List<WorldcupMatchResult>,
      isShared: null == isShared
          ? _value.isShared
          : isShared // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserWorldcupResultImpl implements _UserWorldcupResult {
  const _$UserWorldcupResultImpl(
      {required this.id,
      required this.worldcupId,
      required this.winnerId,
      this.secondPlaceId,
      this.thirdPlaceId,
      this.fourthPlaceId,
      required this.winner,
      this.secondPlace,
      this.thirdPlace,
      this.fourthPlace,
      required final List<WorldcupMatchResult> matchHistory,
      this.isShared = false,
      this.completedAt})
      : _matchHistory = matchHistory;

  factory _$UserWorldcupResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserWorldcupResultImplFromJson(json);

  @override
  final String id;
  @override
  final String worldcupId;
  @override
  final String winnerId;
  @override
  final String? secondPlaceId;
  @override
  final String? thirdPlaceId;
  @override
  final String? fourthPlaceId;
  @override
  final WorldcupCandidate winner;
  @override
  final WorldcupCandidate? secondPlace;
  @override
  final WorldcupCandidate? thirdPlace;
  @override
  final WorldcupCandidate? fourthPlace;
  final List<WorldcupMatchResult> _matchHistory;
  @override
  List<WorldcupMatchResult> get matchHistory {
    if (_matchHistory is EqualUnmodifiableListView) return _matchHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_matchHistory);
  }

  @override
  @JsonKey()
  final bool isShared;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'UserWorldcupResult(id: $id, worldcupId: $worldcupId, winnerId: $winnerId, secondPlaceId: $secondPlaceId, thirdPlaceId: $thirdPlaceId, fourthPlaceId: $fourthPlaceId, winner: $winner, secondPlace: $secondPlace, thirdPlace: $thirdPlace, fourthPlace: $fourthPlace, matchHistory: $matchHistory, isShared: $isShared, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserWorldcupResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.worldcupId, worldcupId) ||
                other.worldcupId == worldcupId) &&
            (identical(other.winnerId, winnerId) ||
                other.winnerId == winnerId) &&
            (identical(other.secondPlaceId, secondPlaceId) ||
                other.secondPlaceId == secondPlaceId) &&
            (identical(other.thirdPlaceId, thirdPlaceId) ||
                other.thirdPlaceId == thirdPlaceId) &&
            (identical(other.fourthPlaceId, fourthPlaceId) ||
                other.fourthPlaceId == fourthPlaceId) &&
            (identical(other.winner, winner) || other.winner == winner) &&
            (identical(other.secondPlace, secondPlace) ||
                other.secondPlace == secondPlace) &&
            (identical(other.thirdPlace, thirdPlace) ||
                other.thirdPlace == thirdPlace) &&
            (identical(other.fourthPlace, fourthPlace) ||
                other.fourthPlace == fourthPlace) &&
            const DeepCollectionEquality()
                .equals(other._matchHistory, _matchHistory) &&
            (identical(other.isShared, isShared) ||
                other.isShared == isShared) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      worldcupId,
      winnerId,
      secondPlaceId,
      thirdPlaceId,
      fourthPlaceId,
      winner,
      secondPlace,
      thirdPlace,
      fourthPlace,
      const DeepCollectionEquality().hash(_matchHistory),
      isShared,
      completedAt);

  /// Create a copy of UserWorldcupResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserWorldcupResultImplCopyWith<_$UserWorldcupResultImpl> get copyWith =>
      __$$UserWorldcupResultImplCopyWithImpl<_$UserWorldcupResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserWorldcupResultImplToJson(
      this,
    );
  }
}

abstract class _UserWorldcupResult implements UserWorldcupResult {
  const factory _UserWorldcupResult(
      {required final String id,
      required final String worldcupId,
      required final String winnerId,
      final String? secondPlaceId,
      final String? thirdPlaceId,
      final String? fourthPlaceId,
      required final WorldcupCandidate winner,
      final WorldcupCandidate? secondPlace,
      final WorldcupCandidate? thirdPlace,
      final WorldcupCandidate? fourthPlace,
      required final List<WorldcupMatchResult> matchHistory,
      final bool isShared,
      final DateTime? completedAt}) = _$UserWorldcupResultImpl;

  factory _UserWorldcupResult.fromJson(Map<String, dynamic> json) =
      _$UserWorldcupResultImpl.fromJson;

  @override
  String get id;
  @override
  String get worldcupId;
  @override
  String get winnerId;
  @override
  String? get secondPlaceId;
  @override
  String? get thirdPlaceId;
  @override
  String? get fourthPlaceId;
  @override
  WorldcupCandidate get winner;
  @override
  WorldcupCandidate? get secondPlace;
  @override
  WorldcupCandidate? get thirdPlace;
  @override
  WorldcupCandidate? get fourthPlace;
  @override
  List<WorldcupMatchResult> get matchHistory;
  @override
  bool get isShared;
  @override
  DateTime? get completedAt;

  /// Create a copy of UserWorldcupResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserWorldcupResultImplCopyWith<_$UserWorldcupResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorldcupRanking _$WorldcupRankingFromJson(Map<String, dynamic> json) {
  return _WorldcupRanking.fromJson(json);
}

/// @nodoc
mixin _$WorldcupRanking {
  String get worldcupId => throw _privateConstructorUsedError;
  String get candidateId => throw _privateConstructorUsedError;
  String get candidateName => throw _privateConstructorUsedError;
  String get candidateImage => throw _privateConstructorUsedError;
  int get winCount => throw _privateConstructorUsedError;
  int get loseCount => throw _privateConstructorUsedError;
  int get finalWinCount => throw _privateConstructorUsedError;
  double get winRate => throw _privateConstructorUsedError;
  int get rank => throw _privateConstructorUsedError;

  /// Serializes this WorldcupRanking to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorldcupRanking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorldcupRankingCopyWith<WorldcupRanking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorldcupRankingCopyWith<$Res> {
  factory $WorldcupRankingCopyWith(
          WorldcupRanking value, $Res Function(WorldcupRanking) then) =
      _$WorldcupRankingCopyWithImpl<$Res, WorldcupRanking>;
  @useResult
  $Res call(
      {String worldcupId,
      String candidateId,
      String candidateName,
      String candidateImage,
      int winCount,
      int loseCount,
      int finalWinCount,
      double winRate,
      int rank});
}

/// @nodoc
class _$WorldcupRankingCopyWithImpl<$Res, $Val extends WorldcupRanking>
    implements $WorldcupRankingCopyWith<$Res> {
  _$WorldcupRankingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorldcupRanking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? worldcupId = null,
    Object? candidateId = null,
    Object? candidateName = null,
    Object? candidateImage = null,
    Object? winCount = null,
    Object? loseCount = null,
    Object? finalWinCount = null,
    Object? winRate = null,
    Object? rank = null,
  }) {
    return _then(_value.copyWith(
      worldcupId: null == worldcupId
          ? _value.worldcupId
          : worldcupId // ignore: cast_nullable_to_non_nullable
              as String,
      candidateId: null == candidateId
          ? _value.candidateId
          : candidateId // ignore: cast_nullable_to_non_nullable
              as String,
      candidateName: null == candidateName
          ? _value.candidateName
          : candidateName // ignore: cast_nullable_to_non_nullable
              as String,
      candidateImage: null == candidateImage
          ? _value.candidateImage
          : candidateImage // ignore: cast_nullable_to_non_nullable
              as String,
      winCount: null == winCount
          ? _value.winCount
          : winCount // ignore: cast_nullable_to_non_nullable
              as int,
      loseCount: null == loseCount
          ? _value.loseCount
          : loseCount // ignore: cast_nullable_to_non_nullable
              as int,
      finalWinCount: null == finalWinCount
          ? _value.finalWinCount
          : finalWinCount // ignore: cast_nullable_to_non_nullable
              as int,
      winRate: null == winRate
          ? _value.winRate
          : winRate // ignore: cast_nullable_to_non_nullable
              as double,
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorldcupRankingImplCopyWith<$Res>
    implements $WorldcupRankingCopyWith<$Res> {
  factory _$$WorldcupRankingImplCopyWith(_$WorldcupRankingImpl value,
          $Res Function(_$WorldcupRankingImpl) then) =
      __$$WorldcupRankingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String worldcupId,
      String candidateId,
      String candidateName,
      String candidateImage,
      int winCount,
      int loseCount,
      int finalWinCount,
      double winRate,
      int rank});
}

/// @nodoc
class __$$WorldcupRankingImplCopyWithImpl<$Res>
    extends _$WorldcupRankingCopyWithImpl<$Res, _$WorldcupRankingImpl>
    implements _$$WorldcupRankingImplCopyWith<$Res> {
  __$$WorldcupRankingImplCopyWithImpl(
      _$WorldcupRankingImpl _value, $Res Function(_$WorldcupRankingImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorldcupRanking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? worldcupId = null,
    Object? candidateId = null,
    Object? candidateName = null,
    Object? candidateImage = null,
    Object? winCount = null,
    Object? loseCount = null,
    Object? finalWinCount = null,
    Object? winRate = null,
    Object? rank = null,
  }) {
    return _then(_$WorldcupRankingImpl(
      worldcupId: null == worldcupId
          ? _value.worldcupId
          : worldcupId // ignore: cast_nullable_to_non_nullable
              as String,
      candidateId: null == candidateId
          ? _value.candidateId
          : candidateId // ignore: cast_nullable_to_non_nullable
              as String,
      candidateName: null == candidateName
          ? _value.candidateName
          : candidateName // ignore: cast_nullable_to_non_nullable
              as String,
      candidateImage: null == candidateImage
          ? _value.candidateImage
          : candidateImage // ignore: cast_nullable_to_non_nullable
              as String,
      winCount: null == winCount
          ? _value.winCount
          : winCount // ignore: cast_nullable_to_non_nullable
              as int,
      loseCount: null == loseCount
          ? _value.loseCount
          : loseCount // ignore: cast_nullable_to_non_nullable
              as int,
      finalWinCount: null == finalWinCount
          ? _value.finalWinCount
          : finalWinCount // ignore: cast_nullable_to_non_nullable
              as int,
      winRate: null == winRate
          ? _value.winRate
          : winRate // ignore: cast_nullable_to_non_nullable
              as double,
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorldcupRankingImpl implements _WorldcupRanking {
  const _$WorldcupRankingImpl(
      {required this.worldcupId,
      required this.candidateId,
      required this.candidateName,
      required this.candidateImage,
      required this.winCount,
      required this.loseCount,
      required this.finalWinCount,
      required this.winRate,
      required this.rank});

  factory _$WorldcupRankingImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorldcupRankingImplFromJson(json);

  @override
  final String worldcupId;
  @override
  final String candidateId;
  @override
  final String candidateName;
  @override
  final String candidateImage;
  @override
  final int winCount;
  @override
  final int loseCount;
  @override
  final int finalWinCount;
  @override
  final double winRate;
  @override
  final int rank;

  @override
  String toString() {
    return 'WorldcupRanking(worldcupId: $worldcupId, candidateId: $candidateId, candidateName: $candidateName, candidateImage: $candidateImage, winCount: $winCount, loseCount: $loseCount, finalWinCount: $finalWinCount, winRate: $winRate, rank: $rank)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorldcupRankingImpl &&
            (identical(other.worldcupId, worldcupId) ||
                other.worldcupId == worldcupId) &&
            (identical(other.candidateId, candidateId) ||
                other.candidateId == candidateId) &&
            (identical(other.candidateName, candidateName) ||
                other.candidateName == candidateName) &&
            (identical(other.candidateImage, candidateImage) ||
                other.candidateImage == candidateImage) &&
            (identical(other.winCount, winCount) ||
                other.winCount == winCount) &&
            (identical(other.loseCount, loseCount) ||
                other.loseCount == loseCount) &&
            (identical(other.finalWinCount, finalWinCount) ||
                other.finalWinCount == finalWinCount) &&
            (identical(other.winRate, winRate) || other.winRate == winRate) &&
            (identical(other.rank, rank) || other.rank == rank));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      worldcupId,
      candidateId,
      candidateName,
      candidateImage,
      winCount,
      loseCount,
      finalWinCount,
      winRate,
      rank);

  /// Create a copy of WorldcupRanking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorldcupRankingImplCopyWith<_$WorldcupRankingImpl> get copyWith =>
      __$$WorldcupRankingImplCopyWithImpl<_$WorldcupRankingImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorldcupRankingImplToJson(
      this,
    );
  }
}

abstract class _WorldcupRanking implements WorldcupRanking {
  const factory _WorldcupRanking(
      {required final String worldcupId,
      required final String candidateId,
      required final String candidateName,
      required final String candidateImage,
      required final int winCount,
      required final int loseCount,
      required final int finalWinCount,
      required final double winRate,
      required final int rank}) = _$WorldcupRankingImpl;

  factory _WorldcupRanking.fromJson(Map<String, dynamic> json) =
      _$WorldcupRankingImpl.fromJson;

  @override
  String get worldcupId;
  @override
  String get candidateId;
  @override
  String get candidateName;
  @override
  String get candidateImage;
  @override
  int get winCount;
  @override
  int get loseCount;
  @override
  int get finalWinCount;
  @override
  double get winRate;
  @override
  int get rank;

  /// Create a copy of WorldcupRanking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorldcupRankingImplCopyWith<_$WorldcupRankingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorldcupGameState _$WorldcupGameStateFromJson(Map<String, dynamic> json) {
  return _WorldcupGameState.fromJson(json);
}

/// @nodoc
mixin _$WorldcupGameState {
  String get worldcupId => throw _privateConstructorUsedError;
  int get currentRound => throw _privateConstructorUsedError;
  int get matchIndex => throw _privateConstructorUsedError;
  List<WorldcupCandidate> get remainingCandidates =>
      throw _privateConstructorUsedError;
  List<WorldcupMatchResult> get matchHistory =>
      throw _privateConstructorUsedError;
  WorldcupCandidate? get currentMatchLeft => throw _privateConstructorUsedError;
  WorldcupCandidate? get currentMatchRight =>
      throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  WorldcupCandidate? get winner => throw _privateConstructorUsedError;
  WorldcupCandidate? get secondPlace => throw _privateConstructorUsedError;
  WorldcupCandidate? get thirdPlace => throw _privateConstructorUsedError;
  WorldcupCandidate? get fourthPlace => throw _privateConstructorUsedError;

  /// Serializes this WorldcupGameState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorldcupGameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorldcupGameStateCopyWith<WorldcupGameState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorldcupGameStateCopyWith<$Res> {
  factory $WorldcupGameStateCopyWith(
          WorldcupGameState value, $Res Function(WorldcupGameState) then) =
      _$WorldcupGameStateCopyWithImpl<$Res, WorldcupGameState>;
  @useResult
  $Res call(
      {String worldcupId,
      int currentRound,
      int matchIndex,
      List<WorldcupCandidate> remainingCandidates,
      List<WorldcupMatchResult> matchHistory,
      WorldcupCandidate? currentMatchLeft,
      WorldcupCandidate? currentMatchRight,
      bool isCompleted,
      WorldcupCandidate? winner,
      WorldcupCandidate? secondPlace,
      WorldcupCandidate? thirdPlace,
      WorldcupCandidate? fourthPlace});

  $WorldcupCandidateCopyWith<$Res>? get currentMatchLeft;
  $WorldcupCandidateCopyWith<$Res>? get currentMatchRight;
  $WorldcupCandidateCopyWith<$Res>? get winner;
  $WorldcupCandidateCopyWith<$Res>? get secondPlace;
  $WorldcupCandidateCopyWith<$Res>? get thirdPlace;
  $WorldcupCandidateCopyWith<$Res>? get fourthPlace;
}

/// @nodoc
class _$WorldcupGameStateCopyWithImpl<$Res, $Val extends WorldcupGameState>
    implements $WorldcupGameStateCopyWith<$Res> {
  _$WorldcupGameStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorldcupGameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? worldcupId = null,
    Object? currentRound = null,
    Object? matchIndex = null,
    Object? remainingCandidates = null,
    Object? matchHistory = null,
    Object? currentMatchLeft = freezed,
    Object? currentMatchRight = freezed,
    Object? isCompleted = null,
    Object? winner = freezed,
    Object? secondPlace = freezed,
    Object? thirdPlace = freezed,
    Object? fourthPlace = freezed,
  }) {
    return _then(_value.copyWith(
      worldcupId: null == worldcupId
          ? _value.worldcupId
          : worldcupId // ignore: cast_nullable_to_non_nullable
              as String,
      currentRound: null == currentRound
          ? _value.currentRound
          : currentRound // ignore: cast_nullable_to_non_nullable
              as int,
      matchIndex: null == matchIndex
          ? _value.matchIndex
          : matchIndex // ignore: cast_nullable_to_non_nullable
              as int,
      remainingCandidates: null == remainingCandidates
          ? _value.remainingCandidates
          : remainingCandidates // ignore: cast_nullable_to_non_nullable
              as List<WorldcupCandidate>,
      matchHistory: null == matchHistory
          ? _value.matchHistory
          : matchHistory // ignore: cast_nullable_to_non_nullable
              as List<WorldcupMatchResult>,
      currentMatchLeft: freezed == currentMatchLeft
          ? _value.currentMatchLeft
          : currentMatchLeft // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate?,
      currentMatchRight: freezed == currentMatchRight
          ? _value.currentMatchRight
          : currentMatchRight // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      winner: freezed == winner
          ? _value.winner
          : winner // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate?,
      secondPlace: freezed == secondPlace
          ? _value.secondPlace
          : secondPlace // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate?,
      thirdPlace: freezed == thirdPlace
          ? _value.thirdPlace
          : thirdPlace // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate?,
      fourthPlace: freezed == fourthPlace
          ? _value.fourthPlace
          : fourthPlace // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate?,
    ) as $Val);
  }

  /// Create a copy of WorldcupGameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorldcupCandidateCopyWith<$Res>? get currentMatchLeft {
    if (_value.currentMatchLeft == null) {
      return null;
    }

    return $WorldcupCandidateCopyWith<$Res>(_value.currentMatchLeft!, (value) {
      return _then(_value.copyWith(currentMatchLeft: value) as $Val);
    });
  }

  /// Create a copy of WorldcupGameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorldcupCandidateCopyWith<$Res>? get currentMatchRight {
    if (_value.currentMatchRight == null) {
      return null;
    }

    return $WorldcupCandidateCopyWith<$Res>(_value.currentMatchRight!, (value) {
      return _then(_value.copyWith(currentMatchRight: value) as $Val);
    });
  }

  /// Create a copy of WorldcupGameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorldcupCandidateCopyWith<$Res>? get winner {
    if (_value.winner == null) {
      return null;
    }

    return $WorldcupCandidateCopyWith<$Res>(_value.winner!, (value) {
      return _then(_value.copyWith(winner: value) as $Val);
    });
  }

  /// Create a copy of WorldcupGameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorldcupCandidateCopyWith<$Res>? get secondPlace {
    if (_value.secondPlace == null) {
      return null;
    }

    return $WorldcupCandidateCopyWith<$Res>(_value.secondPlace!, (value) {
      return _then(_value.copyWith(secondPlace: value) as $Val);
    });
  }

  /// Create a copy of WorldcupGameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorldcupCandidateCopyWith<$Res>? get thirdPlace {
    if (_value.thirdPlace == null) {
      return null;
    }

    return $WorldcupCandidateCopyWith<$Res>(_value.thirdPlace!, (value) {
      return _then(_value.copyWith(thirdPlace: value) as $Val);
    });
  }

  /// Create a copy of WorldcupGameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorldcupCandidateCopyWith<$Res>? get fourthPlace {
    if (_value.fourthPlace == null) {
      return null;
    }

    return $WorldcupCandidateCopyWith<$Res>(_value.fourthPlace!, (value) {
      return _then(_value.copyWith(fourthPlace: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WorldcupGameStateImplCopyWith<$Res>
    implements $WorldcupGameStateCopyWith<$Res> {
  factory _$$WorldcupGameStateImplCopyWith(_$WorldcupGameStateImpl value,
          $Res Function(_$WorldcupGameStateImpl) then) =
      __$$WorldcupGameStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String worldcupId,
      int currentRound,
      int matchIndex,
      List<WorldcupCandidate> remainingCandidates,
      List<WorldcupMatchResult> matchHistory,
      WorldcupCandidate? currentMatchLeft,
      WorldcupCandidate? currentMatchRight,
      bool isCompleted,
      WorldcupCandidate? winner,
      WorldcupCandidate? secondPlace,
      WorldcupCandidate? thirdPlace,
      WorldcupCandidate? fourthPlace});

  @override
  $WorldcupCandidateCopyWith<$Res>? get currentMatchLeft;
  @override
  $WorldcupCandidateCopyWith<$Res>? get currentMatchRight;
  @override
  $WorldcupCandidateCopyWith<$Res>? get winner;
  @override
  $WorldcupCandidateCopyWith<$Res>? get secondPlace;
  @override
  $WorldcupCandidateCopyWith<$Res>? get thirdPlace;
  @override
  $WorldcupCandidateCopyWith<$Res>? get fourthPlace;
}

/// @nodoc
class __$$WorldcupGameStateImplCopyWithImpl<$Res>
    extends _$WorldcupGameStateCopyWithImpl<$Res, _$WorldcupGameStateImpl>
    implements _$$WorldcupGameStateImplCopyWith<$Res> {
  __$$WorldcupGameStateImplCopyWithImpl(_$WorldcupGameStateImpl _value,
      $Res Function(_$WorldcupGameStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorldcupGameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? worldcupId = null,
    Object? currentRound = null,
    Object? matchIndex = null,
    Object? remainingCandidates = null,
    Object? matchHistory = null,
    Object? currentMatchLeft = freezed,
    Object? currentMatchRight = freezed,
    Object? isCompleted = null,
    Object? winner = freezed,
    Object? secondPlace = freezed,
    Object? thirdPlace = freezed,
    Object? fourthPlace = freezed,
  }) {
    return _then(_$WorldcupGameStateImpl(
      worldcupId: null == worldcupId
          ? _value.worldcupId
          : worldcupId // ignore: cast_nullable_to_non_nullable
              as String,
      currentRound: null == currentRound
          ? _value.currentRound
          : currentRound // ignore: cast_nullable_to_non_nullable
              as int,
      matchIndex: null == matchIndex
          ? _value.matchIndex
          : matchIndex // ignore: cast_nullable_to_non_nullable
              as int,
      remainingCandidates: null == remainingCandidates
          ? _value._remainingCandidates
          : remainingCandidates // ignore: cast_nullable_to_non_nullable
              as List<WorldcupCandidate>,
      matchHistory: null == matchHistory
          ? _value._matchHistory
          : matchHistory // ignore: cast_nullable_to_non_nullable
              as List<WorldcupMatchResult>,
      currentMatchLeft: freezed == currentMatchLeft
          ? _value.currentMatchLeft
          : currentMatchLeft // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate?,
      currentMatchRight: freezed == currentMatchRight
          ? _value.currentMatchRight
          : currentMatchRight // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      winner: freezed == winner
          ? _value.winner
          : winner // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate?,
      secondPlace: freezed == secondPlace
          ? _value.secondPlace
          : secondPlace // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate?,
      thirdPlace: freezed == thirdPlace
          ? _value.thirdPlace
          : thirdPlace // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate?,
      fourthPlace: freezed == fourthPlace
          ? _value.fourthPlace
          : fourthPlace // ignore: cast_nullable_to_non_nullable
              as WorldcupCandidate?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorldcupGameStateImpl implements _WorldcupGameState {
  const _$WorldcupGameStateImpl(
      {required this.worldcupId,
      required this.currentRound,
      required this.matchIndex,
      required final List<WorldcupCandidate> remainingCandidates,
      required final List<WorldcupMatchResult> matchHistory,
      this.currentMatchLeft,
      this.currentMatchRight,
      this.isCompleted = false,
      this.winner,
      this.secondPlace,
      this.thirdPlace,
      this.fourthPlace})
      : _remainingCandidates = remainingCandidates,
        _matchHistory = matchHistory;

  factory _$WorldcupGameStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorldcupGameStateImplFromJson(json);

  @override
  final String worldcupId;
  @override
  final int currentRound;
  @override
  final int matchIndex;
  final List<WorldcupCandidate> _remainingCandidates;
  @override
  List<WorldcupCandidate> get remainingCandidates {
    if (_remainingCandidates is EqualUnmodifiableListView)
      return _remainingCandidates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_remainingCandidates);
  }

  final List<WorldcupMatchResult> _matchHistory;
  @override
  List<WorldcupMatchResult> get matchHistory {
    if (_matchHistory is EqualUnmodifiableListView) return _matchHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_matchHistory);
  }

  @override
  final WorldcupCandidate? currentMatchLeft;
  @override
  final WorldcupCandidate? currentMatchRight;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  final WorldcupCandidate? winner;
  @override
  final WorldcupCandidate? secondPlace;
  @override
  final WorldcupCandidate? thirdPlace;
  @override
  final WorldcupCandidate? fourthPlace;

  @override
  String toString() {
    return 'WorldcupGameState(worldcupId: $worldcupId, currentRound: $currentRound, matchIndex: $matchIndex, remainingCandidates: $remainingCandidates, matchHistory: $matchHistory, currentMatchLeft: $currentMatchLeft, currentMatchRight: $currentMatchRight, isCompleted: $isCompleted, winner: $winner, secondPlace: $secondPlace, thirdPlace: $thirdPlace, fourthPlace: $fourthPlace)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorldcupGameStateImpl &&
            (identical(other.worldcupId, worldcupId) ||
                other.worldcupId == worldcupId) &&
            (identical(other.currentRound, currentRound) ||
                other.currentRound == currentRound) &&
            (identical(other.matchIndex, matchIndex) ||
                other.matchIndex == matchIndex) &&
            const DeepCollectionEquality()
                .equals(other._remainingCandidates, _remainingCandidates) &&
            const DeepCollectionEquality()
                .equals(other._matchHistory, _matchHistory) &&
            (identical(other.currentMatchLeft, currentMatchLeft) ||
                other.currentMatchLeft == currentMatchLeft) &&
            (identical(other.currentMatchRight, currentMatchRight) ||
                other.currentMatchRight == currentMatchRight) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.winner, winner) || other.winner == winner) &&
            (identical(other.secondPlace, secondPlace) ||
                other.secondPlace == secondPlace) &&
            (identical(other.thirdPlace, thirdPlace) ||
                other.thirdPlace == thirdPlace) &&
            (identical(other.fourthPlace, fourthPlace) ||
                other.fourthPlace == fourthPlace));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      worldcupId,
      currentRound,
      matchIndex,
      const DeepCollectionEquality().hash(_remainingCandidates),
      const DeepCollectionEquality().hash(_matchHistory),
      currentMatchLeft,
      currentMatchRight,
      isCompleted,
      winner,
      secondPlace,
      thirdPlace,
      fourthPlace);

  /// Create a copy of WorldcupGameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorldcupGameStateImplCopyWith<_$WorldcupGameStateImpl> get copyWith =>
      __$$WorldcupGameStateImplCopyWithImpl<_$WorldcupGameStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorldcupGameStateImplToJson(
      this,
    );
  }
}

abstract class _WorldcupGameState implements WorldcupGameState {
  const factory _WorldcupGameState(
      {required final String worldcupId,
      required final int currentRound,
      required final int matchIndex,
      required final List<WorldcupCandidate> remainingCandidates,
      required final List<WorldcupMatchResult> matchHistory,
      final WorldcupCandidate? currentMatchLeft,
      final WorldcupCandidate? currentMatchRight,
      final bool isCompleted,
      final WorldcupCandidate? winner,
      final WorldcupCandidate? secondPlace,
      final WorldcupCandidate? thirdPlace,
      final WorldcupCandidate? fourthPlace}) = _$WorldcupGameStateImpl;

  factory _WorldcupGameState.fromJson(Map<String, dynamic> json) =
      _$WorldcupGameStateImpl.fromJson;

  @override
  String get worldcupId;
  @override
  int get currentRound;
  @override
  int get matchIndex;
  @override
  List<WorldcupCandidate> get remainingCandidates;
  @override
  List<WorldcupMatchResult> get matchHistory;
  @override
  WorldcupCandidate? get currentMatchLeft;
  @override
  WorldcupCandidate? get currentMatchRight;
  @override
  bool get isCompleted;
  @override
  WorldcupCandidate? get winner;
  @override
  WorldcupCandidate? get secondPlace;
  @override
  WorldcupCandidate? get thirdPlace;
  @override
  WorldcupCandidate? get fourthPlace;

  /// Create a copy of WorldcupGameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorldcupGameStateImplCopyWith<_$WorldcupGameStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorldcupSubmission _$WorldcupSubmissionFromJson(Map<String, dynamic> json) {
  return _WorldcupSubmission.fromJson(json);
}

/// @nodoc
mixin _$WorldcupSubmission {
  String get worldcupId => throw _privateConstructorUsedError;
  String get winnerId => throw _privateConstructorUsedError;
  String? get secondPlaceId => throw _privateConstructorUsedError;
  String? get thirdPlaceId => throw _privateConstructorUsedError;
  String? get fourthPlaceId => throw _privateConstructorUsedError;
  List<WorldcupMatchResult> get matchHistory =>
      throw _privateConstructorUsedError;

  /// Serializes this WorldcupSubmission to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorldcupSubmission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorldcupSubmissionCopyWith<WorldcupSubmission> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorldcupSubmissionCopyWith<$Res> {
  factory $WorldcupSubmissionCopyWith(
          WorldcupSubmission value, $Res Function(WorldcupSubmission) then) =
      _$WorldcupSubmissionCopyWithImpl<$Res, WorldcupSubmission>;
  @useResult
  $Res call(
      {String worldcupId,
      String winnerId,
      String? secondPlaceId,
      String? thirdPlaceId,
      String? fourthPlaceId,
      List<WorldcupMatchResult> matchHistory});
}

/// @nodoc
class _$WorldcupSubmissionCopyWithImpl<$Res, $Val extends WorldcupSubmission>
    implements $WorldcupSubmissionCopyWith<$Res> {
  _$WorldcupSubmissionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorldcupSubmission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? worldcupId = null,
    Object? winnerId = null,
    Object? secondPlaceId = freezed,
    Object? thirdPlaceId = freezed,
    Object? fourthPlaceId = freezed,
    Object? matchHistory = null,
  }) {
    return _then(_value.copyWith(
      worldcupId: null == worldcupId
          ? _value.worldcupId
          : worldcupId // ignore: cast_nullable_to_non_nullable
              as String,
      winnerId: null == winnerId
          ? _value.winnerId
          : winnerId // ignore: cast_nullable_to_non_nullable
              as String,
      secondPlaceId: freezed == secondPlaceId
          ? _value.secondPlaceId
          : secondPlaceId // ignore: cast_nullable_to_non_nullable
              as String?,
      thirdPlaceId: freezed == thirdPlaceId
          ? _value.thirdPlaceId
          : thirdPlaceId // ignore: cast_nullable_to_non_nullable
              as String?,
      fourthPlaceId: freezed == fourthPlaceId
          ? _value.fourthPlaceId
          : fourthPlaceId // ignore: cast_nullable_to_non_nullable
              as String?,
      matchHistory: null == matchHistory
          ? _value.matchHistory
          : matchHistory // ignore: cast_nullable_to_non_nullable
              as List<WorldcupMatchResult>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorldcupSubmissionImplCopyWith<$Res>
    implements $WorldcupSubmissionCopyWith<$Res> {
  factory _$$WorldcupSubmissionImplCopyWith(_$WorldcupSubmissionImpl value,
          $Res Function(_$WorldcupSubmissionImpl) then) =
      __$$WorldcupSubmissionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String worldcupId,
      String winnerId,
      String? secondPlaceId,
      String? thirdPlaceId,
      String? fourthPlaceId,
      List<WorldcupMatchResult> matchHistory});
}

/// @nodoc
class __$$WorldcupSubmissionImplCopyWithImpl<$Res>
    extends _$WorldcupSubmissionCopyWithImpl<$Res, _$WorldcupSubmissionImpl>
    implements _$$WorldcupSubmissionImplCopyWith<$Res> {
  __$$WorldcupSubmissionImplCopyWithImpl(_$WorldcupSubmissionImpl _value,
      $Res Function(_$WorldcupSubmissionImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorldcupSubmission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? worldcupId = null,
    Object? winnerId = null,
    Object? secondPlaceId = freezed,
    Object? thirdPlaceId = freezed,
    Object? fourthPlaceId = freezed,
    Object? matchHistory = null,
  }) {
    return _then(_$WorldcupSubmissionImpl(
      worldcupId: null == worldcupId
          ? _value.worldcupId
          : worldcupId // ignore: cast_nullable_to_non_nullable
              as String,
      winnerId: null == winnerId
          ? _value.winnerId
          : winnerId // ignore: cast_nullable_to_non_nullable
              as String,
      secondPlaceId: freezed == secondPlaceId
          ? _value.secondPlaceId
          : secondPlaceId // ignore: cast_nullable_to_non_nullable
              as String?,
      thirdPlaceId: freezed == thirdPlaceId
          ? _value.thirdPlaceId
          : thirdPlaceId // ignore: cast_nullable_to_non_nullable
              as String?,
      fourthPlaceId: freezed == fourthPlaceId
          ? _value.fourthPlaceId
          : fourthPlaceId // ignore: cast_nullable_to_non_nullable
              as String?,
      matchHistory: null == matchHistory
          ? _value._matchHistory
          : matchHistory // ignore: cast_nullable_to_non_nullable
              as List<WorldcupMatchResult>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorldcupSubmissionImpl implements _WorldcupSubmission {
  const _$WorldcupSubmissionImpl(
      {required this.worldcupId,
      required this.winnerId,
      this.secondPlaceId,
      this.thirdPlaceId,
      this.fourthPlaceId,
      required final List<WorldcupMatchResult> matchHistory})
      : _matchHistory = matchHistory;

  factory _$WorldcupSubmissionImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorldcupSubmissionImplFromJson(json);

  @override
  final String worldcupId;
  @override
  final String winnerId;
  @override
  final String? secondPlaceId;
  @override
  final String? thirdPlaceId;
  @override
  final String? fourthPlaceId;
  final List<WorldcupMatchResult> _matchHistory;
  @override
  List<WorldcupMatchResult> get matchHistory {
    if (_matchHistory is EqualUnmodifiableListView) return _matchHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_matchHistory);
  }

  @override
  String toString() {
    return 'WorldcupSubmission(worldcupId: $worldcupId, winnerId: $winnerId, secondPlaceId: $secondPlaceId, thirdPlaceId: $thirdPlaceId, fourthPlaceId: $fourthPlaceId, matchHistory: $matchHistory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorldcupSubmissionImpl &&
            (identical(other.worldcupId, worldcupId) ||
                other.worldcupId == worldcupId) &&
            (identical(other.winnerId, winnerId) ||
                other.winnerId == winnerId) &&
            (identical(other.secondPlaceId, secondPlaceId) ||
                other.secondPlaceId == secondPlaceId) &&
            (identical(other.thirdPlaceId, thirdPlaceId) ||
                other.thirdPlaceId == thirdPlaceId) &&
            (identical(other.fourthPlaceId, fourthPlaceId) ||
                other.fourthPlaceId == fourthPlaceId) &&
            const DeepCollectionEquality()
                .equals(other._matchHistory, _matchHistory));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      worldcupId,
      winnerId,
      secondPlaceId,
      thirdPlaceId,
      fourthPlaceId,
      const DeepCollectionEquality().hash(_matchHistory));

  /// Create a copy of WorldcupSubmission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorldcupSubmissionImplCopyWith<_$WorldcupSubmissionImpl> get copyWith =>
      __$$WorldcupSubmissionImplCopyWithImpl<_$WorldcupSubmissionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorldcupSubmissionImplToJson(
      this,
    );
  }
}

abstract class _WorldcupSubmission implements WorldcupSubmission {
  const factory _WorldcupSubmission(
          {required final String worldcupId,
          required final String winnerId,
          final String? secondPlaceId,
          final String? thirdPlaceId,
          final String? fourthPlaceId,
          required final List<WorldcupMatchResult> matchHistory}) =
      _$WorldcupSubmissionImpl;

  factory _WorldcupSubmission.fromJson(Map<String, dynamic> json) =
      _$WorldcupSubmissionImpl.fromJson;

  @override
  String get worldcupId;
  @override
  String get winnerId;
  @override
  String? get secondPlaceId;
  @override
  String? get thirdPlaceId;
  @override
  String? get fourthPlaceId;
  @override
  List<WorldcupMatchResult> get matchHistory;

  /// Create a copy of WorldcupSubmission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorldcupSubmissionImplCopyWith<_$WorldcupSubmissionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
