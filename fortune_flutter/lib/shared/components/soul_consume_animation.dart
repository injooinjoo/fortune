import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../glassmorphism/glass_container.dart';
import '../../core/utils/haptic_utils.dart';

class SoulConsumeAnimation {
  static OverlayEntry? _currentOverlay;

  static void show({
    required BuildContext context,
    required int soulAmount,
    Offset? startPosition,
    Offset? endPosition,
  }) {
    // Remove any existing overlay
    _currentOverlay?.remove();
    _currentOverlay = null;

    // Default positions
    final size = MediaQuery.of(context).size;
    final defaultStart = Offset(size.width - 60, 60); // From top right
    final defaultEnd = Offset(size.width / 2, size.height * 0.4); // To center

    // Create new overlay
    _currentOverlay = OverlayEntry(
      builder: (context) => _SoulConsumeAnimationWidget(
        soulAmount: soulAmount,
        startPosition: startPosition ?? defaultStart,
        endPosition: endPosition ?? defaultEnd,
        onComplete: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
        },
      ),
    );

    // Insert overlay
    Overlay.of(context).insert(_currentOverlay!);

    // Haptic feedback
    HapticUtils.lightImpact();
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

class _SoulConsumeAnimationWidget extends StatefulWidget {
  final int soulAmount;
  final Offset startPosition;
  final Offset endPosition;
  final VoidCallback onComplete;

  const _SoulConsumeAnimationWidget({
    required this.soulAmount,
    required this.startPosition,
    required this.endPosition,
    required this.onComplete,
  });

  @override
  State<_SoulConsumeAnimationWidget> createState() => _SoulConsumeAnimationWidgetState();
}

class _SoulConsumeAnimationWidgetState extends State<_SoulConsumeAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _positionAnimation;
  
  final List<_Particle> _particles = [];
  
  @override
  void initState() {
    super.initState();
    
    // Main animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Scale animation - starts normal, gets bigger then smaller
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_mainController);
    
    // Fade animation
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 50,
      ),
    ]).animate(_mainController);
    
    // Position animation with curve
    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInBack,
    ));
    
    // Generate particles
    _generateParticles();
    
    // Start animations
    _mainController.forward();
    _particleController.forward();
    
    // Complete callback
    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }
  
  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < 6; i++) {
      _particles.add(_Particle(
        angle: (i * math.pi / 3) + (random.nextDouble() * math.pi / 6),
        distance: 30.0 + random.nextDouble() * 20,
        delay: Duration(milliseconds: random.nextInt(150)),
        size: 3.0 + random.nextDouble() * 3,
      ));
    }
  }
  
  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Stack(
          children: [
            // Particles flowing inward
            ..._particles.map((particle) => Positioned(
              left: widget.startPosition.dx - 20,
              top: widget.startPosition.dy - 20,
              child: FadeTransition(
                opacity: Tween<double>(
                  begin: 1.0,
                  end: 0.0,
                ).animate(CurvedAnimation(
                  parent: _particleController,
                  curve: const Interval(
                    0.4,
                    1.0,
                    curve: Curves.easeOut,
                  ),
                )),
                child: Transform.translate(
                  offset: Offset(
                    math.cos(particle.angle) * particle.distance * (1 - _particleController.value),
                    math.sin(particle.angle) * particle.distance * (1 - _particleController.value),
                  ),
                  child: Container(
                    width: particle.size,
                    height: particle.size,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.4),
                          blurRadius: 3,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: particle.delay)
                  .fadeIn(duration: 200.ms),
              ),
            )),
            
            // Main soul animation
            Positioned(
              left: _positionAnimation.value.dx - 60,
              top: _positionAnimation.value.dy - 30,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: GlassContainer(
                    width: 120,
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    borderRadius: BorderRadius.circular(30),
                    blur: 20,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.orange,
                          size: 24,
                        ).animate(onPlay: (controller) => controller.repeat())
                          .rotate(duration: 1500.ms, end: -2 * math.pi),
                        const SizedBox(width: 8),
                        Text(
                          '-${widget.soulAmount}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final Duration delay;
  final double size;
  
  _Particle({
    required this.angle,
    required this.distance,
    required this.delay,
    required this.size,
  });
}