import 'package:universal_io/io.dart';
import 'package:flutter/services.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/core/services/resilient_service.dart';

/// Service for communicating with native platform features
/// Handles iOS and Android platform-specific functionality
class NativePlatformService extends ResilientService {
  static final NativePlatformService _instance = NativePlatformService._internal();
  factory NativePlatformService() => _instance;
  NativePlatformService._internal();

  @override
  String get serviceName => 'NativePlatformService';

  // Platform channels - made public for extensions
  static const MethodChannel iosChannel = MethodChannel('com.fortune.fortune/ios');
  static const MethodChannel androidChannel = MethodChannel('com.fortune.fortune/android');

  // Event channels for receiving native updates
  static const EventChannel _iosEventChannel = EventChannel('com.fortune.fortune/ios/events');
  static const EventChannel _androidEventChannel = EventChannel('com.fortune.fortune/android/events');

  // Improved platform detection using Platform.isIOS/isAndroid
  static bool get _isIOS => Platform.isIOS;
  static bool get _isAndroid => Platform.isAndroid;

  // Get the appropriate channel based on actual platform
  static MethodChannel get _channel {
    if (_isIOS) {
      return iosChannel;
    } else if (_isAndroid) {
      return androidChannel;
    }
    // Fallback channel for unsupported platforms
    return const MethodChannel('com.fortune.fortune/native');
  }

  static EventChannel get _eventChannel {
    if (_isIOS) {
      return _iosEventChannel;
    } else if (_isAndroid) {
      return _androidEventChannel;
    }
    return const EventChannel('com.fortune.fortune/native/events');
  }
  
  /// Initialize native platform features
  static Future<void> initialize() async => _instance._initializeInternal();

  Future<void> _initializeInternal() async {
    await safeExecute(
      () async {
        final result = await _channel.invokeMethod('initialize');
        Logger.info('Native platform initialized successfully: $result');
      },
      '네이티브 플랫폼 초기화',
      '네이티브 기능 비활성화'
    );
  }
  
  /// Update widget data on the native side
  static Future<void> updateWidget({
    required String widgetType,
    required Map<String, dynamic> data}) async {
    try {
      await _channel.invokeMethod('updateWidget', {
        'widgetType': widgetType,
        'data': data});
      Logger.info('Native platform initialized successfully');
    } on PlatformException catch (e) {
      Logger.warning('[NativePlatformService] 위젯 업데이트 실패 (선택적 기능, 위젯 데이터 비활성화): $e');
    }
  }
  
