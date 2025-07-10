import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import '../../core/utils/logger.dart';
import '../../core/network/api_client.dart';
import '../token_service.dart';

// 상품 ID 정의
class ProductIds {
  // 소모성 상품 (토큰 패키지)
  static const String tokens10 = 'com.fortune.tokens.10';
  static const String tokens50 = 'com.fortune.tokens.50';
  static const String tokens100 = 'com.fortune.tokens.100';
  static const String tokens200 = 'com.fortune.tokens.200';
  
  // 구독 상품
  static const String monthlySubscription = 'com.fortune.subscription.monthly';
  static const String yearlySubscription = 'com.fortune.subscription.yearly';
  
  // 모든 상품 ID 리스트
  static const List<String> allProductIds = [
    tokens10,
    tokens50,
    tokens100,
    tokens200,
    monthlySubscription,
    yearlySubscription,
  ];
  
  // 토큰 수량 매핑
  static const Map<String, int> tokenAmounts = {
    tokens10: 10,
    tokens50: 50,
    tokens100: 100,
    tokens200: 200,
  };
}

class InAppPurchaseService {
  static final InAppPurchaseService _instance = InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final ApiClient _apiClient = ApiClient();
  final TokenService _tokenService = TokenService();
  
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  
  // 초기화
  Future<void> initialize() async {
    try {
      // 인앱 결제 가능 여부 확인
      _isAvailable = await _inAppPurchase.isAvailable();
      if (!_isAvailable) {
        Logger.error('인앱 결제를 사용할 수 없습니다.');
        return;
      }
      
      // 구매 업데이트 리스너 설정
      final Stream<List<PurchaseDetails>> purchaseUpdated = 
          _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _onPurchaseUpdate,
        onDone: _onPurchaseDone,
        onError: _onPurchaseError,
      );
      
      // 상품 정보 로드
      await loadProducts();
      
      // iOS에서 미완료 거래 처리
      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosPlatformAddition.setDelegate(InAppPurchaseStoreKitDelegate());
      }
      
