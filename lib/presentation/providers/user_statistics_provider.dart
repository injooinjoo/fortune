import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/user_statistics_service.dart';
import '../../services/storage_service.dart';
import '../../core/utils/logger.dart';

final userStatisticsServiceProvider = Provider<UserStatisticsService>((ref) {
  final supabase = Supabase.instance.client;
  final storageService = StorageService();
  return UserStatisticsService(supabase, storageService);
});

final userStatisticsProvider = FutureProvider<UserStatistics?>((ref) async {
  final service = ref.watch(userStatisticsServiceProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    return null;
  }

  try {
    return await service.getUserStatistics(userId);
  } catch (e) {
    Logger.error('Failed to load user statistics', e);
    return UserStatistics.empty();
  }
});

class UserStatisticsNotifier
    extends StateNotifier<AsyncValue<UserStatistics?>> {
  final UserStatisticsService _service;
  final String? _userId;

  UserStatisticsNotifier(this._service, this._userId)
      : super(const AsyncValue.loading()) {
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    if (_userId == null) {
      state = const AsyncValue.data(null);
      return;
    }

    try {
      final stats = await _service.getUserStatistics(_userId);
      state = AsyncValue.data(stats);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> incrementFortuneCount(String fortuneType) async {
    if (_userId == null) return;

    try {
      await _service.incrementFortuneCount(_userId, fortuneType);
      // Reload statistics after update
      await _loadStatistics();
    } catch (e) {
      Logger.error('Failed to increment fortune count', e);
    }
  }

  Future<void> updateConsecutiveDays() async {
    if (_userId == null) return;

    try {
      await _service.updateConsecutiveDays(_userId);
      // Reload statistics after update
      await _loadStatistics();
    } catch (e) {
      Logger.error('Failed to update consecutive days', e);
    }
  }

  Future<void> updateTokenUsage(int tokensUsed, int tokensEarned) async {
    if (_userId == null) return;

    try {
      await _service.updateTokenUsage(_userId, tokensUsed, tokensEarned);
      // Reload statistics after update
      await _loadStatistics();
    } catch (e) {
      Logger.error('Failed to update token usage', e);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadStatistics();
  }
}

final userStatisticsNotifierProvider =
    StateNotifierProvider<UserStatisticsNotifier, AsyncValue<UserStatistics?>>(
        (ref) {
  final service = ref.watch(userStatisticsServiceProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;
  return UserStatisticsNotifier(service, userId);
});

// Helper provider to get the favorite fortune type
final favoriteFortuneTypeProvider = Provider<String?>((ref) {
  final statsAsync = ref.watch(userStatisticsNotifierProvider);
  return statsAsync.when(
      data: (stats) => stats?.favoriteFortuneType,
      loading: () => null,
      error: (_, __) => null);
});

// Helper provider to get fortune access counts
final fortuneTypeCountsProvider = Provider<Map<String, int>>((ref) {
  final statsAsync = ref.watch(userStatisticsNotifierProvider);
  return statsAsync.when(
      data: (stats) => stats?.fortuneTypeCount ?? {},
      loading: () => {},
      error: (_, __) => {});
});
