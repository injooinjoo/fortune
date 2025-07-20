import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';

/// Cache configuration for different endpoints
class CacheConfig {
  final Duration duration;
  final bool cacheOnError;
  final List<int> validStatusCodes;

  const CacheConfig({
    required this.duration,
    this.cacheOnError = true,
    this.validStatusCodes = const [200],
  });
}

/// API Response cache entry
class CacheEntry {
  final String key;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int statusCode;
  final Map<String, List<String>>? headers;

  CacheEntry({
    required this.key,
    required this.data,
    required this.createdAt,
    required this.expiresAt,
    required this.statusCode,
    this.headers,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
    'key': key,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'statusCode': statusCode,
    'headers': headers,
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
    key: json['key'],
    data: json['data'],
    createdAt: DateTime.parse(json['createdAt']),
    expiresAt: DateTime.parse(json['expiresAt']),
    statusCode: json['statusCode'],
    headers: json['headers'],
  );
}

/// HTTP Cache Interceptor using Hive for persistence
class CacheInterceptor extends Interceptor {
  static const String _cacheBoxName = 'api_cache';
  late Box<Map> _cacheBox;
  
  // Default cache configurations for different endpoints
  final Map<RegExp, CacheConfig> _cacheConfigs = {
    // Fortune endpoints - cache for different durations based on type
    RegExp(r'/fortune/daily'): const CacheConfig(duration: Duration(hours: 24)),
    RegExp(r'/fortune/tomorrow'): const CacheConfig(duration: Duration(hours: 12)),
    RegExp(r'/fortune/weekly'): const CacheConfig(duration: Duration(days: 7)),
    RegExp(r'/fortune/monthly'): const CacheConfig(duration: Duration(days: 30)),
    RegExp(r'/fortune/yearly'): const CacheConfig(duration: Duration(days: 365)),
    RegExp(r'/fortune/saju'): const CacheConfig(duration: Duration(days: 365)),
    RegExp(r'/fortune/.*'): const CacheConfig(duration: Duration(hours: 1)), // Default for other fortunes
    
    // User data - shorter cache
    RegExp(r'/user/profile'): const CacheConfig(duration: Duration(minutes: 5)),
    RegExp(r'/user/token-balance'): const CacheConfig(duration: Duration(minutes: 1)),
    
    // Static data - longer cache
    RegExp(r'/config/.*'): const CacheConfig(duration: Duration(days: 1)),
    RegExp(r'/static/.*'): const CacheConfig(duration: Duration(days: 7)),
  };

  CacheInterceptor() {
    _initCache();
  }

