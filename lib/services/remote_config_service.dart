import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/logger.dart';

/// Firebase Remote Config 서비스
/// A/B 테스트를 위한 동적 설정 관리
class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  late FirebaseRemoteConfig _remoteConfig;
  bool _isInitialized = false;
  
  // A/B 테스트 파라미터 키
  static const String subscriptionPriceKey = 'subscription_price';
  static const String subscriptionTitleKey = 'subscription_title';
  static const String subscriptionDescriptionKey = 'subscription_description';
  static const String subscriptionFeaturesKey = 'subscription_features';
  static const String subscriptionBadgeKey = 'subscription_badge';
  
  static const String tokenBonusRateKey = 'token_bonus_rate';
  static const String tokenPackagesKey = 'token_packages';
  static const String popularTokenPackageKey = 'popular_token_package';
  
  static const String onboardingFlowKey = 'onboarding_flow';
  static const String onboardingSkippableKey = 'onboarding_skippable';
  
  static const String fortuneUIStyleKey = 'fortune_ui_style';
  static const String fortuneCardLayoutKey = 'fortune_card_layout';
  static const String fortuneAnimationEnabledKey = 'fortune_animation_enabled';
  
  static const String paymentUILayoutKey = 'payment_ui_layout';
  static const String paymentButtonStyleKey = 'payment_button_style';
  static const String showDiscountBadgeKey = 'show_discount_badge';
  
  static const String dailyFreeTokensKey = 'daily_free_tokens';
  static const String referralBonusTokensKey = 'referral_bonus_tokens';
  static const String newUserBonusTokensKey = 'new_user_bonus_tokens';
  
  /// Remote Config 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      
      // 기본값 설정
      await _setDefaults();
      
      // Remote Config 설정
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1), // 프로덕션에서는 더 길게
      ));
      
      // 값 가져오기 및 활성화
      final updated = await _remoteConfig.fetchAndActivate();
      Logger.info('Remote Config initialized successfully (updated: $updated)');
      
      // 변경사항 리스너 설정
      _remoteConfig.onConfigUpdated.listen((event) async {
        await _remoteConfig.activate();
        Logger.info('Remote Config updated and activated');
      });
      
      _isInitialized = true;
    } catch (e) {
      Logger.warning('[RemoteConfigService] Remote Config 초기화 실패 (기본값 사용): $e');
      _isInitialized = false;
      // 초기화 실패시 기본값으로 동작할 수 있도록 설정
      rethrow;
    }
  }
  
  /// 기본값 설정
  Future<void> _setDefaults() async {
    await _remoteConfig.setDefaults({
      // 구독 관련,
    subscriptionPriceKey: 2500,
      subscriptionTitleKey: '무제한 이용권',
      subscriptionDescriptionKey: '한 달 동안 모든 운세 무제한 이용',
      subscriptionFeaturesKey: json.encode([
        '모든 운세 무제한 이용',
        '광고 제거',
        '우선 고객 지원',
        '프리미엄 기능 이용']),
      subscriptionBadgeKey: '추천',
      
      // 토큰 관련,
      tokenBonusRateKey: 1.0,
      tokenPackagesKey: json.encode([
        {'id': 'tokens10', 'amount': 10, 'price': 1000, 'bonus': 0},
        {'id': 'tokens50', 'amount': 50, 'price': 4500, 'bonus': 5},
        {'id': 'tokens100', 'amount': 100, 'price': 8000, 'bonus': 15},
        {'id': 'tokens200', 'amount': 200, 'price': 14000, 'bonus': 30}],
      ),
      popularTokenPackageKey: 'tokens100',
      
      // 온보딩 관련,
      onboardingFlowKey: 'standard',
      onboardingSkippableKey: false,
      
      // 운세 UI 관련,
      fortuneUIStyleKey: 'modern',
      fortuneCardLayoutKey: 'card',
      fortuneAnimationEnabledKey: true,
      
      // 결제 UI 관련,
      paymentUILayoutKey: 'split',
      paymentButtonStyleKey: 'rounded',
      showDiscountBadgeKey: true,
      
      // 보너스 토큰,
      dailyFreeTokensKey: 1,
      referralBonusTokensKey: 10,
      newUserBonusTokensKey: 5,
    });
  }
  
  // Getter 메서드들
  
  /// 구독 가격 가져오기
  int getSubscriptionPrice() {
    if (!_isInitialized) return 2500;
    return _remoteConfig.getInt(subscriptionPriceKey);
  }
  
  /// 구독 제목 가져오기
  String getSubscriptionTitle() {
    if (!_isInitialized) return '무제한 이용권';
    return _remoteConfig.getString(subscriptionTitleKey);
  }
  
  /// 구독 설명 가져오기
  String getSubscriptionDescription() {
    if (!_isInitialized) return '한 달 동안 모든 운세 무제한 이용';
    return _remoteConfig.getString(subscriptionDescriptionKey);
  }
  
  /// 구독 기능 목록 가져오기
  List<String> getSubscriptionFeatures() {
    if (!_isInitialized) {
      return [
        '모든 운세 무제한 이용',
        '광고 제거',
        '우선 고객 지원',
        '프리미엄 기능 이용'];
    }
    
    try {
      final featuresJson = _remoteConfig.getString(subscriptionFeaturesKey);
      return List<String>.from(json.decode(featuresJson));
    } catch (e) {
      Logger.warning('[RemoteConfigService] 구독 기능 목록 파싱 실패 (빈 목록 반환): $e');
      return [];
    }
  }
  
  /// 구독 뱃지 텍스트 가져오기
  String getSubscriptionBadge() {
    if (!_isInitialized) return '추천';
    return _remoteConfig.getString(subscriptionBadgeKey);
  }
  
  /// 토큰 보너스 비율 가져오기
  double getTokenBonusRate() {
    if (!_isInitialized) return 1.0;
    return _remoteConfig.getDouble(tokenBonusRateKey);
  }
  
  /// 토큰 패키지 목록 가져오기
  List<Map<String, dynamic>> getTokenPackages() {
    if (!_isInitialized) {
      return [
        {'id': 'tokens10', 'amount': 10, 'price': 1000, 'bonus': 0},
        {'id': 'tokens50', 'amount': 50, 'price': 4500, 'bonus': 5},
        {'id': 'tokens100', 'amount': 100, 'price': 8000, 'bonus': 15},
        {'id': 'tokens200', 'amount': 200, 'price': 14000, 'bonus': 30}];
    }
    
    try {
      final packagesJson = _remoteConfig.getString(tokenPackagesKey);
      return List<Map<String, dynamic>>.from(json.decode(packagesJson));
    } catch (e) {
      Logger.warning('[RemoteConfigService] 토큰 패키지 목록 파싱 실패 (빈 목록 반환): $e');
      return [];
    }
  }
  
  /// 인기 토큰 패키지 ID 가져오기
  String getPopularTokenPackage() {
    if (!_isInitialized) return 'tokens100';
    return _remoteConfig.getString(popularTokenPackageKey);
  }
  
  /// 온보딩 플로우 타입 가져오기
  String getOnboardingFlow() {
    if (!_isInitialized) return 'standard';
    return _remoteConfig.getString(onboardingFlowKey);
  }
  
  /// 온보딩 스킵 가능 여부
  bool isOnboardingSkippable() {
    if (!_isInitialized) return false;
    return _remoteConfig.getBool(onboardingSkippableKey);
  }
  
  /// 운세 UI 스타일 가져오기
  String getFortuneUIStyle() {
    if (!_isInitialized) return 'modern';
    return _remoteConfig.getString(fortuneUIStyleKey);
  }
  
  /// 운세 카드 레이아웃 가져오기
  String getFortuneCardLayout() {
    if (!_isInitialized) return 'card';
    return _remoteConfig.getString(fortuneCardLayoutKey);
  }
  
  /// 운세 애니메이션 활성화 여부
  bool isFortuneAnimationEnabled() {
    if (!_isInitialized) return true;
    return _remoteConfig.getBool(fortuneAnimationEnabledKey);
  }
  
  /// 결제 UI 레이아웃 가져오기
  String getPaymentUILayout() {
    if (!_isInitialized) return 'split';
    return _remoteConfig.getString(paymentUILayoutKey);
  }
  
  /// 결제 버튼 스타일 가져오기
  String getPaymentButtonStyle() {
    if (!_isInitialized) return 'rounded';
    return _remoteConfig.getString(paymentButtonStyleKey);
  }
  
  /// 할인 뱃지 표시 여부
  bool shouldShowDiscountBadge() {
    if (!_isInitialized) return true;
    return _remoteConfig.getBool(showDiscountBadgeKey);
  }
  
  /// 일일 무료 토큰 개수
  int getDailyFreeTokens() {
    if (!_isInitialized) return 1;
    return _remoteConfig.getInt(dailyFreeTokensKey);
  }
  
  /// 추천 보너스 토큰 개수
  int getReferralBonusTokens() {
    if (!_isInitialized) return 10;
    return _remoteConfig.getInt(referralBonusTokensKey);
  }
  
  /// 신규 사용자 보너스 토큰 개수
  int getNewUserBonusTokens() {
    if (!_isInitialized) return 5;
    return _remoteConfig.getInt(newUserBonusTokensKey);
  }
  
  /// 특정 키의 값 가져오기 (범용,
  dynamic getValue(String key) {
    if (!_isInitialized) return null;
    return _remoteConfig.getValue(key);
  }
  
  /// Remote Config 값 새로고침
  Future<bool> refresh() async {
    try {
      final updated = await _remoteConfig.fetchAndActivate();
      return updated;
    } catch (e) {
      Logger.warning('[RemoteConfigService] Remote Config 새로고침 실패 (이전 값 유지): $e');
      return false;
    }
  }
}

/// Remote Config Provider
final remoteConfigProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});

/// Remote Config 초기화 Provider
final remoteConfigInitializerProvider = FutureProvider<void>((ref) async {
  final remoteConfig = ref.watch(remoteConfigProvider);
  await remoteConfig.initialize();
});