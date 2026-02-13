import 'dart:async';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import '../core/utils/logger.dart';
import '../core/network/api_client.dart';
import '../core/constants/in_app_products.dart';
import '../shared/components/toast.dart';

class InAppPurchaseService {
  static final InAppPurchaseService _instance =
      InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final ApiClient _apiClient = ApiClient();
  // final TokenService _tokenService = TokenService();

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;

  // 중복 구매 처리 방지를 위한 처리된 구매 ID 추적
  final Set<String> _processedPurchaseIds = {};

  // 복원 관련 상태
  bool _isRestoring = false;
  int _restoredCount = 0;
  Timer? _restoreTimeoutTimer;

  // Compatibility getters
  bool get isAvailable => _isAvailable;
  bool get purchasePending => _purchasePending;
  List<ProductDetails> get products => _products;

  // UI callbacks
  BuildContext? _context;
  void Function()? onPurchaseStarted;
  void Function(String message)? onPurchaseSuccess;

  /// 결제 완료 시 상품 정보와 함께 호출되는 콜백
  /// productId: 상품 ID, productName: 상품명, tokenAmount: 토큰 수량
  void Function(String productId, String productName, int tokenAmount)?
      onPurchaseCompleted;

  /// 구독 활성화 완료 시 호출되는 콜백
  void Function(String productId, bool isSubscription)? onSubscriptionActivated;
  void Function(String error)? onPurchaseError;
  void Function()? onPurchaseCanceled;

  /// 구매 복원 완료 시 호출되는 콜백
  /// [hasRestoredItems]: 복원된 항목이 있는지 여부
  /// [restoredCount]: 복원된 항목 수
  void Function(bool hasRestoredItems, int restoredCount)? onRestoreCompleted;

  // Set context for UI notifications
  void setContext(BuildContext context) {
    _context = context;
  }

  // Set UI callbacks
  void setCallbacks({
    void Function()? onPurchaseStarted,
    void Function(String message)? onPurchaseSuccess,
    void Function(String productId, String productName, int tokenAmount)?
        onPurchaseCompleted,
    void Function(String productId, bool isSubscription)?
        onSubscriptionActivated,
    void Function(String error)? onPurchaseError,
    void Function()? onPurchaseCanceled,
    void Function(bool hasRestoredItems, int restoredCount)? onRestoreCompleted,
  }) {
    this.onPurchaseStarted = onPurchaseStarted;
    this.onPurchaseSuccess = onPurchaseSuccess;
    this.onPurchaseCompleted = onPurchaseCompleted;
    this.onSubscriptionActivated = onSubscriptionActivated;
    this.onPurchaseError = onPurchaseError;
    this.onPurchaseCanceled = onPurchaseCanceled;
    this.onRestoreCompleted = onRestoreCompleted;
  }

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
      if (!kIsWeb && Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _inAppPurchase
                .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosPlatformAddition.setDelegate(InAppPurchaseStoreKitDelegate());
      }

