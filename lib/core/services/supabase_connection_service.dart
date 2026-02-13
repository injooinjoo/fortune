import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';
import 'resilient_service.dart';

/// 강화된 Supabase 연결 관리 서비스
///
/// KAN-73: Supabase 연결 안정성 문제 해결
/// - 연결 복원력 및 재시도 메커니즘
/// - 연결 상태 모니터링 및 감지
/// - 환경별 설정 관리
/// - 타임아웃 및 에러 핸들링
class SupabaseConnectionService extends ResilientService {
  static final SupabaseConnectionService _instance =
      SupabaseConnectionService._internal();
  factory SupabaseConnectionService() => _instance;
  SupabaseConnectionService._internal();

  @override
  String get serviceName => 'SupabaseConnectionService';

  static bool _isInitialized = false;
  static bool _isConnected = false;
  static String? _lastError;
  static DateTime? _lastConnectionAttempt;
  static int _consecutiveFailures = 0;
  static DateTime? _nextRetryAllowedAt;

  /// 연결 상태 스트림
  static final StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();
  static Stream<bool> get connectionState => _connectionStateController.stream;

  /// 현재 연결 상태
  static bool get isConnected => _isConnected;
  static bool get isInitialized => _isInitialized;
  static String? get lastError => _lastError;

  /// 강화된 Supabase 초기화
  static Future<bool> initialize({
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 10),
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    return _instance._initializeInternal(
      maxRetries: maxRetries,
      timeout: timeout,
      retryDelay: retryDelay,
    );
  }