  /// Request permission for notifications
  static Future<bool> requestNotificationPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestNotificationPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      Logger.warning('[NativePlatformService] 노티피케이션 권한 요청 실패 (선택적 기능, 수동 설정 필요): $e');
      return false;
    }
  }
  
  /// Schedule a fortune notification
  static Future<void> scheduleFortuneNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, dynamic>? payload}) async {
    try {
      await _channel.invokeMethod('scheduleNotification', {
        'id': id,
        'title': title,
        'body': body,
        'scheduledTime': scheduledTime.millisecondsSinceEpoch,
        'payload': payload});
      Logger.info('Native platform initialized successfully');
    } on PlatformException catch (e) {
      Logger.warning('[NativePlatformService] 노티피케이션 예약 실패 (선택적 기능, 수동 알림 설정 필요): $e');
    }
  }
  
  /// Cancel a scheduled notification
  static Future<void> cancelNotification(String id) async {
    try {
      await _channel.invokeMethod('cancelNotification', {'id': id});
      Logger.info('Native platform initialized successfully');
    } on PlatformException catch (e) {
      Logger.warning('[NativePlatformService] 노티피케이션 취소 실패 (선택적 기능, 예약된 알림 유지): $e');
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

class iOS extends ResilientService {
  iOS._();

  @override
  String get serviceName => 'NativePlatformService.iOS';

  /// Update Dynamic Island content
  Future<void> updateDynamicIsland({
    required String activityId,
    required Map<String, dynamic> content,
  }) async {
    await safeExecuteWithCondition(
      NativePlatformService._isIOS,
      () async {
        await NativePlatformService.iosChannel.invokeMethod('updateDynamicIsland', {
          'activityId': activityId,
          'content': content,
        });
      },
      null,
      '다이내믹 아일랜드 업데이트',
      'iOS 플랫폼 필요',
      '다이내믹 아일랜드 기능 비활성화'
    );
  }
    
    /// Start a Live Activity
  Future<String?> startLiveActivity({
      required Map<String, dynamic> attributes,
      required Map<String, dynamic> contentState}) async {
      if (const String.fromEnvironment('PLATFORM') != 'ios') return null;
      
      try {
        final activityId = await NativePlatformService.iosChannel.invokeMethod<String>('startLiveActivity', {
          'attributes': attributes,
          'contentState': contentState});
        Logger.info('Native platform initialized successfully');
        return activityId;
      } on PlatformException catch (e) {
        Logger.warning('[NativePlatformService] 라이브 액티비티 시작 실패 (선택적 기능, iOS 16.1+ 전용): $e');
        return null;
      }
    }
    
    /// End a Live Activity
  Future<void> endLiveActivity(String activityId) async {
      if (const String.fromEnvironment('PLATFORM') != 'ios') return;
      
      try {
        await NativePlatformService.iosChannel.invokeMethod('endLiveActivity', {'activityId': activityId});
        Logger.info('Native platform initialized successfully');
      } on PlatformException catch (e) {
        Logger.warning('[NativePlatformService] 라이브 액티비티 종료 실패 (선택적 기능, iOS 16.1+ 전용): $e');
      }
    }
    
    /// Add Siri shortcut
  Future<void> addSiriShortcut({
      required String shortcutId,
      required String title,
      required String phrase,
      required Map<String, dynamic> userInfo}) async {
      if (const String.fromEnvironment('PLATFORM') != 'ios') return;
      
      try {
        await NativePlatformService.iosChannel.invokeMethod('addSiriShortcut', {
          'shortcutId': shortcutId,
          'title': title,
          'phrase': phrase,
          'userInfo': userInfo});
        Logger.info('Native platform initialized successfully');
      } on PlatformException catch (e) {
        Logger.warning('[NativePlatformService] Siri 단축어 추가 실패 (선택적 기능, iOS 전용): $e');
      }
    }
}

/// Android specific methods
class Android {
  Android._();
  
  /// Update home screen widget
  Future<void> updateHomeWidget({
      required int widgetId,
      required Map<String, dynamic> data}) async {
      if (const String.fromEnvironment('PLATFORM') != 'android') return;
      
      try {
        await NativePlatformService.androidChannel.invokeMethod('updateHomeWidget', {
          'widgetId': widgetId,
          'data': data});
        Logger.info('Native platform initialized successfully');
      } on PlatformException catch (e) {
        Logger.warning('[NativePlatformService] 홈 위젯 업데이트 실패 (선택적 기능, Android 전용): $e');
      }
    }
    
    /// Apply Material You theming
  Future<Map<String, dynamic>?> getMaterialYouColors() async {
      if (const String.fromEnvironment('PLATFORM') != 'android') return null;
      
      try {
        final colors = await NativePlatformService.androidChannel.invokeMethod<Map<String, dynamic>>('getMaterialYouColors');
        Logger.info('Material You colors retrieved');
        return colors;
      } on PlatformException catch (e) {
        Logger.warning('[NativePlatformService] Material You 색상 가져오기 실패 (선택적 기능, Android 12+ 전용): $e');
        return null;
      }
    }
    
    /// Create notification channel
    static Future<void> createNotificationChannel({
      required String channelId,
      required String channelName,
      required String channelDescription,
      required int importance}) async {
      if (const String.fromEnvironment('PLATFORM') != 'android') return;
      
      try {
        await NativePlatformService.androidChannel.invokeMethod('createNotificationChannel', {
          'channelId': channelId,
          'channelName': channelName,
          'channelDescription': channelDescription,
          'importance': null});
        Logger.info('Native platform initialized successfully');
      } on PlatformException catch (e) {
        Logger.warning('[NativePlatformService] 노티피케이션 채널 생성 실패 (선택적 기능, Android 전용): $e');
      }
    }
}