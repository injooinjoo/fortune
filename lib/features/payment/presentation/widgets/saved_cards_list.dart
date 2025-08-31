import '../../../../core/theme/toss_design_system.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/toss_design_system.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../presentation/widgets/common/custom_card.dart';
import '../../../../core/utils/haptic_utils.dart';

class SavedCardsList extends StatelessWidget {
  final List<PaymentMethod> paymentMethods;
  final String? selectedPaymentMethodId;
  final Function(String) onSelectPaymentMethod;
  final Function(String)? onDeletePaymentMethod;

  const SavedCardsList({
    super.key,
    required this.paymentMethods,
    this.selectedPaymentMethodId,
    required this.onSelectPaymentMethod,
    this.onDeletePaymentMethod});

  @override
  Widget build(BuildContext context) {
    if (paymentMethods.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '저장된 결제 수단',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...paymentMethods.asMap().entries.map((entry) {
          final index = entry.key;
          final paymentMethod = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPaymentMethodCard(
              context,
              paymentMethod,
              index));
        }).toList()
      ]);
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TossDesignSystem.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TossDesignSystem.gray200,
          style: BorderStyle.solid)),
      child: Column(
        children: [
          Icon(
            Icons.credit_card_off,
            size: 48,
            color: TossDesignSystem.gray600),
          const SizedBox(height: 12),
          Text(
            '저장된 결제 수단이 없습니다',
            style: TossDesignSystem.body1.copyWith(
              color: TossDesignSystem.gray600))
        ])
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    PaymentMethod paymentMethod,
    int index) {
    final card = paymentMethod.card;
    if (card == null) return const SizedBox.shrink();

    final isSelected = selectedPaymentMethodId == paymentMethod.id;
    final cardBrand = _getCardBrandIcon(card.brand ?? '');

    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        onSelectPaymentMethod(paymentMethod.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray200,
            width: isSelected ? 2 : 1),
          color: isSelected 
              ? TossDesignSystem.tossBlue.withOpacity(0.05) 
              : TossDesignSystem.gray50),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 선택 인디케이터
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray600,
                    width: 2),
                  color: isSelected ? TossDesignSystem.tossBlue : Colors.transparent),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white)
                    : null),
              const SizedBox(width: 16),
              
              // 카드 브랜드 아이콘
              Icon(
                cardBrand,
                size: 32,
                color: TossDesignSystem.gray900),
              const SizedBox(width: 12),
              
              // 카드 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCardBrandName(card.brand ?? ''),
                      style: TossDesignSystem.body1.copyWith(
                        fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '•••• ${card.last4}',
                      style: TossDesignSystem.body2.copyWith(
                        color: TossDesignSystem.gray600))
                  ])),
              
              // 만료일
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '만료일',
                    style: TossDesignSystem.caption.copyWith(
                      color: TossDesignSystem.gray600)),
                  Text(
                    '${card.expMonth?.toString().padLeft(2, '0')}/${card.expYear?.toString().substring(2)}',
                    style: TossDesignSystem.body2)
                ]),
              
              // 삭제 버튼
              if (onDeletePaymentMethod != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: TossDesignSystem.errorRed,
                    size: 20),
                  onPressed: () => _showDeleteConfirmation(
                    context,
                    paymentMethod.id,
                    card.last4 ?? ''))
              ]
            ]))))
    ).animate(delay: (index * 100).ms).fadeIn().slideX();
  }

  IconData _getCardBrandIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
      case 'american express':
        return Icons.credit_card;
      case 'discover':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  String _getCardBrandName(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
      case 'american express':
        return 'American Express';
      case 'discover':
        return 'Discover';
      case 'unionpay':
        return 'UnionPay';
      case 'jcb':
        return 'JCB';
      case 'diners':
        return 'Diners Club';
      default:
        return '카드';
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String paymentMethodId,
    String last4) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카드 삭제'),
        content: Text('•••• $last4 카드를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDeletePaymentMethod?.call(paymentMethodId);
            },
            style: TextButton.styleFrom(
              foregroundColor: TossDesignSystem.errorRed),
            child: const Text('삭제'))
        ])
    );
  }
}