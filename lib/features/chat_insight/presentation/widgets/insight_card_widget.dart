import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../data/models/chat_insight_result.dart';
import 'metric_pills_widget.dart';

/// 인사이트 요약 카드 (scores + summary bullets + red/green flags)
class InsightCardWidget extends StatefulWidget {
  final InsightScores scores;
  final InsightHighlights highlights;

  const InsightCardWidget({
    super.key,
    required this.scores,
    required this.highlights,
  });

  @override
  State<InsightCardWidget> createState() => _InsightCardWidgetState();
}

class _InsightCardWidgetState extends State<InsightCardWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final bullets = widget.highlights.summaryBullets;
    final visibleBullets = _isExpanded ? bullets : bullets.take(3).toList();

    return DSCard.elevated(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Icon(Icons.insights, color: colors.textSecondary, size: 20),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '관계 인사이트',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // Metric Pills
          MetricPillsWidget(scores: widget.scores),
          const SizedBox(height: DSSpacing.md),

          // Summary Bullets
          ...visibleBullets.map((bullet) => Padding(
                padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: typography.bodyMedium
                            .copyWith(color: colors.textSecondary)),
                    Expanded(
                      child: Text(
                        bullet,
                        style: typography.bodyMedium
                            .copyWith(color: colors.textSecondary),
                      ),
                    ),
                  ],
                ),
              )),

          // 더 보기 토글
          if (bullets.length > 3)
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: DSSpacing.xs),
                child: Text(
                  _isExpanded ? '접기' : '더 보기',
                  style: typography.bodySmall
                      .copyWith(color: colors.accentSecondary),
                ),
              ),
            ),

          // Red / Green Flags
          if (widget.highlights.redFlags.isNotEmpty ||
              widget.highlights.greenFlags.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: DSSpacing.md),

            // Red Flags
            ...widget.highlights.redFlags.map((flag) => Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: colors.error, size: 16),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: Text(
                          flag.text,
                          style: typography.bodySmall
                              .copyWith(color: colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )),

            // Green Flags
            ...widget.highlights.greenFlags.map((flag) => Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: colors.success, size: 16),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: Text(
                          flag.text,
                          style: typography.bodySmall
                              .copyWith(color: colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
