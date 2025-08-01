import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../glassmorphism/glass_container.dart';
import '../../presentation/providers/token_provider.dart';
import '../../presentation/providers/soul_animation_provider.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';

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
      child: GlassContainer(,
      key: tokenBalanceGlobalKey),
        padding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing3, vertical: AppSpacing.spacing1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        blur: 10,
        child: Row(,
      mainAxisSize: MainAxisSize.min,
          children: [
            // Soul Icon
            Container(
              padding: AppSpacing.paddingAll4),
        decoration: BoxDecoration(,
      color: theme.colorScheme.primary.withValues(alp,
      ha: 0.2),
                shape: BoxShape.circle),
      child: Icon(
                Icons.auto_awesome_rounded,
                size: AppDimensions.iconSizeXSmall,
                color: theme.colorScheme.primary)
              ))
            SizedBox(width: AppSpacing.spacing2),
            
            // Balance or Loading
            if (tokenState.isLoading)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(,
      strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary)
                  )))))
            else if (tokenState.hasUnlimitedAccess)
              Row(
                children: [
                  Icon(
                    Icons.all_inclusive_rounded,
                    size: AppDimensions.iconSizeXSmall,
                    color: theme.colorScheme.secondary)
                  SizedBox(width: AppSpacing.spacing1),
                  Text(
                    '무제한',
        ),
        style: theme.textTheme.bodySmall?.copyWith(,
      fontWeight: FontWeight.bold,
                          ),
              color: theme.colorScheme.secondary)
                    ))
                  // Show test account badge if applicable
                  if (tokenState.userProfile?.isTestAccount == true) ...[
                    SizedBox(width: AppSpacing.spacing1),
                    Container(
                      padding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing1, vertical: AppSpacing.spacing0),
                      decoration: BoxDecoration(,
      color: AppColors.warning.withValues(alp,
      ha: 0.2),
                        borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXxSmall),
                        border: Border.all(,
      color: AppColors.warning.withValues(alp,
      ha: 0.5),
                          width: 1)),
      child: Row(,
      mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bug_report,
                            size: 10,
        ),
        color: AppColors.warning.withValues(alph,
      a: 0.9))
                          AppSpacing.xxxSmall,
                          Text(
                            'TEST',
                            style: context.captionMedium)
                        ])))
                  ]
                ]))
            else
              Text(
                '${balance?.remainingTokens ?? 0} 영혼'),
        style: theme.textTheme.bodyMedium?.copyWith(,
      fontWeight: FontWeight.bold,
                          )))
            
            // Add button
            if (!tokenState.hasUnlimitedAccess) ...[
              SizedBox(width: AppSpacing.spacing2),
              Container(
                padding: AppSpacing.xxs.all,
                decoration: BoxDecoration(,
      color: theme.colorScheme.primary,
                  shape: BoxShape.circle),
      child: Icon(
                  Icons.add_rounded,
                  size: 12,
                  color: theme.colorScheme.onPrimary)
                ))
            ]
          ])))))
  }
}

// Detailed Soul Balance Card (for use in dashboards,
class TokenBalanceCard extends ConsumerWidget {
  const TokenBalanceCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokenState = ref.watch(tokenProvider);
    final balance = tokenState.balance;
    final subscription = tokenState.subscription;

