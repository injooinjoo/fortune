import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/in_app_purchase_service.dart';
import '../../core/utils/logger.dart';
import 'token_provider.dart';

/// 구독 상태 모델
class SubscriptionState {
  final bool isActive;
  final bool isLoading;
  final String? error;
  final DateTime? lastChecked;
  final String? plan;           // 'monthly' | 'yearly'
  final DateTime? expiresAt;    // 만료일
  final String? productId;      // 상품 ID

  const SubscriptionState({
    this.isActive = false,
    this.isLoading = false,
    this.error,
    this.lastChecked,
    this.plan,
    this.expiresAt,
    this.productId,
  });

  SubscriptionState copyWith({
    bool? isActive,
    bool? isLoading,
    String? error,
    DateTime? lastChecked,
    String? plan,
    DateTime? expiresAt,
    String? productId,
  }) {
    return SubscriptionState(
      isActive: isActive ?? this.isActive,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastChecked: lastChecked ?? this.lastChecked,
      plan: plan ?? this.plan,
      expiresAt: expiresAt ?? this.expiresAt,
      productId: productId ?? this.productId,
    );
  }

  /// 남은 일수 계산
  int get remainingDays {
    if (expiresAt == null || !isActive) return 0;
    final remaining = expiresAt!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }
}

/// 구독 상태 관리 Notifier
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final InAppPurchaseService _purchaseService;
  final Ref _ref;
  Timer? _expirationCheckTimer;

  SubscriptionNotifier(this._purchaseService, this._ref) : super(const SubscriptionState()) {
    // 초기 상태 확인
    checkSubscriptionStatus();
    // 만료 체크 타이머 시작
    _startExpirationCheckTimer();
  }

  /// 만료 체크 타이머 시작 (30분 주기)
  void _startExpirationCheckTimer() {
    _expirationCheckTimer?.cancel();
    _expirationCheckTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _checkExpiration();
    });
  }

  /// 만료 여부 확인
  void _checkExpiration() {
    if (!state.isActive) return;

    // 로컬 만료일 체크
    if (state.expiresAt != null && DateTime.now().isAfter(state.expiresAt!)) {
      Logger.info('Subscription expired locally, verifying with server...');
      checkSubscriptionStatus();
      return;
    }

    // 마지막 체크 후 24시간 지났으면 서버 확인
    if (state.lastChecked != null) {
      final hoursSinceLastCheck = DateTime.now().difference(state.lastChecked!).inHours;
      if (hoursSinceLastCheck >= 24) {
        Logger.info('24 hours since last check, refreshing subscription status...');
        checkSubscriptionStatus();
      }
    }
  }

  /// 구독 상태 확인
  Future<void> checkSubscriptionStatus() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final isActive = await _purchaseService.isSubscriptionActive();
      state = state.copyWith(
        isActive: isActive,
        isLoading: false,
        lastChecked: DateTime.now(),
      );
      Logger.info('Subscription status checked: $isActive');

      // 서버에서 비활성화되면 로컬 상태도 초기화
      if (!isActive) {
        state = state.copyWith(
          plan: null,
          expiresAt: null,
          productId: null,
        );
      }
    } catch (e) {
      Logger.error('Failed to check subscription status', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 구독 활성화 (구매 성공 시 호출)
  /// [plan]: 'monthly' | 'yearly'
  /// [expiresAt]: 만료일시
  /// [productId]: 상품 ID
  Future<void> setActive(
    bool isActive, {
    String? plan,
    DateTime? expiresAt,
    String? productId,
  }) async {
    state = state.copyWith(
      isActive: isActive,
      plan: plan,
      expiresAt: expiresAt,
      productId: productId,
      lastChecked: DateTime.now(),
    );
    Logger.info('Subscription status set to: $isActive, plan: $plan, expiresAt: $expiresAt');

    // TokenProvider 동기화 (구독 활성화 시)
    if (isActive) {
      try {
        await _ref.read(tokenProvider.notifier).loadTokenData();
        Logger.info('TokenProvider synced after subscription activation');
      } catch (e) {
        Logger.error('Failed to sync TokenProvider', e);
      }
    }
  }

  @override
  void dispose() {
    _expirationCheckTimer?.cancel();
    super.dispose();
  }
}

/// InAppPurchaseService Provider
final inAppPurchaseServiceProvider = Provider<InAppPurchaseService>((ref) {
  return InAppPurchaseService();
});

/// 구독 상태 Provider
final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final purchaseService = ref.watch(inAppPurchaseServiceProvider);
  return SubscriptionNotifier(purchaseService, ref);
});

/// 프리미엄 사용자 여부 Provider (광고 숨김 등에 사용)
///
/// tokenProvider.hasUnlimitedAccess를 사용하여 3가지 조건 모두 확인:
/// - subscription.isActive (구독 활성화)
/// - hasUnlimitedTokens (테스트 계정)
/// - balance.hasUnlimitedAccess (무제한 토큰)
final isPremiumProvider = Provider<bool>((ref) {
  final tokenState = ref.watch(tokenProvider);
  return tokenState.hasUnlimitedAccess;
});

/// 구독 로딩 상태 Provider
final isSubscriptionLoadingProvider = Provider<bool>((ref) {
  final subscriptionState = ref.watch(subscriptionProvider);
  return subscriptionState.isLoading;
});
