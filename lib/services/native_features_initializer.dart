import 'package:flutter/material.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/core/services/resilient_service.dart';
import 'package:fortune/services/native_platform_service.dart';
import 'package:fortune/services/notification_service.dart';
import 'package:fortune/services/widget_data_manager.dart';
import 'package:fortune/services/widget_service.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case 'widget_update':
          await WidgetDataManager.initialize();
          return true;
        case 'daily_fortune_fetch':
          return true;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  });
}

class NativeFeaturesInitializer extends ResilientService {
  static bool _isInitialized = false;
  static final NativeFeaturesInitializer _instance = NativeFeaturesInitializer._internal();

  factory NativeFeaturesInitializer() => _instance;
  NativeFeaturesInitializer._internal();

  @override
  String get serviceName => 'NativeFeaturesInitializer';

  static Future<void> initialize() async => _instance._initializeInternal();

  Future<void> _initializeInternal() async {
    if (_isInitialized) return;

    Logger.info('Initializing native platform features...');

    final success = await safeExecuteWithRetry([
      () => _initializeCoreServices(),
      () => _initializeBackgroundServices(),
      () => _initializeWidgetServices(),
    ],
    false,
    '네이티브 기능 종합 초기화',
    '네이티브 기능 비활성화'
    );

    if (success) {
      _isInitialized = true;
      Logger.info('Native platform features initialized successfully');
    }
  }

  Future<bool> _initializeCoreServices() async {
    return await safeExecuteWithBool(
      () async {
        await NativePlatformService.initialize();
        await NotificationService.initialize();
        await WidgetDataManager.initialize();
      },
      '핵심 네이티브 서비스 초기화',
      '핵심 서비스 초기화 실패'
    );
  }

  Future<bool> _initializeBackgroundServices() async {
    return await safeExecuteWithBool(
      () async {
        await Workmanager().initialize(
          callbackDispatcher,
          isInDebugMode: false
        );
        await _registerBackgroundTasks();
      },
      '백그라운드 서비스 초기화',
      '백그라운드 작업 비활성화'
    );
  }

  Future<bool> _initializeWidgetServices() async {
    return await safeExecuteWithBool(
      () async {
        // Widget click listener setup
        await safeExecute(
          () async {
            WidgetService.widgetClicks.listen((uri) {
              if (uri != null) {
                WidgetDataManager.handleWidgetClick(uri.queryParameters);
              }
            });
          },
          '위젯 클릭 리스너 설정',
          '위젯 클릭 감지 비활성화'
        );

        // Initial widget data handling
        await safeExecute(
          () async {
            final initialData = await WidgetService.getInitialWidgetData();
            if (initialData != null) {
              await WidgetDataManager.handleWidgetClick(initialData);
            }
          },
          '초기 위젯 데이터 처리',
          '초기 위젯 데이터 무시'
        );
      },
      '위젯 서비스 초기화',
      '위젯 기능 비활성화'
    );
  }

  static Future<bool> requestPermissions() async => _instance._requestPermissionsInternal();

  Future<bool> _requestPermissionsInternal() async {
    return await safeExecuteWithBool(
      () async {
        final notificationPermission = await NotificationService.requestPermissions();
        if (!notificationPermission) {
          throw Exception('사용자가 알림 권한을 거부했습니다');
        }
      },
      '알림 권한 요청',
      '권한 없이 계속 진행'
    );
  }

  Future<void> _registerBackgroundTasks() async {
    await safeExecute(
      () async {
        await Workmanager().registerPeriodicTask(
          'widget_update_task',
          'widget_update',
          frequency: const Duration(hours: 1),
          constraints: Constraints(
            networkType: NetworkType.connected
          )
        );
      },
      '위젯 업데이트 백그라운드 작업 등록',
      '위젯 자동 업데이트 비활성화'
    );

    await safeExecute(
      () async {
        await Workmanager().registerPeriodicTask(
          'daily_fortune_task',
          'daily_fortune_fetch',
          frequency: const Duration(days: 1),
          initialDelay: _calculateInitialDelay(6, 0),
          constraints: Constraints(
            networkType: NetworkType.connected
          )
        );
      },
      '일일 운세 백그라운드 작업 등록',
      '일일 운세 자동 갱신 비활성화'
    );

    Logger.info('Background tasks registration completed');
  }

  static Duration _calculateInitialDelay(int hour, int minute) {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    return scheduledTime.difference(now);
  }

  static Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
    bool enabled = true,
  }) async => _instance._scheduleDailyNotificationInternal(hour, minute, enabled);

  Future<void> _scheduleDailyNotificationInternal(int hour, int minute, bool enabled) async {
    await safeExecute(
      () async {
        await NotificationService.scheduleDailyFortuneReminder(
          time: TimeOfDay(hour: hour, minute: minute),
          enabled: enabled,
        );
      },
      '일일 운세 알림 예약',
      '알림 예약 실패, 수동 확인 필요'
    );
  }

  static Future<void> showTestNotification() async => _instance._showTestNotificationInternal();

  Future<void> _showTestNotificationInternal() async {
    await safeExecute(
      () async {
        await NotificationService.showNotification(
          id: 'test_notification',
          title: '운세 알림 테스트',
          body: '알림이 정상적으로 작동합니다!',
          payload: 'test',
        );
      },
      '테스트 알림 표시',
      '테스트 알림 표시 실패'
    );
  }

  static Future<void> updateDailyFortuneWidget(dynamic fortune) async =>
    _instance._updateDailyFortuneWidgetInternal(fortune);

  Future<void> _updateDailyFortuneWidgetInternal(dynamic fortune) async {
    await safeExecute(
      () async {
        await WidgetDataManager.updateDailyFortune(fortune);
      },
      '일일 운세 위젯 업데이트',
      '위젯 업데이트 생략'
    );
  }

  static Future<void> updateLoveFortuneWidget({
    required String partnerName,
    required int compatibilityScore,
    required String message,
  }) async => _instance._updateLoveFortuneWidgetInternal(partnerName, compatibilityScore, message);

  Future<void> _updateLoveFortuneWidgetInternal(
    String partnerName,
    int compatibilityScore,
    String message
  ) async {
    await safeExecute(
      () async {
        await WidgetDataManager.updateLoveFortune(
          partnerName: partnerName,
          compatibilityScore: compatibilityScore,
          message: message,
        );
      },
      '사랑 운세 위젯 업데이트',
      '위젯 업데이트 생략'
    );
  }
}
