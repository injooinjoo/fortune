import 'package:flutter/material.dart';

class FortuneCompassIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const FortuneCompassIcon({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.primary;
    
    return CustomPaint(
      size: Size(size, size),
      painter: FortuneCompassPainter(color: iconColor),
    );
  }
}

class FortuneCompassPainter extends CustomPainter {
  final Color color;

  FortuneCompassPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
     
   
    ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.4; // 10/24 * size

    // Outer circle - thicker and more prominent
    paint
      ..strokeWidth = 2
     
   
    ..color = color.withValues(alpha: 0.4);
    canvas.drawCircle(center, radius, paint);

    // Reset stroke width for other elements
    paint
      ..strokeWidth = 1.5
     
   
    ..color = color;

    // Top line
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, 0),
      paint
    );

    // Bottom line
    canvas.drawLine(
      Offset(center.dx, center.dy + radius),
      Offset(center.dx, size.height),
      paint
    );

    // Right line
    canvas.drawLine(
      Offset(center.dx + radius, center.dy),
      Offset(size.width, center.dy),
      paint
    );

    // Left line
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(0, center.dy),
      paint
    );

    // Diagonal lines
    final diagonalOffset = radius * 0.707; // cos(45°) ≈ 0.707

    // NE
    canvas.drawLine(
      Offset(center.dx + diagonalOffset * 0.536, center.dy - diagonalOffset * 0.536),
      Offset(center.dx + diagonalOffset * 1.2, center.dy - diagonalOffset * 1.2),
      paint
    );

    // SW
    canvas.drawLine(
      Offset(center.dx - diagonalOffset * 0.536, center.dy + diagonalOffset * 0.536),
      Offset(center.dx - diagonalOffset * 1.2, center.dy + diagonalOffset * 1.2),
      paint
    );

    // NW
    canvas.drawLine(
      Offset(center.dx - diagonalOffset * 0.536, center.dy - diagonalOffset * 0.536),
      Offset(center.dx - diagonalOffset * 1.2, center.dy - diagonalOffset * 1.2),
      paint
    );

    // SE
    canvas.drawLine(
      Offset(center.dx + diagonalOffset * 0.536, center.dy + diagonalOffset * 0.536),
      Offset(center.dx + diagonalOffset * 1.2, center.dy + diagonalOffset * 1.2),
      paint
    );

    // Central star/sparkle
    paint
      ..style = PaintingStyle.fill
     
   
    ..color = color.withValues(alpha: 0.8);

    final starPath = Path();
    final starSize = size.width / 24 * 2.5; // Scaled star size
    
    // Create star path
    starPath.moveTo(center.dx, center.dy - starSize);
    starPath.lineTo(center.dx + starSize * 0.3, center.dy - starSize * 0.3);
    starPath.lineTo(center.dx + starSize, center.dy);
    starPath.lineTo(center.dx + starSize * 0.3, center.dy + starSize * 0.3);
    starPath.lineTo(center.dx, center.dy + starSize);
    starPath.lineTo(center.dx - starSize * 0.3, center.dy + starSize * 0.3);
    starPath.lineTo(center.dx - starSize, center.dy);
    starPath.lineTo(center.dx - starSize * 0.3, center.dy - starSize * 0.3);
    starPath.close();

    canvas.drawPath(starPath, paint);
  }

  @override
  bool shouldRepaint(FortuneCompassPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}