import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../data/models/chat_insight_result.dart';

/// 4개 점수 pill 표시 (온도, 안정성, 주도권, 위험도)
class MetricPillsWidget extends StatelessWidget {
  final InsightScores scores;

  const MetricPillsWidget({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DSSpacing.xs,
      runSpacing: DSSpacing.xs,
      children: scores.entries
          .map((entry) => _buildPill(context, entry.key, entry.value))
          .toList(),
    );
  }

  Widget _buildPill(BuildContext context, String label, ScoreItem item) {
    final colors = context.colors;
    final typography = context.typography;

    final pillColor = _colorForValue(item.value, colors);
    final trendIcon = _trendIcon(item.trend);

    return Semantics(
      label: '$label ${item.value}점 ${_trendLabel(item.trend)}',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.sm,
          vertical: DSSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: pillColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(DSRadius.full),
          border: Border.all(color: pillColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: typography.labelSmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(width: DSSpacing.xxs),
            Text(
              '${item.value}',
              style: typography.labelSmall.copyWith(
                color: pillColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 2),
            Icon(trendIcon, size: 12, color: pillColor),
          ],
        ),
      ),
    );
  }

  Color _colorForValue(int value, DSColorScheme colors) {
    if (value >= 70) return colors.accent;
    if (value >= 40) return colors.accentSecondary;
    return colors.error;
  }

  IconData _trendIcon(ScoreTrend trend) {
    switch (trend) {
      case ScoreTrend.up:
        return Icons.trending_up;
      case ScoreTrend.down:
        return Icons.trending_down;
      case ScoreTrend.stable:
        return Icons.trending_flat;
    }
  }

  String _trendLabel(ScoreTrend trend) {
    switch (trend) {
      case ScoreTrend.up:
        return '상승 추세';
      case ScoreTrend.down:
        return '하락 추세';
      case ScoreTrend.stable:
        return '안정';
    }
  }
}
