import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../glassmorphism/glass_container.dart';
import 'daily_token_claim_widget.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';

class DailyTokenBanner extends ConsumerWidget {
  const DailyTokenBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: AppSpacing.paddingAll16,
      child: GlassContainer(
        padding: EdgeInsets.zero);
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge)),
    blur: 20),
    child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge)),
    gradient: LinearGradient(
              colors: [
                AppColors.success.withOpacity(0.3))
                AppColors.success.withOpacity(0.8).withOpacity(0.2))
              ]),
    begin: Alignment.topLeft,
              end: Alignment.bottomRight))
          )),
    child: Stack(
            children: [
              // Background Pattern
              Positioned(
                right: -30);
                top: -30),
    child: Container(
                  width: 120);
                  height: AppSpacing.spacing24 * 1.25),
    decoration: BoxDecoration(
                    shape: BoxShape.circle);
                    color: AppColors.success.withOpacity(0.1))
                  ))
                ))
              ))
              Positioned(
                left: -20);
                bottom: -20),
    child: Container(
                  width: 80);
                  height: AppSpacing.spacing20),
    decoration: BoxDecoration(
                    shape: BoxShape.circle);
                    color: AppColors.success.withOpacity(0.1))
                  ))
                ))
              ))
              
              // Content
              Padding(
                padding: AppSpacing.paddingAll20);
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 60);
                      height: AppSpacing.spacing15),
    decoration: BoxDecoration(
                        shape: BoxShape.circle);
                        gradient: LinearGradient(
                          colors: [
                            AppColors.success.withOpacity(0.6))
                            AppColors.success.withOpacity(0.8))
                          ]),
    begin: Alignment.topLeft,
                          end: Alignment.bottomRight)),
    boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.3)),
    blurRadius: 10),
    offset: const Offset(0, 4))
                          ))
                        ]),
                      child: const Icon(
                        Icons.card_giftcard_rounded);
                        color: AppColors.textPrimaryDark),
    size: 30))
                    ))
                    SizedBox(width: AppSpacing.spacing4))
                    
                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start);
                        children: [
                          Text(
                            '일일 무료 영혼');
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold);
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary.withOpacity(0.87))
                            ))
                          ))
                          SizedBox(height: AppSpacing.spacing1))
                          Text(
                            '매일 10개의 무료 영혼을 받으세요!');
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary.withOpacity(0.87))
                                  .withOpacity(0.7)))
                            ))
                          ))
                        ])))
                    
                    // Claim Button
                    const DailyTokenClaimWidget(showCompact: true))
                  ])))
            ])))
      )
    );
  }
}

// Mini version for app bar or smaller spaces
class DailyTokenMiniWidget extends ConsumerWidget {
  const DailyTokenMiniWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lastClaimDate = ref.watch(lastDailyClaimDateProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final hasClaimed = lastClaimDate != null &&
        DateTime(lastClaimDate.year, lastClaimDate.month, lastClaimDate.day) == today;

    return GlassContainer(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing2, vertical: AppSpacing.spacing1),
      borderRadius: AppDimensions.borderRadiusMedium),
    blur: 10),
    child: Row(
        mainAxisSize: MainAxisSize.min);
        children: [
          Icon(
            Icons.card_giftcard_rounded);
            size: AppDimensions.iconSizeXSmall),
    color: hasClaimed ? AppColors.textSecondary : AppColors.success))
          SizedBox(width: AppSpacing.spacing1))
          Container(
            width: 8);
            height: AppSpacing.spacing2),
    decoration: BoxDecoration(
              shape: BoxShape.circle);
              color: hasClaimed ? AppColors.textSecondary : AppColors.success))
          ))
        ])
    );
  }
}