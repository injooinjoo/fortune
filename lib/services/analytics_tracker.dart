import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/ab_test_events.dart';
import '../core/utils/logger.dart';
import 'analytics_service.dart';
import 'ab_test_manager.dart';

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
      await _analytics.setUserProperties(userId: userId);
      await _abTestManager.setUserId(userId);
    }

    // 세션 시작 이벤트
    await trackEvent(
      eventName: ABTestEvents.sessionStarted,
      parameters: {
        'session_id': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
  }

  /// 화면 전환 추적
  Future<void> trackScreenView({
    required String screenName,
    String? screenClass,
    String? previousScreen,
    Map<String, dynamic>? parameters,
  }) async {
    // 이전 화면 저장
    final String? fromScreen = _currentScreen;
    _currentScreen = screenName;

    // 사용자 동선에 추가
    _userJourney.add(screenName);

    // 화면 체류 시간 계산 (이전 화면이 있을 경우)
    if (fromScreen != null &&
        _sessionData['${fromScreen}_enter_time'] != null) {
      final enterTime = _sessionData['${fromScreen}_enter_time'] as DateTime;
      final duration = DateTime.now().difference(enterTime).inSeconds;

      await trackEvent(
        eventName: ABTestEvents.screenLoadTime,
        parameters: {
          'screen_name': fromScreen,
          'duration_seconds': duration,
        },
      );
    }

    // 현재 화면 진입 시간 기록
    _sessionData['${screenName}_enter_time'] = DateTime.now();

    // Analytics에 화면 조회 로깅
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );

    // A/B Test Manager에도 로깅
    await _abTestManager.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
      additionalParams: {
        'from_screen': fromScreen,
        'journey_depth': _userJourney.length,
        ...?parameters,
      },
    );

    Logger.debug('Screen view tracked: $screenName');
  }

  /// 이벤트 추적 (통합)
  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    final enrichedParams = {
      ...?parameters,
      'current_screen': _currentScreen,
      'journey_depth': _userJourney.length,
      'session_duration': _sessionStartTime != null
          ? DateTime.now().difference(_sessionStartTime!).inSeconds
          : 0,
    };

    // 두 서비스에 모두 로깅
    await Future.wait([
      _analytics.logEvent(eventName, parameters: enrichedParams),
      _abTestManager.logEvent(eventName: eventName, parameters: enrichedParams),
    ]);
  }

  /// 사용자 행동 추적
  Future<void> trackUserAction({
    required String action,
    String? target,
    String? value,
    Map<String, dynamic>? parameters,
  }) async {
    await trackEvent(
      eventName: 'user_action',
      parameters: {
        'action': action,
        'target': target,
        'value': value,
        ...?parameters,
      },
    );
  }

  /// 전환 추적
  Future<void> trackConversion({
    required String conversionType,
    required dynamic value,
    String? currency,
    Map<String, dynamic>? parameters,
  }) async {
    // 전환까지의 사용자 동선
    final journey = _userJourney.join(' → ');

    await _abTestManager.logConversion(
      conversionType: conversionType,
      value: value,
      currency: currency,
      additionalParams: {
        ...?parameters,
        'user_journey': journey,
        'journey_steps': _userJourney.length,
      },
    );
  }

  /// 퍼널 추적
  Future<void> trackFunnelStep({
    required String funnelName,
    required int step,
    required String stepName,
    Map<String, dynamic>? parameters,
  }) async {
    await _abTestManager.logFunnelStep(
      funnelName: funnelName,
      step: step,
      stepName: stepName,
      additionalParams: {
        ...?parameters,
        'previous_steps': _userJourney.take(5).join(' → '),
      },
    );
  }

  /// 에러 추적
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? errorCode,
    Map<String, dynamic>? parameters,
  }) async {
    await Future.wait([
      _analytics.logError(
        errorType: errorType,
        errorMessage: errorMessage,
        screen: _currentScreen,
        additionalParams: parameters,
      ),
      _abTestManager.logError(
        errorType: errorType,
        errorMessage: errorMessage,
        errorCode: errorCode,
        additionalParams: {
          ...?parameters,
          'error_screen': _currentScreen,
          'user_journey': _userJourney.take(5).join(' → '),
        },
      ),
    ]);
  }

  /// 성능 추적
  Future<void> trackPerformance({
    required String metricName,
    required double value,
    String? unit,
    Map<String, dynamic>? parameters,
  }) async {
    await trackEvent(
      eventName: 'performance_metric',
      parameters: {
        'metric_name': metricName,
        'value': value,
        'unit': unit,
        ...?parameters,
      },
    );
  }

  /// 사용자 속성 설정
  Future<void> setUserProperties({
    String? userId,
    bool? isPremium,
    String? userType,
    String? gender,
    String? birthYear,
    String? mbti,
  }) async {
    await _analytics.setUserProperties(
      userId: userId,
      isPremium: isPremium,
      userType: userType,
      gender: gender,
      birthYear: birthYear,
    );

    // A/B Test Manager에도 사용자 속성 설정
    if (userId != null) {
      await _abTestManager.setUserId(userId);
    }

    final properties = <String, String>{};
    if (isPremium != null) properties['is_premium'] = isPremium.toString();
    if (userType != null) properties['user_type'] = userType;
    if (gender != null) properties['gender'] = gender;
    if (birthYear != null) properties['birth_year'] = birthYear.toString();
    if (mbti != null) properties['mbti'] = mbti;

    if (properties.isNotEmpty) {
      await _abTestManager.setUserProperties(properties);
    }
  }

  /// 세션 종료
  Future<void> endSession() async {
    // 마지막 화면 체류 시간 계산
    if (_currentScreen != null &&
        _sessionData['${_currentScreen}_enter_time'] != null) {
      final enterTime =
          _sessionData['${_currentScreen}_enter_time'] as DateTime;
      final duration = DateTime.now().difference(enterTime).inSeconds;

      await trackEvent(
        eventName: ABTestEvents.screenLoadTime,
        parameters: {
          'screen_name': _currentScreen!,
          'duration_seconds': duration,
        },
      );
    }

    // 세션 종료 이벤트
    final sessionDuration = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!).inSeconds
        : 0;

    await trackEvent(
      eventName: ABTestEvents.sessionEnded,
      parameters: {
        'session_duration': sessionDuration,
        'screens_viewed': _userJourney.length,
        'user_journey': _userJourney.join(' → '),
      },
    );

    // 세션 데이터 초기화
    _currentScreen = null;
    _sessionData.clear();
    _userJourney.clear();
    _sessionStartTime = null;
  }

  /// 사용자 동선 가져오기
  List<String> getUserJourney() => List.unmodifiable(_userJourney);

  /// 현재 화면 가져오기
  String? getCurrentScreen() => _currentScreen;

  /// 세션 데이터 가져오기
  Map<String, dynamic> getSessionData() => Map.unmodifiable(_sessionData);
}

/// AnalyticsTracker Provider
final analyticsTrackerProvider = Provider<AnalyticsTracker>((ref) {
  return AnalyticsTracker();
});
