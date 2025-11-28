import 'package:flutter/material.dart';
import 'utils.dart';

/// Animation durations
@immutable
class AnimationDurations {
  final Duration instant;
  final Duration fast;
  final Duration short;
  final Duration medium;
  final Duration long;
  final Duration veryLong;
  final Duration pageTransition;
  final Duration complexAnimation;

  const AnimationDurations({
    required this.instant,
    required this.fast,
    required this.short,
    required this.medium,
    required this.long,
    required this.veryLong,
    required this.pageTransition,
    required this.complexAnimation});

  factory AnimationDurations.standard() => const AnimationDurations(
        instant: Duration(milliseconds: 50),
        fast: Duration(milliseconds: 100),
        short: Duration(milliseconds: 200),
        medium: Duration(milliseconds: 300),
        long: Duration(milliseconds: 500),
        veryLong: Duration(milliseconds: 800),
        pageTransition: Duration(milliseconds: 300),
        complexAnimation: Duration(milliseconds: 1000));

  static AnimationDurations lerp(AnimationDurations a, AnimationDurations b, double t) {
    return AnimationDurations(
      instant: Duration(milliseconds: lerpDouble(a.instant.inMilliseconds, b.instant.inMilliseconds, t)!.round()),
      fast: Duration(milliseconds: lerpDouble(a.fast.inMilliseconds, b.fast.inMilliseconds, t)!.round()),
      short: Duration(milliseconds: lerpDouble(a.short.inMilliseconds, b.short.inMilliseconds, t)!.round()),
      medium: Duration(milliseconds: lerpDouble(a.medium.inMilliseconds, b.medium.inMilliseconds, t)!.round()),
      long: Duration(milliseconds: lerpDouble(a.long.inMilliseconds, b.long.inMilliseconds, t)!.round()),
      veryLong: Duration(milliseconds: lerpDouble(a.veryLong.inMilliseconds, b.veryLong.inMilliseconds, t)!.round()),
      pageTransition: Duration(milliseconds: lerpDouble(a.pageTransition.inMilliseconds, b.pageTransition.inMilliseconds, t)!.round()),
      complexAnimation: Duration(milliseconds: lerpDouble(a.complexAnimation.inMilliseconds, b.complexAnimation.inMilliseconds, t)!.round()));
  }
}
