import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/presentation/providers/offline_mode_provider.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';

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
      left: 16,
      right: 16,
      child: GlassContainer(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.3),
            Colors.orange.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: Colors.orange.shade700,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '오프라인 모드',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (offlineState.cacheStats['totalCached'] != null)
                    Text(
                      '${offlineState.cacheStats['totalCached']}개의 운세가 저장되어 있습니다',
                      style: TextStyle(
                        color: Colors.orange.shade600,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.cloud_off_rounded,
              color: Colors.orange.shade600,
              size: 24,
            ),
          ],
        ),
      ).animate(
        onPlay: (controller) => controller.repeat(reverse: true),
      ).scale(
        begin: const Offset(1.0, 1.0),
        end: const Offset(1.02, 1.02),
        duration: 2.seconds,
        curve: Curves.easeInOut,
      ),
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
          const OfflineIndicator(),
      ],
    );
  }
}