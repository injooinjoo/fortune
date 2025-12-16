import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/constants/tarot_metadata.dart';
import '../../../../core/design_system/design_system.dart';
import 'package:fortune/core/theme/fortune_colors.dart';

class TarotCardRevealWidget extends StatefulWidget {
  final int cardIndex;
  final bool isRevealed;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final bool showGlow;
  final bool showParticles;

  const TarotCardRevealWidget({
    super.key,
    required this.cardIndex,
    required this.isRevealed,
    this.onTap,
    this.width = 180,
    this.height = 280,
    this.showGlow = true,
    this.showParticles = true});

  @override
  State<TarotCardRevealWidget> createState() => _TarotCardRevealWidgetState();
}

class _TarotCardRevealWidgetState extends State<TarotCardRevealWidget>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _glowController;
  late AnimationController _floatController;
  late AnimationController _particleController;
  late AnimationController _auraController;
  late Animation<double> _flipAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _auraAnimation;
  
  bool _isFlipping = false;
  bool _showFront = false;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    
    _flipController = AnimationController(
      duration: DSAnimation.durationSlow * 2,
      vsync: this);
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this)..repeat(reverse: true);
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this)..repeat(reverse: true);
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this
    );
    
    _auraController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this)..repeat(reverse: true);
    
    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut));
    
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut));
    
    _floatAnimation = Tween<double>(
      begin: -5,
      end: 5).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut));
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1),
        weight: 30),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 0.95),
        weight: 20),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0),
        weight: 50)]).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut));
    
    _auraAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0).animate(CurvedAnimation(
      parent: _auraController,
      curve: Curves.easeInOut));
    
    _flipAnimation.addListener(() {
      if (_flipAnimation.value >= 0.5 && !_showFront) {
        setState(() {
          _showFront = true;
          if (widget.showParticles) {
            _generateParticles();
            _particleController.forward();
          }
        });
      }
    });
}
  
  void _generateParticles() {
    final random = math.Random();
    _particles.clear();
    
    for (int i = 0; i < 20; i++) {
      _particles.add(_Particle(
        position: Offset(
          widget.width / 2 + (random.nextDouble() - 0.5) * widget.width,
          widget.height / 2 + (random.nextDouble() - 0.5) * widget.height),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 100,
          -random.nextDouble() * 150 - 50),
        size: random.nextDouble() * 4 + 2,
        color: [
          Colors.white,
          FortuneColors.spiritualPrimary,
          FortuneColors.spiritualPrimary,
          DSColors.accentTertiary.withValues(alpha: 0.3)][random.nextInt(4)],
        lifespan: random.nextDouble() * 0.5 + 0.5));
    }
  }

  @override
  void didUpdateWidget(TarotCardRevealWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isRevealed && !oldWidget.isRevealed) {
      _flip();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    _particleController.dispose();
    _auraController.dispose();
    super.dispose();
}

  void _flip() async {
    if (_isFlipping) return;
    
    setState(() {
      _isFlipping = true;
    });
    
    HapticFeedback.mediumImpact();
    await _flipController.forward();
    
    setState(() {
      _isFlipping = false;
    });
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Aura effect behind card
          if (widget.showGlow)
            AnimatedBuilder(
              animation: _auraAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _AuraPainter(
                    animation: _auraAnimation.value,
                    color: FortuneColors.spiritualPrimary),
                  size: Size(widget.width * 1.5, widget.height * 1.5),
                );
              },
            ),
          
          // Main card with animations
          AnimatedBuilder(
            animation: Listenable.merge([
              _flipAnimation,
              _floatAnimation,
              _glowAnimation,
              _scaleAnimation]),
            builder: (context, child) {
              final isShowingFront = _showFront;
              
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002) // Perspective
                  ..rotateY(math.pi * _flipAnimation.value)
                  ..translate(0.0, _floatAnimation.value)
                  ..scale(_scaleAnimation.value, _scaleAnimation.value),
                child: SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: isShowingFront
                      ? _buildFrontSide()
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: _buildBackSide()),
                ),
              );
            },
          ),
          
          // Particle effects
          if (widget.showParticles) AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    particles: _particles,
                    progress: _particleController.value),
                  size: Size(widget.width * 2, widget.height * 2),
                );
              },
            ),
        ],
      ),
    );
}

  Widget _buildBackSide() {
    return Stack(
      children: [
        // Card back with enhanced design
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DSRadius.md),
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                FortuneColors.tarotDark,
                FortuneColors.tarotDarker,
                FortuneColors.tarotDarkest],
              stops: const [0.0, 0.6, 1.0]),
            boxShadow: [
              if (widget.showGlow)
                BoxShadow(
                  color: FortuneColors.spiritualPrimary.withValues(alpha: 0.5 * _glowAnimation.value),
                  blurRadius: 30 + 10 * _glowAnimation.value,
                  spreadRadius: 5)]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DSRadius.md),
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: _EnhancedCardBackPatternPainter(
                      glowAnimation: _glowAnimation.value)),
                ),
                
                // Center mystical design
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating mandala
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 2 * math.pi),
                        duration: const Duration(seconds: 30),
                        builder: (context, value, child) {
                          return Transform.rotate(
                            angle: value,
                            child: CustomPaint(
                              painter: _MandalaPainter(
                                color: Colors.white.withValues(alpha: 0.1)),
                              size: const Size(140, 140),
                            ),
                          );
                        },
                        onEnd: () {
                          // Animation repeats automatically
                        },
                      ),
                      
                      // Center emblem
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.2),
                              Colors.transparent]),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2)),
                        child: Center(
                          child: Icon(
                            Icons.auto_awesome,
                            size: 40,
                            color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Mystical particles overlay
                Positioned.fill(
                  child: _FloatingParticlesOverlay(
                    particleCount: 30),
                ),
                
                // Tap hint
                if (widget.onTap != null && !widget.isRevealed)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: FadeTransition(
                      opacity: _glowAnimation,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: FortuneColors.spiritualPrimary.withValues(alpha: 0.3),
                              width: 1)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: 16,
                                color: Colors.white.withValues(alpha: 0.8)),
                              const SizedBox(width: 8),
                              Text(
                                '카드를 터치하세요',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                                  fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // Premium border with gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(DSRadius.md),
                      border: Border.all(
                        width: 4 * 0.5,
                        color: Colors.transparent),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          FortuneColors.spiritualPrimary.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrontSide() {
    final imagePath = _getCardImagePath(widget.cardIndex);
    final cardInfo = TarotMetadata.majorArcana[widget.cardIndex % 22];

    return Stack(
      children: [
        // Card image
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DSRadius.md),
            image: DecorationImage(
              image: AssetImage('assets/images/tarot/$imagePath'),
              fit: BoxFit.cover),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5)),
            ],
          ),
        ),
        
        // Gradient overlay for better text visibility
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),
        
        // Card name
        if (cardInfo != null)
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Text(
              cardInfo.name,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
          ),
        
        // Sparkle effect on reveal
        if (_flipAnimation.value > 0.8)
          Positioned.fill(
            child: _SparkleOverlay(
              // Clamp opacity to valid range [0.0, 1.0] as the calculation could exceed 1.0
              // when _flipAnimation.value approaches 1.0: (1.0 - 0.8) * 5 = 1.0,
              opacity: ((_flipAnimation.value - 0.8) * 5).clamp(0.0, 1.0)),
          ),
        
        // Border
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DSRadius.md),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2),
            ),
          ),
        ),
      ],
    );
  }

  String _getCardImagePath(int cardIndex) {
    // Default to before_tarot deck
    const deckPath = 'decks/before_tarot';
    
    if (cardIndex < 22) {
      // Major Arcana
      final cardNames = [
        'fool', 'magician', 'high_priestess', 'empress', 'emperor',
        'hierophant', 'lovers', 'chariot', 'strength', 'hermit',
        'wheel_of_fortune', 'justice', 'hanged_man', 'death', 'temperance',
        'devil', 'tower', 'star', 'moon', 'sun', 'judgement', 'world'];
      return '$deckPath/major/${cardIndex.toString().padLeft(2, '0')}_${cardNames[cardIndex]}.jpg';
    } else if (cardIndex < 36) {
      // Wands
      final wandsIndex = cardIndex - 21;
      final cardName = wandsIndex <= 10 ? 'of_wands' : _getCourtCardName(wandsIndex, 'wands');
      return '$deckPath/wands/${wandsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else if (cardIndex < 50) {
      // Cups
      final cupsIndex = cardIndex - 35;
      final cardName = cupsIndex <= 10 ? 'of_cups' : _getCourtCardName(cupsIndex, 'cups');
      return '$deckPath/cups/${cupsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else if (cardIndex < 64) {
      // Swords
      final swordsIndex = cardIndex - 49;
      final cardName = swordsIndex <= 10 ? 'of_swords' : _getCourtCardName(swordsIndex, 'swords');
      return '$deckPath/swords/${swordsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else {
      // Pentacles
      final pentaclesIndex = cardIndex - 63;
      final cardName = pentaclesIndex <= 10 ? 'of_pentacles' : _getCourtCardName(pentaclesIndex, 'pentacles');
      return '$deckPath/pentacles/${pentaclesIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    }
  }

  String _getCourtCardName(int index, String suit) {
    switch (index) {
      case 11: return 'page_of_$suit';
      case 12: return 'knight_of_$suit';
      case 13: return 'queen_of_$suit';
      case 14: return 'king_of_$suit';
      default: return 'of_$suit';
    }
  }
}

