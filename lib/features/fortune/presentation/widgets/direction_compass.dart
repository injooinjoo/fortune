import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/design_system/design_system.dart';

class DirectionCompass extends StatefulWidget {
  final List<String> auspiciousDirections;
  final List<String> avoidDirections;
  final String? primaryDirection;
  final bool animated;
  
  const DirectionCompass({
    super.key,
    required this.auspiciousDirections,
    this.avoidDirections = const [],
    this.primaryDirection,
    this.animated = true,
  });

  @override
  State<DirectionCompass> createState() => _DirectionCompassState();
}

class _DirectionCompassState extends State<DirectionCompass>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  final Map<String, DirectionData> _directions = {
    '동': DirectionData('동', '東', 90, DSColors.accent, '청룡'),
    '서': DirectionData('서', '西', 270, Colors.white, '백호'),
    '남': DirectionData('남', '南', 180, DSColors.error, '주작'),
    '북': DirectionData('북', '北', 0, Colors.black, '현무'),
    '남동': DirectionData('남동', '南東', 135, DSColors.warning, ''),
    '남서': DirectionData('남서', '南西', 225, DSColors.accentSecondary, ''),
    '북동': DirectionData('북동', '北東', 45, DSColors.success, ''),
    '북서': DirectionData('북서', '北西', 315, DSColors.accentTertiary, ''),
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    if (widget.animated) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getDirectionColor(String direction) {
    if (widget.primaryDirection == direction) {
      return DSColors.warning;
    } else if (widget.auspiciousDirections.contains(direction) ||
        widget.auspiciousDirections.contains('$direction쪽')) {
      return DSColors.success;
    } else if (widget.avoidDirections.contains(direction) ||
        widget.avoidDirections.contains('$direction쪽')) {
      return DSColors.error.withValues(alpha: 0.7);
    } else {
      return DSColors.border.withValues(alpha: 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DSColors.border.withValues(alpha: 0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 배경 원
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: DSColors.border.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
              ),
              
              // 나침반 바늘
              AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: CustomPaint(
                      size: const Size(280, 280),
                      painter: CompassPainter(
                        directions: _directions,
                        getDirectionColor: _getDirectionColor,
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  );
                },
              ),
              
              // 중앙 장식
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.explore,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 범례
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DSColors.border.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(DSRadius.md),
            border: Border.all(color: DSColors.border.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '방위 안내',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (widget.primaryDirection != null)
                    _buildLegendItem(DSColors.warning, '최고의 방향'),
                  _buildLegendItem(DSColors.success, '길한 방향'),
                  _buildLegendItem(DSColors.error.withValues(alpha: 0.7), '피해야 할 방향'),
                  _buildLegendItem(DSColors.border.withValues(alpha: 0.5), '보통'),
                ],
              ),
              if (widget.auspiciousDirections.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '방향: ${widget.auspiciousDirections.join(', ')}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: DSColors.success.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
              if (widget.avoidDirections.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '방향: ${widget.avoidDirections.join(', ')}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: DSColors.error.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: DSColors.border.withValues(alpha: 0.6), width: 0.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class DirectionData {
  final String korean;
  final String chinese;
  final double angle;
  final Color baseColor;
  final String guardian;
  
  DirectionData(
    this.korean,
    this.chinese,
    this.angle,
    this.baseColor,
    this.guardian,
  );
}

class CompassPainter extends CustomPainter {
  final Map<String, DirectionData> directions;
  final Color Function(String) getDirectionColor;
  final TextStyle? textStyle;
  
  CompassPainter({
    required this.directions,
    required this.getDirectionColor,
    this.textStyle,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    // 방위별 섹터 그리기
    for (var entry in directions.entries) {
      final direction = entry.value;
      final color = getDirectionColor(entry.key);
      
      // 메인 방위만 그리기 (동서남북)
      if (direction.guardian.isNotEmpty) {
        final paint = Paint()
          ..color = color.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        
        final sweepAngle = 90 * (math.pi / 180);
        final startAngle = (direction.angle - 45) * (math.pi / 180);
        
        final path = Path();
        path.moveTo(center.dx, center.dy);
        path.arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false
        );
        path.close();
        
        canvas.drawPath(path, paint);
        
        // 방위 텍스트
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${direction.chinese}\n${direction.korean}',
            style: textStyle,
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout();
        
        final angleRad = direction.angle * (math.pi / 180);
        final textOffset = Offset(
          center.dx + radius * 0.65 * math.sin(angleRad) - textPainter.width / 2,
          center.dy - radius * 0.65 * math.cos(angleRad) - textPainter.height / 2
        );
        
        textPainter.paint(canvas, textOffset);
        
        // 수호신 텍스트 (더 작게)
        if (direction.guardian.isNotEmpty) {
          final guardianPainter = TextPainter(
            text: TextSpan(
              text: direction.guardian,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: textStyle?.fontSize ?? 14,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          guardianPainter.layout();
          
          final guardianOffset = Offset(
            center.dx + radius * 0.85 * math.sin(angleRad) - guardianPainter.width / 2,
            center.dy - radius * 0.85 * math.cos(angleRad) - guardianPainter.height / 2
          );
          
          guardianPainter.paint(canvas, guardianOffset);
        }
      }
    }
    
    // 나침반 화살표
    final arrowPaint = Paint()
      ..color = DSColors.error
      ..style = PaintingStyle.fill;
    
    final northArrow = Path();
    northArrow.moveTo(center.dx, center.dy - radius * 0.4);
    northArrow.lineTo(center.dx - 8, center.dy);
    northArrow.lineTo(center.dx, center.dy - 10);
    northArrow.lineTo(center.dx + 8, center.dy);
    northArrow.close();
    
    canvas.drawPath(northArrow, arrowPaint);
    
    final southArrowPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final southArrow = Path();
    southArrow.moveTo(center.dx, center.dy + radius * 0.4);
    southArrow.lineTo(center.dx - 8, center.dy);
    southArrow.lineTo(center.dx, center.dy + 10);
    southArrow.lineTo(center.dx + 8, center.dy);
    southArrow.close();
    
    canvas.drawPath(southArrow, southArrowPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}