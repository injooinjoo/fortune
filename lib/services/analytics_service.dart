import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../core/config/environment.dart';
import '../core/utils/logger.dart';
import '../core/services/resilient_service.dart';

/// 강화된 Firebase Analytics 서비스
///
/// KAN-74: Firebase Analytics 연결 안정성 문제 해결
/// - ResilientService 패턴 적용
/// - Firebase 연결 상태 모니터링
/// - 오프라인 모드 지원 (이벤트 큐잉)
/// - 백그라운드 재시도 메커니즘
class AnalyticsService extends ResilientService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static AnalyticsService get instance => _instance;

  @override
  String get serviceName => 'AnalyticsService';

  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? _observer;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  FirebaseAnalytics? get analytics => _analytics;
  FirebaseAnalyticsObserver? get observer => _observer;

  /// 강화된 Firebase Analytics 초기화 (ResilientService 패턴)
  Future<void> initialize() async {
    if (_isInitialized) return;

    await safeExecute(() async {
      // 기능 플래그 확인
      if (!Environment.enableAnalytics) {
        Logger.info('Analytics are disabled via feature flag');
        return;
      }

      // Firebase Analytics 초기화
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);

      // 수집 설정
      await _analytics!.setAnalyticsCollectionEnabled(!kDebugMode);

      _isInitialized = true;
      Logger.info('Firebase Analytics initialized successfully');

      // 앱 시작 이벤트 로깅
      await logEvent('app_open');
    }, 'Firebase Analytics 초기화', '분석 기능 비활성화 (앱은 정상 작동)');
  }

  /// 사용자 속성 설정 (ResilientService 패턴)
  Future<void> setUserProperties(
      {String? userId,
      bool? isPremium,
      String? userType,
      String? gender,
      String? birthYear}) async {
    if (!_isInitialized || _analytics == null) return;

    await safeExecute(() async {
      if (userId != null) {
        await _analytics!.setUserId(id: userId);
      }

      if (isPremium != null) {
        await _analytics!.setUserProperty(
          name: 'is_premium',
          value: isPremium.toString(),
        );
      }

      if (userType != null) {
        await _analytics!.setUserProperty(
          name: 'user_type',
          value: userType,
        );
      }

      if (gender != null) {
        await _analytics!.setUserProperty(
          name: 'gender',
          value: gender,
        );
      }

      if (birthYear != null) {
        await _analytics!.setUserProperty(
          name: 'birth_year',
          value: birthYear,
        );
      }

      Logger.info('User properties set successfully');
    }, '사용자 속성 설정', '분석 속성 설정 생략 (기능은 정상 작동)');
  }

  /// 커스텀 이벤트 로깅 (ResilientService 패턴)
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    if (!_isInitialized || _analytics == null) return;

    await safeExecute(() async {
      // 파라미터를 Map<String, Object>로 변환
      final Map<String, Object>? safeParameters = parameters?.map((key, value) {
        final Object safeValue = value ?? '';
        return MapEntry(key, safeValue);
      });

      await _analytics!.logEvent(
        name: name,
        parameters: safeParameters,
      );
      Logger.info('Event logged: $name', parameters);
    }, '이벤트 로깅: $name', '분석 이벤트 생략 (기능은 정상 작동)');
  }

  /// Log fortune recommendation impression
  Future<void> logFortuneRecommendationImpression({
    required String fortuneType,
    required String category,
    required double score,
    required String recommendationType,
    required int position,
  }) async {
    await logEvent(
      'fortune_recommendation_impression',
      parameters: {
        'fortune_type': fortuneType,
        'category': category,
        'score': score,
        'recommendation_type': recommendationType,
        'position': position,
      },
    );
  }

  /// Log fortune recommendation click
  Future<void> logFortuneRecommendationClick({
    required String fortuneType,
    required String category,
    required double score,
    required String recommendationType,
    required int position,
  }) async {
    await logEvent(
      'fortune_recommendation_click',
      parameters: {
        'fortune_type': fortuneType,
        'category': category,
        'score': score,
        'recommendation_type': recommendationType,
        'position': position,
        'action': 'click',
      },
    );
  }

  /// Log recommendation effectiveness
  Future<void> logRecommendationEffectiveness(
      {required String fortuneType,
      required bool visited,
      required double personalScore,
      required double popularityScore}) async {
    await logEvent(
      'recommendation_effectiveness',
      parameters: {
        'fortune_type': fortuneType,
        'visited': visited,
        'personal_score': personalScore,
        'popularity_score': popularityScore,
        'effectiveness': visited ? 1.0 : 0.0,
      },
    );
  }

  /// 화면 뷰 로깅 (ResilientService 패턴)
  Future<void> logScreenView(
      {required String screenName, String? screenClass}) async {
    if (!_isInitialized || _analytics == null) return;

    await safeExecute(() async {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );

      Logger.info('Screen view logged: $screenName');
    }, '화면 뷰 로깅: $screenName', '분석 화면 추적 생략 (기능은 정상 작동)');
  }

  /// Log fortune generation event
  Future<void> logFortuneGeneration(
      {required String fortuneType,
      required bool success,
      String? source,
      int? responseTimeMs,
      Map<String, dynamic>? additionalParams}) async {
    await logEvent('fortune_generation', parameters: {
      'fortune_type': fortuneType,
      'success': success,
      'source': source ?? 'api',
      if (responseTimeMs != null) 'response_time_ms': responseTimeMs,
      ...?additionalParams,
    });
  }

  /// Log token purchase event
  Future<void> logTokenPurchase(
      {required String packageId,
      required double price,
      required String currency,
      required int tokenAmount,
      bool success = true}) async {
    await logEvent('purchase', parameters: {
      'item_id': packageId,
      'price': price,
      'currency': currency,
      'token_amount': tokenAmount,
      'success': success,
      'item_category': 'tokens',
    });
  }

  /// Log token consumption event
  Future<void> logTokenConsumption(
      {required String fortuneType,
      required int tokenAmount,
      int? remainingTokens}) async {
    await logEvent('token_consumed', parameters: {
      'fortune_type': fortuneType,
      'token_amount': tokenAmount,
      if (remainingTokens != null) 'remaining_tokens': remainingTokens,
    });
  }

  /// Log ad events
  Future<void> logAdImpression(
      {required String adType, String? adUnitId, String? placement}) async {
    await logEvent('ad_impression', parameters: {
      'ad_type': adType,
      if (adUnitId != null) 'ad_unit_id': adUnitId,
      if (placement != null) 'placement': placement,
    });
  }

  Future<void> logAdClick(
      {required String adType, String? adUnitId, String? placement}) async {
    await logEvent('ad_click', parameters: {
      'ad_type': adType,
      if (adUnitId != null) 'ad_unit_id': adUnitId,
      if (placement != null) 'placement': placement,
    });
  }

  Future<void> logAdReward(
      {required String adType,
      required int rewardAmount,
      String? rewardType}) async {
    await logEvent('ad_reward_earned', parameters: {
      'ad_type': adType,
      'reward_amount': rewardAmount,
      'reward_type': rewardType ?? 'tokens',
    });
  }

  /// Log user engagement
  Future<void> logUserEngagement(
      {required String action,
      String? target,
      Map<String, dynamic>? additionalParams}) async {
    await logEvent('user_engagement', parameters: {
      'action': action,
      if (target != null) 'target': target,
      ...?additionalParams,
    });
  }

  /// Log error events
  Future<void> logError(
      {required String errorType,
      String? errorMessage,
      String? screen,
      Map<String, dynamic>? additionalParams}) async {
    await logEvent('app_error', parameters: {
      'error_type': errorType,
      if (errorMessage != null) 'error_message': errorMessage,
      if (screen != null) 'screen': screen,
      ...?additionalParams,
    });
  }

  /// Log share events
  Future<void> logShare(
      {required String contentType,
      required String method,
      String? itemId}) async {
    await logEvent('share', parameters: {
      'content_type': contentType,
      'method': method,
      if (itemId != null) 'item_id': itemId,
    });
  }

  /// Log tutorial/onboarding events
  Future<void> logTutorialBegin() async {
    await logEvent('tutorial_begin');
  }

  Future<void> logTutorialComplete() async {
    await logEvent('tutorial_complete');
  }

  Future<void> logSignUp({required String method}) async {
    await logEvent('sign_up', parameters: {
      'method': method,
    });
  }

  Future<void> logLogin({required String method}) async {
    await logEvent('login', parameters: {
      'method': method,
    });
  }

  /// Analytics 초기화 (로그아웃 시 등) (ResilientService 패턴)
  Future<void> reset() async {
    if (!_isInitialized || _analytics == null) return;

    await safeExecute(() async {
      await _analytics!.setUserId(id: null);
      await _analytics!.resetAnalyticsData();
      Logger.info('Analytics reset successfully');
    }, 'Analytics 데이터 초기화', '분석 초기화 생략 (로그아웃은 정상 진행)');
  }

  // ============ A/B Testing Analytics Events ============

  /// Log A/B test variant exposure
  Future<void> logABTestExposure({
    required String experimentId,
    required String variantId,
    String? variantName,
    String? userId,
    Map<String, dynamic>? additionalParams,
  }) async {
    await logEvent('ab_test_exposure', parameters: {
      'experiment_id': experimentId,
      'variant_id': variantId,
      if (variantName != null) 'variant_name': variantName,
      if (userId != null) 'user_id': userId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?additionalParams,
    });
  }

  /// Log A/B test conversion event
  Future<void> logABTestConversion({
    required String experimentId,
    required String variantId,
    String? conversionType,
    double? conversionValue,
    String? userId,
    Map<String, dynamic>? additionalParams,
  }) async {
    await logEvent('ab_test_conversion', parameters: {
      'experiment_id': experimentId,
      'variant_id': variantId,
      'conversion_type': conversionType ?? 'default',
      if (conversionValue != null) 'conversion_value': conversionValue,
      if (userId != null) 'user_id': userId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?additionalParams,
    });
  }

  /// Log A/B test metric event
  Future<void> logABTestMetric({
    required String experimentId,
    required String variantId,
    required String metricName,
    required dynamic metricValue,
    String? userId,
    Map<String, dynamic>? additionalParams,
  }) async {
    await logEvent('ab_test_metric', parameters: {
      'experiment_id': experimentId,
      'variant_id': variantId,
      'metric_name': metricName,
      'metric_value': metricValue,
      if (userId != null) 'user_id': userId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?additionalParams,
    });
  }

  /// Log payment UI A/B test events
  Future<void> logPaymentUITestEvent({
    required String variantId,
    required String action,
    String? packageId,
    double? price,
    Map<String, dynamic>? uiParameters,
  }) async {
    await logEvent('payment_ui_test', parameters: {
      'variant_id': variantId,
      'action': action, // 'view', 'click', 'purchase'
      if (packageId != null) 'package_id': packageId,
      if (price != null) 'price': price,
      if (uiParameters != null) ...uiParameters,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Log onboarding A/B test events
  Future<void> logOnboardingTestEvent({
    required String variantId,
    required String step,
    required String action,
    bool? skipped,
    int? timeSpentSeconds,
  }) async {
    await logEvent('onboarding_test', parameters: {
      'variant_id': variantId,
      'step': step,
      'action': action, // 'start', 'complete', 'skip', 'abandon'
      if (skipped != null) 'skipped': skipped,
      if (timeSpentSeconds != null) 'time_spent_seconds': timeSpentSeconds,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Log fortune card UI A/B test events
  Future<void> logFortuneCardUITestEvent({
    required String variantId,
    required String fortuneType,
    required String action,
    String? cardStyle,
    bool? animationEnabled,
  }) async {
    await logEvent('fortune_card_ui_test', parameters: {
      'variant_id': variantId,
      'fortune_type': fortuneType,
      'action': action, // 'view', 'interact', 'share', 'save'
      if (cardStyle != null) 'card_style': cardStyle,
      if (animationEnabled != null) 'animation_enabled': animationEnabled,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Log token pricing A/B test events
  Future<void> logTokenPricingTestEvent({
    required String variantId,
    required String action,
    String? packageId,
    int? tokenAmount,
    double? price,
    double? bonusRate,
  }) async {
    await logEvent('token_pricing_test', parameters: {
      'variant_id': variantId,
      'action': action, // 'view', 'select', 'purchase'
      if (packageId != null) 'package_id': packageId,
      if (tokenAmount != null) 'token_amount': tokenAmount,
      if (price != null) 'price': price,
      if (bonusRate != null) 'bonus_rate': bonusRate,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// A/B 테스트 사용자 속성 설정 (ResilientService 패턴)
  Future<void> setABTestUserProperty({
    required String experimentId,
    required String variantId,
  }) async {
    if (!_isInitialized || _analytics == null) return;

    await safeExecute(() async {
      await _analytics!.setUserProperty(
        name: 'ab_$experimentId',
        value: variantId,
      );

      Logger.info('Set A/B test user property: $experimentId = $variantId');
    }, 'A/B 테스트 사용자 속성 설정: $experimentId', 'A/B 테스트 분석 속성 생략 (실험 기능은 정상 작동)');
  }

  /// Log experiment started event
  Future<void> logExperimentStarted({
    required String experimentId,
    required String experimentName,
    required int variantCount,
    double? trafficAllocation,
  }) async {
    await logEvent('experiment_started', parameters: {
      'experiment_id': experimentId,
      'experiment_name': experimentName,
      'variant_count': variantCount,
      if (trafficAllocation != null) 'traffic_allocation': trafficAllocation,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Log experiment ended event
  Future<void> logExperimentEnded({
    required String experimentId,
    required String winningVariant,
    double? uplift,
    int? totalParticipants,
  }) async {
    await logEvent('experiment_ended', parameters: {
      'experiment_id': experimentId,
      'winning_variant': winningVariant,
      if (uplift != null) 'uplift_percentage': uplift,
      if (totalParticipants != null) 'total_participants': totalParticipants,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
