import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../glassmorphism/glass_container.dart';
import '../../presentation/providers/token_provider.dart';
import '../../presentation/providers/soul_animation_provider.dart';

class TokenBalanceWidget extends ConsumerWidget {
  const TokenBalanceWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenState = ref.watch(tokenProvider);
    final balance = tokenState.balance;
    
    if (balance == null && !tokenState.isLoading) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        DSHaptics.light();
        context.push('/token-purchase');
      },
      child: GlassContainer(
        key: tokenBalanceGlobalKey,
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.sm,
          vertical: DSSpacing.xs
        ),
        borderRadius: BorderRadius.circular(DSRadius.lg),
        blur: 10,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Soul Icon
            Container(
              padding: const EdgeInsets.all(DSSpacing.xs),
              decoration: BoxDecoration(
                color: colors.accentTertiary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: colors.accentTertiary,
              ),
            ),
            const SizedBox(width: DSSpacing.xs),
            
            // Balance or Loading
            if (tokenState.isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.accentTertiary,
                  ),
                ),
              )
            else
              Text(
                balance?.remainingTokens.toString() ?? '0',
                style: context.typography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FullTokenBalanceWidget extends ConsumerWidget {
  const FullTokenBalanceWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final tokenState = ref.watch(tokenProvider);
    final balance = tokenState.balance;

    return GestureDetector(
      onTap: () {
        DSHaptics.light();
        context.push('/token-purchase');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(DSSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.accentTertiary.withValues(alpha: 0.1),
              colors.accentTertiary.withValues(alpha: 0.05)]),
          borderRadius: BorderRadius.circular(DSRadius.lg),
          border: Border.all(
            color: colors.accentTertiary.withValues(alpha: 0.2),
            width: 1)),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '영혼 잔액',
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary)),
                Icon(
                  Icons.add_circle_outline,
                  color: colors.accentTertiary,
                  size: 24)]),
            const SizedBox(height: DSSpacing.sm),

            // Balance Display
            if (tokenState.isLoading)
              SizedBox(
                height: 48,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colors.accentTertiary,
                    ),
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(DSSpacing.sm),
                    decoration: BoxDecoration(
                      color: colors.accentTertiary.withValues(alpha: 0.1),
                      shape: BoxShape.circle),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 32,
                      color: colors.accentTertiary,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        balance?.toString() ?? '0',
                        style: typography.numberLarge.copyWith(
                          color: colors.textPrimary)),
                      Text(
                        '영혼',
                        style: typography.bodySmall.copyWith(
                          color: colors.textSecondary))])]),

            const SizedBox(height: DSSpacing.md),

            // Action Button - Using gold accent for premium feel
            DSButton.gold(
              text: '영혼 충전하기',
              fullWidth: true,
              onPressed: () {
                DSHaptics.light();
                context.push('/token-purchase');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Token balance stats widget
class TokenBalanceStats extends ConsumerWidget {
  const TokenBalanceStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;

    return DSCard.hanji(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '영혼 사용 통계',
            style: typography.headingSmall.copyWith(
              color: colors.textPrimary)),
          const SizedBox(height: DSSpacing.sm),

          // Stats rows - TODO: Add these fields to TokenState
          // _buildTokenStat(
          //   context: context,
          //   label: '오늘 사용',
          //   value: '${tokenState.todayUsed ?? 0}',
          //   color: colors.textSecondary,
          //   icon: Icons.arrow_downward,
          // ),
          // SizedBox(height: DSSpacing.xs),
          // _buildTokenStat(
          //   context: context,
          //   label: '오늘 획득',
          //   value: '${tokenState.todayEarned ?? 0}',
          //   color: colors.textSecondary,
          //   icon: Icons.arrow_upward,
          // ),
          // SizedBox(height: DSSpacing.xs),
          // _buildTokenStat(
          //   context: context,
          //   label: '이번 달 사용',
          //   value: '${tokenState.monthlyUsed ?? 0}',
          //   color: colors.accent,
          //   icon: Icons.calendar_today,
          // ),
        ],
      ),
    );
  }
}