/// In-App Purchase Product IDs
class InAppProducts {
  // Consumable Products (Token Packages)
  static const String tokens10 = 'com.beyond.fortune.tokens10';
  static const String tokens50 = 'com.beyond.fortune.tokens50';
  static const String tokens100 = 'com.beyond.fortune.tokens100';
  static const String tokens200 = 'com.beyond.fortune.tokens200';

  // Subscription Products (광고 제거 + 무제한 이용)
  static const String monthlySubscription =
      'com.beyond.fortune.subscription.monthly';
  static const String yearlySubscription =
      'com.beyond.fortune.subscription.yearly';

  // Product Details
  static const Map<String, ProductInfo> productDetails = {
    tokens10: ProductInfo(
      id: tokens10,
      title: '복주머니 10개',
      description: '기본 운세 10회 이용',
      price: 1000,
      tokens: 10,
      isSubscription: false),
    tokens50: ProductInfo(
      id: tokens50,
      title: '복주머니 50개',
      description: '10% 보너스 복주머니 포함',
      price: 4500,
      tokens: 50,
      isSubscription: false),
    tokens100: ProductInfo(
      id: tokens100,
      title: '복주머니 100개',
      description: '20% 보너스 복주머니 포함',
      price: 8000,
      tokens: 100,
      isSubscription: false),
    tokens200: ProductInfo(
      id: tokens200,
      title: '복주머니 200개',
      description: '30% 보너스 복주머니 포함',
      price: 14000,
      tokens: 200,
      isSubscription: false),
    monthlySubscription: ProductInfo(
      id: monthlySubscription,
      title: '프리미엄운세 월간',
      description: '광고 제거 + 모든 운세 무제한',
      price: 2200,
      tokens: -1, // Unlimited
      isSubscription: true,
      subscriptionPeriod: 'monthly'),
    yearlySubscription: ProductInfo(
      id: yearlySubscription,
      title: '프리미엄운세 연간',
      description: '광고 제거 + 모든 운세 무제한 (17% 할인)',
      price: 19000,
      tokens: -1, // Unlimited
      isSubscription: true,
      subscriptionPeriod: 'yearly')};

  // Get all consumable product IDs
  static List<String> get consumableIds => [
        tokens10,
        tokens50,
        tokens100,
        tokens200];

  // Get all subscription product IDs
  static List<String> get subscriptionIds => [
        monthlySubscription,
        yearlySubscription];

  // Get all product IDs
  static List<String> get allProductIds => [
        ...consumableIds,
        ...subscriptionIds];
}

class ProductInfo {
  final String id;
  final String title;
  final String description;
  final int price; // in KRW
  final int tokens; // -1 for unlimited
  final bool isSubscription;
  final String? subscriptionPeriod; // 'monthly' or 'yearly'

  const ProductInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.tokens,
    required this.isSubscription,
    this.subscriptionPeriod});

  /// 구독 여부에 따른 혜택 문구
  String get benefitText {
    if (isSubscription) {
      return '광고 제거 + 무제한 운세';
    }
    return '$tokens 복주머니 충전';
  }

  /// 월간 기준 가격 (연간 구독 시 할인율 계산용)
  int get monthlyEquivalentPrice {
    if (subscriptionPeriod == 'yearly') {
      return (price / 12).round();
    }
    return price;
  }
}
