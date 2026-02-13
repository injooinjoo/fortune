import '../utils/logger.dart';

/// 선택적 기능에 대한 강화된 에러 처리를 제공하는 기본 서비스 클래스
///
/// 이 클래스는 앱의 모든 서비스에서 공통적으로 사용되는
/// "선택적 기능" 패턴을 표준화하여 견고한 에러 처리를 제공합니다.
///
/// **핵심 원칙**:
/// - 서비스 실패가 앱 전체를 중단시키지 않음
/// - 일관된 에러 메시지 패턴 제공
/// - 적절한 fallback 값 반환
/// - 한국어 에러 메시지로 사용자 친화적 로깅
abstract class ResilientService {
  /// 서비스 이름 (로깅에 사용)
  String get serviceName;

  /// 선택적 기능 실행 - 안전한 void 작업
  ///
  /// [operation]: 실행할 비동기 작업
  /// [operationName]: 작업 이름 (로깅용)
  /// [fallbackMessage]: 실패 시 추가 안내 메시지
  ///
  /// 예시:
  /// ```dart
  /// await safeExecute(
  ///   () => uploadFile(file),
  ///   'file upload',
  ///   '파일 업로드 기능 비활성화'
  /// );
  /// ```
  Future<void> safeExecute(
    Future<void> Function() operation,
    String operationName,
    String fallbackMessage,
  ) async {
    try {
      await operation();
    } catch (e) {
      Logger.warning(
          '[$serviceName] $operationName 실패 (선택적 기능, $fallbackMessage): $e');
    }
  }

  /// 선택적 기능 실행 - null 반환형
  ///
  /// [operation]: 실행할 비동기 작업
  /// [operationName]: 작업 이름 (로깅용)
  /// [fallbackMessage]: 실패 시 추가 안내 메시지
  ///
  /// 예시:
  /// ```dart
  /// final result = await safeExecuteWithNull(
  ///   () => getUserProfile(userId),
  ///   'profile fetch',
  ///   'null 반환'
  /// );
  /// ```
  Future<T?> safeExecuteWithNull<T>(
    Future<T> Function() operation,
    String operationName,
    String fallbackMessage,
  ) async {
    try {
      return await operation();
    } catch (e) {
      Logger.warning(
          '[$serviceName] $operationName 실패 (선택적 기능, $fallbackMessage): $e');
      return null;
    }
  }

  /// 선택적 기능 실행 - fallback 값 반환형
  ///
  /// [operation]: 실행할 비동기 작업
  /// [fallbackValue]: 실패 시 반환할 기본값
  /// [operationName]: 작업 이름 (로깅용)
  /// [fallbackMessage]: 실패 시 추가 안내 메시지
  ///
  /// 예시:
  /// ```dart
  /// final pets = await safeExecuteWithFallback(
  ///   () => fetchUserPets(userId),
  ///   <PetProfile>[],
  ///   'pets fetch',
  ///   '빈 목록 반환'
  /// );
  /// ```
  Future<T> safeExecuteWithFallback<T>(
    Future<T> Function() operation,
    T fallbackValue,
    String operationName,
    String fallbackMessage,
  ) async {
    try {
      return await operation();
    } catch (e) {
      Logger.warning(
          '[$serviceName] $operationName 실패 (선택적 기능, $fallbackMessage): $e');
      return fallbackValue;
    }
  }

  /// 선택적 기능 실행 - bool 반환형 (성공/실패)
  ///
  /// [operation]: 실행할 비동기 작업
  /// [operationName]: 작업 이름 (로깅용)
  /// [fallbackMessage]: 실패 시 추가 안내 메시지
  ///
  /// 예시:
  /// ```dart
  /// final success = await safeExecuteWithBool(
  ///   () => sendNotification(message),
  ///   'notification send',
  ///   'false 반환'
  /// );
  /// ```
  Future<bool> safeExecuteWithBool(
    Future<void> Function() operation,
    String operationName,
    String fallbackMessage,
  ) async {
    try {
      await operation();
      return true;
    } catch (e) {
      Logger.warning(
          '[$serviceName] $operationName 실패 (선택적 기능, $fallbackMessage): $e');
      return false;
    }
  }