  Future<void> _initCache() async {
    _cacheBox = await Hive.openBox<Map>(_cacheBoxName);
    // Clean expired entries on init
    _cleanExpiredEntries();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Only cache GET requests
    if (options.method != 'GET') {
      handler.next(options);
      return;
    }

    // Check if caching is disabled for this request
    if (options.extra['noCache'] == true) {
      handler.next(options);
      return;
    }

    // Generate cache key
    final cacheKey = _generateCacheKey(options);
    
    // Try to get from cache
    final cachedData = await _getFromCache(cacheKey);
    if (cachedData != null) {
      // Return cached response
      handler.resolve(
        Response(
          requestOptions: options,
          data: cachedData.data,
          statusCode: cachedData.statusCode,
          headers: Headers.fromMap(cachedData.headers ?? <String, List<String>>{}),
          extra: {'cached': true, 'cacheKey': cacheKey},
        ),
      );
      return;
    }

    // Add cache key to options for later use
    options.extra['cacheKey'] = cacheKey;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // Only cache successful responses
    final cacheConfig = _getCacheConfig(response.requestOptions.uri.path);
    if (cacheConfig != null && 
        cacheConfig.validStatusCodes.contains(response.statusCode)) {
      
      final cacheKey = response.requestOptions.extra['cacheKey'] as String?;
      if (cacheKey != null) {
        await _saveToCache(cacheKey, response, cacheConfig);
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Try to return cached data on error if configured
    final cacheConfig = _getCacheConfig(err.requestOptions.uri.path);
    if (cacheConfig?.cacheOnError == true) {
      final cacheKey = err.requestOptions.extra['cacheKey'] as String?;
      if (cacheKey != null) {
        final cachedData = await _getFromCache(cacheKey, ignoreExpiry: true);
        if (cachedData != null) {
          // Return stale cached data on error
          handler.resolve(
            Response(
              requestOptions: err.requestOptions,
              data: cachedData.data,
              statusCode: cachedData.statusCode,
              headers: Headers.fromMap(cachedData.headers ?? <String, List<String>>{}),
              extra: {'cached': true, 'stale': true, 'originalError': err},
            ),
          );
          return;
        }
      }
    }

    handler.next(err);
  }

  String _generateCacheKey(RequestOptions options) {
    final uri = options.uri.toString();
    final headers = options.headers.toString();
    final data = options.data?.toString() ?? '';
    final content = '$uri|$headers|$data';
    
    // Use SHA256 to generate a unique key
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  CacheConfig? _getCacheConfig(String path) {
    for (final entry in _cacheConfigs.entries) {
      if (entry.key.hasMatch(path)) {
        return entry.value;
      }
    }
    return null;
  }

  Future<CacheEntry?> _getFromCache(String key, {bool ignoreExpiry = false}) async {
    try {
      final cached = _cacheBox.get(key);
      if (cached == null) return null;
      
      final entry = CacheEntry.fromJson(Map<String, dynamic>.from(cached));
      
      if (!ignoreExpiry && entry.isExpired) {
        // Remove expired entry
        await _cacheBox.delete(key);
        return null;
      }
      
      return entry;
    } catch (e) {
      // Handle cache corruption
      await _cacheBox.delete(key);
      return null;
    }
  }

  Future<void> _saveToCache(String key, Response response, CacheConfig config) async {
    try {
      final now = DateTime.now();
      final entry = CacheEntry(
        key: key,
        data: response.data,
        createdAt: now,
        expiresAt: now.add(config.duration),
        statusCode: response.statusCode ?? 200,
        headers: response.headers.map,
      );
      
      await _cacheBox.put(key, entry.toJson());
    } catch (e) {
      // Ignore cache save errors
      print('Failed to save to cache: $e');
    }
  }

  Future<void> _cleanExpiredEntries() async {
    final keysToRemove = <String>[];
    
    for (final key in _cacheBox.keys) {
      try {
        final cached = _cacheBox.get(key);
        if (cached != null) {
          final entry = CacheEntry.fromJson(Map<String, dynamic>.from(cached));
          if (entry.isExpired) {
            keysToRemove.add(key as String);
          }
        }
      } catch (e) {
        // Remove corrupted entries
        keysToRemove.add(key as String);
      }
    }
    
    for (final key in keysToRemove) {
      await _cacheBox.delete(key);
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  /// Clear cache for specific pattern
  Future<void> clearCacheForPattern(String pattern) async {
    final regex = RegExp(pattern);
    final keysToRemove = <String>[];
    
    for (final key in _cacheBox.keys) {
      if (regex.hasMatch(key as String)) {
        keysToRemove.add(key);
      }
    }
    
    for (final key in keysToRemove) {
      await _cacheBox.delete(key);
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    int totalEntries = 0;
    int expiredEntries = 0;
    int totalSize = 0;
    
    for (final key in _cacheBox.keys) {
      totalEntries++;
      try {
        final cached = _cacheBox.get(key);
        if (cached != null) {
          totalSize += jsonEncode(cached).length;
          final entry = CacheEntry.fromJson(Map<String, dynamic>.from(cached));
          if (entry.isExpired) {
            expiredEntries++;
          }
        }
      } catch (e) {
        // Ignore corrupted entries
      }
    }
    
    return {
      'totalEntries': totalEntries,
      'expiredEntries': expiredEntries,
      'activeEntries': totalEntries - expiredEntries,
      'totalSizeBytes': totalSize,
      'totalSizeMB': (totalSize / 1024 / 1024).toStringAsFixed(2),
    };
  }
}

/// Extension to easily add cache interceptor to Dio
extension DioCacheExtension on Dio {
  void addCacheInterceptor() {
    interceptors.add(CacheInterceptor());
  }
  
  /// Make a request without caching
  Future<Response<T>> getNoCache<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    final opts = options ?? Options();
    opts.extra = {...opts.extra ?? {}, 'noCache': true};
    return get<T>(path, queryParameters: queryParameters, options: opts);
  }
}