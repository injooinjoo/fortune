import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/investment_ticker.dart';
import '../datasources/ticker_static_data.dart';

/// 티커 데이터 Repository
/// API 우선, 실패 시 정적 데이터 fallback
class TickerRepository {
  final SupabaseClient _supabase;

  TickerRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// 카테고리별 티커 조회
  Future<List<InvestmentTicker>> getTickersByCategory(String category) async {
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

      return tickers;
    } catch (e) {
      // API 실패 시 정적 데이터 fallback
      debugPrint('⚠️ [TickerRepository] API failed, using static data: $e');
      return TickerStaticData.getTickersByCategory(category);
    }
  }

  /// 인기 종목 조회
  Future<List<InvestmentTicker>> getPopularTickers({String? category}) async {
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

      return tickers;
    } catch (e) {
      debugPrint('⚠️ [TickerRepository] API failed, using static data: $e');
      return TickerStaticData.getPopularTickers(category: category);
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
}
