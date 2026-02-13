// Mock InAppPurchase Service for Integration Tests
// IAP Mock 서비스 - 실제 결제 없이 구매 플로우 테스트
//
// 사용법:
// ```dart
// final mockIAP = MockInAppPurchaseService();
// mockIAP.setNextPurchaseResult(MockPurchaseResult.success);
// await mockIAP.purchaseProduct('soul_100');
// ```

import 'dart:async';

/// Mock 구매 결과 타입
enum MockPurchaseResult {
  /// 구매 성공
  success,

  /// 사용자 취소
  cancelled,

  /// 네트워크 에러
  networkError,

  /// 결제 실패
  paymentFailed,

  /// 상품 없음
  productNotFound,

  /// 이미 구매됨 (구독)
  alreadyPurchased,

  /// 대기 중 (결제 승인 대기)
  pending,
}

/// Mock 상품 정보
class MockProductDetails {
  final String id;
  final String title;
  final String description;
  final String price;
  final double rawPrice;
  final String currencyCode;
  final bool isSubscription;
  final int? tokens;

  const MockProductDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rawPrice,
    this.currencyCode = 'KRW',
    this.isSubscription = false,
    this.tokens,
  });
}

/// Mock 구매 상세 정보
class MockPurchaseDetails {
  final String productId;
  final String purchaseId;
  final MockPurchaseResult status;
  final DateTime purchaseDate;
  final String? errorCode;
  final String? errorMessage;

  MockPurchaseDetails({
    required this.productId,
    required this.status,
    String? purchaseId,
    DateTime? purchaseDate,
    this.errorCode,
    this.errorMessage,
  })  : purchaseId = purchaseId ??
            'mock-purchase-${DateTime.now().millisecondsSinceEpoch}',
        purchaseDate = purchaseDate ?? DateTime.now();
}

/// Mock InAppPurchase Service
class MockInAppPurchaseService {
  // Singleton
  static final MockInAppPurchaseService _instance =
      MockInAppPurchaseService._internal();
  factory MockInAppPurchaseService() => _instance;
  MockInAppPurchaseService._internal();

  // 상태
  bool _isAvailable = true;
  bool _purchasePending = false;
  MockPurchaseResult _nextResult = MockPurchaseResult.success;
  Duration _simulatedDelay = const Duration(milliseconds: 500);

  // Mock 상품 목록
  final List<MockProductDetails> _products = [
    // 토큰 상품
    const MockProductDetails(
      id: 'soul_10',
      title: '소울 10개',
      description: '운세 10회 이용 가능',
      price: '₩1,100',
      rawPrice: 1100,
      tokens: 10,
    ),
    const MockProductDetails(
      id: 'soul_50',
      title: '소울 50개',
      description: '운세 50회 이용 가능',
      price: '₩4,900',
      rawPrice: 4900,
      tokens: 50,
    ),
    const MockProductDetails(
      id: 'soul_100',
      title: '소울 100개',
      description: '운세 100회 이용 가능',
      price: '₩8,900',
      rawPrice: 8900,
      tokens: 100,
    ),
    const MockProductDetails(
      id: 'soul_500',
      title: '소울 500개',
      description: '운세 500회 이용 가능',
      price: '₩39,000',
      rawPrice: 39000,
      tokens: 500,
    ),
    // 구독 상품
    const MockProductDetails(
      id: 'premium_monthly',
      title: '프리미엄 월간',
      description: '모든 운세 무제한 이용',
      price: '₩9,900/월',
      rawPrice: 9900,
      isSubscription: true,
    ),
    const MockProductDetails(
      id: 'premium_yearly',
      title: '프리미엄 연간',
      description: '모든 운세 무제한 이용 (연간)',
      price: '₩79,000/년',
      rawPrice: 79000,
      isSubscription: true,
    ),
  ];

  // 구매 기록
  final List<MockPurchaseDetails> _purchaseHistory = [];

  // 구독 상태
  bool _isSubscriptionActive = false;
  DateTime? _subscriptionExpiryDate;

  // 토큰 잔액
  int _tokenBalance = 0;

  // 콜백
  void Function()? onPurchaseStarted;
  void Function(MockPurchaseDetails)? onPurchaseSuccess;
  void Function(MockPurchaseDetails)? onPurchaseError;

  // Getters
  bool get isAvailable => _isAvailable;
  bool get purchasePending => _purchasePending;
  List<MockProductDetails> get products => _products;
  List<MockPurchaseDetails> get purchaseHistory => _purchaseHistory;
  bool get isSubscriptionActive => _isSubscriptionActive;
  DateTime? get subscriptionExpiryDate => _subscriptionExpiryDate;
  int get tokenBalance => _tokenBalance;

  // 테스트 설정 메서드

  /// 다음 구매 결과 설정
  void setNextPurchaseResult(MockPurchaseResult result) {
    _nextResult = result;
  }

  /// 구매 시뮬레이션 딜레이 설정
  void setSimulatedDelay(Duration delay) {
    _simulatedDelay = delay;
  }

  /// IAP 사용 가능 여부 설정
  void setAvailable(bool available) {
    _isAvailable = available;
  }

  /// 구독 상태 설정
  void setSubscriptionStatus(bool active, {DateTime? expiryDate}) {
    _isSubscriptionActive = active;
    _subscriptionExpiryDate = expiryDate;
  }

  /// 토큰 잔액 설정
  void setTokenBalance(int balance) {
    _tokenBalance = balance;
  }

  /// 토큰 추가
  void addTokens(int amount) {
    _tokenBalance += amount;
  }

  /// 토큰 차감
  bool deductTokens(int amount) {
    if (_tokenBalance >= amount) {
      _tokenBalance -= amount;
      return true;
    }
    return false;
  }

