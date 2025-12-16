import 'package:flutter/material.dart';

/// Korean Traditional "Saaju" animation system
///
/// Design Philosophy: Slow, meditative animations that evoke
/// the feeling of ink spreading on hanji paper (번짐 효과)
///
/// Usage:
/// ```dart
/// // Breathing fade (ink spread effect)
/// child.animate()
///   .fadeIn(duration: DSAnimation.breathingFade, curve: DSAnimation.breathingCurve)
///   .scale(begin: Offset(0.98, 0.98), end: Offset(1, 1));
///
/// // Standard animation
/// AnimatedContainer(
///   duration: DSAnimation.durationMedium,
///   curve: DSAnimation.curveStandard,
/// )
/// ```
class DSAnimation {
  DSAnimation._();

  // ============================================
  // DURATIONS - General
  // ============================================

  /// 100ms - Micro interactions (ripples, hover states)
  static const Duration durationFast = Duration(milliseconds: 100);

  /// 150ms - Quick transitions, button tap
  static const Duration durationQuick = Duration(milliseconds: 150);

  /// 200ms - Standard transitions, button release
  static const Duration durationMedium = Duration(milliseconds: 200);

  /// 300ms - Complex transitions
  static const Duration durationSlow = Duration(milliseconds: 300);

  /// 400ms - Page transitions
  static const Duration durationPage = Duration(milliseconds: 400);

  /// 500ms - Long animations
  static const Duration durationLong = Duration(milliseconds: 500);

  /// 800ms - Breathing fade, ink spread effect
  static const Duration durationXLong = Duration(milliseconds: 800);

  /// 1000ms - Meditative loading
  static const Duration durationMeditative = Duration(milliseconds: 1000);

  /// 1200ms - Slow ink loading animation
  static const Duration durationInkLoading = Duration(milliseconds: 1200);

  // ============================================
  // CURVES
  // ============================================

  /// Standard ease - default for most animations
  static const Curve curveStandard = Curves.easeInOut;

  /// Emphasized ease - for important transitions
  static const Curve curveEmphasized = Curves.easeOutCubic;

  /// Decelerate - for incoming elements
  static const Curve curveDecelerate = Curves.decelerate;

  /// Accelerate - for outgoing elements
  static const Curve curveAccelerate = Curves.easeIn;

  /// Bounce - for playful interactions
  static const Curve curveBounce = Curves.bounceOut;

  /// Elastic - for spring-like effects
  static const Curve curveElastic = Curves.elasticOut;

  /// Linear - for constant speed
  static const Curve curveLinear = Curves.linear;

  /// Fast out, slow in - entering elements
  static const Curve curveFastOutSlowIn = Curves.fastOutSlowIn;

  // ============================================
  // INK-SPREAD ANIMATIONS (번짐 효과)
  // Korean Traditional breathing animations
  // ============================================

  /// Breathing fade - slow ink spreading on paper (800ms)
  static const Duration breathingFade = durationXLong;

  /// Breathing curve - smooth ease in-out for meditative feel
  static const Curve breathingCurve = Curves.easeInOut;

  /// Ink spread animation - content appearing like ink on hanji
  static const Duration inkSpread = durationXLong;

  /// Ink spread curve
  static const Curve inkSpreadCurve = Curves.easeOut;

  /// Fortune reveal - slow, mystical content reveal (1000ms)
  static const Duration fortuneReveal = durationMeditative;

  /// Fortune reveal curve
  static const Curve fortuneRevealCurve = Curves.easeInOutCubic;

  // ============================================
  // SEAL/STAMP ANIMATIONS (인장 효과)
  // Button press animations
  // ============================================

  /// Seal press - button tap down (150ms)
  static const Duration sealPress = durationQuick;

  /// Seal release - button tap up with slight bounce (200ms)
  static const Duration sealRelease = durationMedium;

  /// Seal press scale factor
  static const double sealPressScale = 0.97;

  /// Seal press curve
  static const Curve sealPressCurve = Curves.easeIn;

  /// Seal release curve
  static const Curve sealReleaseCurve = Curves.easeOutCubic;

  // ============================================
  // CARD ANIMATIONS (한지 카드)
  // Hanji card interactions
  // ============================================

