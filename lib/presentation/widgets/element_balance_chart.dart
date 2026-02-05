import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/design_system/design_system.dart';

/// 오행 균형 차트 위젯 - 목/화/토/금/수 균형을 시각화
class ElementBalanceChart extends StatelessWidget {
  final Map<String, double> elements; // 각 오행의 값 (0.0 ~ 1.0)
  final double size;
  final bool showPercentage;
  final bool animated;

  const ElementBalanceChart({
    super.key,
    required this.elements,
    this.size = 200,
    this.showPercentage = true,
    this.animated = true,
  });

  // 오행별 색상과 아이콘
  static const elementData = {
    '목': {'color': DSFortuneColors.elementWood, 'icon': '🌳', 'name': '목(木)'},
    '화': {'color': DSFortuneColors.elementFire, 'icon': '🔥', 'name': '화(火)'},
    '토': {'color': DSFortuneColors.elementEarth, 'icon': '⛰️', 'name': '토(土)'},
    '금': {'color': DSFortuneColors.elementMetal, 'icon': '⚡', 'name': '금(金)'},
    '수': {'color': DSFortuneColors.elementWater, 'icon': '💧', 'name': '수(水)'},
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 오행 원형 차트
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: ElementCirclePainter(
              elements: elements,
              showPercentage: showPercentage,
              iconStyle: context.headingSmall,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 오행 범례
        _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: elements.entries.map((entry) {
        final data = elementData[entry.key];
        if (data == null) return const SizedBox.shrink();
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: data['color'] as Color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${data['icon']} ${data['name']}',
              style: TextStyle(
                color: DSColors.backgroundSecondaryDark.withValues(alpha: 0.8),
                
                fontWeight: FontWeight.w300,
              ),
            ),
            if (showPercentage) ...[
              const SizedBox(width: 4),
              Text(
                '${(entry.value * 100).toInt()}%',
                style: TextStyle(
                  color: DSColors.backgroundSecondaryDark.withValues(alpha: 0.6),
                  
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        );
      }).toList(),
    );
  }
}

class ElementCirclePainter extends CustomPainter {
  final Map<String, double> elements;
  final bool showPercentage;
  final TextStyle iconStyle;

  ElementCirclePainter({
    required this.elements,
    required this.showPercentage,
    required this.iconStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    
    // 배경 원
    final bgPaint = Paint()
      ..color = DSColors.backgroundSecondaryDark.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);
    
    // 총합 계산
    double total = elements.values.fold(0, (sum, value) => sum + value);
    if (total == 0) total = 1; // 0으로 나누기 방지
    
    // 오행 파이 차트 그리기
    double startAngle = -math.pi / 2; // 12시 방향부터 시작
    
    elements.forEach((key, value) {
      final data = ElementBalanceChart.elementData[key];
      if (data == null) return;
      
      final sweepAngle = (value / total) * 2 * math.pi;
      
      // 섹터 그리기
      final paint = Paint()
        ..color = (data['color'] as Color).withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;
      
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
        )
        ..close();
      
      canvas.drawPath(path, paint);
      
      // 테두리 그리기
      final borderPaint = Paint()
        ..color = DSColors.backgroundSecondaryDark.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawPath(path, borderPaint);
      
      // 중앙에 아이콘과 퍼센트 표시
      if (showPercentage && value > 0) {
        final midAngle = startAngle + sweepAngle / 2;
        final labelRadius = radius * 0.7;
        final labelPoint = Offset(
          center.dx + labelRadius * math.cos(midAngle),
          center.dy + labelRadius * math.sin(midAngle),
        );
        
        // 아이콘 그리기
        final iconPainter = TextPainter(
          text: TextSpan(
            text: data['icon'] as String,
            style: iconStyle,
          ),
          textDirection: TextDirection.ltr,
        );
        iconPainter.layout();
        iconPainter.paint(
          canvas,
          Offset(
            labelPoint.dx - iconPainter.width / 2,
            labelPoint.dy - iconPainter.height / 2 - 8,
          ),
        );
        
        // 퍼센트 그리기
        final percentage = (value / total * 100).toInt();
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$percentage%',
            style: TextStyle(
              color: DSColors.backgroundSecondaryDark,
              
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                  color: DSColors.textPrimary.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            labelPoint.dx - textPainter.width / 2,
            labelPoint.dy + 4,
          ),
        );
      }
      
      startAngle += sweepAngle;
    });
    
    // 중앙 원 (도넛 효과)
    final centerCirclePaint = Paint()
      ..color = DSColors.textPrimary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.3, centerCirclePaint);
    
    // 중앙 텍스트
    final centerTextPainter = TextPainter(
      text: TextSpan(
        text: '오행\n균형',
        style: TextStyle(
          color: DSColors.backgroundSecondaryDark.withValues(alpha: 0.8),
          
          fontWeight: FontWeight.w300,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    centerTextPainter.layout();
    centerTextPainter.paint(
      canvas,
      Offset(
        center.dx - centerTextPainter.width / 2,
        center.dy - centerTextPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}