import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/fortune_model.dart';
import '../models/cache_entry.dart';

class CacheService {
  static const String _fortuneBoxName = 'fortunes';
  static const String _cacheMetaBoxName = 'cache_meta';

  static const Map<String, int> _cacheDuration = {
    'daily': 24,
    'hourly': 1,
    'weekly': 168,
    'monthly': 720,
    'yearly': 8760,
    'zodiac': 720,
    'personality': 8760,
    'default': 72,
  };

  late Box<FortuneModel> _fortuneBox;
  late Box<CacheEntry> _cacheMetaBox;

  CacheService._internal();
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;

  Future<void> initialize() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(FortuneModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CacheEntryAdapter());
    }

    _fortuneBox = await Hive.openBox<FortuneModel>(_fortuneBoxName);
    _cacheMetaBox = await Hive.openBox<CacheEntry>(_cacheMetaBoxName);

    await cleanExpiredCache();
  }

  String _generateCacheKey(String fortuneType, Map<String, dynamic> params) {
    final userId = params['userId'] ?? 'anonymous';
    final sortedParams = Map.fromEntries(
      params.entries.where((e) => e.key != 'userId').toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );
    final dateKey = _getDateKeyForType(fortuneType);
    final paramsString = sortedParams.isEmpty ? '' : ':${sortedParams.toString()}';

    return '$userId:$fortuneType:$dateKey$paramsString';
  }

  String _getDateKeyForType(String fortuneType) {
    final now = DateTime.now();

    switch (fortuneType) {
      case 'hourly':
        return '${now.year}-${now.month}-${now.day}-${now.hour}';
      case 'daily':
        return '${now.year}-${now.month}-${now.day}';
      case 'weekly':
        final weekNumber = _getWeekNumber(now);
        return '${now.year}-W$weekNumber';
      case 'monthly':
        return '${now.year}-${now.month}';
      case 'yearly':
        return '${now.year}';
      default:
        return '${now.year}-${now.month}-${now.day}';
    }
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).ceil();
  }

  Future<FortuneModel?> getCachedFortune(
    String fortuneType,
    Map<String, dynamic> params,
  ) async {
    try {
      final key = _generateCacheKey(fortuneType, params);
      final cacheEntry = _cacheMetaBox.get(key);

      if (cacheEntry == null) return null;

      if (cacheEntry.isExpired) {
        await removeCachedFortune(fortuneType, params);
        return null;
      }

      return _fortuneBox.get(key);
    } catch (e) {
      debugPrint('Error getting cached fortune: $e');
      return null;
    }
  }

  Future<void> cacheFortune(
    String fortuneType,
    Map<String, dynamic> params,
    FortuneModel fortune,
  ) async {
    try {
      final key = _generateCacheKey(fortuneType, params);
      final duration = _cacheDuration[fortuneType] ?? _cacheDuration['default']!;
      final expiryDate = DateTime.now().add(Duration(hours: duration));

      await _fortuneBox.put(key, fortune);

      final cacheEntry = CacheEntry(
        key: key,
        fortuneType: fortuneType,
        createdAt: DateTime.now(),
        expiresAt: expiryDate,
      );
      await _cacheMetaBox.put(key, cacheEntry);
    } catch (e) {
      debugPrint('Error caching fortune: $e');
    }
  }

  Future<void> removeCachedFortune(
    String fortuneType,
    Map<String, dynamic> params,
  ) async {
    try {
      final key = _generateCacheKey(fortuneType, params);
      await _fortuneBox.delete(key);
      await _cacheMetaBox.delete(key);
    } catch (e) {
      debugPrint('Error removing cached fortune: $e');
    }
  }

  Future<void> clearAllCache() async {
    try {
      await _fortuneBox.clear();
      await _cacheMetaBox.clear();
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  Future<void> cleanExpiredCache() async {
    try {
      final expiredKeys = <String>[];
      for (final entry in _cacheMetaBox.values) {
        if (entry.isExpired) {
          expiredKeys.add(entry.key);
        }
      }
      for (final key in expiredKeys) {
        await _fortuneBox.delete(key);
        await _cacheMetaBox.delete(key);
      }
      debugPrint('Cleaned \${expiredKeys.length} expired cache entries');
    } catch (e) {
      debugPrint('Error cleaning expired cache: $e');
    }
  }

  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final totalEntries = _cacheMetaBox.length;
      int expiredCount = 0;
      int validCount = 0;
      for (final entry in _cacheMetaBox.values) {
        if (entry.isExpired) {
          expiredCount++;
        } else {
          validCount++;
        }
      }
      return {
        'total': totalEntries,
        'valid': validCount,
        'expired': expiredCount,
        'sizeInBytes': _fortuneBox.path != null
            ? await _calculateBoxSize(_fortuneBox.path!)
            : 0,
      };
    } catch (e) {
      debugPrint('Error getting cache stats: $e');
      return {
        'total': 0,
        'valid': 0,
        'expired': 0,
        'sizeInBytes': 0,
      };
    }
  }

  Future<int> _calculateBoxSize(String path) async {
    return _fortuneBox.length * 1024;
  }

  Future<List<FortuneModel>> getCachedFortunesByType(String fortuneType) async {
    try {
      final fortunes = <FortuneModel>[];
      for (final entry in _cacheMetaBox.values) {
        if (entry.fortuneType == fortuneType && !entry.isExpired) {
          final fortune = _fortuneBox.get(entry.key);
          if (fortune != null) {
            fortunes.add(fortune);
          }
        }
      }
      return fortunes;
    } catch (e) {
      debugPrint('Error getting cached fortunes by type: $e');
      return [];
    }
  }

  Future<List<FortuneModel>> getAllCachedFortunesForUser(String userId, {bool includeExpired = false}) async {
    try {
      final fortunes = <FortuneModel>[];
      for (final entry in _cacheMetaBox.values) {
        if (entry.key.startsWith('$userId:')) {
          if (includeExpired || !entry.isExpired) {
            final fortune = _fortuneBox.get(entry.key);
            if (fortune != null) {
              fortunes.add(fortune);
            }
          }
        }
      }
      fortunes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return fortunes;
    } catch (e) {
      debugPrint('Error getting cached fortunes for user: $e');
      return [];
    }
  }

  Future<bool> shouldUseOfflineMode() async {
    try {
      final hasCache = _fortuneBox.isNotEmpty;
      return hasCache;
    } catch (e) {
      debugPrint('Error checking offline mode: $e');
      return false;
    }
  }

  Future<FortuneModel?> getMostRecentCachedFortune(String fortuneType, String userId) async {
    try {
      FortuneModel? mostRecent;
      DateTime? mostRecentDate;
      for (final entry in _cacheMetaBox.values) {
        if (entry.fortuneType == fortuneType && entry.key.startsWith('$userId:')) {
          final fortune = _fortuneBox.get(entry.key);
          if (fortune != null) {
            if (mostRecentDate == null || fortune.createdAt.isAfter(mostRecentDate)) {
              mostRecent = fortune;
              mostRecentDate = fortune.createdAt;
            }
          }
        }
      }
      return mostRecent;
    } catch (e) {
      debugPrint('Error getting most recent cached fortune: $e');
      return null;
    }
  }

  Future<void> preloadForOffline(String userId, List<String> fortuneTypes) async {
    try {
      debugPrint('Preloading \${fortuneTypes.length} fortune types for offline use');
    } catch (e) {
      debugPrint('Error preloading for offline: $e');
    }
  }

  void dispose() {
    _fortuneBox.close();
    _cacheMetaBox.close();
  }
}