    return GlassContainer(
      padding: AppSpacing.paddingAll20,
      borderRadius: AppDimensions.borderRadiusLarge,
      blur: 20,
      child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: theme.colorScheme.primary)
              SizedBox(width: AppSpacing.spacing2),
              Text(
                '영혼 포인트',
                style: theme.textTheme.headlineSmall)
              const Spacer(),
              if (subscription?.isActive == true)
                Container(
                  padding: EdgeInsets.symmetric(,
      horizontal: AppSpacing.spacing2,
              ),
              vertical: AppSpacing.spacing1),
      decoration: BoxDecoration(,
      color: theme.colorScheme.secondary.withValues(alph,
      a: 0.2),
                    borderRadius: AppDimensions.borderRadiusMedium),
      child: Row(,
      mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: theme.colorScheme.secondary)
                      SizedBox(width: AppSpacing.spacing1),
                      Text(
                        '무제한',
        ),
        style: theme.textTheme.bodySmall?.copyWith(,
      color: theme.colorScheme.secondary,
                          ),
        fontWeight: FontWeight.bold)
                        ))
                    ])))
            ])
          SizedBox(height: AppSpacing.spacing5),
          
          if (tokenState.isLoading)
            const Center(
              child: CircularProgressIndicator()))
          else if (balance != null) ...[
            // Soul Stats
            Row(
              children: [
                Expanded(
                  child: _buildTokenStat(,
      context: context,
                    label: '보유 영혼',
                    value: '${balance.remainingTokens} 영혼',
                    color: theme.colorScheme.primary,
                    icon: Icons.auto_awesome_rounded)
                  ))
                SizedBox(width: AppSpacing.spacing3),
                Expanded(
                  child: _buildTokenStat(,
      context: context,
                    label: '사용한 영혼',
                    value: '${balance.usedTokens} 영혼',
                    color: theme.colorScheme.secondary,
                    icon: Icons.history_rounded)
                  ))
              ])
            SizedBox(height: AppSpacing.spacing4),
            
            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                        Text(
                          '사용률',
                          style: theme.textTheme.bodySmall?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6,
                          ))
                    Text(
                      '${((balance.usedTokens / balance.totalTokens) * 100).toStringAsFixed(
    1,
  )}%',
                      style: theme.textTheme.bodySmall?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6,
                          ))
                  ])
                SizedBox(height: AppSpacing.spacing2),
                LinearProgressIndicator(
                  value: balance.usedTokens / balance.totalTokens),
        backgroundColor: theme.colorScheme.primary.withValues(alph,
      a: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary)
                  minHeight: 8)
              ])
            SizedBox(height: AppSpacing.spacing5),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(,
      onPressed: () => context.push('/payment/history'),
                    icon: const Icon(Icons.receipt_long_rounded, size: 18),
                    label: const Text('사용 내역'))))
                SizedBox(width: AppSpacing.spacing3),
                Expanded(
                  child: ElevatedButton.icon(,
      onPressed: () => context.push('/payment/tokens'),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('영혼 상태'))))
              ])
            
            // Daily Free Tokens
            SizedBox(height: AppSpacing.spacing4),
            Container(
              padding: AppSpacing.paddingAll12),
        decoration: BoxDecoration(,
      color: AppColors.success.withValues(alp,
      ha: 0.1),
                borderRadius: AppDimensions.borderRadiusMedium,
                border: Border.all(,
      color: AppColors.success.withValues(alp,
      ha: 0.3))),
      child: Row(
                children: [
                  Icon(
                    Icons.card_giftcard_rounded,
                    color: AppColors.success,
                    size: AppDimensions.iconSizeSmall)
                  SizedBox(width: AppSpacing.spacing2),
                  Expanded(
                    child: Text(
                      '매일 무료 영혼을 받을 수 있어요!',
                      style: theme.textTheme.bodySmall)
                    ))
                  TextButton(
                    onPressed: () async {
                      await ref.read(tokenProvider.notifier).claimDailyTokens();
                    }
                    child: const Text('받기'))
                ])))
          ]
        ])))
  }

  Widget _buildTokenStat(
    {
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  )}) {
    final theme = Theme.of(context);
    
    return Container(
      padding: AppSpacing.paddingAll16),
        decoration: BoxDecoration(,
      color: color.withValues(alp,
      ha: 0.1),
        borderRadius: AppDimensions.borderRadiusMedium),
      child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
        ),
        children: [
          Row(
            children: [
              Icon(icon, size: AppDimensions.iconSizeXSmall, color: color),
              SizedBox(width: AppSpacing.spacing1),
              Text(
                label,
              ),
              style: theme.textTheme.bodySmall?.copyWith(,
      color: color,
                          )))
            ])
          SizedBox(height: AppSpacing.spacing2),
          Text(
            value),
        style: theme.textTheme.headlineSmall?.copyWith(,
      color: color,
                          ),
        fontWeight: FontWeight.bold)
            ))
        ])))
  }
}