import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// High-performance caching service with memory and disk layers
class PerformanceCacheService {
  static final PerformanceCacheService _instance = PerformanceCacheService._internal();
  factory PerformanceCacheService() => _instance;
  PerformanceCacheService._internal();

  // Memory cache with LRU eviction
  final Map<String, CacheEntry> _memoryCache = {};
  static const int _maxMemoryCacheSize = 50;
  static const Duration _defaultTTL = Duration(hours: 24);
  
  // Preload cache for adjacent MBTI types
  final Set<String> _preloadQueue = {};
  Timer? _preloadTimer;
  
  // Cache statistics
  int _cacheHits = 0;
  int _cacheMisses = 0;
  
  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
    
    // Start preload timer
    _preloadTimer = Timer.periodic(Duration(seconds: 5), (_) => _processPreloadQueue());
    
    // Clean expired cache on startup
    await _cleanExpiredCache();
  }

  /// Get cached data with automatic memory/disk fallback
  Future<T?> get<T>(
    String key, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    if (!_initialized) await initialize();
    
    // Check memory cache first
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      _cacheHits++;
      _updateLRU(key);
      debugPrint('Cache hit: $key');
      return memoryEntry.data as T?;
    }
    
    // Check disk cache
    final diskData = _prefs.getString('cache_$key');
    if (diskData != null) {
      try {
        final entry = CacheEntry.fromJson(json.decode(diskData));
        if (!entry.isExpired) {
          _cacheHits++;
          // Promote to memory cache
          _addToMemoryCache(key, entry);
          debugPrint('Disk cache hit: $key');
          
          if (fromJson != null) {
            return fromJson(entry.data);
          }
          return entry.data as T?;
        }
      } catch (e) {
        debugPrint('Cache decode error: $e');
      }
    }
    
    _cacheMisses++;
    debugPrint('Cache miss: $key');
    return null;
  }

  /// Set cache data with TTL
  Future<void> set<T>(
    String key,
    T data, {
    Duration? ttl,
    Map<String, dynamic> Function(T)? toJson,
  }) async {
    if (!_initialized) await initialize();
    
    final entry = CacheEntry(
      data: toJson != null ? toJson(data) : data,
      expiry: DateTime.now().add(ttl ?? _defaultTTL),
    );
    
    // Add to memory cache
    _addToMemoryCache(key, entry);
    
    // Persist to disk
    try {
      await _prefs.setString('cache_$key', json.encode(entry.toJson()));
      debugPrint('Cache set: $key');
    } catch (e) {
      debugPrint('Cache set error: $e');
    }
  }

  /// Preload adjacent MBTI types for smooth browsing
  void preloadAdjacentMBTI(String currentType) {
    if (!_initialized) return;
    
    final adjacentTypes = _getAdjacentMBTITypes(currentType);
    for (final type in adjacentTypes) {
      _preloadQueue.add(type);
    }
  }

  /// Clear all cache
  Future<void> clearAll() async {
    if (!_initialized) await initialize();
    
    _memoryCache.clear();
    final keys = _prefs.getKeys().where((key) => key.startsWith('cache_'));
    for (final key in keys) {
      await _prefs.remove(key);
    }
    
    _cacheHits = 0;
    _cacheMisses = 0;
    debugPrint('📱 Cache cleared');
  }

  /// Get cache statistics
  Map<String, dynamic> getStatistics() {
    final total = _cacheHits + _cacheMisses;
    return {
      'hits': _cacheHits,
      'misses': _cacheMisses,
      'hitRate': total > 0 ? (_cacheHits / total * 100).toStringAsFixed(1) : '0.0',
      'memoryCacheSize': _memoryCache.length,
      'diskCacheKeys': _prefs.getKeys().where((k) => k.startsWith('cache_')).length,
    };
  }

  // Private methods
  
  void _addToMemoryCache(String key, CacheEntry entry) {
    // Evict oldest if at capacity
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      _evictOldest();
    }
    
    _memoryCache[key] = entry;
  }

  void _updateLRU(String key) {
    final entry = _memoryCache.remove(key);
    if (entry != null) {
      _memoryCache[key] = entry;
    }
  }

  void _evictOldest() {
    if (_memoryCache.isEmpty) return;
    
    final oldestKey = _memoryCache.keys.first;
    _memoryCache.remove(oldestKey);
    debugPrint('Cache evicted: $oldestKey');
  }

  Future<void> _cleanExpiredCache() async {
    // Clean memory cache
    _memoryCache.removeWhere((key, entry) => entry.isExpired);
    
    // Clean disk cache
    final keys = _prefs.getKeys().where((key) => key.startsWith('cache_'));
    for (final key in keys) {
      final data = _prefs.getString(key);
      if (data != null) {
        try {
          final entry = CacheEntry.fromJson(json.decode(data));
          if (entry.isExpired) {
            await _prefs.remove(key);
          }
        } catch (_) {
          await _prefs.remove(key);
        }
      }
    }
  }

  List<String> _getAdjacentMBTITypes(String type) {
    // Get MBTI types that differ by one dimension
    final types = <String>[];
    final dimensions = [
      ['E', 'I'],
      ['S', 'N'],
      ['T', 'F'],
      ['J', 'P'],
    ];
    
    for (int i = 0; i < 4; i++) {
      final chars = type.split('');
      final currentDim = chars[i];
      final otherDim = dimensions[i].firstWhere((d) => d != currentDim);
      chars[i] = otherDim;
      types.add(chars.join());
    }
    
    return types;
  }

  Future<void> _processPreloadQueue() async {
    if (_preloadQueue.isEmpty) return;
    
    // Check network connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) return;
    
    // Process one item from queue
    final type = _preloadQueue.first;
    _preloadQueue.remove(type);
    
    // Trigger preload through provider/service
    debugPrint('Preloading MBTI type: $type');
  }

  void dispose() {
    _preloadTimer?.cancel();
  }
}

