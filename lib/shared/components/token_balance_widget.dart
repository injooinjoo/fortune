import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../glassmorphism/glass_container.dart';
import '../../presentation/providers/token_provider.dart';
import '../../presentation/providers/soul_animation_provider.dart';

class TokenBalanceWidget extends ConsumerWidget {
  const TokenBalanceWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokenState = ref.watch(tokenProvider);
    final balance = tokenState.balance;
    
    if (balance == null && !tokenState.isLoading) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => context.push('/payment/history'),
      child: GlassContainer(
        key: tokenBalanceGlobalKey,
        padding: EdgeInsets.symmetric(
          horizontal: TossDesignSystem.spacingS, 
          vertical: TossDesignSystem.spacingXXS
        ),
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusXL),
        blur: 10,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Soul Icon
            Container(
              padding: const EdgeInsets.all(TossDesignSystem.spacingXXS),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: TossDesignSystem.spacingXS),
            
            // Balance or Loading
            if (tokenState.isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    balance?.toString() ?? '0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class FullTokenBalanceWidget extends ConsumerWidget {
  const FullTokenBalanceWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokenState = ref.watch(tokenProvider);
    final balance = tokenState.balance;
    
    return GestureDetector(
      onTap: () => context.push('/payment/token-purchase'),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(TossDesignSystem.spacingL),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
              theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1)]),
          borderRadius: BorderRadius.circular(TossDesignSystem.radiusL),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            width: 1)),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '영혼 잔액',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface)),
                Icon(
                  Icons.add_circle_outline,
                  color: theme.colorScheme.primary,
                  size: 24)]),
            SizedBox(height: TossDesignSystem.spacingS),
            
            // Balance Display
            if (tokenState.isLoading)
              SizedBox(
                height: 48,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(TossDesignSystem.spacingS),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: TossDesignSystem.spacingS),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        balance?.toString() ?? '0',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface)),
                      Text(
                        '영혼',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7)))])]),
            
            SizedBox(height: TossDesignSystem.spacingM),
            
            // Action Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: TossDesignSystem.spacingS),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(TossDesignSystem.radiusM)),
              child: Center(
                child: Text(
                  '영혼 충전하기',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: TossDesignSystem.white,
                    fontWeight: FontWeight.w600,
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

// Token balance stats widget
class TokenBalanceStats extends ConsumerWidget {
  const TokenBalanceStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokenState = ref.watch(tokenProvider);
    
    return Container(
      padding: EdgeInsets.all(TossDesignSystem.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '영혼 사용 통계',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface)),
          const SizedBox(height: TossDesignSystem.spacingS),
          
          // Stats rows - TODO: Add these fields to TokenState
          // _buildTokenStat(
          //   context: context,
          //   label: '오늘 사용',
          //   value: '${tokenState.todayUsed ?? 0}',
          //   color: TossDesignSystem.gray600,
          //   icon: Icons.arrow_downward,
          // ),
          // SizedBox(height: TossDesignSystem.spacingXS),
          // _buildTokenStat(
          //   context: context,
          //   label: '오늘 획득',
          //   value: '${tokenState.todayEarned ?? 0}',
          //   color: TossDesignSystem.gray600,
          //   icon: Icons.arrow_upward,
          // ),
          // SizedBox(height: TossDesignSystem.spacingXS),
          // _buildTokenStat(
          //   context: context,
          //   label: '이번 달 사용',
          //   value: '${tokenState.monthlyUsed ?? 0}',
          //   color: theme.colorScheme.secondary,
          //   icon: Icons.calendar_today,
          // ),
        ],
      ),
    );
  }

  Widget _buildTokenStat({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
    required IconData icon}) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color),
            SizedBox(width: TossDesignSystem.spacingXS),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7)))]),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color))]);
  }
}