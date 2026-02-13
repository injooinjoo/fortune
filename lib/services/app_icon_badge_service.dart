import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/resilient_service.dart';
import '../core/utils/logger.dart';

/// 앱 아이콘 배지 관리 서비스 (No-op 버전)
///
/// flutter_app_badger 패키지가 discontinued되어 Android 빌드 에러가 발생하여
/// 임시로 비활성화됨. 나중에 대체 패키지로 복구 가능.
class AppIconBadgeService extends ResilientService {
  static final AppIconBadgeService _instance = AppIconBadgeService._internal();
  factory AppIconBadgeService() => _instance;
  AppIconBadgeService._internal();

  @override
  String get serviceName => 'AppIconBadgeService';

  // SharedPreferences 키
  static const String _fortuneLastVisitKey = 'fortune_tab_last_visit';

  /// 서비스 초기화
  static Future<void> initialize() async {
    Logger.info('앱 배지 서비스 비활성화됨 (flutter_app_badger 제거됨)');
  }

  /// 배지 표시 (no-op)
  static Future<void> showBadge() async {
    // No-op: flutter_app_badger 제거됨
  }

  /// 숫자 배지 업데이트 (no-op)
  static Future<void> updateBadgeCount(int count) async {
    // No-op: flutter_app_badger 제거됨
  }

  /// 배지 제거 (no-op)
  static Future<void> clearBadge() async {
    // No-op: flutter_app_badger 제거됨
  }

  /// 오늘 운세를 확인했는지 검사
  static Future<bool> isFortuneViewedToday() async {
    return await _instance._isFortuneViewedTodayInternal();
  }

  Future<bool> _isFortuneViewedTodayInternal() async {
    return await safeExecuteWithFallback(
      () async {
        final prefs = await SharedPreferences.getInstance();
        final lastVisit = prefs.getString(_fortuneLastVisitKey);

        if (lastVisit == null) return false;

        final lastVisitDate = DateTime.tryParse(lastVisit);
        if (lastVisitDate == null) return false;

        final today = DateTime.now();
        return lastVisitDate.year == today.year &&
            lastVisitDate.month == today.month &&
            lastVisitDate.day == today.day;
      },
      false,
      '운세 확인 상태 조회',
      'false 반환',
    );
  }

  /// 아침 배지 체크 (no-op)
  static Future<void> checkAndSetMorningBadge() async {
    // No-op: flutter_app_badger 제거됨
  }

  /// 운세 확인 시 호출 (no-op)
  static Future<void> onFortuneViewed() async {
    // No-op: flutter_app_badger 제거됨
  }
}
