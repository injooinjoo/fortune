import 'dart:async';
import 'dart:convert';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

/// 실시간 에러 리포팅 서비스
/// Flutter 앱에서 발생하는 모든 에러를 캡처하여 JSON 파일로 저장
/// 백그라운드 모니터링 시스템이 이 파일을 읽어 자동으로 JIRA에 등록
class ErrorReporterService {
  static const String _errorLogPath = '/tmp/fortune_runtime_errors.json';
  static final ErrorReporterService _instance = ErrorReporterService._internal();

  factory ErrorReporterService() => _instance;
  ErrorReporterService._internal();

  final List<Map<String, dynamic>> _errorQueue = [];
  final Set<String> _reportedErrorHashes = {};
  Timer? _flushTimer;
  bool _isInitialized = false;

  /// 에러 리포터 초기화
  /// FlutterError.onError와 PlatformDispatcher.instance.onError 설정
  void initialize() {
    if (_isInitialized) {
      Logger.warning('ErrorReporterService already initialized');
      return;
    }

    Logger.info('🚨 Initializing ErrorReporterService');

    // 1. 동기 에러 캡처 (FlutterError)
    FlutterError.onError = (FlutterErrorDetails details) {
      // 원래 에러 핸들러 호출 (Flutter 기본 동작 유지)
      FlutterError.presentError(details);

      // 에러 리포팅
      _captureError(
        errorType: 'FlutterError',
        errorMessage: details.exceptionAsString(),
        stackTrace: details.stack,
        context: details.context?.toDescription(),
      );
    };

    // 2. 비동기 에러 캡처 (Zone errors)
    PlatformDispatcher.instance.onError = (error, stack) {
      _captureError(
        errorType: _classifyError(error),
        errorMessage: error.toString(),
        stackTrace: stack,
      );
      return true; // 에러 처리 완료
    };

    // 3. 주기적으로 에러 큐를 파일로 플러시 (5초마다)
    _flushTimer = Timer.periodic(Duration(seconds: 5), (_) {
      _flushErrorsToFile();
    });

    _isInitialized = true;
    Logger.info('✅ ErrorReporterService initialized successfully');
  }

  /// 에러 캡처 및 큐에 추가
  void _captureError({
    required String errorType,
    required String errorMessage,
    StackTrace? stackTrace,
    String? context,
  }) {
    try {
      // 에러 해시 생성 (중복 체크용)
      final errorHash = _generateErrorHash(errorMessage, stackTrace);

      // 이미 보고된 에러면 카운트만 증가
      if (_reportedErrorHashes.contains(errorHash)) {
        _incrementErrorCount(errorHash);
        return;
      }

      // 새 에러 기록
      final errorData = {
        'error_hash': errorHash,
        'error_type': errorType,
        'error_message': errorMessage,
        'stack_trace': _formatStackTrace(stackTrace),
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
        'build_mode': kDebugMode ? 'debug' : kReleaseMode ? 'release' : 'profile',
        'platform': Platform.operatingSystem,
        'occurrence_count': 1,
      };

      _errorQueue.add(errorData);
      _reportedErrorHashes.add(errorHash);

      Logger.error('🚨 Error captured: $errorType', errorMessage);

      // 즉시 플러시 (중요한 에러는 즉시 기록)
      if (_isCriticalError(errorType)) {
        _flushErrorsToFile();
      }
    } catch (e) {
      debugPrint('❌ Failed to capture error: $e');
    }
  }

  /// 에러 타입 자동 분류
  String _classifyError(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socket') || errorString.contains('network') || errorString.contains('connection')) {
      return 'NetworkError';
    } else if (errorString.contains('timeout')) {
      return 'TimeoutError';
    } else if (errorString.contains('renderbox') || errorString.contains('overflow')) {
      return 'UIRenderError';
    } else if (errorString.contains('assertion')) {
      return 'AssertionError';
    } else if (errorString.contains('null')) {
      return 'NullPointerError';
    } else if (error is Exception) {
      return 'Exception';
    } else if (error is Error) {
      return 'Error';
    } else {
      return 'UnknownError';
    }
  }

  /// Stack trace 포맷팅 (처음 10줄만)
  String _formatStackTrace(StackTrace? stackTrace) {
    if (stackTrace == null) return 'No stack trace available';

    final lines = stackTrace.toString().split('\n');
    final limitedLines = lines.take(10).join('\n');

    return limitedLines;
  }

  /// 에러 해시 생성 (중복 체크용)
  String _generateErrorHash(String errorMessage, StackTrace? stackTrace) {
    final combined = '$errorMessage${stackTrace?.toString() ?? ""}';
    return combined.hashCode.toString();
  }

  /// 같은 에러 발생 횟수 증가
  void _incrementErrorCount(String errorHash) {
    for (var error in _errorQueue) {
      if (error['error_hash'] == errorHash) {
        error['occurrence_count'] = (error['occurrence_count'] as int) + 1;
        error['last_occurrence'] = DateTime.now().toIso8601String();
        break;
      }
    }
  }

  /// 중요한 에러 여부 판단
  bool _isCriticalError(String errorType) {
    return errorType.contains('Network') ||
           errorType.contains('Assertion') ||
           errorType.contains('NullPointer');
  }

  /// 에러 큐를 JSON 파일로 플러시
  Future<void> _flushErrorsToFile() async {
    if (_errorQueue.isEmpty) return;

    try {
      final file = File(_errorLogPath);

      // 기존 에러 로드
      List<dynamic> existingErrors = [];
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          try {
            existingErrors = jsonDecode(content) as List<dynamic>;
          } catch (e) {
            Logger.warning('Failed to parse existing error log, creating new file');
          }
        }
      }

      // 새 에러 추가
      existingErrors.addAll(_errorQueue);

      // 파일 저장
      final jsonContent = JsonEncoder.withIndent('  ').convert(existingErrors);
      await file.writeAsString(jsonContent);

      Logger.info('💾 Flushed ${_errorQueue.length} errors to $_errorLogPath');

      // 큐 비우기
      _errorQueue.clear();
    } catch (e) {
      Logger.error('Failed to flush errors to file', e);
    }
  }

  /// 수동으로 에러 리포트 (테스트용)
  void reportManualError(String message, {StackTrace? stackTrace}) {
    _captureError(
      errorType: 'ManualReport',
      errorMessage: message,
      stackTrace: stackTrace,
      context: 'Manually reported error',
    );
  }

  /// 서비스 종료 시 정리
  void dispose() {
    _flushTimer?.cancel();
    _flushErrorsToFile(); // 마지막 에러 플러시
    _isInitialized = false;
    Logger.info('🛑 ErrorReporterService disposed');
  }
}
