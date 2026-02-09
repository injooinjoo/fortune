import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../glassmorphism/glass_container.dart';
import '../../core/utils/haptic_utils.dart';
import '../../core/design_system/design_system.dart';

class TokenCelebrationOverlay {
  static OverlayEntry? _currentOverlay;

  static void show({
    required BuildContext context,
    VoidCallback? onComplete,
  }) {
    // Remove any existing overlay
    _currentOverlay?.remove();
    _currentOverlay = null;

    // Create new overlay
    _currentOverlay = OverlayEntry(
      builder: (context) => _TokenCelebrationWidget(
        onComplete: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
          onComplete?.call();
        },
      ),
    );

    // Insert overlay
    Overlay.of(context).insert(_currentOverlay!);

    // Multiple haptic feedback for celebration
    _triggerCelebrationHaptics();
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  static Future<void> _triggerCelebrationHaptics() async {
    await HapticUtils.success();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticUtils.success();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticUtils.success();
  }
}

class _TokenCelebrationWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const _TokenCelebrationWidget({
    required this.onComplete,
  });

  @override
  State<_TokenCelebrationWidget> createState() =>
      _TokenCelebrationWidgetState();
}

class _TokenCelebrationWidgetState extends State<_TokenCelebrationWidget>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Main animation controller - 2.5 seconds
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Bounce scale animation (0.8 -> 1.2 -> 1.0)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.8).chain(CurveTween(curve: Curves.easeOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.8, end: 1.2).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_mainController);

    // Fade animation
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(_mainController);

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
    for (int i = 0; i < 8; i++) {
      _particles.add(_Particle(
        angle: (i * math.pi / 4) + (random.nextDouble() * math.pi / 8),
        distance: 80.0 + random.nextDouble() * 40,
        delay: Duration(milliseconds: random.nextInt(200)),
        size: 6.0 + random.nextDouble() * 6,
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
    final colors = context.colors;
    final typography = context.typography;
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Stack(
          children: [
            // Semi-transparent background
            Positioned.fill(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            ),

            // Particles
            ..._particles.map((particle) => Positioned(
              left: size.width / 2 - 10,
              top: size.height / 2 - 10,
              child: FadeTransition(
                opacity: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: _particleController,
                  curve: const Interval(
                    0.0,
                    0.6,
                    curve: Curves.easeOut,
                  ),
                )),
                child: Transform.translate(
                  offset: Offset(
                    math.cos(particle.angle) *
                        particle.distance *
                        _particleController.value,
                    math.sin(particle.angle) *
                        particle.distance *
                        _particleController.value,
                  ),
                  child: Container(
                    width: particle.size,
                    height: particle.size,
                    decoration: BoxDecoration(
                      color: colors.accentTertiary.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.accentTertiary.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: 1000.ms,
                    color: colors.textPrimary.withValues(alpha: 0.4),
                  )
                  .fadeOut(delay: particle.delay, duration: 500.ms),
            )),

            // Main token icon and text
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.xxl,
                      vertical: DSSpacing.xl,
                    ),
                    borderRadius: BorderRadius.circular(DSRadius.xxl),
                    blur: 30,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Lucky bag icon
                        const Text(
                          '💰',
                          style: TextStyle(fontSize: 80),
                        )
                            .animate(onPlay: (controller) => controller.repeat())
                            .rotate(
                              duration: 2000.ms,
                              begin: -0.05,
                              end: 0.05,
                            )
                            .then()
                            .rotate(
                              duration: 2000.ms,
                              begin: 0.05,
                              end: -0.05,
                            ),

                        const SizedBox(height: DSSpacing.lg),

                        // Celebration text
                        Text(
                          '토큰 획득!',
                          style: typography.headingSmall.copyWith(
                            color: colors.accentTertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 400.ms)
                            .slideY(
                              begin: 0.3,
                              end: 0,
                              delay: 300.ms,
                              duration: 400.ms,
                            )
                            .shimmer(
                              delay: 700.ms,
                              duration: 1500.ms,
                              color: colors.textPrimary.withValues(alpha: 0.3),
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
