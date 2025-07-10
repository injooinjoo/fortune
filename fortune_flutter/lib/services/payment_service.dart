import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_data.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';
// import 'package:tosspayments_widget_sdk_flutter/widgets/agreement.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/environment.dart';
import '../core/utils/logger.dart';

enum PaymentProvider {
  stripe,
  tossPay,
}

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();


  bool _isInitialized = false;
  late PaymentWidget _tossPaymentWidget;

  String _generatePaymentKey() {
    // Generate a unique payment key
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'pay_${timestamp}_$random';
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Stripe
      Stripe.publishableKey = Environment.stripePublishableKey;
      await Stripe.instance.applySettings();

      // Initialize TossPay
      final tossKey = Environment.tossPayClientKey;
      
      _tossPaymentWidget = PaymentWidget(
        clientKey: tossKey,
        customerKey: await _getCustomerKey(),
      );

      _isInitialized = true;
      Logger.info('Payment services initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize payment services', e);
      rethrow;
    }
  }

  Future<String> _getCustomerKey() async {
    // 실제 구현에서는 사용자 ID를 기반으로 고유한 customer key를 생성해야 합니다
    // 예: return 'user_${userId}';
    return 'customer_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Stripe 결제 처리
  Future<PaymentResult> processStripePayment({
    required int amount,
    required String currency,
    required String productName,
    required String userId,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // 1. Create payment intent on your server
      final paymentIntentData = await _createStripePaymentIntent(
        amount: amount,
        currency: currency,
        userId: userId,
      );

      // 2. Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          merchantDisplayName: 'Fortune App',
          customerId: paymentIntentData['customer'],
          customerEphemeralKeySecret: paymentIntentData['ephemeral_key'],
          style: ThemeMode.system,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFF6200EE),
            ),
          ),
        ),
      );

      // 3. Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Confirm payment on server
      final confirmResult = await _confirmStripePayment(
        paymentIntentId: paymentIntentData['payment_intent_id'],
        userId: userId,
      );

      return PaymentResult(
        success: true,
        paymentId: paymentIntentData['payment_intent_id'],
        provider: PaymentProvider.stripe,
        amount: amount,
      );

    } on StripeException catch (e) {
      Logger.error('Stripe payment failed', e);
      return PaymentResult(
        success: false,
        errorMessage: e.error.localizedMessage ?? 'Payment failed',
        provider: PaymentProvider.stripe,
        amount: amount,
      );
    } catch (e) {
      Logger.error('Payment processing error', e);
      return PaymentResult(
        success: false,
        errorMessage: 'An unexpected error occurred',
        provider: PaymentProvider.stripe,
        amount: amount,
      );
    }
  }

  // TossPay 결제 처리
  Future<PaymentResult> processTossPayment({
    required int amount,
    required String orderId,
    required String orderName,
    required String userId,
    required BuildContext context,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final paymentData = PaymentData(
        paymentKey: _generatePaymentKey(), // 결제 키 생성
        orderId: orderId,
        orderName: orderName,
        amount: amount,
        customerName: '사용자', // 실제 사용자 이름
        customerEmail: 'user@example.com', // 실제 사용자 이메일
      );

      // TossPay 결제 위젯 표시
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TossPaymentScreen(
            paymentWidget: _tossPaymentWidget,
            paymentData: paymentData,
            onSuccess: (paymentKey) async {
              // 서버에 결제 확인 요청
              final confirmResult = await _confirmTossPayment(
                paymentKey: paymentKey,
                orderId: orderId,
                amount: amount,
                userId: userId,
              );
              
              Navigator.pop(context, confirmResult);
            },
            onFail: (error) {
              Navigator.pop(context, PaymentResult(
                success: false,
                errorMessage: error,
                provider: PaymentProvider.tossPay,
                amount: amount,
              ));
            },
          ),
        ),
      );

      return result ?? PaymentResult(
        success: false,
        errorMessage: 'Payment cancelled',
        provider: PaymentProvider.tossPay,
        amount: amount,
      );

    } catch (e) {
      Logger.error('TossPay payment failed', e);
      return PaymentResult(
        success: false,
        errorMessage: 'Payment processing failed',
        provider: PaymentProvider.tossPay,
        amount: amount,
      );
    }
  }

  // Stripe Payment Intent 생성 (서버 API 호출)
  Future<Map<String, dynamic>> _createStripePaymentIntent({
    required int amount,
    required String currency,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Environment.apiBaseUrl}/api/payment/stripe/create-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create payment intent');
      }
    } catch (e) {
      Logger.error('Failed to create payment intent', e);
      rethrow;
    }
  }

  // Stripe 결제 확인 (서버 API 호출)
  Future<bool> _confirmStripePayment({
    required String paymentIntentId,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Environment.apiBaseUrl}/api/payment/stripe/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'paymentIntentId': paymentIntentId,
          'userId': userId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      Logger.error('Failed to confirm payment', e);
      return false;
    }
  }

  // TossPay 결제 확인 (서버 API 호출)
  Future<PaymentResult> _confirmTossPayment({
    required String paymentKey,
    required String orderId,
    required int amount,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Environment.apiBaseUrl}/api/payment/toss/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'paymentKey': paymentKey,
          'orderId': orderId,
          'amount': amount,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        return PaymentResult(
          success: true,
          paymentId: paymentKey,
          provider: PaymentProvider.tossPay,
          amount: amount,
        );
      } else {
        final error = jsonDecode(response.body);
        return PaymentResult(
          success: false,
          errorMessage: error['message'] ?? 'Payment confirmation failed',
          provider: PaymentProvider.tossPay,
          amount: amount,
        );
      }
    } catch (e) {
      Logger.error('Failed to confirm TossPay payment', e);
      return PaymentResult(
        success: false,
        errorMessage: 'Payment confirmation failed',
        provider: PaymentProvider.tossPay,
        amount: amount,
      );
    }
  }

  // 인증 토큰 가져오기
  Future<String> _getAuthToken() async {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      if (session != null) {
        return session.accessToken;
      }
      throw Exception('No auth session');
    } catch (e) {
      Logger.error('Failed to get auth token', e);
      throw Exception('Authentication required');
    }
  }

  // 토큰 충전 처리
  Future<bool> chargeTokens({
    required String userId,
    required int tokenAmount,
    required PaymentResult paymentResult,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Environment.apiBaseUrl}/api/user/tokens/charge'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'userId': userId,
          'tokenAmount': tokenAmount,
          'paymentId': paymentResult.paymentId,
          'paymentProvider': paymentResult.provider.name,
          'amount': paymentResult.amount,
        }),
      );

      if (response.statusCode == 200) {
        Logger.info('Tokens charged successfully: $tokenAmount tokens');
        return true;
      } else {
        Logger.error('Failed to charge tokens: ${response.body}');
        return false;
      }
    } catch (e) {
      Logger.error('Failed to charge tokens', e);
      return false;
    }
  }
}

