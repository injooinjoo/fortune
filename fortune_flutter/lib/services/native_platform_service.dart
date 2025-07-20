import 'package:flutter/services.dart';
import 'package:fortune/core/utils/logger.dart';

/// Service for communicating with native platform features
/// Handles iOS and Android platform-specific functionality
class NativePlatformService {
  // Platform channels - made public for extensions
  static const MethodChannel iosChannel = MethodChannel('com.fortune.fortune/ios');
  static const MethodChannel androidChannel = MethodChannel('com.fortune.fortune/android');
  
  // Event channels for receiving native updates
  static const EventChannel _iosEventChannel = EventChannel('com.fortune.fortune/ios/events');
  static const EventChannel _androidEventChannel = EventChannel('com.fortune.fortune/android/events');
  
  // Get the appropriate channel based on platform
  static MethodChannel get _channel {
    if (const String.fromEnvironment('PLATFORM') == 'ios') {
      return iosChannel;
    } else if (const String.fromEnvironment('PLATFORM') == 'android') {
      return androidChannel;
    }
    // Default fallback
    return const MethodChannel('com.fortune.fortune/native');
  }
  
  static EventChannel get _eventChannel {
    if (const String.fromEnvironment('PLATFORM') == 'ios') {
      return _iosEventChannel;
    } else if (const String.fromEnvironment('PLATFORM') == 'android') {
      return _androidEventChannel;
    }
    return const EventChannel('com.fortune.fortune/native/events');
  }
  
  /// Initialize native platform features
  static Future<void> initialize() async {
    try {
      final result = await _channel.invokeMethod('initialize');
      Logger.info('Native platform initialized: $result');
    } on PlatformException catch (e) {
      Logger.error('Failed to initialize native platform', e);
    }
  }
  
  /// Update widget data on the native side
  static Future<void> updateWidget({
    required String widgetType,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _channel.invokeMethod('updateWidget', {
        'widgetType': widgetType,
        'data': data,
      });
      Logger.info('Widget updated: $widgetType');
    } on PlatformException catch (e) {
      Logger.error('Failed to update widget', e);
    }
  }
  
  /// Request permission for notifications
  static Future<bool> requestNotificationPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestNotificationPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      Logger.error('Failed to request notification permission', e);
      return false;
    }
  }
  
  /// Schedule a fortune notification
  static Future<void> scheduleFortuneNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, dynamic>? payload,
  }) async {
    try {
      await _channel.invokeMethod('scheduleNotification', {
        'id': id,
        'title': title,
        'body': body,
        'scheduledTime': scheduledTime.millisecondsSinceEpoch,
        'payload': payload,
      });
      Logger.info('Notification scheduled: $id');
    } on PlatformException catch (e) {
      Logger.error('Failed to schedule notification', e);
    }
  }
  
  /// Cancel a scheduled notification
  static Future<void> cancelNotification(String id) async {
    try {
      await _channel.invokeMethod('cancelNotification', {'id': id});
      Logger.info('Notification cancelled: $id');
    } on PlatformException catch (e) {
      Logger.error('Failed to cancel notification', e);
    }
  }
  
  /// Listen to native events
  static Stream<dynamic> get nativeEventStream {
    return _eventChannel.receiveBroadcastStream();
  }
  
  /// iOS specific methods
  static final iOS ios = iOS._();
  
  /// Android specific methods
  static final Android android = Android._();
}

class iOS {
  iOS._();
    /// Update Dynamic Island content
    static Future<void> updateDynamicIsland({
      required String activityId,
      required Map<String, dynamic> content,
    }) async {
      if (const String.fromEnvironment('PLATFORM') != 'ios') return;
      
      try {
        await NativePlatformService.iosChannel.invokeMethod('updateDynamicIsland', {
          'activityId': activityId,
          'content': content,
        });
        Logger.info('Dynamic Island updated: $activityId');
      } on PlatformException catch (e) {
        Logger.error('Failed to update Dynamic Island', e);
      }
    }
    
    /// Start a Live Activity
    static Future<String?> startLiveActivity({
      required Map<String, dynamic> attributes,
      required Map<String, dynamic> contentState,
    }) async {
      if (const String.fromEnvironment('PLATFORM') != 'ios') return null;
      
      try {
        final activityId = await NativePlatformService.iosChannel.invokeMethod<String>('startLiveActivity', {
          'attributes': attributes,
          'contentState': contentState,
        });
        Logger.info('Live Activity started: $activityId');
        return activityId;
      } on PlatformException catch (e) {
        Logger.error('Failed to start Live Activity', e);
        return null;
      }
    }
    
    /// End a Live Activity
    static Future<void> endLiveActivity(String activityId) async {
      if (const String.fromEnvironment('PLATFORM') != 'ios') return;
      
      try {
        await NativePlatformService.iosChannel.invokeMethod('endLiveActivity', {'activityId': activityId});
        Logger.info('Live Activity ended: $activityId');
      } on PlatformException catch (e) {
        Logger.error('Failed to end Live Activity', e);
      }
    }
    
    /// Add Siri shortcut
    static Future<void> addSiriShortcut({
      required String shortcutId,
      required String title,
      required String phrase,
      required Map<String, dynamic> userInfo,
    }) async {
      if (const String.fromEnvironment('PLATFORM') != 'ios') return;
      
      try {
        await NativePlatformService.iosChannel.invokeMethod('addSiriShortcut', {
          'shortcutId': shortcutId,
          'title': title,
          'phrase': phrase,
          'userInfo': userInfo,
        });
        Logger.info('Siri shortcut added: $shortcutId');
      } on PlatformException catch (e) {
        Logger.error('Failed to add Siri shortcut', e);
      }
    }
}

/// Android specific methods
class Android {
  Android._();
    /// Update home screen widget
    static Future<void> updateHomeWidget({
      required int widgetId,
      required Map<String, dynamic> data,
    }) async {
      if (const String.fromEnvironment('PLATFORM') != 'android') return;
      
      try {
        await NativePlatformService.androidChannel.invokeMethod('updateHomeWidget', {
          'widgetId': widgetId,
          'data': data,
        });
        Logger.info('Home widget updated: $widgetId');
      } on PlatformException catch (e) {
        Logger.error('Failed to update home widget', e);
      }
    }
    
    /// Apply Material You theming
    static Future<Map<String, dynamic>?> getMaterialYouColors() async {
      if (const String.fromEnvironment('PLATFORM') != 'android') return null;
      
      try {
        final colors = await NativePlatformService.androidChannel.invokeMethod<Map<String, dynamic>>('getMaterialYouColors');
        Logger.info('Material You colors retrieved');
        return colors;
      } on PlatformException catch (e) {
        Logger.error('Failed to get Material You colors', e);
        return null;
      }
    }
    
    /// Create notification channel
    static Future<void> createNotificationChannel({
      required String channelId,
      required String channelName,
      required String channelDescription,
      required int importance,
    }) async {
      if (const String.fromEnvironment('PLATFORM') != 'android') return;
      
      try {
        await NativePlatformService.androidChannel.invokeMethod('createNotificationChannel', {
          'channelId': channelId,
          'channelName': channelName,
          'channelDescription': channelDescription,
          'importance': importance,
        });
        Logger.info('Notification channel created: $channelId');
      } on PlatformException catch (e) {
        Logger.error('Failed to create notification channel', e);
      }
    }
}