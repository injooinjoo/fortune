import 'package:equatable/equatable.dart';

// 토큰 잔액 엔티티
class TokenBalance extends Equatable {
  final String userId;
  final int totalTokens;
  final int usedTokens;
  final int remainingTokens;
  final DateTime lastUpdated;
  final bool hasUnlimitedAccess;

  const TokenBalance({
    required this.userId,
    required this.totalTokens,
    required this.usedTokens,
    required this.remainingTokens,
    required this.lastUpdated,
    this.hasUnlimitedAccess = false,
  });

  @override
  List<Object?> get props => [
    userId, totalTokens, usedTokens, remainingTokens, lastUpdated, hasUnlimitedAccess
  ];

  bool get hasEnoughTokens => remainingTokens > 0 || hasUnlimitedAccess;
  
  // Add getter for balance (alias for remainingTokens)
  int get balance => remainingTokens;
  
  // Add getter for canUseFree
  bool get canUseFree => hasUnlimitedAccess;

  TokenBalance copyWith({
    String? userId,
    int? totalTokens,
    int? usedTokens,
    int? remainingTokens,
    DateTime? lastUpdated,
    bool? hasUnlimitedAccess,
  }) {
    return TokenBalance(
      userId: userId ?? this.userId,
      totalTokens: totalTokens ?? this.totalTokens,
      usedTokens: usedTokens ?? this.usedTokens,
      remainingTokens: remainingTokens ?? this.remainingTokens,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      hasUnlimitedAccess: hasUnlimitedAccess ?? this.hasUnlimitedAccess,
    );
  }
}

// 토큰 트랜잭션 엔티티
class TokenTransaction extends Equatable {
  final String id;
  final String userId;
  final int amount;
  final String type; // 'purchase', 'consumption', 'bonus', 'refund'
  final String? description;
  final String? referenceId; // fortune_id, payment_id 등
  final DateTime createdAt;
  final int? balanceAfter; // 트랜잭션 후 잔액

  const TokenTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    this.description,
    this.referenceId,
    required this.createdAt,
    this.balanceAfter,
  });

  @override
  List<Object?> get props => [
    id, userId, amount, type, description, referenceId, createdAt, balanceAfter
  ];
}

// 토큰 패키지 (구매 옵션)
class TokenPackage extends Equatable {
  final String id;
  final String name;
  final int tokens;
  final double price;
  final double? originalPrice; // 할인 전 가격
  final String currency;
  final String? badge; // 'BEST', 'HOT', 'SALE' 등
  final int? bonusTokens;
  final String? description;
  final bool isPopular;
  final bool isBestValue; // 베스트 밸류 표시

  const TokenPackage({
    required this.id,
    required this.name,
    required this.tokens,
    required this.price,
    this.originalPrice,
    required this.currency,
    this.badge,
    this.bonusTokens,
    this.description,
    this.isPopular = false,
    this.isBestValue = false,
  });

  double get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return ((originalPrice! - price) / originalPrice! * 100);
  }

  int get totalTokens => tokens + (bonusTokens ?? 0);

  @override
  List<Object?> get props => [
    id, name, tokens, price, originalPrice, currency, badge, 
    bonusTokens, description, isPopular, isBestValue
  ];
}

// 토큰 소비 정보
class TokenConsumption extends Equatable {
  final String fortuneType;
  final int requiredTokens;
  final String? description;

  const TokenConsumption({
    required this.fortuneType,
    required this.requiredTokens,
    this.description,
  });

  @override
  List<Object?> get props => [fortuneType, requiredTokens, description];
}

// 무제한 구독 정보
class UnlimitedSubscription extends Equatable {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'active', 'expired', 'cancelled'
  final String plan; // 'monthly', 'yearly'
  final double price;
  final String currency;

  const UnlimitedSubscription({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.plan,
    required this.price,
    required this.currency,
  });

  bool get isActive => status == 'active' && endDate.isAfter(DateTime.now());

  int get remainingDays => isActive ? endDate.difference(DateTime.now()).inDays : 0;

  @override
  List<Object?> get props => [
    id, userId, startDate, endDate, status, plan, price, currency
  ];
}