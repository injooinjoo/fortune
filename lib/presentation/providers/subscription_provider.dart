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

  const SubscriptionState({
    this.isActive = false,
    this.isLoading = false,
    this.error,
    this.lastChecked,
  });

  SubscriptionState copyWith({
    bool? isActive,
    bool? isLoading,
    String? error,
    DateTime? lastChecked,
  }) {
    return SubscriptionState(
      isActive: isActive ?? this.isActive,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}

/// 구독 상태 관리 Notifier
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final InAppPurchaseService _purchaseService;

  SubscriptionNotifier(this._purchaseService) : super(const SubscriptionState()) {
    // 초기 상태 확인
    checkSubscriptionStatus();
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
    } catch (e) {
      Logger.error('Failed to check subscription status', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 구독 활성화 (구매 성공 시 호출)
  void setActive(bool isActive) {
    state = state.copyWith(
      isActive: isActive,
      lastChecked: DateTime.now(),
    );
    Logger.info('Subscription status set to: $isActive');
  }
}

/// InAppPurchaseService Provider
final inAppPurchaseServiceProvider = Provider<InAppPurchaseService>((ref) {
  return InAppPurchaseService();
});

/// 구독 상태 Provider
final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final purchaseService = ref.watch(inAppPurchaseServiceProvider);
  return SubscriptionNotifier(purchaseService);
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
