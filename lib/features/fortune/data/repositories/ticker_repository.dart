import '../models/investment_ticker.dart';
import '../datasources/ticker_static_data.dart';

/// 티커 데이터 Repository
/// 정적 데이터만 사용 (트래픽 절감, 오프라인 지원)
class TickerRepository {
  TickerRepository();

  /// 카테고리별 티커 조회
  List<InvestmentTicker> getTickersByCategory(String category) {
    return TickerStaticData.getTickersByCategory(category);
  }

  /// 인기 종목 조회
  List<InvestmentTicker> getPopularTickers({String? category}) {
    return TickerStaticData.getPopularTickers(category: category);
  }

  /// 티커 검색
  List<InvestmentTicker> searchTickers(
    String query, {
    String? category,
  }) {
    if (query.trim().isEmpty) {
      return category != null
          ? getTickersByCategory(category)
          : getPopularTickers();
    }
    return TickerStaticData.searchTickers(query, category: category);
  }

  /// 전체 티커 조회 (카테고리별 그룹화)
  Map<String, List<InvestmentTicker>> getAllTickersByCategory() {
    return TickerStaticData.getAllTickersByCategory();
  }
}
