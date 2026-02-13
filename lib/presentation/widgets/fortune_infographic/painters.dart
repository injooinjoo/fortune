import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';

/// Custom painter for drawing timeline chart with real hourly scores
class TimelineChartPainter extends CustomPainter {
  final List<int> hourlyScores;
  final int currentHour;
  final bool isDark;

  TimelineChartPainter({
    required this.hourlyScores,
    required this.currentHour,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 8.0;
    final chartWidth = size.width - (padding * 2);
    final chartHeight = size.height - (padding * 2);

    if (hourlyScores.isEmpty) return;

    // Calculate data points for the line chart
    final points = <Offset>[];
    const maxScore = 100;
    const minScore = 20;

    for (int i = 0; i < hourlyScores.length; i++) {
      final x = padding + (i / (hourlyScores.length - 1)) * chartWidth;
      final normalizedScore =
          (hourlyScores[i] - minScore) / (maxScore - minScore);
      final y = padding + chartHeight - (normalizedScore * chartHeight);
      points.add(Offset(x, y));
    }

    // Draw gradient background
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          (isDark ? DSColors.accent : DSColors.accentDark)
              .withValues(alpha: 0.1),
          (isDark ? DSColors.accent : DSColors.accentDark)
              .withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create path for the area under the curve
    final areaPath = Path();
    if (points.isNotEmpty) {
      areaPath.moveTo(points.first.dx, size.height - padding);
      for (final point in points) {
        areaPath.lineTo(point.dx, point.dy);
      }
      areaPath.lineTo(points.last.dx, size.height - padding);
      areaPath.close();
    }

    // Draw the area under the curve
    canvas.drawPath(areaPath, backgroundPaint);

    // Draw the main line
    final linePaint = Paint()
      ..color = isDark ? DSColors.accent : DSColors.accentDark
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (points.length > 1) {
      final linePath = Path();
      linePath.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        // Create smooth curves between points
        if (i < points.length - 1) {
          final cp1 = Offset(
            points[i - 1].dx + (points[i].dx - points[i - 1].dx) * 0.5,
            points[i - 1].dy,
          );
          final cp2 = Offset(
            points[i - 1].dx + (points[i].dx - points[i - 1].dx) * 0.5,
            points[i].dy,
          );
          linePath.cubicTo(
              cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
        } else {
          linePath.lineTo(points[i].dx, points[i].dy);
        }
      }
      canvas.drawPath(linePath, linePaint);
    }

    // Draw points on the line
    final pointPaint = Paint()
      ..color = isDark ? DSColors.accent : DSColors.accentDark
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = isDark ? DSColors.surfaceSecondary : DSColors.surfaceDark
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      // Draw larger point for current hour
      if (i == currentHour) {
        // Draw border
        canvas.drawCircle(point, 5, pointBorderPaint);
        // Draw center
        canvas.drawCircle(point, 3, pointPaint);

        // Draw current hour indicator line
        final indicatorPaint = Paint()
          ..color = (isDark ? DSColors.accent : DSColors.accentDark)
              .withValues(alpha: 0.3)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

        canvas.drawLine(
          Offset(point.dx, padding),
          Offset(point.dx, size.height - padding),
          indicatorPaint,
        );
      } else {
        // Draw smaller points for other hours
        canvas.drawCircle(point, 2, pointPaint);
      }
    }

    // Draw horizontal reference lines
    final gridPaint = Paint()
      ..color = (isDark ? DSColors.textTertiary : DSColors.borderDark)
          .withValues(alpha: 0.3)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw reference lines at 25%, 50%, 75% heights
    for (double ratio in [0.25, 0.5, 0.75]) {
      final y = padding + chartHeight * (1 - ratio);
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(TimelineChartPainter oldDelegate) {
    return oldDelegate.hourlyScores != hourlyScores ||
        oldDelegate.currentHour != currentHour ||
        oldDelegate.isDark != isDark;
  }
}

/// Custom painter for drawing radar chart with multiple score categories
class RadarChartPainter extends CustomPainter {
  final Map<String, int> scores;
  final bool isDark;
  final Color primaryColor;

  RadarChartPainter({
    required this.scores,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    final categories = scores.keys.toList();
    final values = scores.values.toList();
    final categoryCount = categories.length;

    if (categoryCount == 0) return;

    // Draw background grid
    final gridPaint = Paint()
      ..color = (isDark ? DSColors.textTertiary : DSColors.borderDark)
          .withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw concentric circles (grid lines)
    for (int i = 1; i <= 5; i++) {
      final gridRadius = radius * (i / 5.0);
      canvas.drawCircle(center, gridRadius, gridPaint);
    }

    // Draw category axes
    for (int i = 0; i < categoryCount; i++) {
      final angle = (i * 2 * math.pi / categoryCount) - (math.pi / 2);
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, end, gridPaint);

      // Draw category labels
      final textPainter = TextPainter(
        text: TextSpan(
          text: _getCategoryLabel(categories[i]),
          style: TextStyle(
            color: isDark ? DSColors.textTertiary : DSColors.textSecondaryDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final labelOffset = Offset(
        center.dx + (radius + 15) * math.cos(angle) - textPainter.width / 2,
        center.dy + (radius + 15) * math.sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, labelOffset);
    }

    // Draw data area
    final dataPath = Path();
    final dataPoints = <Offset>[];

    for (int i = 0; i < categoryCount; i++) {
      final score = values[i].clamp(0, 100);
      final angle = (i * 2 * math.pi / categoryCount) - (math.pi / 2);
      final distance = radius * (score / 100.0);
      final point = Offset(
        center.dx + distance * math.cos(angle),
        center.dy + distance * math.sin(angle),
      );
      dataPoints.add(point);

      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();

    // Fill the data area
    final fillPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dataPath, fillPaint);

    // Draw the data outline
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(dataPath, linePaint);

    // Draw data points
    final pointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = isDark ? DSColors.surfaceSecondary : DSColors.surfaceDark
      ..style = PaintingStyle.fill;

    for (final point in dataPoints) {
      canvas.drawCircle(point, 4, pointBorderPaint);
      canvas.drawCircle(point, 3, pointPaint);
    }
  }

  String _getCategoryLabel(String key) {
    switch (key.toLowerCase()) {
      case 'love':
      case '연애':
        return '연애';
      case 'money':
      case '금전':
        return '금전';
      case 'work':
      case 'career':
      case '직장':
        return '직장';
      case 'health':
      case '건강':
        return '건강';
      case 'study':
      case '학업':
        return '학업';
      default:
        return key.length > 2 ? key.substring(0, 2) : key;
    }
  }

  @override
  bool shouldRepaint(RadarChartPainter oldDelegate) {
    return oldDelegate.scores != scores ||
        oldDelegate.isDark != isDark ||
        oldDelegate.primaryColor != primaryColor;
  }
}
