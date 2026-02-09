import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/ds_extensions.dart';
import '../../tokens/ds_colors.dart';

/// Traditional Korean endless knot (吉祥結, 길상결) loading indicator
///
/// The endless knot is a traditional symbol representing
/// eternal love, friendship, and good fortune.
///
/// Usage:
/// ```dart
/// TraditionalKnotIndicator(
///   size: 32,
///   color: DSColors.textPrimary,
/// )
/// ```
class TraditionalKnotIndicator extends StatefulWidget {
  /// Size of the knot indicator
  final double size;

  /// Color of the knot (defaults to ink color)
  final Color? color;

  /// Animation duration for one full rotation
  final Duration duration;

  const TraditionalKnotIndicator({
    super.key,
    this.size = 32,
    this.color,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<TraditionalKnotIndicator> createState() =>
      _TraditionalKnotIndicatorState();
}

class _TraditionalKnotIndicatorState extends State<TraditionalKnotIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final knotColor = widget.color ?? DSColors.getTextPrimary(brightness);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _EndlessKnotPainter(
              color: knotColor,
            ),
          ),
        );
      },
    );
  }
}

/// CustomPainter for drawing the endless knot pattern
class _EndlessKnotPainter extends CustomPainter {
  final Color color;

  _EndlessKnotPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Draw endless knot (simplified version - interlocking loops)
    _drawEndlessKnot(canvas, center, radius, paint);
  }

  void _drawEndlessKnot(
      Canvas canvas, Offset center, double radius, Paint paint) {
    // The endless knot consists of interlocking loops
    // Simplified representation with 4 overlapping curved sections

    final path = Path();

    // Outer boundary points
    final top = Offset(center.dx, center.dy - radius);
    final bottom = Offset(center.dx, center.dy + radius);
    final left = Offset(center.dx - radius, center.dy);
    final right = Offset(center.dx + radius, center.dy);

    // Inner cross points
    final innerRadius = radius * 0.4;
    final innerTop = Offset(center.dx, center.dy - innerRadius);
    final innerBottom = Offset(center.dx, center.dy + innerRadius);
    final innerLeft = Offset(center.dx - innerRadius, center.dy);
    final innerRight = Offset(center.dx + innerRadius, center.dy);

    // Draw the main knot pattern (4 interlocking loops)
    // Loop 1: Top-Left
    path.moveTo(top.dx, top.dy);
    path.quadraticBezierTo(
      center.dx - radius * 0.8,
      center.dy - radius * 0.8,
      left.dx,
      left.dy,
    );
    path.quadraticBezierTo(
      center.dx - radius * 0.5,
      center.dy - radius * 0.2,
      innerTop.dx,
      innerTop.dy,
    );

    // Loop 2: Left-Bottom
    path.moveTo(left.dx, left.dy);
    path.quadraticBezierTo(
      center.dx - radius * 0.8,
      center.dy + radius * 0.8,
      bottom.dx,
      bottom.dy,
    );
    path.quadraticBezierTo(
      center.dx - radius * 0.2,
      center.dy + radius * 0.5,
      innerLeft.dx,
      innerLeft.dy,
    );

    // Loop 3: Bottom-Right
    path.moveTo(bottom.dx, bottom.dy);
    path.quadraticBezierTo(
      center.dx + radius * 0.8,
      center.dy + radius * 0.8,
      right.dx,
      right.dy,
    );
    path.quadraticBezierTo(
      center.dx + radius * 0.5,
      center.dy + radius * 0.2,
      innerBottom.dx,
      innerBottom.dy,
    );

    // Loop 4: Right-Top
    path.moveTo(right.dx, right.dy);
    path.quadraticBezierTo(
      center.dx + radius * 0.8,
      center.dy - radius * 0.8,
      top.dx,
      top.dy,
    );
    path.quadraticBezierTo(
      center.dx + radius * 0.2,
      center.dy - radius * 0.5,
      innerRight.dx,
      innerRight.dy,
    );

    // Inner cross connections
    path.moveTo(innerTop.dx, innerTop.dy);
    path.lineTo(innerBottom.dx, innerBottom.dy);

    path.moveTo(innerLeft.dx, innerLeft.dy);
    path.lineTo(innerRight.dx, innerRight.dy);

    canvas.drawPath(path, paint);

    // Draw center dot
    canvas.drawCircle(
      center,
      radius * 0.12,
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _EndlessKnotPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Simplified traditional pattern indicator with rotating arcs
/// Alternative to the complex endless knot
class TraditionalPatternIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;

  const TraditionalPatternIndicator({
    super.key,
    this.size = 32,
    this.color,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<TraditionalPatternIndicator> createState() =>
      _TraditionalPatternIndicatorState();
}

class _TraditionalPatternIndicatorState
    extends State<TraditionalPatternIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final patternColor = widget.color ?? DSColors.getTextPrimary(brightness);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _CloudPatternPainter(
            color: patternColor,
            rotation: _controller.value * 2 * math.pi,
          ),
        );
      },
    );
  }
}

/// Cloud pattern spinner (구름무늬)
class _CloudPatternPainter extends CustomPainter {
  final Color color;
  final double rotation;

  _CloudPatternPainter({
    required this.color,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;

    final radius = size.width * 0.38;

    // Draw 4 curved cloud segments
    for (var i = 0; i < 4; i++) {
      final startAngle = (i * math.pi / 2) - math.pi / 4;
      final sweepAngle = math.pi / 3;

      // Opacity varies based on position
      final opacity = 0.3 + (0.7 * ((i + 1) / 4));
      paint.color = color.withValues(alpha: opacity);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CloudPatternPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.rotation != rotation;
  }
}
