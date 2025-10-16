import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdDialog extends ConsumerWidget {
  final VoidCallback onComplete;
  final String? adType;

  const AdDialog({
    super.key,
    required this.onComplete,
    this.adType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusLarge,
      ),
      child: Container(
        padding: AppSpacing.paddingAll24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
              children: [
            Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: AppSpacing.spacing4),
            Text(
              '광고 시청하기',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.spacing2),
            Text(
              '짧은 광고를 시청하고 운세를 확인하세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.spacing6),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('취소'),
                  ),
                ),
                SizedBox(width: AppSpacing.spacing4),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Simulate ad viewing
                      Navigator.of(context).pop();
                      // In real app, this would trigger actual ad
                      Future.delayed(const Duration(seconds: 2), onComplete);
                    },
                    child: const Text('광고 보기'),
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

class AdBanner extends StatelessWidget {
  final double height;
  final double? width;

  const AdBanner({
    super.key,
    this.height = 60,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppDimensions.borderRadiusSmall,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Center(
        child: Text(
          'Advertisement',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class NativeAdWidget extends StatelessWidget {
  final String? adId;

  const NativeAdWidget({
    super.key,
    this.adId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppDimensions.borderRadiusMedium,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2))
        ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppDimensions.buttonHeightSmall,
                height: AppDimensions.buttonHeightSmall,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  borderRadius: AppDimensions.borderRadiusSmall)),
              SizedBox(width: AppSpacing.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sponsored Content',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Learn more',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary))
                  ]
                )
              ),
              Icon(
                Icons.ad_units,
                size: AppDimensions.iconSizeSmall,
                color: Theme.of(context).colorScheme.onSurfaceVariant)
            ],
          ),
          SizedBox(height: AppSpacing.spacing3),
          Text(
            'This is a placeholder for native ad content. In production, this would display actual ad content.',
            style: Theme.of(context).textTheme.bodyMedium)
        ]
      )
    );
  }
}