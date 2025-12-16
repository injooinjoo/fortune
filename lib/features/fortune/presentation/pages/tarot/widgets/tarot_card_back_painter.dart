import 'package:flutter/material.dart';
import 'dart:math' as dart_math;

/// 타로 카드 뒷면 그리기 위한 CustomPainter
class TarotCardBackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.3);

    final center = Offset(size.width / 2, size.height / 2);

    // 중앙 별 그리기
    _drawStar(canvas, center, size.width * 0.15, paint);

    // 주변 별들 그리기
    for (int i = 0; i < 6; i++) {
      final angle = i * 3.14159 / 3;
      final starPos = Offset(
        center.dx + size.width * 0.25 * (angle.cos()),
        center.dy + size.width * 0.25 * (angle.sin()),
      );
      _drawStar(canvas, starPos, size.width * 0.08, paint);
    }

    // 테두리 패턴
    final borderRect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.05,
      size.width * 0.8,
      size.height * 0.9,
    );
    canvas.drawRect(borderRect, paint);

    final innerRect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.08,
      size.width * 0.7,
      size.height * 0.84,
    );
    paint.strokeWidth = 0.5;
    canvas.drawRect(innerRect, paint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const angle = -3.14159 / 2;

    for (int i = 0; i < 5; i++) {
      final outerAngle = angle + i * 2 * 3.14159 / 5;
      final outerX = center.dx + radius * outerAngle.cos();
      final outerY = center.dy + radius * outerAngle.sin();

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }

      final innerRadius = radius * 0.4;
      final innerAngle = angle + (i * 2 + 1) * 3.14159 / 5;
      final innerX = center.dx + innerRadius * innerAngle.cos();
      final innerY = center.dy + innerRadius * innerAngle.sin();
      path.lineTo(innerX, innerY);
    }

    path.close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Math extensions
extension on double {
  double cos() => dart_math.cos(this);
  double sin() => dart_math.sin(this);
}
