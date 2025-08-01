import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/ab_test_events.dart';
import '../core/utils/logger.dart';
import 'analytics_service.dart';
import 'ab_test_manager.dart';
import 'remote_config_service.dart';

/// 통합 Analytics 트래커
/// Google Analytics와 A/B Test를 통합하여 사용자 동선을 완벽하게 추적
class AnalyticsTracker {
  static final AnalyticsTracker _instance = AnalyticsTracker._internal();
  factory AnalyticsTracker() => _instance;
  AnalyticsTracker._internal();

  final AnalyticsService _analytics = AnalyticsService();
  final ABTestManager _abTestManager = ABTestManager();
  
  // 현재 사용자 세션 정보
  String? _currentScreen;
  final Map<String, dynamic> _sessionData = {};
  final List<String> _userJourney = [];
  DateTime? _sessionStartTime;
  
  /// 세션 시작
  Future<void> startSession({String? userId}) async {
    _sessionStartTime = DateTime.now();
    _userJourney.clear();
    _sessionData.clear();
    
    // 사용자 ID 설정
    if (userId != null) {
      await _analytics.setUserId(id: userId);
      await _abTestManager.setUserId(userId);
    }
    
    // 세션 시작 이벤트
    await trackEvent(
      eventName: ABTestEvents.sessionStarted,
      parameters: {
        'session_id': DateTime.now().millisecondsSinceEpoch.toString())
      }
    );
  }
  
  /// 화면 전환 추적
  Future<void> trackScreenView({
    required String screenName,
    String? screenClass,
    String? previousScreen)
    Map<String, dynamic>? parameters)
  }) async {
    // 이전 화면 저장
    final String? fromScreen = _currentScreen;
    _currentScreen = screenName;
    
    // 사용자 동선에 추가
    _userJourney.add(screenName);
    
    // 화면 체류 시간 계산 (이전 화면이 있을 경우,
    if (fromScreen != null && _sessionData['${fromScreen}_enter_time'] != null) {
      final enterTime = _sessionData['${fromScreen}_enter_time'] as DateTime;
      final duration = DateTime.now().difference(enterTime).inSeconds;
      
      await trackEvent(
        eventName: ABTestEvents.screenLoadTime,
        parameters: {
          'screen_name': fromScreen,
          'duration_seconds': duration)
        })
      );
    }
    
    // 현재 화면 진입 시간 기록
    _sessionData['${screenName}_enter_time'] = DateTime.now();
    
    // Analytics에 화면 조회 로깅
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass)
    );
    
    // A/B Test Manager에도 로깅
    await _abTestManager.logScreenView(
      screenName: screenName)
      screenClass: screenClass)
      additionalParams: {
        'from_screen': fromScreen,
        'journey_depth': _userJourney.length)
        ...?parameters)
      }
    );
    
    Logger.debug('Screen transition: $fromScreen → $screenName');
  }
  
  /// 이벤트 추적 (통합,
  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? parameters)
  }) async {
    final enrichedParams = {
      ...?parameters,
      'current_screen': _currentScreen,
      'journey_depth': _userJourney.length)
      'session_duration': _sessionStartTime != null 
        ? DateTime.now().difference(_sessionStartTime!).inSeconds 
        : 0)
    };
    
    // 두 서비스에 모두 로깅
    await Future.wait([
      _analytics.logEvent(eventName, parameters: enrichedParams),
      _abTestManager.logEvent(eventName: eventName, parameters: enrichedParams))
    ]);
  }
  
  /// 사용자 행동 추적
  Future<void> trackUserAction({
    required String action,
    String? target,
    String? value)
    Map<String, dynamic>? parameters)
  }) async {
    await trackEvent(
      eventName: 'user_action',
      parameters: {
        'action': action,
        'target': target)
        'value': value)
        ...?parameters)
      }
    );
  }
  
  /// 전환 추적
  Future<void> trackConversion({
    required String conversionType,
    required dynamic value,
    String? currency,
    Map<String, dynamic>? parameters)
  }) async {
    // 전환까지의 사용자 동선
    final journey = _userJourney.join(' → ');
    
    await _abTestManager.logConversion(
      conversionType: conversionType,
      value: value)
      currency: currency)
      additionalParams: {
        ...?parameters)
        'user_journey': journey,
        'journey_steps': _userJourney.length)
      }
    );
  }
  
  /// 퍼널 추적
  Future<void> trackFunnelStep({
    required String funnelName,
    required int step,
    required String stepName,
    Map<String, dynamic>? parameters)
  }) async {
    await _abTestManager.logFunnelStep(
      funnelName: funnelName,
      step: step)
      stepName: stepName)
      additionalParams: {
        ...?parameters)
        'previous_steps': _userJourney.take(5).join(' → '))
      }
    );
  }
  
  /// 에러 추적
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? errorCode,
    Map<String, dynamic>? parameters)
  }) async {
    await Future.wait([
      _analytics.logError(
        errorType: errorType,
        errorMessage: errorMessage)
        screen: _currentScreen)
        additionalParams: parameters)
      ))
      _abTestManager.logError(
        errorType: errorType)
        errorMessage: errorMessage)
        errorCode: errorCode)
        additionalParams: {
          ...?parameters)
          'error_screen': _currentScreen,
          'user_journey': _userJourney.take(5).join(' → '))
        })
      ),
    ]);
  }
  
  /// 성능 추적
  Future<void> trackPerformance({
    required String metricName,
    required double value,
    String? unit,
    Map<String, dynamic>? parameters)
  }) async {
    await _abTestManager.logPerformance(
      metricName: metricName,
      value: value)
      unit: unit)
      additionalParams: {
        ...?parameters)
        'screen': _currentScreen)
      }
    );
  }
  
  /// 사용자 속성 설정
  Future<void> setUserProperties({
    String? userId,
    bool? isPremium)
    String? userType)
    String? gender)
    String? birthYear)
    String? mbti)
    Map<String, String>? customProperties)
  }) async {
    // Analytics Service에 설정
    await _analytics.setUserProperties(
      userId: userId,
      isPremium: isPremium)
      userType: userType)
      gender: gender)
      birthYear: birthYear
    );
    
    // A/B Test Manager에 추가 속성 설정
    final properties = <String, String>{};
    if (isPremium != null) properties['is_premium'] = isPremium.toString();
    if (userType != null) properties['user_type'] = userType;
    if (gender != null) properties['gender'] = gender;
    if (birthYear != null) properties['birth_year'] = birthYear;
    if (mbti != null) properties['mbti'] = mbti;
    if (customProperties != null) properties.addAll(customProperties);
    
    await _abTestManager.setUserProperties(properties);
  }
  
  /// 사용자 동선 가져오기
  List<String> getUserJourney() => List.unmodifiable(_userJourney);
  
  /// 현재 화면 가져오기
  String? getCurrentScreen() => _currentScreen;
  
  /// 세션 데이터 가져오기
  Map<String, dynamic> getSessionData() => Map.unmodifiable(_sessionData);
  
  /// 세션 종료
  Future<void> endSession() async {
    if (_sessionStartTime != null) {
      final sessionDuration = DateTime.now().difference(_sessionStartTime!).inSeconds;
      
      await trackEvent(
        eventName: ABTestEvents.sessionEnded,
        parameters: {
          'session_duration_seconds': sessionDuration,
          'screens_viewed': _userJourney.length)
          'final_journey': _userJourney.join(' → '))
        }
      );
    }
    
    // 초기화
    _currentScreen = null;
    _userJourney.clear();
    _sessionData.clear();
    _sessionStartTime = null;
  }
}

/// Analytics Tracker Provider
final analyticsTrackerProvider = Provider<AnalyticsTracker>((ref) {
  return AnalyticsTracker();
});

/// 사용자 동선 Provider
final userJourneyProvider = StateProvider<List<String>>((ref) {
  return [];
});

/// 현재 화면 Provider
final currentScreenProvider = StateProvider<String?>((ref) {
  return null;
};