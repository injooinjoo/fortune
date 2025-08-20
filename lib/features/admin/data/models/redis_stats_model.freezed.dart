// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'redis_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RedisStatsModel _$RedisStatsModelFromJson(Map<String, dynamic> json) {
  return _RedisStatsModel.fromJson(json);
}

/// @nodoc
mixin _$RedisStatsModel {
  RedisConnectionInfo get connection => throw _privateConstructorUsedError;
  RedisCacheStats get cache => throw _privateConstructorUsedError;
  RedisOperationStats get operations => throw _privateConstructorUsedError;
  RedisPerformanceStats get performance => throw _privateConstructorUsedError;
  Map<String, RateLimitInfo> get rateLimits =>
      throw _privateConstructorUsedError;

  /// Serializes this RedisStatsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RedisStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RedisStatsModelCopyWith<RedisStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RedisStatsModelCopyWith<$Res> {
  factory $RedisStatsModelCopyWith(
          RedisStatsModel value, $Res Function(RedisStatsModel) then) =
      _$RedisStatsModelCopyWithImpl<$Res, RedisStatsModel>;
  @useResult
  $Res call(
      {RedisConnectionInfo connection,
      RedisCacheStats cache,
      RedisOperationStats operations,
      RedisPerformanceStats performance,
      Map<String, RateLimitInfo> rateLimits});

  $RedisConnectionInfoCopyWith<$Res> get connection;
  $RedisCacheStatsCopyWith<$Res> get cache;
  $RedisOperationStatsCopyWith<$Res> get operations;
  $RedisPerformanceStatsCopyWith<$Res> get performance;
}

