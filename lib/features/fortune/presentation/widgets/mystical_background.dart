import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:fortune/core/theme/fortune_colors.dart';

class MysticalBackground extends StatefulWidget {
  final Widget child;
  final bool showShootingStars;
  final bool showNebula;
  
  const MysticalBackground({
    super.key,
    required this.child,
    this.showShootingStars = true,
    this.showNebula = true});

  @override
  State<MysticalBackground> createState() => _MysticalBackgroundState();
}

class Star {
  final double x;
  final double y;
  final double size;
  final double twinkleSpeed;
  final double twinkleOffset;
  final double opacity;
  final Color color;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleSpeed,
    required this.twinkleOffset,
    required this.opacity,
    required this.color});
}

class ShootingStar {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double startTime;
  final double duration;

  ShootingStar({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.startTime,
    required this.duration});
}

class _MysticalBackgroundState extends State<MysticalBackground> 
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _nebulaeController;
  late AnimationController _shootingStarController;
  final List<Star> _stars = [];
  final List<ShootingStar> _shootingStars = [];
  final math.Random _random = math.Random();
  double _lastShootingStarTime = 0;

  @override
  void initState() {
    super.initState();
    
    _starController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this)..repeat();
    
    _nebulaeController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this)..repeat();
    
    _shootingStarController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this)..repeat();
    
    // Generate stars with layers
    // Background stars (small, dim)
    for (int i = 0; i < 100; i++) {
      _stars.add(Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 1.5 + 0.5,
        twinkleSpeed: _random.nextDouble() * 2 + 1,
        twinkleOffset: _random.nextDouble() * math.pi * 2,
        opacity: _random.nextDouble() * 0.4 + 0.1,
        color: _getStarColor()));
    }
    
    // Foreground stars (larger, brighter)
    for (int i = 0; i < 30; i++) {
      _stars.add(Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 2.5 + 1.5,
        twinkleSpeed: _random.nextDouble() * 3 + 0.5,
        twinkleOffset: _random.nextDouble() * math.pi * 2,
        opacity: _random.nextDouble() * 0.6 + 0.4,
        color: _getStarColor()));
    }
    
    if (widget.showShootingStars) {
      _shootingStarController.addListener(_updateShootingStars);
    }
  }
  
  Color _getStarColor() {
    final colors = [
      Colors.white,
      DSColors.accent.withValues(alpha:0.9),
      DSColors.accentTertiary.withValues(alpha:0.9),
      Colors.white]; // Warm white
    return colors[_random.nextInt(colors.length)];
  }
  
  void _updateShootingStars() {
    final currentTime = _shootingStarController.value * 10;
    
    // Add new shooting star every 2-3 seconds
    if (currentTime - _lastShootingStarTime > 2.5) {
      _lastShootingStarTime = currentTime;
      
      setState(() {
        _shootingStars.add(ShootingStar(
          startX: _random.nextDouble() * 0.8,
          startY: _random.nextDouble() * 0.3,
          endX: _random.nextDouble() * 0.8 + 0.2,
          endY: _random.nextDouble() * 0.3 + 0.4,
          startTime: currentTime,
          duration: _random.nextDouble() * 0.5 + 0.5));
        
        // Remove old shooting stars
        _shootingStars.removeWhere((star) => 
          currentTime - star.startTime > star.duration + 0.5
        );
      });
    }
  }

  @override
  void dispose() {
    if (widget.showShootingStars) {
      _shootingStarController.removeListener(_updateShootingStars);
    }
    _starController.dispose();
    _nebulaeController.dispose();
    _shootingStarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep space gradient background
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.5,
              colors: [
                FortuneColors.tarotDarkest, // Deep purple
                FortuneColors.tarotDarkest, // Darker purple
                Colors.black],
              stops: const [0.0, 0.7, 1.0]))),
        
        // Animated nebulae
        if (widget.showNebula)
          AnimatedBuilder(
            animation: _nebulaeController,
            builder: (context, child) {
              return CustomPaint(
                painter: _NebulaePainter(
                  animation: _nebulaeController.value),
                child: Container());
            }),
        
        // Twinkling stars
        AnimatedBuilder(
          animation: _starController,
          builder: (context, child) {
            return CustomPaint(
              painter: _StarFieldPainter(
                stars: _stars,
                animation: _starController.value),
              child: Container());
          }),
        
        // Shooting stars
        if (widget.showShootingStars)
          AnimatedBuilder(
            animation: _shootingStarController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ShootingStarPainter(
                  shootingStars: _shootingStars,
                  currentTime: _shootingStarController.value * 10),
                child: Container());
            }),
        
        // Subtle overlay gradient
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha:0.3)]))),
        
        // Child widget
        widget.child,
      ],
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  final List<Star> stars;
  final double animation;

  _StarFieldPainter({
    required this.stars,
    required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle = math.sin(animation * math.pi * 2 * star.twinkleSpeed + star.twinkleOffset);
      final opacity = (twinkle + 1) / 2 * 0.8 + 0.2; // Range: 0.2 to 1.0
      
      final center = Offset(star.x * size.width, star.y * size.height);
      
      // Draw star glow
      final glowPaint = Paint()
        ..color = star.color.withValues(alpha:star.opacity * opacity * 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.size * 2)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(center, star.size * 2, glowPaint);
      
      // Draw star core
      final corePaint = Paint()
        ..color = star.color.withValues(alpha:star.opacity * opacity * 0.9)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(center, star.size, corePaint);
      
      // Draw bright center
      final centerPaint = Paint()
        ..color = Colors.white.withValues(alpha:star.opacity * opacity);
      canvas.drawCircle(center, star.size * 0.3, centerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _NebulaePainter extends CustomPainter {
  final double animation;

  _NebulaePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // Purple nebula with rotation
    final purpleCenter = Offset(
      size.width * (0.3 + math.sin(animation * math.pi * 2) * 0.05),
      size.height * (0.2 + math.cos(animation * math.pi * 2) * 0.05));
    
    final purplePaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80)
      ..shader = ui.Gradient.radial(
        purpleCenter,
        size.width * 0.4,
        [
          FortuneColors.mystical.withValues(alpha:0.3),
          FortuneColors.mystical.withValues(alpha:0.1),
          Colors.transparent],
        [0.0, 0.6, 1.0],
        TileMode.clamp,
        Matrix4.rotationZ(animation * 0.5).storage
      );
    
    canvas.drawCircle(purpleCenter, size.width * 0.4, purplePaint);

    // Indigo nebula with counter-rotation
    final indigoCenter = Offset(
      size.width * (0.7 + math.cos(animation * math.pi * 2 * 0.8) * 0.05),
      size.height * (0.8 + math.sin(animation * math.pi * 2 * 0.8) * 0.05));
    
    final indigoPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60)
      ..shader = ui.Gradient.radial(
        indigoCenter,
        size.width * 0.3,
        [
          FortuneColors.mystical.withValues(alpha:0.25),
          FortuneColors.mystical.withValues(alpha:0.1),
          Colors.transparent],
        [0.0, 0.7, 1.0],
        TileMode.clamp,
        Matrix4.rotationZ(-animation * 0.3).storage
      );
    
    canvas.drawCircle(indigoCenter, size.width * 0.3, indigoPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ShootingStarPainter extends CustomPainter {
  final List<ShootingStar> shootingStars;
  final double currentTime;
  
  _ShootingStarPainter({
    required this.shootingStars,
    required this.currentTime});

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in shootingStars) {
      final progress = math.min(1.0, (currentTime - star.startTime) / star.duration);
      if (progress < 0 || progress > 1) continue;
      
      final fadeProgress = progress < 0.5 ? progress * 2 : (1 - progress) * 2;
      
      final startPoint = Offset(star.startX * size.width, star.startY * size.height);
      final endPoint = Offset(star.endX * size.width, star.endY * size.height);
      final currentPoint = Offset.lerp(startPoint, endPoint, progress)!;
      
      // Draw trail with gradient
      final trailPaint = Paint()
        ..shader = ui.Gradient.linear(
          currentPoint,
          Offset.lerp(startPoint, currentPoint, 0.7)!,
          [
            Colors.white.withValues(alpha:fadeProgress * 0.8),
            FortuneColors.mystical.withValues(alpha:fadeProgress * 0.4),
            Colors.transparent],
          [0.0, 0.5, 1.0])
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(
        currentPoint,
        Offset.lerp(startPoint, currentPoint, 0.7)!,
        trailPaint
      );
      
      // Draw star head with glow
      final headGlowPaint = Paint()
        ..color = Colors.white.withValues(alpha:fadeProgress * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(currentPoint, 4, headGlowPaint);

      final headPaint = Paint()
        ..color = Colors.white.withValues(alpha:fadeProgress);

      canvas.drawCircle(currentPoint, 2, headPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}