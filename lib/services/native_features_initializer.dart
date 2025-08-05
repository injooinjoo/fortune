import 'package:flutter/material.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/services/live_activity_service.dart';
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

class NativeFeaturesInitializer {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      Logger.info('Initializing native platform features...');
      await NativePlatformService.initialize();
      await NotificationService.initialize();
      await WidgetDataManager.initialize();
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false);
      await _registerBackgroundTasks();
      WidgetService.widgetClicks.listen((uri) {
        if (uri != null) {
          WidgetDataManager.handleWidgetClick(uri.queryParameters);
        }
      });
      final initialData = await WidgetService.getInitialWidgetData();
      if (initialData != null) {
        await WidgetDataManager.handleWidgetClick(initialData);
      }
      _isInitialized = true;
      Logger.info('Native platform features initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize native features', e);
    }
  }

  static Future<bool> requestPermissions() async {
    try {
      final notificationPermission = await NotificationService.requestPermissions();
      if (!notificationPermission) {
        Logger.warning('Notification permission denied');
      }
      return notificationPermission;
    } catch (e) {
      Logger.error('Failed to request permissions', e);
      return false;
    }
  }

  static Future<void> _registerBackgroundTasks() async {
    try {
      await Workmanager().registerPeriodicTask(
        'widget_update_task',
        'widget_update',
        frequency: const Duration(hours: 1),
        constraints: Constraints(
          networkType: NetworkType.connected));
      await Workmanager().registerPeriodicTask(
        'daily_fortune_task',
        'daily_fortune_fetch',
        frequency: const Duration(days: 1),
        initialDelay: _calculateInitialDelay(6, 0),
        constraints: Constraints(
          networkType: NetworkType.connected));
      Logger.info('Background tasks registered');
    } catch (e) {
      Logger.error('Failed to register background tasks', e);
    }
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
    bool enabled = true}) async {
    await NotificationService.scheduleDailyFortuneReminder(
      time: TimeOfDay(hour: hour, minute: minute),
      enabled: enabled);
  }

  static Future<void> showTestNotification() async {
    await NotificationService.showNotification(
      id: 'test_notification',
      title: '운세 알림 테스트',
      body: '알림이 정상적으로 작동합니다!',
      payload: 'test');
  }

  static Future<void> updateDailyFortuneWidget(dynamic fortune) async {
    await WidgetDataManager.updateDailyFortune(fortune);
  }

  static Future<void> updateLoveFortuneWidget({
    required String partnerName,
    required int compatibilityScore,
    required String message}) async {
    await WidgetDataManager.updateLoveFortune(
      partnerName: partnerName,
      compatibilityScore: compatibilityScore,
      message: message);
  }
}