      Logger.info('인앱 결제 서비스 초기화 완료');
    } catch (e) {
      Logger.error('인앱 결제 초기화 실패', error: e);
    }
  }
  
  // 상품 정보 로드
  Future<void> loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(
        ProductIds.allProductIds.toSet(),
      );
      
      if (response.error != null) {
        Logger.error('상품 정보 로드 오류: ${response.error}');
        return;
      }
      
      _products = response.productDetails;
      Logger.info('${_products.length}개의 상품 로드 완료');
      
      // 상품 정보 로그
      for (final product in _products) {
        Logger.info('상품: ${product.id} - ${product.title} (${product.price})');
      }
    } catch (e) {
      Logger.error('상품 정보 로드 실패', error: e);
    }
  }
  
  // 구매 처리
  Future<bool> purchaseProduct(String productId) async {
    if (!_isAvailable) {
      throw Exception('인앱 결제를 사용할 수 없습니다.');
    }
    
    if (_purchasePending) {
      throw Exception('이미 구매가 진행 중입니다.');
    }
    
    // 상품 찾기
    final ProductDetails? productDetails = _products.firstWhere(
      (product) => product.id == productId,
      orElse: () => throw Exception('상품을 찾을 수 없습니다: $productId'),
    );
    
    if (productDetails == null) {
      throw Exception('상품 정보를 찾을 수 없습니다.');
    }
    
    // 구매 파라미터 설정
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );
    
    try {
      _purchasePending = true;
      
      // 소모성 상품인지 구독 상품인지 확인
      if (_isConsumable(productId)) {
        return await _inAppPurchase.buyConsumable(
          purchaseParam: purchaseParam,
        );
      } else {
        return await _inAppPurchase.buyNonConsumable(
          purchaseParam: purchaseParam,
        );
      }
    } catch (e) {
      _purchasePending = false;
      Logger.error('구매 시작 실패', error: e);
      throw Exception('구매를 시작할 수 없습니다.');
    }
  }
  
  // 구매 업데이트 처리
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchaseUpdate(purchaseDetails);
    }
  }
  
  // 개별 구매 처리
  Future<void> _handlePurchaseUpdate(PurchaseDetails purchaseDetails) async {
    Logger.info('구매 상태 업데이트: ${purchaseDetails.status}');
    
    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        _showPendingUI();
        break;
        
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _deliverProduct(purchaseDetails);
        break;
        
      case PurchaseStatus.error:
        _handleError(purchaseDetails.error!);
        break;
        
      case PurchaseStatus.canceled:
        Logger.info('구매가 취소되었습니다.');
        _purchasePending = false;
        break;
    }
    
    // 구매 완료 처리
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }
  
  // 상품 전달
  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    try {
      // 서버에 구매 검증 요청
      final isValid = await _verifyPurchase(purchaseDetails);
      
      if (!isValid) {
        Logger.error('구매 검증 실패');
        _purchasePending = false;
        return;
      }
      
      // 토큰 상품인 경우 토큰 추가
      final tokenAmount = ProductIds.tokenAmounts[purchaseDetails.productID];
      if (tokenAmount != null) {
        await _tokenService.addTokens(tokenAmount);
        Logger.info('$tokenAmount 토큰이 추가되었습니다.');
      }
      
      // 구독 상품인 경우 구독 활성화
      if (_isSubscription(purchaseDetails.productID)) {
        await _activateSubscription(purchaseDetails);
      }
      
      _purchasePending = false;
      
      // 성공 알림
      _showSuccessNotification(purchaseDetails.productID);
      
    } catch (e) {
      Logger.error('상품 전달 실패', error: e);
      _purchasePending = false;
    }
  }
  
  // 구매 검증
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      final Map<String, dynamic> verificationData = {};
      
      if (Platform.isAndroid) {
        // Android 영수증 데이터
        final InAppPurchaseAndroidPlatformAddition androidAddition =
            _inAppPurchase.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        verificationData['platform'] = 'android';
        verificationData['purchaseToken'] = purchaseDetails.verificationData.serverVerificationData;
        verificationData['productId'] = purchaseDetails.productID;
        verificationData['orderId'] = purchaseDetails.purchaseID;
      } else if (Platform.isIOS) {
        // iOS 영수증 데이터
        verificationData['platform'] = 'ios';
        verificationData['receipt'] = purchaseDetails.verificationData.serverVerificationData;
        verificationData['productId'] = purchaseDetails.productID;
        verificationData['transactionId'] = purchaseDetails.purchaseID;
      }
      
      // 서버에 검증 요청
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/payment/verify-purchase',
        data: verificationData,
      );
      
      return response['valid'] ?? false;
      
    } catch (e) {
      Logger.error('구매 검증 오류', error: e);
      return false;
    }
  }
  
  // 구독 활성화
  Future<void> _activateSubscription(PurchaseDetails purchaseDetails) async {
    try {
      await _apiClient.post(
        '/subscription/activate',
        data: {
          'productId': purchaseDetails.productID,
          'purchaseId': purchaseDetails.purchaseID,
          'platform': Platform.isIOS ? 'ios' : 'android',
        },
      );
      
      Logger.info('구독이 활성화되었습니다: ${purchaseDetails.productID}');
    } catch (e) {
      Logger.error('구독 활성화 실패', error: e);
    }
  }
  
  // 구매 복원
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      Logger.info('구매 복원 시작');
    } catch (e) {
      Logger.error('구매 복원 실패', error: e);
      throw Exception('구매 복원에 실패했습니다.');
    }
  }
  
  // 구독 상태 확인
  Future<bool> isSubscriptionActive() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/subscription/status',
      );
      
      return response['active'] ?? false;
    } catch (e) {
      Logger.error('구독 상태 확인 실패', error: e);
      return false;
    }
  }
  
  // 상품 목록 가져오기
  List<ProductDetails> getProducts() {
    return _products;
  }
  
  // 특정 상품 가져오기
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }
  
  // 소모성 상품인지 확인
  bool _isConsumable(String productId) {
    return ProductIds.tokenAmounts.containsKey(productId);
  }
  
  // 구독 상품인지 확인
  bool _isSubscription(String productId) {
    return productId == ProductIds.monthlySubscription || 
           productId == ProductIds.yearlySubscription;
  }
  
  // UI 알림 메서드들
  void _showPendingUI() {
    // TODO: 구매 진행 중 UI 표시
    Logger.info('구매가 진행 중입니다...');
  }
  
  void _handleError(IAPError error) {
    Logger.error('구매 오류: ${error.code} - ${error.message}');
    _purchasePending = false;
    // TODO: 에러 UI 표시
  }
  
  void _showSuccessNotification(String productId) {
    // TODO: 구매 성공 알림 표시
    Logger.info('구매 완료: $productId');
  }
  
  void _onPurchaseDone() {
    _subscription?.cancel();
  }
  
  void _onPurchaseError(dynamic error) {
    Logger.error('구매 스트림 오류', error: error);
  }
  
  // 리소스 정리
  void dispose() {
    _subscription?.cancel();
  }
}

// iOS StoreKit 델리게이트
class InAppPurchaseStoreKitDelegate extends SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }
  
  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}