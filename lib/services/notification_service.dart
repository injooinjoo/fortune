import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_native_timezone/flutter_native_timezone.dart';  // AGP 8.x compatibility issue
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/core/theme/theme_keys.dart';
import 'package:fortune/services/native_platform_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:go_router/go_router.dart';

/// Service for managing local notifications
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      // Temporarily using default timezone due to flutter_native_timezone compatibility issue
      // final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
      // tz.setLocalLocation(tz.getLocation(timeZoneName));
      tz.setLocalLocation(
          tz.getLocation('Asia/Seoul')); // Default to Seoul timezone

      // Initialize native platform notifications
      await NativePlatformService.initialize();

      // Initialize Flutter local notifications
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      _isInitialized = true;
      Logger.info('Notification service initialized');
    } catch (e) {
      Logger.warning(
          '[NotificationService] 노티피케이션 서비스 초기화 실패 (선택적 기능, 노티피케이션 비활성화): $e');
    }
  }

  /// Request notification permissions
  static Future<bool> requestPermissions() async {
    try {
      // Request native permissions
      final nativePermission =
          await NativePlatformService.requestNotificationPermission();

      // Request Flutter permissions
      final flutterPermission = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      return nativePermission && (flutterPermission ?? true);
    } catch (e) {
      Logger.warning(
          '[NotificationService] 노티피케이션 권한 요청 실패 (선택적 기능, 수동 설정 필요): $e');
      return false;
    }
  }

  /// Show immediate notification
  static Future<void> showNotification(
      {required String id,
      required String title,
      required String body,
      String? payload}) async {
    if (!_isInitialized) await initialize();

    try {
      const androidDetails = AndroidNotificationDetails(
        'fortune_default',
        'Fortune Notifications',
        channelDescription: 'Notifications for fortune updates',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        id.hashCode,
        title,
        body,
        details,
        payload: payload,
      );

      Logger.info('Notification scheduled successfully');
    } catch (e) {
      Logger.warning(
          '[NotificationService] 노티피케이션 표시 실패 (선택적 기능, 앱 내 메시지 사용): $e');
    }
  }

  /// Schedule a notification
  static Future<void> scheduleNotification(
      {required String id,
      required String title,
      required String body,
      required DateTime scheduledTime,
      String? payload,
      bool repeatDaily = false}) async {
    if (!_isInitialized) await initialize();

    try {
      const androidDetails = AndroidNotificationDetails(
        'fortune_scheduled',
        'Scheduled Fortune Notifications',
        channelDescription: 'Scheduled notifications for fortune reminders',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      if (repeatDaily) {
        await _notifications.zonedSchedule(
          id.hashCode,
          title,
          body,
          _nextInstanceOfTime(scheduledTime),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
      } else {
        await _notifications.zonedSchedule(
          id.hashCode,
          title,
          body,
          tz.TZDateTime.from(scheduledTime, tz.local),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
      }

      // Also schedule using native platform service for better reliability
      await NativePlatformService.scheduleFortuneNotification(
        id: id,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        payload: payload != null ? {'payload': payload} : null,
      );

      Logger.info('Notification scheduled successfully');
    } catch (e) {
      Logger.warning(
          '[NotificationService] 노티피케이션 예약 실패 (선택적 기능, 수동 알림 설정 필요): $e');
    }
  }

  /// Cancel a scheduled notification
  static Future<void> cancelNotification(String id) async {
    try {
      await _notifications.cancel(id.hashCode);
      await NativePlatformService.cancelNotification(id);
      Logger.info('Notification scheduled successfully');
    } catch (e) {
      Logger.warning(
          '[NotificationService] 노티피케이션 취소 실패 (선택적 기능, 예약된 알림 유지): $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      Logger.info('All notifications cancelled');
    } catch (e) {
      Logger.warning(
          '[NotificationService] 전체 노티피케이션 취소 실패 (선택적 기능, 예약된 알림 유지): $e');
    }
  }

  /// Schedule daily fortune reminder
  static Future<void> scheduleDailyFortuneReminder(
      {required TimeOfDay time, bool enabled = true}) async {
    const notificationId = 'daily_fortune_reminder';

    if (!enabled) {
      await cancelNotification(notificationId);
      return;
    }

    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    await scheduleNotification(
      id: notificationId,
      title: '오늘의 운세 확인하기',
      body: '오늘의 운세와 행운의 숫자를 확인해보세요!',
      scheduledTime: scheduledTime,
      repeatDaily: true,
      payload: 'daily_fortune',
    );
  }

  /// Helper method to get next instance of time
  static tz.TZDateTime _nextInstanceOfTime(DateTime dateTime) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      dateTime.hour,
      dateTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Handle notification tap
  static void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) {
      return;
    }

    final payload = response.payload!;
    Logger.info('tapped: $payload');

    // 기존 문자열 payload: character_chat:characterId
    if (payload.startsWith('character_chat:')) {
      final characterId = payload.split(':').last;
      _handleNavigationPayload(
          {'type': 'character_dm', 'character_id': characterId});
      return;
    }

    // JSON payload
    final parsedPayload = _tryDecodePayload(payload);
    if (parsedPayload != null) {
      _handleNavigationPayload(parsedPayload);
    } else {
      Logger.warning('[NotificationService] 알림 페이로드 파싱 실패');
    }
  }

  static Map<String, dynamic>? _tryDecodePayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static void _handleNavigationPayload(Map<String, dynamic> data) {
    final type = data['type'];
    final route = data['route'] as String?;
    final characterId =
        data['character_id']?.toString() ?? data['characterId']?.toString();
    final appContext = appNavigatorKey.currentContext;

    if (appContext == null) {
      Logger.warning('[NotificationService] 네비게이션 컨텍스트 없음');
      return;
    }

    if (route != null && route.isNotEmpty) {
      GoRouter.of(appContext).go(route);
      return;
    }

    if (type == 'character_dm' || type == 'character_follow_up') {
      if (characterId != null && characterId.isNotEmpty) {
        final encodedCharacterId = Uri.encodeComponent(characterId);
        GoRouter.of(appContext)
            .go('/character/$encodedCharacterId?openCharacterChat=true');
      }
      return;
    }
  }
}
