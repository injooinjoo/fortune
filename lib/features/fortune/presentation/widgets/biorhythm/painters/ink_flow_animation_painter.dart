import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../../core/design_system/tokens/ds_biorhythm_colors.dart';

/// Ink flow animation painter for loading screens
///
/// Creates a mesmerizing ink spreading effect on hanji paper:
/// - Three colors (Physical, Emotional, Intellectual) spread sequentially
/// - Organic, water-like spreading motion
/// - Subtle color blending at overlaps
class InkFlowAnimationPainter extends CustomPainter {
  final double animationProgress; // 0.0 to 1.0
  final int currentPhase; // 0-2 for three rhythm colors
  final bool isDark;
  final double waveAmplitude;

  InkFlowAnimationPainter({
    required this.animationProgress,
    this.currentPhase = 0,
    this.isDark = false,
    this.waveAmplitude = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;

    // Draw ink drops for each phase
    if (currentPhase >= 0) {
      _drawInkDrop(
        canvas, center, maxRadius,
        DSBiorhythmColors.getPhysical(isDark),
        animationProgress,
        0, // offset angle
      );
    }

    if (currentPhase >= 1) {
      _drawInkDrop(
        canvas, center, maxRadius,
        DSBiorhythmColors.getEmotional(isDark),
        math.max(0, animationProgress - 0.1),
        math.pi * 2 / 3, // 120 degrees offset
      );
    }

    if (currentPhase >= 2) {
      _drawInkDrop(
        canvas, center, maxRadius,
        DSBiorhythmColors.getIntellectual(isDark),
        math.max(0, animationProgress - 0.2),
        math.pi * 4 / 3, // 240 degrees offset
      );
    }

    // Center pulse dot
    _drawCenterPulse(canvas, center, animationProgress);
  }

  void _drawInkDrop(
    Canvas canvas,
    Offset center,
    double maxRadius,
    Color color,
    double progress,
    double angleOffset,
  ) {
    if (progress <= 0) return;

    final effectiveProgress = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));

    // Calculate organic blob shape with wave distortion
    final path = Path();
    final points = <Offset>[];
    final segments = 36;
    final baseRadius = maxRadius * 0.6 * effectiveProgress;

    for (var i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * math.pi + angleOffset;

      // Organic wave distortion
      final wave1 = math.sin(angle * 3 + animationProgress * math.pi * 2) * waveAmplitude * 8;
      final wave2 = math.cos(angle * 5 - animationProgress * math.pi * 3) * waveAmplitude * 5;
      final wave3 = math.sin(angle * 2 + animationProgress * math.pi) * waveAmplitude * 3;

      final radius = baseRadius + wave1 + wave2 + wave3;

      points.add(Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      ));
    }

    if (points.isEmpty) return;

    // Create smooth blob path
    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final midX = (current.dx + next.dx) / 2;
      final midY = (current.dy + next.dy) / 2;
      path.quadraticBezierTo(current.dx, current.dy, midX, midY);
    }
    path.close();

    // Draw multiple layers for depth

    // Outer glow (very light)
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.05 * effectiveProgress)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Mid layer (medium transparency)
    final midPath = _scalePath(path, center, 0.8);
    canvas.drawPath(
      midPath,
      Paint()
        ..color = color.withValues(alpha: 0.15 * effectiveProgress)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Inner layer (more opaque)
    final innerPath = _scalePath(path, center, 0.5);
    canvas.drawPath(
      innerPath,
      Paint()
        ..color = color.withValues(alpha: 0.25 * effectiveProgress)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Core (solid center)
    final corePath = _scalePath(path, center, 0.2);
    canvas.drawPath(
      corePath,
      Paint()
        ..color = color.withValues(alpha: 0.4 * effectiveProgress)
        ..style = PaintingStyle.fill,
    );

    // Ink splatter particles
    _drawInkSplatters(canvas, center, baseRadius, color, effectiveProgress, angleOffset);
  }

  Path _scalePath(Path original, Offset center, double scale) {
    final matrix = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..scale(scale)
      ..translate(-center.dx, -center.dy);

    return original.transform(matrix.storage);
  }

  void _drawInkSplatters(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double progress,
    double angleOffset,
  ) {
    if (progress < 0.3) return;

    final splatterProgress = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);
    final random = math.Random(angleOffset.hashCode);

    // Draw small ink particles around the main drop
    for (var i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi + angleOffset + random.nextDouble() * 0.5;
      final distance = radius * (0.8 + random.nextDouble() * 0.5) * splatterProgress;
      final particleSize = (2 + random.nextDouble() * 3) * splatterProgress;

      final particlePos = Offset(
        center.dx + distance * math.cos(angle),
        center.dy + distance * math.sin(angle),
      );

      canvas.drawCircle(
        particlePos,
        particleSize,
        Paint()
          ..color = color.withValues(alpha: 0.3 * splatterProgress)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, particleSize / 2),
      );
    }
  }

  void _drawCenterPulse(Canvas canvas, Offset center, double progress) {
    final pulseSize = 8 + math.sin(progress * math.pi * 4) * 3;
    final pulseAlpha = 0.3 + math.sin(progress * math.pi * 2) * 0.2;

    final pulseColor = isDark
        ? DSBiorhythmColors.hanjiCream
        : DSBiorhythmColors.inkBleed;

    // Outer pulse ring
    canvas.drawCircle(
      center,
      pulseSize + 4,
      Paint()
        ..color = pulseColor.withValues(alpha: pulseAlpha * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Inner solid dot
    canvas.drawCircle(
      center,
      pulseSize / 2,
      Paint()
        ..color = pulseColor.withValues(alpha: pulseAlpha)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant InkFlowAnimationPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
           oldDelegate.currentPhase != currentPhase ||
           oldDelegate.isDark != isDark ||
           oldDelegate.waveAmplitude != waveAmplitude;
  }
}

/// Full-screen animated ink flow loading widget
class AnimatedInkFlowLoading extends StatefulWidget {
  final bool isDark;
  final Duration cycleDuration;
  final VoidCallback? onCycleComplete;

  const AnimatedInkFlowLoading({
    super.key,
    this.isDark = false,
    this.cycleDuration = const Duration(seconds: 3),
    this.onCycleComplete,
  });

  @override
  State<AnimatedInkFlowLoading> createState() => _AnimatedInkFlowLoadingState();
}

class _AnimatedInkFlowLoadingState extends State<AnimatedInkFlowLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentPhase = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.cycleDuration,
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentPhase = (_currentPhase + 1) % 3;
        });
        widget.onCycleComplete?.call();
        _controller.forward(from: 0);
      }
    });
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
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: InkFlowAnimationPainter(
            animationProgress: _controller.value,
            currentPhase: _currentPhase,
            isDark: widget.isDark,
            waveAmplitude: 1.0 + math.sin(_controller.value * math.pi) * 0.5,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Continuous ink ripple painter for subtle background animations
class InkRipplePainter extends CustomPainter {
  final double animationProgress;
  final Color color;
  final int rippleCount;

  InkRipplePainter({
    required this.animationProgress,
    required this.color,
    this.rippleCount = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;

    for (var i = 0; i < rippleCount; i++) {
      final rippleProgress = (animationProgress + i / rippleCount) % 1.0;
      final radius = maxRadius * rippleProgress;
      final alpha = (1.0 - rippleProgress) * 0.3;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * (1 - rippleProgress) + 0.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant InkRipplePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress;
  }
}
