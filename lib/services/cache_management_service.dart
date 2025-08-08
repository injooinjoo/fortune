import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/network/cache_interceptor.dart';

/// Service for managing application cache
class CacheManagementService {
  static CacheManagementService? _instance;
  static CacheManagementService get instance {
    _instance ??= CacheManagementService._();
    return _instance!;
  }

  CacheManagementService._();

  final CacheInterceptor _cacheInterceptor = CacheInterceptor();

  /// Initialize cache system
  Future<void> initialize() async {
    // Hive is already initialized in main.dart
    debugPrint('Cache management service initialized');
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      // Clear API response cache
      await _cacheInterceptor.clearCache();
      
      // Clear other Hive boxes if any
      final boxes = ['fortune_cache', 'user_cache', 'settings_cache'];
      for (final boxName in boxes) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            await box.clear();
          }
        } catch (e) {
          debugPrint('Failed to clear box $boxName: $e');
        }
      }
      
      debugPrint('All cache cleared successfully');
    } catch (e) {
      debugPrint('Failed to clear all cache: $e');
      rethrow;
    }
  }

  /// Clear fortune-related cache
  Future<void> clearFortuneCache() async {
    try {
      // Clear API cache for fortune endpoints
      await _cacheInterceptor.clearCacheForPattern(r'/fortune/.*');
      
      // Clear fortune cache box
      if (Hive.isBoxOpen('fortune_cache')) {
        final box = Hive.box('fortune_cache');
        await box.clear();
      }
      
      debugPrint('Fortune cache cleared successfully');
    } catch (e) {
      debugPrint('Failed to clear fortune cache: $e');
      rethrow;
    }
  }

  /// Clear user-related cache
  Future<void> clearUserCache() async {
    try {
      // Clear API cache for user endpoints
      await _cacheInterceptor.clearCacheForPattern(r'/user/.*');
      
      // Clear user cache box
      if (Hive.isBoxOpen('user_cache')) {
        final box = Hive.box('user_cache');
        await box.clear();
      }
      
      debugPrint('User cache cleared successfully');
    } catch (e) {
      debugPrint('Failed to clear user cache: $e');
      rethrow;
    }
  }

  /// Get cache statistics
  Future<CacheStatistics> getCacheStatistics() async {
    try {
      // Get API cache stats
      final apiCacheStats = await _cacheInterceptor.getCacheStats();
      
      // Get Hive cache stats
      int hiveEntries = 0;
      int hiveSizeBytes = 0;
      
      final boxes = ['fortune_cache', 'user_cache', 'settings_cache'];
      for (final boxName in boxes) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            hiveEntries += box.length;
            // Estimate size (rough approximation,
            for (final key in box.keys) {
              final value = box.get(key);
              if (value != null) {
                hiveSizeBytes += value.toString().length * 2; // UTF-16 estimation
              }
            }
          }
        } catch (e) {
          debugPrint('Failed to get stats for box $boxName: $e');
        }
      }
      
      return CacheStatistics(
        apiCacheEntries: apiCacheStats['totalEntries'] ?? 0,
        apiCacheActiveEntries: apiCacheStats['activeEntries'] ?? 0,
        apiCacheSizeBytes: apiCacheStats['totalSizeBytes'] ?? 0,
        hiveCacheEntries: hiveEntries,
        hiveCacheSizeBytes: hiveSizeBytes,
        totalEntries: (apiCacheStats['totalEntries'] ?? 0) + hiveEntries,
        totalSizeBytes: (apiCacheStats['totalSizeBytes'] ?? 0) + hiveSizeBytes,
      );
    } catch (e) {
      debugPrint('Failed to get cache statistics: $e');
      return CacheStatistics.empty();
    }
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    try {
      // API cache handles expiry automatically
      
      // Clear expired entries from Hive boxes
      final boxes = ['fortune_cache', 'user_cache'];
      for (final boxName in boxes) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            final keysToRemove = <dynamic>[];
            
            for (final key in box.keys) {
              final value = box.get(key);
              if (value is Map && value['expiresAt'] != null) {
                final expiresAt = DateTime.tryParse(value['expiresAt'].toString());
                if (expiresAt != null && expiresAt.isBefore(DateTime.now())) {
                  keysToRemove.add(key);
                }
              }
            }
            
            for (final key in keysToRemove) {
              await box.delete(key);
            }
            
            if (keysToRemove.isNotEmpty) {
              debugPrint('Cleared ${keysToRemove.length} expired entries from $boxName');
            }
          }
        } catch (e) {
          debugPrint('Failed to clear expired entries from $boxName: $e');
        }
      }
    } catch (e) {
      debugPrint('Failed to clear expired cache: $e');
    }
  }

  /// Set cache size limit (in MB)
  Future<void> setCacheSizeLimit(int limitMB) async {
    // This is a simplified implementation
    // In production, you'd want more sophisticated cache eviction
    final limitBytes = limitMB * 1024 * 1024;
    
    final stats = await getCacheStatistics();
    if (stats.totalSizeBytes > limitBytes) {
      // Simple strategy: clear all cache if over limit
      // Better strategy would be LRU eviction
      await clearAllCache();
      debugPrint('Cache cleared due to size limit exceeded');
    }
  }
}

/// Cache statistics model
class CacheStatistics {
  final int apiCacheEntries;
  final int apiCacheActiveEntries;
  final int apiCacheSizeBytes;
  final int hiveCacheEntries;
  final int hiveCacheSizeBytes;
  final int totalEntries;
  final int totalSizeBytes;

  CacheStatistics({
    required this.apiCacheEntries,
    required this.apiCacheActiveEntries,
    required this.apiCacheSizeBytes,
    required this.hiveCacheEntries,
    required this.hiveCacheSizeBytes,
    required this.totalEntries,
    required this.totalSizeBytes,
  });

  factory CacheStatistics.empty() => CacheStatistics(
    apiCacheEntries: 0,
    apiCacheActiveEntries: 0,
    apiCacheSizeBytes: 0,
    hiveCacheEntries: 0,
    hiveCacheSizeBytes: 0,
    totalEntries: 0,
    totalSizeBytes: 0,
  );

  double get totalSizeMB => totalSizeBytes / 1024 / 1024;
  double get apiCacheSizeMB => apiCacheSizeBytes / 1024 / 1024;
  double get hiveCacheSizeMB => hiveCacheSizeBytes / 1024 / 1024;

  Map<String, dynamic> toJson() => {
    'apiCache': {
      'entries': apiCacheEntries,
      'activeEntries': apiCacheActiveEntries)
      'sizeBytes': apiCacheSizeBytes,
      'sizeMB': apiCacheSizeMB.toStringAsFixed(2))
    })
    'hiveCache': {
      'entries': hiveCacheEntries,
      'sizeBytes': hiveCacheSizeBytes,
      'sizeMB': hiveCacheSizeMB.toStringAsFixed(2))
    })
    'total': {
      'entries': totalEntries,
      'sizeBytes': totalSizeBytes,
      'sizeMB': totalSizeMB.toStringAsFixed(2))
    })
  };
}