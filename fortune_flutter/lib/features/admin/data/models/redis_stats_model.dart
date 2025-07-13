import 'package:freezed_annotation/freezed_annotation.dart';

part 'redis_stats_model.freezed.dart';
part 'redis_stats_model.g.dart';

@freezed
class RedisStatsModel with _$RedisStatsModel {
  const factory RedisStatsModel({
    required RedisConnectionInfo connection,
    required RedisCacheStats cache,
    required RedisOperationStats operations,
    required RedisPerformanceStats performance,
    required Map<String, RateLimitInfo> rateLimits,
  }) = _RedisStatsModel;

  factory RedisStatsModel.fromJson(Map<String, dynamic> json) =>
      _$RedisStatsModelFromJson(json);
}

@freezed
class RedisConnectionInfo with _$RedisConnectionInfo {
  const factory RedisConnectionInfo({
    required bool connected,
    required String status,
    String? error,
    required int totalConnections,
    required int activeConnections,
  }) = _RedisConnectionInfo;

  factory RedisConnectionInfo.fromJson(Map<String, dynamic> json) =>
      _$RedisConnectionInfoFromJson(json);
}

@freezed
class RedisCacheStats with _$RedisCacheStats {
  const factory RedisCacheStats({
    required int hits,
    required int misses,
    required double hitRate,
    required int totalKeys,
    required String memoryUsage,
  }) = _RedisCacheStats;

  factory RedisCacheStats.fromJson(Map<String, dynamic> json) =>
      _$RedisCacheStatsFromJson(json);
}

@freezed
class RedisOperationStats with _$RedisOperationStats {
  const factory RedisOperationStats({
    required int reads,
    required int writes,
    required int deletes,
    required int errors,
    required int totalOperations,
  }) = _RedisOperationStats;

  factory RedisOperationStats.fromJson(Map<String, dynamic> json) =>
      _$RedisOperationStatsFromJson(json);
}

@freezed
class RedisPerformanceStats with _$RedisPerformanceStats {
  const factory RedisPerformanceStats({
    required double avgResponseTime,
    required double maxResponseTime,
    required double minResponseTime,
    required int slowQueries,
  }) = _RedisPerformanceStats;

  factory RedisPerformanceStats.fromJson(Map<String, dynamic> json) =>
      _$RedisPerformanceStatsFromJson(json);
}

@freezed
class RateLimitInfo with _$RateLimitInfo {
  const factory RateLimitInfo({
    required String tier,
    required int limit,
    required int used,
    required int remaining,
    required DateTime resetAt,
  }) = _RateLimitInfo;

  factory RateLimitInfo.fromJson(Map<String, dynamic> json) =>
      _$RateLimitInfoFromJson(json);
}