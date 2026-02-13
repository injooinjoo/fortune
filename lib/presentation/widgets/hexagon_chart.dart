import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import 'dart:math' as math;

class HexagonChart extends StatelessWidget {
  final Map<String, int> scores;
  final double size;
  final Color? primaryColor;
  final Color? backgroundColor;
  final TextStyle? labelStyle;
  final bool showValues;
  final bool animate;

  const HexagonChart(
      {super.key,
      required this.scores,
      this.size = 200,
      this.primaryColor,
      this.backgroundColor,
      this.labelStyle,
      this.showValues = true,
      this.animate = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePrimaryColor = primaryColor ?? theme.primaryColor;
    final effectiveBackgroundColor = backgroundColor ??
        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1);
    final effectiveLabelStyle = labelStyle ??
        Theme.of(context).textTheme.labelSmall ??
        context.labelMedium;

    return SizedBox(
        width: size * 1.5,
        height: size * 1.5,
        child: CustomPaint(
            painter: HexagonChartPainter(
                scores: scores,
                primaryColor: effectivePrimaryColor,
                backgroundColor: effectiveBackgroundColor,
                labelStyle: effectiveLabelStyle,
                showValues: showValues)));
  }
}

class HexagonChartPainter extends CustomPainter {
  final Map<String, int> scores;
  final Color primaryColor;
  final Color backgroundColor;
  final TextStyle labelStyle;
  final bool showValues;

  HexagonChartPainter(
      {required this.scores,
      required this.primaryColor,
      required this.backgroundColor,
      required this.labelStyle,
      required this.showValues});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw background hexagon grid
    _drawBackgroundGrid(canvas, center, radius, paint);

    // Draw data polygon
    _drawDataPolygon(canvas, center, radius);

    // Draw labels
    _drawLabels(canvas, center, radius);
  }

  void _drawBackgroundGrid(
      Canvas canvas, Offset center, double radius, Paint paint) {
    paint.color = backgroundColor.withValues(alpha: 0.3);

    // Draw multiple hexagon layers
    for (int i = 1; i <= 5; i++) {
      final layerRadius = radius * (i / 5);
      _drawHexagon(canvas, center, layerRadius, paint);
    }

    // Draw axes
    paint.color = backgroundColor.withValues(alpha: 0.5);
    final labels = scores.keys.toList();
    for (int i = 0; i < labels.length; i++) {
      final angle = (i * 2 * math.pi / labels.length) - math.pi / 2;
      final endPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, endPoint, paint);
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final labels = scores.keys.toList();

    for (int i = 0; i <= labels.length; i++) {
      final angle = (i * 2 * math.pi / labels.length) - math.pi / 2;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawDataPolygon(Canvas canvas, Offset center, double radius) {
    final path = Path();
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withValues(alpha: 0.3);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = primaryColor;

    final labels = scores.keys.toList();
    final points = <Offset>[];

    for (int i = 0; i <= labels.length; i++) {
      final index = i % labels.length;
      final score = scores[labels[index]] ?? 0;
      final angle = (index * 2 * math.pi / labels.length) - math.pi / 2;
      // 점수 반영 개선: 최소값 보장 및 더 정확한 스케일링
      final normalizedScore = score.clamp(0, 100);
      final distance = radius * (normalizedScore / 100).clamp(0.1, 1.0);
      final point = Offset(center.dx + distance * math.cos(angle),
          center.dy + distance * math.sin(angle));

      points.add(point);

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    // Fill the polygon
    canvas.drawPath(path, paint);

    // Draw the stroke
    canvas.drawPath(path, strokePaint);

    // Draw dots at vertices
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor;

    for (final point in points.take(labels.length)) {
      canvas.drawCircle(point, 5, dotPaint);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    final labels = scores.keys.toList();
    final textPainter = TextPainter(
        textDirection: TextDirection.ltr, textAlign: TextAlign.center);

    for (int i = 0; i < labels.length; i++) {
      final angle = (i * 2 * math.pi / labels.length) - math.pi / 2;
      final labelRadius = radius + 35; // 여백 증가
      final labelCenter = Offset(center.dx + labelRadius * math.cos(angle),
          center.dy + labelRadius * math.sin(angle));

      // Draw label with improved centering
      textPainter.text = TextSpan(text: labels[i], style: labelStyle);
      textPainter.layout();

      // 텍스트 가운데 정렬 개선
      final offset = Offset(labelCenter.dx - textPainter.width / 2,
          labelCenter.dy - textPainter.height / 2);
      textPainter.paint(canvas, offset);

      // Draw value if enabled with better positioning
      if (showValues) {
        final score = scores[labels[i]] ?? 0;
        textPainter.text = TextSpan(
            text: '$score',
            style: labelStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: (labelStyle.fontSize ?? 12) * 0.9,
                color: primaryColor));
        textPainter.layout();

        // 점수 텍스트도 정확히 가운데 정렬
        final valueOffset = Offset(labelCenter.dx - textPainter.width / 2,
            labelCenter.dy - textPainter.height / 2 + 18);
        textPainter.paint(canvas, valueOffset);
      }
    }
  }

  @override
  bool shouldRepaint(HexagonChartPainter oldDelegate) {
    return oldDelegate.scores != scores ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
