// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redis_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RedisStatsModelImpl _$$RedisStatsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$RedisStatsModelImpl(
      connection: RedisConnectionInfo.fromJson(
          json['connection'] as Map<String, dynamic>),
      cache: RedisCacheStats.fromJson(json['cache'] as Map<String, dynamic>),
      operations: RedisOperationStats.fromJson(
          json['operations'] as Map<String, dynamic>),
      performance: RedisPerformanceStats.fromJson(
          json['performance'] as Map<String, dynamic>),
      rateLimits: (json['rateLimits'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, RateLimitInfo.fromJson(e as Map<String, dynamic>))));

Map<String, dynamic> _$$RedisStatsModelImplToJson(
        _$RedisStatsModelImpl instance) =>
    <String, dynamic>{
      'connection': instance.connection,
      'cache': instance.cache,
      'operations': instance.operations,
      'performance': instance.performance,
      'rateLimits': instance.rateLimits};

_$RedisConnectionInfoImpl _$$RedisConnectionInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$RedisConnectionInfoImpl(
      connected: json['connected'] as bool,
      status: json['status'] as String,
      error: json['error'] as String?,
      totalConnections: (json['totalConnections'] as num).toInt(),
      activeConnections: (json['activeConnections'] as num).toInt());

Map<String, dynamic> _$$RedisConnectionInfoImplToJson(
        _$RedisConnectionInfoImpl instance) =>
    <String, dynamic>{
      'connected': instance.connected,
      'status': instance.status,
      'error': instance.error,
      'totalConnections': instance.totalConnections,
      'activeConnections': instance.activeConnections};

_$RedisCacheStatsImpl _$$RedisCacheStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$RedisCacheStatsImpl(
      hits: (json['hits'] as num).toInt(),
      misses: (json['misses'] as num).toInt(),
      hitRate: (json['hitRate'] as num).toDouble(),
      totalKeys: (json['totalKeys'] as num).toInt(),
      memoryUsage: json['memoryUsage'] as String);

Map<String, dynamic> _$$RedisCacheStatsImplToJson(
        _$RedisCacheStatsImpl instance) =>
    <String, dynamic>{
      'hits': instance.hits,
      'misses': instance.misses,
      'hitRate': instance.hitRate,
      'totalKeys': instance.totalKeys,
      'memoryUsage': instance.memoryUsage};

_$RedisOperationStatsImpl _$$RedisOperationStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$RedisOperationStatsImpl(
      reads: (json['reads'] as num).toInt(),
      writes: (json['writes'] as num).toInt(),
      deletes: (json['deletes'] as num).toInt(),
      errors: (json['errors'] as num).toInt(),
      totalOperations: (json['totalOperations'] as num).toInt());

Map<String, dynamic> _$$RedisOperationStatsImplToJson(
        _$RedisOperationStatsImpl instance) =>
    <String, dynamic>{
      'reads': instance.reads,
      'writes': instance.writes,
      'deletes': instance.deletes,
      'errors': instance.errors,
      'totalOperations': instance.totalOperations};

_$RedisPerformanceStatsImpl _$$RedisPerformanceStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$RedisPerformanceStatsImpl(
      avgResponseTime: (json['avgResponseTime'] as num).toDouble(),
      maxResponseTime: (json['maxResponseTime'] as num).toDouble(),
      minResponseTime: (json['minResponseTime'] as num).toDouble(),
      slowQueries: (json['slowQueries'] as num).toInt());

Map<String, dynamic> _$$RedisPerformanceStatsImplToJson(
        _$RedisPerformanceStatsImpl instance) =>
    <String, dynamic>{
      'avgResponseTime': instance.avgResponseTime,
      'maxResponseTime': instance.maxResponseTime,
      'minResponseTime': instance.minResponseTime,
      'slowQueries': instance.slowQueries};

_$RateLimitInfoImpl _$$RateLimitInfoImplFromJson(Map<String, dynamic> json) =>
    _$RateLimitInfoImpl(
      tier: json['tier'] as String,
      limit: (json['limit'] as num).toInt(),
      used: (json['used'] as num).toInt(),
      remaining: (json['remaining'] as num).toInt(),
      resetAt: DateTime.parse(json['resetAt'] as String));

Map<String, dynamic> _$$RateLimitInfoImplToJson(_$RateLimitInfoImpl instance) =>
    <String, dynamic>{
      'tier': instance.tier,
      'limit': instance.limit,
      'used': instance.used,
      'remaining': instance.remaining,
      'resetAt': instance.resetAt.toIso8601String()};