/// @nodoc
class _$RedisStatsModelCopyWithImpl<$Res, $Val extends RedisStatsModel>
    implements $RedisStatsModelCopyWith<$Res> {
  _$RedisStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RedisStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connection = null,
    Object? cache = null,
    Object? operations = null,
    Object? performance = null,
    Object? rateLimits = null,
  }) {
    return _then(_value.copyWith(
      connection: null == connection
          ? _value.connection
          : connection // ignore: cast_nullable_to_non_nullable
              as RedisConnectionInfo,
      cache: null == cache
          ? _value.cache
          : cache // ignore: cast_nullable_to_non_nullable
              as RedisCacheStats,
      operations: null == operations
          ? _value.operations
          : operations // ignore: cast_nullable_to_non_nullable
              as RedisOperationStats,
      performance: null == performance
          ? _value.performance
          : performance // ignore: cast_nullable_to_non_nullable
              as RedisPerformanceStats,
      rateLimits: null == rateLimits
          ? _value.rateLimits
          : rateLimits // ignore: cast_nullable_to_non_nullable
              as Map<String, RateLimitInfo>,
    ) as $Val);
  }

  /// Create a copy of RedisStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RedisConnectionInfoCopyWith<$Res> get connection {
    return $RedisConnectionInfoCopyWith<$Res>(_value.connection, (value) {
      return _then(_value.copyWith(connection: value) as $Val);
    });
  }

  /// Create a copy of RedisStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RedisCacheStatsCopyWith<$Res> get cache {
    return $RedisCacheStatsCopyWith<$Res>(_value.cache, (value) {
      return _then(_value.copyWith(cache: value) as $Val);
    });
  }

  /// Create a copy of RedisStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RedisOperationStatsCopyWith<$Res> get operations {
    return $RedisOperationStatsCopyWith<$Res>(_value.operations, (value) {
      return _then(_value.copyWith(operations: value) as $Val);
    });
  }

  /// Create a copy of RedisStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RedisPerformanceStatsCopyWith<$Res> get performance {
    return $RedisPerformanceStatsCopyWith<$Res>(_value.performance, (value) {
      return _then(_value.copyWith(performance: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RedisStatsModelImplCopyWith<$Res>
    implements $RedisStatsModelCopyWith<$Res> {
  factory _$$RedisStatsModelImplCopyWith(_$RedisStatsModelImpl value,
          $Res Function(_$RedisStatsModelImpl) then) =
      __$$RedisStatsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {RedisConnectionInfo connection,
      RedisCacheStats cache,
      RedisOperationStats operations,
      RedisPerformanceStats performance,
      Map<String, RateLimitInfo> rateLimits});

  @override
  $RedisConnectionInfoCopyWith<$Res> get connection;
  @override
  $RedisCacheStatsCopyWith<$Res> get cache;
  @override
  $RedisOperationStatsCopyWith<$Res> get operations;
  @override
  $RedisPerformanceStatsCopyWith<$Res> get performance;
}

/// @nodoc
class __$$RedisStatsModelImplCopyWithImpl<$Res>
    extends _$RedisStatsModelCopyWithImpl<$Res, _$RedisStatsModelImpl>
    implements _$$RedisStatsModelImplCopyWith<$Res> {
  __$$RedisStatsModelImplCopyWithImpl(
      _$RedisStatsModelImpl _value, $Res Function(_$RedisStatsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of RedisStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connection = null,
    Object? cache = null,
    Object? operations = null,
    Object? performance = null,
    Object? rateLimits = null,
  }) {
    return _then(_$RedisStatsModelImpl(
      connection: null == connection
          ? _value.connection
          : connection // ignore: cast_nullable_to_non_nullable
              as RedisConnectionInfo,
      cache: null == cache
          ? _value.cache
          : cache // ignore: cast_nullable_to_non_nullable
              as RedisCacheStats,
      operations: null == operations
          ? _value.operations
          : operations // ignore: cast_nullable_to_non_nullable
              as RedisOperationStats,
      performance: null == performance
          ? _value.performance
          : performance // ignore: cast_nullable_to_non_nullable
              as RedisPerformanceStats,
      rateLimits: null == rateLimits
          ? _value._rateLimits
          : rateLimits // ignore: cast_nullable_to_non_nullable
              as Map<String, RateLimitInfo>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RedisStatsModelImpl implements _RedisStatsModel {
  const _$RedisStatsModelImpl(
      {required this.connection,
      required this.cache,
      required this.operations,
      required this.performance,
      required final Map<String, RateLimitInfo> rateLimits})
      : _rateLimits = rateLimits;

  factory _$RedisStatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RedisStatsModelImplFromJson(json);

  @override
  final RedisConnectionInfo connection;
  @override
  final RedisCacheStats cache;
  @override
  final RedisOperationStats operations;
  @override
  final RedisPerformanceStats performance;
  final Map<String, RateLimitInfo> _rateLimits;
  @override
  Map<String, RateLimitInfo> get rateLimits {
    if (_rateLimits is EqualUnmodifiableMapView) return _rateLimits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rateLimits);
  }

  @override
  String toString() {
    return 'RedisStatsModel(connection: $connection, cache: $cache, operations: $operations, performance: $performance, rateLimits: $rateLimits)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RedisStatsModelImpl &&
            (identical(other.connection, connection) ||
                other.connection == connection) &&
            (identical(other.cache, cache) || other.cache == cache) &&
            (identical(other.operations, operations) ||
                other.operations == operations) &&
            (identical(other.performance, performance) ||
                other.performance == performance) &&
            const DeepCollectionEquality()
                .equals(other._rateLimits, _rateLimits));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, connection, cache, operations,
      performance, const DeepCollectionEquality().hash(_rateLimits));

  /// Create a copy of RedisStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RedisStatsModelImplCopyWith<_$RedisStatsModelImpl> get copyWith =>
      __$$RedisStatsModelImplCopyWithImpl<_$RedisStatsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RedisStatsModelImplToJson(
      this,
    );
  }
}

abstract class _RedisStatsModel implements RedisStatsModel {
  const factory _RedisStatsModel(
          {required final RedisConnectionInfo connection,
          required final RedisCacheStats cache,
          required final RedisOperationStats operations,
          required final RedisPerformanceStats performance,
          required final Map<String, RateLimitInfo> rateLimits}) =
      _$RedisStatsModelImpl;

  factory _RedisStatsModel.fromJson(Map<String, dynamic> json) =
      _$RedisStatsModelImpl.fromJson;

  @override
  RedisConnectionInfo get connection;
  @override
  RedisCacheStats get cache;
  @override
  RedisOperationStats get operations;
  @override
  RedisPerformanceStats get performance;
  @override
  Map<String, RateLimitInfo> get rateLimits;

  /// Create a copy of RedisStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RedisStatsModelImplCopyWith<_$RedisStatsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RedisConnectionInfo _$RedisConnectionInfoFromJson(Map<String, dynamic> json) {
  return _RedisConnectionInfo.fromJson(json);
}

/// @nodoc
mixin _$RedisConnectionInfo {
  bool get connected => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  int get totalConnections => throw _privateConstructorUsedError;
  int get activeConnections => throw _privateConstructorUsedError;

  /// Serializes this RedisConnectionInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RedisConnectionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RedisConnectionInfoCopyWith<RedisConnectionInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RedisConnectionInfoCopyWith<$Res> {
  factory $RedisConnectionInfoCopyWith(
          RedisConnectionInfo value, $Res Function(RedisConnectionInfo) then) =
      _$RedisConnectionInfoCopyWithImpl<$Res, RedisConnectionInfo>;
  @useResult
  $Res call(
      {bool connected,
      String status,
      String? error,
      int totalConnections,
      int activeConnections});
}

/// @nodoc
class _$RedisConnectionInfoCopyWithImpl<$Res, $Val extends RedisConnectionInfo>
    implements $RedisConnectionInfoCopyWith<$Res> {
  _$RedisConnectionInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RedisConnectionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connected = null,
    Object? status = null,
    Object? error = freezed,
    Object? totalConnections = null,
    Object? activeConnections = null,
  }) {
    return _then(_value.copyWith(
      connected: null == connected
          ? _value.connected
          : connected // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      totalConnections: null == totalConnections
          ? _value.totalConnections
          : totalConnections // ignore: cast_nullable_to_non_nullable
              as int,
      activeConnections: null == activeConnections
          ? _value.activeConnections
          : activeConnections // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RedisConnectionInfoImplCopyWith<$Res>
    implements $RedisConnectionInfoCopyWith<$Res> {
  factory _$$RedisConnectionInfoImplCopyWith(_$RedisConnectionInfoImpl value,
          $Res Function(_$RedisConnectionInfoImpl) then) =
      __$$RedisConnectionInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool connected,
      String status,
      String? error,
      int totalConnections,
      int activeConnections});
}

/// @nodoc
class __$$RedisConnectionInfoImplCopyWithImpl<$Res>
    extends _$RedisConnectionInfoCopyWithImpl<$Res, _$RedisConnectionInfoImpl>
    implements _$$RedisConnectionInfoImplCopyWith<$Res> {
  __$$RedisConnectionInfoImplCopyWithImpl(_$RedisConnectionInfoImpl _value,
      $Res Function(_$RedisConnectionInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of RedisConnectionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connected = null,
    Object? status = null,
    Object? error = freezed,
    Object? totalConnections = null,
    Object? activeConnections = null,
  }) {
    return _then(_$RedisConnectionInfoImpl(
      connected: null == connected
          ? _value.connected
          : connected // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      totalConnections: null == totalConnections
          ? _value.totalConnections
          : totalConnections // ignore: cast_nullable_to_non_nullable
              as int,
      activeConnections: null == activeConnections
          ? _value.activeConnections
          : activeConnections // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RedisConnectionInfoImpl implements _RedisConnectionInfo {
  const _$RedisConnectionInfoImpl(
      {required this.connected,
      required this.status,
      this.error,
      required this.totalConnections,
      required this.activeConnections});

  factory _$RedisConnectionInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RedisConnectionInfoImplFromJson(json);

  @override
  final bool connected;
  @override
  final String status;
  @override
  final String? error;
  @override
  final int totalConnections;
  @override
  final int activeConnections;

  @override
  String toString() {
    return 'RedisConnectionInfo(connected: $connected, status: $status, error: $error, totalConnections: $totalConnections, activeConnections: $activeConnections)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RedisConnectionInfoImpl &&
            (identical(other.connected, connected) ||
                other.connected == connected) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.totalConnections, totalConnections) ||
                other.totalConnections == totalConnections) &&
            (identical(other.activeConnections, activeConnections) ||
                other.activeConnections == activeConnections));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, connected, status, error,
      totalConnections, activeConnections);

  /// Create a copy of RedisConnectionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RedisConnectionInfoImplCopyWith<_$RedisConnectionInfoImpl> get copyWith =>
      __$$RedisConnectionInfoImplCopyWithImpl<_$RedisConnectionInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RedisConnectionInfoImplToJson(
      this,
    );
  }
}

abstract class _RedisConnectionInfo implements RedisConnectionInfo {
  const factory _RedisConnectionInfo(
      {required final bool connected,
      required final String status,
      final String? error,
      required final int totalConnections,
      required final int activeConnections}) = _$RedisConnectionInfoImpl;

  factory _RedisConnectionInfo.fromJson(Map<String, dynamic> json) =
      _$RedisConnectionInfoImpl.fromJson;

  @override
  bool get connected;
  @override
  String get status;
  @override
  String? get error;
  @override
  int get totalConnections;
  @override
  int get activeConnections;

  /// Create a copy of RedisConnectionInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RedisConnectionInfoImplCopyWith<_$RedisConnectionInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RedisCacheStats _$RedisCacheStatsFromJson(Map<String, dynamic> json) {
  return _RedisCacheStats.fromJson(json);
}

/// @nodoc
mixin _$RedisCacheStats {
  int get hits => throw _privateConstructorUsedError;
  int get misses => throw _privateConstructorUsedError;
  double get hitRate => throw _privateConstructorUsedError;
  int get totalKeys => throw _privateConstructorUsedError;
  String get memoryUsage => throw _privateConstructorUsedError;

  /// Serializes this RedisCacheStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RedisCacheStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RedisCacheStatsCopyWith<RedisCacheStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RedisCacheStatsCopyWith<$Res> {
  factory $RedisCacheStatsCopyWith(
          RedisCacheStats value, $Res Function(RedisCacheStats) then) =
      _$RedisCacheStatsCopyWithImpl<$Res, RedisCacheStats>;
  @useResult
  $Res call(
      {int hits,
      int misses,
      double hitRate,
      int totalKeys,
      String memoryUsage});
}

/// @nodoc
class _$RedisCacheStatsCopyWithImpl<$Res, $Val extends RedisCacheStats>
    implements $RedisCacheStatsCopyWith<$Res> {
  _$RedisCacheStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RedisCacheStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hits = null,
    Object? misses = null,
    Object? hitRate = null,
    Object? totalKeys = null,
    Object? memoryUsage = null,
  }) {
    return _then(_value.copyWith(
      hits: null == hits
          ? _value.hits
          : hits // ignore: cast_nullable_to_non_nullable
              as int,
      misses: null == misses
          ? _value.misses
          : misses // ignore: cast_nullable_to_non_nullable
              as int,
      hitRate: null == hitRate
          ? _value.hitRate
          : hitRate // ignore: cast_nullable_to_non_nullable
              as double,
      totalKeys: null == totalKeys
          ? _value.totalKeys
          : totalKeys // ignore: cast_nullable_to_non_nullable
              as int,
      memoryUsage: null == memoryUsage
          ? _value.memoryUsage
          : memoryUsage // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RedisCacheStatsImplCopyWith<$Res>
    implements $RedisCacheStatsCopyWith<$Res> {
  factory _$$RedisCacheStatsImplCopyWith(_$RedisCacheStatsImpl value,
          $Res Function(_$RedisCacheStatsImpl) then) =
      __$$RedisCacheStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int hits,
      int misses,
      double hitRate,
      int totalKeys,
      String memoryUsage});
}

/// @nodoc
class __$$RedisCacheStatsImplCopyWithImpl<$Res>
    extends _$RedisCacheStatsCopyWithImpl<$Res, _$RedisCacheStatsImpl>
    implements _$$RedisCacheStatsImplCopyWith<$Res> {
  __$$RedisCacheStatsImplCopyWithImpl(
      _$RedisCacheStatsImpl _value, $Res Function(_$RedisCacheStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of RedisCacheStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hits = null,
    Object? misses = null,
    Object? hitRate = null,
    Object? totalKeys = null,
    Object? memoryUsage = null,
  }) {
    return _then(_$RedisCacheStatsImpl(
      hits: null == hits
          ? _value.hits
          : hits // ignore: cast_nullable_to_non_nullable
              as int,
      misses: null == misses
          ? _value.misses
          : misses // ignore: cast_nullable_to_non_nullable
              as int,
      hitRate: null == hitRate
          ? _value.hitRate
          : hitRate // ignore: cast_nullable_to_non_nullable
              as double,
      totalKeys: null == totalKeys
          ? _value.totalKeys
          : totalKeys // ignore: cast_nullable_to_non_nullable
              as int,
      memoryUsage: null == memoryUsage
          ? _value.memoryUsage
          : memoryUsage // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RedisCacheStatsImpl implements _RedisCacheStats {
  const _$RedisCacheStatsImpl(
      {required this.hits,
      required this.misses,
      required this.hitRate,
      required this.totalKeys,
      required this.memoryUsage});

  factory _$RedisCacheStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RedisCacheStatsImplFromJson(json);

  @override
  final int hits;
  @override
  final int misses;
  @override
  final double hitRate;
  @override
  final int totalKeys;
  @override
  final String memoryUsage;

  @override
  String toString() {
    return 'RedisCacheStats(hits: $hits, misses: $misses, hitRate: $hitRate, totalKeys: $totalKeys, memoryUsage: $memoryUsage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RedisCacheStatsImpl &&
            (identical(other.hits, hits) || other.hits == hits) &&
            (identical(other.misses, misses) || other.misses == misses) &&
            (identical(other.hitRate, hitRate) || other.hitRate == hitRate) &&
            (identical(other.totalKeys, totalKeys) ||
                other.totalKeys == totalKeys) &&
            (identical(other.memoryUsage, memoryUsage) ||
                other.memoryUsage == memoryUsage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, hits, misses, hitRate, totalKeys, memoryUsage);

  /// Create a copy of RedisCacheStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RedisCacheStatsImplCopyWith<_$RedisCacheStatsImpl> get copyWith =>
      __$$RedisCacheStatsImplCopyWithImpl<_$RedisCacheStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RedisCacheStatsImplToJson(
      this,
    );
  }
}

abstract class _RedisCacheStats implements RedisCacheStats {
  const factory _RedisCacheStats(
      {required final int hits,
      required final int misses,
      required final double hitRate,
      required final int totalKeys,
      required final String memoryUsage}) = _$RedisCacheStatsImpl;

  factory _RedisCacheStats.fromJson(Map<String, dynamic> json) =
      _$RedisCacheStatsImpl.fromJson;

  @override
  int get hits;
  @override
  int get misses;
  @override
  double get hitRate;
  @override
  int get totalKeys;
  @override
  String get memoryUsage;

  /// Create a copy of RedisCacheStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RedisCacheStatsImplCopyWith<_$RedisCacheStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RedisOperationStats _$RedisOperationStatsFromJson(Map<String, dynamic> json) {
  return _RedisOperationStats.fromJson(json);
}

/// @nodoc
mixin _$RedisOperationStats {
  int get reads => throw _privateConstructorUsedError;
  int get writes => throw _privateConstructorUsedError;
  int get deletes => throw _privateConstructorUsedError;
  int get errors => throw _privateConstructorUsedError;
  int get totalOperations => throw _privateConstructorUsedError;

  /// Serializes this RedisOperationStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RedisOperationStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RedisOperationStatsCopyWith<RedisOperationStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RedisOperationStatsCopyWith<$Res> {
  factory $RedisOperationStatsCopyWith(
          RedisOperationStats value, $Res Function(RedisOperationStats) then) =
      _$RedisOperationStatsCopyWithImpl<$Res, RedisOperationStats>;
  @useResult
  $Res call(
      {int reads, int writes, int deletes, int errors, int totalOperations});
}

/// @nodoc
class _$RedisOperationStatsCopyWithImpl<$Res, $Val extends RedisOperationStats>
    implements $RedisOperationStatsCopyWith<$Res> {
  _$RedisOperationStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RedisOperationStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reads = null,
    Object? writes = null,
    Object? deletes = null,
    Object? errors = null,
    Object? totalOperations = null,
  }) {
    return _then(_value.copyWith(
      reads: null == reads
          ? _value.reads
          : reads // ignore: cast_nullable_to_non_nullable
              as int,
      writes: null == writes
          ? _value.writes
          : writes // ignore: cast_nullable_to_non_nullable
              as int,
      deletes: null == deletes
          ? _value.deletes
          : deletes // ignore: cast_nullable_to_non_nullable
              as int,
      errors: null == errors
          ? _value.errors
          : errors // ignore: cast_nullable_to_non_nullable
              as int,
      totalOperations: null == totalOperations
          ? _value.totalOperations
          : totalOperations // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RedisOperationStatsImplCopyWith<$Res>
    implements $RedisOperationStatsCopyWith<$Res> {
  factory _$$RedisOperationStatsImplCopyWith(_$RedisOperationStatsImpl value,
          $Res Function(_$RedisOperationStatsImpl) then) =
      __$$RedisOperationStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int reads, int writes, int deletes, int errors, int totalOperations});
}

/// @nodoc
class __$$RedisOperationStatsImplCopyWithImpl<$Res>
    extends _$RedisOperationStatsCopyWithImpl<$Res, _$RedisOperationStatsImpl>
    implements _$$RedisOperationStatsImplCopyWith<$Res> {
  __$$RedisOperationStatsImplCopyWithImpl(_$RedisOperationStatsImpl _value,
      $Res Function(_$RedisOperationStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of RedisOperationStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reads = null,
    Object? writes = null,
    Object? deletes = null,
    Object? errors = null,
    Object? totalOperations = null,
  }) {
    return _then(_$RedisOperationStatsImpl(
      reads: null == reads
          ? _value.reads
          : reads // ignore: cast_nullable_to_non_nullable
              as int,
      writes: null == writes
          ? _value.writes
          : writes // ignore: cast_nullable_to_non_nullable
              as int,
      deletes: null == deletes
          ? _value.deletes
          : deletes // ignore: cast_nullable_to_non_nullable
              as int,
      errors: null == errors
          ? _value.errors
          : errors // ignore: cast_nullable_to_non_nullable
              as int,
      totalOperations: null == totalOperations
          ? _value.totalOperations
          : totalOperations // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RedisOperationStatsImpl implements _RedisOperationStats {
  const _$RedisOperationStatsImpl(
      {required this.reads,
      required this.writes,
      required this.deletes,
      required this.errors,
      required this.totalOperations});

  factory _$RedisOperationStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RedisOperationStatsImplFromJson(json);

  @override
  final int reads;
  @override
  final int writes;
  @override
  final int deletes;
  @override
  final int errors;
  @override
  final int totalOperations;

  @override
  String toString() {
    return 'RedisOperationStats(reads: $reads, writes: $writes, deletes: $deletes, errors: $errors, totalOperations: $totalOperations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RedisOperationStatsImpl &&
            (identical(other.reads, reads) || other.reads == reads) &&
            (identical(other.writes, writes) || other.writes == writes) &&
            (identical(other.deletes, deletes) || other.deletes == deletes) &&
            (identical(other.errors, errors) || other.errors == errors) &&
            (identical(other.totalOperations, totalOperations) ||
                other.totalOperations == totalOperations));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, reads, writes, deletes, errors, totalOperations);

  /// Create a copy of RedisOperationStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RedisOperationStatsImplCopyWith<_$RedisOperationStatsImpl> get copyWith =>
      __$$RedisOperationStatsImplCopyWithImpl<_$RedisOperationStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RedisOperationStatsImplToJson(
      this,
    );
  }
}

abstract class _RedisOperationStats implements RedisOperationStats {
  const factory _RedisOperationStats(
      {required final int reads,
      required final int writes,
      required final int deletes,
      required final int errors,
      required final int totalOperations}) = _$RedisOperationStatsImpl;

  factory _RedisOperationStats.fromJson(Map<String, dynamic> json) =
      _$RedisOperationStatsImpl.fromJson;

  @override
  int get reads;
  @override
  int get writes;
  @override
  int get deletes;
  @override
  int get errors;
  @override
  int get totalOperations;

  /// Create a copy of RedisOperationStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RedisOperationStatsImplCopyWith<_$RedisOperationStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RedisPerformanceStats _$RedisPerformanceStatsFromJson(
    Map<String, dynamic> json) {
  return _RedisPerformanceStats.fromJson(json);
}

/// @nodoc
mixin _$RedisPerformanceStats {
  double get avgResponseTime => throw _privateConstructorUsedError;
  double get maxResponseTime => throw _privateConstructorUsedError;
  double get minResponseTime => throw _privateConstructorUsedError;
  int get slowQueries => throw _privateConstructorUsedError;

  /// Serializes this RedisPerformanceStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RedisPerformanceStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RedisPerformanceStatsCopyWith<RedisPerformanceStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RedisPerformanceStatsCopyWith<$Res> {
  factory $RedisPerformanceStatsCopyWith(RedisPerformanceStats value,
          $Res Function(RedisPerformanceStats) then) =
      _$RedisPerformanceStatsCopyWithImpl<$Res, RedisPerformanceStats>;
  @useResult
  $Res call(
      {double avgResponseTime,
      double maxResponseTime,
      double minResponseTime,
      int slowQueries});
}

/// @nodoc
class _$RedisPerformanceStatsCopyWithImpl<$Res,
        $Val extends RedisPerformanceStats>
    implements $RedisPerformanceStatsCopyWith<$Res> {
  _$RedisPerformanceStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RedisPerformanceStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avgResponseTime = null,
    Object? maxResponseTime = null,
    Object? minResponseTime = null,
    Object? slowQueries = null,
  }) {
    return _then(_value.copyWith(
      avgResponseTime: null == avgResponseTime
          ? _value.avgResponseTime
          : avgResponseTime // ignore: cast_nullable_to_non_nullable
              as double,
      maxResponseTime: null == maxResponseTime
          ? _value.maxResponseTime
          : maxResponseTime // ignore: cast_nullable_to_non_nullable
              as double,
      minResponseTime: null == minResponseTime
          ? _value.minResponseTime
          : minResponseTime // ignore: cast_nullable_to_non_nullable
              as double,
      slowQueries: null == slowQueries
          ? _value.slowQueries
          : slowQueries // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RedisPerformanceStatsImplCopyWith<$Res>
    implements $RedisPerformanceStatsCopyWith<$Res> {
  factory _$$RedisPerformanceStatsImplCopyWith(
          _$RedisPerformanceStatsImpl value,
          $Res Function(_$RedisPerformanceStatsImpl) then) =
      __$$RedisPerformanceStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double avgResponseTime,
      double maxResponseTime,
      double minResponseTime,
      int slowQueries});
}

/// @nodoc
class __$$RedisPerformanceStatsImplCopyWithImpl<$Res>
    extends _$RedisPerformanceStatsCopyWithImpl<$Res,
        _$RedisPerformanceStatsImpl>
    implements _$$RedisPerformanceStatsImplCopyWith<$Res> {
  __$$RedisPerformanceStatsImplCopyWithImpl(_$RedisPerformanceStatsImpl _value,
      $Res Function(_$RedisPerformanceStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of RedisPerformanceStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avgResponseTime = null,
    Object? maxResponseTime = null,
    Object? minResponseTime = null,
    Object? slowQueries = null,
  }) {
    return _then(_$RedisPerformanceStatsImpl(
      avgResponseTime: null == avgResponseTime
          ? _value.avgResponseTime
          : avgResponseTime // ignore: cast_nullable_to_non_nullable
              as double,
      maxResponseTime: null == maxResponseTime
          ? _value.maxResponseTime
          : maxResponseTime // ignore: cast_nullable_to_non_nullable
              as double,
      minResponseTime: null == minResponseTime
          ? _value.minResponseTime
          : minResponseTime // ignore: cast_nullable_to_non_nullable
              as double,
      slowQueries: null == slowQueries
          ? _value.slowQueries
          : slowQueries // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RedisPerformanceStatsImpl implements _RedisPerformanceStats {
  const _$RedisPerformanceStatsImpl(
      {required this.avgResponseTime,
      required this.maxResponseTime,
      required this.minResponseTime,
      required this.slowQueries});

  factory _$RedisPerformanceStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RedisPerformanceStatsImplFromJson(json);

  @override
  final double avgResponseTime;
  @override
  final double maxResponseTime;
  @override
  final double minResponseTime;
  @override
  final int slowQueries;

  @override
  String toString() {
    return 'RedisPerformanceStats(avgResponseTime: $avgResponseTime, maxResponseTime: $maxResponseTime, minResponseTime: $minResponseTime, slowQueries: $slowQueries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RedisPerformanceStatsImpl &&
            (identical(other.avgResponseTime, avgResponseTime) ||
                other.avgResponseTime == avgResponseTime) &&
            (identical(other.maxResponseTime, maxResponseTime) ||
                other.maxResponseTime == maxResponseTime) &&
            (identical(other.minResponseTime, minResponseTime) ||
                other.minResponseTime == minResponseTime) &&
            (identical(other.slowQueries, slowQueries) ||
                other.slowQueries == slowQueries));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, avgResponseTime, maxResponseTime,
      minResponseTime, slowQueries);

  /// Create a copy of RedisPerformanceStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RedisPerformanceStatsImplCopyWith<_$RedisPerformanceStatsImpl>
      get copyWith => __$$RedisPerformanceStatsImplCopyWithImpl<
          _$RedisPerformanceStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RedisPerformanceStatsImplToJson(
      this,
    );
  }
}

abstract class _RedisPerformanceStats implements RedisPerformanceStats {
  const factory _RedisPerformanceStats(
      {required final double avgResponseTime,
      required final double maxResponseTime,
      required final double minResponseTime,
      required final int slowQueries}) = _$RedisPerformanceStatsImpl;

  factory _RedisPerformanceStats.fromJson(Map<String, dynamic> json) =
      _$RedisPerformanceStatsImpl.fromJson;

  @override
  double get avgResponseTime;
  @override
  double get maxResponseTime;
  @override
  double get minResponseTime;
  @override
  int get slowQueries;

  /// Create a copy of RedisPerformanceStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RedisPerformanceStatsImplCopyWith<_$RedisPerformanceStatsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

RateLimitInfo _$RateLimitInfoFromJson(Map<String, dynamic> json) {
  return _RateLimitInfo.fromJson(json);
}

/// @nodoc
mixin _$RateLimitInfo {
  String get tier => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  int get used => throw _privateConstructorUsedError;
  int get remaining => throw _privateConstructorUsedError;
  DateTime get resetAt => throw _privateConstructorUsedError;

  /// Serializes this RateLimitInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RateLimitInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RateLimitInfoCopyWith<RateLimitInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RateLimitInfoCopyWith<$Res> {
  factory $RateLimitInfoCopyWith(
          RateLimitInfo value, $Res Function(RateLimitInfo) then) =
      _$RateLimitInfoCopyWithImpl<$Res, RateLimitInfo>;
  @useResult
  $Res call(
      {String tier, int limit, int used, int remaining, DateTime resetAt});
}

/// @nodoc
class _$RateLimitInfoCopyWithImpl<$Res, $Val extends RateLimitInfo>
    implements $RateLimitInfoCopyWith<$Res> {
  _$RateLimitInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RateLimitInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tier = null,
    Object? limit = null,
    Object? used = null,
    Object? remaining = null,
    Object? resetAt = null,
  }) {
    return _then(_value.copyWith(
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      used: null == used
          ? _value.used
          : used // ignore: cast_nullable_to_non_nullable
              as int,
      remaining: null == remaining
          ? _value.remaining
          : remaining // ignore: cast_nullable_to_non_nullable
              as int,
      resetAt: null == resetAt
          ? _value.resetAt
          : resetAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RateLimitInfoImplCopyWith<$Res>
    implements $RateLimitInfoCopyWith<$Res> {
  factory _$$RateLimitInfoImplCopyWith(
          _$RateLimitInfoImpl value, $Res Function(_$RateLimitInfoImpl) then) =
      __$$RateLimitInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String tier, int limit, int used, int remaining, DateTime resetAt});
}

/// @nodoc
class __$$RateLimitInfoImplCopyWithImpl<$Res>
    extends _$RateLimitInfoCopyWithImpl<$Res, _$RateLimitInfoImpl>
    implements _$$RateLimitInfoImplCopyWith<$Res> {
  __$$RateLimitInfoImplCopyWithImpl(
      _$RateLimitInfoImpl _value, $Res Function(_$RateLimitInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of RateLimitInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tier = null,
    Object? limit = null,
    Object? used = null,
    Object? remaining = null,
    Object? resetAt = null,
  }) {
    return _then(_$RateLimitInfoImpl(
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      used: null == used
          ? _value.used
          : used // ignore: cast_nullable_to_non_nullable
              as int,
      remaining: null == remaining
          ? _value.remaining
          : remaining // ignore: cast_nullable_to_non_nullable
              as int,
      resetAt: null == resetAt
          ? _value.resetAt
          : resetAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RateLimitInfoImpl implements _RateLimitInfo {
  const _$RateLimitInfoImpl(
      {required this.tier,
      required this.limit,
      required this.used,
      required this.remaining,
      required this.resetAt});

  factory _$RateLimitInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RateLimitInfoImplFromJson(json);

  @override
  final String tier;
  @override
  final int limit;
  @override
  final int used;
  @override
  final int remaining;
  @override
  final DateTime resetAt;

  @override
  String toString() {
    return 'RateLimitInfo(tier: $tier, limit: $limit, used: $used, remaining: $remaining, resetAt: $resetAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RateLimitInfoImpl &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.used, used) || other.used == used) &&
            (identical(other.remaining, remaining) ||
                other.remaining == remaining) &&
            (identical(other.resetAt, resetAt) || other.resetAt == resetAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, tier, limit, used, remaining, resetAt);

  /// Create a copy of RateLimitInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RateLimitInfoImplCopyWith<_$RateLimitInfoImpl> get copyWith =>
      __$$RateLimitInfoImplCopyWithImpl<_$RateLimitInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RateLimitInfoImplToJson(
      this,
    );
  }
}

abstract class _RateLimitInfo implements RateLimitInfo {
  const factory _RateLimitInfo(
      {required final String tier,
      required final int limit,
      required final int used,
      required final int remaining,
      required final DateTime resetAt}) = _$RateLimitInfoImpl;

  factory _RateLimitInfo.fromJson(Map<String, dynamic> json) =
      _$RateLimitInfoImpl.fromJson;

  @override
  String get tier;
  @override
  int get limit;
  @override
  int get used;
  @override
  int get remaining;
  @override
  DateTime get resetAt;

  /// Create a copy of RateLimitInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RateLimitInfoImplCopyWith<_$RateLimitInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
