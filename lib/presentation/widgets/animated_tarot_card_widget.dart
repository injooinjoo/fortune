import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class AnimatedTarotCardWidget extends StatefulWidget {
  final double width;
  final double height;
  
  const AnimatedTarotCardWidget({
    super.key,
    this.width = double.infinity,
    this.height = double.infinity}));

  @override
  State<AnimatedTarotCardWidget> createState() => _AnimatedTarotCardWidgetState();
}

class _AnimatedTarotCardWidgetState extends State<AnimatedTarotCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late AnimationController _floatController;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _floatAnimation;
  
  final List<_Sparkle> _sparkles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this)..repeat();
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this)..repeat(reverse: true);
    
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0).animate(_sparkleController);
    
    _floatAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut);
    
    // Generate sparkles
    for (int i = 0; i < 15; i++) {
      _sparkles.add(_Sparkle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 4 + 2,
        speed: _random.nextDouble() * 0.5 + 0.5,
        delay: _random.nextDouble()));
    }
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_sparkleAnimation, _floatAnimation]),
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _TarotCardPainter(
            sparkles: _sparkles,
            sparkleProgress: _sparkleAnimation.value,
            floatOffset: _floatAnimation.value));
      });
  }
}

class _Sparkle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double delay;
  
  _Sparkle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.delay}));
}

class _TarotCardPainter extends CustomPainter {
  final List<_Sparkle> sparkles;
  final double sparkleProgress;
  final double floatOffset;
  
  _TarotCardPainter({
    required this.sparkles,
    required this.sparkleProgress,
    required this.floatOffset}));
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw mystical symbols
    final symbolPaint = Paint()
      ..color = AppColors.textPrimaryDark.withOpacity(0.1)
      ..style = PaintingStyle.stroke
     
   
    ..strokeWidth = 2;
    
    // Central sun/moon symbol
    final centerX = size.width / 2;
    final centerY = size.height / 2 + floatOffset;
    
    // Draw sun rays
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final startRadius = 40;
      final endRadius = 60;
      
      final startX = centerX + math.cos(angle) * startRadius;
      final startY = centerY + math.sin(angle) * startRadius;
      final endX = centerX + math.cos(angle) * endRadius;
      final endY = centerY + math.sin(angle) * endRadius;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        symbolPaint);
    }
    
    // Draw central circle
    canvas.drawCircle(
      Offset(centerX, centerY),
      35,
      symbolPaint);
    
    // Draw moon crescent
    final moonPath = Path();
    moonPath.addArc(
      Rect.fromCenter(
        center: Offset(centerX - 10, centerY),
        width: 50,
        height: 50),
      -math.pi / 3,
      4 * math.pi / 3);
    canvas.drawPath(moonPath, symbolPaint);
    
    // Draw decorative elements
    _drawDecorativeStars(canvas, size, symbolPaint);
    
    // Draw sparkles
    final sparklePaint = Paint()
      ..style = PaintingStyle.fill
     
   
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    for (final sparkle in sparkles) {
      final progress = (sparkleProgress + sparkle.delay) % 1.0;
      final opacity = math.sin(progress * math.pi).abs() * 0.8; // Use abs() to ensure positive value
      
      if (opacity > 0) {
        sparklePaint.color = AppColors.textPrimaryDark.withOpacity(opacity);
        
        final x = size.width * sparkle.x;
        final y = size.height * sparkle.y + floatOffset * 0.5;
        
        // Draw star-shaped sparkle
        _drawSparkle(canvas, Offset(x, y), sparkle.size, sparklePaint);
      }
    }
  }
  
  void _drawDecorativeStars(Canvas canvas, Size size, Paint paint) {
    final starPositions = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.15, size.height * 0.7),
      Offset(size.width * 0.85, size.height * 0.75)];
    
    for (final pos in starPositions) {
      _drawStar(canvas, pos.translate(0, floatOffset * 0.3), 8, paint);
    }
  }
  
  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 144 - 90) * math.pi / 180;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  
  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    // Horizontal line
    canvas.drawLine(
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      paint);
    
    // Vertical line
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      paint);
    
    // Diagonal lines
    final diagonalSize = size * 0.7;
    canvas.drawLine(
      Offset(center.dx - diagonalSize, center.dy - diagonalSize),
      Offset(center.dx + diagonalSize, center.dy + diagonalSize),
      paint);
    canvas.drawLine(
      Offset(center.dx + diagonalSize, center.dy - diagonalSize),
      Offset(center.dx - diagonalSize, center.dy + diagonalSize),
      paint);
  }
  
  @override
  bool shouldRepaint(_TarotCardPainter oldDelegate) {
    return oldDelegate.sparkleProgress != sparkleProgress ||
           oldDelegate.floatOffset != floatOffset;
  }
}