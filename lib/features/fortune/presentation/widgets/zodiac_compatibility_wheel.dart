import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../services/zodiac_compatibility_service.dart';

class ZodiacCompatibilityWheel extends StatefulWidget {
  final String selectedZodiac;
  final Function(String) onZodiacSelected;
  final bool showAnimation;

  const ZodiacCompatibilityWheel({
    Key? key,
    required this.selectedZodiac,
    required this.onZodiacSelected,
    this.showAnimation = true,
  }) : super(key: key);

  @override
  State<ZodiacCompatibilityWheel> createState() => _ZodiacCompatibilityWheelState();
}

class _ZodiacCompatibilityWheelState extends State<ZodiacCompatibilityWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  String? _hoveredZodiac;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    
    if (widget.showAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildWheel(),
        const SizedBox(height: 20),
        _buildLegend(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.stars,
          color: Colors.amber,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          '띠별 궁합 관계도',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildWheel() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GlassContainer(
          width: 350,
          height: 350,
          padding: const EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 관계선 그리기
              CustomPaint(
                size: const Size(310, 310),
                painter: _ZodiacRelationshipPainter(
                  selectedZodiac: widget.selectedZodiac,
                  animationValue: _animationController.value,
                ),
              ),
              // 띠 아이콘들
              ...List.generate(12, (index) {
                final angle = (index * 30 - 90) * math.pi / 180;
                final radius = 130.0;
                final x = radius * math.cos(angle);
                final y = radius * math.sin(angle);
                final zodiac = ZodiacCompatibilityService.zodiacAnimals[index];
                
                return Transform.translate(
                  offset: Offset(x, y),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: _buildZodiacIcon(zodiac, index),
                  ),
                );
              }),
              // 중앙 정보
              _buildCenterInfo(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildZodiacIcon(String zodiac, int index) {
    final isSelected = widget.selectedZodiac == zodiac;
    final isHovered = _hoveredZodiac == zodiac;
    final compatibility = ZodiacCompatibilityService.calculateCompatibility(
      widget.selectedZodiac,
      zodiac,
    );
    
    return GestureDetector(
      onTap: () => widget.onZodiacSelected(zodiac),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredZodiac = zodiac),
        onExit: (_) => setState(() => _hoveredZodiac = null),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isSelected ? 70 : 60,
          height: isSelected ? 70 : 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getCompatibilityColor(compatibility).withValues(alpha: 0.2),
            border: Border.all(
              color: isSelected 
                  ? Colors.amber 
                  : _getCompatibilityColor(compatibility),
              width: isSelected ? 3 : 2,
            ),
            boxShadow: (isSelected || isHovered) ? [
              BoxShadow(
                color: _getCompatibilityColor(compatibility).withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ] : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getZodiacEmoji(zodiac),
                style: TextStyle(
                  fontSize: isSelected ? 28 : 24,
                ),
              ),
              Text(
                zodiac,
                style: TextStyle(
                  fontSize: isSelected ? 12 : 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterInfo() {
    final info = ZodiacCompatibilityService.zodiacInfo[widget.selectedZodiac]!;
    
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.3),
            Colors.amber.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getZodiacEmoji(widget.selectedZodiac),
            style: const TextStyle(fontSize: 32),
          ),
          Text(
            widget.selectedZodiac,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            info['hanja'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          Text(
            info['element'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem('육합': Colors.green, '최고 궁합',
          const SizedBox(width: 20),
          _buildLegendItem('삼합': Colors.blue, '좋은 궁합',
          const SizedBox(width: 20),
          _buildLegendItem('육해': Colors.red, '주의 필요',
          const SizedBox(width: 20),
          _buildLegendItem('보통': Colors.grey, '노력 필요',
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String description) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getCompatibilityColor(double compatibility) {
    if (compatibility >= 0.9) return Colors.green;
    if (compatibility >= 0.8) return Colors.blue;
    if (compatibility >= 0.6) return Colors.amber;
    if (compatibility >= 0.4) return Colors.orange;
    return Colors.red;
  }

  String _getZodiacEmoji(String zodiac) {
    const emojiMap = {
      '쥐': '🐭',
      '소': '🐮',
      '호랑이': '🐯',
      '토끼': '🐰',
      '용': '🐲',
      '뱀': '🐍',
      '말': '🐴',
      '양': '🐑',
      '원숭이': '🐵',
      '닭': '🐓',
      '개': '🐕',
      '돼지': '🐷',
    };
    return emojiMap[zodiac] ?? '🌟';
  }
}

class _ZodiacRelationshipPainter extends CustomPainter {
  final String selectedZodiac;
  final double animationValue;

  _ZodiacRelationshipPainter({
    required this.selectedZodiac,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    // 육합 관계선 그리기
    _drawBestMatchLine(canvas, center, radius);
    
    // 삼합 관계선 그리기
    _drawHarmonyLines(canvas, center, radius);
    
    // 육해 관계선 그리기
    _drawConflictLine(canvas, center, radius);
  }

  void _drawBestMatchLine(Canvas canvas, Offset center, double radius) {
    final selectedIndex = ZodiacCompatibilityService.zodiacAnimals.indexOf(selectedZodiac);
    final bestMatch = ZodiacCompatibilityService.bestMatchPairs[selectedZodiac];
    if (bestMatch == null) return;
    
    final bestMatchIndex = ZodiacCompatibilityService.zodiacAnimals.indexOf(bestMatch);
    
    final paint = Paint()
      ..color = Colors.green.withValues(alpha: 0.6 * animationValue)
      ..strokeWidth = 3
     
   
    ..style = PaintingStyle.stroke;
    
    final angle1 = (selectedIndex * 30 - 90) * math.pi / 180;
    final angle2 = (bestMatchIndex * 30 - 90) * math.pi / 180;
    
    final point1 = Offset(
      center.dx + radius * math.cos(angle1),
      center.dy + radius * math.sin(angle1),
    );
    final point2 = Offset(
      center.dx + radius * math.cos(angle2),
      center.dy + radius * math.sin(angle2),
    );
    
    canvas.drawLine(point1, point2, paint);
  }

  void _drawHarmonyLines(Canvas canvas, Offset center, double radius) {
    final selectedIndex = ZodiacCompatibilityService.zodiacAnimals.indexOf(selectedZodiac);
    
    for (final group in ZodiacCompatibilityService.harmonyGroups) {
      if (group.contains(selectedZodiac)) {
        final paint = Paint()
          ..color = Colors.blue.withValues(alpha: 0.4 * animationValue)
          ..strokeWidth = 2
         
   
    ..style = PaintingStyle.stroke;
        
        final path = Path();
        bool first = true;
        
        for (final zodiac in group) {
          final index = ZodiacCompatibilityService.zodiacAnimals.indexOf(zodiac);
          final angle = (index * 30 - 90) * math.pi / 180;
          final point = Offset(
            center.dx + radius * math.cos(angle),
            center.dy + radius * math.sin(angle),
          );
          
          if (first) {
            path.moveTo(point.dx, point.dy);
            first = false;
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        path.close();
        
        canvas.drawPath(path, paint);
        break;
      }
    }
  }

  void _drawConflictLine(Canvas canvas, Offset center, double radius) {
    final selectedIndex = ZodiacCompatibilityService.zodiacAnimals.indexOf(selectedZodiac);
    final conflict = ZodiacCompatibilityService.conflictPairs[selectedZodiac];
    if (conflict == null) return;
    
    final conflictIndex = ZodiacCompatibilityService.zodiacAnimals.indexOf(conflict);
    
    final paint = Paint()
      ..color = Colors.red.withValues(alpha: 0.5 * animationValue)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
     
   
    ..strokeCap = StrokeCap.round;
    
    // 점선 효과
    final angle1 = (selectedIndex * 30 - 90) * math.pi / 180;
    final angle2 = (conflictIndex * 30 - 90) * math.pi / 180;
    
    final point1 = Offset(
      center.dx + radius * math.cos(angle1),
      center.dy + radius * math.sin(angle1),
    );
    final point2 = Offset(
      center.dx + radius * math.cos(angle2),
      center.dy + radius * math.sin(angle2),
    );
    
    _drawDashedLine(canvas, point1, point2, paint);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final distance = (p2 - p1).distance;
    final dashLength = 5.0;
    final dashSpace = 5.0;
    final dashCount = (distance / (dashLength + dashSpace)).floor();
    
    for (int i = 0; i < dashCount; i++) {
      final start = p1 + (p2 - p1) * (i * (dashLength + dashSpace) / distance);
      final end = p1 + (p2 - p1) * ((i * (dashLength + dashSpace) + dashLength) / distance);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}