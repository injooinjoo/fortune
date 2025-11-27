import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/services/native_platform_service.dart';
import 'package:home_widget/home_widget.dart';

/// Service for managing home screen and lock screen widgets
class WidgetService {
  static const String appGroupId = 'group.com.beyond.fortune';
  static const String dailyFortuneWidgetKey = 'daily_fortune_widget';
  static const String loveFortuneWidgetKey = 'love_fortune_widget';
  static const String favoritesWidgetKey = 'favorites_fortune_widget';

  // Keys for favorites widget data (must match iOS/Android native code)
  static const String keyFavorites = 'fortune_favorites';
  static const String keyRollingIndex = 'widget_rolling_index';
  static const String keyFortuneCachePrefix = 'widget_fortune_cache_';
  
  /// Initialize widget service
  static Future<void> initialize() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HomeWidget.setAppGroupId(appGroupId);
      }
      Logger.info('Widget service initialized');
    } catch (e) {
      Logger.warning('[WidgetService] 위젯 서비스 초기화 실패 (선택적 기능, 위젯 비활성화): $e');
    }
  }
  
  /// Update daily fortune widget
  static Future<void> updateDailyFortuneWidget({
    required String score,
    required String message,
    String? detailedFortune,
    Map<String, dynamic>? additionalData}) async {
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
          ...?additionalData});
      
      // Reload widget
      await HomeWidget.updateWidget(
        name: dailyFortuneWidgetKey,
        iOSName: 'FortuneDailyWidget',
        androidName: 'FortuneDailyWidget');
      
      Logger.info('Daily fortune widget updated');
    } catch (e) {
      Logger.warning('[WidgetService] 일일 운세 위젯 업데이트 실패 (선택적 기능, 위젯 비활성화): $e');
    }
  }
  
  /// Update love fortune widget
  static Future<void> updateLoveFortuneWidget({
    required String compatibilityScore,
    required String partnerName,
    required String message,
    Map<String, dynamic>? additionalData}) async {
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
          ...?additionalData});
      
      // Reload widget
      await HomeWidget.updateWidget(
        name: loveFortuneWidgetKey,
        iOSName: 'FortuneLoveWidget',
        androidName: 'FortuneLoveWidget');
      
      Logger.info('Love fortune widget updated');
    } catch (e) {
      Logger.warning('[WidgetService] 사랑 운세 위젯 업데이트 실패 (선택적 기능, 위젯 비활성화): $e');
    }
  }
  
  /// Register widget update callback
  static void registerUpdateCallback(Future<void> Function(Uri?) callback) {
    HomeWidget.registerInteractivityCallback(callback);
  }
  
  /// Get initial widget data (when app is launched from widget,
  static Future<Map<String, dynamic>?> getInitialWidgetData() async {
    try {
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (uri != null) {
        return uri.queryParameters;
      }
    } catch (e) {
      Logger.warning('[WidgetService] 초기 위젯 데이터 가져오기 실패 (선택적 기능, null 반환): $e');
    }
    return null;
  }
  
  /// Listen to widget clicks
  static Stream<Uri?> get widgetClicks => HomeWidget.widgetClicked;

  // ============================================================
  // FAVORITES WIDGET METHODS
  // ============================================================

  /// Save favorites list to native widget storage
  static Future<void> saveFavorites(List<String> favorites) async {
    try {
      final jsonStr = jsonEncode(favorites);
      await HomeWidget.saveWidgetData<String>(keyFavorites, jsonStr);
      Logger.info('[WidgetService] Favorites saved: ${favorites.length} items');
    } catch (e) {
      Logger.warning('[WidgetService] Failed to save favorites: $e');
    }
  }

  /// Save rolling index for favorites widget
  static Future<void> saveRollingIndex(int index) async {
    try {
      await HomeWidget.saveWidgetData<int>(keyRollingIndex, index);
    } catch (e) {
      Logger.warning('[WidgetService] Failed to save rolling index: $e');
    }
  }

  /// Cache fortune data for widget display
  static Future<void> cacheFortune(String fortuneType, Map<String, dynamic> data) async {
    try {
      final jsonStr = jsonEncode(data);
      await HomeWidget.saveWidgetData<String>('$keyFortuneCachePrefix$fortuneType', jsonStr);
      Logger.info('[WidgetService] Cached fortune: $fortuneType');
    } catch (e) {
      Logger.warning('[WidgetService] Failed to cache fortune: $e');
    }
  }

  /// Update favorites fortune widget with current display data
  static Future<void> updateFavoritesWidget({
    required String fortuneType,
    required String icon,
    required String title,
    String? score,
    String? message,
    String? extraInfo,
    int? currentIndex,
    int? totalCount,
  }) async {
    try {
      // Save individual fields for native widget
      await HomeWidget.saveWidgetData<String>('current_type', fortuneType);
      await HomeWidget.saveWidgetData<String>('current_icon', icon);
      await HomeWidget.saveWidgetData<String>('current_title', title);

      if (score != null) {
        await HomeWidget.saveWidgetData<String>('current_score', score);
      }
      if (message != null) {
        await HomeWidget.saveWidgetData<String>('current_message', message);
      }
      if (extraInfo != null) {
        await HomeWidget.saveWidgetData<String>('current_extra_info', extraInfo);
      }
      if (currentIndex != null && totalCount != null) {
        await HomeWidget.saveWidgetData<String>('rolling_indicator', '${currentIndex + 1}/$totalCount');
      }

      final now = DateTime.now();
      await HomeWidget.saveWidgetData<String>('last_updated', '${now.hour}:${now.minute.toString().padLeft(2, '0')}');

      // Update native widget
      await NativePlatformService.updateWidget(
        widgetType: 'favorites',
        data: {
          'type': fortuneType,
          'icon': icon,
          'title': title,
          'score': score ?? '',
          'message': message ?? '',
          'extraInfo': extraInfo ?? '',
          'currentIndex': currentIndex ?? 0,
          'totalCount': totalCount ?? 0,
        },
      );

      // Reload widget on both platforms
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HomeWidget.updateWidget(
          iOSName: 'FavoritesFortuneWidget',
        );
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        await HomeWidget.updateWidget(
          androidName: 'FavoritesAppWidget',
        );
      }

      Logger.info('[WidgetService] Favorites widget updated: $fortuneType');
    } catch (e) {
      Logger.warning('[WidgetService] Failed to update favorites widget: $e');
    }
  }

  /// Sync all favorites data to native widgets
  static Future<void> syncFavoritesToWidgets({
    required List<String> favorites,
    required Map<String, Map<String, dynamic>> fortuneCache,
    required int currentIndex,
  }) async {
    try {
      // Save favorites list
      await saveFavorites(favorites);
      await saveRollingIndex(currentIndex);

      // Cache all fortune data
      for (final entry in fortuneCache.entries) {
        await cacheFortune(entry.key, entry.value);
      }

      // If there are favorites, update widget with current item
      if (favorites.isNotEmpty) {
        final currentType = favorites[currentIndex % favorites.length];
        final currentData = fortuneCache[currentType];

        if (currentData != null) {
          await updateFavoritesWidget(
            fortuneType: currentType,
            icon: currentData['icon'] as String? ?? '🔮',
            title: currentData['title'] as String? ?? currentType,
            score: currentData['score'] as String?,
            message: currentData['message'] as String?,
            extraInfo: _extractExtraInfo(currentType, currentData),
            currentIndex: currentIndex,
            totalCount: favorites.length,
          );
        }
      }

      Logger.info('[WidgetService] Favorites synced: ${favorites.length} items');
    } catch (e) {
      Logger.warning('[WidgetService] Failed to sync favorites: $e');
    }
  }

  /// Extract extra info based on fortune type
  static String? _extractExtraInfo(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'investment':
        final numbers = data['lottoNumbers'] as List<dynamic>?;
        if (numbers != null && numbers.isNotEmpty) {
          return numbers.take(5).join(', ');
        }
        return null;
      case 'biorhythm':
        final physical = data['physical'];
        final emotional = data['emotional'];
        final intellectual = data['intellectual'];
        if (physical != null && emotional != null && intellectual != null) {
          return '신체 $physical | 감정 $emotional | 지성 $intellectual';
        }
        return null;
      case 'mbti':
        return data['mbtiType'] as String?;
      case 'tarot':
        return data['cardName'] as String?;
      case 'lucky-items':
        final items = data['items'] as List<dynamic>?;
        if (items != null && items.isNotEmpty) {
          return items.take(3).join(', ');
        }
        return null;
      case 'time':
        return data['currentPeriod'] as String?;
      case 'moving':
        final direction = data['bestDirection'];
        final date = data['bestDate'];
        if (direction != null || date != null) {
          return [direction, date].whereType<String>().join(' | ');
        }
        return null;
      default:
        return null;
    }
  }

  /// Trigger rolling to next favorite (called by timer)
  static Future<void> rollToNextFavorite() async {
    try {
      // Notify native widgets to roll
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HomeWidget.updateWidget(
          iOSName: 'FavoritesFortuneWidget',
        );
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        // Android handles rolling via AlarmManager, but we can trigger manual update
        await HomeWidget.updateWidget(
          androidName: 'FavoritesAppWidget',
        );
      }
    } catch (e) {
      Logger.warning('[WidgetService] Failed to trigger rolling: $e');
    }
  }
}