class _SparkleOverlay extends StatelessWidget {
  final double opacity;

  const _SparkleOverlay({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklePainter(opacity: opacity));
  }
}

class _SparklePainter extends CustomPainter {
  final double opacity;

  _SparklePainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.3)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;
      
      canvas.drawCircle(Offset(x, y), radius * opacity, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Enhanced card back pattern painter
class _EnhancedCardBackPatternPainter extends CustomPainter {
  final double glowAnimation;

  _EnhancedCardBackPatternPainter({required this.glowAnimation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw mystical sacred geometry
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Outer hexagon
    paint.color = Colors.white.withValues(alpha: 0.1 + glowAnimation * 0.05);
    _drawHexagon(canvas, centerX, centerY, 60, paint);
    
    // Inner circles
    for (int i = 1; i <= 3; i++) {
      paint.color = Colors.white.withValues(alpha: 0.05 + glowAnimation * 0.02);
      canvas.drawCircle(Offset(centerX, centerY), i * 20.0, paint);
    }

    // Star patterns
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final x1 = centerX + 40 * math.cos(angle);
      final y1 = centerY + 40 * math.sin(angle);
      final x2 = centerX + 50 * math.cos(angle);
      final y2 = centerY + 50 * math.sin(angle);
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Corner ornaments
    _drawCornerOrnaments(canvas, size, paint);
  }

  void _drawHexagon(Canvas canvas, double cx, double cy, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3 - math.pi / 6;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCornerOrnaments(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.white.withValues(alpha: 0.15 + glowAnimation * 0.05);
    final cornerSize = 15.0;
    
    // Top left
    canvas.drawArc(
      Rect.fromLTWH(0, 0, cornerSize * 2, cornerSize * 2),
      math.pi, math.pi / 2,
      false, paint
    );
    
    // Top right
    canvas.drawArc(
      Rect.fromLTWH(size.width - cornerSize * 2, 0, cornerSize * 2, cornerSize * 2),
      -math.pi / 2, math.pi / 2,
      false, paint
    );
    
    // Bottom left
    canvas.drawArc(
      Rect.fromLTWH(0, size.height - cornerSize * 2, cornerSize * 2, cornerSize * 2),
      math.pi / 2, math.pi / 2,
      false, paint
    );
    
    // Bottom right
    canvas.drawArc(
      Rect.fromLTWH(size.width - cornerSize * 2, size.height - cornerSize * 2, 
                    cornerSize * 2, cornerSize * 2),
      0, math.pi / 2,
      false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Mandala painter for center design
class _MandalaPainter extends CustomPainter {
  final Color color;

  _MandalaPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw mandala pattern
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      
      // Petal shapes
      final path = Path();
      path.moveTo(center.dx, center.dy);
      
      final controlPoint1 = Offset(
        center.dx + radius * 0.5 * math.cos(angle - 0.3),
        center.dy + radius * 0.5 * math.sin(angle - 0.3));
      final controlPoint2 = Offset(
        center.dx + radius * 0.5 * math.cos(angle + 0.3),
        center.dy + radius * 0.5 * math.sin(angle + 0.3));
      final endPoint = Offset(
        center.dx + radius * 0.8 * math.cos(angle),
        center.dy + radius * 0.8 * math.sin(angle));
      
      path.quadraticBezierTo(
        controlPoint1.dx, controlPoint1.dy,
        endPoint.dx, endPoint.dy);
      path.quadraticBezierTo(
        controlPoint2.dx, controlPoint2.dy,
        center.dx, center.dy);
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Aura painter for glow effect
class _AuraPainter extends CustomPainter {
  final double animation;
  final Color color;

  _AuraPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Multiple layers of aura
    for (int i = 3; i > 0; i--) {
      final radius = size.width / 3 * i / 3;
      final opacity = 0.1 * animation * (4 - i) / 3;
      
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: opacity * 0.5),
            Colors.transparent],
          stops: const [0.0, 0.6, 1.0]).createShader(Rect.fromCircle(center: center, radius: radius))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20 + i * 10.0);
      
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Particle painter for magical effects
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    for (final particle in particles) {
      final opacity = progress < particle.lifespan 
          ? (progress < 0.2 ? progress * 5 : 1.0 - (progress - 0.2) / 0.8)
          : 0.0;
      
      if (opacity <= 0) continue;
      
      final position = particle.position + particle.velocity * progress;
      
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(center + position, particle.size, paint);
      
      // Inner bright spot
      final innerPaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(center + position, particle.size * 0.3, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Floating particles overlay widget
class _FloatingParticlesOverlay extends StatefulWidget {
  final int particleCount;

  const _FloatingParticlesOverlay({
    required this.particleCount});

  @override
  State<_FloatingParticlesOverlay> createState() => _FloatingParticlesOverlayState();
}

class _FloatingParticlesOverlayState extends State<_FloatingParticlesOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FloatingParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this)..repeat();
    
    _generateParticles();
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_FloatingParticle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2 + 1,
        speed: random.nextDouble() * 0.02 + 0.01,
        opacity: random.nextDouble() * 0.3 + 0.1));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _FloatingParticlesPainter(
            particles: _particles,
            animation: _controller.value),
          child: Container());
      });
  }
}

class _FloatingParticlesPainter extends CustomPainter {
  final List<_FloatingParticle> particles;
  final double animation;

  _FloatingParticlesPainter({required this.particles, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (final particle in particles) {
      final y = (particle.y - animation * particle.speed) % 1.0;
      final opacity = math.sin(animation * 2 * math.pi + particle.x * 4) * 0.5 + 0.5;
      
      paint.color = Colors.white.withValues(alpha: particle.opacity * opacity);
      
      canvas.drawCircle(
        Offset(particle.x * size.width, y * size.height),
        particle.size,
        paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Particle class
class _Particle {
  final Offset position;
  final Offset velocity;
  final double size;
  final Color color;
  final double lifespan;

  _Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.lifespan});
}

// Floating particle class
class _FloatingParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  _FloatingParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity});
}