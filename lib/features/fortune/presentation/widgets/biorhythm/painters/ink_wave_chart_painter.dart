import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../../core/design_system/tokens/ds_biorhythm_colors.dart';
import '../../../../../../core/theme/font_config.dart';

/// Ink wash painting style chart painter for biorhythm visualization
///
/// Replaces fl_chart with traditional Korean ink wash (수묵화) aesthetic:
/// - Brush stroke line thickness variation
/// - Ink bleed effects at endpoints
/// - Dotted ink wash guide lines
/// - Seal stamp (낙관) style data points
class InkWaveChartPainter extends CustomPainter {
  final List<double> physicalData;  // -100 to 100
  final List<double> emotionalData;
  final List<double> intellectualData;
  final double animationProgress;   // 0.0 to 1.0
  final bool isDark;
  final List<String> dayLabels;

  InkWaveChartPainter({
    required this.physicalData,
    required this.emotionalData,
    required this.intellectualData,
    this.animationProgress = 1.0,
    this.isDark = false,
    this.dayLabels = const ['오늘', '내일', '모레', '3일후', '4일후', '5일후', '6일후'],
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Ensure minimum size to prevent negative chart area
    if (size.width < 100 || size.height < 100) return;

    // 명확한 마진 설정 (점수/라벨 겹침 방지)
    const leftMargin = 36.0;  // Y축 라벨용
    const topMargin = 10.0;   // 상단 여백
    const rightMargin = 20.0; // 우측 라벨 공간
    const bottomMargin = 36.0; // X축 라벨용 (legend는 WeeklyForecastHeader에 있음)

    final chartArea = Rect.fromLTWH(
      leftMargin,
      topMargin,
      size.width - leftMargin - rightMargin,
      size.height - topMargin - bottomMargin,
    );

    // Additional safety check
    if (chartArea.width <= 0 || chartArea.height <= 0) return;

    // 1. Draw ink wash guide lines (담묵 가이드)
    _drawGuideLines(canvas, chartArea);

    // 2. Draw rhythm curves with brush stroke effect
    if (animationProgress > 0) {
      _drawRhythmCurve(
        canvas, chartArea, physicalData,
        DSBiorhythmColors.getPhysical(isDark),
        animationProgress,
      );
      _drawRhythmCurve(
        canvas, chartArea, emotionalData,
        DSBiorhythmColors.getEmotional(isDark),
        animationProgress,
      );
      _drawRhythmCurve(
        canvas, chartArea, intellectualData,
        DSBiorhythmColors.getIntellectual(isDark),
        animationProgress,
      );
    }

    // 3. Draw data points (seal stamp style)
    if (animationProgress >= 0.8) {
      _drawDataPoints(canvas, chartArea, physicalData, DSBiorhythmColors.getPhysical(isDark));
      _drawDataPoints(canvas, chartArea, emotionalData, DSBiorhythmColors.getEmotional(isDark));
      _drawDataPoints(canvas, chartArea, intellectualData, DSBiorhythmColors.getIntellectual(isDark));
    }

    // 4. Draw Y axis labels
    _drawYAxisLabels(canvas, chartArea);

    // 5. Draw day labels (X axis)
    _drawDayLabels(canvas, chartArea);

    // Legend는 WeeklyForecastHeader에서 표시하므로 여기서는 생략
  }

  void _drawGuideLines(Canvas canvas, Rect chartArea) {
    final guideColor = DSBiorhythmColors.getInkWashGuide(isDark);
    final paint = Paint()
      ..color = guideColor.withValues(alpha: 0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Horizontal guide lines at 0, 25, 50, 75, 100
    final yPositions = [0.0, 0.25, 0.5, 0.75, 1.0];
    for (final yRatio in yPositions) {
      final y = chartArea.top + chartArea.height * (1 - yRatio);

      // Draw dotted line (담묵 점선)
      final path = Path();
      const dashWidth = 6.0;
      const dashSpace = 4.0;
      var startX = chartArea.left;

      while (startX < chartArea.right) {
        path.moveTo(startX, y);
        path.lineTo(math.min(startX + dashWidth, chartArea.right), y);
        startX += dashWidth + dashSpace;
      }

      canvas.drawPath(path, paint);
    }

    // Vertical guide lines for each day
    final dayCount = dayLabels.length;
    for (var i = 0; i < dayCount; i++) {
      final x = chartArea.left + (chartArea.width / (dayCount - 1)) * i;

      // Subtle vertical dotted lines
      final path = Path();
      const dashWidth = 4.0;
      const dashSpace = 6.0;
      var startY = chartArea.top;

      while (startY < chartArea.bottom) {
        path.moveTo(x, startY);
        path.lineTo(x, math.min(startY + dashWidth, chartArea.bottom));
        startY += dashWidth + dashSpace;
      }

      canvas.drawPath(path, paint..color = guideColor.withValues(alpha: 0.2));
    }
  }

  void _drawRhythmCurve(
    Canvas canvas,
    Rect chartArea,
    List<double> data,
    Color color,
    double progress,
  ) {
    if (data.isEmpty) return;

    // Check for invalid chart area
    if (chartArea.width <= 0 || chartArea.height <= 0) return;

    final points = <Offset>[];
    final dayCount = data.length;

    // Prevent division by zero
    if (dayCount < 2) return;

    for (var i = 0; i < dayCount; i++) {
      final x = chartArea.left + (chartArea.width / (dayCount - 1)) * i;
      // Convert 0~100 to 0~1 range, then to chart coordinates
      // Clamp values to prevent overflow
      final clampedValue = data[i].clamp(0.0, 100.0);
      final normalizedValue = clampedValue / 100;
      final y = chartArea.bottom - (chartArea.height * normalizedValue);
      points.add(Offset(x, y));
    }

    if (points.length < 2) return;

    // Create smooth bezier curve path
    final path = _createSmoothPath(points, progress);

    // Draw main stroke with brush effect (varying thickness)
    _drawBrushStroke(canvas, path, color, progress);

    // Draw ink bleed effect at curve ends
    if (progress >= 0.9) {
      _drawInkBleedEffect(canvas, points.first, color);
      _drawInkBleedEffect(canvas, points.last, color);
    }
  }

  Path _createSmoothPath(List<Offset> points, double progress) {
    final path = Path();

    if (points.isEmpty) return path;

    path.moveTo(points.first.dx, points.first.dy);

    // Calculate the number of points to draw based on progress
    final pointsToDraw = (points.length * progress).ceil();

    for (var i = 0; i < pointsToDraw - 1; i++) {
      final current = points[i];
      final next = points[math.min(i + 1, points.length - 1)];

      // Calculate control points for smooth curve
      final controlPoint1 = Offset(
        current.dx + (next.dx - current.dx) / 3,
        current.dy,
      );
      final controlPoint2 = Offset(
        current.dx + (next.dx - current.dx) * 2 / 3,
        next.dy,
      );

      // For the last segment, interpolate based on remaining progress
      if (i == pointsToDraw - 2 && progress < 1.0) {
        final segmentProgress = (progress * points.length) - i;
        final endPoint = Offset(
          current.dx + (next.dx - current.dx) * segmentProgress,
          current.dy + (next.dy - current.dy) * segmentProgress,
        );
        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx * segmentProgress, controlPoint2.dy,
          endPoint.dx, endPoint.dy,
        );
      } else {
        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          next.dx, next.dy,
        );
      }
    }

    return path;
  }