// 결제 결과 모델
class PaymentResult {
  final bool success;
  final String? paymentId;
  final String? errorMessage;
  final PaymentProvider provider;
  final int amount;

  PaymentResult({
    required this.success,
    this.paymentId,
    this.errorMessage,
    required this.provider,
    required this.amount,
  });
}

// TossPay 결제 화면
class TossPaymentScreen extends StatefulWidget {
  final PaymentWidget paymentWidget;
  final PaymentData paymentData;
  final Function(String) onSuccess;
  final Function(String) onFail;

  const TossPaymentScreen({
    Key? key,
    required this.paymentWidget,
    required this.paymentData,
    required this.onSuccess,
    required this.onFail,
  }) : super(key: key);

  @override
  _TossPaymentScreenState createState() => _TossPaymentScreenState();
}

class _TossPaymentScreenState extends State<TossPaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제하기'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    '결제 금액: ${widget.paymentData.amount}원',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            // Agreement(
            //   paymentWidget: widget.paymentWidget,
            // ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    // TossPay 결제 요청
                    widget.onSuccess(widget.paymentData.paymentKey);
                    Navigator.pop(context, {'success': true, 'paymentKey': widget.paymentData.paymentKey});
                  } catch (e) {
                    widget.onFail(e.toString());
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text('${widget.paymentData.amount}원 결제하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}