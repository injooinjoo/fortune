import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/models/shared_widget_data.dart';
import 'package:fortune/services/native_platform_service.dart';
import 'package:fortune/services/widget_data_service.dart';
import 'package:home_widget/home_widget.dart';

/// Service for managing home screen widgets
/// 새 위젯 시스템: 총운, 카테고리, 시간대, 로또 위젯 지원
class WidgetService {
  static const String appGroupId = 'group.com.beyond.fortune';

  // 새 위젯 이름들
  static const String overallWidgetName = 'FortuneOverallWidget';
  static const String categoryWidgetName = 'FortuneCategoryWidget';
  static const String timeSlotWidgetName = 'FortuneTimeSlotWidget';
  static const String lottoWidgetName = 'FortuneLottoWidget';

  // 백그라운드 새로고침용 Method Channel
  static const MethodChannel _backgroundChannel =
      MethodChannel('com.beyond.fortune/widget_refresh');

  // 현재 사용자 ID 캐시 (백그라운드 새로고침 시 사용)
  static String? _cachedUserId;

  /// Initialize widget service
  static Future<void> initialize() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HomeWidget.setAppGroupId(appGroupId);
      }
      await WidgetDataService.initialize();

      // 백그라운드 새로고침 핸들러 등록
      _setupBackgroundRefreshHandler();

      Logger.info('[WidgetService] 위젯 서비스 초기화 완료');
    } catch (e) {
      Logger.warning('[WidgetService] 위젯 서비스 초기화 실패 (선택적 기능): $e');
    }
  }

  /// 백그라운드 새로고침 핸들러 설정
  static void _setupBackgroundRefreshHandler() {
    _backgroundChannel.setMethodCallHandler((call) async {
      if (call.method == 'refreshWidgetData') {
        Logger.info('[WidgetService] 백그라운드 새로고침 요청 수신');
        await _handleBackgroundRefresh();
        return {'success': true};
      }
      return {'success': false, 'error': 'Unknown method'};
    });
  }

  /// 백그라운드에서 위젯 데이터 새로고침
  static Future<void> _handleBackgroundRefresh() async {
    try {
      // 캐시된 사용자 ID가 없으면 저장된 데이터에서 로드 시도
      if (_cachedUserId == null) {
        Logger.warning('[WidgetService] 캐시된 사용자 ID 없음, 저장된 데이터 로드 시도');
        // 저장된 데이터가 있으면 그대로 위젯 갱신만 수행
        final existingData = await WidgetDataService.loadWidgetData();
        if (existingData != null && existingData.isValidForToday) {
          await updateAllWidgetsFromData(existingData);
          Logger.info('[WidgetService] 기존 데이터로 위젯 갱신 완료');
          return;
        }
        Logger.warning('[WidgetService] 백그라운드 새로고침 건너뜀: 사용자 ID 필요');
        return;
      }

      await forceRefreshWidgetData(_cachedUserId!);
      Logger.info('[WidgetService] 백그라운드 새로고침 완료');
    } catch (e) {
      Logger.warning('[WidgetService] 백그라운드 새로고침 실패: $e');
    }
  }

  /// 사용자 ID 캐시 설정 (로그인 시 호출)
  static void setUserId(String userId) {
    _cachedUserId = userId;
    Logger.info('[WidgetService] 사용자 ID 캐시 설정: ${userId.substring(0, 8)}...');
  }

  /// 사용자 ID 캐시 해제 (로그아웃 시 호출)
  static void clearUserId() {
    _cachedUserId = null;
    Logger.info('[WidgetService] 사용자 ID 캐시 해제');
  }

  /// 위젯 데이터 새로고침 (앱 시작 시 또는 운세 조회 후 호출)
  static Future<void> refreshWidgetData(String userId) async {
    try {
      // 오늘 데이터가 이미 있는지 확인
      final isValid = await WidgetDataService.isDataValidForToday();
      if (isValid) {
        Logger.info('[WidgetService] 오늘 위젯 데이터 이미 존재');
        return;
      }

      // 새 데이터 fetch 및 저장
      await WidgetDataService.fetchAndSaveForWidget(userId: userId);
      Logger.info('[WidgetService] 위젯 데이터 새로고침 완료');
    } catch (e) {
      Logger.warning('[WidgetService] 위젯 데이터 새로고침 실패: $e');
    }
  }

  /// 강제 위젯 데이터 새로고침 (오늘 데이터가 있어도 갱신)
  static Future<void> forceRefreshWidgetData(String userId) async {
    try {
      await WidgetDataService.fetchAndSaveForWidget(userId: userId);
      Logger.info('[WidgetService] 위젯 데이터 강제 새로고침 완료');
    } catch (e) {
      Logger.warning('[WidgetService] 위젯 데이터 강제 새로고침 실패: $e');
    }
  }

  /// 총운 위젯 업데이트
  static Future<void> updateOverallWidget({
    required int score,
    required String grade,
    required String message,
    String? description,
  }) async {
    try {
      await HomeWidget.saveWidgetData<int>('overall_score', score);
      await HomeWidget.saveWidgetData<String>('overall_grade', grade);
      await HomeWidget.saveWidgetData<String>('overall_message', message);
      if (description != null) {
        await HomeWidget.saveWidgetData<String>('overall_description', description);
      }

      await _updateLastUpdated();
      await _notifyWidget(overallWidgetName);
      Logger.info('[WidgetService] 총운 위젯 업데이트 완료');
    } catch (e) {
      Logger.warning('[WidgetService] 총운 위젯 업데이트 실패: $e');
    }
  }

  /// 카테고리 위젯 업데이트
  static Future<void> updateCategoryWidget({
    required String category,
    required String name,
    required int score,
    required String message,
    required String icon,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('category_key', category);
      await HomeWidget.saveWidgetData<String>('category_name', name);
      await HomeWidget.saveWidgetData<int>('category_score', score);
      await HomeWidget.saveWidgetData<String>('category_message', message);
      await HomeWidget.saveWidgetData<String>('category_icon', icon);

      await _updateLastUpdated();
      await _notifyWidget(categoryWidgetName);
      Logger.info('[WidgetService] 카테고리 위젯 업데이트 완료: $category');
    } catch (e) {
      Logger.warning('[WidgetService] 카테고리 위젯 업데이트 실패: $e');
    }
  }

  /// 시간대 위젯 업데이트
  static Future<void> updateTimeSlotWidget({
    required String timeSlotName,
    required int score,
    required String message,
    required String icon,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('timeslot_name', timeSlotName);
      await HomeWidget.saveWidgetData<int>('timeslot_score', score);
      await HomeWidget.saveWidgetData<String>('timeslot_message', message);
      await HomeWidget.saveWidgetData<String>('timeslot_icon', icon);

      await _updateLastUpdated();
      await _notifyWidget(timeSlotWidgetName);
      Logger.info('[WidgetService] 시간대 위젯 업데이트 완료: $timeSlotName');
    } catch (e) {
      Logger.warning('[WidgetService] 시간대 위젯 업데이트 실패: $e');
    }
  }

  /// 로또 위젯 업데이트
  static Future<void> updateLottoWidget({
    required List<int> numbers,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('lotto_numbers', numbers.join(', '));

      await _updateLastUpdated();
      await _notifyWidget(lottoWidgetName);
      Logger.info('[WidgetService] 로또 위젯 업데이트 완료: ${numbers.join(", ")}');
    } catch (e) {
      Logger.warning('[WidgetService] 로또 위젯 업데이트 실패: $e');
    }
  }

  /// SharedWidgetData로 모든 위젯 업데이트
  static Future<void> updateAllWidgetsFromData(SharedWidgetData data) async {
    try {
      // 총운 위젯
      await updateOverallWidget(
        score: data.overall.score,
        grade: data.overall.grade,
        message: data.overall.message,
        description: data.overall.description,
      );

      // 시간대 위젯 (현재 시간대)
      final currentSlot = data.currentTimeSlot;
      if (currentSlot != null) {
        await updateTimeSlotWidget(
          timeSlotName: currentSlot.name,
          score: currentSlot.score,
          message: currentSlot.message,
          icon: currentSlot.icon,
        );
      }

      // 로또 위젯
      await updateLottoWidget(numbers: data.lottoNumbers);

      // 카테고리 위젯은 사용자가 선택한 카테고리에 따라 업데이트
      // 저장된 선택 카테고리 확인
      final selectedCategory = await HomeWidget.getWidgetData<String>('selected_category') ?? 'love';
      final categoryData = data.categories[selectedCategory];
      if (categoryData != null) {
        await updateCategoryWidget(
          category: categoryData.key,
          name: categoryData.name,
          score: categoryData.score,
          message: categoryData.message,
          icon: categoryData.icon,
        );
      }

      Logger.info('[WidgetService] 모든 위젯 업데이트 완료');
    } catch (e) {
      Logger.warning('[WidgetService] 전체 위젯 업데이트 실패: $e');
    }
  }

  /// 마지막 업데이트 시간 저장
  static Future<void> _updateLastUpdated() async {
    final now = DateTime.now();
    final lastUpdated = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    await HomeWidget.saveWidgetData<String>('last_updated', lastUpdated);

    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await HomeWidget.saveWidgetData<String>('valid_date', todayStr);
  }

  /// 특정 위젯에 업데이트 알림
  static Future<void> _notifyWidget(String widgetName) async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HomeWidget.updateWidget(iOSName: widgetName);
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        // Android 위젯 이름은 다를 수 있음
        final androidName = _getAndroidWidgetName(widgetName);
        await HomeWidget.updateWidget(androidName: androidName);
      }
    } catch (e) {
      Logger.warning('[WidgetService] 위젯 알림 실패: $widgetName - $e');
    }
  }

  /// iOS 위젯 이름을 Android 위젯 이름으로 변환
  static String _getAndroidWidgetName(String iosName) {
    switch (iosName) {
      case 'FortuneOverallWidget':
        return 'OverallAppWidget';
      case 'FortuneCategoryWidget':
        return 'CategoryAppWidget';
      case 'FortuneTimeSlotWidget':
        return 'TimeSlotAppWidget';
      case 'FortuneLottoWidget':
        return 'LottoAppWidget';
      default:
        return iosName;
    }
  }

  /// 모든 위젯 업데이트 알림
  static Future<void> notifyAllWidgets() async {
    try {
      await NativePlatformService.updateWidget(
        widgetType: 'all',
        data: {'action': 'refresh'},
      );

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HomeWidget.updateWidget(iOSName: overallWidgetName);
        await HomeWidget.updateWidget(iOSName: categoryWidgetName);
        await HomeWidget.updateWidget(iOSName: timeSlotWidgetName);
        await HomeWidget.updateWidget(iOSName: lottoWidgetName);
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        await HomeWidget.updateWidget(androidName: 'OverallAppWidget');
        await HomeWidget.updateWidget(androidName: 'CategoryAppWidget');
        await HomeWidget.updateWidget(androidName: 'TimeSlotAppWidget');
        await HomeWidget.updateWidget(androidName: 'LottoAppWidget');
      }

      Logger.info('[WidgetService] 모든 위젯 업데이트 알림 완료');
    } catch (e) {
      Logger.warning('[WidgetService] 전체 위젯 알림 실패: $e');
    }
  }

  /// Register widget update callback
  static void registerUpdateCallback(Future<void> Function(Uri?) callback) {
    HomeWidget.registerInteractivityCallback(callback);
  }

  /// Get initial widget data (when app is launched from widget)
  static Future<Map<String, dynamic>?> getInitialWidgetData() async {
    try {
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (uri != null) {
        return uri.queryParameters;
      }
    } catch (e) {
      Logger.warning('[WidgetService] 초기 위젯 데이터 가져오기 실패: $e');
    }
    return null;
  }

  /// Listen to widget clicks
  static Stream<Uri?> get widgetClicks => HomeWidget.widgetClicked;

  /// 카테고리 위젯의 선택된 카테고리 저장
  static Future<void> setSelectedCategory(String category) async {
    try {
      await HomeWidget.saveWidgetData<String>('selected_category', category);

      // 저장된 데이터에서 해당 카테고리 정보 로드하여 위젯 업데이트
      final widgetData = await WidgetDataService.loadWidgetData();
      if (widgetData != null) {
        final categoryData = widgetData.categories[category];
        if (categoryData != null) {
          await updateCategoryWidget(
            category: categoryData.key,
            name: categoryData.name,
            score: categoryData.score,
            message: categoryData.message,
            icon: categoryData.icon,
          );
        }
      }

      Logger.info('[WidgetService] 선택 카테고리 변경: $category');
    } catch (e) {
      Logger.warning('[WidgetService] 선택 카테고리 저장 실패: $e');
    }
  }

  /// 선택된 카테고리 조회
  static Future<String> getSelectedCategory() async {
    try {
      return await HomeWidget.getWidgetData<String>('selected_category') ?? 'love';
    } catch (e) {
      return 'love';
    }
  }

  // ============================================
  // 구 API 호환성 (WidgetDataManager 지원)
  // ============================================

  /// [Deprecated] 일일 운세 위젯 업데이트 (구 API)
  /// 새 코드에서는 updateOverallWidget 사용 권장
  static Future<void> updateDailyFortuneWidget({
    required String score,
    required String message,
    required String detailedFortune,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final scoreInt = int.tryParse(score) ?? 50;
      final grade = scoreInt >= 80 ? '상' : (scoreInt >= 50 ? '중' : '하');

      await updateOverallWidget(
        score: scoreInt,
        grade: grade,
        message: message,
        description: detailedFortune,
      );
      Logger.info('[WidgetService] 구 API - 일일 운세 위젯 업데이트 완료');
    } catch (e) {
      Logger.warning('[WidgetService] 구 API - 일일 운세 위젯 업데이트 실패: $e');
    }
  }

  /// [Deprecated] 사랑 운세 위젯 업데이트 (구 API)
  /// 새 코드에서는 updateCategoryWidget 사용 권장
  static Future<void> updateLoveFortuneWidget({
    required String compatibilityScore,
    required String partnerName,
    required String message,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final scoreInt = int.tryParse(compatibilityScore) ?? 50;

      await updateCategoryWidget(
        category: 'love',
        name: '연애운',
        score: scoreInt,
        message: '$partnerName: $message',
        icon: '💕',
      );
      Logger.info('[WidgetService] 구 API - 사랑 운세 위젯 업데이트 완료');
    } catch (e) {
      Logger.warning('[WidgetService] 구 API - 사랑 운세 위젯 업데이트 실패: $e');
    }
  }
}