  void _drawBrushStroke(Canvas canvas, Path path, Color color, double progress) {
    // Draw multiple layers for brush stroke effect

    // Base shadow layer (ink bleed simulation)
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.1 * progress)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Main stroke layer
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.8 * progress)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Highlight layer (ink shine)
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.3 * progress)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawInkBleedEffect(Canvas canvas, Offset point, Color color) {
    // Subtle ink bleed at endpoints
    final bleedPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(point, 8, bleedPaint);
  }

  void _drawDataPoints(Canvas canvas, Rect chartArea, List<double> data, Color color) {
    final dayCount = data.length;

    // Prevent division by zero and invalid state
    if (dayCount < 2 || chartArea.width <= 0 || chartArea.height <= 0) return;

    for (var i = 0; i < dayCount; i++) {
      final x = chartArea.left + (chartArea.width / (dayCount - 1)) * i;
      // Convert 0~100 to 0~1 range (matching Y-axis labels)
      final clampedValue = data[i].clamp(0.0, 100.0);
      final normalizedValue = clampedValue / 100;
      final y = chartArea.bottom - (chartArea.height * normalizedValue);
      final point = Offset(x, y);

      // Seal stamp style point (낙관 스타일)
      // Outer ring
      canvas.drawCircle(
        point,
        6,
        Paint()
          ..color = color.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill,
      );

      // Inner solid circle
      canvas.drawCircle(
        point,
        4,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );

      // Highlight dot
      canvas.drawCircle(
        point.translate(-1, -1),
        1.5,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _drawYAxisLabels(Canvas canvas, Rect chartArea) {
    final textColor = isDark
        ? DSBiorhythmColors.hanjiCream.withValues(alpha: 0.7)
        : DSBiorhythmColors.inkBleed.withValues(alpha: 0.6);

    final labels = ['0', '25', '50', '75', '100'];
    final yPositions = [1.0, 0.75, 0.5, 0.25, 0.0];

    for (var i = 0; i < labels.length; i++) {
      final y = chartArea.top + chartArea.height * yPositions[i];

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: textColor,
            fontSize: FontConfig.captionLarge,
            fontFamily: FontConfig.primary,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(chartArea.left - textPainter.width - 8, y - textPainter.height / 2),
      );
    }
  }

  void _drawDayLabels(Canvas canvas, Rect chartArea) {
    final textColor = isDark
        ? DSBiorhythmColors.hanjiCream.withValues(alpha: 0.8)
        : DSBiorhythmColors.inkBleed.withValues(alpha: 0.7);

    final dayCount = dayLabels.length;

    for (var i = 0; i < dayCount; i++) {
      final x = chartArea.left + (chartArea.width / (dayCount - 1)) * i;

      final textPainter = TextPainter(
        text: TextSpan(
          text: dayLabels[i],
          style: TextStyle(
            color: textColor,
            fontSize: FontConfig.captionLarge,
            fontFamily: FontConfig.primary,
            fontWeight: i == 0 ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, chartArea.bottom + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant InkWaveChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
           oldDelegate.isDark != isDark ||
           oldDelegate.physicalData != physicalData ||
           oldDelegate.emotionalData != emotionalData ||
           oldDelegate.intellectualData != intellectualData;
  }
}

/// Animated wrapper for InkWaveChartPainter
class AnimatedInkWaveChart extends StatefulWidget {
  final List<double> physicalData;
  final List<double> emotionalData;
  final List<double> intellectualData;
  final bool isDark;
  final Duration duration;
  final List<String>? dayLabels;

  const AnimatedInkWaveChart({
    super.key,
    required this.physicalData,
    required this.emotionalData,
    required this.intellectualData,
    this.isDark = false,
    this.duration = const Duration(milliseconds: 1200),
    this.dayLabels,
  });

  @override
  State<AnimatedInkWaveChart> createState() => _AnimatedInkWaveChartState();
}

class _AnimatedInkWaveChartState extends State<AnimatedInkWaveChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: InkWaveChartPainter(
            physicalData: widget.physicalData,
            emotionalData: widget.emotionalData,
            intellectualData: widget.intellectualData,
            animationProgress: _animation.value,
            isDark: widget.isDark,
            dayLabels: widget.dayLabels ?? const ['오늘', '내일', '모레', '3일후', '4일후', '5일후', '6일후'],
          ),
          size: Size.infinite,
        );
      },
    );
  }
}
