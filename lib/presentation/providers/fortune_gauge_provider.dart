import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/storage_service.dart';
import 'providers.dart';

// Fortune Gauge State
class FortuneGaugeState {
  final int currentProgress; // 0-10
  final int totalTokens; // 획득한 토큰 총 개수
  final Set<String> todayViewed; // 오늘 본 운세 타입들
  final DateTime? lastResetDate; // 일일 리셋용
  final bool isAnimating; // 애니메이션 진행 중 여부
  final bool isLoading;
  final String? error;

  const FortuneGaugeState({
    this.currentProgress = 0,
    this.totalTokens = 0,
    this.todayViewed = const {},
    this.lastResetDate,
    this.isAnimating = false,
    this.isLoading = false,
    this.error,
  });

  FortuneGaugeState copyWith({
    int? currentProgress,
    int? totalTokens,
    Set<String>? todayViewed,
    DateTime? lastResetDate,
    bool? isAnimating,
    bool? isLoading,
    String? error,
  }) {
    return FortuneGaugeState(
      currentProgress: currentProgress ?? this.currentProgress,
      totalTokens: totalTokens ?? this.totalTokens,
      todayViewed: todayViewed ?? this.todayViewed,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      isAnimating: isAnimating ?? this.isAnimating,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isComplete => currentProgress >= 10;
}

// Fortune Gauge Notifier
class FortuneGaugeNotifier extends StateNotifier<FortuneGaugeState> {
  final StorageService _storageService;
  final Ref ref;

  FortuneGaugeNotifier(this._storageService, this.ref)
      : super(const FortuneGaugeState()) {
    loadProgress();
  }

  // 앱 시작 시 StorageService에서 로드
  Future<void> loadProgress() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _storageService.getFortuneGaugeData();

      if (data != null) {
        // 날짜 변경 체크 및 리셋
        final lastResetDate = data['lastResetDate'] != null
            ? DateTime.parse(data['lastResetDate'] as String)
            : null;

        final todayViewedList = (data['todayViewed'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toSet() ??
            {};

        // 날짜가 변경되었는지 확인
        final needsReset = _checkAndResetIfNeeded(lastResetDate);

        state = state.copyWith(
          currentProgress:
              needsReset ? 0 : (data['currentProgress'] as int? ?? 0),
          totalTokens: data['totalLuckyBags'] as int? ?? 0, // 스토리지 키 유지 (하위호환)
          todayViewed: needsReset ? {} : todayViewedList,
          lastResetDate: DateTime.now(),
          isLoading: false,
        );

        // 리셋이 발생했으면 저장
        if (needsReset) {
          await _saveToStorage();
        }
      } else {
        // 데이터가 없으면 초기 상태
        state = state.copyWith(
          lastResetDate: DateTime.now(),
          isLoading: false,
        );
        await _saveToStorage();
      }
    } catch (e) {
      debugPrint('[FortuneGaugeProvider] Error loading progress: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 게이지 증가 (중복 체크 포함)
  Future<bool> incrementGauge(String fortuneType) async {
    // 날짜 리셋 체크
    _resetDailyViewedIfNeeded();

    // 이미 오늘 본 운세인지 체크
    if (state.todayViewed.contains(fortuneType)) {
      debugPrint('[FortuneGaugeProvider] Already viewed today: $fortuneType');
      return false;
    }

    // 이미 10에 도달했으면 증가 불가
    if (state.isComplete) {
      debugPrint('[FortuneGaugeProvider] Already complete (10/10)');
      return false;
    }

    state = state.copyWith(isAnimating: true);

    try {
      // 새로운 운세 추가
      final newTodayViewed = Set<String>.from(state.todayViewed)
        ..add(fortuneType);
      final newProgress = state.currentProgress + 1;

      state = state.copyWith(
        currentProgress: newProgress,
        todayViewed: newTodayViewed,
        isAnimating: false,
      );

      // 저장
      await _saveToStorage();

      // 10 도달 시 토큰 지급
      if (newProgress == 10) {
        await _checkAndAwardToken();
      }

      debugPrint(
          '[FortuneGaugeProvider] Progress: $newProgress/10 (type: $fortuneType)');
      return true;
    } catch (e) {
      debugPrint('[FortuneGaugeProvider] Error incrementing gauge: $e');
      state = state.copyWith(
        isAnimating: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // 10 도달 시 게이지 리셋 (획득형 보상 정책 제거)
  Future<void> _checkAndAwardToken() async {
    try {
      debugPrint(
          '[FortuneGaugeProvider] Gauge cycle completed. Resetting progress.');
      state = state.copyWith(
        currentProgress: 0,
        todayViewed: {}, // 다음 사이클 위해 초기화
      );
      await _saveToStorage();
    } catch (e) {
      debugPrint('[FortuneGaugeProvider] Error resetting gauge cycle: $e');
    }
  }

  // 날짜 변경 시 todayViewed 리셋
  void _resetDailyViewedIfNeeded() {
    if (state.lastResetDate == null) return;

    if (_checkAndResetIfNeeded(state.lastResetDate)) {
      state = state.copyWith(
        currentProgress: 0,
        todayViewed: {},
        lastResetDate: DateTime.now(),
      );
      _saveToStorage();
      debugPrint('[FortuneGaugeProvider] Daily reset performed');
    }
  }

  // 날짜 변경 체크
  bool _checkAndResetIfNeeded(DateTime? lastResetDate) {
    if (lastResetDate == null) return true;

    final now = DateTime.now();
    final lastReset = lastResetDate;

    // 날짜가 다르면 리셋 필요
    return now.year != lastReset.year ||
        now.month != lastReset.month ||
        now.day != lastReset.day;
  }

  // 변경사항 저장
  Future<void> _saveToStorage() async {
    try {
      final data = {
        'currentProgress': state.currentProgress,
        'totalLuckyBags': state.totalTokens, // 스토리지 키 유지 (하위호환)
        'todayViewed': state.todayViewed.toList(),
        'lastResetDate': state.lastResetDate?.toIso8601String(),
      };

      await _storageService.saveFortuneGaugeData(data);
      debugPrint('[FortuneGaugeProvider] Data saved to storage');
    } catch (e) {
      debugPrint('[FortuneGaugeProvider] Error saving to storage: $e');
    }
  }

  // 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  // 수동 리셋 (테스트용)
  Future<void> reset() async {
    state = state.copyWith(
      currentProgress: 0,
      todayViewed: {},
      lastResetDate: DateTime.now(),
    );
    await _saveToStorage();
    debugPrint('[FortuneGaugeProvider] Manual reset performed');
  }
}

// Provider
final fortuneGaugeProvider =
    StateNotifierProvider<FortuneGaugeNotifier, FortuneGaugeState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return FortuneGaugeNotifier(storageService, ref);
});

// Convenient providers
final gaugeProgressProvider = Provider<int>((ref) {
  return ref.watch(fortuneGaugeProvider).currentProgress;
});

final totalTokensProvider = Provider<int>((ref) {
  return ref.watch(fortuneGaugeProvider).totalTokens;
});

final isGaugeCompleteProvider = Provider<bool>((ref) {
  return ref.watch(fortuneGaugeProvider).isComplete;
});