      Logger.info('인앱 결제 서비스 초기화 완료');
    } catch (e) {
      Logger.error('인앱 결제 초기화 실패', e);
    }
  }

  // 상품 정보 로드
  Future<void> loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(InAppProducts.allProductIds.toSet());

      if (response.error != null) {
        Logger.error('오류: ${response.error}');
        return;
      }

      _products = response.productDetails;
      Logger.info('${_products.length}개의 상품 로드 완료');

      // 상품 정보 상세 로그
      for (final product in _products) {
        Logger.info('========== 스토어 상품 정보 ==========');
        Logger.info('id: ${product.id}');
        Logger.info('title: ${product.title}');
        Logger.info('description: ${product.description}');
        Logger.info('price: ${product.price}');
        Logger.info('rawPrice: ${product.rawPrice}');
        Logger.info('======================================');
      }
    } catch (e) {
      Logger.error('상품 정보 로드 실패', e);
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
    ProductDetails? productDetails;
    try {
      productDetails =
          _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      throw Exception('상품을 찾을 수 없습니다: $productId');
    }

    // 구매 파라미터 설정
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);

    try {
      _purchasePending = true;

      // 소모성 상품인지 구독 상품인지 확인
      if (_isConsumable(productId)) {
        return await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      } else {
        return await _inAppPurchase.buyNonConsumable(
            purchaseParam: purchaseParam);
      }
    } catch (e) {
      _purchasePending = false;
      Logger.error('구매 시작 실패', e);
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
    final purchaseId = purchaseDetails.purchaseID;
    Logger.info('========== 🛒 구매 업데이트 수신 ==========');
    Logger.info('status: ${purchaseDetails.status}');
    Logger.info('purchaseID: $purchaseId');
    Logger.info('productID: ${purchaseDetails.productID}');
    Logger.info(
        'pendingCompletePurchase: ${purchaseDetails.pendingCompletePurchase}');
    Logger.info(
        'verificationData.source: ${purchaseDetails.verificationData.source}');
    Logger.info(
        'verificationData.localVerificationData 길이: ${purchaseDetails.verificationData.localVerificationData.length}');
    Logger.info(
        'verificationData.serverVerificationData 길이: ${purchaseDetails.verificationData.serverVerificationData.length}');
    Logger.info('============================================');

    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        _showPendingUI();
        break;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        // 중복 처리 방지: 이미 처리된 구매 ID는 스킵
        if (purchaseId != null && _processedPurchaseIds.contains(purchaseId)) {
          Logger.info('이미 처리된 구매입니다. 스킵: $purchaseId');
        } else {
          if (purchaseId != null) {
            _processedPurchaseIds.add(purchaseId);
          }
          // 복원 시 카운트 증가
          if (purchaseDetails.status == PurchaseStatus.restored &&
              _isRestoring) {
            _restoredCount++;
            Logger.info('복원된 구매 카운트: $_restoredCount');
          }
          await _deliverProduct(purchaseDetails);
        }
        break;

      case PurchaseStatus.error:
        _handleError(purchaseDetails.error!);
        break;

      case PurchaseStatus.canceled:
        Logger.info('구매가 취소되었습니다.');
        _purchasePending = false;
        onPurchaseCanceled?.call();
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
      // 디버그 로그 - 어떤 상품 정보가 오는지 확인
      Logger.info('========== 상품 전달 시작 ==========');
      Logger.info('productID: ${purchaseDetails.productID}');
      Logger.info('purchaseID: ${purchaseDetails.purchaseID}');
      Logger.info('status: ${purchaseDetails.status}');
      Logger.info('======================================');

      // 서버에 구매 검증 요청
      Logger.info('🔍 서버 구매 검증 시작...');
      final isValid = await _verifyPurchase(purchaseDetails);
      Logger.info('🔍 서버 구매 검증 결과: isValid = $isValid');

      if (!isValid) {
        Logger.error('❌ 구매 검증 실패! isValid=false');
        _purchasePending = false;
        return;
      }

      Logger.info('✅ 구매 검증 성공! 토큰 추가 처리 시작...');

      // 토큰 상품인 경우 토큰 추가
      final productInfo =
          InAppProducts.productDetails[purchaseDetails.productID];
      Logger.info('📦 productInfo 조회 결과:');
      Logger.info('   - productID: ${purchaseDetails.productID}');
      Logger.info('   - productInfo 존재: ${productInfo != null}');
      if (productInfo != null) {
        Logger.info('   - isSubscription: ${productInfo.isSubscription}');
        Logger.info('   - points: ${productInfo.points}');
      }

      if (productInfo != null &&
          !productInfo.isSubscription &&
          productInfo.points > 0) {
        Logger.info('✅ 토큰 상품 확인! ${productInfo.points}개 토큰 추가 완료 (서버에서 처리됨)');
      } else {
        Logger.info('⚠️ 토큰 상품 아님 또는 조건 미충족');
      }

      // 구독 상품인 경우 구독 활성화
      if (_isSubscription(purchaseDetails.productID)) {
        await _activateSubscription(purchaseDetails);
      }

      _purchasePending = false;

      // 성공 알림
      _showSuccessNotification(purchaseDetails.productID);
    } catch (e) {
      Logger.error('상품 전달 실패', e);
      _purchasePending = false;
    }
  }

  // 구매 검증
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      final Map<String, dynamic> verificationData = {};
      if (!kIsWeb && Platform.isAndroid) {
        // Android 영수증 데이터
        verificationData['platform'] = 'android';
        verificationData['purchaseToken'] =
            purchaseDetails.verificationData.serverVerificationData;
        verificationData['productId'] = purchaseDetails.productID;
        verificationData['orderId'] = purchaseDetails.purchaseID;
      } else if (!kIsWeb && Platform.isIOS) {
        // iOS 영수증 데이터
        verificationData['platform'] = 'ios';
        verificationData['receipt'] =
            purchaseDetails.verificationData.serverVerificationData;
        verificationData['productId'] = purchaseDetails.productID;
        verificationData['transactionId'] = purchaseDetails.purchaseID;
      }

      Logger.info('========== 🔍 구매 검증 요청 ==========');
      Logger.info('platform: ${verificationData['platform']}');
      Logger.info('productId: ${verificationData['productId']}');
      Logger.info(
          'transactionId/orderId: ${verificationData['transactionId'] ?? verificationData['orderId']}');
      Logger.info(
          'receipt 길이: ${(verificationData['receipt'] ?? verificationData['purchaseToken'] ?? '').toString().length}');
      Logger.info('=========================================');

      // 서버에 검증 요청
      final response = await _apiClient.post<Map<String, dynamic>>(
          '/payment-verify-purchase',
          data: verificationData);

      Logger.info('========== ✅ 구매 검증 응답 ==========');
      Logger.info('전체 응답: $response');
      Logger.info('valid: ${response['valid']}');
      Logger.info('tokensAdded: ${response['tokensAdded']}');
      Logger.info('error: ${response['error']}');
      Logger.info('=========================================');

      return response['valid'] ?? false;
    } catch (e, stackTrace) {
      Logger.error('========== ❌ 구매 검증 오류 ==========');
      Logger.error('오류: $e');
      Logger.error('스택트레이스: $stackTrace');
      Logger.error('=========================================');
      return false;
    }
  }

  // 구독 활성화
  Future<void> _activateSubscription(PurchaseDetails purchaseDetails) async {
    try {
      await _apiClient.post('/subscription-activate', data: {
        'productId': purchaseDetails.productID,
        'purchaseId': purchaseDetails.purchaseID,
        'platform':
            kIsWeb ? 'web' : (!kIsWeb && Platform.isIOS ? 'ios' : 'android')
      });

      Logger.info('구독 활성화되었습니다: ${purchaseDetails.productID}');

      // 구독 활성화 콜백 호출
      onSubscriptionActivated?.call(purchaseDetails.productID, true);
    } catch (e) {
      Logger.error('구독 활성화 실패', e);
    }
  }

  // 구매 복원
  Future<void> restorePurchases() async {
    try {
      // 복원 상태 초기화
      _isRestoring = true;
      _restoredCount = 0;
      _restoreTimeoutTimer?.cancel();

      await _inAppPurchase.restorePurchases();
      Logger.info('구매 복원 시작');

      // 타임아웃: 5초 후 복원할 항목이 없으면 완료 콜백 호출
      _restoreTimeoutTimer = Timer(const Duration(seconds: 5), () {
        if (_isRestoring) {
          _isRestoring = false;
          Logger.info('복원 타임아웃 - 복원된 항목: $_restoredCount개');
          onRestoreCompleted?.call(_restoredCount > 0, _restoredCount);
          _restoredCount = 0;
        }
      });
    } catch (e) {
      _isRestoring = false;
      _restoredCount = 0;
      Logger.error('구매 복원 실패', e);
      throw Exception('구매 복원에 실패했습니다.');
    }
  }

  // 구독 상태 확인
  Future<bool> isSubscriptionActive() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>('/subscription-status');

      return response['active'] ?? false;
    } catch (e) {
      Logger.error('구독 상태 확인 실패', e);
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
    final productInfo = InAppProducts.productDetails[productId];
    return productInfo != null && !productInfo.isSubscription;
  }

  // 구독 상품인지 확인
  bool _isSubscription(String productId) {
    final productInfo = InAppProducts.productDetails[productId];
    return productInfo != null && productInfo.isSubscription;
  }

  // UI 알림 메서드들
  void _showPendingUI() {
    Logger.info('구매가 진행 중입니다...');

    // Show loading UI using callback or toast
    if (onPurchaseStarted != null) {
      onPurchaseStarted!();
    } else if (_context != null) {
      Toast.show(_context!, message: '구매가 진행 중입니다...', type: ToastType.info);
    }
  }

  void _handleError(IAPError error) {
    Logger.error('오류: ${error.code} - ${error.message}');
    _purchasePending = false;

    // Show error UI using callback or toast
    final errorMessage = _getErrorMessage(error.code);
    if (onPurchaseError != null) {
      onPurchaseError!(errorMessage);
    } else if (_context != null) {
      Toast.show(_context!, message: errorMessage, type: ToastType.error);
    }
  }

  void _showSuccessNotification(String productId) {
    Logger.info('구매 완료 - productId: $productId');

    // Get product info - 정확한 매칭 먼저 시도
    ProductInfo? productInfo = InAppProducts.productDetails[productId];

    // 정확한 매칭 실패 시 부분 매칭 시도 (sandbox에서 ID 형식이 다를 수 있음)
    if (productInfo == null) {
      Logger.warning('정확한 productId 매칭 실패, 부분 매칭 시도: $productId');
      for (final entry in InAppProducts.productDetails.entries) {
        if (productId.contains(entry.key) || entry.key.contains(productId)) {
          productInfo = entry.value;
          Logger.info('부분 매칭 성공: ${entry.key}');
          break;
        }
      }
    }

    // 여전히 없으면 토큰 수 기반 추측
    if (productInfo == null) {
      Logger.warning('상품 정보 찾기 실패 - 기본값 사용');
    }

    final productName = productInfo?.title ?? '토큰';
    final tokenAmount = productInfo?.points ?? 0;
    final message = '$productName 구매가 완료되었습니다!';

    // 결제 완료 콜백 호출 (상품 정보 포함)
    if (onPurchaseCompleted != null) {
      onPurchaseCompleted!(productId, productName, tokenAmount);
    }

    // Show success UI using callback or toast
    if (onPurchaseSuccess != null) {
      onPurchaseSuccess!(message);
    } else if (_context != null) {
      Toast.show(_context!, message: message, type: ToastType.success);
    }
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      // 사용자 취소
      case 'E_USER_CANCELLED':
      case 'BillingResponse.userCanceled':
      case 'SKErrorPaymentCancelled':
        return '구매가 취소되었습니다';

      // 네트워크 오류
      case 'E_NETWORK_ERROR':
      case 'BillingResponse.serviceUnavailable':
      case 'SKErrorCloudServiceNetworkConnectionFailed':
        return '네트워크 연결을 확인해주세요';

      // 결제 정보 오류
      case 'E_PAYMENT_INVALID':
      case 'BillingResponse.developerError':
      case 'SKErrorPaymentInvalid':
        return '결제 정보가 올바르지 않습니다';

      // 상품 구매 불가
      case 'E_PRODUCT_NOT_AVAILABLE':
      case 'BillingResponse.itemUnavailable':
      case 'SKErrorStoreProductNotAvailable':
        return '해당 상품을 구매할 수 없습니다';

      // 이미 소유한 상품
      case 'BillingResponse.itemAlreadyOwned':
      case 'E_ALREADY_OWNED':
        return '이미 구매한 상품입니다. 구매 복원을 시도해주세요';

      // 구매 허용되지 않음
      case 'BillingResponse.featureNotSupported':
      case 'SKErrorPaymentNotAllowed':
        return '이 기기에서는 인앱 구매가 허용되지 않습니다';

      // 결제 지연
      case 'SKErrorPaymentDeferred':
        return '결제 승인 대기 중입니다. 잠시 후 다시 확인해주세요';

      // 서버 오류
      case 'BillingResponse.error':
      case 'SKErrorUnknown':
        return '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요';

      default:
        Logger.warning('알 수 없는 에러 코드: $errorCode');
        return '구매 중 오류가 발생했습니다. 다시 시도해주세요';
    }
  }

  void _onPurchaseDone() {
    _subscription?.cancel();
  }

  void _onPurchaseError(dynamic error) {
    Logger.error('구매 스트림 오류', error);
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
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
