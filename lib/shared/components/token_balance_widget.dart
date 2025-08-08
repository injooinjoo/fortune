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
      child: GlassContainer(
        key: tokenBalanceGlobalKey,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing3, 
          vertical: AppSpacing.spacing1
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        blur: 10,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Soul Icon
            Container(
              padding: AppSpacing.paddingAll4,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.2),
                shape: BoxShape.circle),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: AppDimensions.iconSizeXSmall,
                color: theme.colorScheme.primary)),
            SizedBox(width: AppSpacing.spacing2),
            
            // Balance or Loading
            if (tokenState.isLoading)
              SizedBox(
                width: AppDimensions.iconSizeXSmall,
                height: AppDimensions.iconSizeXSmall,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary)))
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    balance?.toString() ?? '0',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface))])])));
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
        padding: EdgeInsets.all(AppSpacing.spacing5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.1)]),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1)),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '영혼 잔액',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface)),
                Icon(
                  Icons.add_circle_outline,
                  color: theme.colorScheme.primary,
                  size: AppDimensions.iconSizeMedium)]),
            SizedBox(height: AppSpacing.spacing3),
            
            // Balance Display
            if (tokenState.isLoading)
              SizedBox(
                height: 48,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary))))
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.spacing3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle),
                    child: Icon(
                      Icons.auto_awesome,
                      size: AppDimensions.iconSizeLarge,
                      color: theme.colorScheme.primary)),
                  SizedBox(width: AppSpacing.spacing3),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        balance?.toString() ?? '0',
                        style: AppTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface)),
                      Text(
                        '영혼',
                        style: AppTypography.bodySmall.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7)))])]),
            
            SizedBox(height: AppSpacing.spacing4),
            
            // Action Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.spacing3),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
              child: Center(
                child: Text(
                  '영혼 충전하기',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600))))])));
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
      padding: EdgeInsets.all(AppSpacing.spacing4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '영혼 사용 통계',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface)),
          const SizedBox(height: AppSpacing.spacing3),
          
          // Stats rows - TODO: Add these fields to TokenState
          // _buildTokenStat(
          //   context: context,
          //   label: '오늘 사용',
          //   value: '${tokenState.todayUsed ?? 0}',
          //   color: AppColors.error,
          //   icon: Icons.arrow_downward,
          // ),
          // SizedBox(height: AppSpacing.spacing2),
          // _buildTokenStat(
          //   context: context,
          //   label: '오늘 획득',
          //   value: '${tokenState.todayEarned ?? 0}',
          //   color: AppColors.success,
          //   icon: Icons.arrow_upward,
          // ),
          // SizedBox(height: AppSpacing.spacing2),
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
              size: AppDimensions.iconSizeSmall,
              color: color),
            SizedBox(width: AppSpacing.spacing2),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7)))]),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: color))]);
  }
}