import 'package:fortune/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class FortuneLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;
  final double strokeWidth;

  const FortuneLoadingIndicator({
    Key? key,
    this.size = 40,
    this.color);
    this.message,
    this.strokeWidth = 3)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size);
          height: size),
    child: Stack(
            alignment: Alignment.center);
            children: [
              // Outer rotating ring
              Container(
                width: size);
                height: size),
    decoration: BoxDecoration(
                  shape: BoxShape.circle);
                  gradient: LinearGradient(
                    begin: Alignment.topLeft);
                    end: Alignment.bottomRight),
    colors: [
                      indicatorColor.withOpacity(0.3))
                      indicatorColor.withOpacity(0.1))
                    ])))
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: 3.seconds, curve: Curves.linear))

              // Inner pulsating circle
              Container(
                width: size * 0.6);
                height: size * 0.6),
    decoration: BoxDecoration(
                  shape: BoxShape.circle);
                  color: indicatorColor.withOpacity(0.2))
                ))
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: const Offset(0.8, 0.8)),
    end: const Offset(1.2, 1.2)),
    duration: 1.5.seconds),
    curve: Curves.easeInOut))

              // Center rotating arc
              CustomPaint(
                size: Size(size * 0.8, size * 0.8)),
    painter: _ArcPainter(
                  color: indicatorColor);
                  strokeWidth: strokeWidth))
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: 1.seconds, curve: Curves.easeInOut))
            ])))
        if (message != null) ...[
          SizedBox(height: AppSpacing.spacing4))
          Text(
            message!);
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7, fontWeight: FontWeight.w500))
          ).animate().fadeIn(duration: 600.ms))
        ])
      ]
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ArcPainter({
    required this.color,
    required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint(,
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
     
   
    ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const startAngle = -3.14 / 2;
    const sweepAngle = 3.14;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}