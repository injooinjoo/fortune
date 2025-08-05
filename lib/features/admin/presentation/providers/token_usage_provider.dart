import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/features/admin/data/services/admin_api_service.dart';
import 'package:fortune/features/admin/data/models/token_usage_detail_model.dart';
import 'package:fortune/features/admin/presentation/providers/redis_stats_provider.dart';
import 'package:fortune/core/utils/logger.dart';

// State for token usage period selection
final tokenUsagePeriodProvider = StateProvider<String>((ref) => '7d');

// State notifier for token usage stats
class TokenUsageNotifier
    extends StateNotifier<AsyncValue<TokenUsageDetailModel>> {
  final AdminApiService _adminApiService;
  final Ref _ref;

  TokenUsageNotifier(this._adminApiService, this._ref)
      : super(const AsyncValue.loading()) {
    fetchTokenUsageStats();
  }

  Future<void> fetchTokenUsageStats() async {
    try {
      state = const AsyncValue.loading();
      final period = _ref.read(tokenUsagePeriodProvider);

      // Calculate date range based on period
      final endDate = DateTime.now();
      DateTime startDate;

      switch (period) {
        case '7d':
          startDate = endDate.subtract(const Duration(days: 7));
          break;
        case '30d':
          startDate = endDate.subtract(const Duration(days: 30));
          break;
        case '90d':
          startDate = endDate.subtract(const Duration(days: 90));
          break;
        default:
          startDate = endDate.subtract(const Duration(days: 7));
      }

      final stats = await _adminApiService.getTokenUsageStats(
        startDate: startDate,
        endDate: endDate,
        period: period);

      state = AsyncValue.data(stats);
    } catch (e, stackTrace) {
      Logger.error('Failed to fetch token usage stats', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void changePeriod(String newPeriod) {
    _ref.read(tokenUsagePeriodProvider.notifier).state = newPeriod;
    fetchTokenUsageStats();
  }
}

// Provider for token usage stats
final tokenUsageProvider = StateNotifierProvider<TokenUsageNotifier,
    AsyncValue<TokenUsageDetailModel>>((ref) {
  final adminApiService = ref.watch(adminApiServiceProvider);
  return TokenUsageNotifier(adminApiService, ref);
});

// Computed providers for specific token usage data
final tokenUsageSummaryProvider = Provider<TokenUsageSummary?>((ref) {
  return ref.watch(tokenUsageProvider).maybeWhen(
        data: (stats) => stats.summary,
        orElse: () => null);
});

final dailyTokenUsageProvider = Provider<List<DailyTokenUsage>>((ref) {
  return ref.watch(tokenUsageProvider).maybeWhen(
        data: (stats) => stats.dailyUsage,
        orElse: () => []);
});

final topUsersProvider = Provider<List<TopUserUsage>>((ref) {
  return ref.watch(tokenUsageProvider).maybeWhen(
        data: (stats) => stats.topUsers,
        orElse: () => []);
});

final tokenUsageByTypeProvider = Provider<List<TokenUsageByType>>((ref) {
  return ref.watch(tokenUsageProvider).maybeWhen(
        data: (stats) => stats.usageByType,
        orElse: () => []);
});

final packageEfficiencyProvider = Provider<PackageEfficiency?>((ref) {
  return ref.watch(tokenUsageProvider).maybeWhen(
        data: (stats) => stats.packageEfficiency,
        orElse: () => null);
});

final tokenUsageTrendProvider = Provider<TokenUsageTrend?>((ref) {
  return ref.watch(tokenUsageProvider).maybeWhen(
        data: (stats) => stats.trend,
        orElse: () => null);
});
