import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../../core/design_system/tokens/ds_biorhythm_colors.dart';
import '../../../../../../core/theme/font_config.dart';

/// Ink brush style circular score painter
///
/// Creates a traditional Korean ink wash painting style score display:
/// - Ink wash circle outline with brush stroke effect
/// - Calligraphy style score number
/// - Subtle ink bleed decorations
class InkScoreCirclePainter extends CustomPainter {
  final int score; // 0-100
  final Color? statusColor;
  final bool isDark;
  final double animationProgress; // 0.0 to 1.0
  final bool showHanja; // Show Hanja status text

  InkScoreCirclePainter({
    required this.score,
    this.statusColor,
    this.isDark = false,
    this.animationProgress = 1.0,
    this.showHanja = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final color = statusColor ?? DSBiorhythmColors.getStatusColor(score);

    // 1. Draw ink wash background circle (subtle)
    _drawInkWashBackground(canvas, center, radius);

    // 2. Draw brush stroke circle outline
    if (animationProgress > 0.1) {
      _drawBrushStrokeCircle(canvas, center, radius, color);
    }

    // 3. Draw ink bleed decorations at compass points
    if (animationProgress > 0.5) {
      _drawInkBleedDecorations(canvas, center, radius, color);
    }

    // 4. Draw calligraphy style score number
    if (animationProgress > 0.3) {
      _drawScoreNumber(canvas, center, size);
    }

    // 5. Draw "점" label
    if (animationProgress > 0.6) {
      _drawScoreLabel(canvas, center, size);
    }
  }

  void _drawInkWashBackground(Canvas canvas, Offset center, double radius) {
    // Subtle ink wash background
    final bgColor = isDark
        ? DSBiorhythmColors.hanjiDark.withValues(alpha: 0.3)
        : DSBiorhythmColors.hanjiCream.withValues(alpha: 0.5);

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(center, radius - 4, bgPaint);
  }

  void _drawBrushStrokeCircle(Canvas canvas, Offset center, double radius, Color color) {
    // Draw circle with brush stroke effect (varying thickness)
    final segments = 60;
    final sweepAngle = 2 * math.pi * animationProgress;

    for (var i = 0; i < segments * animationProgress; i++) {
      final angle = -math.pi / 2 + (sweepAngle * i / segments);
      final nextAngle = -math.pi / 2 + (sweepAngle * (i + 1) / segments);

      // Vary stroke thickness for brush effect
      final thicknessFactor = 0.7 + 0.3 * math.sin(angle * 3);
      final strokeWidth = 3.0 * thicknessFactor;

      final startPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final endPoint = Offset(
        center.dx + radius * math.cos(nextAngle),
        center.dy + radius * math.sin(nextAngle),
      );

      canvas.drawLine(
        startPoint,
        endPoint,
        Paint()
          ..color = color.withValues(alpha: 0.7)
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }

    // Ink bleed effect at start/end points
    if (animationProgress >= 0.95) {
      final startAngle = -math.pi / 2;
      final startPoint = Offset(
        center.dx + radius * math.cos(startAngle),
        center.dy + radius * math.sin(startAngle),
      );

      // Small ink splatter at connection point
      canvas.drawCircle(
        startPoint,
        4,
        Paint()
          ..color = color.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  void _drawInkBleedDecorations(Canvas canvas, Offset center, double radius, Color color) {
    // Four small ink dots at compass points (decorative seal stamps)
    final positions = [
      Offset(center.dx, center.dy - radius - 8), // top
      Offset(center.dx + radius + 8, center.dy), // right
      Offset(center.dx, center.dy + radius + 8), // bottom
      Offset(center.dx - radius - 8, center.dy), // left
    ];

    for (var i = 0; i < positions.length; i++) {
      final alpha = (animationProgress - 0.5) * 2 * 0.3;
      if (alpha > 0) {
        // Small seal dot
        canvas.drawCircle(
          positions[i],
          2,
          Paint()
            ..color = color.withValues(alpha: alpha)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  void _drawScoreNumber(Canvas canvas, Offset center, Size size) {
    final textColor = isDark
        ? DSBiorhythmColors.hanjiCream
        : DSBiorhythmColors.inkBleed;

    // Main score number (large, calligraphy style)
    final scoreText = '$score';
    final scoreAlpha = ((animationProgress - 0.3) / 0.7).clamp(0.0, 1.0);

    final scorePainter = TextPainter(
      text: TextSpan(
        text: scoreText,
        style: TextStyle(
          color: textColor.withValues(alpha: scoreAlpha),
          fontSize: size.width * 0.35,
          fontFamily: FontConfig.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: -2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    scorePainter.layout();

    // Slight shadow for ink depth
    final shadowPainter = TextPainter(
      text: TextSpan(
        text: scoreText,
        style: TextStyle(
          color: textColor.withValues(alpha: scoreAlpha * 0.2),
          fontSize: size.width * 0.35,
          fontFamily: FontConfig.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: -2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    shadowPainter.layout();

    // Draw shadow
    shadowPainter.paint(
      canvas,
      Offset(
        center.dx - shadowPainter.width / 2 + 1,
        center.dy - shadowPainter.height / 2 - size.height * 0.08 + 1,
      ),
    );

    // Draw main text
    scorePainter.paint(
      canvas,
      Offset(
        center.dx - scorePainter.width / 2,
        center.dy - scorePainter.height / 2 - size.height * 0.08,
      ),
    );
  }

  void _drawScoreLabel(Canvas canvas, Offset center, Size size) {
    final textColor = isDark
        ? DSBiorhythmColors.hanjiCream.withValues(alpha: 0.7)
        : DSBiorhythmColors.inkBleed.withValues(alpha: 0.6);

    final labelAlpha = ((animationProgress - 0.6) / 0.4).clamp(0.0, 1.0);

    // "점" label below score
    final labelPainter = TextPainter(
      text: TextSpan(
        text: '점',
        style: TextStyle(
          color: textColor.withValues(alpha: labelAlpha),
          fontSize: size.width * 0.12,
          fontFamily: FontConfig.primary,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(
      canvas,
      Offset(
        center.dx - labelPainter.width / 2,
        center.dy + size.height * 0.12,
      ),
    );

    // Hanja status text (optional)
    if (showHanja && labelAlpha > 0.5) {
      final hanjaText = DSBiorhythmColors.getStatusHanja(score);
      final hanjaPainter = TextPainter(
        text: TextSpan(
          text: hanjaText,
          style: TextStyle(
            color: DSBiorhythmColors.getStatusColor(score).withValues(alpha: (labelAlpha - 0.5) * 2),
            fontSize: size.width * 0.08,
            fontFamily: FontConfig.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      hanjaPainter.layout();
      hanjaPainter.paint(
        canvas,
        Offset(
          center.dx - hanjaPainter.width / 2,
          center.dy + size.height * 0.22,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant InkScoreCirclePainter oldDelegate) {
    return oldDelegate.score != score ||
           oldDelegate.animationProgress != animationProgress ||
           oldDelegate.isDark != isDark ||
           oldDelegate.statusColor != statusColor;
  }
}

/// Animated wrapper for InkScoreCirclePainter
class AnimatedInkScoreCircle extends StatefulWidget {
  final int score;
  final Color? statusColor;
  final bool isDark;
  final Duration duration;
  final bool showHanja;
  final double size;

  const AnimatedInkScoreCircle({
    super.key,
    required this.score,
    this.statusColor,
    this.isDark = false,
    this.duration = const Duration(milliseconds: 1000),
    this.showHanja = true,
    this.size = 120,
  });

  @override
  State<AnimatedInkScoreCircle> createState() => _AnimatedInkScoreCircleState();
}

class _AnimatedInkScoreCircleState extends State<AnimatedInkScoreCircle>
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
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: InkScoreCirclePainter(
              score: widget.score,
              statusColor: widget.statusColor,
              isDark: widget.isDark,
              animationProgress: _animation.value,
              showHanja: widget.showHanja,
            ),
          ),
        );
      },
    );
  }
}
