import 'package:flutter/material.dart';
import 'package:tosspayments_widget_sdk_flutter/tosspayments_widget_sdk_flutter.dart';
import '../../core/config/environment.dart';
import '../../core/utils/logger.dart';
import '../../core/network/api_client.dart';
import '../../models/payment_data.dart';

class TossPayService {
  static final TossPayService _instance = TossPayService._internal();
  factory TossPayService() => _instance;
  TossPayService._internal();

  final ApiClient _apiClient = ApiClient();
  PaymentWidget? _paymentWidget;
  bool _initialized = false;

  // TossPay 초기화
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final clientKey = Environment.tossPayClientKey;
      if (clientKey.isEmpty) {
        throw Exception('TossPay client key가 설정되지 않았습니다.');
      }

      _paymentWidget = PaymentWidget(
        clientKey: clientKey,
        customerKey: await _getCustomerKey(),
      );

      _initialized = true;
      Logger.info('TossPay 초기화 완료');
    } catch (e) {
      Logger.error('TossPay 초기화 실패', error: e);
      throw Exception('TossPay 초기화에 실패했습니다: $e');
    }
  }

  // 고객 키 생성 (사용자별 고유 키)
  Future<String> _getCustomerKey() async {
    // TODO: 실제 사용자 ID 기반으로 생성
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    return userId;
  }

  // TossPay 결제 위젯 가져오기
  PaymentWidget get paymentWidget {
    if (_paymentWidget == null) {
      throw Exception('TossPay가 초기화되지 않았습니다.');
    }
    return _paymentWidget!;
  }

  // 결제 위젯 렌더링
  Future<void> renderPaymentWidget({
    required String selector,
    required int amount,
    required String orderId,
    required String orderName,
  }) async {
    try {
      await _paymentWidget!.renderPaymentMethods(
        selector: selector,
        amount: PaymentAmount(
          currency: Currency.KRW,
          value: amount,
        ),
      );

      await _paymentWidget!.renderAgreement(
        selector: '${selector}_agreement',
      );
    } catch (e) {
      Logger.error('결제 위젯 렌더링 실패', error: e);
      throw Exception('결제 수단을 불러오는데 실패했습니다.');
    }
  }

  // 결제 요청
  Future<PaymentResponse> requestPayment({
    required String orderId,
    required String orderName,
    required int amount,
    required String successUrl,
    required String failUrl,
    String? customerEmail,
    String? customerName,
    String? customerMobilePhone,
  }) async {
    try {
      final response = await _paymentWidget!.requestPayment(
        paymentInfo: PaymentInfo(
          orderId: orderId,
          orderName: orderName,
          successUrl: successUrl,
          failUrl: failUrl,
          customerEmail: customerEmail,
          customerName: customerName,
          customerMobilePhone: customerMobilePhone,
        ),
      );

      return response;
    } catch (e) {
      Logger.error('결제 요청 실패', error: e);
      throw Exception('결제 요청에 실패했습니다.');
    }
  }

  // 결제 승인 (서버에서 처리)
  Future<TossPaymentResult> confirmPayment({
    required String paymentKey,
    required String orderId,
    required int amount,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/payment/toss/confirm',
        data: {
          'paymentKey': paymentKey,
          'orderId': orderId,
          'amount': amount,
        },
      );

      return TossPaymentResult(
        success: response['success'] ?? false,
        paymentKey: paymentKey,
        orderId: orderId,
        amount: amount,
        approvedAt: response['approvedAt'],
        receiptUrl: response['receiptUrl'],
        message: response['message'],
      );
    } catch (e) {
      Logger.error('결제 승인 실패', error: e);
      return TossPaymentResult(
        success: false,
        paymentKey: paymentKey,
        orderId: orderId,
        amount: amount,
        message: '결제 승인에 실패했습니다.',
      );
    }
  }

  // 결제 취소
  Future<bool> cancelPayment({
    required String paymentKey,
    required String cancelReason,
    int? cancelAmount,
  }) async {
    try {
      await _apiClient.post(
        '/payment/toss/cancel',
        data: {
          'paymentKey': paymentKey,
          'cancelReason': cancelReason,
          'cancelAmount': cancelAmount,
        },
      );

      return true;
    } catch (e) {
      Logger.error('결제 취소 실패', error: e);
      return false;
    }
  }

  // 결제 내역 조회
  Future<List<TossPaymentHistory>> getPaymentHistory() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/payment/toss/history',
      );

      final payments = (response['payments'] as List)
          .map((payment) => TossPaymentHistory.fromJson(payment))
          .toList();

      return payments;
    } catch (e) {
      Logger.error('결제 내역 조회 실패', error: e);
      return [];
    }
  }
}

// TossPay 결제 결과 모델
class TossPaymentResult {
  final bool success;
  final String paymentKey;
  final String orderId;
  final int amount;
  final String? approvedAt;
  final String? receiptUrl;
  final String? message;

  TossPaymentResult({
    required this.success,
    required this.paymentKey,
    required this.orderId,
    required this.amount,
    this.approvedAt,
    this.receiptUrl,
    this.message,
  });
}

// TossPay 결제 내역 모델
class TossPaymentHistory {
  final String paymentKey;
  final String orderId;
  final String orderName;
  final int amount;
  final String status;
  final String? approvedAt;
  final String? canceledAt;
  final String? receiptUrl;

  TossPaymentHistory({
    required this.paymentKey,
    required this.orderId,
    required this.orderName,
    required this.amount,
    required this.status,
    this.approvedAt,
    this.canceledAt,
    this.receiptUrl,
  });

  factory TossPaymentHistory.fromJson(Map<String, dynamic> json) {
    return TossPaymentHistory(
      paymentKey: json['paymentKey'],
      orderId: json['orderId'],
      orderName: json['orderName'],
      amount: json['amount'],
      status: json['status'],
      approvedAt: json['approvedAt'],
      canceledAt: json['canceledAt'],
      receiptUrl: json['receiptUrl'],
    );
  }
}

// 결제 응답 모델
class PaymentResponse {
  final bool success;
  final SuccessResponse? successResponse;
  final FailResponse? failResponse;

  PaymentResponse({
    required this.success,
    this.successResponse,
    this.failResponse,
  });
}

class SuccessResponse {
  final String paymentKey;
  final String orderId;
  final int amount;

  SuccessResponse({
    required this.paymentKey,
    required this.orderId,
    required this.amount,
  });
}

class FailResponse {
  final String errorCode;
  final String errorMessage;
  final String orderId;

  FailResponse({
    required this.errorCode,
    required this.errorMessage,
    required this.orderId,
  });
}