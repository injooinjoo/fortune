// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'asset_pack.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AssetPack _$AssetPackFromJson(Map<String, dynamic> json) {
  return _AssetPack.fromJson(json);
}

/// @nodoc
mixin _$AssetPack {
  /// 팩 고유 ID (예: 'tarot_rider_waite', 'mbti_characters')
  String get id => throw _privateConstructorUsedError;

  /// 표시 이름 (예: 'Rider Waite 타로 덱')
  String get displayName => throw _privateConstructorUsedError;

  /// Tier 분류
  AssetTier get tier => throw _privateConstructorUsedError;

  /// 로컬 자산 경로 목록
  List<String> get localPaths => throw _privateConstructorUsedError;

  /// Supabase Storage 경로 (CDN)
  String? get storagePath => throw _privateConstructorUsedError;

  /// 예상 파일 크기 (bytes)
  int get estimatedSize => throw _privateConstructorUsedError;

  /// 관련 운세 타입 (트리거)
  String? get fortuneType => throw _privateConstructorUsedError;

  /// 현재 상태
  AssetPackStatus get status => throw _privateConstructorUsedError;

  /// 다운로드 진행률 (0.0 ~ 1.0)
  double get downloadProgress => throw _privateConstructorUsedError;

  /// 마지막 접근 시간
  DateTime? get lastAccessedAt => throw _privateConstructorUsedError;

  /// 설치 시간
  DateTime? get installedAt => throw _privateConstructorUsedError;

  /// Serializes this AssetPack to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssetPack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssetPackCopyWith<AssetPack> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssetPackCopyWith<$Res> {
  factory $AssetPackCopyWith(AssetPack value, $Res Function(AssetPack) then) =
      _$AssetPackCopyWithImpl<$Res, AssetPack>;
  @useResult
  $Res call(
      {String id,
      String displayName,
      AssetTier tier,
      List<String> localPaths,
      String? storagePath,
      int estimatedSize,
      String? fortuneType,
      AssetPackStatus status,
      double downloadProgress,
      DateTime? lastAccessedAt,
      DateTime? installedAt});
}

/// @nodoc
class _$AssetPackCopyWithImpl<$Res, $Val extends AssetPack>
    implements $AssetPackCopyWith<$Res> {
  _$AssetPackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssetPack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displayName = null,
    Object? tier = null,
    Object? localPaths = null,
    Object? storagePath = freezed,
    Object? estimatedSize = null,
    Object? fortuneType = freezed,
    Object? status = null,
    Object? downloadProgress = null,
    Object? lastAccessedAt = freezed,
    Object? installedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as AssetTier,
      localPaths: null == localPaths
          ? _value.localPaths
          : localPaths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      storagePath: freezed == storagePath
          ? _value.storagePath
          : storagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedSize: null == estimatedSize
          ? _value.estimatedSize
          : estimatedSize // ignore: cast_nullable_to_non_nullable
              as int,
      fortuneType: freezed == fortuneType
          ? _value.fortuneType
          : fortuneType // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AssetPackStatus,
      downloadProgress: null == downloadProgress
          ? _value.downloadProgress
          : downloadProgress // ignore: cast_nullable_to_non_nullable
              as double,
      lastAccessedAt: freezed == lastAccessedAt
          ? _value.lastAccessedAt
          : lastAccessedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      installedAt: freezed == installedAt
          ? _value.installedAt
          : installedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssetPackImplCopyWith<$Res>
    implements $AssetPackCopyWith<$Res> {
  factory _$$AssetPackImplCopyWith(
          _$AssetPackImpl value, $Res Function(_$AssetPackImpl) then) =
      __$$AssetPackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String displayName,
      AssetTier tier,
      List<String> localPaths,
      String? storagePath,
      int estimatedSize,
      String? fortuneType,
      AssetPackStatus status,
      double downloadProgress,
      DateTime? lastAccessedAt,
      DateTime? installedAt});
}

