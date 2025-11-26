import '../models/investment_ticker.dart';

/// 정적 종목 데이터
/// 카테고리별 인기 종목 약 100개
class TickerStaticData {
  TickerStaticData._();

  /// 전체 종목 데이터
  static final Map<String, List<InvestmentTicker>> tickersByCategory = {
    'crypto': _cryptoTickers,
    'krStock': _krStockTickers,
    'usStock': _usStockTickers,
    'etf': _etfTickers,
    'commodity': _commodityTickers,
    'realEstate': _realEstateTickers,
  };

  /// 카테고리별 종목 조회
  static List<InvestmentTicker> getTickersByCategory(String category) {
    return tickersByCategory[category] ?? [];
  }

  /// 인기 종목만 조회
  static List<InvestmentTicker> getPopularTickers({String? category}) {
    if (category != null) {
      return getTickersByCategory(category)
          .where((t) => t.isPopular)
          .toList();
    }
    // 카테고리 지정 없으면 전체 인기 종목
    return tickersByCategory.values
        .expand((list) => list)
        .where((t) => t.isPopular)
        .toList();
  }

  /// 전체 종목 데이터 반환 (카테고리별 Map)
  static Map<String, List<InvestmentTicker>> getAllTickersByCategory() {
    return Map.from(tickersByCategory);
  }

