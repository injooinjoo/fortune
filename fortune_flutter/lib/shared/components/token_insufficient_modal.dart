// This modal is preserved for future premium features that will require tokens
// Currently not used for regular fortune viewing (which uses ads instead)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../glassmorphism/glass_container.dart';
import '../../presentation/providers/token_provider.dart';
import '../../domain/entities/token.dart';

class TokenInsufficientModal extends ConsumerStatefulWidget {
  final int requiredTokens;
  final String fortuneType;

  const TokenInsufficientModal({
    Key? key,
    required this.requiredTokens,
    required this.fortuneType,
  }) : super(key: key);

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
      duration: const Duration(milliseconds: 300),
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
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            width: MediaQuery.of(context).size.width * 0.9 > 400 
                ? 400 
                : MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24),
            borderRadius: BorderRadius.circular(20),
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
                    Icons.token_outlined,
                    size: 40,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  '토큰이 부족합니다',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Description
                Text(
                  '이 운세를 보려면 ${widget.requiredTokens}개의 토큰이 필요합니다.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Current Balance
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTokenInfo(
                        label: '보유 토큰',
                        value: remainingTokens.toString(),
                        color: theme.colorScheme.primary,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                      _buildTokenInfo(
                        label: '필요 토큰',
                        value: widget.requiredTokens.toString(),
                        color: theme.colorScheme.error,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                      _buildTokenInfo(
                        label: '부족',
                        value: (widget.requiredTokens - remainingTokens).toString(),
                        color: theme.colorScheme.error,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Options
                Text(
                  '토큰을 충전하시겠습니까?',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.shopping_cart_rounded,
                        label: '토큰 구매',
                        color: theme.colorScheme.primary,
                        onTap: () {
                          context.pop();
                          context.push('/payment/tokens');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.card_giftcard_rounded,
                        label: '무료 토큰',
                        color: Colors.green,
                        onTap: () async {
                          final result = await ref.read(tokenProvider.notifier).claimDailyTokens();
                          if (result && mounted) {
                            Navigator.of(context).pop(true);
                          } else if (mounted) {
                            _showClaimError();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Subscription Option
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.secondary.withValues(alpha: 0.2),
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        context.pop();
                        context.push('/subscription');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.all_inclusive_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
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
                                    '월 ₩9,900으로 모든 운세 무제한',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
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
                const SizedBox(height: 16),
                
                // Cancel Button
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    '나중에 하기',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 4),
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
              ? '오늘은 이미 무료 토큰을 받으셨습니다'
              : '무료 토큰 받기에 실패했습니다',
        ),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}