import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/services/native_platform_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service for managing local notifications
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;
  
  /// Initialize notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize timezone
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      
      // Initialize native platform notifications
      await NativePlatformService.initialize();
      
      // Initialize Flutter local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings);
      
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap);
      
      _isInitialized = true;
      Logger.info('Notification service initialized');
    } catch (e) {
      Logger.error('Failed to initialize notification service', e);
    }
  }
  
  /// Request notification permissions
  static Future<bool> requestPermissions() async {
    try {
      // Request native permissions
      final nativePermission = await NativePlatformService.requestNotificationPermission();
      
      // Request Flutter permissions
      final flutterPermission = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true);
      
      return nativePermission && (flutterPermission ?? true);
    } catch (e) {
      Logger.error('Failed to request notification permissions', e);
      return false;
    }
  }
  
  /// Show immediate notification
  static Future<void> showNotification({
    required String id,
    required String title,
    required String body,
    String? payload}) async {
    if (!_isInitialized) await initialize()
    
    try {
      const androidDetails = AndroidNotificationDetails(
        'fortune_default',
        'Fortune Notifications',
        channelDescription: 'Notifications for fortune updates',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true);
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails);
      
      await _notifications.show(
        id.hashCode,
        title,
        body,
        details,
        payload: payload);
      
      Logger.info('Notification scheduled successfully');
    } catch (e) {
      Logger.error('Failed to show notification', e);
    }
  }
  
  /// Schedule a notification
  static Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    bool repeatDaily = false}) async {
    if (!_isInitialized) await initialize()
    
    try {
      const androidDetails = AndroidNotificationDetails(
        'fortune_scheduled',
        'Scheduled Fortune Notifications',
        channelDescription: 'Scheduled notifications for fortune reminders',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true);
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails);
      
      if (repeatDaily) {
        await _notifications.zonedSchedule(
          id.hashCode,
          title,
          body,
          _nextInstanceOfTime(scheduledTime),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload);
      } else {
        await _notifications.zonedSchedule(
          id.hashCode,
          title,
          body,
          tz.TZDateTime.from(scheduledTime, tz.local),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload);
      }
      
      // Also schedule using native platform service for better reliability
      await NativePlatformService.scheduleFortuneNotification(
        id: id,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        payload: payload != null ? {'payload': payload} : null);
      
      Logger.info('Notification scheduled successfully');
    } catch (e) {
      Logger.error('Failed to schedule notification', e);
    }
  }
  
  /// Cancel a scheduled notification
  static Future<void> cancelNotification(String id) async {
    try {
      await _notifications.cancel(id.hashCode);
      await NativePlatformService.cancelNotification(id);
      Logger.info('Notification scheduled successfully');
    } catch (e) {
      Logger.error('Failed to cancel notification', e);
    }
  }
  
  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      Logger.info('All notifications cancelled');
    } catch (e) {
      Logger.error('Failed to cancel all notifications', e);
    }
  }
  
  /// Schedule daily fortune reminder
  static Future<void> scheduleDailyFortuneReminder({
    required TimeOfDay time,
    bool enabled = true}) async {
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
      time.minute);
    
    await scheduleNotification(
      id: notificationId,
      title: '오늘의 운세 확인하기',
      body: '오늘의 운세와 행운의 숫자를 확인해보세요!',
      scheduledTime: scheduledTime,
      repeatDaily: true,
      payload: 'daily_fortune');
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
      dateTime.minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }
  
  /// Handle notification tap
  static void _onNotificationTap(NotificationResponse response) {
    Logger.info('tapped: ${response.payload}');
    // Handle navigation based on payload
    // This should be implemented based on your navigation structure
  }
}