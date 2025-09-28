import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../core/config/environment.dart';
import '../core/utils/logger.dart';

/// Service for managing analytics tracking
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static AnalyticsService get instance => _instance;

  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? _observer;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  FirebaseAnalytics? get analytics => _analytics;
  FirebaseAnalyticsObserver? get observer => _observer;

  /// Initialize Firebase Analytics
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Check if analytics are enabled
      if (!Environment.enableAnalytics) {
        Logger.info('Analytics are disabled via feature flag');
        return;
      }

      // Initialize Firebase Analytics
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);

      // Set collection settings
      await _analytics!.setAnalyticsCollectionEnabled(!kDebugMode);
      
      _isInitialized = true;
      Logger.info('Firebase Analytics initialized successfully');
      
      // Log app open event
      await logEvent('app_open');
    } catch (e) {
      Logger.warning('[AnalyticsService] Firebase Analytics 초기화 실패 (분석 없이 진행): $e');
    }
  }

  /// Set user properties
  Future<void> setUserProperties({
    String? userId,
    bool? isPremium,
    String? userType,
    String? gender,
    String? birthYear}) async {
    if (!_isInitialized || _analytics == null) return;

    try {
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
    } catch (e) {
      Logger.warning('[AnalyticsService] 사용자 속성 설정 실패 (분석 없이 진행): $e');
    }
  }

  /// Log a custom event
  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters}) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      // Convert parameters to Map<String, Object> if needed
      final Map<String, Object>? safeParameters = parameters?.map((key, value) {
        // Convert null values to empty string
        final Object safeValue = value ?? '';
        return MapEntry(key, safeValue);
      });
      
      await _analytics!.logEvent(
        name: name,
        parameters: safeParameters,
      );
      Logger.info('Event logged: $name', parameters);
    } catch (e) {
      Logger.warning('[AnalyticsService] 이벤트 로깅 실패 (분석 없이 진행): $name - $e');
    }
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
  Future<void> logRecommendationEffectiveness({
    required String fortuneType,
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


  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass}) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      
      Logger.info('Supabase initialized successfully');
    } catch (e) {
      Logger.warning('[AnalyticsService] 화면 뷰 로깅 실패 (분석 없이 진행): $screenName - $e');
    }
  }

  /// Log fortune generation event
  Future<void> logFortuneGeneration({
    required String fortuneType,
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
  Future<void> logTokenPurchase({
    required String packageId,
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
  Future<void> logTokenConsumption({
    required String fortuneType,
    required int tokenAmount,
    int? remainingTokens}) async {
    await logEvent('token_consumed', parameters: {
      'fortune_type': fortuneType,
      'token_amount': tokenAmount,
      if (remainingTokens != null) 'remaining_tokens': remainingTokens,
    });
  }

  /// Log ad events
  Future<void> logAdImpression({
    required String adType,
    String? adUnitId,
    String? placement}) async {
    await logEvent('ad_impression', parameters: {
      'ad_type': adType,
      if (adUnitId != null) 'ad_unit_id': adUnitId,
      if (placement != null) 'placement': placement,
    });
  }

  Future<void> logAdClick({
    required String adType,
    String? adUnitId,
    String? placement}) async {
    await logEvent('ad_click', parameters: {
      'ad_type': adType,
      if (adUnitId != null) 'ad_unit_id': adUnitId,
      if (placement != null) 'placement': placement,
    });
  }

  Future<void> logAdReward({
    required String adType,
    required int rewardAmount,
    String? rewardType}) async {
    await logEvent('ad_reward_earned', parameters: {
      'ad_type': adType,
      'reward_amount': rewardAmount,
      'reward_type': rewardType ?? 'tokens',
    });
  }

  /// Log user engagement
  Future<void> logUserEngagement({
    required String action,
    String? target,
    Map<String, dynamic>? additionalParams}) async {
    await logEvent('user_engagement', parameters: {
      'action': action,
      if (target != null) 'target': target,
      ...?additionalParams,
    });
  }

  /// Log error events
  Future<void> logError({
    required String errorType,
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
  Future<void> logShare({
    required String contentType,
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

  Future<void> logSignUp({
    required String method}) async {
    await logEvent('sign_up', parameters: {
      'method': method,
    });
  }

  Future<void> logLogin({
    required String method}) async {
    await logEvent('login', parameters: {
      'method': method,
    });
  }

  /// Reset analytics (e.g., on logout)
  Future<void> reset() async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.setUserId(id: null);
      await _analytics!.resetAnalyticsData();
      Logger.info('Analytics reset successfully');
    } catch (e) {
      Logger.warning('[AnalyticsService] Analytics 리셋 실패 (무시): $e');
    }
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

  /// Set user property for A/B test segment
  Future<void> setABTestUserProperty({
    required String experimentId,
    required String variantId,
  }) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.setUserProperty(
        name: 'ab_${experimentId}',
        value: variantId,
      );
      
      Logger.info('Set A/B test user property: $experimentId = $variantId');
    } catch (e) {
      Logger.warning('[AnalyticsService] A/B 테스트 사용자 속성 설정 실패 (분석 없이 진행): $e');
    }
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