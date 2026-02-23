// In-App Purchase Product IDs - 토큰 시스템
class InAppProducts {
  // Consumable Products (토큰 패키지)
  static const String points300 = 'com.beyond.fortune.points300';
  static const String points600 = 'com.beyond.fortune.points600';
  static const String points1200 = 'com.beyond.fortune.points1200';
  static const String points3000 = 'com.beyond.fortune.points3000';

  // Subscription Products (Pro / Max)
  static const String proSubscription =
      'com.beyond.fortune.subscription.monthly'; // Pro 월간 구독
  static const String maxSubscription =
      'com.beyond.fortune.subscription.max'; // Max 월간 구독 (신규)

  // Non-Consumable Products (평생 소유)
  static const String premiumSajuLifetime =
      'com.beyond.fortune.premium_saju_lifetime';

  // Product Details
  static const Map<String, ProductInfo> productDetails = {
    points300: ProductInfo(
      id: points300,
      title: '350 토큰',
      description: '300 + 50 보너스',
      price: 3300,
      points: 350,
      basePoints: 300,
      bonusPoints: 50,
      isSubscription: false,
    ),
    points600: ProductInfo(
      id: points600,
      title: '700 토큰',
      description: '600 + 100 보너스',
      price: 5500,
      points: 700,
      basePoints: 600,
      bonusPoints: 100,
      isSubscription: false,
    ),
    points1200: ProductInfo(
      id: points1200,
      title: '1,650 토큰',
      description: '1,500 + 150 보너스',
      price: 11000,
      points: 1650,
      basePoints: 1500,
      bonusPoints: 150,
      isSubscription: false,
    ),
    points3000: ProductInfo(
      id: points3000,
      title: '4,400 토큰',
      description: '4,000 + 400 보너스',
      price: 22000,
      points: 4400,
      basePoints: 4000,
      bonusPoints: 400,
      isSubscription: false,
    ),
    proSubscription: ProductInfo(
      id: proSubscription,
      title: 'Pro 구독',
      description: '매월 3,000 토큰 자동 충전',
      price: 3300,
      points: 3000, // 월간 토큰
      isSubscription: true,
      subscriptionPeriod: 'pro',
    ),
    maxSubscription: ProductInfo(
      id: maxSubscription,
      title: 'Max 구독',
      description: '매월 12,600 토큰 자동 충전',
      price: 13000,
      points: 12600, // 월간 토큰
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

  // Get all consumable product IDs
  static List<String> get consumableIds => [
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

  // Get all product IDs
  static List<String> get allProductIds => [
        ...consumableIds,
        ...subscriptionIds,
        ...nonConsumableIds,
      ];

  // Legacy product IDs (마이그레이션 기간용)
  static const String tokens10 = 'com.beyond.fortune.tokens10';
  static const String tokens50 = 'com.beyond.fortune.tokens50';
  static const String tokens100 = 'com.beyond.fortune.tokens100';
  static const String tokens200 = 'com.beyond.fortune.tokens200';
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
