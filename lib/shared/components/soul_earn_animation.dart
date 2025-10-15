import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../glassmorphism/glass_container.dart';
import '../../core/utils/haptic_utils.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_animations.dart';

class SoulEarnAnimation {
  static OverlayEntry? _currentOverlay;

  static void show({
    required BuildContext context,
    required int soulAmount,
    Offset? startPosition,
    Offset? endPosition}) {
    // Remove any existing overlay
    _currentOverlay?.remove();
    _currentOverlay = null;

    // Default positions
    final size = MediaQuery.of(context).size;
    final defaultStart = Offset(size.width / 2, size.height * 0.4);
    final defaultEnd = Offset(size.width - 60, 60); // Top right corner

    // Create new overlay
    _currentOverlay = OverlayEntry(
      builder: (context) => _SoulEarnAnimationWidget(
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
    HapticUtils.success();
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

class _SoulEarnAnimationWidget extends StatefulWidget {
  final int soulAmount;
  final Offset startPosition;
  final Offset endPosition;
  final VoidCallback onComplete;

  const _SoulEarnAnimationWidget({
    required this.soulAmount,
    required this.startPosition,
    required this.endPosition,
    required this.onComplete,
  });

  @override
  State<_SoulEarnAnimationWidget> createState() => _SoulEarnAnimationWidgetState();
}

class _SoulEarnAnimationWidgetState extends State<_SoulEarnAnimationWidget>
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
      duration: AppAnimations.durationSkeleton,
      vsync: this,
    );
    
    // Particle animation controller
    _particleController = AnimationController(
      duration: AppAnimations.durationLong * 2,
      vsync: this,
    );
    
    // Scale animation - starts big, then normal, then small
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 40),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.3).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20)
    ]).animate(_mainController);
    
    // Fade animation
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 20),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 60),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 20)
    ]).animate(_mainController);
    
    // Position animation with curve
    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeInOut)));
    
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
        distance: 50.0 + random.nextDouble() * 30,
        delay: Duration(milliseconds: random.nextInt(200)),
        size: 4.0 + random.nextDouble() * 4));
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
            // Particles
            ..._particles.map((particle) => Positioned(
              left: widget.startPosition.dx - 20,
              top: widget.startPosition.dy - 20,
              child: FadeTransition(
                opacity: Tween<double>(
                  begin: 0.0,
                  end: 1.0).animate(CurvedAnimation(
                  parent: _particleController,
                  curve: Interval(
                    0.0,
                    0.6,
                    curve: Curves.easeOut))),
                child: Transform.translate(
                  offset: Offset(
                    math.cos(particle.angle) * particle.distance * _particleController.value,
                    math.sin(particle.angle) * particle.distance * _particleController.value),
                  child: Container(
                    width: particle.size,
                    height: particle.size,
                    decoration: BoxDecoration(
                      color: TossDesignSystem.warningOrange.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: TossDesignSystem.warningOrange.withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1)
                      ],
                    ),
                  ),
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1000.ms, color: TossDesignSystem.grayDark900.withValues(alpha: 0.3))
                  .fadeOut(delay: particle.delay, duration: 400.ms)),
            
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
                    height: AppSpacing.spacing15,
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing3),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXxLarge),
                    blur: 20,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: TossDesignSystem.warningOrange,
                          size: AppDimensions.iconSizeMedium).animate(onPlay: (controller) => controller.repeat())
                          .rotate(duration: 2000.ms)
                          .shimmer(duration: 1500.ms, color: TossDesignSystem.grayDark900),
                        SizedBox(width: AppSpacing.spacing2),
                        Text(
                          '+${widget.soulAmount}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: TossDesignSystem.warningOrange,
                            fontWeight: FontWeight.bold)).animate()
                          .fadeIn(delay: 200.ms, duration: 300.ms)
                          .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 300.ms),
                      ],
                    ),
                  ).animate()
                    .custom(
                      duration: 1000.ms,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, math.sin(value * math.pi * 2) * 5),
                          child: child,
                        );
                      },
                    ),
                ),
              ),
            ),
          ],
        );
      });
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
    required this.size});
}