  /// 비동기 선택적 기능 실행 - fallback 함수 실행
  ///
  /// [operation]: 실행할 주요 비동기 작업
  /// [fallback]: 실패 시 실행할 대체 비동기 작업
  /// [operationName]: 작업 이름 (로깅용)
  /// [fallbackMessage]: 실패 시 추가 안내 메시지
  ///
  /// 예시:
  /// ```dart
  /// final data = await safeExecuteWithFallbackFunction(
  ///   () => fetchFromApi(),
  ///   () => getCachedData(),
  ///   'API 데이터 조회',
  ///   '캐시된 데이터로 대체'
  /// );
  /// ```
  Future<T> safeExecuteWithFallbackFunction<T>(
    Future<T> Function() operation,
    Future<T> Function() fallback,
    String operationName,
    String fallbackMessage,
  ) async {
    try {
      return await operation();
    } catch (e) {
      Logger.warning(
          '[$serviceName] $operationName 실패 (선택적 기능, $fallbackMessage): $e');
      try {
        return await fallback();
      } catch (fallbackError) {
        Logger.warning(
            '[$serviceName] $operationName fallback도 실패: $fallbackError');
        rethrow;
      }
    }
  }

  /// 동기 선택적 기능 실행 - fallback 값 반환형
  ///
  /// [operation]: 실행할 동기 작업
  /// [fallbackValue]: 실패 시 반환할 기본값
  /// [operationName]: 작업 이름 (로깅용)
  /// [fallbackMessage]: 실패 시 추가 안내 메시지
  Future<T> safeExecuteSyncWithFallback<T>(
    T Function() operation,
    T fallbackValue,
    String operationName,
    String fallbackMessage,
  ) async {
    try {
      return operation();
    } catch (e) {
      Logger.warning(
          '[$serviceName] $operationName 실패 (선택적 기능, $fallbackMessage): $e');
      return fallbackValue;
    }
  }

  /// 권한 확인과 함께 실행하는 선택적 기능
  ///
  /// [permissionCheck]: 권한 확인 함수
  /// [operation]: 권한이 있을 때 실행할 작업
  /// [fallbackValue]: 권한 없거나 실패 시 반환값
  /// [operationName]: 작업 이름 (로깅용)
  /// [permissionMessage]: 권한 없을 때 메시지
  /// [fallbackMessage]: 실패 시 메시지
  Future<T> safeExecuteWithPermission<T>(
    Future<bool> Function() permissionCheck,
    Future<T> Function() operation,
    T fallbackValue,
    String operationName,
    String permissionMessage,
    String fallbackMessage,
  ) async {
    try {
      final hasPermission = await permissionCheck();
      if (!hasPermission) {
        Logger.warning(
            '[$serviceName] $operationName 권한 없음 (선택적 기능, $permissionMessage): 권한 없음');
        return fallbackValue;
      }

      return await operation();
    } catch (e) {
      Logger.warning(
          '[$serviceName] $operationName 실패 (선택적 기능, $fallbackMessage): $e');
      return fallbackValue;
    }
  }

  /// 여러 시도를 통한 선택적 기능 실행
  ///
  /// [operations]: 순서대로 시도할 작업 목록
  /// [fallbackValue]: 모든 시도 실패 시 반환값
  /// [operationName]: 작업 이름 (로깅용)
  /// [fallbackMessage]: 실패 시 메시지
  Future<T> safeExecuteWithRetry<T>(
    List<Future<T> Function()> operations,
    T fallbackValue,
    String operationName,
    String fallbackMessage,
  ) async {
    for (int i = 0; i < operations.length; i++) {
      try {
        return await operations[i]();
      } catch (e) {
        if (i == operations.length - 1) {
          // 마지막 시도도 실패
          Logger.warning(
              '[$serviceName] $operationName 모든 시도 실패 (선택적 기능, $fallbackMessage): $e');
          return fallbackValue;
        }
        // 다음 시도로 계속
        Logger.warning(
            '[$serviceName] $operationName 시도 ${i + 1} 실패, 다음 시도 진행: $e');
      }
    }

    return fallbackValue;
  }

  /// 조건부 선택적 기능 실행
  ///
  /// [condition]: 실행 조건
  /// [operation]: 조건이 true일 때 실행할 작업
  /// [fallbackValue]: 조건이 false이거나 실패 시 반환값
  /// [operationName]: 작업 이름 (로깅용)
  /// [conditionMessage]: 조건 불만족 시 메시지
  /// [fallbackMessage]: 실패 시 메시지
  Future<T> safeExecuteWithCondition<T>(
    bool condition,
    Future<T> Function() operation,
    T fallbackValue,
    String operationName,
    String conditionMessage,
    String fallbackMessage,
  ) async {
    if (!condition) {
      Logger.warning(
          '[$serviceName] $operationName 조건 불만족 (선택적 기능, $conditionMessage): 조건 불만족');
      return fallbackValue;
    }

    try {
      return await operation();
    } catch (e) {
      Logger.warning(
          '[$serviceName] $operationName 실패 (선택적 기능, $fallbackMessage): $e');
      return fallbackValue;
    }
  }
}
