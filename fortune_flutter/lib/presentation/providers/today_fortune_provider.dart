import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/data/services/fortune_api_service.dart';
import 'package:fortune/domain/entities/fortune.dart';
import 'package:fortune/presentation/providers/auth_provider.dart';

// Today Fortune State
class TodayFortuneState {
  final Fortune? fortune;
  final bool isLoading;
  final String? error;
  final DateTime? lastGeneratedAt;

  const TodayFortuneState({
    this.fortune,
    this.isLoading = false,
    this.error,
    this.lastGeneratedAt,
  });

  TodayFortuneState copyWith({
    Fortune? fortune,
    bool? isLoading,
    String? error,
    DateTime? lastGeneratedAt,
  }) {
    return TodayFortuneState(
      fortune: fortune ?? this.fortune,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastGeneratedAt: lastGeneratedAt ?? this.lastGeneratedAt,
    );
  }

// Today Fortune Notifier
class TodayFortuneNotifier extends StateNotifier<TodayFortuneState> {
  final FortuneApiService _apiService;
  final Ref ref;

  TodayFortuneNotifier(this._apiService, this.ref) : super(const TodayFortuneState());

  Future<void> generateTodayFortune() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Get user profile
      final userProfileAsync = await ref.read(userProfileProvider.future);
      final userProfile = userProfileAsync;
      
      if (userProfile == null) {
        state = state.copyWith(
          isLoading: false,
          error: '프로필 정보가 필요합니다',
        );
        return;
      }

      // Check if fortune was already generated today
      final today = DateTime.now();
      if (state.lastGeneratedAt != null &&
          state.lastGeneratedAt!.year == today.year &&
          state.lastGeneratedAt!.month == today.month &&
          state.lastGeneratedAt!.day == today.day &&
          state.fortune != null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final fortune = await _apiService.generateDailyFortune(
        userId: userProfile.userId),
        date: DateTime.now(),
      );
      state = state.copyWith(
        fortune: fortune,
        isLoading: false,
        lastGeneratedAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearFortune() {
    state = const TodayFortuneState();
  }
}

// Provider
final todayFortuneProvider = StateNotifierProvider<TodayFortuneNotifier, TodayFortuneState>((ref) {
  final apiService = ref.watch(fortuneApiServiceProvider);
  return TodayFortuneNotifier(apiService, ref);
};