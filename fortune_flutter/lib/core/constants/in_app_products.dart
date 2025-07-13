/// In-App Purchase Product IDs
class InAppProducts {
  // Consumable Products (Token Packages)
  static const String tokens10 = 'com.fortune.app.tokens10';
  static const String tokens50 = 'com.fortune.app.tokens50';
  static const String tokens100 = 'com.fortune.app.tokens100';
  static const String tokens200 = 'com.fortune.app.tokens200';
  
  // Subscription Products
  static const String monthlySubscription = 'com.fortune.app.subscription.monthly';
  static const String yearlySubscription = 'com.fortune.app.subscription.yearly';
  
  // Product Details
  static const Map<String, ProductInfo> productDetails = {
    tokens10: ProductInfo(
      id: tokens10,
      title: '토큰 10개',
      description: '기본 운세 10회 이용',
      price: 1000,
      tokens: 10,
      isSubscription: false,
    ),
    tokens50: ProductInfo(
      id: tokens50,
      title: '토큰 50개',
      description: '10% 보너스 토큰 포함',
      price: 4500,
      tokens: 50,
      isSubscription: false,
    ),
    tokens100: ProductInfo(
      id: tokens100,
      title: '토큰 100개',
      description: '20% 보너스 토큰 포함',
      price: 8000,
      tokens: 100,
      isSubscription: false,
    ),
    tokens200: ProductInfo(
      id: tokens200,
      title: '토큰 200개',
      description: '30% 보너스 토큰 포함',
      price: 14000,
      tokens: 200,
      isSubscription: false,
    ),
    monthlySubscription: ProductInfo(
      id: monthlySubscription,
      title: '월간 무제한',
      description: '한 달 동안 무제한 이용',
      price: 9900,
      tokens: -1, // Unlimited
      isSubscription: true,
    ),
    yearlySubscription: ProductInfo(
      id: yearlySubscription,
      title: '연간 무제한',
      description: '1년 동안 무제한 이용 (17% 할인)',
      price: 99000,
      tokens: -1, // Unlimited
      isSubscription: true,
    ),
  };
  
  // Get all consumable product IDs
  static List<String> get consumableIds => [
    tokens10,
    tokens50,
    tokens100,
    tokens200,
  ];
  
  // Get all subscription product IDs
  static List<String> get subscriptionIds => [
    monthlySubscription,
    yearlySubscription,
  ];
  
  // Get all product IDs
  static List<String> get allProductIds => [
    ...consumableIds,
    ...subscriptionIds,
  ];
}

class ProductInfo {
  final String id;
  final String title;
  final String description;
  final int price; // in KRW
  final int tokens; // -1 for unlimited
  final bool isSubscription;
  
  const ProductInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.tokens,
    required this.isSubscription,
  });
}