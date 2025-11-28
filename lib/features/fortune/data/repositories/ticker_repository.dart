import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/investment_ticker.dart';
import '../datasources/ticker_static_data.dart';

/// 티커 데이터 Repository
/// 캐시 우선 → API → 정적 데이터 fallback
/// 24시간 캐시 TTL로 불필요한 API 호출 최소화
class TickerRepository {
  final SupabaseClient _supabase;

  // 캐시 키 및 TTL
  static const String _cacheKeyPrefix = 'ticker_cache_';
  static const String _cacheTimestampPrefix = 'ticker_cache_ts_';
  static const Duration _cacheTTL = Duration(hours: 24);

  // 인메모리 캐시 (세션 동안 유지)
  static final Map<String, List<InvestmentTicker>> _memoryCache = {};
  static DateTime? _memoryCacheTime;

  TickerRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// 카테고리별 티커 조회 (캐시 우선)
  Future<List<InvestmentTicker>> getTickersByCategory(String category) async {
    // 1. 인메모리 캐시 확인
    final memCached = _getFromMemoryCache(category);
    if (memCached != null) {
      debugPrint('✅ [TickerRepository] Memory cache hit for $category');
      return memCached;
    }

    // 2. SharedPreferences 캐시 확인
    final cached = await _getCachedTickers(category);
    if (cached != null) {
      debugPrint('✅ [TickerRepository] Disk cache hit for $category');
      _saveToMemoryCache(category, cached);
      return cached;
    }

    // 3. API 호출
    try {
      final response = await _supabase.functions.invoke(
        'fetch-tickers',
        body: {'category': category},
      );

      if (response.status != 200) {
        throw Exception('API Error: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      final tickers = (data['tickers'] as List)
          .map((t) => _mapToInvestmentTicker(t))
          .toList();

      // 캐시 저장
      await _cacheTickers(category, tickers);
      _saveToMemoryCache(category, tickers);
      debugPrint('✅ [TickerRepository] API success, cached ${tickers.length} tickers for $category');

      return tickers;
    } catch (e) {
      // 4. API 실패 시 정적 데이터 fallback
      debugPrint('⚠️ [TickerRepository] API failed, using static data: $e');
      final staticData = TickerStaticData.getTickersByCategory(category);
      _saveToMemoryCache(category, staticData);
      return staticData;
    }
  }

  /// 인기 종목 조회 (캐시 우선)
  Future<List<InvestmentTicker>> getPopularTickers({String? category}) async {
    final cacheKey = 'popular_${category ?? 'all'}';

    // 1. 인메모리 캐시 확인
    final memCached = _getFromMemoryCache(cacheKey);
    if (memCached != null) {
      debugPrint('✅ [TickerRepository] Memory cache hit for popular');
      return memCached;
    }

    // 2. SharedPreferences 캐시 확인
    final cached = await _getCachedTickers(cacheKey);
    if (cached != null) {
      debugPrint('✅ [TickerRepository] Disk cache hit for popular');
      _saveToMemoryCache(cacheKey, cached);
      return cached;
    }

    // 3. API 호출
    try {
      final response = await _supabase.functions.invoke(
        'fetch-tickers',
        body: {
          'popularOnly': true,
          if (category != null) 'category': category,
        },
      );

      if (response.status != 200) {
        throw Exception('API Error: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      final tickers = (data['tickers'] as List)
          .map((t) => _mapToInvestmentTicker(t))
          .toList();

      // 캐시 저장
      await _cacheTickers(cacheKey, tickers);
      _saveToMemoryCache(cacheKey, tickers);

      return tickers;
    } catch (e) {
      debugPrint('⚠️ [TickerRepository] API failed, using static data: $e');
      final staticData = TickerStaticData.getPopularTickers(category: category);
      _saveToMemoryCache(cacheKey, staticData);
      return staticData;
    }
  }

  /// 티커 검색
  Future<List<InvestmentTicker>> searchTickers(
    String query, {
    String? category,
  }) async {
    if (query.trim().isEmpty) {
      return category != null
          ? await getTickersByCategory(category)
          : await getPopularTickers();
    }

    try {
      final response = await _supabase.functions.invoke(
        'fetch-tickers',
        body: {
          'search': query,
          if (category != null) 'category': category,
        },
      );

      if (response.status != 200) {
        throw Exception('API Error: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      final tickers = (data['tickers'] as List)
          .map((t) => _mapToInvestmentTicker(t))
          .toList();

      return tickers;
    } catch (e) {
      debugPrint('⚠️ [TickerRepository] API failed, using static data: $e');
      return TickerStaticData.searchTickers(query, category: category);
    }
  }

  /// 전체 티커 조회 (카테고리별 그룹화)
  Future<Map<String, List<InvestmentTicker>>> getAllTickersByCategory() async {
    try {
      final response = await _supabase.functions.invoke(
        'fetch-tickers',
        body: {},
      );

      if (response.status != 200) {
        throw Exception('API Error: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      final tickersByCategory =
          data['tickersByCategory'] as Map<String, dynamic>;

      final result = <String, List<InvestmentTicker>>{};
      for (final entry in tickersByCategory.entries) {
        result[entry.key] = (entry.value as List)
            .map((t) => _mapToInvestmentTicker(t))
            .toList();
      }

      return result;
    } catch (e) {
      debugPrint('⚠️ [TickerRepository] API failed, using static data: $e');
      return TickerStaticData.getAllTickersByCategory();
    }
  }

  /// API 응답을 InvestmentTicker로 변환
  InvestmentTicker _mapToInvestmentTicker(Map<String, dynamic> json) {
    return InvestmentTicker(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      exchange: json['exchange'] as String?,
      description: json['description'] as String?,
      isPopular: json['is_popular'] as bool? ?? false,
    );
  }

  // ===== 캐시 헬퍼 메서드 =====

  /// 인메모리 캐시에서 조회
  List<InvestmentTicker>? _getFromMemoryCache(String key) {
    // 메모리 캐시 TTL 체크 (1시간)
    if (_memoryCacheTime != null &&
        DateTime.now().difference(_memoryCacheTime!).inHours >= 1) {
      _memoryCache.clear();
      _memoryCacheTime = null;
      return null;
    }
    return _memoryCache[key];
  }

  /// 인메모리 캐시에 저장
  void _saveToMemoryCache(String key, List<InvestmentTicker> tickers) {
    _memoryCache[key] = tickers;
    _memoryCacheTime ??= DateTime.now();
  }

  /// SharedPreferences에서 캐시된 티커 조회
  Future<List<InvestmentTicker>?> _getCachedTickers(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampKey = '$_cacheTimestampPrefix$key';
      final dataKey = '$_cacheKeyPrefix$key';

      // 캐시 타임스탬프 확인
      final timestamp = prefs.getInt(timestampKey);
      if (timestamp == null) return null;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cacheTime) > _cacheTTL) {
        // 캐시 만료
        await prefs.remove(dataKey);
        await prefs.remove(timestampKey);
        return null;
      }

      // 캐시 데이터 로드
      final jsonString = prefs.getString(dataKey);
      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => InvestmentTicker.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('⚠️ [TickerRepository] Cache read error: $e');
      return null;
    }
  }

  /// SharedPreferences에 티커 캐시 저장
  Future<void> _cacheTickers(String key, List<InvestmentTicker> tickers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampKey = '$_cacheTimestampPrefix$key';
      final dataKey = '$_cacheKeyPrefix$key';

      // JSON 직렬화
      final jsonList = tickers.map((t) => t.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      // 저장
      await prefs.setString(dataKey, jsonString);
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);

      debugPrint('✅ [TickerRepository] Cached ${tickers.length} tickers for $key');
    } catch (e) {
      debugPrint('⚠️ [TickerRepository] Cache write error: $e');
    }
  }

  /// 캐시 초기화 (필요 시 사용)
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_cacheKeyPrefix) || key.startsWith(_cacheTimestampPrefix)) {
          await prefs.remove(key);
        }
      }
      _memoryCache.clear();
      _memoryCacheTime = null;
      debugPrint('✅ [TickerRepository] Cache cleared');
    } catch (e) {
      debugPrint('⚠️ [TickerRepository] Cache clear error: $e');
    }
  }
}
