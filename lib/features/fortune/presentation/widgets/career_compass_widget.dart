import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';



class CareerCompassData {
  final String direction;
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const CareerCompassData({
    required this.direction,
    required this.label,
    required this.value,
    required this.color,
    required this.icon});
}

class CareerCompassWidget extends StatefulWidget {
  final List<CareerCompassData> data;
  final String centerText;
  final double size;

  const CareerCompassWidget({
    super.key,
    required this.data,
    this.centerText = '커리어',
    this.size = 300,
  });

  @override
  State<CareerCompassWidget> createState() => _CareerCompassWidgetState();
}

class _CareerCompassWidgetState extends State<CareerCompassWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this)..repeat();
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background compass circle
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 0.1,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _CompassBackgroundPainter(
                    primaryColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    secondaryColor: theme.colorScheme.secondary.withValues(alpha: 0.05)),
                ),
              );
            },
          ),
          
          // Compass directions and data
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _CompassPainter(
              data: widget.data,
              textColor: theme.colorScheme.onSurface,
              backgroundColor: theme.colorScheme.surface),
          ),
          
          // Center circle with text
          Container(
            width: widget.size * 0.25,
            height: widget.size * 0.25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5),
              ],
            ),
            child: Center(
              child: Text(
                widget.centerText,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: TossDesignSystem.white,
                  fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          // Interactive data points
          ...widget.data.map((item) {
            final index = widget.data.indexOf(item);
            final angle = (index / widget.data.length) * 2 * math.pi - math.pi / 2;
            final radius = widget.size * 0.35;
            
            return Positioned(
              left: widget.size / 2 + radius * math.cos(angle) - 30,
              top: widget.size / 2 + radius * math.sin(angle) - 30,
              child: _DataPoint(
                data: item,
                onTap: () => _showDataDetail(context, item)),
            );
          }),
        ],
      ),
    );
  }

  void _showDataDetail(BuildContext context, CareerCompassData data) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: TossDesignSystem.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: TossDesignSystem.spacingXS,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4 * 0.5),
              ),
            ),
            const SizedBox(height: TossDesignSystem.spacingL),
            Icon(
              data.icon,
              size: 48,
              color: data.color),
            const SizedBox(height: TossDesignSystem.spacingM),
            Text(
              data.label,
              style: theme.textTheme.headlineSmall),
            const SizedBox(height: TossDesignSystem.spacingS),
            Text(
              '${data.direction} 방향',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: TossDesignSystem.spacingL),
            LinearProgressIndicator(
              value: data.value / 100,
              backgroundColor: data.color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(data.color),
              minHeight: 8),
            const SizedBox(height: TossDesignSystem.spacingS),
            Text(
              '${data.value.toInt()}%',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: data.color,
                fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: TossDesignSystem.spacingM),
            Text(
              _getDescription(data),
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center),
            const SizedBox(height: TossDesignSystem.spacingXL),
          ],
        ),
      ),
    );
  }
  
  String _getDescription(CareerCompassData data) {
    if (data.value >= 80) {
      return '매우 긍정적인 신호입니다. 이 방향으로 적극적으로 나아가세요!';
    } else if (data.value >= 60) {
      return '좋은 기회가 있습니다. 준비를 철저히 하여 도전해보세요.';
    } else if (data.value >= 40) {
      return '가능성은 있지만 신중한 접근이 필요합니다.';
    } else {
      return '현재는 다른 방향을 고려해보는 것이 좋겠습니다.';
    }
  }
}

class _DataPoint extends StatelessWidget {
  final CareerCompassData data;
  final VoidCallback onTap;

  const _DataPoint({
    required this.data,
    required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface,
          border: Border.all(
            color: data.color,
            width: 3),
          boxShadow: [
            BoxShadow(
              color: data.color.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              data.icon,
              color: data.color,
              size: 24),
            Text(
              '${data.value.toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _CompassBackgroundPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _CompassBackgroundPainter({
    required this.primaryColor,
    required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Draw concentric circles
    for (int i = 1; i <= 3; i++) {
      final paint = Paint()
        ..color = i % 2 == 0 ? primaryColor : secondaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      
      canvas.drawCircle(center, radius * (i / 3), paint);
    }
    
    // Draw compass lines
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1;
    
    // N-S line
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      linePaint
    );
    
    // E-W line
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      linePaint
    );
    
    // Diagonal lines
    final diagonalLength = radius * 0.7;
    for (int i = 0; i < 4; i++) {
      final angle = (math.pi / 4) + (i * math.pi / 2);
      final dx = diagonalLength * math.cos(angle);
      final dy = diagonalLength * math.sin(angle);
      
      canvas.drawLine(
        center,
        Offset(center.dx + dx, center.dy + dy),
        linePaint..color = secondaryColor
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompassPainter extends CustomPainter {
  final List<CareerCompassData> data;
  final Color textColor;
  final Color backgroundColor;

  _CompassPainter({
    required this.data,
    required this.textColor,
    required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Draw direction labels
    final directions = ['북', '동', '남', '서'];
    final textStyle = TypographyUnified.bodySmall.copyWith(color: textColor);
    
    for (int i = 0; i < directions.length; i++) {
      final angle = (i * math.pi / 2) - math.pi / 2;
      final labelRadius = radius * 0.85;
      
      final textPainter = TextPainter(
        text: TextSpan(text: directions[i], style: textStyle),
        textDirection: TextDirection.ltr
      );
      
      textPainter.layout();
      
      final x = center.dx + labelRadius * math.cos(angle) - textPainter.width / 2;
      final y = center.dy + labelRadius * math.sin(angle) - textPainter.height / 2;
      
      textPainter.paint(canvas, Offset(x, y));
    }
    
    // Draw data connections
    final dataPath = Path();
    final dataPaint = Paint()
      ..color = textColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < data.length; i++) {
      final angle = (i / data.length) * 2 * math.pi - math.pi / 2;
      final dataRadius = radius * 0.35 * (data[i].value / 100);
      
      final x = center.dx + dataRadius * math.cos(angle);
      final y = center.dy + dataRadius * math.sin(angle);
      
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    
    dataPath.close();
    canvas.drawPath(dataPath, dataPaint);
    
    // Draw data border
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = textColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}