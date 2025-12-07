import '../models/investment_ticker.dart';

/// 정적 종목 데이터
/// 카테고리별 종목 약 330개 (오프라인/로컬 전용)
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

  /// ========== 코인 (50개) ==========
  static final List<InvestmentTicker> _cryptoTickers = [
    // 시총 상위 (인기)
    const InvestmentTicker(symbol: 'BTC', name: '비트코인', category: 'crypto', exchange: 'BINANCE', isPopular: true),
    const InvestmentTicker(symbol: 'ETH', name: '이더리움', category: 'crypto', exchange: 'BINANCE', isPopular: true),
    const InvestmentTicker(symbol: 'XRP', name: '리플', category: 'crypto', exchange: 'BINANCE', isPopular: true),
    const InvestmentTicker(symbol: 'SOL', name: '솔라나', category: 'crypto', exchange: 'BINANCE', isPopular: true),
    const InvestmentTicker(symbol: 'BNB', name: '바이낸스코인', category: 'crypto', exchange: 'BINANCE', isPopular: true),
    const InvestmentTicker(symbol: 'ADA', name: '에이다', category: 'crypto', exchange: 'BINANCE', isPopular: true),
    const InvestmentTicker(symbol: 'DOGE', name: '도지코인', category: 'crypto', exchange: 'BINANCE', isPopular: true),
    const InvestmentTicker(symbol: 'TRX', name: '트론', category: 'crypto', exchange: 'BINANCE', isPopular: true),
    // 주요 알트코인
    const InvestmentTicker(symbol: 'AVAX', name: '아발란체', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'DOT', name: '폴카닷', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'LINK', name: '체인링크', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'MATIC', name: '폴리곤', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'SHIB', name: '시바이누', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'LTC', name: '라이트코인', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'BCH', name: '비트코인캐시', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'UNI', name: '유니스왑', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'ATOM', name: '코스모스', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'XLM', name: '스텔라루멘', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'NEAR', name: '니어프로토콜', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'FIL', name: '파일코인', category: 'crypto', exchange: 'BINANCE'),
    // Layer2 & 신규 코인
    const InvestmentTicker(symbol: 'ARB', name: '아비트럼', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'OP', name: '옵티미즘', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'APT', name: '앱토스', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'SUI', name: '수이', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'SEI', name: '세이', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'TIA', name: '셀레스티아', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'INJ', name: '인젝티브', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'IMX', name: '이뮤터블X', category: 'crypto', exchange: 'BINANCE'),
    // DeFi
    const InvestmentTicker(symbol: 'AAVE', name: '에이브', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'MKR', name: '메이커', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'CRV', name: '커브', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'LDO', name: '리도', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'SNX', name: '신세틱스', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'COMP', name: '컴파운드', category: 'crypto', exchange: 'BINANCE'),
    // 게임/메타버스
    const InvestmentTicker(symbol: 'SAND', name: '샌드박스', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'MANA', name: '디센트럴랜드', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'AXS', name: '엑시인피니티', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'GALA', name: '갈라', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'APE', name: '에이프코인', category: 'crypto', exchange: 'BINANCE'),
    // 기타 주요 코인
    const InvestmentTicker(symbol: 'VET', name: '비체인', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'ALGO', name: '알고랜드', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'HBAR', name: '헤데라', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'ICP', name: '인터넷컴퓨터', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'FTM', name: '팬텀', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'THETA', name: '쎄타', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'XTZ', name: '테조스', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'EOS', name: '이오스', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'EGLD', name: '멀티버스X', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'KLAY', name: '클레이튼', category: 'crypto', exchange: 'BINANCE'),
    const InvestmentTicker(symbol: 'PEPE', name: '페페', category: 'crypto', exchange: 'BINANCE'),
  ];

  /// ========== 국내주식 (100개) ==========
  static final List<InvestmentTicker> _krStockTickers = [
    // 시총 상위 (인기)
    const InvestmentTicker(symbol: '005930', name: '삼성전자', category: 'krStock', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '000660', name: 'SK하이닉스', category: 'krStock', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '373220', name: 'LG에너지솔루션', category: 'krStock', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '005380', name: '현대차', category: 'krStock', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '035420', name: 'NAVER', category: 'krStock', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '035720', name: '카카오', category: 'krStock', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '207940', name: '삼성바이오로직스', category: 'krStock', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '006400', name: '삼성SDI', category: 'krStock', exchange: 'KRX', isPopular: true),
    // 대형주
    const InvestmentTicker(symbol: '000270', name: '기아', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '068270', name: '셀트리온', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '105560', name: 'KB금융', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '055550', name: '신한지주', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '005490', name: 'POSCO홀딩스', category: 'krStock', exchange: 'KRX'),
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
    const InvestmentTicker(symbol: '034730', name: 'SK', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '003550', name: 'LG', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '018260', name: '삼성에스디에스', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '010130', name: '고려아연', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '011200', name: 'HMM', category: 'krStock', exchange: 'KRX'),
    // 게임/엔터
    const InvestmentTicker(symbol: '259960', name: '크래프톤', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '036570', name: '엔씨소프트', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '251270', name: '넷마블', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '263750', name: '펄어비스', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '293490', name: '카카오게임즈', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '352820', name: '하이브', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '041510', name: 'SM', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '122870', name: 'YG엔터테인먼트', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '035900', name: 'JYP엔터테인먼트', category: 'krStock', exchange: 'KRX'),
    // 바이오/헬스케어
    const InvestmentTicker(symbol: '091990', name: '셀트리온헬스케어', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '326030', name: 'SK바이오팜', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '145020', name: '휴젤', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '196170', name: '알테오젠', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '141080', name: '레고켐바이오', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '328130', name: '루닛', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '950160', name: '코오롱티슈진', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '214370', name: '케어젠', category: 'krStock', exchange: 'KRX'),
    // IT/반도체
    const InvestmentTicker(symbol: '402340', name: 'SK스퀘어', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '247540', name: '에코프로비엠', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '086520', name: '에코프로', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '003670', name: '포스코퓨처엠', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '058470', name: '리노공업', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '000990', name: 'DB하이텍', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '042700', name: '한미반도체', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '357780', name: '솔브레인', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '240810', name: '원익IPS', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '005290', name: '동진쎄미켐', category: 'krStock', exchange: 'KRX'),
    // 2차전지/에너지
    const InvestmentTicker(symbol: '006280', name: '녹십자', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '112610', name: '씨에스윈드', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '009540', name: '한국조선해양', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '329180', name: 'HD현대중공업', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '267260', name: 'HD현대일렉트릭', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '336260', name: '두산퓨얼셀', category: 'krStock', exchange: 'KRX'),
    // 소비재/유통
    const InvestmentTicker(symbol: '051900', name: 'LG생활건강', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '097950', name: 'CJ제일제당', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '004170', name: '신세계', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '139480', name: '이마트', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '069960', name: '현대백화점', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '023530', name: '롯데쇼핑', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '034220', name: 'LG디스플레이', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '018880', name: '한온시스템', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '010950', name: 'S-Oil', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '009150', name: '삼성전기', category: 'krStock', exchange: 'KRX'),
    // 통신/미디어
    const InvestmentTicker(symbol: '030200', name: 'KT', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '032640', name: 'LG유플러스', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '079160', name: 'CJ CGV', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '034120', name: 'SBS', category: 'krStock', exchange: 'KRX'),
    // 건설/부동산
    const InvestmentTicker(symbol: '000720', name: '현대건설', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '028050', name: '삼성엔지니어링', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '000210', name: 'DL', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '047040', name: '대우건설', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '006360', name: 'GS건설', category: 'krStock', exchange: 'KRX'),
    // 금융
    const InvestmentTicker(symbol: '138930', name: 'BNK금융지주', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '024110', name: '기업은행', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '139130', name: 'DGB금융지주', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '000810', name: '삼성화재', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '088350', name: '한화생명', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '005830', name: 'DB손해보험', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '001450', name: '현대해상', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '006800', name: '미래에셋증권', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '005940', name: 'NH투자증권', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '016360', name: '삼성증권', category: 'krStock', exchange: 'KRX'),
    // 기타 중소형
    const InvestmentTicker(symbol: '011170', name: '롯데케미칼', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '011780', name: '금호석유', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '009830', name: '한화솔루션', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '003490', name: '대한항공', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '020560', name: '아시아나항공', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '004020', name: '현대제철', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '161390', name: '한국타이어앤테크놀로지', category: 'krStock', exchange: 'KRX'),
    const InvestmentTicker(symbol: '004000', name: '롯데정밀화학', category: 'krStock', exchange: 'KRX'),
  ];

  /// ========== 해외주식 (100개) ==========
  static final List<InvestmentTicker> _usStockTickers = [
    // 빅테크 (인기)
    const InvestmentTicker(symbol: 'AAPL', name: '애플', category: 'usStock', exchange: 'NASDAQ', isPopular: true),
    const InvestmentTicker(symbol: 'MSFT', name: '마이크로소프트', category: 'usStock', exchange: 'NASDAQ', isPopular: true),
    const InvestmentTicker(symbol: 'GOOGL', name: '알파벳(구글)', category: 'usStock', exchange: 'NASDAQ', isPopular: true),
    const InvestmentTicker(symbol: 'AMZN', name: '아마존', category: 'usStock', exchange: 'NASDAQ', isPopular: true),
    const InvestmentTicker(symbol: 'NVDA', name: '엔비디아', category: 'usStock', exchange: 'NASDAQ', isPopular: true),
    const InvestmentTicker(symbol: 'META', name: '메타(페이스북)', category: 'usStock', exchange: 'NASDAQ', isPopular: true),
    const InvestmentTicker(symbol: 'TSLA', name: '테슬라', category: 'usStock', exchange: 'NASDAQ', isPopular: true),
    const InvestmentTicker(symbol: 'NFLX', name: '넷플릭스', category: 'usStock', exchange: 'NASDAQ', isPopular: true),
    // 반도체
    const InvestmentTicker(symbol: 'AMD', name: 'AMD', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'INTC', name: '인텔', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'AVGO', name: '브로드컴', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'QCOM', name: '퀄컴', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'MU', name: '마이크론', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'ARM', name: 'ARM홀딩스', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'ASML', name: 'ASML', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'TSM', name: 'TSMC', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'TXN', name: '텍사스인스트루먼트', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'MRVL', name: '마벨테크놀로지', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'LRCX', name: '램리서치', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'KLAC', name: 'KLA', category: 'usStock', exchange: 'NASDAQ'),
    // IT 서비스/소프트웨어
    const InvestmentTicker(symbol: 'CRM', name: '세일즈포스', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'ADBE', name: '어도비', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'ORCL', name: '오라클', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'IBM', name: 'IBM', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'NOW', name: '서비스나우', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'SNOW', name: '스노우플레이크', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'PLTR', name: '팔란티어', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'PANW', name: '팔로알토네트웍스', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'CRWD', name: '크라우드스트라이크', category: 'usStock', exchange: 'NASDAQ'),
    // 전기차/자동차
    const InvestmentTicker(symbol: 'RIVN', name: '리비안', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'LCID', name: '루시드', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'NIO', name: '니오', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'XPEV', name: '샤오펑', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'LI', name: '리오토', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'F', name: '포드', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'GM', name: 'GM', category: 'usStock', exchange: 'NYSE'),
    // 핀테크/금융
    const InvestmentTicker(symbol: 'V', name: '비자', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'MA', name: '마스터카드', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'PYPL', name: '페이팔', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'SQ', name: '블록(스퀘어)', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'COIN', name: '코인베이스', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'HOOD', name: '로빈후드', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'SOFI', name: '소파이', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'AXP', name: '아메리칸익스프레스', category: 'usStock', exchange: 'NYSE'),
    // 은행/투자
    const InvestmentTicker(symbol: 'JPM', name: 'JP모건', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'BAC', name: '뱅크오브아메리카', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'WFC', name: '웰스파고', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'GS', name: '골드만삭스', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'MS', name: '모건스탠리', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'BRK.B', name: '버크셔해서웨이', category: 'usStock', exchange: 'NYSE'),
    // 헬스케어/바이오
    const InvestmentTicker(symbol: 'JNJ', name: '존슨앤존슨', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'UNH', name: '유나이티드헬스', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'PFE', name: '화이자', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'ABBV', name: '애브비', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'MRK', name: '머크', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'LLY', name: '일라이릴리', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'TMO', name: '써모피셔', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'MRNA', name: '모더나', category: 'usStock', exchange: 'NASDAQ'),
    // 소비재/유통
    const InvestmentTicker(symbol: 'WMT', name: '월마트', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'COST', name: '코스트코', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'HD', name: '홈디포', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'TGT', name: '타겟', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'NKE', name: '나이키', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'SBUX', name: '스타벅스', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'MCD', name: '맥도날드', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'DIS', name: '월트디즈니', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'PG', name: '프록터앤갬블', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'KO', name: '코카콜라', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'PEP', name: '펩시코', category: 'usStock', exchange: 'NASDAQ'),
    // 공유경제/여행
    const InvestmentTicker(symbol: 'UBER', name: '우버', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'LYFT', name: '리프트', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'ABNB', name: '에어비앤비', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'BKNG', name: '부킹홀딩스', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'EXPE', name: '익스피디아', category: 'usStock', exchange: 'NASDAQ'),
    // 통신/미디어
    const InvestmentTicker(symbol: 'T', name: 'AT&T', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'VZ', name: '버라이즌', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'TMUS', name: 'T-모바일', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'CMCSA', name: '컴캐스트', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'PARA', name: '파라마운트', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'WBD', name: '워너브라더스', category: 'usStock', exchange: 'NASDAQ'),
    // 에너지
    const InvestmentTicker(symbol: 'XOM', name: '엑슨모빌', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'CVX', name: '쉐브론', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'COP', name: '코노코필립스', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'OXY', name: '옥시덴탈', category: 'usStock', exchange: 'NYSE'),
    // 항공우주/방산
    const InvestmentTicker(symbol: 'BA', name: '보잉', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'LMT', name: '록히드마틴', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'RTX', name: 'RTX(레이시온)', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'NOC', name: '노스롭그루먼', category: 'usStock', exchange: 'NYSE'),
    // 게임/엔터
    const InvestmentTicker(symbol: 'RBLX', name: '로블록스', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'EA', name: 'EA', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'TTWO', name: '테이크투', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'U', name: '유니티', category: 'usStock', exchange: 'NYSE'),
    // 전자상거래
    const InvestmentTicker(symbol: 'SHOP', name: '쇼피파이', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'ETSY', name: '엣시', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'EBAY', name: '이베이', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'MELI', name: '메르카도리브레', category: 'usStock', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'SE', name: 'SEA리미티드', category: 'usStock', exchange: 'NYSE'),
    // 기타
    const InvestmentTicker(symbol: 'CAT', name: '캐터필러', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'DE', name: '디어', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'MMM', name: '3M', category: 'usStock', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'HON', name: '허니웰', category: 'usStock', exchange: 'NASDAQ'),
  ];

  /// ========== ETF (50개) ==========
  static final List<InvestmentTicker> _etfTickers = [
    // 미국 대표 ETF (인기)
    const InvestmentTicker(symbol: 'SPY', name: 'SPDR S&P 500', category: 'etf', exchange: 'NYSE', isPopular: true),
    const InvestmentTicker(symbol: 'QQQ', name: 'Invesco QQQ(나스닥100)', category: 'etf', exchange: 'NASDAQ', isPopular: true),
    const InvestmentTicker(symbol: 'VOO', name: 'Vanguard S&P 500', category: 'etf', exchange: 'NYSE', isPopular: true),
    const InvestmentTicker(symbol: 'VTI', name: 'Vanguard Total Stock', category: 'etf', exchange: 'NYSE', isPopular: true),
    const InvestmentTicker(symbol: 'IWM', name: 'iShares Russell 2000', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'DIA', name: 'SPDR Dow Jones', category: 'etf', exchange: 'NYSE'),
    // 레버리지/인버스
    const InvestmentTicker(symbol: 'TQQQ', name: 'ProShares 나스닥3배', category: 'etf', exchange: 'NASDAQ', isPopular: true),
    const InvestmentTicker(symbol: 'SQQQ', name: 'ProShares 나스닥인버스3배', category: 'etf', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'SOXL', name: 'Direxion 반도체3배', category: 'etf', exchange: 'NYSE', isPopular: true),
    const InvestmentTicker(symbol: 'SOXS', name: 'Direxion 반도체인버스3배', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'SPXL', name: 'Direxion S&P3배', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'SPXS', name: 'Direxion S&P인버스3배', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'UPRO', name: 'ProShares S&P3배', category: 'etf', exchange: 'NYSE'),
    // 섹터 ETF
    const InvestmentTicker(symbol: 'XLK', name: 'SPDR 기술', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'XLF', name: 'SPDR 금융', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'XLE', name: 'SPDR 에너지', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'XLV', name: 'SPDR 헬스케어', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'XLI', name: 'SPDR 산업재', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'XLY', name: 'SPDR 임의소비재', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'XLP', name: 'SPDR 필수소비재', category: 'etf', exchange: 'NYSE'),
    // 반도체 ETF
    const InvestmentTicker(symbol: 'SOXX', name: 'iShares 반도체', category: 'etf', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'SMH', name: 'VanEck 반도체', category: 'etf', exchange: 'NASDAQ'),
    // 원자재/금
    const InvestmentTicker(symbol: 'GLD', name: 'SPDR Gold', category: 'etf', exchange: 'NYSE', isPopular: true),
    const InvestmentTicker(symbol: 'SLV', name: 'iShares Silver', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'USO', name: 'US Oil Fund', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'UNG', name: 'US Natural Gas', category: 'etf', exchange: 'NYSE'),
    // 채권 ETF
    const InvestmentTicker(symbol: 'TLT', name: 'iShares 20년+국채', category: 'etf', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'BND', name: 'Vanguard Total Bond', category: 'etf', exchange: 'NASDAQ'),
    const InvestmentTicker(symbol: 'LQD', name: 'iShares 투자등급회사채', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'HYG', name: 'iShares 하이일드', category: 'etf', exchange: 'NYSE'),
    // 글로벌/신흥국
    const InvestmentTicker(symbol: 'VEA', name: 'Vanguard 선진국', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'VWO', name: 'Vanguard 신흥국', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'EEM', name: 'iShares 신흥국', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'EFA', name: 'iShares EAFE', category: 'etf', exchange: 'NYSE'),
    // 테마 ETF
    const InvestmentTicker(symbol: 'ARKK', name: 'ARK Innovation', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'ARKG', name: 'ARK Genomic', category: 'etf', exchange: 'NYSE'),
    const InvestmentTicker(symbol: 'ARKW', name: 'ARK Next Gen Internet', category: 'etf', exchange: 'NYSE'),
    // 국내 ETF (인기)
    const InvestmentTicker(symbol: '069500', name: 'KODEX 200', category: 'etf', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '102110', name: 'TIGER 200', category: 'etf', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '122630', name: 'KODEX 레버리지', category: 'etf', exchange: 'KRX'),
    const InvestmentTicker(symbol: '114800', name: 'KODEX 인버스', category: 'etf', exchange: 'KRX'),
    const InvestmentTicker(symbol: '252670', name: 'KODEX 200선물인버스2X', category: 'etf', exchange: 'KRX'),
    const InvestmentTicker(symbol: '360750', name: 'TIGER 미국S&P500', category: 'etf', exchange: 'KRX', isPopular: true),
    const InvestmentTicker(symbol: '133690', name: 'TIGER 미국나스닥100', category: 'etf', exchange: 'KRX'),
    const InvestmentTicker(symbol: '379800', name: 'KODEX 미국S&P500TR', category: 'etf', exchange: 'KRX'),
    const InvestmentTicker(symbol: '379810', name: 'KODEX 미국나스닥100TR', category: 'etf', exchange: 'KRX'),
    const InvestmentTicker(symbol: '091160', name: 'KODEX 반도체', category: 'etf', exchange: 'KRX'),
    const InvestmentTicker(symbol: '091170', name: 'KODEX 은행', category: 'etf', exchange: 'KRX'),
    const InvestmentTicker(symbol: '117700', name: 'KODEX 건설', category: 'etf', exchange: 'KRX'),
    const InvestmentTicker(symbol: '143850', name: 'TIGER 200에너지화학', category: 'etf', exchange: 'KRX'),
  ];

  /// ========== 금/원자재 (15개) ==========
  static final List<InvestmentTicker> _commodityTickers = [
    // 귀금속 (인기)
    const InvestmentTicker(symbol: 'GOLD', name: '금', category: 'commodity', description: '금 현물', isPopular: true),
    const InvestmentTicker(symbol: 'SILVER', name: '은', category: 'commodity', description: '은 현물', isPopular: true),
    const InvestmentTicker(symbol: 'PLATINUM', name: '백금', category: 'commodity', description: '백금 현물'),
    const InvestmentTicker(symbol: 'PALLADIUM', name: '팔라듐', category: 'commodity', description: '팔라듐 현물'),
    // 에너지 (인기)
    const InvestmentTicker(symbol: 'WTI', name: '원유(WTI)', category: 'commodity', description: '서부텍사스유', isPopular: true),
    const InvestmentTicker(symbol: 'BRENT', name: '원유(브렌트)', category: 'commodity', description: '브렌트유'),
    const InvestmentTicker(symbol: 'NG', name: '천연가스', category: 'commodity', description: '천연가스 선물'),
    // 산업금속
    const InvestmentTicker(symbol: 'COPPER', name: '구리', category: 'commodity', description: '구리 선물'),
    const InvestmentTicker(symbol: 'ALUMINUM', name: '알루미늄', category: 'commodity', description: '알루미늄 선물'),
    const InvestmentTicker(symbol: 'NICKEL', name: '니켈', category: 'commodity', description: '니켈 선물'),
    const InvestmentTicker(symbol: 'ZINC', name: '아연', category: 'commodity', description: '아연 선물'),
    // 농산물
    const InvestmentTicker(symbol: 'WHEAT', name: '밀', category: 'commodity', description: '밀 선물'),
    const InvestmentTicker(symbol: 'CORN', name: '옥수수', category: 'commodity', description: '옥수수 선물'),
    const InvestmentTicker(symbol: 'SOYBEAN', name: '대두', category: 'commodity', description: '대두 선물'),
    const InvestmentTicker(symbol: 'COFFEE', name: '커피', category: 'commodity', description: '커피 선물'),
  ];

  /// ========== 부동산 (15개) ==========
  static final List<InvestmentTicker> _realEstateTickers = [
    // 국내 부동산 (인기)
    const InvestmentTicker(symbol: 'SEOUL_APT', name: '서울 아파트', category: 'realEstate', description: '서울 전체 아파트', isPopular: true),
    const InvestmentTicker(symbol: 'GANGNAM_APT', name: '강남 아파트', category: 'realEstate', description: '강남구 아파트', isPopular: true),
    const InvestmentTicker(symbol: 'METRO_APT', name: '수도권 아파트', category: 'realEstate', description: '경기/인천 아파트', isPopular: true),
    const InvestmentTicker(symbol: 'MAPO_APT', name: '마포 아파트', category: 'realEstate', description: '마포구 아파트'),
    const InvestmentTicker(symbol: 'YONGSAN_APT', name: '용산 아파트', category: 'realEstate', description: '용산구 아파트'),
    const InvestmentTicker(symbol: 'BUNDANG_APT', name: '분당 아파트', category: 'realEstate', description: '성남시 분당구'),
    const InvestmentTicker(symbol: 'PANGYO_APT', name: '판교 아파트', category: 'realEstate', description: '판교신도시'),
    const InvestmentTicker(symbol: 'BUSAN_APT', name: '부산 아파트', category: 'realEstate', description: '부산광역시'),
    const InvestmentTicker(symbol: 'HAEUNDAE_APT', name: '해운대 아파트', category: 'realEstate', description: '해운대구'),
    // 기타 부동산
    const InvestmentTicker(symbol: 'OFFICETEL', name: '오피스텔', category: 'realEstate', description: '전국 오피스텔'),
    const InvestmentTicker(symbol: 'COMMERCIAL', name: '상업용 부동산', category: 'realEstate', description: '상가, 오피스'),
    // REITs
    const InvestmentTicker(symbol: 'GLOBAL_REIT', name: '글로벌 REITs', category: 'realEstate', description: '해외 부동산 리츠', isPopular: true),
    const InvestmentTicker(symbol: 'VNQ', name: 'Vanguard REITs', category: 'realEstate', exchange: 'NYSE', description: '미국 리츠 ETF'),
    const InvestmentTicker(symbol: 'XLRE', name: 'SPDR 부동산', category: 'realEstate', exchange: 'NYSE', description: 'S&P 부동산섹터'),
    const InvestmentTicker(symbol: 'IYR', name: 'iShares 부동산', category: 'realEstate', exchange: 'NYSE', description: '미국 부동산 ETF'),
  ];
}
