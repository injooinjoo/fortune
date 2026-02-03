import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../data/models/chat_insight_result.dart';

/// 감정 변화 타임라인 카드 (sparkline + dip/spike 마커)
class TimelineCardWidget extends StatefulWidget {
  final InsightTimeline timeline;

  const TimelineCardWidget({super.key, required this.timeline});

  @override
  State<TimelineCardWidget> createState() => _TimelineCardWidgetState();
}

class _TimelineCardWidgetState extends State<TimelineCardWidget> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final points = widget.timeline.points;

    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    return DSCard.elevated(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Icon(Icons.timeline, color: colors.accent, size: 20),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '감정 변화',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // Sparkline
          Semantics(
            label: _accessibilityLabel(points),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: GestureDetector(
                onTapDown: (details) => _handleTap(details, points),
                child: CustomPaint(
                  painter: _SparklinePainter(
                    points: points,
                    selectedIndex: _selectedIndex,
                    lineColor: colors.accent,
                    negativeColor: colors.error,
                    dotColor: colors.textPrimary,
                  ),
                ),
              ),
            ),
          ),

          // 선택한 포인트 상세
          if (_selectedIndex != null && _selectedIndex! < points.length) ...[
            const SizedBox(height: DSSpacing.sm),
            _buildPointDetail(context, points[_selectedIndex!]),
          ],

          // Dips & Spikes
          if (widget.timeline.dips.isNotEmpty ||
              widget.timeline.spikes.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: DSSpacing.sm),
            ...widget.timeline.dips.map((dip) => _buildEvent(
                  context,
                  icon: Icons.arrow_downward,
                  color: colors.error,
                  event: dip,
                )),
            ...widget.timeline.spikes.map((spike) => _buildEvent(
                  context,
                  icon: Icons.arrow_upward,
                  color: colors.accent,
                  event: spike,
                )),
          ],
        ],
      ),
    );
  }

  void _handleTap(TapDownDetails details, List<TimelinePoint> points) {
    if (points.length < 2) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localX = details.localPosition.dx;
    final width = renderBox.size.width;
    final segmentWidth = width / (points.length - 1);
    final index = (localX / segmentWidth).round().clamp(0, points.length - 1);

    setState(() {
      _selectedIndex = index == _selectedIndex ? null : index;
    });
  }

  Widget _buildPointDetail(BuildContext context, TimelinePoint point) {
    final colors = context.colors;
    final typography = context.typography;
    final date =
        '${point.time.month}/${point.time.day}';
    final sentimentLabel = point.sentiment >= 0 ? '긍정적' : '부정적';

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DSRadius.sm),
      ),
      child: Text(
        '$date: ${(point.sentiment * 100).toInt()}점 ($sentimentLabel)',
        style: typography.bodySmall.copyWith(color: colors.textSecondary),
      ),
    );
  }

  Widget _buildEvent(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required TimelineEvent event,
  }) {
    final typography = context.typography;
    final colors = context.colors;
    final date = '${event.time.month}/${event.time.day}';

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: DSSpacing.xs),
          Text(date,
              style: typography.labelSmall.copyWith(color: colors.textTertiary)),
          const SizedBox(width: DSSpacing.xs),
          Expanded(
            child: Text(event.label,
                style: typography.bodySmall
                    .copyWith(color: colors.textSecondary)),
          ),
        ],
      ),
    );
  }

  String _accessibilityLabel(List<TimelinePoint> points) {
    if (points.isEmpty) return '감정 변화 데이터 없음';
    final first = points.first;
    final last = points.last;
    return '감정 변화 그래프. '
        '${first.time.month}월 ${first.time.day}일 '
        '${(first.sentiment * 100).toInt()}점에서 '
        '${last.time.month}월 ${last.time.day}일 '
        '${(last.sentiment * 100).toInt()}점으로 변화';
  }
}

class _SparklinePainter extends CustomPainter {
  final List<TimelinePoint> points;
  final int? selectedIndex;
  final Color lineColor;
  final Color negativeColor;
  final Color dotColor;

  _SparklinePainter({
    required this.points,
    this.selectedIndex,
    required this.lineColor,
    required this.negativeColor,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()..style = PaintingStyle.fill;

    final segmentWidth = size.width / (points.length - 1);
    const padding = 8.0;
    final chartHeight = size.height - padding * 2;

    for (var i = 0; i < points.length - 1; i++) {
      final x1 = i * segmentWidth;
      final x2 = (i + 1) * segmentWidth;
      final y1 = padding + (1 - (points[i].sentiment + 1) / 2) * chartHeight;
      final y2 =
          padding + (1 - (points[i + 1].sentiment + 1) / 2) * chartHeight;

      final avgSentiment = (points[i].sentiment + points[i + 1].sentiment) / 2;
      paint.color = avgSentiment >= 0 ? lineColor : negativeColor;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Draw dots
    for (var i = 0; i < points.length; i++) {
      final x = i * segmentWidth;
      final y =
          padding + (1 - (points[i].sentiment + 1) / 2) * chartHeight;

      final isSelected = i == selectedIndex;
      dotPaint.color = isSelected ? lineColor : dotColor.withValues(alpha: 0.5);
      canvas.drawCircle(Offset(x, y), isSelected ? 5.0 : 3.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.points != points;
  }
}