/// @nodoc
class __$$AssetPackImplCopyWithImpl<$Res>
    extends _$AssetPackCopyWithImpl<$Res, _$AssetPackImpl>
    implements _$$AssetPackImplCopyWith<$Res> {
  __$$AssetPackImplCopyWithImpl(
      _$AssetPackImpl _value, $Res Function(_$AssetPackImpl) _then)
      : super(_value, _then);

  /// Create a copy of AssetPack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displayName = null,
    Object? tier = null,
    Object? localPaths = null,
    Object? storagePath = freezed,
    Object? estimatedSize = null,
    Object? fortuneType = freezed,
    Object? status = null,
    Object? downloadProgress = null,
    Object? lastAccessedAt = freezed,
    Object? installedAt = freezed,
  }) {
    return _then(_$AssetPackImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as AssetTier,
      localPaths: null == localPaths
          ? _value._localPaths
          : localPaths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      storagePath: freezed == storagePath
          ? _value.storagePath
          : storagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedSize: null == estimatedSize
          ? _value.estimatedSize
          : estimatedSize // ignore: cast_nullable_to_non_nullable
              as int,
      fortuneType: freezed == fortuneType
          ? _value.fortuneType
          : fortuneType // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AssetPackStatus,
      downloadProgress: null == downloadProgress
          ? _value.downloadProgress
          : downloadProgress // ignore: cast_nullable_to_non_nullable
              as double,
      lastAccessedAt: freezed == lastAccessedAt
          ? _value.lastAccessedAt
          : lastAccessedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      installedAt: freezed == installedAt
          ? _value.installedAt
          : installedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssetPackImpl implements _AssetPack {
  const _$AssetPackImpl(
      {required this.id,
      required this.displayName,
      required this.tier,
      final List<String> localPaths = const [],
      this.storagePath,
      this.estimatedSize = 0,
      this.fortuneType,
      this.status = AssetPackStatus.notInstalled,
      this.downloadProgress = 0.0,
      this.lastAccessedAt,
      this.installedAt})
      : _localPaths = localPaths;

  factory _$AssetPackImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssetPackImplFromJson(json);

  /// 팩 고유 ID (예: 'tarot_rider_waite', 'mbti_characters')
  @override
  final String id;

  /// 표시 이름 (예: 'Rider Waite 타로 덱')
  @override
  final String displayName;

  /// Tier 분류
  @override
  final AssetTier tier;

  /// 로컬 자산 경로 목록
  final List<String> _localPaths;

  /// 로컬 자산 경로 목록
  @override
  @JsonKey()
  List<String> get localPaths {
    if (_localPaths is EqualUnmodifiableListView) return _localPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_localPaths);
  }

  /// Supabase Storage 경로 (CDN)
  @override
  final String? storagePath;

  /// 예상 파일 크기 (bytes)
  @override
  @JsonKey()
  final int estimatedSize;

  /// 관련 운세 타입 (트리거)
  @override
  final String? fortuneType;

  /// 현재 상태
  @override
  @JsonKey()
  final AssetPackStatus status;

  /// 다운로드 진행률 (0.0 ~ 1.0)
  @override
  @JsonKey()
  final double downloadProgress;

  /// 마지막 접근 시간
  @override
  final DateTime? lastAccessedAt;

  /// 설치 시간
  @override
  final DateTime? installedAt;

  @override
  String toString() {
    return 'AssetPack(id: $id, displayName: $displayName, tier: $tier, localPaths: $localPaths, storagePath: $storagePath, estimatedSize: $estimatedSize, fortuneType: $fortuneType, status: $status, downloadProgress: $downloadProgress, lastAccessedAt: $lastAccessedAt, installedAt: $installedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssetPackImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            const DeepCollectionEquality()
                .equals(other._localPaths, _localPaths) &&
            (identical(other.storagePath, storagePath) ||
                other.storagePath == storagePath) &&
            (identical(other.estimatedSize, estimatedSize) ||
                other.estimatedSize == estimatedSize) &&
            (identical(other.fortuneType, fortuneType) ||
                other.fortuneType == fortuneType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.downloadProgress, downloadProgress) ||
                other.downloadProgress == downloadProgress) &&
            (identical(other.lastAccessedAt, lastAccessedAt) ||
                other.lastAccessedAt == lastAccessedAt) &&
            (identical(other.installedAt, installedAt) ||
                other.installedAt == installedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      displayName,
      tier,
      const DeepCollectionEquality().hash(_localPaths),
      storagePath,
      estimatedSize,
      fortuneType,
      status,
      downloadProgress,
      lastAccessedAt,
      installedAt);

  /// Create a copy of AssetPack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssetPackImplCopyWith<_$AssetPackImpl> get copyWith =>
      __$$AssetPackImplCopyWithImpl<_$AssetPackImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssetPackImplToJson(
      this,
    );
  }
}

