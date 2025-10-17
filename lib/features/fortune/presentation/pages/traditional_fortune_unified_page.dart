import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../../../core/theme/toss_design_system.dart';
import 'package:go_router/go_router.dart';

enum TraditionalType {
  saju('정통 사주', 'saju', '사주팔자로 보는 운명', Icons.auto_stories_rounded, [Color(0xFF7C3AED), Color(0xFF6D28D9)], false),
  sajuChart('사주 차트', 'saju-chart', '시각적 사주 분석', Icons.analytics_rounded, [Color(0xFF0284C7), Color(0xFF0369A1)], false),
  tojeong('토정비결', 'tojeong', '전통 토정비결', Icons.menu_book_rounded, [Color(0xFF8B5CF6), Color(0xFF7C3AED)], true);
  
  final String label;
  final String value;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isPremium;
  
  const TraditionalType(this.label, this.value, this.description, this.icon, this.gradientColors, this.isPremium);
}

class TraditionalFortuneUnifiedPage extends ConsumerStatefulWidget {
  const TraditionalFortuneUnifiedPage({super.key});

  @override
  ConsumerState<TraditionalFortuneUnifiedPage> createState() => _TraditionalFortuneUnifiedPageState();
}

class _TraditionalFortuneUnifiedPageState extends ConsumerState<TraditionalFortuneUnifiedPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Navigate directly to the saju toss page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.pushReplacement('/traditional-saju');
    });

    // Show loading while navigating
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFEF4444),
        ),
      ),
    );
  }
}

// Custom painter for Saju background pattern
class SajuPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = TossDesignSystem.white.withValues(alpha:0.1);

    // Draw Yin-Yang pattern
    final centerX = size.width * 0.85;
    final centerY = size.height * 0.2;
    final radius = 30.0;

    // Outer circle
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // Inner circles
    paint.style = PaintingStyle.fill;
    paint.color = TossDesignSystem.white.withValues(alpha:0.15);
    canvas.drawCircle(Offset(centerX - radius / 3, centerY), radius / 3, paint);
    paint.color = TossDesignSystem.gray900.withValues(alpha:0.15);
    canvas.drawCircle(Offset(centerX + radius / 3, centerY), radius / 3, paint);
}

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for Chart preview
class ChartPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = TossDesignSystem.white.withValues(alpha:0.3);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Draw pentagon
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * 3.14159 / 180;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      
      if (i == 0) {
        paint.style = PaintingStyle.fill;
        paint.color = TossDesignSystem.white.withValues(alpha:0.2);
        canvas.drawPath(
          Path()
            ..moveTo(x, y)
            ..lineTo(center.dx + radius * 0.7 * cos(angle), center.dy + radius * 0.7 * sin(angle))
            ..lineTo(center.dx + radius * 0.7 * cos((i + 1) * 72 - 90) * 3.14159 / 180, 
                     center.dy + radius * 0.7 * sin((i + 1) * 72 - 90) * 3.14159 / 180)
            ..lineTo(center.dx + radius * cos((i + 1) * 72 - 90) * 3.14159 / 180,
                     center.dy + radius * sin((i + 1) * 72 - 90) * 3.14159 / 180)
            ..close(),
          paint
        );
        paint.style = PaintingStyle.stroke;
        paint.color = TossDesignSystem.white.withValues(alpha:0.3);
      }
      
      if (i < 4) {
        final nextAngle = ((i + 1) * 72 - 90) * 3.14159 / 180;
        final nextX = center.dx + radius * cos(nextAngle);
        final nextY = center.dy + radius * sin(nextAngle);
        canvas.drawLine(Offset(x, y), Offset(nextX, nextY), paint);
      } else {
        final firstAngle = (-90) * 3.14159 / 180;
        final firstX = center.dx + radius * cos(firstAngle);
        final firstY = center.dy + radius * sin(firstAngle);
        canvas.drawLine(Offset(x, y), Offset(firstX, firstY), paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for Tojeong pattern
class TojeongPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = TossDesignSystem.white.withValues(alpha:0.1);

    // Draw traditional Korean pattern
    final spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Draw small circle pattern
        canvas.drawCircle(Offset(x, y), 2, paint);
        
        // Draw connecting lines
        if (x + spacing < size.width) {
          canvas.drawLine(Offset(x, y), Offset(x + spacing / 2, y), paint);
}
        if (y + spacing < size.height) {
          canvas.drawLine(Offset(x, y), Offset(x, y + spacing / 2), paint);
}
      }}
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}