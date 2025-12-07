/// Mock Payment Services - 결제 관련 Mock 클래스
/// Phase 4: 결제 & 프리미엄 테스트용

import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';

// ============================================
// Test Data Factory - Payment
// ============================================

class PaymentTestData {
  /// 토큰 잔액 데이터
  static Map<String, dynamic> createTokenBalance({
    String userId = 'test-user-id',
    int remainingTokens = 100,
    bool isUnlimited = false,
    DateTime? expiresAt,
  }) {
    return {
      'user_id': userId,
      'remaining_tokens': remainingTokens,
      'is_unlimited': isUnlimited,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// 토큰 패키지 데이터
  static Map<String, dynamic> createTokenPackage({
    String id = 'token_100',
    String name = '100 토큰',
    int tokens = 100,
    double price = 5000,
    String currency = 'KRW',
    bool isPopular = false,
    int? bonusTokens,
  }) {
    return {
      'id': id,
      'name': name,
      'tokens': tokens,
      'bonus_tokens': bonusTokens ?? 0,
      'total_tokens': tokens + (bonusTokens ?? 0),
      'price': price,
      'currency': currency,
      'price_string': '₩${price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
      'is_popular': isPopular,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// 구독 상품 데이터
  static Map<String, dynamic> createSubscriptionProduct({
    String id = 'premium_monthly',
    String name = '프리미엄 월간',
    String description = '모든 운세 무제한 이용',
    double price = 9900,
    String currency = 'KRW',
    String period = 'monthly',
    List<String>? features,
    bool isBestValue = false,
  }) {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'price_string': '₩${price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
      'period': period,
      'period_string': period == 'monthly' ? '월' : period == 'yearly' ? '년' : period,
      'features': features ?? [
        '모든 운세 무제한',
        '광고 제거',
        '프리미엄 콘텐츠',
        '우선 지원',
      ],
      'is_best_value': isBestValue,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// 구매 기록 데이터
  static Map<String, dynamic> createPurchaseRecord({
    String id = 'purchase-123',
    String userId = 'test-user-id',
    String productId = 'token_100',
    String productType = 'token', // token, subscription
    double amount = 5000,
    String currency = 'KRW',
    String status = 'completed', // pending, completed, failed, refunded
    String platform = 'ios', // ios, android
    String? transactionId,
    DateTime? purchasedAt,
  }) {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'product_type': productType,
      'amount': amount,
      'currency': currency,
      'status': status,
      'platform': platform,
      'transaction_id': transactionId ?? 'txn_${DateTime.now().millisecondsSinceEpoch}',
      'purchased_at': (purchasedAt ?? DateTime.now()).toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// 구독 상태 데이터
  static Map<String, dynamic> createSubscriptionStatus({
    String userId = 'test-user-id',
    bool isActive = true,
    String plan = 'premium_monthly',
    DateTime? startDate,
    DateTime? endDate,
    bool autoRenew = true,
    String status = 'active', // active, cancelled, expired, grace_period
  }) {
    final now = DateTime.now();
    return {
      'user_id': userId,
      'is_active': isActive,
      'plan': plan,
      'plan_name': plan == 'premium_monthly' ? '프리미엄 월간' : '프리미엄 연간',
      'start_date': (startDate ?? now.subtract(const Duration(days: 15))).toIso8601String(),
      'end_date': (endDate ?? now.add(const Duration(days: 15))).toIso8601String(),
      'auto_renew': autoRenew,
      'status': status,
      'days_remaining': endDate != null
          ? endDate.difference(now).inDays
          : 15,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// 프리미엄 혜택 목록
  static List<Map<String, dynamic>> getPremiumBenefits() {
    return [
      {
        'icon': 'infinity',
        'title': '무제한 운세',
        'description': '모든 운세를 제한 없이 이용하세요',
      },
      {
        'icon': 'no_ads',
        'title': '광고 제거',
        'description': '광고 없이 깔끔하게 이용하세요',
      },
      {
        'icon': 'star',
        'title': '프리미엄 콘텐츠',
        'description': '심화 분석과 상세 해석을 받아보세요',
      },
      {
        'icon': 'support',
        'title': '우선 지원',
        'description': '문의 시 우선적으로 답변드립니다',
      },
      {
        'icon': 'early_access',
        'title': '신규 기능 먼저',
        'description': '새로운 기능을 먼저 체험하세요',
      },
    ];
  }

  /// 토큰 패키지 목록
  static List<Map<String, dynamic>> getTokenPackages() {
    return [
      createTokenPackage(
        id: 'token_50',
        name: '50 토큰',
        tokens: 50,
        price: 3000,
      ),
      createTokenPackage(
        id: 'token_100',
        name: '100 토큰',
        tokens: 100,
        price: 5000,
        isPopular: true,
      ),
      createTokenPackage(
        id: 'token_300',
        name: '300 토큰',
        tokens: 300,
        price: 12000,
        bonusTokens: 30,
      ),
      createTokenPackage(
        id: 'token_500',
        name: '500 토큰',
        tokens: 500,
        price: 18000,
        bonusTokens: 100,
      ),
    ];
  }

  /// 구독 상품 목록
  static List<Map<String, dynamic>> getSubscriptionProducts() {
    return [
      createSubscriptionProduct(
        id: 'premium_monthly',
        name: '프리미엄 월간',
        price: 9900,
        period: 'monthly',
      ),
      createSubscriptionProduct(
        id: 'premium_yearly',
        name: '프리미엄 연간',
        price: 79000,
        period: 'yearly',
        isBestValue: true,
        features: [
          '모든 운세 무제한',
          '광고 제거',
          '프리미엄 콘텐츠',
          '우선 지원',
          '33% 할인 적용',
        ],
      ),
    ];
  }

  /// 결제 에러 데이터
  static Map<String, dynamic> createPaymentError({
    String code = 'payment_failed',
    String message = '결제 처리 중 오류가 발생했습니다',
    String? details,
  }) {
    return {
      'error': true,
      'code': code,
      'message': message,
      'details': details,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// 결제 검증 결과 데이터
  static Map<String, dynamic> createVerificationResult({
    bool isValid = true,
    String productId = 'token_100',
    String transactionId = 'txn_123',
    DateTime? purchaseDate,
    String? errorMessage,
  }) {
    return {
      'is_valid': isValid,
      'product_id': productId,
      'transaction_id': transactionId,
      'purchase_date': (purchaseDate ?? DateTime.now()).toIso8601String(),
      'error_message': errorMessage,
      'verified_at': DateTime.now().toIso8601String(),
    };
  }

  /// 토큰 사용 기록
  static Map<String, dynamic> createTokenUsage({
    String userId = 'test-user-id',
    int tokensUsed = 10,
    String fortuneType = 'daily',
    DateTime? usedAt,
  }) {
    return {
      'user_id': userId,
      'tokens_used': tokensUsed,
      'fortune_type': fortuneType,
      'fortune_name': _getFortuneTypeName(fortuneType),
      'used_at': (usedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// 토큰 사용 내역 목록
  static List<Map<String, dynamic>> getTokenUsageHistory({
    String userId = 'test-user-id',
    int count = 10,
  }) {
    final fortuneTypes = ['daily', 'love', 'career', 'tarot', 'dream', 'compatibility'];
    return List.generate(count, (i) {
      return createTokenUsage(
        userId: userId,
        tokensUsed: (i % 3 + 1) * 10,
        fortuneType: fortuneTypes[i % fortuneTypes.length],
        usedAt: DateTime.now().subtract(Duration(days: i)),
      );
    });
  }

  // Helper methods
  static String _getFortuneTypeName(String type) {
    const names = {
      'daily': '오늘의 운세',
      'love': '연애운',
      'career': '직업 코칭',
      'tarot': '타로',
      'dream': '꿈 해몽',
      'compatibility': '궁합',
      'face': '관상',
      'mbti': 'MBTI 운세',
      'biorhythm': '바이오리듬',
      'investment': '투자운',
      'celebrity': '유명인 운세',
    };
    return names[type] ?? type;
  }
}

// ============================================
// Mock Classes
// ============================================

/// Mock In-App Purchase Service
class MockInAppPurchaseService extends Mock {
  Future<List<Map<String, dynamic>>> getProducts() async {
    return PaymentTestData.getTokenPackages();
  }

  Future<List<Map<String, dynamic>>> getSubscriptions() async {
    return PaymentTestData.getSubscriptionProducts();
  }

  Future<Map<String, dynamic>> purchaseProduct(String productId) async {
    return PaymentTestData.createPurchaseRecord(productId: productId);
  }

  Future<Map<String, dynamic>> verifyPurchase(String transactionId) async {
    return PaymentTestData.createVerificationResult(transactionId: transactionId);
  }

  Future<bool> restorePurchases() async {
    return true;
  }
}

/// Mock Token Service
class MockTokenService extends Mock {
  Future<Map<String, dynamic>> getBalance(String userId) async {
    return PaymentTestData.createTokenBalance(userId: userId);
  }

  Future<bool> deductTokens(String userId, int amount) async {
    return true;
  }

  Future<Map<String, dynamic>> addTokens(String userId, int amount) async {
    return PaymentTestData.createTokenBalance(
      userId: userId,
      remainingTokens: 100 + amount,
    );
  }

  Future<List<Map<String, dynamic>>> getUsageHistory(String userId) async {
    return PaymentTestData.getTokenUsageHistory(userId: userId);
  }
}

/// Mock Subscription Service
class MockSubscriptionService extends Mock {
  Future<Map<String, dynamic>> getStatus(String userId) async {
    return PaymentTestData.createSubscriptionStatus(userId: userId);
  }

  Future<bool> cancelSubscription(String userId) async {
    return true;
  }

  Future<Map<String, dynamic>> subscribe(String userId, String planId) async {
    return PaymentTestData.createSubscriptionStatus(
      userId: userId,
      plan: planId,
    );
  }
}

// ============================================
// Fallback Value Registration
// ============================================

void registerPaymentFallbackValues() {
  registerFallbackValue(DateTime.now());
  registerFallbackValue(<String, dynamic>{});
  registerFallbackValue(const Duration(seconds: 1));
}