abstract class _AssetPack implements AssetPack {
  const factory _AssetPack(
      {required final String id,
      required final String displayName,
      required final AssetTier tier,
      final List<String> localPaths,
      final String? storagePath,
      final int estimatedSize,
      final String? fortuneType,
      final AssetPackStatus status,
      final double downloadProgress,
      final DateTime? lastAccessedAt,
      final DateTime? installedAt}) = _$AssetPackImpl;

  factory _AssetPack.fromJson(Map<String, dynamic> json) =
      _$AssetPackImpl.fromJson;

  /// 팩 고유 ID (예: 'tarot_rider_waite', 'mbti_characters')
  @override
  String get id;

  /// 표시 이름 (예: 'Rider Waite 타로 덱')
  @override
  String get displayName;

  /// Tier 분류
  @override
  AssetTier get tier;

  /// 로컬 자산 경로 목록
  @override
  List<String> get localPaths;

  /// Supabase Storage 경로 (CDN)
  @override
  String? get storagePath;

  /// 예상 파일 크기 (bytes)
  @override
  int get estimatedSize;

  /// 관련 운세 타입 (트리거)
  @override
  String? get fortuneType;

  /// 현재 상태
  @override
  AssetPackStatus get status;

  /// 다운로드 진행률 (0.0 ~ 1.0)
  @override
  double get downloadProgress;

  /// 마지막 접근 시간
  @override
  DateTime? get lastAccessedAt;

  /// 설치 시간
  @override
  DateTime? get installedAt;

  /// Create a copy of AssetPack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssetPackImplCopyWith<_$AssetPackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DownloadProgress _$DownloadProgressFromJson(Map<String, dynamic> json) {
  return _DownloadProgress.fromJson(json);
}

/// @nodoc
mixin _$DownloadProgress {
  /// 팩 ID
  String get packId => throw _privateConstructorUsedError;

  /// 상태
  AssetPackStatus get status => throw _privateConstructorUsedError;

  /// 진행률 (0.0 ~ 1.0)
  double get progress => throw _privateConstructorUsedError;

  /// 다운로드된 바이트
  int get downloadedBytes => throw _privateConstructorUsedError;

  /// 전체 바이트
  int get totalBytes => throw _privateConstructorUsedError;

  /// 에러 메시지 (실패 시)
  String? get errorMessage => throw _privateConstructorUsedError;

  /// 남은 예상 시간 (초)
  int? get estimatedSecondsRemaining => throw _privateConstructorUsedError;

  /// Serializes this DownloadProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DownloadProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DownloadProgressCopyWith<DownloadProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadProgressCopyWith<$Res> {
  factory $DownloadProgressCopyWith(
          DownloadProgress value, $Res Function(DownloadProgress) then) =
      _$DownloadProgressCopyWithImpl<$Res, DownloadProgress>;
  @useResult
  $Res call(
      {String packId,
      AssetPackStatus status,
      double progress,
      int downloadedBytes,
      int totalBytes,
      String? errorMessage,
      int? estimatedSecondsRemaining});
}

