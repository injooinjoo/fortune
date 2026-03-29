// In-App Purchase Product IDs - 리뷰/서버 기준 카탈로그
class InAppProducts {
  // Consumable Products (기본 토큰 패키지)
  static const String tokens10 = 'com.beyond.ondo.tokens10';
  static const String tokens50 = 'com.beyond.ondo.tokens50';
  static const String tokens100 = 'com.beyond.ondo.tokens100';
  static const String tokens200 = 'com.beyond.ondo.tokens200';

  // Alternate token products kept for compatibility while the catalog settles.
  static const String points300 = 'com.beyond.ondo.points300';
  static const String points600 = 'com.beyond.ondo.points600';
  static const String points1200 = 'com.beyond.ondo.points1200';
  static const String points3000 = 'com.beyond.ondo.points3000';

  // Subscription Products (Pro / Max)
  static const String proSubscription =
      'com.beyond.ondo.subscription.monthly'; // Pro 월간 구독
  static const String maxSubscription = 'com.beyond.ondo.subscription.max';

  // Non-Consumable Products (평생 소유)
  static const String premiumSajuLifetime =
      'com.beyond.ondo.premium_saju_lifetime';

  // Product Details
  static const Map<String, ProductInfo> productDetails = {
    tokens10: ProductInfo(
      id: tokens10,
      title: '10 Tokens',
      description: '기본 운세를 가볍게 체험할 수 있는 스타터 패키지',
      price: 1100,
      points: 10,
      basePoints: 10,
      isSubscription: false,
    ),
    tokens50: ProductInfo(
      id: tokens50,
      title: '50 Tokens',
      description: '자주 사용하는 분들을 위한 50 토큰 패키지',
      price: 4500,
      points: 50,
      basePoints: 50,
      bonusPoints: 5,
      isSubscription: false,
    ),
    tokens100: ProductInfo(
      id: tokens100,
      title: '100 Tokens',
      description: '다양한 운세와 깊이 있는 인사이트를 위한 알찬 패키지',
      price: 8000,
      points: 100,
      basePoints: 100,
      bonusPoints: 15,
      isSubscription: false,
    ),
    tokens200: ProductInfo(
      id: tokens200,
      title: '200 Tokens',
      description: '헤비 유저를 위한 최대 가성비 토큰 패키지',
      price: 14000,
      points: 200,
      basePoints: 200,
      bonusPoints: 30,
      isSubscription: false,
    ),
    points300: ProductInfo(
      id: points300,
      title: '350 토큰',
      description: '호환용 토큰 패키지',
      price: 3300,
      points: 350,
      basePoints: 300,
      bonusPoints: 50,
      isSubscription: false,
    ),
    points600: ProductInfo(
      id: points600,
      title: '700 토큰',
      description: '호환용 토큰 패키지',
      price: 5500,
      points: 700,
      basePoints: 600,
      bonusPoints: 100,
      isSubscription: false,
    ),
    points1200: ProductInfo(
      id: points1200,
      title: '1,650 토큰',
      description: '호환용 토큰 패키지',
      price: 11000,
      points: 1650,
      basePoints: 1500,
      bonusPoints: 150,
      isSubscription: false,
    ),
    points3000: ProductInfo(
      id: points3000,
      title: '4,400 토큰',
      description: '호환용 토큰 패키지',
      price: 22000,
      points: 4400,
      basePoints: 4000,
      bonusPoints: 400,
      isSubscription: false,
    ),
    proSubscription: ProductInfo(
      id: proSubscription,
      title: 'Pro 구독',
      description: '매월 토큰이 자동 충전되는 기본 구독 플랜',
      price: 4500,
      points: 30000,
      isSubscription: true,
      subscriptionPeriod: 'monthly',
    ),
    maxSubscription: ProductInfo(
      id: maxSubscription,
      title: 'Max 구독',
      description: '모든 기능을 넉넉하게 쓰는 고급 구독 플랜',
      price: 12900,
      points: 100000,
      isSubscription: true,
      subscriptionPeriod: 'max',
    ),
    premiumSajuLifetime: ProductInfo(
      id: premiumSajuLifetime,
      title: '상세 사주명리서',
      description: '215페이지 상세 사주 분석서 (평생 소유)',
      price: 39000,
      points: 0,
      isSubscription: false,
      isNonConsumable: true,
    ),
  };

  // Active consumable product IDs (displayed in store UI)
  static List<String> get consumableIds => [
        tokens10,
        tokens50,
        tokens100,
        tokens200,
      ];

  // Legacy product IDs kept for server-side compatibility / restore
  static List<String> get legacyConsumableIds => [
        points300,
        points600,
        points1200,
        points3000,
      ];

  // Get all subscription product IDs
  static List<String> get subscriptionIds => [
        proSubscription,
        maxSubscription,
      ];

  // Get all non-consumable product IDs (평생 소유)
  static List<String> get nonConsumableIds => [
        premiumSajuLifetime,
      ];

  // Get all product IDs (including legacy for store queries)
  static List<String> get allProductIds => [
        ...consumableIds,
        ...legacyConsumableIds,
        ...subscriptionIds,
        ...nonConsumableIds,
      ];

  static int displayPriority(String productId) {
    const priorities = <String, int>{
      // Subscriptions first
      proSubscription: 0,
      maxSubscription: 1,
      // Token packages: small → large
      tokens10: 10,
      tokens50: 11,
      tokens100: 12,
      tokens200: 13,
      // Non-consumable
      premiumSajuLifetime: 20,
      // Legacy (hidden from UI but queryable)
      points300: 90,
      points600: 91,
      points1200: 92,
      points3000: 93,
    };
    return priorities[productId] ?? 999;
  }
}

class ProductInfo {
  final String id;
  final String title;
  final String description;
  final int price; // in KRW
  final int points; // 총 토큰 (보너스 포함)
  final int? basePoints; // 기본 토큰
  final int? bonusPoints; // 보너스 토큰
  final bool isSubscription;
  final String? subscriptionPeriod; // 'monthly' or 'yearly'
  final bool isNonConsumable; // 평생 소유 상품
  final int? dailyPointLimit; // 구독 시 일일 한도

  const ProductInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.points,
    this.basePoints,
    this.bonusPoints,
    required this.isSubscription,
    this.subscriptionPeriod,
    this.isNonConsumable = false,
    this.dailyPointLimit,
  });

  /// 구독 여부에 따른 혜택 문구
  String get benefitText {
    if (isSubscription) {
      return '매일 $dailyPointLimit 토큰 충전';
    }
    if (bonusPoints != null && bonusPoints! > 0) {
      return '$basePoints + $bonusPoints 보너스';
    }
    return '$points 토큰 충전';
  }

  /// 토큰당 가격 (원)
  double get pricePerToken {
    if (points <= 0) return 0;
    return price / points;
  }

  /// 포인트당 가격 (원) - 레거시 호환
  double get pricePerPoint => pricePerToken;

  /// 월간 가격 반환
  int get monthlyEquivalentPrice => price;

  /// Pro 대비 Max 절약률 (Max 구독 시)
  int get savingsPercent {
    if (subscriptionPeriod == 'max') {
      // Pro 가격 대비 토큰당 가격 절약률
      const proPrice = 3300;
      const proTokens = 3000;
      final proPricePerToken = proPrice / proTokens;
      final maxPricePerToken = price / points;
      return (((proPricePerToken - maxPricePerToken) / proPricePerToken) * 100)
          .round();
    }
    return 0;
  }
}
