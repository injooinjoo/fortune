import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../presentation/widgets/common/custom_card.dart';

class PaymentCardInput extends StatefulWidget {
  final Function(CardDetails) onCardDetailsComplete;
  final bool showSaveCard;
  final VoidCallback? onSaveCardToggle;
  final bool saveCardValue;

  const PaymentCardInput({
    super.key,
    required this.onCardDetailsComplete,
    this.showSaveCard = false,
    this.onSaveCardToggle,
    this.saveCardValue = false,
  });

  @override
  State<PaymentCardInput> createState() => _PaymentCardInputState();
}

class _PaymentCardInputState extends State<PaymentCardInput> {
  CardFormEditController? _controller;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = CardFormEditController();
      _controller!.addListener(_onCardDetailsChanged);
    }
  }

  @override
  void dispose() {
    if (!kIsWeb && _controller != null) {
      _controller!.removeListener(_onCardDetailsChanged);
      _controller!.dispose();
    }
    super.dispose();
  }

  void _onCardDetailsChanged() {
    if (_controller == null) return;
    
    final details = _controller!.details;
    final isComplete = details.complete == true;
    
    if (_isComplete != isComplete) {
      setState(() {
        _isComplete = isComplete;
      });
      
      if (isComplete) {
        widget.onCardDetailsComplete(details);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카드 정보',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Stripe 카드 입력 폼
                if (kIsWeb) ...[
                  // Web platform placeholder
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.credit_card,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '웹 브라우저에서는 결제가 지원되지 않습니다.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '모바일 앱을 이용해주세요.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  CardFormField(
                    controller: _controller!,
                    style: CardFormStyle(
                      backgroundColor: AppColors.surface,
                      borderColor: AppColors.divider,
                      borderWidth: 1,
                      borderRadius: 12,
                      cursorColor: AppColors.primary,
                      textColor: AppColors.textPrimary,
                      placeholderColor: AppColors.textSecondary,
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                    ),
                    enablePostalCode: false,
                    autofocus: true,
                    dangerouslyGetFullCardDetails: true,
                  ),
                ],
                
                if (widget.showSaveCard) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: widget.saveCardValue,
                        onChanged: (_) => widget.onSaveCardToggle?.call(),
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '다음 결제를 위해 카드 정보 저장',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSecurityInfo(),
        if (!_isComplete) ...[
          const SizedBox(height: 16),
          _buildHelpText(),
        ],
      ],
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            size: 20,
            color: AppColors.info,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'PCI DSS 준수 보안 결제',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHelpItem(
          icon: Icons.credit_card,
          text: '카드번호 16자리를 입력해주세요',
        ),
        const SizedBox(height: 8),
        _buildHelpItem(
          icon: Icons.calendar_today,
          text: '유효기간은 MM/YY 형식으로 입력해주세요',
        ),
        const SizedBox(height: 8),
        _buildHelpItem(
          icon: Icons.lock_outline,
          text: 'CVC는 카드 뒷면의 3자리 숫자입니다',
        ),
      ],
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}