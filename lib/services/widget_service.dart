import 'package:flutter/foundation.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/services/native_platform_service.dart';
import 'package:home_widget/home_widget.dart';

/// Service for managing home screen and lock screen widgets
class WidgetService {
  static const String appGroupId = 'group.com.fortune.fortune';
  static const String dailyFortuneWidgetKey = 'daily_fortune_widget';
  static const String loveFortuneWidgetKey = 'love_fortune_widget';
  
  /// Initialize widget service
  static Future<void> initialize() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HomeWidget.setAppGroupId(appGroupId);
      }
      Logger.info('Widget service initialized');
    } catch (e) {
      Logger.error('Failed to initialize widget service', e);
    }
  }
  
  /// Update daily fortune widget
  static Future<void> updateDailyFortuneWidget({
    required String score,
    required String message,
    String? detailedFortune,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final now = DateTime.now();
      final lastUpdated = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
      
      // Save data using HomeWidget
      await HomeWidget.saveWidgetData<String>('score', score);
      await HomeWidget.saveWidgetData<String>('message', message);
      await HomeWidget.saveWidgetData<String>('lastUpdated', lastUpdated);
      
      if (detailedFortune != null) {
        await HomeWidget.saveWidgetData<String>('detailedFortune', detailedFortune);
      }
      
      // Update native widget
      await NativePlatformService.updateWidget(
        widgetType: 'fortune_daily',
        data: {
          'score': score,
          'message': message,
          'lastUpdated': lastUpdated,
          'detailedFortune': detailedFortune ?? '',
          ...?additionalData,
        },
      );
      
      // Reload widget
      await HomeWidget.updateWidget(
        name: dailyFortuneWidgetKey,
        iOSName: 'FortuneDailyWidget',
        androidName: 'FortuneDailyWidget',
      );
      
      Logger.info('Daily fortune widget updated');
    } catch (e) {
      Logger.error('Failed to update daily fortune widget', e);
    }
  }
  
  /// Update love fortune widget
  static Future<void> updateLoveFortuneWidget({
    required String compatibilityScore,
    required String partnerName,
    required String message,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final now = DateTime.now();
      final lastUpdated = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
      
      // Save data using HomeWidget
      await HomeWidget.saveWidgetData<String>('compatibilityScore', compatibilityScore);
      await HomeWidget.saveWidgetData<String>('partnerName', partnerName);
      await HomeWidget.saveWidgetData<String>('loveMessage', message);
      await HomeWidget.saveWidgetData<String>('lastUpdated', lastUpdated);
      
      // Update native widget
      await NativePlatformService.updateWidget(
        widgetType: 'fortune_love',
        data: {
          'compatibilityScore': compatibilityScore,
          'partnerName': partnerName,
          'message': message,
          'lastUpdated': lastUpdated,
          ...?additionalData,
        },
      );
      
      // Reload widget
      await HomeWidget.updateWidget(
        name: loveFortuneWidgetKey,
        iOSName: 'FortuneLoveWidget',
        androidName: 'FortuneLoveWidget',
      );
      
      Logger.info('Love fortune widget updated');
    } catch (e) {
      Logger.error('Failed to update love fortune widget', e);
    }
  }
  
  /// Register widget update callback
  static void registerUpdateCallback(Future<void> Function(Uri?) callback) {
    HomeWidget.registerBackgroundCallback(callback);
  }
  
  /// Get initial widget data (when app is launched from widget,
  static Future<Map<String, dynamic>?> getInitialWidgetData() async {
    try {
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (uri != null) {
        return uri.queryParameters;
      }
    } catch (e) {
      Logger.error('Failed to get initial widget data', e);
    }
    return null;
  }
  
  /// Listen to widget clicks
  static Stream<Uri?> get widgetClicks => HomeWidget.widgetClicked;
}