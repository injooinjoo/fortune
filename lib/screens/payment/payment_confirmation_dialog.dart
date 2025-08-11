import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/glassmorphism/glass_container.dart';
import '../../domain/entities/token.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_animations.dart';

class PaymentConfirmationDialog extends StatefulWidget {
  final TokenPackage package;
  final Function(String paymentMethod) onConfirm;

  const PaymentConfirmationDialog({
    Key? key,
    required this.package,
    required this.onConfirm}) : super(key: key);

  static Future<bool> show({
    required BuildContext context,
    required TokenPackage package,
    required Function(String paymentMethod) onConfirm
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentConfirmationDialog(
        package: package,
        onConfirm: onConfirm
      )
    );
    return result ?? false;
  }

  @override
  State<PaymentConfirmationDialog> createState() => _PaymentConfirmationDialogState();
}

class _PaymentConfirmationDialogState extends State<PaymentConfirmationDialog> 
    with SingleTickerProviderStateMixin {
  String? _selectedPaymentMethod;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'card',
      'name': '신용/체크카드',
      'icon': Icons.credit_card,
      'color': AppColors.primary,
      'available': true,
    },
    {
      'id': 'tosspay',
      'name': '토스페이',
      'icon': Icons.payment,
      'color': Color(0xFF0064FF),
      'available': true,
    },
    {
      'id': 'kakaopay',
      'name': '카카오페이',
      'icon': Icons.payment,
      'color': Color(0xFFFEE500),
      'available': false, // Coming soon
    },
    {
      'id': 'naverpay',
      'name': '네이버페이',
      'icon': Icons.payment,
      'color': Color(0xFF03C75A),
      'available': false, // Coming soon
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppAnimations.durationMedium
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            width: MediaQuery.of(context).size.width * 0.9 > 400 
                ? 400 
                : MediaQuery.of(context).size.width * 0.9,
            padding: AppSpacing.paddingAll24,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXxLarge),
            blur: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: AppSpacing.paddingAll12,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        shape: BoxShape.circle
                      ),
                      child: Icon(
                        Icons.shopping_cart_rounded,
                        color: theme.colorScheme.primary,
                        size: AppDimensions.iconSizeMedium
                      )
                    ),
                    SizedBox(width: AppSpacing.spacing3),
                    Expanded(
                      child: Text(
                        '구매 확인',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold
                        )
                      )
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close),
                      iconSize: 20
                    )
                  ],
                SizedBox(height: AppSpacing.spacing6),
                
                // Package Summary
                Container(
                  padding: AppSpacing.paddingAll16,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.5),
                    borderRadius: AppDimensions.borderRadiusMedium,
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3)
                    )
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: AppSpacing.spacing12 * 1.04,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.amber.withOpacity(0.6), AppColors.warning.withOpacity(0.6)]
                              )
                            ),
                            child: Center(
                              child: Text(
                                '${widget.package.tokens}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppColors.textPrimaryDark,
                                  fontWeight: FontWeight.bold
                                )
                              )
                            )
                          ),
                          SizedBox(width: AppSpacing.spacing4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.package.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                if (widget.package.bonusTokens != null && 
                                    widget.package.bonusTokens! > 0)
                                  Text(
                                    '+ ${widget.package.bonusTokens} 보너스',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.success
                                    )
                                  )
                              ]
                            )
                          ),
                          Text(
                            '₩${_formatPrice(widget.package.price)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary
                            )
                          )
                        ],
                      if (widget.package.originalPrice != null) ...[
                        SizedBox(height: AppSpacing.spacing3),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.spacing3,
                            vertical: AppSpacing.spacing1 * 1.5
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: AppDimensions.borderRadiusSmall
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_offer,
                                size: AppDimensions.iconSizeXSmall,
                                color: AppColors.error
                              ),
                              SizedBox(width: AppSpacing.spacing1),
                              Text(
                                '${((1 - widget.package.price / widget.package.originalPrice!) * 100).round()}% 할인 적용',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold
                                )
                              )
                            ]
                          )
                        )
                      ]
                    ]
                  )
                ),
                SizedBox(height: AppSpacing.spacing6),
                
                // Payment Methods
                Text(
                  '결제 수단 선택',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold
                  )
                ),
                SizedBox(height: AppSpacing.spacing3),
                ..._paymentMethods.map((method) => _buildPaymentMethodTile(
                  method: method,
                  theme: theme
                )).toList(),
                SizedBox(height: AppSpacing.spacing6),
                
                // Terms
                Container(
                  padding: AppSpacing.paddingAll12,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.3),
                    borderRadius: AppDimensions.borderRadiusSmall
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: AppDimensions.iconSizeXSmall,
                        color: theme.colorScheme.onSurface.withOpacity(0.6)
                      ),
                      SizedBox(width: AppSpacing.spacing2),
                      Expanded(
                        child: Text(
                          '구매 후 7일 이내 미사용 토큰에 한해 환불이 가능합니다.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6)
                          )
                        )
                      )
                    ]
                  )
                ),
                SizedBox(height: AppSpacing.spacing6),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isProcessing 
                            ? null 
                            : () => Navigator.of(context).pop(false),
                        child: const Text('취소')
                      )
                    ),
                    SizedBox(width: AppSpacing.spacing3),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedPaymentMethod != null && !_isProcessing
                            ? _handleConfirm
                            : null,
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.textPrimaryDark
                                  )
                                )
                              )
                            : const Text('구매하기')
                      )
                    )
                  ]
                )
              ]
            )
          )
        )
      )
    );
  }

  Widget _buildPaymentMethodTile({
    required Map<String, dynamic> method,
    required ThemeData theme}) {
    final isSelected = _selectedPaymentMethod == method['id'];
    final isAvailable = method['available'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xSmall),
      child: InkWell(
        onTap: isAvailable
            ? () {
                setState(() {
                  _selectedPaymentMethod = method['id'];
                });
              }
            : null,
        borderRadius: AppDimensions.borderRadiusMedium,
        child: Container(
          padding: AppSpacing.paddingAll16,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.surface.withOpacity(0.3),
            borderRadius: AppDimensions.borderRadiusMedium,
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.2),
              width: isSelected ? 2 : 1
            )
          ),
          child: Row(
            children: [
              Container(
                width: AppDimensions.buttonHeightSmall,
                height: AppDimensions.buttonHeightSmall,
                decoration: BoxDecoration(
                  color: (method['color'] as Color).withOpacity(isAvailable ? 0.2 : 0.1),
                  borderRadius: AppDimensions.borderRadiusSmall
                ),
                child: Icon(
                  method['icon'] as IconData,
                  color: isAvailable
                      ? method['color'] as Color
                      : AppColors.textSecondary,
                  size: AppDimensions.iconSizeMedium
                )
              ),
              SizedBox(width: AppSpacing.spacing3),
              Expanded(
                child: Text(
                  method['name'] as String,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isAvailable
                        ? null
                        : theme.colorScheme.onSurface.withOpacity(0.5)
                  )
                )
              ),
              if (!isAvailable)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing2,
                    vertical: AppSpacing.spacing1
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXxSmall)
                  ),
                  child: Text(
                    'Coming Soon',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5)
                    )
                  )
                ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary
                )
            ]
          )
        )
      )
    );
  }

  Future<void> _handleConfirm() async {
    setState(() => _isProcessing = true);
    
    try {
      final result = await widget.onConfirm(_selectedPaymentMethod!);
      if (mounted) {
        // Only close dialog if payment was successful
        if (result == true) {
          Navigator.of(context).pop(true);
        } else {
          setState(() => _isProcessing = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('발생했습니다: $e'),
            backgroundColor: AppColors.error)
        );
      }
    }
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'      
    );
  }
}