import 'package:flutter/material.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/agreement.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import '../../models/payment_data.dart';
import '../../shared/components/app_header.dart';
import '../../core/utils/logger.dart';

class TossPaymentScreen extends StatefulWidget {
  final PaymentWidget paymentWidget;
  final PaymentData paymentData;
  final Function(String paymentKey) onSuccess;
  final Function(String error) onFail;

  const TossPaymentScreen({
    Key? key,
    required this.paymentWidget,
    required this.paymentData,
    required this.onSuccess,
    required this.onFail,
  }) : super(key: key);

  @override
  State<TossPaymentScreen> createState() => _TossPaymentScreenState();
}

class _TossPaymentScreenState extends State<TossPaymentScreen> {
  bool _isLoading = false;
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      await widget.paymentWidget.renderPaymentMethods(
        method: PaymentMethodWidget(
          selector: 'payment-methods',
          amount: widget.paymentData.amount,
        ),
        amount: PaymentAmount(
          currency: 'KRW',
          value: widget.paymentData.amount,
        ),
      );
    } catch (e) {
      Logger.error('Failed to initialize payment methods', e);
      widget.onFail('결제 수단을 불러오는데 실패했습니다');
    }
  }

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    try {
      final result = await widget.paymentWidget.requestPayment(
        paymentInfo: PaymentInfo(
          orderId: widget.paymentData.orderId,
          orderName: widget.paymentData.orderName,
          amount: widget.paymentData.amount,
        ),
      );

      if (result.success) {
        widget.onSuccess(result.paymentKey);
      } else {
        widget.onFail(result.fail?.message ?? '결제에 실패했습니다');
      }
    } catch (e) {
      Logger.error('Payment failed', e);
      widget.onFail('결제 처리 중 오류가 발생했습니다');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const AppHeader(
        title: 'TossPay 결제',
        showShareButton: false,
        showTokenBalance: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Order Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.paymentData.orderName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '결제 금액',
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(
                        '₩${widget.paymentData.amount.toStringAsFixed(0)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Payment Methods
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '결제 수단 선택',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // TossPay payment methods will be rendered here
                    Container(
                      id: 'payment-methods',
                      constraints: const BoxConstraints(
                        minHeight: 200,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Agreement widget
                    Agreement(
                      selector: 'agreement',
                    ),
                  ],
                ),
              ),
            ),

            // Payment Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          '₩${widget.paymentData.amount.toStringAsFixed(0)} 결제하기',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}