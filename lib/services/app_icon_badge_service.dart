import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/resilient_service.dart';
import '../core/utils/logger.dart';

/// 앱 아이콘 배지 관리 서비스
///
/// OS 레벨의 앱 아이콘 배지(빨간 점)를 관리합니다.
/// - 아침 06:00에 조용히 배지 표시 (푸시 없이)
/// - 오늘의 운세 확인 시 배지 제거
/// - 숫자 없이 점(dot) 배지만 사용 (count=1)
class AppIconBadgeService extends ResilientService {
  static final AppIconBadgeService _instance = AppIconBadgeService._internal();
  factory AppIconBadgeService() => _instance;
  AppIconBadgeService._internal();

  @override
  String get serviceName => 'AppIconBadgeService';

  // SharedPreferences 키
  static const String _fortuneLastVisitKey = 'fortune_tab_last_visit';
  static const String _lastBadgeSetKey = 'app_badge_last_set';

  /// 서비스 초기화
  static Future<void> initialize() async {
    await _instance._initializeInternal();
  }

  Future<void> _initializeInternal() async {
    await safeExecute(
      () async {
        // 배지 지원 여부 확인
        final isSupported = await FlutterAppBadger.isAppBadgeSupported();
        if (isSupported) {
          Logger.info('앱 배지 지원됨');
        } else {
          Logger.warning('앱 배지 미지원 디바이스');
        }
      },
      '앱 배지 초기화',
      '배지 기능 비활성화',
    );
  }

  /// 배지 표시 (count=1로 dot 효과)
  static Future<void> showBadge() async {
    await _instance._showBadgeInternal();
  }

  Future<void> _showBadgeInternal() async {
    await safeExecute(
      () async {
        final isSupported = await FlutterAppBadger.isAppBadgeSupported();
        if (!isSupported) {
          Logger.warning('배지 미지원 디바이스, 표시 생략');
          return;
        }

        await FlutterAppBadger.updateBadgeCount(1);

        // 배지 설정 시간 기록
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            _lastBadgeSetKey, DateTime.now().toIso8601String());

        Logger.info('앱 아이콘 배지 표시됨');
      },
      '배지 표시',
      '배지 표시 실패',
    );
  }

  /// 숫자 배지 업데이트 (카카오톡 스타일)
  ///
  /// [count] 표시할 숫자 (0이면 배지 제거)
  static Future<void> updateBadgeCount(int count) async {
    await _instance._updateBadgeCountInternal(count);
  }

  Future<void> _updateBadgeCountInternal(int count) async {
    await safeExecute(
      () async {
        final isSupported = await FlutterAppBadger.isAppBadgeSupported();
        if (!isSupported) return;

        if (count > 0) {
          await FlutterAppBadger.updateBadgeCount(count);
          Logger.info('앱 아이콘 배지 업데이트: $count');
        } else {
          await FlutterAppBadger.removeBadge();
          Logger.info('앱 아이콘 배지 제거 (count=0)');
        }
      },
      '배지 카운트 업데이트',
      '배지 업데이트 실패',
    );
  }

  /// 배지 제거
  static Future<void> clearBadge() async {
    await _instance._clearBadgeInternal();
  }

  Future<void> _clearBadgeInternal() async {
    await safeExecute(
      () async {
        final isSupported = await FlutterAppBadger.isAppBadgeSupported();
        if (!isSupported) return;

        await FlutterAppBadger.removeBadge();
        Logger.info('앱 아이콘 배지 제거됨');
      },
      '배지 제거',
      '배지 제거 실패',
    );
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

  /// 아침 배지 체크 (백그라운드 태스크에서 호출)
  ///
  /// 06:00~08:00 사이에 호출되며,
  /// 오늘 운세를 아직 확인하지 않았으면 배지를 표시합니다.
  static Future<void> checkAndSetMorningBadge() async {
    await _instance._checkAndSetMorningBadgeInternal();
  }

  Future<void> _checkAndSetMorningBadgeInternal() async {
    await safeExecute(
      () async {
        final viewedToday = await isFortuneViewedToday();

        if (!viewedToday) {
          await showBadge();
          Logger.info('아침 배지 표시됨 (운세 미확인)');
        } else {
          Logger.info('아침 배지 생략 (이미 운세 확인함)');
        }
      },
      '아침 배지 체크',
      '아침 배지 표시 실패',
    );
  }

  /// 운세 확인 시 호출 (배지 클리어)
  static Future<void> onFortuneViewed() async {
    await clearBadge();
  }
}
