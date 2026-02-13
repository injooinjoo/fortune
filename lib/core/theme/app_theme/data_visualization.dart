import 'package:flutter/material.dart';
import 'utils.dart';

/// Data visualization styles
@immutable
class DataVisualization {
  final List<Color> chartColors;
  final double chartLineWidth;
  final double chartPointSize;
  final bool chartShowGrid;
  final Duration chartAnimationDuration;

  const DataVisualization(
      {required this.chartColors,
      required this.chartLineWidth,
      required this.chartPointSize,
      required this.chartShowGrid,
      required this.chartAnimationDuration});

  factory DataVisualization.light() => const DataVisualization(
          chartColors: [
            Color(0xFF3B82F6),
            Color(0xFF10B981),
            Color(0xFFF59E0B),
            Color(0xFFEF4444),
            Color(0xFF8B5CF6)
          ],
          chartLineWidth: 2.0,
          chartPointSize: 4.0,
          chartShowGrid: true,
          chartAnimationDuration: Duration(milliseconds: 1000));

  factory DataVisualization.dark() => const DataVisualization(
          chartColors: [
            Color(0xFF60A5FA),
            Color(0xFF34D399),
            Color(0xFFFBBF24),
            Color(0xFFF87171),
            Color(0xFFA78BFA)
          ],
          chartLineWidth: 2.0,
          chartPointSize: 4.0,
          chartShowGrid: true,
          chartAnimationDuration: Duration(milliseconds: 1000));

  static DataVisualization lerp(
      DataVisualization a, DataVisualization b, double t) {
    return DataVisualization(
        chartColors: List.generate(a.chartColors.length,
            (i) => Color.lerp(a.chartColors[i], b.chartColors[i], t)!),
        chartLineWidth: lerpDouble(a.chartLineWidth, b.chartLineWidth, t)!,
        chartPointSize: lerpDouble(a.chartPointSize, b.chartPointSize, t)!,
        chartShowGrid: t < 0.5 ? a.chartShowGrid : b.chartShowGrid,
        chartAnimationDuration: Duration(
            milliseconds: lerpDouble(a.chartAnimationDuration.inMilliseconds,
                    b.chartAnimationDuration.inMilliseconds, t)!
                .round()));
  }
}
