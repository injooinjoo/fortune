// In-App Purchase Product IDs - 포인트 시스템
class InAppProducts {
  // Consumable Products (포인트 패키지)
  static const String points300 = 'com.beyond.fortune.points300';
  static const String points600 = 'com.beyond.fortune.points600';
  static const String points1200 = 'com.beyond.fortune.points1200';
  static const String points3000 = 'com.beyond.fortune.points3000';

  // Subscription Products (일일 1000P 한도)
  static const String monthlySubscription =
      'com.beyond.fortune.subscription.monthly';
  static const String yearlySubscription =
      'com.beyond.fortune.subscription.yearly';

  // Non-Consumable Products (평생 소유)
  static const String premiumSajuLifetime =
      'com.beyond.fortune.premium_saju_lifetime';

  // Product Details
  static const Map<String, ProductInfo> productDetails = {
    points300: ProductInfo(
      id: points300,
      title: '330 포인트',
      description: '300P + 30P 보너스',
      price: 3000,
      points: 330,
      basePoints: 300,
      bonusPoints: 30,
      isSubscription: false,
    ),
    points600: ProductInfo(
      id: points600,
      title: '700 포인트',
      description: '600P + 100P 보너스',
      price: 5500,
      points: 700,
      basePoints: 600,
      bonusPoints: 100,
      isSubscription: false,
    ),
    points1200: ProductInfo(
      id: points1200,
      title: '1,500 포인트',
      description: '1,200P + 300P 보너스',
      price: 9900,
      points: 1500,
      basePoints: 1200,
      bonusPoints: 300,
      isSubscription: false,
    ),
    points3000: ProductInfo(
      id: points3000,
      title: '4,000 포인트',
      description: '3,000P + 1,000P 보너스',
      price: 22000,
      points: 4000,
      basePoints: 3000,
      bonusPoints: 1000,
      isSubscription: false,
    ),
    monthlySubscription: ProductInfo(
      id: monthlySubscription,
      title: '월간 구독',
      description: '매월 50개 토큰 자동 충전',
      price: 1500,
      points: 50, // 월간 토큰
      isSubscription: true,
      subscriptionPeriod: 'monthly',
    ),
    yearlySubscription: ProductInfo(
      id: yearlySubscription,
      title: '연간 구독',
      description: '매월 50개 토큰 (17% 할인)',
      price: 15000,
      points: 600, // 연간 토큰 (50 x 12)
      isSubscription: true,
      subscriptionPeriod: 'yearly',
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
    monthlySubscription,
    yearlySubscription,
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
  final int points; // 총 포인트 (보너스 포함)
  final int? basePoints; // 기본 포인트
  final int? bonusPoints; // 보너스 포인트
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
      return '매일 ${dailyPointLimit}P 충전';
    }
    if (bonusPoints != null && bonusPoints! > 0) {
      return '$basePoints P + $bonusPoints P 보너스';
    }
    return '$points P 충전';
  }

  /// 포인트당 가격 (원)
  double get pricePerPoint {
    if (points <= 0) return 0;
    return price / points;
  }

  /// 월간 기준 가격 (연간 구독 시 할인율 계산용)
  int get monthlyEquivalentPrice {
    if (subscriptionPeriod == 'yearly') {
      return (price / 12).round();
    }
    return price;
  }

  /// 할인율 계산 (연간 구독 기준)
  int get discountPercent {
    if (subscriptionPeriod == 'yearly') {
      // 월간 가격 * 12 대비 할인율
      const monthlyPrice = 4900;
      final yearlyEquivalent = monthlyPrice * 12; // 58,800원
      return (((yearlyEquivalent - price) / yearlyEquivalent) * 100).round();
    }
    return 0;
  }
}
