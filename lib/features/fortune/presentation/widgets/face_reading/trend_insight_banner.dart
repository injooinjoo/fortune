import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/theme/typography_unified.dart';
import '../../providers/face_condition_tracker_provider.dart';

/// 트렌드 인사이트 배너
/// "요즘 표정이 점점 부드러워지고 있어요" 같은 메시지를 표시합니다.
///
/// 핵심 가치: 위로·공감·공유 (자기계발 ❌)
/// 타겟: 2-30대 여성
class TrendInsightBanner extends ConsumerWidget {
  /// 다크 모드 여부
  final bool isDark;

  /// 사용자 성별 (콘텐츠 차별화)
  final String? gender;

  /// 커스텀 인사이트 메시지 (없으면 Provider에서 가져옴)
  final String? customInsight;

  /// 탭 콜백
  final VoidCallback? onTap;

  const TrendInsightBanner({
    super.key,
    this.isDark = false,
    this.gender,
    this.customInsight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackerState = ref.watch(faceConditionTrackerProvider);
    final trendDirection = ref.watch(conditionTrendDirectionProvider);
    final trendInsight = customInsight ?? ref.watch(conditionTrendInsightProvider) ?? '이번 주 트렌드를 분석 중이에요';

    // 트렌드 방향에 따른 스타일
    final (color, icon, emoji) = _getTrendStyle(trendDirection);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.12),
              color.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // 트렌드 아이콘
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),

            // 인사이트 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 라벨
                  Row(
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getHeaderLabel(trendDirection),
                        style: context.labelSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // 인사이트 메시지
                  Text(
                    trendInsight,
                    style: context.bodyMedium.copyWith(
                      color: isDark
                          ? DSColors.textPrimaryDark
                          : DSColors.textPrimary,
                      height: 1.4,
                    ),
                  ),

                  // 로딩 상태
                  if (trackerState.isLoading) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 화살표 (탭 가능한 경우)
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: isDark
                    ? DSColors.textSecondaryDark
                    : DSColors.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  /// 트렌드 방향에 따른 스타일 반환
  (Color, IconData, String) _getTrendStyle(String direction) {
    switch (direction) {
      case 'up':
      case 'improving':
        return (DSColors.success, Icons.trending_up, '📈');
      case 'down':
      case 'declining':
        return (DSColors.warning, Icons.trending_down, '📉');
      case 'stable':
      default:
        return (DSColors.accentSecondary, Icons.trending_flat, '✨');
    }
  }

  /// 트렌드 방향에 따른 헤더 라벨
  String _getHeaderLabel(String direction) {
    switch (direction) {
      case 'up':
      case 'improving':
        return '좋은 흐름이에요';
      case 'down':
      case 'declining':
        return '조금 쉬어가도 괜찮아요';
      case 'stable':
      default:
        return '이번 주 트렌드';
    }
  }
}

/// 간단한 트렌드 칩 (작은 공간용)
class TrendChip extends ConsumerWidget {
  final bool isDark;

  const TrendChip({
    super.key,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendDirection = ref.watch(conditionTrendDirectionProvider);

    final (color, icon, label) = switch (trendDirection) {
      'up' || 'improving' => (DSColors.success, Icons.arrow_upward, '상승'),
      'down' || 'declining' => (DSColors.warning, Icons.arrow_downward, '하락'),
      _ => (DSColors.accentSecondary, Icons.remove, '유지'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
