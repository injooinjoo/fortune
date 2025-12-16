// This modal is used for premium features that require souls
// Premium fortunes consume souls while regular fortunes give souls
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../glassmorphism/glass_container.dart';
import '../../presentation/providers/token_provider.dart';

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
      duration: DSAnimation.durationMedium,
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
    final colors = context.colors;
    final typography = context.typography;
    final tokenState = ref.watch(tokenProvider);
    final remainingTokens = tokenState.balance?.remainingTokens ?? 0;

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
            padding: const EdgeInsets.all(DSSpacing.lg),
            borderRadius: BorderRadius.circular(DSRadius.lg),
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
                    color: colors.error.withValues(alpha: 0.2),
                  ),
                  child: Icon(
                    Icons.auto_awesome_outlined,
                    size: 40,
                    color: colors.error,
                  ),
                ),
                const SizedBox(height: DSSpacing.lg),

                // Title
                Text(
                  '영혼이 부족합니다',
                  style: typography.headingMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: DSSpacing.sm),

                // Description
                Text(
                  '이 프리미엄 운세를 보려면 ${widget.requiredTokens}개의 영혼이 필요합니다.',
                  style: typography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DSSpacing.lg),

                // Current Balance
                Container(
                  padding: const EdgeInsets.all(DSSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTokenInfo(
                        label: '보유 영혼',
                        value: '$remainingTokens개',
                        color: colors.accent,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: colors.divider,
                      ),
                      _buildTokenInfo(
                        label: '필요 영혼',
                        value: '${widget.requiredTokens}개',
                        color: colors.error,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: colors.divider,
                      ),
                      _buildTokenInfo(
                        label: '부족',
                        value: '${widget.requiredTokens - remainingTokens}개',
                        color: colors.error,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DSSpacing.xl),

                // Options
                Text(
                  '영혼을 얻으시겠습니까?',
                  style: typography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: DSSpacing.lg),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.shopping_cart_rounded,
                        label: '영혼 상점',
                        color: colors.accent,
                        onTap: () {
                          context.pop();
                          context.push('/token-purchase');
                        },
                      ),
                    ),
                    const SizedBox(width: DSSpacing.md),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.card_giftcard_rounded,
                        label: '무료 영혼',
                        color: colors.textSecondary,
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
                const SizedBox(height: DSSpacing.md),

                // Subscription Option
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.accentTertiary.withValues(alpha: 0.2),
                        colors.accent.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    border: Border.all(
                      color: colors.accentTertiary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        DSHaptics.light();
                        context.pop();
                        context.push('/subscription');
                      },
                      borderRadius: BorderRadius.circular(DSRadius.md),
                      child: Padding(
                        padding: const EdgeInsets.all(DSSpacing.md),
                        child: Row(
                          children: [
                            Icon(
                              Icons.all_inclusive_rounded,
                              color: colors.accentTertiary,
                            ),
                            const SizedBox(width: DSSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '무제한 이용권',
                                    style: typography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '월 ₩30,000으로 모든 프리미엄 운세 무제한',
                                    style: typography.bodySmall.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: colors.accentTertiary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: DSSpacing.lg),

                // Cancel Button
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    '나중에 하기',
                    style: typography.labelMedium.copyWith(
                      color: colors.textSecondary,
                    ),
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
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      children: [
        Text(
          label,
          style: typography.labelSmall.copyWith(
            color: colors.textTertiary,
          ),
        ),
        const SizedBox(height: DSSpacing.xs),
        Text(
          value,
          style: typography.headingSmall.copyWith(
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
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            DSHaptics.light();
            onTap();
          },
          borderRadius: BorderRadius.circular(DSRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: DSSpacing.md),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: DSSpacing.xs),
                Text(
                  label,
                  style: typography.labelSmall.copyWith(
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
    final colors = context.colors;
    final tokenError = ref.read(tokenProvider).error;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tokenError == 'ALREADY_CLAIMED'
              ? '오늘은 이미 무료 영혼을 받으셨습니다'
              : '무료 영혼 받기에 실패했습니다',
        ),
        backgroundColor: colors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        margin: const EdgeInsets.all(DSSpacing.md),
      ),
    );
  }
}