/// @nodoc
class _$DownloadProgressCopyWithImpl<$Res, $Val extends DownloadProgress>
    implements $DownloadProgressCopyWith<$Res> {
  _$DownloadProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DownloadProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packId = null,
    Object? status = null,
    Object? progress = null,
    Object? downloadedBytes = null,
    Object? totalBytes = null,
    Object? errorMessage = freezed,
    Object? estimatedSecondsRemaining = freezed,
  }) {
    return _then(_value.copyWith(
      packId: null == packId
          ? _value.packId
          : packId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AssetPackStatus,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      downloadedBytes: null == downloadedBytes
          ? _value.downloadedBytes
          : downloadedBytes // ignore: cast_nullable_to_non_nullable
              as int,
      totalBytes: null == totalBytes
          ? _value.totalBytes
          : totalBytes // ignore: cast_nullable_to_non_nullable
              as int,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedSecondsRemaining: freezed == estimatedSecondsRemaining
          ? _value.estimatedSecondsRemaining
          : estimatedSecondsRemaining // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DownloadProgressImplCopyWith<$Res>
    implements $DownloadProgressCopyWith<$Res> {
  factory _$$DownloadProgressImplCopyWith(_$DownloadProgressImpl value,
          $Res Function(_$DownloadProgressImpl) then) =
      __$$DownloadProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String packId,
      AssetPackStatus status,
      double progress,
      int downloadedBytes,
      int totalBytes,
      String? errorMessage,
      int? estimatedSecondsRemaining});
}

/// @nodoc
class __$$DownloadProgressImplCopyWithImpl<$Res>
    extends _$DownloadProgressCopyWithImpl<$Res, _$DownloadProgressImpl>
    implements _$$DownloadProgressImplCopyWith<$Res> {
  __$$DownloadProgressImplCopyWithImpl(_$DownloadProgressImpl _value,
      $Res Function(_$DownloadProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of DownloadProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packId = null,
    Object? status = null,
    Object? progress = null,
    Object? downloadedBytes = null,
    Object? totalBytes = null,
    Object? errorMessage = freezed,
    Object? estimatedSecondsRemaining = freezed,
  }) {
    return _then(_$DownloadProgressImpl(
      packId: null == packId
          ? _value.packId
          : packId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AssetPackStatus,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      downloadedBytes: null == downloadedBytes
          ? _value.downloadedBytes
          : downloadedBytes // ignore: cast_nullable_to_non_nullable
              as int,
      totalBytes: null == totalBytes
          ? _value.totalBytes
          : totalBytes // ignore: cast_nullable_to_non_nullable
              as int,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedSecondsRemaining: freezed == estimatedSecondsRemaining
          ? _value.estimatedSecondsRemaining
          : estimatedSecondsRemaining // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DownloadProgressImpl implements _DownloadProgress {
  const _$DownloadProgressImpl(
      {required this.packId,
      required this.status,
      this.progress = 0.0,
      this.downloadedBytes = 0,
      this.totalBytes = 0,
      this.errorMessage,
      this.estimatedSecondsRemaining});

  factory _$DownloadProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$DownloadProgressImplFromJson(json);

  /// 팩 ID
  @override
  final String packId;

  /// 상태
  @override
  final AssetPackStatus status;

  /// 진행률 (0.0 ~ 1.0)
  @override
  @JsonKey()
  final double progress;

  /// 다운로드된 바이트
  @override
  @JsonKey()
  final int downloadedBytes;

  /// 전체 바이트
  @override
  @JsonKey()
  final int totalBytes;

  /// 에러 메시지 (실패 시)
  @override
  final String? errorMessage;

  /// 남은 예상 시간 (초)
  @override
  final int? estimatedSecondsRemaining;

  @override
  String toString() {
    return 'DownloadProgress(packId: $packId, status: $status, progress: $progress, downloadedBytes: $downloadedBytes, totalBytes: $totalBytes, errorMessage: $errorMessage, estimatedSecondsRemaining: $estimatedSecondsRemaining)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadProgressImpl &&
            (identical(other.packId, packId) || other.packId == packId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.downloadedBytes, downloadedBytes) ||
                other.downloadedBytes == downloadedBytes) &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.estimatedSecondsRemaining,
                    estimatedSecondsRemaining) ||
                other.estimatedSecondsRemaining == estimatedSecondsRemaining));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, packId, status, progress,
      downloadedBytes, totalBytes, errorMessage, estimatedSecondsRemaining);

  /// Create a copy of DownloadProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadProgressImplCopyWith<_$DownloadProgressImpl> get copyWith =>
      __$$DownloadProgressImplCopyWithImpl<_$DownloadProgressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DownloadProgressImplToJson(
      this,
    );
  }
}

abstract class _DownloadProgress implements DownloadProgress {
  const factory _DownloadProgress(
      {required final String packId,
      required final AssetPackStatus status,
      final double progress,
      final int downloadedBytes,
      final int totalBytes,
      final String? errorMessage,
      final int? estimatedSecondsRemaining}) = _$DownloadProgressImpl;

  factory _DownloadProgress.fromJson(Map<String, dynamic> json) =
      _$DownloadProgressImpl.fromJson;

