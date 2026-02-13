import 'package:flutter/material.dart';

/// Animation curves
@immutable
class AnimationCurves {
  final Curve emphasize;
  final Curve decelerate;
  final Curve standard;
  final Curve accelerate;
  final Curve bounce;

  const AnimationCurves(
      {required this.emphasize,
      required this.decelerate,
      required this.standard,
      required this.accelerate,
      required this.bounce});

  factory AnimationCurves.toss() => const AnimationCurves(
      emphasize: Curves.easeOutBack,
      decelerate: Curves.decelerate,
      standard: Curves.easeInOutCubic,
      accelerate: Curves.easeIn,
      bounce: Curves.elasticOut);

  static AnimationCurves lerp(AnimationCurves a, AnimationCurves b, double t) {
    // Curves don't interpolate, return a or b based on t
    return t < 0.5 ? a : b;
  }
}
