import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/utils/logger.dart';
import '../../core/network/api_client.dart';

class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  final ApiClient _apiClient = ApiClient();
  bool _initialized = false;

  // Stripe 초기화
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Stripe publishable key 설정
      final publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
      if (publishableKey.isEmpty) {
        throw Exception('Stripe publishable key가 설정되지 않았습니다.');
      }

      Stripe.publishableKey = publishableKey;
      
      // 필요한 경우 merchantIdentifier 설정 (Apple Pay용)
      await Stripe.instance.applySettings();
      
      _initialized = true;
      Logger.info('Stripe 초기화 완료');
    } catch (e) {
      Logger.error('Stripe 초기화 실패', error: e);
      throw Exception('Stripe 초기화에 실패했습니다: $e');
    }
  }

  // 결제 인텐트 생성 (서버에서 처리)
  Future<Map<String, dynamic>> createPaymentIntent({
    required int amount, // 원 단위
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/payment/create-payment-intent',
        data: {
          'amount': amount,
          'currency': currency,
          'metadata': metadata,
        },
      );

      return response;
    } catch (e) {
      Logger.error('결제 인텐트 생성 실패', error: e);
      throw Exception('결제 준비에 실패했습니다.');
    }
  }

  // 결제 처리
  Future<PaymentResult> processPayment({
    required int amount,
    required String currency,
    String? customerEmail,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // 1. 서버에서 payment intent 생성
      final paymentIntentData = await createPaymentIntent(
        amount: amount,
        currency: currency,
        metadata: metadata,
      );

      // 2. Payment sheet 초기화
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['clientSecret'],
          merchantDisplayName: 'Fortune 운세',
          customerEphemeralKeySecret: paymentIntentData['ephemeralKey'],
          customerId: paymentIntentData['customer'],
          style: ThemeMode.system,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFFFFD700), // 골드 색상
            ),
            shapes: const PaymentSheetShape(
              borderRadius: 12.0,
            ),
          ),
          billingDetails: BillingDetails(
            email: customerEmail,
          ),
        ),
      );

      // 3. Payment sheet 표시
      await Stripe.instance.presentPaymentSheet();

      // 4. 결제 성공
      return PaymentResult(
        success: true,
        paymentIntentId: paymentIntentData['paymentIntentId'],
        message: '결제가 성공적으로 완료되었습니다.',
      );
    } on StripeException catch (e) {
      Logger.error('Stripe 결제 오류', error: e);
      
      // 사용자가 취소한 경우
      if (e.error.code == FailureCode.Canceled) {
        return PaymentResult(
          success: false,
          message: '결제가 취소되었습니다.',
          errorCode: 'CANCELLED',
        );
      }
      
      // 기타 오류
      return PaymentResult(
        success: false,
        message: e.error.localizedMessage ?? '결제 처리 중 오류가 발생했습니다.',
        errorCode: e.error.code.toString(),
      );
    } catch (e) {
      Logger.error('결제 처리 중 예외 발생', error: e);
      return PaymentResult(
        success: false,
        message: '결제 처리 중 오류가 발생했습니다.',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  // 구독 결제 처리
  Future<PaymentResult> processSubscription({
    required String priceId,
    String? customerEmail,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // 1. 서버에서 subscription intent 생성
      final subscriptionData = await _apiClient.post<Map<String, dynamic>>(
        '/payment/create-subscription',
        data: {
          'priceId': priceId,
          'customerEmail': customerEmail,
          'metadata': metadata,
        },
      );

      // 2. Payment sheet 초기화 (구독용)
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: subscriptionData['setupIntentClientSecret'],
          merchantDisplayName: 'Fortune 운세',
          customerEphemeralKeySecret: subscriptionData['ephemeralKey'],
          customerId: subscriptionData['customer'],
          style: ThemeMode.system,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFFFFD700),
            ),
          ),
        ),
      );

      // 3. Payment sheet 표시
      await Stripe.instance.presentPaymentSheet();

      // 4. 구독 활성화 확인
      await _apiClient.post(
        '/payment/confirm-subscription',
        data: {
          'subscriptionId': subscriptionData['subscriptionId'],
        },
      );

      return PaymentResult(
        success: true,
        subscriptionId: subscriptionData['subscriptionId'],
        message: '구독이 성공적으로 시작되었습니다.',
      );
    } on StripeException catch (e) {
      Logger.error('Stripe 구독 오류', error: e);
      
      if (e.error.code == FailureCode.Canceled) {
        return PaymentResult(
          success: false,
          message: '구독이 취소되었습니다.',
          errorCode: 'CANCELLED',
        );
      }
      
      return PaymentResult(
        success: false,
        message: e.error.localizedMessage ?? '구독 처리 중 오류가 발생했습니다.',
        errorCode: e.error.code.toString(),
      );
    } catch (e) {
      Logger.error('구독 처리 중 예외 발생', error: e);
      return PaymentResult(
        success: false,
        message: '구독 처리 중 오류가 발생했습니다.',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  // Apple Pay 지원 여부 확인
  Future<bool> isApplePaySupported() async {
    try {
      return await Stripe.instance.isApplePaySupported();
    } catch (e) {
      Logger.error('Apple Pay 지원 확인 실패', error: e);
      return false;
    }
  }

  // Google Pay 지원 여부 확인
  Future<bool> isGooglePaySupported() async {
    try {
      return await Stripe.instance.isPlatformPaySupported();
    } catch (e) {
      Logger.error('Google Pay 지원 확인 실패', error: e);
      return false;
    }
  }

  // 카드 정보 수집 (직접 입력)
  Future<PaymentMethod?> collectCardDetails() async {
    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      
      return paymentMethod;
    } catch (e) {
      Logger.error('카드 정보 수집 실패', error: e);
      return null;
    }
  }

  // 저장된 결제 수단 조회
  Future<List<PaymentMethod>> getSavedPaymentMethods(String customerId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/payment/payment-methods',
        queryParameters: {'customerId': customerId},
      );

      final methods = (response['paymentMethods'] as List)
          .map((method) => PaymentMethod.fromJson(method))
          .toList();

      return methods;
    } catch (e) {
      Logger.error('저장된 결제 수단 조회 실패', error: e);
      return [];
    }
  }

  // 구독 취소
  Future<bool> cancelSubscription(String subscriptionId) async {
    try {
      await _apiClient.post(
        '/payment/cancel-subscription',
        data: {'subscriptionId': subscriptionId},
      );
      
      return true;
    } catch (e) {
      Logger.error('구독 취소 실패', error: e);
      return false;
    }
  }
}

// 결제 결과 모델
class PaymentResult {
  final bool success;
  final String message;
  final String? paymentIntentId;
  final String? subscriptionId;
  final String? errorCode;

  PaymentResult({
    required this.success,
    required this.message,
    this.paymentIntentId,
    this.subscriptionId,
    this.errorCode,
  });
}