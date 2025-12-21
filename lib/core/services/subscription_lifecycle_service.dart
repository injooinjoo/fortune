import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/subscription_provider.dart';
import '../utils/logger.dart';

/// 앱 라이프사이클에 따른 구독 상태 자동 체크 서비스
///
/// - 앱이 포그라운드로 돌아올 때 구독 상태 확인
/// - 백그라운드에서 구독이 만료되었을 수 있으므로 재확인 필요
class SubscriptionLifecycleService with WidgetsBindingObserver {
  final Ref _ref;
  bool _isInitialized = false;

  SubscriptionLifecycleService(this._ref);

  /// 서비스 초기화 (앱 시작 시 호출)
  void initialize() {
    if (_isInitialized) return;

    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
    Logger.info('[SubscriptionLifecycleService] Initialized');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // 앱이 포그라운드로 돌아올 때 구독 상태 확인
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // 다른 상태에서는 별도 처리 없음
        break;
    }
  }

  void _onAppResumed() {
    Logger.info('[SubscriptionLifecycleService] App resumed - checking subscription status');

    try {
      // 구독 상태 확인
      _ref.read(subscriptionProvider.notifier).checkSubscriptionStatus();
    } catch (e) {
      Logger.error('[SubscriptionLifecycleService] Failed to check subscription status', e);
    }
  }

  /// 서비스 정리 (앱 종료 시 호출)
  void dispose() {
    if (!_isInitialized) return;

    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
    Logger.info('[SubscriptionLifecycleService] Disposed');
  }
}

/// SubscriptionLifecycleService Provider
final subscriptionLifecycleServiceProvider = Provider<SubscriptionLifecycleService>((ref) {
  final service = SubscriptionLifecycleService(ref);

  // Provider가 생성될 때 초기화
  service.initialize();

  // Provider가 dispose될 때 정리
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
