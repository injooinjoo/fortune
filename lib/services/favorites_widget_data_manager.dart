import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/domain/entities/fortune.dart';
import 'package:fortune/services/widget_service.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Favorites Widget Data Manager
///
/// Manages widget data for favorite fortunes with rolling display.
/// Supports 20+ fortune types with type-specific data extraction.
class FavoritesWidgetDataManager {
  static const String _prefKeyFavorites = 'fortune_favorites';
  static const String _prefKeyCurrentIndex = 'widget_rolling_index';
  static const String _prefKeyLastRollTime = 'widget_last_roll_time';
  static const String _prefKeyFortuneCachePrefix = 'widget_fortune_cache_';

  // Rolling interval: 1 minute
  static const Duration rollingInterval = Duration(minutes: 1);

  /// Initialize widget data manager
  static Future<void> initialize() async {
    await WidgetService.initialize();
    Logger.info('[FavoritesWidgetDataManager] Initialized');
  }

  /// Get current favorites list
  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefKeyFavorites) ?? [];
  }

  /// Get current rolling index
  static Future<int> getCurrentIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefKeyCurrentIndex) ?? 0;
  }

  /// Roll to next favorite (called every 1 minute)
  static Future<String?> rollToNextFavorite() async {
    final favorites = await getFavorites();
    if (favorites.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final currentIndex = prefs.getInt(_prefKeyCurrentIndex) ?? 0;
    final nextIndex = (currentIndex + 1) % favorites.length;

    await prefs.setInt(_prefKeyCurrentIndex, nextIndex);
    await prefs.setString(_prefKeyLastRollTime, DateTime.now().toIso8601String());

    final nextFavorite = favorites[nextIndex];
    Logger.info('[FavoritesWidgetDataManager] Rolled to: $nextFavorite (index: $nextIndex)');

    return nextFavorite;
  }

  /// Get current favorite to display
  static Future<String?> getCurrentFavorite() async {
    final favorites = await getFavorites();
    if (favorites.isEmpty) return null;

    final currentIndex = await getCurrentIndex();
    return favorites[currentIndex % favorites.length];
  }

  /// Check if rolling is needed (1 minute passed)
  static Future<bool> shouldRoll() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRollTimeStr = prefs.getString(_prefKeyLastRollTime);

    if (lastRollTimeStr == null) return true;

    final lastRollTime = DateTime.parse(lastRollTimeStr);
    final now = DateTime.now();

    return now.difference(lastRollTime) >= rollingInterval;
  }

  /// Cache fortune data for widget
  static Future<void> cacheFortune(String fortuneType, Fortune fortune) async {
    final prefs = await SharedPreferences.getInstance();
    final widgetData = extractWidgetData(fortuneType, fortune);
    final jsonStr = jsonEncode(widgetData);

    await prefs.setString('$_prefKeyFortuneCachePrefix$fortuneType', jsonStr);
    Logger.info('[FavoritesWidgetDataManager] Cached fortune: $fortuneType');
  }

  /// Get cached fortune data
  static Future<Map<String, dynamic>?> getCachedFortune(String fortuneType) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('$_prefKeyFortuneCachePrefix$fortuneType');

    if (jsonStr == null) return null;
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  /// Extract widget data based on fortune type
  static Map<String, dynamic> extractWidgetData(String fortuneType, Fortune fortune) {
    final baseData = {
      'type': fortuneType,
      'icon': _getIconForType(fortuneType),
      'title': _getTitleForType(fortuneType),
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    switch (fortuneType) {
      case 'daily':
        return {
          ...baseData,
          'score': fortune.overallScore?.toString() ?? '0',
          'luckyColor': fortune.luckyColor ?? '-',
          'luckyNumber': fortune.luckyNumber?.toString() ?? '-',
          'message': _truncate(fortune.content, 50),
          'percentile': fortune.percentile?.toString(),
        };

      case 'love':
        final loveScore = fortune.categories?['love']?['score'] as int? ?? fortune.overallScore ?? 0;
        return {
          ...baseData,
          'score': loveScore.toString(),
          'goodDay': fortune.categories?['love']?['best_day'] ?? '-',
          'message': _truncate(fortune.categories?['love']?['summary'] as String? ?? fortune.content, 50),
        };

      case 'career':
        final careerScore = fortune.categories?['work']?['score'] as int? ?? fortune.overallScore ?? 0;
        return {
          ...baseData,
          'score': careerScore.toString(),
          'luckyTime': fortune.bestTime ?? '-',
          'message': _truncate(fortune.categories?['work']?['summary'] as String? ?? fortune.content, 50),
        };

      case 'investment':
        // Extract lotto numbers if available
        final lottoNumbers = fortune.metadata?['lotto_numbers'] as List<dynamic>? ?? [];
        final displayNumbers = lottoNumbers.take(5).map((n) => n.toString()).toList();
        return {
          ...baseData,
          'lottoNumbers': displayNumbers,
          'sector': fortune.metadata?['recommended_sector'] ?? '-',
          'message': _truncate(fortune.content, 40),
        };

      case 'mbti':
        return {
          ...baseData,
          'mbtiType': fortune.metadata?['mbti_type'] ?? '-',
          'energyLevel': fortune.metadata?['energy_level']?.toString() ?? '50',
          'mood': fortune.metadata?['today_mood'] ?? '-',
          'message': _truncate(fortune.content, 40),
        };

      case 'tarot':
        return {
          ...baseData,
          'cardName': fortune.metadata?['card_name'] ?? 'The Fool',
          'cardImage': fortune.metadata?['card_image'],
          'interpretation': _truncate(fortune.content, 60),
        };

      case 'biorhythm':
        final hexagon = fortune.hexagonScores ?? {};
        return {
          ...baseData,
          'physical': hexagon['신체']?.toString() ?? '50',
          'emotional': hexagon['감정']?.toString() ?? '50',
          'intellectual': hexagon['지성']?.toString() ?? '50',
          'message': _truncate(fortune.summary ?? fortune.content, 40),
        };

      case 'compatibility':
        return {
          ...baseData,
          'score': fortune.overallScore?.toString() ?? '0',
          'partnerName': fortune.metadata?['partner_name'] ?? '',
          'message': _truncate(fortune.content, 50),
        };

      case 'health':
        final healthScore = fortune.categories?['health']?['score'] as int? ?? fortune.overallScore ?? 0;
        return {
          ...baseData,
          'score': healthScore.toString(),
          'warningArea': fortune.warnings?.firstOrNull ?? '-',
          'message': _truncate(fortune.categories?['health']?['summary'] as String? ?? fortune.content, 50),
        };

      case 'dream':
        return {
          ...baseData,
          'symbol': fortune.metadata?['main_symbol'] ?? '-',
          'meaning': _truncate(fortune.content, 60),
        };

      case 'lucky-items':
        final items = <String>[];
        if (fortune.luckyColor != null) items.add(fortune.luckyColor!);
        if (fortune.luckyNumber != null) items.add(fortune.luckyNumber.toString());
        if (fortune.luckyDirection != null) items.add(fortune.luckyDirection!);
        return {
          ...baseData,
          'items': items.take(3).toList(),
          'message': _truncate(fortune.content, 40),
        };

      case 'traditional-saju':
        return {
          ...baseData,
          'summary': _truncate(fortune.summary ?? '', 30),
          'todayFortune': _truncate(fortune.content, 50),
        };

      case 'face-reading':
        return {
          ...baseData,
          'score': fortune.overallScore?.toString() ?? '0',
          'features': fortune.metadata?['features'] ?? '-',
          'message': _truncate(fortune.content, 50),
        };

      case 'talent':
        return {
          ...baseData,
          'area': fortune.metadata?['talent_area'] ?? '-',
          'activity': fortune.metadata?['recommended_activity'] ?? '-',
          'message': _truncate(fortune.content, 50),
        };

      case 'blind-date':
        return {
          ...baseData,
          'score': fortune.overallScore?.toString() ?? '0',
          'bestDay': fortune.metadata?['best_day'] ?? '-',
          'advice': _truncate(fortune.recommendations?.firstOrNull ?? fortune.content, 50),
        };

      case 'ex-lover':
        return {
          ...baseData,
          'score': fortune.overallScore?.toString() ?? '0',
          'possibility': fortune.metadata?['reunion_possibility'] ?? '-',
          'advice': _truncate(fortune.content, 50),
        };

      case 'moving':
        return {
          ...baseData,
          'score': fortune.overallScore?.toString() ?? '0',
          'bestDirection': fortune.metadata?['best_direction'] ?? '-',
          'bestDate': fortune.metadata?['best_date'] ?? '-',
          'message': _truncate(fortune.content, 40),
        };

      case 'pet-compatibility':
        return {
          ...baseData,
          'score': fortune.overallScore?.toString() ?? '0',
          'petType': fortune.metadata?['pet_type'] ?? '-',
          'message': _truncate(fortune.content, 50),
        };

      case 'family-harmony':
        return {
          ...baseData,
          'score': fortune.overallScore?.toString() ?? '0',
          'advice': _truncate(fortune.recommendations?.firstOrNull ?? '', 40),
          'message': _truncate(fortune.content, 50),
        };

      case 'time':
        final currentHour = DateTime.now().hour;
        final currentPeriod = _getTimePeriod(currentHour);
        final timeSpecific = fortune.timeSpecificFortunes?.firstWhere(
          (t) => t.time.contains(currentPeriod),
          orElse: () => fortune.timeSpecificFortunes?.first ?? const TimeSpecificFortune(time: '', title: '', score: 0, description: ''),
        );
        return {
          ...baseData,
          'currentPeriod': currentPeriod,
          'score': timeSpecific?.score.toString() ?? fortune.overallScore?.toString() ?? '0',
          'message': _truncate(timeSpecific?.description ?? fortune.content, 50),
        };

      case 'avoid-people':
        return {
          ...baseData,
          'warningType': fortune.metadata?['warning_type'] ?? '-',
          'description': _truncate(fortune.content, 50),
          'advice': _truncate(fortune.recommendations?.firstOrNull ?? '', 40),
        };

      default:
        // Generic fallback for any other fortune type
        return {
          ...baseData,
          'score': fortune.overallScore?.toString() ?? '0',
          'message': _truncate(fortune.content, 60),
        };
    }
  }

  /// Sync current favorite to native widget
  static Future<void> syncToWidget() async {
    try {
      final currentFavorite = await getCurrentFavorite();
      if (currentFavorite == null) {
        Logger.warning('[FavoritesWidgetDataManager] No favorites to sync');
        return;
      }

      final cachedData = await getCachedFortune(currentFavorite);
      if (cachedData == null) {
        Logger.warning('[FavoritesWidgetDataManager] No cached data for $currentFavorite');
        return;
      }

      // Save to HomeWidget
      for (final entry in cachedData.entries) {
        if (entry.value is String) {
          await HomeWidget.saveWidgetData<String>(entry.key, entry.value);
        } else if (entry.value is List) {
          await HomeWidget.saveWidgetData<String>(entry.key, jsonEncode(entry.value));
        }
      }

      // Update native widgets
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HomeWidget.updateWidget(
          iOSName: 'FavoritesFortuneWidget',
        );
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        await HomeWidget.updateWidget(
          androidName: 'FavoritesAppWidget',
        );
      }

      Logger.info('[FavoritesWidgetDataManager] Synced to widget: $currentFavorite');
    } catch (e) {
      Logger.warning('[FavoritesWidgetDataManager] Sync failed: $e');
    }
  }

  /// Sync all favorites data (when favorites change or fortune is loaded)
  static Future<void> syncAllFavorites(Map<String, Fortune> fortuneData) async {
    final favorites = await getFavorites();

    for (final type in favorites) {
      final fortune = fortuneData[type];
      if (fortune != null) {
        await cacheFortune(type, fortune);
      }
    }

    await syncToWidget();
  }

  /// Handle rolling and widget update (call this periodically)
  static Future<void> handleRollingUpdate() async {
    if (await shouldRoll()) {
      await rollToNextFavorite();
      await syncToWidget();
    }
  }

  /// Get icon emoji for fortune type
  static String _getIconForType(String type) {
    const icons = {
      'daily': '✨',
      'love': '💖',
      'career': '💼',
      'investment': '📈',
      'mbti': '🧠',
      'tarot': '🃏',
      'biorhythm': '📊',
      'compatibility': '💑',
      'health': '🏥',
      'dream': '🌙',
      'lucky-items': '🍀',
      'traditional-saju': '🔮',
      'face-reading': '👤',
      'talent': '⭐',
      'blind-date': '💘',
      'ex-lover': '💔',
      'moving': '🏠',
      'pet-compatibility': '🐾',
      'family-harmony': '👨‍👩‍👧‍👦',
      'time': '⏰',
      'avoid-people': '🚫',
    };
    return icons[type] ?? '🔮';
  }

  /// Get display title for fortune type
  static String _getTitleForType(String type) {
    const titles = {
      'daily': '일일운세',
      'love': '연애운',
      'career': '직업운',
      'investment': '투자운',
      'mbti': 'MBTI 운세',
      'tarot': '타로',
      'biorhythm': '바이오리듬',
      'compatibility': '궁합',
      'health': '건강운',
      'dream': '꿈해몽',
      'lucky-items': '행운 아이템',
      'traditional-saju': '전통 사주',
      'face-reading': '관상',
      'talent': '재능운',
      'blind-date': '소개팅운',
      'ex-lover': '재회운',
      'moving': '이사운',
      'pet-compatibility': '반려동물 궁합',
      'family-harmony': '가족 화목',
      'time': '시간대별 운세',
      'avoid-people': '피해야 할 사람',
    };
    return titles[type] ?? type;
  }

  /// Truncate string with ellipsis
  static String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Get time period name from hour
  static String _getTimePeriod(int hour) {
    if (hour >= 5 && hour < 9) return '아침';
    if (hour >= 9 && hour < 12) return '오전';
    if (hour >= 12 && hour < 14) return '점심';
    if (hour >= 14 && hour < 18) return '오후';
    if (hour >= 18 && hour < 21) return '저녁';
    if (hour >= 21 || hour < 5) return '밤';
    return '오전';
  }
}
