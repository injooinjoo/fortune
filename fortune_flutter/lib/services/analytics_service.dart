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
      Logger.error('Failed to initialize Firebase Analytics', e);
    }
  }

  /// Set user properties
  Future<void> setUserProperties({
    String? userId,
    bool? isPremium,
    String? userType,
    String? gender,
    String? birthYear,
  }) async {
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
      Logger.error('Failed to set user properties', e);
    }
  }

  /// Log a custom event
  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
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
        parameters: safeParameters
      );
      Logger.info('Analytics event logged: $name', parameters);
    } catch (e) {
      Logger.error('Failed to log analytics event: $name', e);
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
    required double popularityScore,
  }) async {
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
    String? screenClass,
  }) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName
      );
      
      Logger.info('Screen view logged: $screenName');
    } catch (e) {
      Logger.error('Failed to log screen view: $screenName', e);
    }
  }

  /// Log fortune generation event
  Future<void> logFortuneGeneration({
    required String fortuneType,
    required bool success,
    String? source,
    int? responseTimeMs,
    Map<String, dynamic>? additionalParams,
  }) async {
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
    bool success = true,
  }) async {
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
    int? remainingTokens,
  }) async {
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
    String? placement,
  }) async {
    await logEvent('ad_impression', parameters: {
      'ad_type': adType,
      if (adUnitId != null) 'ad_unit_id': adUnitId,
      if (placement != null) 'placement': placement,
    });
  }

  Future<void> logAdClick({
    required String adType,
    String? adUnitId,
    String? placement,
  }) async {
    await logEvent('ad_click', parameters: {
      'ad_type': adType,
      if (adUnitId != null) 'ad_unit_id': adUnitId,
      if (placement != null) 'placement': placement,
    });
  }

  Future<void> logAdReward({
    required String adType,
    required int rewardAmount,
    String? rewardType,
  }) async {
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
    Map<String, dynamic>? additionalParams,
  }) async {
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
    Map<String, dynamic>? additionalParams,
  }) async {
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
    String? itemId,
  }) async {
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
    required String method,
  }) async {
    await logEvent('sign_up', parameters: {
      'method': method,
    });
  }

  Future<void> logLogin({
    required String method,
  }) async {
    await logEvent('login', parameters: {
      'method': method,
    });
  }

  /// Reset analytics (e.g., on logout,
  Future<void> reset() async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.setUserId(id: null);
      await _analytics!.resetAnalyticsData();
      Logger.info('Analytics reset successfully');
    } catch (e) {
      Logger.error('Failed to reset analytics', e);
    }
  }
}