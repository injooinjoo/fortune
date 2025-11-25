// This modal is used for premium features that require souls
// Premium fortunes consume souls while regular fortunes give souls
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../glassmorphism/glass_container.dart';
import '../../presentation/providers/token_provider.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_animations.dart';

class TokenInsufficientModal extends ConsumerStatefulWidget {
  final int requiredTokens;
  final String fortuneType;

  const TokenInsufficientModal({
    super.key,
    required this.requiredTokens,
    required this.fortuneType,
  });

  @override
  ConsumerState<TokenInsufficientModal> createState() => _TokenInsufficientModalState();

  static Future<bool> show({
    required BuildContext context,
    required int requiredTokens,
    required String fortuneType,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TokenInsufficientModal(
        requiredTokens: requiredTokens,
        fortuneType: fortuneType,
      ),
    );
    return result ?? false;
  }
}

class _TokenInsufficientModalState extends ConsumerState<TokenInsufficientModal> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppAnimations.medium,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
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
    final tokenState = ref.watch(tokenProvider);
    final remainingTokens = tokenState.balance?.remainingTokens ?? 0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: TossDesignSystem.transparent,
          child: GlassContainer(
      width: MediaQuery.of(context).size.width * 0.9 > 400 
                ? 400 
                : MediaQuery.of(context).size.width * 0.9,
            padding: AppSpacing.paddingAll24,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
            blur: 20,
            child: Column(
      mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.error.withValues(alpha: 0.2),
                  ),
                  child: Icon(
                    Icons.auto_awesome_outlined,
                    size: 40,
                    color: theme.colorScheme.error,
                  ),
                ),
                SizedBox(height: AppSpacing.spacing4),
                
                // Title
                Text(
                  '영혼이 부족합니다',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.spacing2),
                
                // Description
                Text(
                  '이 프리미엄 운세를 보려면 ${widget.requiredTokens}개의 영혼이 필요합니다.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.spacing4),
                
                // Current Balance
                Container(
                  padding: AppSpacing.paddingAll16,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.5),
                    borderRadius: AppDimensions.borderRadiusMedium,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTokenInfo(
                        label: '보유 영혼',
                        value: '$remainingTokens개',
                        color: theme.colorScheme.primary,
                      ),
                      Container(
                        width: 1,
                        height: AppDimensions.buttonHeightSmall,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                      _buildTokenInfo(
                        label: '필요 영혼',
                        value: '${widget.requiredTokens}개',
                        color: theme.colorScheme.error,
                      ),
                      Container(
                        width: 1,
                        height: AppDimensions.buttonHeightSmall,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                      _buildTokenInfo(
                        label: '부족',
                        value: '${widget.requiredTokens - remainingTokens}개',
                        color: theme.colorScheme.error,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.spacing6),
                
                // Options
                Text(
                  '영혼을 얻으시겠습니까?',
                  style: theme.textTheme.bodyLarge,
                ),
                SizedBox(height: AppSpacing.spacing4),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.shopping_cart_rounded,
                        label: '영혼 상점',
                        color: theme.colorScheme.primary,
                        onTap: () {
                          context.pop();
                          context.push('/payment/tokens');
                        },
                      ),
                    ),
                    SizedBox(width: AppSpacing.spacing3),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.card_giftcard_rounded,
                        label: '무료 영혼',
                        color: TossDesignSystem.gray600,
                        onTap: () async {
                          final result = await ref.read(tokenProvider.notifier).claimDailyTokens();
                          if (result && context.mounted) {
                            Navigator.of(context).pop(true);
                          } else if (context.mounted) {
                            _showClaimError();
                          }
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(height: AppSpacing.spacing3),
                
                // Subscription Option
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.secondary.withValues(alpha: 0.2),
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: AppDimensions.borderRadiusMedium,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Material(
                    color: TossDesignSystem.transparent,
                    child: InkWell(
      onTap: () {
                        context.pop();
                        context.push('/subscription');
                      },
                      borderRadius: AppDimensions.borderRadiusMedium,
                      child: Padding(
                        padding: AppSpacing.paddingAll16,
                        child: Row(
                          children: [
                            Icon(
                              Icons.all_inclusive_rounded,
                              color: theme.colorScheme.primary,
                      ),
                            SizedBox(width: AppSpacing.spacing3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                        Text(
                                    '무제한 이용권',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                                    '월 ₩30,000으로 모든 프리미엄 운세 무제한',
                          style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      )),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.spacing4),
                
                // Cancel Button
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    '나중에 하기',
                    style: AppTypography.button,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTokenInfo({
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
                        Text(
                          label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
        SizedBox(height: AppSpacing.spacing1),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
      color: color.withValues(alpha: 0.2),
        borderRadius: AppDimensions.borderRadiusMedium,
        border: Border.all(
                      color: color.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: TossDesignSystem.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDimensions.borderRadiusMedium,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.spacing3),
            child: Column(
              children: [
                Icon(icon, color: color, size: AppDimensions.iconSizeMedium),
                SizedBox(height: AppSpacing.spacing1),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showClaimError() {
    final theme = Theme.of(context);
    final tokenError = ref.read(tokenProvider).error;
    
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content: Text(
          tokenError == 'ALREADY_CLAIMED'
              ? '오늘은 이미 무료 영혼을 받으셨습니다'
              : '무료 영혼 받기에 실패했습니다',
        ),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}