  /// 종목 검색
  static List<InvestmentTicker> searchTickers(String query, {String? category}) {
    final lowerQuery = query.toLowerCase();

    List<InvestmentTicker> tickers;
    if (category != null) {
      tickers = getTickersByCategory(category);
    } else {
      tickers = tickersByCategory.values.expand((list) => list).toList();
    }

    return tickers.where((t) {
      return t.symbol.toLowerCase().contains(lowerQuery) ||
             t.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// 코인 (20개)
  static final List<InvestmentTicker> _cryptoTickers = [
    const InvestmentTicker(symbol: 'BTC', name: '비트코인', category: 'crypto', exchange: 'BINANCE', isPopular: true),
    const InvestmentTicker(symbol: 'ETH', name: '이더리움', category: 'crypto', exchange: 'BINANCE', isPopular: true),
    const InvestmentTicker(symbol: 'XRP', name: '리플', category: 'crypto', exchange: 'BINANCE', isPopular: true),
    const InvestmentTicker(symbol: 'SOL', name: '솔라나', category: 'crypto', exchange: 'BINANCE', isPopular: true),
    const InvestmentTicker(symbol: 'ADA', name: '에이다', category: 'crypto', exchange: 'BINANCE', isPopular: true),
    const InvestmentTicker(symbol: 'DOGE', name: '도지코인', category: 'crypto', exchange: 'BINANCE', isPopular: true),
    const InvestmentTicker(symbol: 'DOT', name: '폴카닷', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'AVAX', name: '아발란체', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'MATIC', name: '폴리곤', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'LINK', name: '체인링크', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'UNI', name: '유니스왑', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'ATOM', name: '코스모스', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'LTC', name: '라이트코인', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'BCH', name: '비트코인캐시', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'XLM', name: '스텔라루멘', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'ALGO', name: '알고랜드', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'VET', name: '비체인', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'FIL', name: '파일코인', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'SAND', name: '샌드박스', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'APT', name: '앱토스', category: 'crypto', exchange: 'BINANCE'),
  ];

  /// 국내주식 (25개)
  static final List<InvestmentTicker> _krStockTickers = [
    const InvestmentTicker(symbol: '005930', name: '삼성전자', category: 'krStock', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '000660', name: 'SK하이닉스', category: 'krStock', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '373220', name: 'LG에너지솔루션', category: 'krStock', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '207940', name: '삼성바이오로직스', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '005380', name: '현대차', category: 'krStock', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '000270', name: '기아', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '068270', name: '셀트리온', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '105560', name: 'KB금융', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '055550', name: '신한지주', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '005490', name: 'POSCO홀딩스', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '035420', name: '네이버', category: 'krStock', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '035720', name: '카카오', category: 'krStock', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '006400', name: '삼성SDI', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '051910', name: 'LG화학', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '012330', name: '현대모비스', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '028260', name: '삼성물산', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '096770', name: 'SK이노베이션', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '086790', name: '하나금융지주', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '316140', name: '우리금융지주', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '033780', name: 'KT&G', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '032830', name: '삼성생명', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '015760', name: '한국전력', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '017670', name: 'SK텔레콤', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '066570', name: 'LG전자', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '090430', name: '아모레퍼시픽', category: 'krStock', exchange: 'KRX'),
  ];

  /// 해외주식 (25개)
  static final List<InvestmentTicker> _usStockTickers = [
    const InvestmentTicker(symbol: 'AAPL', name: '애플', category: 'usStock', exchange: 'NASDAQ', isPopular: true),
    const InvestmentTicker(symbol: 'MSFT', name: '마이크로소프트', category: 'usStock', exchange: 'NASDAQ', isPopular: true),
    const InvestmentTicker(symbol: 'GOOGL', name: '알파벳(구글)', category: 'usStock', exchange: 'NASDAQ', isPopular: true),
    const InvestmentTicker(symbol: 'AMZN', name: '아마존', category: 'usStock', exchange: 'NASDAQ', isPopular: true),
    const InvestmentTicker(symbol: 'NVDA', name: '엔비디아', category: 'usStock', exchange: 'NASDAQ', isPopular: true),
    const InvestmentTicker(symbol: 'META', name: '메타(페이스북)', category: 'usStock', exchange: 'NASDAQ', isPopular: true),
    const InvestmentTicker(symbol: 'TSLA', name: '테슬라', category: 'usStock', exchange: 'NASDAQ', isPopular: true),
    const InvestmentTicker(symbol: 'BRK.B', name: '버크셔해서웨이', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'UNH', name: '유나이티드헬스', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'JNJ', name: '존슨앤존슨', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'V', name: '비자', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'MA', name: '마스터카드', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'PG', name: '프록터앤갬블', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'HD', name: '홈디포', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'DIS', name: '월트디즈니', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'PYPL', name: '페이팔', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'NFLX', name: '넷플릭스', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'ADBE', name: '어도비', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'CRM', name: '세일즈포스', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'INTC', name: '인텔', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'AMD', name: 'AMD', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'QCOM', name: '퀄컴', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'COST', name: '코스트코', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'PEP', name: '펩시코', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'KO', name: '코카콜라', category: 'usStock', exchange: 'NYSE'),
  ];

  /// ETF (20개)
  static final List<InvestmentTicker> _etfTickers = [
    const InvestmentTicker(symbol: 'SPY', name: 'SPDR S&P 500', category: 'etf', exchange: 'NYSE', isPopular: true),
    const InvestmentTicker(symbol: 'QQQ', name: 'Invesco QQQ (나스닥100)', category: 'etf', exchange: 'NASDAQ', isPopular: true),
    const InvestmentTicker(symbol: 'IWM', name: 'iShares Russell 2000', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'DIA', name: 'SPDR Dow Jones', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'VTI', name: 'Vanguard Total Stock', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'VOO', name: 'Vanguard S&P 500', category: 'etf', exchange: 'NYSE', isPopular: true),
    const InvestmentTicker(symbol: 'VEA', name: 'Vanguard FTSE Developed', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'VWO', name: 'Vanguard FTSE Emerging', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'EEM', name: 'iShares MSCI Emerging', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'GLD', name: 'SPDR Gold Shares', category: 'etf', exchange: 'NYSE', isPopular: true),
    const InvestmentTicker(symbol: 'SLV', name: 'iShares Silver Trust', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'TLT', name: 'iShares 20+ Year Treasury', category: 'etf', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'ARKK', name: 'ARK Innovation ETF', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: '069500', name: 'KODEX 200', category: 'etf', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '102110', name: 'TIGER 200', category: 'etf', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '122630', name: 'KODEX 레버리지', category: 'etf', exchange: 'KRX'),
    const InvestmentTicker(symbol: '360750', name: 'TIGER 미국S&P500', category: 'etf', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '133690', name: 'TIGER 미국나스닥100', category: 'etf', exchange: 'KRX'),
    const InvestmentTicker(symbol: '114800', name: 'KODEX 인버스', category: 'etf', exchange: 'KRX'),
    const InvestmentTicker(symbol: '252670', name: 'KODEX 200선물인버스2X', category: 'etf', exchange: 'KRX'),
  ];

  /// 금/원자재 (5개)
  static final List<InvestmentTicker> _commodityTickers = [
    const InvestmentTicker(symbol: 'GOLD', name: '금', category: 'commodity', description: '금 현물', isPopular: true),
    const InvestmentTicker(symbol: 'SILVER', name: '은', category: 'commodity', description: '은 현물', isPopular: true),
    const InvestmentTicker(symbol: 'WTI', name: '원유(WTI)', category: 'commodity', description: '서부텍사스유', isPopular: true),
    const InvestmentTicker(symbol: 'COPPER', name: '구리', category: 'commodity', description: '구리 선물'),
    const InvestmentTicker(symbol: 'NG', name: '천연가스', category: 'commodity', description: '천연가스 선물'),
  ];

  /// 부동산 (5개)
  static final List<InvestmentTicker> _realEstateTickers = [
    const InvestmentTicker(symbol: 'SEOUL_APT', name: '서울 아파트', category: 'realEstate', description: '서울 지역 아파트', isPopular: true),
    const InvestmentTicker(symbol: 'METRO_APT', name: '수도권 아파트', category: 'realEstate', description: '수도권 지역 아파트', isPopular: true),
    const InvestmentTicker(symbol: 'OFFICETEL', name: '오피스텔', category: 'realEstate', description: '도심 오피스텔'),
    const InvestmentTicker(symbol: 'COMMERCIAL', name: '상업용 부동산', category: 'realEstate', description: '상가, 오피스'),
    const InvestmentTicker(symbol: 'GLOBAL_REIT', name: '글로벌 REITs', category: 'realEstate', description: '해외 부동산 리츠', isPopular: true),
  ];
}
