import 'package:hive_flutter/hive_flutter.dart';
import 'package:fortune/core/cache/models/cached_fortune.dart';
import 'package:fortune/domain/entities/fortune.dart';
import 'package:fortune/core/utils/logger.dart';

class CacheService {
  static const String _fortuneBoxName = 'fortunes';
  static const String _settingsBoxName = 'settings';
  static const int _maxCacheSize = 50 * 1024 * 1024; // 50MB
  
  late Box<CachedFortune> _fortuneBox;
  late Box _settingsBox;
  
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CachedFortuneAdapter());
      }
      
      // Open boxes
      _fortuneBox = await Hive.openBox<CachedFortune>(_fortuneBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);
      
      // Clean expired cache on startup
      await _cleanExpiredCache();
      
      Logger.info('Cache service initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize cache service', e);
      rethrow;
    }
  }

  // Fortune caching methods
  Future<void> cacheFortune(Fortune fortune) async {
    try {
      final cacheKey = _generateCacheKey(fortune.type, fortune.userId);
      final cachedFortune = CachedFortune.fromFortune(fortune);
      
      await _fortuneBox.put(cacheKey, cachedFortune);
      await _enforceCacheSize();
      
      Logger.debug('Fortune cached');
    } catch (e) {
      Logger.error('Failed to cache fortune', e);
    }
  }

  Future<Fortune?> getCachedFortune(String fortuneType, String userId) async {
    try {
      final cacheKey = _generateCacheKey(fortuneType, userId);
      final cachedFortune = _fortuneBox.get(cacheKey);
      
      if (cachedFortune == null) {
        return null;
      }
      
      if (cachedFortune.isExpired) {
        await _fortuneBox.delete(cacheKey);
        Logger.debug('Fortune cached');
        return null;
      }
      
      Logger.debug('Fortune cached');
      return cachedFortune.toFortune();
    } catch (e) {
      Logger.error('Failed to get cached fortune', e);
      return null;
    }
  }

  Future<List<Fortune>> getAllCachedFortunes(String userId) async {
    try {
      final fortunes = <Fortune>[];
      
      for (final cachedFortune in _fortuneBox.values) {
        if (cachedFortune.userId == userId && !cachedFortune.isExpired) {
          fortunes.add(cachedFortune.toFortune());
        }
      }
      
      fortunes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return fortunes;
    } catch (e) {
      Logger.error('Failed to get all cached fortunes', e);
      return [];
    }
  }

  Future<void> clearFortuneCache({String? userId}) async {
    try {
      if (userId != null) {
        // Clear only specific user's cache
        final keysToDelete = <dynamic>[];
        _fortuneBox.toMap().forEach((key, value) {
          if (value.userId == userId) {
            keysToDelete.add(key);
          }
        });
        await _fortuneBox.deleteAll(keysToDelete);
        Logger.debug('Fortune cached');
      } else {
        // Clear all fortune cache
        await _fortuneBox.clear();
        Logger.debug('Cleared all fortune cache');
      }
    } catch (e) {
      Logger.error('Failed to clear fortune cache', e);
    }
  }

  // Settings cache methods
  Future<void> setSetting(String key, dynamic value) async {
    try {
      await _settingsBox.put(key, value);
    } catch (e) {
      Logger.error('setting: $key', e);
    }
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    try {
      return _settingsBox.get(key, defaultValue: defaultValue) as T?;
    } catch (e) {
      Logger.error('setting: $key', e);
      return defaultValue;
    }
  }

  Future<void> removeSetting(String key) async {
    try {
      await _settingsBox.delete(key);
    } catch (e) {
      Logger.error('setting: $key', e);
    }
  }

  // Cache management
  Future<int> getCacheSize() async {
    try {
      int totalSize = 0;
      
      // Calculate fortune box size
      for (final fortune in _fortuneBox.values) {
        totalSize += fortune.content.length;
        if (fortune.additionalInfo != null) {
          totalSize += fortune.additionalInfo.toString().length;
        }
      }
      
      // Calculate settings box size
      for (final value in _settingsBox.values) {
        totalSize += value.toString().length;
      }
      
      return totalSize;
    } catch (e) {
      Logger.error('Failed to calculate cache size', e);
      return 0;
    }
  }

  Future<void> clearAllCache() async {
    try {
      await _fortuneBox.clear();
      await _settingsBox.clear();
      Logger.info('Cleared all cache');
    } catch (e) {
      Logger.error('Failed to clear all cache', e);
    }
  }

  // Private helper methods
  String _generateCacheKey(String fortuneType, String userId) {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return '${userId}_${fortuneType}_$dateKey';
  }

  Future<void> _cleanExpiredCache() async {
    try {
      final keysToDelete = <dynamic>[];
      
      _fortuneBox.toMap().forEach((key, value) {
        if (value.isExpired) {
          keysToDelete.add(key);
        }
      });
      
      if (keysToDelete.isNotEmpty) {
        await _fortuneBox.deleteAll(keysToDelete);
        Logger.debug('Removed ${keysToDelete.length} expired cache entries');
      }
    } catch (e) {
      Logger.error('Failed to clean expired cache', e);
    }
  }

  Future<void> _enforceCacheSize() async {
    try {
      final currentSize = await getCacheSize();
      
      if (currentSize > _maxCacheSize) {
        // Remove oldest entries until size is under limit
        final entries = _fortuneBox.toMap().entries.toList()
          ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));
        
        int removedSize = 0;
        final keysToDelete = <dynamic>[];
        
        for (final entry in entries) {
          if (currentSize - removedSize <= _maxCacheSize * 0.8) {
            break;
          }
          
          keysToDelete.add(entry.key);
          removedSize += entry.value.content.length;
          if (entry.value.additionalInfo != null) {
            removedSize += entry.value.additionalInfo.toString().length;
          }
        }
        
        if (keysToDelete.isNotEmpty) {
          await _fortuneBox.deleteAll(keysToDelete);
          Logger.debug('Removed ${keysToDelete.length} entries to enforce cache size limit');
        }
      }
    } catch (e) {
      Logger.error('Failed to enforce cache size', e);
    }
  }

  // Offline mode support
  bool get isOffline => getSetting<bool>('isOffline': defaultValue: false) ?? false;
  
  Future<void> setOfflineMode(bool offline) async {
    await setSetting('isOffline': offline);
  }

  Future<Map<String, dynamic>> getOfflineStats() async {
    final totalCached = _fortuneBox.length;
    final cacheSize = await getCacheSize();
    final oldestEntry = _fortuneBox.values.isEmpty 
      ? null 
      : _fortuneBox.values.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);
    
    return {
      'totalCached': totalCached,
      'cacheSize': cacheSize,
      'cacheSizeMB': (cacheSize / (1024 * 1024)).toStringAsFixed(2),
      'oldestEntryDate': oldestEntry?.createdAt.toIso8601String(),
      'isOffline': null,
    };
  }
}