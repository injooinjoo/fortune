import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/presentation/providers/providers.dart';
import 'package:fortune/features/admin/data/services/admin_api_service.dart';
import 'package:fortune/features/admin/data/models/redis_stats_model.dart';
import 'package:fortune/core/utils/logger.dart';

// Provider for AdminApiService
final adminApiServiceProvider = Provider<AdminApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminApiService(apiClient);
});

// State notifier for Redis stats
class RedisStatsNotifier extends StateNotifier<AsyncValue<RedisStatsModel>> {
  final AdminApiService _adminApiService;
  Timer? _refreshTimer;

  RedisStatsNotifier(this._adminApiService)
      : super(const AsyncValue.loading()) {
    fetchRedisStats();
  }

  Future<void> fetchRedisStats() async {
    try {
      state = const AsyncValue.loading();
      final stats = await _adminApiService.getRedisStats();
      state = AsyncValue.data(stats);
    } catch (e, stackTrace) {
      Logger.error('Failed to fetch Redis stats': e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 5)}) {
    stopAutoRefresh();
    _refreshTimer = Timer.periodic(interval, (_) {
      fetchRedisStats();
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}

// Provider for Redis stats
final redisStatsProvider =
    StateNotifierProvider<RedisStatsNotifier, AsyncValue<RedisStatsModel>>(
        (ref) {
  final adminApiService = ref.watch(adminApiServiceProvider);
  return RedisStatsNotifier(adminApiService);
});

// Computed providers for specific Redis stats
final redisConnectionStatusProvider = Provider<bool>((ref) {
  return ref.watch(redisStatsProvider).maybeWhen(
        data: (stats) => stats.connection.connected,
        orElse: () => false,
      );
});

final redisCacheHitRateProvider = Provider<double>((ref) {
  return ref.watch(redisStatsProvider).maybeWhen(
        data: (stats) => stats.cache.hitRate,
        orElse: () => 0.0,
      );
});

final redisOperationStatsProvider = Provider<RedisOperationStats?>((ref) {
  return ref.watch(redisStatsProvider).maybeWhen(
        data: (stats) => stats.operations,
        orElse: () => null,
      );
});

final redisRateLimitsProvider = Provider<Map<String, RateLimitInfo>>((ref) {
  return ref.watch(redisStatsProvider).maybeWhen(
        data: (stats) => stats.rateLimits,
        orElse: () => {},
      );
});
