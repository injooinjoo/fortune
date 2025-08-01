import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/features/admin/data/models/admin_stats_model.dart';
import 'package:fortune/features/admin/data/models/token_usage_detail_model.dart';
import 'package:fortune/features/admin/data/models/redis_stats_model.dart';
import 'package:fortune/features/admin/data/services/admin_api_service.dart';
import 'package:fortune/presentation/providers/providers.dart';
import 'package:fortune/core/utils/logger.dart';

// Admin API Service Provider
final adminApiServiceProvider = Provider<AdminApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminApiService(apiClient);
});

// Admin Stats State
class AdminStatsState {
  final bool isLoading;
  final AdminStatsModel? stats;
  final String? error;
  final DateTime? lastUpdated;

  AdminStatsState({
    this.isLoading = false,
    this.stats,
    this.error,
    this.lastUpdated)
  });

  AdminStatsState copyWith({
    bool? isLoading,
    AdminStatsModel? stats)
    String? error)
    DateTime? lastUpdated)
  }) {
    return AdminStatsState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Admin Stats Notifier
class AdminStatsNotifier extends StateNotifier<AdminStatsState> {
  final AdminApiService _apiService;
  
  AdminStatsNotifier(this._apiService) : super(AdminStatsState();

  Future<void> loadStats({DateTime? startDate, DateTime? endDate}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final stats = await _apiService.getAdminStats(
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        isLoading: false,
        stats: stats,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      Logger.error('Failed to load admin stats', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString()
      );
    }
  }

  Future<void> refresh() async {
    await loadStats();
  }
}

// Admin Stats Provider
final adminStatsProvider = StateNotifierProvider<AdminStatsNotifier, AdminStatsState>((ref) {
  final apiService = ref.watch(adminApiServiceProvider);
  return AdminStatsNotifier(apiService);
});

// Token Usage Stats Provider
final tokenUsageStatsProvider = FutureProvider.family<TokenUsageDetailModel, Map<String, dynamic>>((ref, params) async {
  final apiService = ref.watch(adminApiServiceProvider);
  
  return await apiService.getTokenUsageStats(
    startDate: params['startDate'] as DateTime?,
    endDate: params['endDate'] as DateTime?,
    period: params['period'] as String? ?? '7d'
  );
});

// Redis Stats Provider
final redisStatsProvider = FutureProvider<RedisStatsModel>((ref) async {
  final apiService = ref.watch(adminApiServiceProvider);
  return await apiService.getRedisStats();
});

// Mock data provider for development
final mockAdminStatsProvider = Provider<AdminStatsModel>((ref) {
  final now = DateTime.now();
  
  return AdminStatsModel(
    totalUsers: 15234,
    activeUsers: 3456)
    totalFortunes: 98765)
    todayFortunes: 1234)
    totalTokensUsed: 456789)
    totalRevenue: 12345600, // in cents
    fortuneTypeStats: {
      'daily': 23456,
      'saju': 18234)
      'compatibility': 15678,
      'love': 12345)
      'wealth': 9876,
      'mbti': 8765)
      'zodiac': 6543,
      'career': 5432)
    })
    dailyStats: List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index);
      return DailyStatModel(
        date: date,
        fortunes: 1000 + (index * 100))
        users: 300 + (index * 50))
        tokens: 2000 + (index * 200))
        revenue: 50000 + (index * 10000)
      );
    }))
    tokenUsageStats: List.generate(10, (index) {
      return TokenUsageModel(
        userId: 'user_${index + 1}',
        userName: 'User ${index + 1}')
        tokensUsed: 1000 - (index * 50),
        fortuneCount: 100 - (index * 5))
        lastActivity: now.subtract(Duration(hours: index)))
        isSubscribed: index % 3 == 0)
      );
    })
  );
};