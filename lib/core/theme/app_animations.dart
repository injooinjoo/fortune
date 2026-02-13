import 'package:flutter/material.dart';

/// Animation constants following Toss design system
/// Provides consistent animation values throughout the app
class AppAnimations {
  // Duration constants
  static const Duration durationInstant = Duration(milliseconds: 0);
  static const Duration durationMicro =
      Duration(milliseconds: 50); // Hover, tap feedback
  static const Duration durationShort =
      Duration(milliseconds: 60); // Fade, slide
  static const Duration durationMedium =
      Duration(milliseconds: 80); // Expand, collapse
  static const Duration durationLong =
      Duration(milliseconds: 100); // Page transitions
  static const Duration durationXLong =
      Duration(milliseconds: 800); // Complex animations

  // Specific animation durations
  static const Duration durationFade = durationShort;
  static const Duration durationSlide = durationShort;
  static const Duration durationScale = durationMicro;
  static const Duration durationPageTransition = Duration(milliseconds: 80);
  static const Duration durationBottomSheet = Duration(milliseconds: 80);
  static const Duration durationDialog = durationShort;
  static const Duration durationToast = durationShort;
  static const Duration durationRipple = durationMedium;
  static const Duration durationSkeleton = Duration(milliseconds: 1500);
  static const Duration durationShimmer = Duration(milliseconds: 1200);

  // Delay constants
  static const Duration delayMicro = Duration(milliseconds: 50);
  static const Duration delayShort = Duration(milliseconds: 100);
  static const Duration delayMedium = Duration(milliseconds: 200);
  static const Duration delayLong = Duration(milliseconds: 300);
  static const Duration delayStagger =
      Duration(milliseconds: 50); // For staggered animations

  // Curve constants (following Material Design and Toss patterns,
  static const Curve curveStandard = Curves.easeInOut; // Standard curve
  static const Curve curveDecelerate = Curves.easeOut; // Enter/appear
  static const Curve curveAccelerate = Curves.easeIn; // Exit/disappear
  static const Curve curveSharp = Curves.easeInOutCubic; // Quick movements
  static const Curve curveBounce = Curves.elasticOut; // Playful feedback
  static const Curve curveOvershoot = Curves.easeOutBack; // Emphasis

  // Specific animation curves
  static const Curve curvePageTransition = curveDecelerate;
  static const Curve curveBottomSheet = curveDecelerate;
  static const Curve curveDialog = curveDecelerate;
  static const Curve curveFade = curveStandard;
  static const Curve curveScale = curveOvershoot;
  static const Curve curveSlide = curveDecelerate;
  static const Curve curveExpand = curveStandard;
  static const Curve curveCollapse = curveAccelerate;

  // Animation values
  static const double scalePressed = 0.95;
  static const double scaleHover = 1.02;
  static const double scaleDisabled = 1.0;

  static const double opacityDisabled = 0.38;
  static const double opacityHover = 0.08;
  static const double opacityPressed = 0.12;
  static const double opacityFocus = 0.12;

  // Slide distances
  static const double slideDistanceSmall = 8.0;
  static const double slideDistanceMedium = 16.0;
  static const double slideDistanceLarge = 32.0;

  // Page transition builders
  static Widget fadeTransition(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }

  static Widget slideTransition(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = curvePageTransition;

    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(position: animation.drive(tween), child: child);
  }

  static Widget scaleTransition(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    const curve = curveScale;

    final tween = Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: curve));

    return ScaleTransition(
        scale: animation.drive(tween),
        child: FadeTransition(opacity: animation, child: child));
  }

  // Common animated widgets
  static Widget animatedContainer(
      {required Widget child,
      Duration duration = durationMedium,
      Curve curve = curveStandard}) {
    return AnimatedContainer(duration: duration, curve: curve, child: child);
  }

  static Widget animatedOpacity(
      {required Widget child,
      required double opacity,
      Duration duration = durationShort,
      Curve curve = curveFade}) {
    return AnimatedOpacity(
        opacity: opacity, duration: duration, curve: curve, child: child);
  }

  static Widget animatedScale(
      {required Widget child,
      required double scale,
      Duration duration = durationMicro,
      Curve curve = curveScale}) {
    return AnimatedScale(
        scale: scale, duration: duration, curve: curve, child: child);
  }

  // Stagger animation helper
  static Duration getStaggerDelay(int index, {Duration delay = delayStagger}) {
    return delay * index;
  }

  // Loading animations
  static Widget shimmerLoading(
      {required double width,
      required double height,
      BorderRadius? borderRadius}) {
    return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.3),
            borderRadius: borderRadius ?? BorderRadius.circular(4)));
  }

  // Pulse animation for loading states
  static Widget pulseAnimation(
      {required Widget child, Duration duration = durationSkeleton}) {
    return TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 0.5),
        duration: duration,
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Opacity(opacity: value, child: child);
        },
        child: child,
        onEnd: () {
          // Loop animation
        });
  }

  // Hero animation tag generator
  static String heroTag(String prefix, dynamic id) {
    return '${prefix}_$id';
  }

  // Semantic duration aliases for easier access
  static const Duration instant = durationInstant;
  static const Duration micro = durationMicro;
  static const Duration short = durationShort;
  static const Duration medium = durationMedium;
  static const Duration long = durationLong;
  static const Duration xLong = durationXLong;
  static const Duration fast = durationMicro;
  static const Duration slow = durationLong;
  static const Duration quick = durationShort;
}
