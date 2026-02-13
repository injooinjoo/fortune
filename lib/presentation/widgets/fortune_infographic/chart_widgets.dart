import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'painters.dart';

/// Chart widgets for fortune infographic
class ChartWidgets {
  ChartWidgets._();

  /// Radar chart with real score data
  static Widget buildRadarChart({
    required Map<String, int> scores,
    double? size,
    Color? primaryColor,
  }) {
    return Builder(
      builder: (context) {
        final isDark = context.isDark;

        return Container(
          height: size ?? 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? DSColors.surfaceSecondary : DSColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? DSColors.border : DSColors.borderDark,
            ),
          ),
          child: scores.isNotEmpty ?
            CustomPaint(
              size: Size((size ?? 200) - 32, (size ?? 200) - 32),
              painter: RadarChartPainter(
                scores: scores,
                isDark: isDark,
                primaryColor: primaryColor ?? (isDark ? DSColors.accent : DSColors.accentDark),
              ),
            ) :
            Center(
              child: Text(
                '레이더 차트 준비 중...',
                style: TextStyle(
                  color: isDark ? DSColors.textTertiary : DSColors.textSecondaryDark,
                ),
              ),
            ),
        );
      },
    );
  }

  /// Timeline chart with real hourly data
  static Widget buildTimelineChart({
    required List<int> hourlyScores,
    required int currentHour,
    required double height,
  }) {
    return _InteractiveTimelineChart(
      hourlyScores: hourlyScores,
      currentHour: currentHour,
      height: height,
    );
  }
}

/// Interactive Timeline Chart with touch support
class _InteractiveTimelineChart extends StatefulWidget {
  final List<int> hourlyScores;
  final int currentHour;
  final double height;

  const _InteractiveTimelineChart({
    required this.hourlyScores,
    required this.currentHour,
    required this.height,
  });

  @override
  State<_InteractiveTimelineChart> createState() => _InteractiveTimelineChartState();
}

class _InteractiveTimelineChartState extends State<_InteractiveTimelineChart> {
  int? _touchedHour;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final displayHour = _touchedHour ?? widget.currentHour;
    final displayScore = widget.hourlyScores[displayHour];

    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? DSColors.border : DSColors.borderDark,
        ),
      ),
      child: Column(
        children: [
          // Chart header with current/touched hour indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _touchedHour != null ? '$displayHour시' : '현재 $displayHour시',
                style: TextStyle(
                  color: isDark ? DSColors.textPrimary : DSColors.textPrimaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$displayScore점',
                style: TextStyle(
                  color: isDark ? DSColors.accent : DSColors.accentDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Timeline chart with touch detection
          Expanded(
            child: GestureDetector(
              onTapDown: (details) {
                _handleTouch(details.localPosition);
              },
              onPanUpdate: (details) {
                _handleTouch(details.localPosition);
              },
              onPanEnd: (_) {
                setState(() {
                  _touchedHour = null;
                });
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: TimelineChartPainter(
                  hourlyScores: widget.hourlyScores,
                  currentHour: _touchedHour ?? widget.currentHour,
                  isDark: isDark,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Time labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < 24; i += 6)
                Text(
                  '${i.toString().padLeft(2, '0')}:00',
                  style: TextStyle(
                    color: isDark ? DSColors.textTertiary : DSColors.textSecondaryDark,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleTouch(Offset position) {
    // Get the chart area dimensions (excluding padding)
    const padding = 16.0 + 8.0; // Container padding + chart internal padding
    final chartWidth = MediaQuery.of(context).size.width - (padding * 2);

    // Calculate which hour was touched
    final relativeX = position.dx - 8.0; // Internal chart padding
    final hourIndex = ((relativeX / chartWidth) * widget.hourlyScores.length).round();

    if (hourIndex >= 0 && hourIndex < widget.hourlyScores.length) {
      setState(() {
        _touchedHour = hourIndex;
      });
    }
  }
}
