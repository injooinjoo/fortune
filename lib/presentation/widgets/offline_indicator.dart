import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/app_typography.dart';
import '../../../../core/theme/toss_design_system.dart';

class OfflineIndicator extends ConsumerWidget {
  final bool isOffline;
  final DateTime? lastSyncTime;

  const OfflineIndicator({
    super.key,
    required this.isOffline,
    this.lastSyncTime});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.2),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.error.withOpacity(0.5),
            width: 1
          )
        )
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            size: AppDimensions.iconSizeXSmall,
            color: Theme.of(context).colorScheme.error.withOpacity(0.9)
          ),
          SizedBox(width: AppSpacing.spacing2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '오프라인 모드',
                  style: Theme.of(context).textTheme.labelSmall
                ),
                if (lastSyncTime != null) ...[
                  SizedBox(height: AppSpacing.spacing1),
                  Text(
                    '동기화: ${_formatLastSync(lastSyncTime!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error.withOpacity(0.8))
                  )
                ]
              ]
            )
          ),
          TextButton(
            onPressed: () {
              // Retry connection
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('연결을 다시 시도합니다...'),
                  duration: Duration(seconds: 2)
                )
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing2, vertical: AppSpacing.spacing1),
              minimumSize: Size.zero
            ),
            child: Text(
              '재시도',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error.withOpacity(0.9))
            )
          )
        ]
      )
    );
  }

  String _formatLastSync(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }
}

// Cached Fortune Card Widget
class CachedFortuneCard extends StatelessWidget {
  final String title;
  final String content;
  final DateTime cachedAt;
  final VoidCallback? onTap;
  final bool isExpired;

  const CachedFortuneCard({
    super.key,
    required this.title,
    required this.content,
    required this.cachedAt,
    this.onTap,
    this.isExpired = false
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing2),
      elevation: isExpired ? 1 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusMedium,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppDimensions.borderRadiusMedium,
            color: isExpired ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1) : null
          ),
          child: Padding(
            padding: AppSpacing.paddingAll16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                      )
                    ),
                    if (isExpired)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.spacing2,
                          vertical: AppSpacing.spacing1
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error.withOpacity(0.2),
                          borderRadius: AppDimensions.borderRadiusMedium
                        ),
                        child: Text(
                          '만료됨',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error.withOpacity(0.9))
                        )
                      ),
                    SizedBox(width: AppSpacing.spacing2),
                    Icon(
                      Icons.offline_bolt,
                      size: AppDimensions.iconSizeXSmall,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)
                    )
                  ]
                ),
                SizedBox(height: AppSpacing.spacing2),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isExpired ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.onSurface.withOpacity(0.87)
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis
                ),
                SizedBox(height: AppSpacing.spacing2),
                Text(
                  '캐시됨: ${_formatCachedTime(cachedAt)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)
                )
              ]
            )
          )
        )
      )
    );
  }

  String _formatCachedTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 7) {
      return '${time.month}월 ${time.day}일';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}