  /// 팩 ID
  @override
  String get packId;

  /// 상태
  @override
  AssetPackStatus get status;

  /// 진행률 (0.0 ~ 1.0)
  @override
  double get progress;

  /// 다운로드된 바이트
  @override
  int get downloadedBytes;

  /// 전체 바이트
  @override
  int get totalBytes;

  /// 에러 메시지 (실패 시)
  @override
  String? get errorMessage;

  /// 남은 예상 시간 (초)
  @override
  int? get estimatedSecondsRemaining;

  /// Create a copy of DownloadProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadProgressImplCopyWith<_$DownloadProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StorageUsage _$StorageUsageFromJson(Map<String, dynamic> json) {
  return _StorageUsage.fromJson(json);
}

/// @nodoc
mixin _$StorageUsage {
  /// 번들 자산 크기
  int get bundledSize => throw _privateConstructorUsedError;

  /// 다운로드된 자산 크기
  int get downloadedSize => throw _privateConstructorUsedError;

  /// 캐시 크기
  int get cacheSize => throw _privateConstructorUsedError;

  /// 전체 사용량
  int get totalSize => throw _privateConstructorUsedError;

  /// 디바이스 가용 공간
  int get availableSpace => throw _privateConstructorUsedError;

  /// 팩별 사용량
  Map<String, int> get packSizes => throw _privateConstructorUsedError;

  /// Serializes this StorageUsage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StorageUsage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StorageUsageCopyWith<StorageUsage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StorageUsageCopyWith<$Res> {
  factory $StorageUsageCopyWith(
          StorageUsage value, $Res Function(StorageUsage) then) =
      _$StorageUsageCopyWithImpl<$Res, StorageUsage>;
  @useResult
  $Res call(
      {int bundledSize,
      int downloadedSize,
      int cacheSize,
      int totalSize,
      int availableSpace,
      Map<String, int> packSizes});
}

