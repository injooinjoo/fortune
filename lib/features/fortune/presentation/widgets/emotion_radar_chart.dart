import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/toss_design_system.dart';


class EmotionRadarChart extends StatelessWidget {
  final Map<String, double> emotions;
  final double size;
  final Color primaryColor;
  final Color backgroundColor;

  const EmotionRadarChart({
    Key? key,
    required this.emotions,
    this.size = 200,
    this.primaryColor = TossDesignSystem.purple,
    this.backgroundColor = TossDesignSystem.gray200}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RadarChartPainter(
        emotions: emotions,
        primaryColor: primaryColor,
        backgroundColor: backgroundColor));
  }
}

class _RadarChartPainter extends CustomPainter {
  final Map<String, double> emotions;
  final Color primaryColor;
  final Color backgroundColor;

  _RadarChartPainter({
    required this.emotions,
    required this.primaryColor,
    required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;
    final angle = (2 * math.pi) / emotions.length;

    // Draw background circles
    final bgPaint = Paint()
      ..color = backgroundColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
     
   
    ..strokeWidth = 1;

    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(center, radius * (i / 5), bgPaint);
    }

    // Draw axes
    final axisPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    emotions.keys.toList().asMap().forEach((index, key) {
      final x = center.dx + radius * math.cos(angle * index - math.pi / 2);
      final y = center.dy + radius * math.sin(angle * index - math.pi / 2);
      canvas.drawLine(center, Offset(x, y), axisPaint);

      // Draw labels
      final textPainter = TextPainter(
        text: TextSpan(
          text: _getEmotionLabel(key),
          style: const TextStyle(fontSize: 12, color: TossDesignSystem.black)),
        textDirection: TextDirection.ltr);
      textPainter.layout();

      final labelOffset = Offset(
        x - textPainter.width / 2,
        y - textPainter.height / 2
      );

      // 라벨 위치를 더 정확하게 계산하여 가운데 정렬
      double adjustedX = x;
      double adjustedY = y;

      // 각 방향별로 라벨 위치 조정
      if (x > center.dx + 5) {
        // 오른쪽
        adjustedX = x + 15;
        adjustedY = y - textPainter.height / 2;
      } else if (x < center.dx - 5) {
        // 왼쪽
        adjustedX = x - textPainter.width - 15;
        adjustedY = y - textPainter.height / 2;
      } else {
        // 위/아래 (중앙)
        adjustedX = x - textPainter.width / 2;
        if (y < center.dy) {
          // 위쪽
          adjustedY = y - textPainter.height - 10;
        } else {
          // 아래쪽
          adjustedY = y + 10;
        }
      }

      textPainter.paint(canvas, Offset(adjustedX, adjustedY));
    });

    // Draw data polygon
    final dataPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final dataStrokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    emotions.values.toList().asMap().forEach((index, value) {
      final normalizedValue = value / 100;
      final x = center.dx + radius * normalizedValue * math.cos(angle * index - math.pi / 2);
      final y = center.dy + radius * normalizedValue * math.sin(angle * index - math.pi / 2);

      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw points
      canvas.drawCircle(Offset(x, y), 4, dataStrokePaint);
    });

    path.close();
    canvas.drawPath(path, dataPaint);
    canvas.drawPath(path, dataStrokePaint);
  }

  String _getEmotionLabel(String key) {
    final labels = {
      'healing': '치유',
      'acceptance': '수용',
      'growth': '성장',
      'peace': '평화',
      'hope': '희망',
      'strength': '강인함'};
    return labels[key] ?? key;
  }

  @override
  bool shouldRepaint(_RadarChartPainter oldDelegate) {
    return oldDelegate.emotions != emotions;
  }
}