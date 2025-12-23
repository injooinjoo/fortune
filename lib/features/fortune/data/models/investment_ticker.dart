import 'package:freezed_annotation/freezed_annotation.dart';

part 'investment_ticker.freezed.dart';
part 'investment_ticker.g.dart';

/// 투자 카테고리 정의
enum InvestmentCategory {
  crypto('코인', 'BTC, ETH 등 암호화폐', 'currency_bitcoin'),
  krStock('국내주식', 'KOSPI, KOSDAQ 상장 종목', 'trending_up'),
  usStock('해외주식', 'NYSE, NASDAQ 상장 종목', 'show_chart'),
  etf('ETF', '국내외 상장지수펀드', 'pie_chart'),
  commodity('금/원자재', '금, 은, 원유 등', 'diamond'),
  realEstate('부동산', '아파트, REITs 등', 'home');

  final String label;
  final String description;
  final String iconName;

  const InvestmentCategory(this.label, this.description, this.iconName);

  /// 이미지 경로 반환
  String get imagePath {
    switch (this) {
      case InvestmentCategory.crypto:
        return 'assets/images/fortune/categories/investment_crypto.png';
      case InvestmentCategory.krStock:
        return 'assets/images/fortune/categories/investment_kr_stock.png';
      case InvestmentCategory.usStock:
        return 'assets/images/fortune/categories/investment_us_stock.png';
      case InvestmentCategory.etf:
        return 'assets/images/fortune/categories/investment_etf.png';
      case InvestmentCategory.commodity:
        return 'assets/images/fortune/categories/investment_commodity.png';
      case InvestmentCategory.realEstate:
        return 'assets/images/fortune/categories/investment_real_estate.png';
    }
  }

  /// 카테고리 코드로부터 enum 반환
  static InvestmentCategory fromCode(String code) {
    return InvestmentCategory.values.firstWhere(
      (c) => c.name == code,
      orElse: () => InvestmentCategory.krStock,
    );
  }
}

/// 투자 종목 (티커) 모델
@freezed
class InvestmentTicker with _$InvestmentTicker {
  const factory InvestmentTicker({
    required String symbol,
    required String name,
    required String category,
    String? exchange,
    String? description,
    @Default(false) bool isPopular,
  }) = _InvestmentTicker;

  factory InvestmentTicker.fromJson(Map<String, dynamic> json) =>
      _$InvestmentTickerFromJson(json);
}