  /// Card tap - subtle scale on touch (150ms)
  static const Duration cardTap = durationQuick;

  /// Card tap scale factor
  static const double cardTapScale = 0.98;

  /// Card tap curve
  static const Curve cardTapCurve = Curves.easeIn;

  /// Card release - return to normal with soft ease (200ms)
  static const Duration cardRelease = durationMedium;

  /// Card release curve
  static const Curve cardReleaseCurve = Curves.easeOutCubic;

  /// Card hover - ink border darkens
  static const Duration cardHover = durationMedium;

  // ============================================
  // SEMANTIC ANIMATIONS
  // ============================================

  /// Button press animation duration
  static const Duration buttonPress = sealPress;

  /// Toggle switch animation duration
  static const Duration toggleSwitch = durationMedium;

  /// Modal show/hide duration
  static const Duration modalTransition = durationSlow;

  /// Bottom sheet slide duration
  static const Duration bottomSheetSlide = durationSlow;

  /// Page transition duration
  static const Duration pageTransition = durationPage;

  /// Loading indicator rotation - slow, meditative (1200ms)
  static const Duration loadingRotation = durationInkLoading;

  /// Skeleton shimmer duration
  static const Duration shimmer = Duration(milliseconds: 1500);

  /// Toast show/hide duration
  static const Duration toastTransition = durationMedium;

  /// Fade in/out duration - breathing fade for traditional feel
  static const Duration fade = breathingFade;

  /// Scale animation duration
  static const Duration scale = durationMedium;

  // ============================================
  // SEMANTIC CURVES
  // ============================================

  /// Default UI animation curve
  static const Curve curveDefault = curveStandard;

  /// Button animation curve - seal press feel
  static const Curve curveButton = sealReleaseCurve;

  /// Toggle animation curve
  static const Curve curveToggle = curveEmphasized;

  /// Modal animation curve
  static const Curve curveModal = curveEmphasized;

  /// Page transition curve - fade with ink spread
  static const Curve curvePage = breathingCurve;

  /// List item stagger curve - ink appearing sequentially
  static const Curve curveStagger = inkSpreadCurve;

  /// Card animation curve
  static const Curve curveCard = cardReleaseCurve;

  /// Fortune content curve
  static const Curve curveFortune = fortuneRevealCurve;

  // ============================================
  // STAGGER DELAYS (순차 애니메이션)
  // For list items appearing like ink drops
  // ============================================

  /// Stagger delay between items - ink drop effect
  static const Duration staggerDelay = Duration(milliseconds: 50);

  /// Stagger delay for fortune content
  static const Duration fortuneStaggerDelay = Duration(milliseconds: 80);

  /// Stagger delay for card grid
  static const Duration cardStaggerDelay = Duration(milliseconds: 60);
}

/// Animation scheme for context-based access
class DSAnimationScheme {
  const DSAnimationScheme();

  // Durations
  Duration get fast => DSAnimation.durationFast;
  Duration get quick => DSAnimation.durationQuick;
  Duration get medium => DSAnimation.durationMedium;
  Duration get slow => DSAnimation.durationSlow;
  Duration get page => DSAnimation.durationPage;

  // Ink-spread (번짐)
  Duration get breathingFade => DSAnimation.breathingFade;
  Curve get breathingCurve => DSAnimation.breathingCurve;
  Duration get inkSpread => DSAnimation.inkSpread;
  Duration get fortuneReveal => DSAnimation.fortuneReveal;

  // Seal/Stamp (인장)
  Duration get sealPress => DSAnimation.sealPress;
  Duration get sealRelease => DSAnimation.sealRelease;
  double get sealPressScale => DSAnimation.sealPressScale;

  // Card (한지 카드)
  Duration get cardTap => DSAnimation.cardTap;
  Duration get cardRelease => DSAnimation.cardRelease;
  double get cardTapScale => DSAnimation.cardTapScale;

  // Stagger
  Duration get staggerDelay => DSAnimation.staggerDelay;
  Duration get fortuneStaggerDelay => DSAnimation.fortuneStaggerDelay;

  // Loading
  Duration get loadingRotation => DSAnimation.loadingRotation;
}
