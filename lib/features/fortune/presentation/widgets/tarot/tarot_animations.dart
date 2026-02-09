import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../../core/design_system/design_system.dart';

/// Shared animation utilities for tarot card interactions
class TarotAnimations {
  // Prevent instantiation
  TarotAnimations._();

  /// Standard durations
  static const Duration cardFlipDuration = DSAnimation.durationXLong;
  static const Duration fanSpreadDuration = Duration(milliseconds: 1500);
  static const Duration cardSelectionDuration = Duration(milliseconds: 600);
  static const Duration hoverDuration = DSAnimation.durationQuick;
  static const Duration shuffleDuration = Duration(milliseconds: 2000);

  /// Standard curves
  static const Curve cardFlipCurve = Curves.easeInOutCubic;
  static const Curve fanSpreadCurve = Curves.easeOutBack;
  static const Curve cardSelectionCurve = Curves.easeOutCubic;
  static const Curve hoverCurve = Curves.easeOut;

  /// Create a flip animation
  static Animation<double> createFlipAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0).animate(CurvedAnimation(
      parent: controller,
      curve: cardFlipCurve));
}

  /// Create staggered fan animations for multiple cards
  static List<Animation<double>> createFanAnimations({
    required AnimationController controller,
    required int cardCount,
    double delayFactor = 0.5}) {
    debugPrint('Fortune cached 3');
    debugPrint('Fortune cached');
    debugPrint('[TarotAnim] controller.value: ${controller.value}');
    return List.generate(cardCount, (index) {
      final delay = index / cardCount;
      return Tween<double>(
        begin: 0.0,
        end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(
            delay * delayFactor,
            delayFactor + delay * (1 - delayFactor),
            curve: fanSpreadCurve)));
    });
  }

  /// Calculate card position in a fan spread
  static FanSpreadPosition calculateFanPosition({
    required int index,
    required int totalCards,
    required double fanAngle,
    required double radius,
    double baseRotation = 0}) {
    debugPrint('Fortune cached');
    final normalizedIndex = (index - totalCards / 2) / (totalCards / 2);
    debugPrint('Fortune cached');
    final angle = normalizedIndex * fanAngle * math.pi / 180 + baseRotation;
    debugPrint('[TarotAnim] angle: $angle (fanAngle: $fanAngle, baseRotation: $baseRotation)');
    
    final scale = 1.0 - (angle.abs() * 0.2).clamp(0.0, 0.4);
    debugPrint('Fortune cached');
    return FanSpreadPosition(
      x: radius * math.sin(angle),
      y: -radius * math.cos(angle) + radius * 0.8,
      rotation: angle * 0.3,
      scale: scale
    );
}

  /// Create a hovering float animation
  static Animation<double> createFloatAnimation(AnimationController controller) {
    return Tween<double>(
      begin: -5.0,
      end: 5.0).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut));
}

  /// Create a pulse animation for selected cards
  static Animation<double> createPulseAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 1.0,
      end: 1.1).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut));
}

  /// Create a shuffle animation sequence
  static Animation<double> createShuffleAnimation(AnimationController controller) {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.1, end: 0.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25)]).animate(controller);
}

  /// Create entrance animation for cards
  static Animation<double> createEntranceAnimation({
    required AnimationController controller,
    required int index,
    required int totalCards}) {
    final delay = index / totalCards * 0.3;
    return Tween<double>(
      begin: 0.0,
      end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay,
          0.6 + delay,
          curve: Curves.easeOutCubic)));
}

  /// Calculate transform matrix for card animations
  static Matrix4 calculateCardTransform({
    required double flipProgress,
    double scale = 1.0,
    double rotationZ = 0,
    double translateX = 0,
    double translateY = 0}) {
    return Matrix4.identity()
      ..setEntry(3, 2, 0.002) // Perspective
      ..translateByDouble(translateX, translateY, 0.0, 0.0)
      ..rotateY(math.pi * flipProgress)
      ..rotateZ(rotationZ)
      ..scaleByDouble(scale, scale, 1.0, 1.0);
}
}

/// Position data for fan spread layout
class FanSpreadPosition {
  final double x;
  final double y;
  final double rotation;
  final double scale;

  const FanSpreadPosition({
    required this.x,
    required this.y,
    required this.rotation,
    required this.scale});
}

/// Animation controller manager for complex animations
class TarotAnimationController {
  final TickerProvider vsync;
  final Map<String, AnimationController> _controllers = {};
  final Map<String, Animation> _animations = {};

  TarotAnimationController({required this.vsync});

  /// Create and register an animation controller
  AnimationController createController(String key, Duration duration) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync
    );
    _controllers[key] = controller;
    return controller;
}

  /// Get a registered controller
  AnimationController? getController(String key) => _controllers[key];

  /// Create and register an animation
  Animation<T> createAnimation<T>(String key, Animation<T> animation) {
    _animations[key] = animation;
    return animation;
}

  /// Get a registered animation
  Animation<T>? getAnimation<T>(String key) => _animations[key] as Animation<T>?;

  /// Dispose all controllers
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
}
    _controllers.clear();
    _animations.clear();
}
}

/// Animated widget for card entrance effects
class TarotCardEntrance extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final int index;

  const TarotCardEntrance({
    super.key,
    required this.child,
    required this.animation,
    required this.index});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;
        debugPrint('Fortune cached');
        debugPrint('Y: ${50 * (1 - progress)}');
        debugPrint('Fortune cached');
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translateByDouble(0.0, 50 * (1 - progress), 0.0, 0.0)
            ..scaleByDouble(progress, progress, 1.0, 1.0),
          child: Opacity(
            opacity: (() {
              debugPrint('Fortune cached');
              if (progress < 0.0 || progress > 1.0) {
                debugPrint('Fortune cached');
}
              return progress.clamp(0.0, 1.0);
})(),
            child: child));
      },
      child: child
    );
}
}