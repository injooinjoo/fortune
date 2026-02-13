import 'package:flutter/foundation.dart';
import '../config/environment.dart';
import '../../services/analytics_service.dart';

/// 로깅 유틸리티 클래스
/// 보안: 프로덕션 환경에서는 민감한 정보 로깅 방지
class Logger {
  static const String _prefix = '[Fortune]';

  // ANSI 색상 코드 (디버그 모드에서만 사용)
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';

  // 로그 레벨
  static const int _levelDebug = 0;
  static const int _levelInfo = 1;
  static const int _levelWarning = 2;
  static const int _levelError = 3;

  // 현재 로그 레벨 (프로덕션에서는 WARNING 이상만)
  static int get _currentLevel {
    // 디버그 모드에서는 항상 모든 로그 출력
    if (kDebugMode) {
      return _levelDebug;
    }
    if (Environment.current == Environment.production) {
      return _levelWarning;
    }
    return _levelDebug;
  }

  // 디버그 로그
  static void debug(String message, [dynamic data]) {
    if (_currentLevel <= _levelDebug && kDebugMode) {
      _log('$_cyan[DEBUG]$_reset', message, data);
    }
  }

  // 정보 로그
  static void info(String message, [dynamic data]) {
    if (_currentLevel <= _levelInfo) {
      _log('$_blue[INFO]$_reset', message, data);
    }
  }

  // 경고 로그
  static void warning(String message, [dynamic data]) {
    if (_currentLevel <= _levelWarning) {
      _log('$_yellow[WARNING]$_reset', message, data);
    }
  }

  // 에러 로그
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_currentLevel <= _levelError) {
      _log('$_red[ERROR]$_reset', message, error);
      if (stackTrace != null && kDebugMode) {
        debugPrint(stackTrace.toString());
      }

      // 프로덕션에서는 에러 리포팅 서비스로 전송
      if (Environment.current == Environment.production &&
          Environment.enableCrashReporting) {
        // TODO: Sentry로 에러 전송
      }
    }
  }

  // API 요청 로그
  static void apiRequest(String method, String url, [dynamic data]) {
    if (kDebugMode) {
      final sanitizedData = _sanitizeData(data);
      final fullUrl =
          url.startsWith('http') ? url : '${Environment.apiBaseUrl}$url';
      debug('$_green→ $method$_reset $fullUrl', sanitizedData);
    }
  }

  // API 응답 로그
  static void apiResponse(String method, String url, int statusCode,
      [dynamic data]) {
    if (kDebugMode) {
      final color = statusCode < 400
          ? _green
          : statusCode == 0
              ? _yellow
              : _red;
      final sanitizedData = _sanitizeData(data);
      final fullUrl =
          url.startsWith('http') ? url : '${Environment.apiBaseUrl}$url';
      final statusMsg =
          statusCode == 0 ? '0 (Network Error/CORS)' : statusCode.toString();
      debug('$color← $method $statusMsg$_reset $fullUrl', sanitizedData);

      if (statusCode == 0) {
        debug(
            'Possible causes: Network error, CORS issue, or server not running');
      }
    }
  }

  // 분석 이벤트 로그
  static void analytics(String event, [Map<String, dynamic>? parameters]) {
    if (kDebugMode) {
      debug('$_magenta[Analytics]$_reset $event', parameters);
    }

    // Send to Firebase Analytics if initialized
    if (AnalyticsService.instance.isInitialized) {
      AnalyticsService.instance.logEvent(event, parameters: parameters);
    }
  }

  // 성능 측정 시작
  static Stopwatch startTimer(String label) {
    if (kDebugMode) {
      debug('⏱ Start: $label');
    }
    return Stopwatch()..start();
  }

  // 성능 측정 종료
  static void endTimer(String label, Stopwatch stopwatch) {
    if (kDebugMode) {
      stopwatch.stop();
      debug('⏱️ $label completed in ${stopwatch.elapsedMilliseconds}ms');
    }
  }

  // 실제 로그 출력
  static void _log(String level, String message, [dynamic data]) {
    final logMessage = '$_prefix $level $message';

    if (kDebugMode) {
      debugPrint(logMessage);
      if (data != null) {
        debugPrint('  └─ Data: $data');
      }
    } else {
      // 프로덕션에서는 debugPrint 사용 (Flutter의 로그 제한 우회)
      debugPrint(logMessage);
    }
  }

  // 민감한 정보 제거
  static dynamic _sanitizeData(dynamic data) {
    if (!kDebugMode || data == null) return null;

    if (data is Map<String, dynamic>) {
      final sanitized = Map<String, dynamic>.from(data);
      final sensitiveKeys = [
        'password',
        'token',
        'accessToken',
        'refreshToken',
        'apiKey',
        'secret',
        'cardNumber',
        'cvv',
        'pin'
      ];

      for (final key in sensitiveKeys) {
        if (sanitized.containsKey(key)) {
          sanitized[key] = '***REDACTED***';
        }
      }

      return sanitized;
    }

    return data;
  }

  // 개발 진행 상황 보고용
  static void developmentProgress(String feature, String status,
      {String? details}) {
    if (kDebugMode) {
      debugPrint('\n${"=" * 50}');
      debugPrint('📊 DEVELOPMENT PROGRESS REPORT');
      debugPrint('Feature: $feature');
      debugPrint('Status: $status');
      if (details != null) {
        debugPrint('Details: $details');
      }
      debugPrint('Timestamp: ${DateTime.now().toIso8601String()}');
      debugPrint('${"=" * 50}\n');
    }
  }

  // 보안 체크포인트 로그
  static void securityCheckpoint(String checkpoint, {bool passed = true}) {
    final icon = passed ? '✅' : '❌';

    if (kDebugMode) {
      debugPrint('$icon SECURITY: $checkpoint');
    }

    // 프로덕션에서도 보안 실패는 기록
    if (!passed && Environment.current == Environment.production) {
      debugPrint(
          'ALERT: $checkpoint failed at ${DateTime.now().toIso8601String()}');
    }
  }

  // Fortune generation flow summary
  static void fortuneFlowSummary(
      {required String fortuneType,
      required int totalTimeMs,
      required bool success,
      bool fromCache = false,
      int? apiTimeMs,
      int? cacheTimeMs,
      int? overallScore,
      String? errorMessage}) {
    if (!kDebugMode) return;
    final icon = success ? '✨' : '❌';

    debugPrint('\n${"=" * 60}');
    debugPrint('$icon FORTUNE GENERATION SUMMARY');
    debugPrint('Fortune Type: $fortuneType');
    debugPrint('Status: ${success ? "SUCCESS" : "FAILED"}');
    debugPrint('Total Time: ${totalTimeMs}ms');

    if (fromCache) {
      debugPrint('Source: CACHE');
      if (cacheTimeMs != null) {
        debugPrint('Cache Time: ${cacheTimeMs}ms');
      }
    } else {
      debugPrint('Source: API');
      if (apiTimeMs != null) {
        debugPrint('API Time: ${apiTimeMs}ms');
      }
    }

    if (overallScore != null) {
      debugPrint('Overall Score: $overallScore');
    }

    if (errorMessage != null) {
      debugPrint('Error: $errorMessage');
    }

    debugPrint('Timestamp: ${DateTime.now().toIso8601String()}');
    debugPrint('${"=" * 60}\n');
  }
}
