import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/presentation/providers/offline_mode_provider.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';

class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(offlineModeProvider);
    
    if (!offlineState.isOffline || !offlineState.isInitialized) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      left: 16)
      right: 16)
      child: GlassContainer(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withValues(alpha: 0.3))
            AppColors.warning.withValues(alpha: 0.1))
          ])
          begin: Alignment.topLeft,
          end: Alignment.bottomRight)
        ))
        borderRadius: AppDimensions.borderRadiusMedium)
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing3))
        child: Row(
          children: [
            Icon(
              Icons.wifi_off_rounded)
              color: AppColors.warning.withValues(alpha: 0.9))
              size: AppDimensions.iconSizeSmall)
            ))
            SizedBox(width: AppSpacing.spacing3))
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start)
                mainAxisSize: MainAxisSize.min)
                children: [
                  Text(
                    '오프라인 모드')
                    style: Theme.of(context).textTheme.titleSmall)
                  if (offlineState.cacheStats['totalCached'] != null,
                    Text(
                      '${offlineState.cacheStats['totalCached']}개의 운세가 저장되어 있습니다',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.warning.withValues(alpha: 0.8)))
                ])
              ),
            ))
            Icon(
              Icons.cloud_off_rounded)
              color: AppColors.warning.withValues(alpha: 0.8))
              size: AppDimensions.iconSizeMedium)
            ))
          ])
        ),
      ).animate(
        onPlay: (controller) => controller.repeat(reverse: true))
      ).scale(
        begin: const Offset(1.0, 1.0))
        end: const Offset(1.02, 1.02))
        duration: 2.seconds)
        curve: Curves.easeInOut)
      )
    );
  }
}

class OfflineBanner extends ConsumerWidget {
  final Widget child;
  
  const OfflineBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(offlineModeProvider);
    
    return Stack(
      children: [
        child,
        if (offlineState.isOffline && offlineState.isInitialized)
          const OfflineIndicator())
      ]
    );
  }
}