import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';
import '../core/utils/logger.dart';
import '../core/services/resilient_service.dart';
import 'native_platform_service.dart';

/// 강화된 iOS Live Activities 및 Dynamic Island 서비스
///
/// KAN-80: Live Activities 플랫폼 채널 안정성 문제 해결
/// - ResilientService 패턴 적용
/// - 플랫폼 채널 연결 상태 모니터링
/// - iOS 버전 호환성 검증 강화
/// - 실패 시 graceful degradation
class LiveActivityService extends ResilientService {
  static final LiveActivityService _instance = LiveActivityService._internal();
  factory LiveActivityService() => _instance;
  LiveActivityService._internal();

  @override
  String get serviceName => 'LiveActivityService';

  final Map<String, String> _activeActivities = {};

  /// 강화된 Live Activities 지원 여부 확인 (안전한 플랫폼 검증)
  bool get isSupported {
    try {
      if (defaultTargetPlatform != TargetPlatform.iOS || !Platform.isIOS) {
        return false;
      }

      // iOS 버전 파싱 안전성 강화
      final versionString = Platform.operatingSystemVersion;
      final match = RegExp(r'(\d+)\.(\d+)').firstMatch(versionString);
      if (match == null) return false;

      final majorVersion = int.parse(match.group(1)!);
      final minorVersion = int.parse(match.group(2)!);

      // iOS 16.1+ 필요 (Live Activities 최소 요구사항)
      return majorVersion > 16 || (majorVersion == 16 && minorVersion >= 1);
    } catch (e) {
      Logger.warning(
          '[$serviceName] Live Activities 지원 여부 확인 실패 (선택적 기능, iOS 버전 검증 실패): $e');
      return false;
    }
  }

  /// 강화된 운세 Live Activity 시작 (ResilientService 패턴)
  Future<String?> startFortuneActivity({
    required String fortuneType,
    required Map<String, dynamic> initialData,
  }) async {
    return await safeExecuteWithNull(() async {
      // 1. 플랫폼 지원 여부 확인
      if (!isSupported) {
        throw Exception('Live Activities는 iOS 16.1+ 에서만 지원됩니다');
      }

      // 2. 네이티브 플랫폼 서비스 통신
      final activityId = await NativePlatformService.ios.startLiveActivity(
        attributes: {
          'fortuneType': fortuneType,
          'startedAt': DateTime.now().toIso8601String(),
        },
        contentState: initialData,
      );

      // 3. 성공 시 상태 관리
      if (activityId != null) {
        _activeActivities[fortuneType] = activityId;
        Logger.info('Live Activity 시작 성공: $fortuneType = $activityId');
        return activityId;
      } else {
        throw Exception('Native platform에서 null 반환');
      }
    }, 'Live Activity 시작: $fortuneType', 'Live Activity 시작 실패, 기능 비활성화');
  }

  /// 강화된 Live Activity 업데이트 (ResilientService 패턴)
  Future<void> updateFortuneActivity({
    required String fortuneType,
    required Map<String, dynamic> updatedData,
  }) async {
    await safeExecute(() async {
      // 1. 플랫폼 지원 여부 확인
      if (!isSupported) {
        throw Exception('Live Activities는 iOS 16.1+ 에서만 지원됩니다');
      }

      // 2. 활성 Activity 확인
      final activityId = _activeActivities[fortuneType];
      if (activityId == null) {
        throw Exception('활성화된 Live Activity가 없습니다: $fortuneType');
      }

      // 3. Dynamic Island 업데이트
      await NativePlatformService.ios.updateDynamicIsland(
        activityId: activityId,
        content: {
          ...updatedData,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      Logger.info('Live Activity 업데이트 성공: $fortuneType');
    }, 'Live Activity 업데이트: $fortuneType', 'Live Activity 업데이트 실패, 기능 유지');
  }

  /// 강화된 Live Activity 종료 (ResilientService 패턴)
  Future<void> endFortuneActivity(String fortuneType) async {
    await safeExecute(() async {
      // 1. 플랫폼 지원 여부 확인
      if (!isSupported) {
        throw Exception('Live Activities는 iOS 16.1+ 에서만 지원됩니다');
      }

      // 2. 활성 Activity 확인
      final activityId = _activeActivities[fortuneType];
      if (activityId == null) {
        throw Exception('활성화된 Live Activity가 없습니다: $fortuneType');
      }

      // 3. Live Activity 종료
      await NativePlatformService.ios.endLiveActivity(activityId);

      // 4. 성공 시 상태 정리
      _activeActivities.remove(fortuneType);
      Logger.info('Live Activity 종료 성공: $fortuneType');
    }, 'Live Activity 종료: $fortuneType', 'Live Activity 종료 실패, 상태는 유지');
  }

  /// 강화된 모든 Live Activities 종료 (ResilientService 패턴)
  Future<void> endAllActivities() async {
    await safeExecute(() async {
      // 1. 플랫폼 지원 여부 확인
      if (!isSupported) {
        throw Exception('Live Activities는 iOS 16.1+ 에서만 지원됩니다');
      }

      // 2. 활성 Activities 복사 (수정 중 concurrent modification 방지)
      final activeFortuneTypes = List<String>.from(_activeActivities.keys);

      // 3. 각 Activity 순차적으로 종료
      for (final fortuneType in activeFortuneTypes) {
        await endFortuneActivity(fortuneType);
      }

      Logger.info('모든 Live Activities 종료 완료 (${activeFortuneTypes.length}개)');
    }, '모든 Live Activities 종료', '일부 Live Activities 종료 실패, 상태는 유지');
  }

  /// 일일 운세 Live Activity 시작 (헬퍼 메서드)
  Future<String?> startDailyFortune({
    required String score,
    required String message,
    required String luckyColor,
    required String luckyNumber,
  }) async {
    return await startFortuneActivity(
      fortuneType: 'daily',
      initialData: {
        'score': score,
        'message': message,
        'luckyColor': luckyColor,
        'luckyNumber': luckyNumber,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// 궁합 체크 Live Activity 시작 (헬퍼 메서드)
  Future<String?> startCompatibilityCheck({
    required String userName,
    required String partnerName,
    required String status,
  }) async {
    return await startFortuneActivity(
      fortuneType: 'compatibility',
      initialData: {
        'userName': userName,
        'partnerName': partnerName,
        'status': status,
        'progress': 0,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// 궁합 체크 진행 상황 업데이트 (헬퍼 메서드)
  Future<void> updateCompatibilityProgress({
    required int progress,
    required String status,
    String? score,
    String? message,
  }) async {
    await updateFortuneActivity(
      fortuneType: 'compatibility',
      updatedData: {
        'progress': progress,
        'status': status,
        'score': score,
        'message': message,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// 싱글톤 인스턴스 접근을 위한 정적 getter
  static LiveActivityService get instance => _instance;
}
