import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/payment_service.dart';
import '../../core/utils/logger.dart';
import 'auth_provider.dart';
import 'token_provider.dart';
import '../../domain/entities/token.dart';

export 'token_provider.dart' show tokenPackagesProvider;

// Payment Service Provider
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

// Payment State Provider
final paymentStateProvider = StateNotifierProvider<PaymentStateNotifier, PaymentState>((ref) {
  return PaymentStateNotifier(ref);
});

// Payment State Model
class PaymentState {
  final bool isProcessing;
  final PaymentResult? lastResult;
  final String? error;

  PaymentState({
    this.isProcessing = false,
    this.lastResult,
    this.error,
  });

  PaymentState copyWith({
    bool? isProcessing,
    PaymentResult? lastResult,
    String? error,
  }) {
    return PaymentState(
      isProcessing: isProcessing ?? this.isProcessing,
      lastResult: lastResult ?? this.lastResult,
      error: error,
    );
  }
}

// Payment State Notifier
class PaymentStateNotifier extends StateNotifier<PaymentState> {
  final Ref ref;
  late final PaymentService _paymentService;

  PaymentStateNotifier(this.ref) : super(PaymentState()) {
    _paymentService = ref.read(paymentServiceProvider);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _paymentService.initialize();
    } catch (e) {
      Logger.error('Failed to initialize payment service', e);
    }
  }

  // Process payment with selected provider
  Future<PaymentResult> processPayment({
    required PaymentProvider provider,
    required int amount,
    required int tokenAmount,
    required BuildContext context,
  }) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      final authState = ref.read(authStateProvider).value;
      final userId = authState?.session?.user.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      PaymentResult result;

      switch (provider) {
        case PaymentProvider.stripe:
          result = await _paymentService.processStripePayment(
            amount: amount,
            currency: 'KRW',
            productName: '$tokenAmount 토큰',
            userId: userId,
          );
          break;

        case PaymentProvider.tossPay:
          final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
          result = await _paymentService.processTossPayment(
            amount: amount,
            orderId: orderId,
            orderName: '$tokenAmount 토큰 구매',
            userId: userId,
            context: context,
          );
          break;
      }

      if (result.success) {
        // Charge tokens on successful payment
        final chargeSuccess = await _paymentService.chargeTokens(
          userId: userId,
          tokenAmount: tokenAmount,
          paymentResult: result,
        );

        if (chargeSuccess) {
          // Refresh token balance
          await ref.read(tokenProvider.notifier).refreshBalance();
          
          state = state.copyWith(
            isProcessing: false,
            lastResult: result,
          );
        } else {
          // Payment succeeded but token charge failed
          state = state.copyWith(
            isProcessing: false,
            error: 'Payment successful but failed to charge tokens. Please contact support.',
          );
        }
      } else {
        state = state.copyWith(
          isProcessing: false,
          lastResult: result,
          error: result.errorMessage,
        );
      }

      return result;
    } catch (e) {
      Logger.error('Payment processing error', e);
      final errorResult = PaymentResult(
        success: false,
        errorMessage: e.toString(),
        provider: provider,
        amount: amount,
      );
      
      state = state.copyWith(
        isProcessing: false,
        lastResult: errorResult,
        error: e.toString(),
      );
      
      return errorResult;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

