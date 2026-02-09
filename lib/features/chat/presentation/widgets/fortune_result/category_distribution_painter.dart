import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';

/// 카테고리 분포 도넛 차트 페인터 (Top 3 운세)
class CategoryDistributionDonutPainter extends CustomPainter {
  final List<MapEntry<String, int>> categories;
  final double strokeWidth;

  CategoryDistributionDonutPainter({
    required this.categories,
    this.strokeWidth = 20,
  });

  // 카테고리별 색상 정의
  static const Map<String, Color> categoryColors = {
    'love': DSColors.error, // 핑크
    'money': DSColors.warning, // 노랑
    'work': DSColors.info, // 파랑
    'health': DSColors.success, // 초록
    'study': DSColors.accentSecondary, // 보라
    'total': DSColors.error, // 코랄
  };

  @override
  void paint(Canvas canvas, Size size) {
    if (categories.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 총합 계산
    final total = categories.fold<int>(0, (sum, e) => sum + e.value);
    if (total == 0) return;

    // 시작 각도 (12시 방향에서 시작)
    double startAngle = -math.pi / 2;

    // 각 카테고리별로 호 그리기
    for (final entry in categories) {
      final sweepAngle = (entry.value / total) * 2 * math.pi;

      final paint = Paint()
        ..color = categoryColors[entry.key] ?? DSColors.textTertiary
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(CategoryDistributionDonutPainter oldDelegate) {
    return oldDelegate.categories != categories ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