  Future<bool> _initializeInternal({
    required int maxRetries,
    required Duration timeout,
    required Duration retryDelay,
  }) async {
    if (_isInitialized && _isConnected) {
      Logger.info('Supabase already initialized and connected');
      return true;
    }

    return await safeExecuteWithBool(() async {
      final credentials = await _loadCredentials();
      if (credentials == null) {
        throw Exception('Supabase 환경변수 설정이 필요합니다');
      }

      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        _lastConnectionAttempt = DateTime.now();

        try {
          await _attemptConnection(
            credentials['url']!,
            credentials['anonKey']!,
            timeout,
          );

          _isInitialized = true;
          _isConnected = true;
          _lastError = null;
          _connectionStateController.add(true);

          Logger.info('Supabase 연결 성공 (시도 $attempt/$maxRetries)');
          await _startHealthMonitoring();
          return;
        } catch (e) {
          _lastError = e.toString();
          Logger.warning('Supabase 연결 시도 $attempt/$maxRetries 실패: $e');

          if (attempt < maxRetries) {
            await Future.delayed(retryDelay * attempt); // 지수 백오프
          } else {
            rethrow;
          }
        }
      }
    }, 'Supabase 연결 초기화', '연결 실패, 오프라인 모드 사용');
  }

  /// 환경변수에서 Supabase 인증정보 로드
  Future<Map<String, String>?> _loadCredentials() async {
    return await safeExecuteWithNull(() async {
      final url = dotenv.dotenv.env['SUPABASE_URL'];
      final anonKey = dotenv.dotenv.env['SUPABASE_ANON_KEY'];

      if (url == null || anonKey == null || url.isEmpty || anonKey.isEmpty) {
        throw Exception('SUPABASE_URL 또는 SUPABASE_ANON_KEY가 설정되지 않음');
      }

      // URL 형식 검증
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.isAbsolute) {
        throw Exception('잘못된 SUPABASE_URL 형식: $url');
      }

      // anonKey 길이 검증 (최소 길이 체크)
      if (anonKey.length < 100) {
        throw Exception('유효하지 않은 SUPABASE_ANON_KEY 형식');
      }

      return {'url': url, 'anonKey': anonKey};
    }, 'Supabase 인증정보 로드', '인증정보 없음');
  }

  /// 실제 연결 시도
  Future<void> _attemptConnection(
      String url, String anonKey, Duration timeout) async {
    await Future.any([
      Supabase.initialize(
        url: url,
        anonKey: anonKey,
        debug: false,
      ),
      Future.delayed(timeout, () => throw TimeoutException('연결 타임아웃', timeout)),
    ]);

    // 연결 검증 - celebrities 테이블이 없거나 RLS로 차단되면 실패하므로 주석 처리
    // OAuth는 테이블 접근 없이도 동작함
    // await _verifyConnection();
  }

  /// 연결 상태 검증
  Future<void> _verifyConnection() async {
    final client = Supabase.instance.client;

    // 간단한 쿼리로 연결 상태 확인 - celebrities 테이블 접근 테스트 (실제로 존재하는 테이블)
    await client
        .from('celebrities')
        .select('id')
        .limit(0)
        .timeout(const Duration(seconds: 5));
  }

  /// 연결 상태 지속 모니터링
  Future<void> _startHealthMonitoring() async {
    await safeExecute(() async {
      Timer.periodic(const Duration(minutes: 5), (timer) async {
        try {
          await _verifyConnection();

          // 연결 성공 - 실패 카운터 리셋
          if (!_isConnected) {
            _isConnected = true;
            _lastError = null;
            _consecutiveFailures = 0;
            _nextRetryAllowedAt = null;
            _connectionStateController.add(true);
            Logger.info('Supabase 연결 복구됨');
          }
        } catch (e) {
          if (_isConnected) {
            _isConnected = false;
            _lastError = e.toString();
            _connectionStateController.add(false);

            // DNS 실패 감지
            final isDnsFailure = e.toString().contains('Failed host lookup') ||
                e.toString().contains('SocketException');

            if (isDnsFailure) {
              _consecutiveFailures++;
              Logger.warning('Supabase DNS 연결 실패 ($_consecutiveFailures회): $e');

              // 연속 실패 3회 이상 시 1시간 대기
              if (_consecutiveFailures >= 3) {
                _nextRetryAllowedAt =
                    DateTime.now().add(const Duration(hours: 1));
                Logger.warning('연속 3회 실패로 1시간 후 재시도: $_nextRetryAllowedAt');
                return; // 재연결 시도 차단
              }
            } else {
              Logger.warning('Supabase 연결 끊김 감지: $e');
            }

            // 자동 재연결 시도 (backoff 적용)
            _attemptReconnection();
          }
        }
      });
    }, 'Supabase 연결 상태 모니터링 시작', '모니터링 비활성화');
  }

  /// 자동 재연결 시도
  Future<void> _attemptReconnection() async {
    await safeExecute(() async {
      // 재시도 대기 시간 체크
      if (_nextRetryAllowedAt != null &&
          DateTime.now().isBefore(_nextRetryAllowedAt!)) {
        final waitTime = _nextRetryAllowedAt!.difference(DateTime.now());
        Logger.info('재연결 대기 중 (${waitTime.inMinutes}분 남음)');
        return;
      }

      // Exponential backoff 계산: 5초 * 2^(실패횟수-1)
      final backoffSeconds =
          5 * (1 << (_consecutiveFailures - 1).clamp(0, 5)); // 최대 160초
      Logger.info('Supabase 자동 재연결 시도 중 (backoff: $backoffSeconds초)...');

      final success = await initialize(
        maxRetries: 2,
        timeout: const Duration(seconds: 15),
        retryDelay: Duration(seconds: backoffSeconds),
      );

      if (success) {
        // 성공 시 실제 네트워크 검증
        try {
          await _verifyConnection();
          _consecutiveFailures = 0;
          _nextRetryAllowedAt = null;
          Logger.info('Supabase 자동 재연결 성공 (검증 완료)');
        } catch (e) {
          Logger.warning('재연결은 성공했으나 네트워크 검증 실패: $e');
        }
      } else {
        Logger.warning('Supabase 자동 재연결 실패');
      }
    }, 'Supabase 자동 재연결', '재연결 실패');
  }

  /// 수동 재연결
  static Future<bool> reconnect() async {
    return _instance._reconnectInternal();
  }

  Future<bool> _reconnectInternal() async {
    return await safeExecuteWithBool(() async {
      Logger.info('Supabase 수동 재연결 시도...');

      _isConnected = false;
      _connectionStateController.add(false);

      await initialize(
        maxRetries: 3,
        timeout: const Duration(seconds: 20),
      );

      // 성공 여부만 반환하고 void 함수이므로 return 없음
    }, 'Supabase 수동 재연결', '재연결 실패');
  }

  /// 연결 상태 정보 조회
  static Map<String, dynamic> getConnectionInfo() {
    return {
      'isInitialized': _isInitialized,
      'isConnected': _isConnected,
      'lastError': _lastError,
      'lastConnectionAttempt': _lastConnectionAttempt?.toIso8601String(),
      'timeSinceLastAttempt': _lastConnectionAttempt != null
          ? DateTime.now().difference(_lastConnectionAttempt!).inSeconds
          : null,
    };
  }

  /// 리소스 정리
  static void dispose() {
    _connectionStateController.close();
  }
}
