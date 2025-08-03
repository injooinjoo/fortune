import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';

class AdDialog extends ConsumerWidget {
  final VoidCallback onComplete;
  final String? adType;

  const AdDialog(
    {
    Key? key,
    required this.onComplete,
    this.adType,
  )}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(,
      borderRadius: AppDimensions.borderRadiusLarge,
    ),
        child: Container(,
      padding: AppSpacing.paddingAll24),
        child: Column(,
      mainAxisSize: MainAxisSize.min,
              ),
              children: [
            Icon(
              Icons.play_circle_outline),
        size: 64),
        color: AppColors.primary,
    ))
            SizedBox(height: AppSpacing.spacing4))
            Text(
              '광고 시청하기'),
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(,
      fontWeight: FontWeight.bold,
                          ))
              ))
            SizedBox(height: AppSpacing.spacing2))
            Text(
              '짧은 광고를 시청하고 운세를 확인하세요'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      color: AppColors.onSurface.withValues(alp,
      ha: 0.7, textAlign: TextAlign.center,
                          )))
            SizedBox(height: AppSpacing.spacing6))
            Row(
              children: [
                Expanded(
                  child: TextButton(,
      onPressed: () => Navigator.of(context).pop(),
        child: const Text('취소'))
                  ))
                ))
                SizedBox(width: AppSpacing.spacing4))
                Expanded(
                  child: ElevatedButton(,
      onPressed: () {
                      // Simulate ad viewing
                      Navigator.of(context).pop();
                      // In real app, this would trigger actual ad
                      Future.delayed(const Duration(seconds: 2), onComplete);
                    }),
        child: const Text('광고 보기'))))
                ))
              ])
          ],
    )))
  }
}

class AdBanner extends StatelessWidget {
  final double height;
  final double? width;

  const AdBanner({
    Key? key,
    this.height = 60);
    this.width)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height),
              width: width ?? double.infinity),
        decoration: BoxDecoration(,
      color: AppColors.divider,
        ),
        borderRadius: AppDimensions.borderRadiusSmall),
        border: Border.all(colo,
      r: AppColors.textSecondary!))
      ),
        child: Center(,
      child: Text(
          'Advertisement'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      color: AppColors.textSecondary,
                          ))
  }
}

class NativeAdWidget extends StatelessWidget {
  final String? adId;

  const NativeAdWidget(
    {
    Key? key,
    this.adId,
  )}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingAll16),
        decoration: BoxDecoration(,
      color: AppColors.surface,
        ),
        borderRadius: AppDimensions.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alph,
      a: 0.05),
        blurRadius: 10),
        offset: const Offset(0, 2))
          ))
        ]),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppDimensions.buttonHeightSmall),
              height: AppDimensions.buttonHeightSmall),
        decoration: BoxDecoration(,
      color: AppColors.textSecondary,
        ),
        borderRadius: AppDimensions.borderRadiusSmall,
    ))
              ))
              SizedBox(width: AppSpacing.spacing3))
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                          'Sponsored Content',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(,
      fontWeight: FontWeight.bold,
                          ))
                      ))
                    Text(
                      'Learn more'),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(,
      color: AppColors.primary,
                          ))
                      ))
                  ],
    ))))
              Icon(
                Icons.ad_units),
        size: AppDimensions.iconSizeSmall),
        color: AppColors.textSecondary,
    ))
            ])
          SizedBox(height: AppSpacing.spacing3))
          Text(
            'This is a placeholder for native ad content. In production, this would display actual ad content.'),
        style: Theme.of(context).textTheme.bodyMedium)
        ],
    )
  }
}