  /// 모든 상태 초기화
  void reset() {
    _isAvailable = true;
    _purchasePending = false;
    _nextResult = MockPurchaseResult.success;
    _simulatedDelay = const Duration(milliseconds: 500);
    _purchaseHistory.clear();
    _isSubscriptionActive = false;
    _subscriptionExpiryDate = null;
    _tokenBalance = 0;
  }

  // IAP 메서드

  /// 초기화 (Mock)
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock 초기화 완료
  }

  /// 상품 정보 로드 (Mock)
  Future<void> loadProducts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock 상품은 이미 로드됨
  }

  /// 구매 처리 (Mock)
  Future<MockPurchaseDetails> purchaseProduct(String productId) async {
    if (!_isAvailable) {
      return MockPurchaseDetails(
        productId: productId,
        status: MockPurchaseResult.networkError,
        errorCode: 'E_NOT_AVAILABLE',
        errorMessage: '인앱 결제를 사용할 수 없습니다.',
      );
    }

    if (_purchasePending) {
      return MockPurchaseDetails(
        productId: productId,
        status: MockPurchaseResult.pending,
        errorCode: 'E_PENDING',
        errorMessage: '이미 구매가 진행 중입니다.',
      );
    }

    // 상품 찾기
    final product = _products.where((p) => p.id == productId).firstOrNull;
    if (product == null) {
      return MockPurchaseDetails(
        productId: productId,
        status: MockPurchaseResult.productNotFound,
        errorCode: 'E_PRODUCT_NOT_FOUND',
        errorMessage: '상품을 찾을 수 없습니다.',
      );
    }

    _purchasePending = true;
    onPurchaseStarted?.call();

    // 시뮬레이션 딜레이
    await Future.delayed(_simulatedDelay);

    _purchasePending = false;

    // 결과 생성
    final result = MockPurchaseDetails(
      productId: productId,
      status: _nextResult,
      errorCode: _getErrorCode(_nextResult),
      errorMessage: _getErrorMessage(_nextResult),
    );

    // 성공 처리
    if (_nextResult == MockPurchaseResult.success) {
      _purchaseHistory.add(result);

      // 토큰 상품이면 토큰 추가
      if (product.tokens != null) {
        _tokenBalance += product.tokens!;
      }

      // 구독 상품이면 구독 활성화
      if (product.isSubscription) {
        _isSubscriptionActive = true;
        _subscriptionExpiryDate = DateTime.now().add(
          product.id.contains('yearly')
              ? const Duration(days: 365)
              : const Duration(days: 30),
        );
      }

      onPurchaseSuccess?.call(result);
    } else {
      onPurchaseError?.call(result);
    }

    // 다음 구매는 기본값으로 리셋
    _nextResult = MockPurchaseResult.success;

    return result;
  }

  /// 구매 복원 (Mock)
  Future<List<MockPurchaseDetails>> restorePurchases() async {
    await Future.delayed(_simulatedDelay);

    // 구독 구매만 복원
    final restoredPurchases = _purchaseHistory
        .where((p) => p.status == MockPurchaseResult.success)
        .where((p) {
      final product =
          _products.where((prod) => prod.id == p.productId).firstOrNull;
      return product?.isSubscription ?? false;
    }).toList();

    // 구독 상태 복원
    if (restoredPurchases.isNotEmpty) {
      _isSubscriptionActive = true;
    }

    return restoredPurchases;
  }

  /// 구독 상태 확인 (Mock)
  Future<bool> checkSubscriptionStatus() async {
    await Future.delayed(const Duration(milliseconds: 100));

    // 만료 확인
    if (_subscriptionExpiryDate != null &&
        DateTime.now().isAfter(_subscriptionExpiryDate!)) {
      _isSubscriptionActive = false;
    }

    return _isSubscriptionActive;
  }

  /// 상품 정보 가져오기
  MockProductDetails? getProduct(String productId) {
    return _products.where((p) => p.id == productId).firstOrNull;
  }

  /// 토큰 상품 목록
  List<MockProductDetails> get tokenProducts =>
      _products.where((p) => !p.isSubscription).toList();

  /// 구독 상품 목록
  List<MockProductDetails> get subscriptionProducts =>
      _products.where((p) => p.isSubscription).toList();

  // Helper methods
  String? _getErrorCode(MockPurchaseResult result) {
    switch (result) {
      case MockPurchaseResult.success:
        return null;
      case MockPurchaseResult.cancelled:
        return 'E_USER_CANCELLED';
      case MockPurchaseResult.networkError:
        return 'E_NETWORK_ERROR';
      case MockPurchaseResult.paymentFailed:
        return 'E_PAYMENT_FAILED';
      case MockPurchaseResult.productNotFound:
        return 'E_PRODUCT_NOT_FOUND';
      case MockPurchaseResult.alreadyPurchased:
        return 'E_ALREADY_PURCHASED';
      case MockPurchaseResult.pending:
        return 'E_PENDING';
    }
  }

  String? _getErrorMessage(MockPurchaseResult result) {
    switch (result) {
      case MockPurchaseResult.success:
        return null;
      case MockPurchaseResult.cancelled:
        return '구매가 취소되었습니다.';
      case MockPurchaseResult.networkError:
        return '네트워크 오류가 발생했습니다.';
      case MockPurchaseResult.paymentFailed:
        return '결제에 실패했습니다.';
      case MockPurchaseResult.productNotFound:
        return '상품을 찾을 수 없습니다.';
      case MockPurchaseResult.alreadyPurchased:
        return '이미 구매한 상품입니다.';
      case MockPurchaseResult.pending:
        return '결제 승인 대기 중입니다.';
    }
  }
}