/// Cache entry with expiration
class CacheEntry {
  final dynamic data;
  final DateTime expiry;

  CacheEntry({
    required this.data,
    required this.expiry,
  });

  bool get isExpired => DateTime.now().isAfter(expiry);

  Map<String, dynamic> toJson() => {
    'data': data,
    'expiry': expiry.toIso8601String(),
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
    data: json['data'],
    expiry: DateTime.parse(json['expiry']),
  );
}

/// Performance monitoring service
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, List<int>> _metrics = {};
  Timer? _reportTimer;

  void startMonitoring() {
    _reportTimer = Timer.periodic(Duration(minutes: 5), (_) => _reportMetrics());
  }

  void recordMetric(String name, int durationMs) {
    _metrics.putIfAbsent(name, () => []).add(durationMs);
    
    // Keep only last 100 measurements
    if (_metrics[name]!.length > 100) {
      _metrics[name]!.removeAt(0);
    }
  }

  Map<String, dynamic> getMetrics() {
    final results = <String, dynamic>{};
    
    _metrics.forEach((name, durations) {
      if (durations.isEmpty) return;
      
      durations.sort();
      final avg = durations.reduce((a, b) => a + b) / durations.length;
      final p50 = durations[durations.length ~/ 2];
      final p95 = durations[(durations.length * 0.95).floor()];
      
      results[name] = {
        'avg': avg.round(),
        'p50': p50,
        'p95': p95,
        'count': durations.length,
      };
    });
    
    return results;
  }

  void _reportMetrics() {
    final metrics = getMetrics();
    if (metrics.isNotEmpty) {
      debugPrint('Metrics:');
      metrics.forEach((name, data) {
        debugPrint('  $name: avg=${data['avg']}ms, p50=${data['p50']}ms, p95=${data['p95']}ms');
      });
    }
  }

  void dispose() {
    _reportTimer?.cancel();
  }
}