/// @nodoc
class _$StorageUsageCopyWithImpl<$Res, $Val extends StorageUsage>
    implements $StorageUsageCopyWith<$Res> {
  _$StorageUsageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StorageUsage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bundledSize = null,
    Object? downloadedSize = null,
    Object? cacheSize = null,
    Object? totalSize = null,
    Object? availableSpace = null,
    Object? packSizes = null,
  }) {
    return _then(_value.copyWith(
      bundledSize: null == bundledSize
          ? _value.bundledSize
          : bundledSize // ignore: cast_nullable_to_non_nullable
              as int,
      downloadedSize: null == downloadedSize
          ? _value.downloadedSize
          : downloadedSize // ignore: cast_nullable_to_non_nullable
              as int,
      cacheSize: null == cacheSize
          ? _value.cacheSize
          : cacheSize // ignore: cast_nullable_to_non_nullable
              as int,
      totalSize: null == totalSize
          ? _value.totalSize
          : totalSize // ignore: cast_nullable_to_non_nullable
              as int,
      availableSpace: null == availableSpace
          ? _value.availableSpace
          : availableSpace // ignore: cast_nullable_to_non_nullable
              as int,
      packSizes: null == packSizes
          ? _value.packSizes
          : packSizes // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StorageUsageImplCopyWith<$Res>
    implements $StorageUsageCopyWith<$Res> {
  factory _$$StorageUsageImplCopyWith(
          _$StorageUsageImpl value, $Res Function(_$StorageUsageImpl) then) =
      __$$StorageUsageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int bundledSize,
      int downloadedSize,
      int cacheSize,
      int totalSize,
      int availableSpace,
      Map<String, int> packSizes});
}

/// @nodoc
class __$$StorageUsageImplCopyWithImpl<$Res>
    extends _$StorageUsageCopyWithImpl<$Res, _$StorageUsageImpl>
    implements _$$StorageUsageImplCopyWith<$Res> {
  __$$StorageUsageImplCopyWithImpl(
      _$StorageUsageImpl _value, $Res Function(_$StorageUsageImpl) _then)
      : super(_value, _then);

  /// Create a copy of StorageUsage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bundledSize = null,
    Object? downloadedSize = null,
    Object? cacheSize = null,
    Object? totalSize = null,
    Object? availableSpace = null,
    Object? packSizes = null,
  }) {
    return _then(_$StorageUsageImpl(
      bundledSize: null == bundledSize
          ? _value.bundledSize
          : bundledSize // ignore: cast_nullable_to_non_nullable
              as int,
      downloadedSize: null == downloadedSize
          ? _value.downloadedSize
          : downloadedSize // ignore: cast_nullable_to_non_nullable
              as int,
      cacheSize: null == cacheSize
          ? _value.cacheSize
          : cacheSize // ignore: cast_nullable_to_non_nullable
              as int,
      totalSize: null == totalSize
          ? _value.totalSize
          : totalSize // ignore: cast_nullable_to_non_nullable
              as int,
      availableSpace: null == availableSpace
          ? _value.availableSpace
          : availableSpace // ignore: cast_nullable_to_non_nullable
              as int,
      packSizes: null == packSizes
          ? _value._packSizes
          : packSizes // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StorageUsageImpl implements _StorageUsage {
  const _$StorageUsageImpl(
      {this.bundledSize = 0,
      this.downloadedSize = 0,
      this.cacheSize = 0,
      this.totalSize = 0,
      this.availableSpace = 0,
      final Map<String, int> packSizes = const {}})
      : _packSizes = packSizes;

  factory _$StorageUsageImpl.fromJson(Map<String, dynamic> json) =>
      _$$StorageUsageImplFromJson(json);

  /// 번들 자산 크기
  @override
  @JsonKey()
  final int bundledSize;

  /// 다운로드된 자산 크기
  @override
  @JsonKey()
  final int downloadedSize;

  /// 캐시 크기
  @override
  @JsonKey()
  final int cacheSize;

  /// 전체 사용량
  @override
  @JsonKey()
  final int totalSize;

  /// 디바이스 가용 공간
  @override
  @JsonKey()
  final int availableSpace;

  /// 팩별 사용량
  final Map<String, int> _packSizes;

  /// 팩별 사용량
  @override
  @JsonKey()
  Map<String, int> get packSizes {
    if (_packSizes is EqualUnmodifiableMapView) return _packSizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_packSizes);
  }

  @override
  String toString() {
    return 'StorageUsage(bundledSize: $bundledSize, downloadedSize: $downloadedSize, cacheSize: $cacheSize, totalSize: $totalSize, availableSpace: $availableSpace, packSizes: $packSizes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StorageUsageImpl &&
            (identical(other.bundledSize, bundledSize) ||
                other.bundledSize == bundledSize) &&
            (identical(other.downloadedSize, downloadedSize) ||
                other.downloadedSize == downloadedSize) &&
            (identical(other.cacheSize, cacheSize) ||
                other.cacheSize == cacheSize) &&
            (identical(other.totalSize, totalSize) ||
                other.totalSize == totalSize) &&
            (identical(other.availableSpace, availableSpace) ||
                other.availableSpace == availableSpace) &&
            const DeepCollectionEquality()
                .equals(other._packSizes, _packSizes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      bundledSize,
      downloadedSize,
      cacheSize,
      totalSize,
      availableSpace,
      const DeepCollectionEquality().hash(_packSizes));

  /// Create a copy of StorageUsage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StorageUsageImplCopyWith<_$StorageUsageImpl> get copyWith =>
      __$$StorageUsageImplCopyWithImpl<_$StorageUsageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StorageUsageImplToJson(
      this,
    );
  }
}

abstract class _StorageUsage implements StorageUsage {
  const factory _StorageUsage(
      {final int bundledSize,
      final int downloadedSize,
      final int cacheSize,
      final int totalSize,
      final int availableSpace,
      final Map<String, int> packSizes}) = _$StorageUsageImpl;

  factory _StorageUsage.fromJson(Map<String, dynamic> json) =
      _$StorageUsageImpl.fromJson;

  /// 번들 자산 크기
  @override
  int get bundledSize;

  /// 다운로드된 자산 크기
  @override
  int get downloadedSize;

  /// 캐시 크기
  @override
  int get cacheSize;

  /// 전체 사용량
  @override
  int get totalSize;

  /// 디바이스 가용 공간
  @override
  int get availableSpace;

  /// 팩별 사용량
  @override
  Map<String, int> get packSizes;

  /// Create a copy of StorageUsage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StorageUsageImplCopyWith<_$StorageUsageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
