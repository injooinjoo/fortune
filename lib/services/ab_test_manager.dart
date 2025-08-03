import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/logger.dart';
import 'remote_config_service.dart';

/// A/B 테스트 관리자
/// Firebase Analytics와 Remote Config를 통합하여 실험 추적 및 분석
class ABTestManager {
  static final ABTestManager _instance = ABTestManager._internal();
  factory ABTestManager() => _instance;
  ABTestManager._internal();
  
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final Map<String, String> _activeExperiments = {};
  
  /// 실험 그룹 설정
  Future<void> setExperimentGroup(String experimentName, String variant) async {
    try {
      _activeExperiments[experimentName] = variant;
      
      await _analytics.setUserProperty(
        name: 'exp_$experimentName',
        value: variant,
      );
      
      Logger.info('Supabase initialized successfully');
    } catch (e) {
      Logger.error('Failed to set experiment group', e);
    }
  }
  
  /// 활성 실험 가져오기
  String? getExperimentVariant(String experimentName) {
    return _activeExperiments[experimentName];
  }
  
  /// 이벤트 로깅 with A/B 테스트 컨텍스트
  Future<void> logEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final params = parameters ?? {};
      
      // Remote Config 값들 추가
      final remoteConfig = RemoteConfigService();
      params['ab_subscription_price'] = remoteConfig.getSubscriptionPrice();
      params['ab_payment_layout'] = remoteConfig.getPaymentUILayout();
      params['ab_onboarding_flow'] = remoteConfig.getOnboardingFlow();
      params['ab_fortune_ui_style'] = remoteConfig.getFortuneUIStyle();
      
      // 활성 실험 정보 추가
      _activeExperiments.forEach((key, value) {
        params['exp_$key'] = value;
      });
      
      // 타임스탬프 추가
      params['event_timestamp'] = DateTime.now().millisecondsSinceEpoch;
      
      await _analytics.logEvent(
        name: eventName,
        parameters: params,
      );
      
      Logger.debug('Fortune cached');
    } catch (e) {
      Logger.error('event: $eventName', e);
    }
  }
  
  /// 화면 조회 이벤트
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? additionalParams,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
    
    // 추가 파라미터와 함께 커스텀 이벤트도 로깅
    await logEvent(
      eventName: 'screen_view_custom',
      parameters: {
        'screen_name': screenName,
        'screen_class': null,
        ...?additionalParams,
      },
    );
  }
  
  /// 전환 이벤트 로깅
  Future<void> logConversion({
    required String conversionType,
    required dynamic value,
    String? currency,
    Map<String, dynamic>? additionalParams,
  }) async {
    final params = additionalParams ?? {};
    params['conversion_type'] = conversionType;
    params['conversion_value'] = value;
    if (currency != null) {
      params['currency'] = currency;
    }
    
    // 표준 전환 이벤트
    switch (conversionType) {
      case 'subscription':
        await _analytics.logPurchase(
          value: value.toDouble(),
          currency: currency ?? 'KRW',
          items: [
            AnalyticsEventItem(
              itemId: 'subscription_monthly',
              itemName: RemoteConfigService().getSubscriptionTitle(),
              price: value.toDouble(),
              quantity: 1,
            ),
          ],
        );
        break;
        
      case 'token_purchase':
        await _analytics.logPurchase(
          value: value.toDouble(),
          currency: currency ?? 'KRW',
          parameters: params,
        );
        break;
        
      case 'signup':
        await _analytics.logSignUp(signUpMethod: params['method'] ?? 'email');
        break;
        
      default:
        // 커스텀 전환 이벤트
        await logEvent(
          eventName: 'custom_conversion',
          parameters: params,
        );
    }
    
    // 추가로 커스텀 전환 이벤트도 로깅
    await logEvent(
      eventName: 'conversion_${conversionType}',
      parameters: params,
    );
  }
  
  /// 사용자 행동 이벤트
  Future<void> logUserAction({
    required String action,
    String? target,
    String? value,
    Map<String, dynamic>? additionalParams,
  }) async {
    final params = additionalParams ?? {};
    params['action'] = action;
    if (target != null) params['target'] = target;
    if (value != null) params['value'] = value;
    
    await logEvent(
      eventName: 'user_action',
      parameters: params,
    );
  }
  
  /// 퍼널 이벤트 로깅
  Future<void> logFunnelStep({
    required String funnelName,
    required int step,
    required String stepName,
    Map<String, dynamic>? additionalParams,
  }) async {
    final params = additionalParams ?? {};
    params['funnel_name'] = funnelName;
    params['funnel_step'] = step;
    params['step_name'] = stepName;
    
    await logEvent(
      eventName: 'funnel_step',
      parameters: params,
    );
  }
  
  /// 에러 이벤트 로깅
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? errorCode,
    Map<String, dynamic>? additionalParams,
  }) async {
    final params = additionalParams ?? {};
    params['error_type'] = errorType;
    params['error_message'] = errorMessage;
    if (errorCode != null) params['error_code'] = errorCode;
    
    await logEvent(
      eventName: 'app_error',
      parameters: params,
    );
  }
  
  /// 성능 이벤트 로깅
  Future<void> logPerformance({
    required String metricName,
    required double value,
    String? unit,
    Map<String, dynamic>? additionalParams,
  }) async {
    final params = additionalParams ?? {};
    params['metric_name'] = metricName;
    params['metric_value'] = value;
    if (unit != null) params['metric_unit'] = unit;
    
    await logEvent(
      eventName: 'performance_metric',
      parameters: params,
    );
  }
  
  /// 사용자 속성 설정
  Future<void> setUserProperties(Map<String, String> properties) async {
    try {
      for (final entry in properties.entries) {
        await _analytics.setUserProperty(
          name: entry.key,
          value: entry.value,
        );
      }
      Logger.info('properties: ${properties.keys.join('), ')}');
    } catch (e) {
      Logger.error('Failed to set user properties', e);
    }
  }
  
  /// 사용자 ID 설정
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
      Logger.info('ID: ${userId ??')null'}');
    } catch (e) {
      Logger.error('Failed to set user ID', e);
    }
  }
  
  /// 실험 시작 이벤트
  Future<void> logExperimentExposure({
    required String experimentName,
    required String variant,
    Map<String, dynamic>? additionalParams,
  }) async {
    await setExperimentGroup(experimentName, variant);
    
    await logEvent(
      eventName: 'experiment_exposure',
      parameters: {
        'experiment_name': experimentName,
        'variant': null,
        ...?additionalParams,
      },
    );
  }
}

/// A/B 테스트 매니저 Provider
final abTestManagerProvider = Provider<ABTestManager>((ref) {
  return ABTestManager();
});

/// 실험 그룹 Provider
final experimentGroupProvider = StateNotifierProvider<ExperimentGroupNotifier, Map<String, String>>((ref) {
  return ExperimentGroupNotifier();
});

/// 실험 그룹 관리자
class ExperimentGroupNotifier extends StateNotifier<Map<String, String>> {
  ExperimentGroupNotifier() : super({});
  
  void setExperiment(String name, String variant) {
    state = {...state, name: variant};
  }
  
  String? getVariant(String name) {
    return state[name];
  }
  
  void clearExperiments() {
    state = {};
  }
}