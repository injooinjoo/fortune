import 'package:flutter/material.dart';

/// Claude-inspired Modern Animation System
///
/// Design Philosophy: Smooth & Subtle (부드럽고 미묘함)
///
/// Key Principles:
/// - Custom Easing: Claude's signature cubic-bezier(0.165, 0.85, 0.45, 1)
/// - Subtle Feedback: Not overly dramatic animations
/// - Quick Response: Fast initial reaction, gentle finish
/// - Scale on Press: 0.98 scale (not 0.97)
///
/// Claude animation formula:
/// ```css
/// transition: all 300ms cubic-bezier(0.165, 0.85, 0.45, 1);
/// active:scale-[0.98]
/// ```
///
/// Usage:
/// ```dart
/// AnimatedContainer(
///   duration: DSAnimation.normal,
///   curve: DSAnimation.claude,
/// )
/// ```
class DSAnimation {
  DSAnimation._();

  // ============================================
  // CLAUDE SIGNATURE CURVE
  // cubic-bezier(0.165, 0.85, 0.45, 1)
  // = Fast-out, gentle-in (snappy but smooth)
  // ============================================

  /// Claude's signature animation curve
  /// Fast start, gentle finish - "snappy but smooth"
  static const Curve claude = Cubic(0.165, 0.85, 0.45, 1);

  /// Alias for Claude curve
  static const Curve primary = claude;

  // ============================================
  // DURATIONS - Modern naming
  // ============================================

  /// 50ms - Instant micro interactions
  static const Duration instant = Duration(milliseconds: 50);

  /// 100ms - Micro interactions (ripples, focus states)
  static const Duration micro = Duration(milliseconds: 100);

  /// 150ms - Fast feedback (button press, hover)
  static const Duration fast = Duration(milliseconds: 150);

  /// 200ms - Quick transitions
  static const Duration quick = Duration(milliseconds: 200);

  /// 300ms - Normal transitions (Claude default)
  static const Duration normal = Duration(milliseconds: 300);

  /// 400ms - Page transitions
  static const Duration page = Duration(milliseconds: 400);

  /// 500ms - Slow animations (complex reveals)
  static const Duration slow = Duration(milliseconds: 500);

  /// 800ms - Long animations (content reveals)
  static const Duration long = Duration(milliseconds: 800);

  /// 1000ms - Very long animations (loading states)
  static const Duration xlong = Duration(milliseconds: 1000);

  // ============================================
  // CURVES - Standard library + Claude
  // ============================================

  /// Standard ease - most transitions
  static const Curve standard = Curves.easeInOut;

  /// Emphasized ease - important transitions
  static const Curve emphasized = Curves.easeOutCubic;

  /// Decelerate - incoming elements
  static const Curve decelerate = Curves.decelerate;

  /// Accelerate - outgoing elements
  static const Curve accelerate = Curves.easeIn;

  /// Bounce - playful interactions
  static const Curve bounce = Curves.bounceOut;

  /// Elastic - spring-like effects
  static const Curve elastic = Curves.elasticOut;

  /// Linear - constant speed
  static const Curve linear = Curves.linear;

  /// Fast out, slow in
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  /// Gentle ease for smooth animations
  static const Curve gentle = Curves.easeOutQuart;

  // ============================================
  // PRESS SCALES - Claude uses 0.98
  // ============================================

  /// Button press scale (Claude standard)
  static const double pressScale = 0.98;

  /// Card tap scale (same as press)
  static const double tapScale = 0.98;

  /// Hover scale (slight enlargement)
  static const double hoverScale = 1.02;

  // ============================================
  // SEMANTIC ANIMATIONS - Button/Card
  // ============================================

  /// Button press duration
  static const Duration buttonPress = fast;

  /// Button release duration
  static const Duration buttonRelease = quick;

  /// Button press curve
  static const Curve buttonPressCurve = accelerate;

  /// Button release curve (Claude curve)
  static const Curve buttonReleaseCurve = claude;

  /// Card tap duration
  static const Duration cardTap = fast;

  /// Card release duration
  static const Duration cardRelease = quick;

  /// Card tap curve
  static const Curve cardTapCurve = accelerate;

  /// Card release curve (Claude curve)
  static const Curve cardReleaseCurve = claude;

  /// Card hover duration
  static const Duration cardHover = quick;

  // ============================================
  // SEMANTIC ANIMATIONS - Content
  // ============================================

  /// Content fade in duration
  static const Duration fadeIn = normal;

  /// Content fade in curve (Claude curve)
  static const Curve fadeInCurve = claude;

  /// Content reveal duration
  static const Duration contentReveal = slow;

  /// Content reveal curve
  static const Curve contentRevealCurve = claude;

  /// Result reveal duration (fortune results, etc.)
  static const Duration resultReveal = long;

  /// Result reveal curve
  static const Curve resultRevealCurve = gentle;

  // ============================================
  // SEMANTIC ANIMATIONS - UI Elements
  // ============================================

  /// Toggle switch duration
  static const Duration toggleSwitch = quick;

  /// Modal show/hide duration
  static const Duration modal = slow;

  /// Modal curve (Claude curve)
  static const Curve modalCurve = claude;

  /// Bottom sheet slide duration
  static const Duration bottomSheet = slow;

  /// Bottom sheet curve
  static const Curve bottomSheetCurve = emphasized;

  /// Page transition duration
  static const Duration pageTransition = page;

  /// Page transition curve (Claude curve)
  static const Curve pageTransitionCurve = claude;

  /// Toast show/hide duration
  static const Duration toast = quick;

  /// Shimmer duration for skeleton loaders
  static const Duration shimmer = Duration(milliseconds: 1500);

  /// Loading rotation duration
  static const Duration loading = xlong;

  // ============================================
  // STAGGER DELAYS
  // ============================================

  /// Default stagger delay between items
  static const Duration stagger = Duration(milliseconds: 50);

  /// Card stagger delay
  static const Duration cardStagger = Duration(milliseconds: 60);

  /// Content stagger delay
  static const Duration contentStagger = Duration(milliseconds: 80);

  /// List item stagger delay
  static const Duration listStagger = Duration(milliseconds: 40);

  // ============================================
  // LEGACY COMPATIBILITY - Ink-wash aliases
  // Maps old Korean traditional naming to new
  // ============================================

  /// @deprecated Use [long] instead
  static const Duration breathingFade = long;

  /// @deprecated Use [claude] instead
  static const Curve breathingCurve = standard;

  /// @deprecated Use [long] instead
  static const Duration inkSpread = long;

  /// @deprecated Use [claude] instead
  static const Curve inkSpreadCurve = emphasized;

  /// @deprecated Use [xlong] instead
  static const Duration fortuneReveal = xlong;

  /// @deprecated Use [gentle] instead
  static const Curve fortuneRevealCurve = gentle;

  /// @deprecated Use [fast] instead
  static const Duration sealPress = fast;

  /// @deprecated Use [quick] instead
  static const Duration sealRelease = quick;

  /// @deprecated Use [pressScale] instead
  static const double sealPressScale = pressScale;

  /// @deprecated Use [accelerate] instead
  static const Curve sealPressCurve = accelerate;

  /// @deprecated Use [claude] instead
  static const Curve sealReleaseCurve = claude;

  /// @deprecated Use [tapScale] instead
  static const double cardTapScale = tapScale;

  /// @deprecated Use [xlong] instead
  static const Duration durationMeditative = xlong;

  /// @deprecated Use [loading] instead
  static const Duration durationInkLoading = loading;

  /// @deprecated Use [micro] instead
  static const Duration durationFast = micro;

  /// @deprecated Use [fast] instead
  static const Duration durationQuick = fast;

  /// @deprecated Use [quick] instead
  static const Duration durationMedium = quick;

  /// @deprecated Use [normal] instead
  static const Duration durationSlow = normal;

  /// @deprecated Use [page] instead
  static const Duration durationPage = page;

  /// @deprecated Use [slow] instead
  static const Duration durationLong = slow;

  /// @deprecated Use [long] instead
  static const Duration durationXLong = long;

  /// @deprecated Use [stagger] instead
  static const Duration staggerDelay = stagger;

  /// @deprecated Use [contentStagger] instead
  static const Duration fortuneStaggerDelay = contentStagger;

  /// @deprecated Use [cardStagger] instead
  static const Duration cardStaggerDelay = cardStagger;

  /// @deprecated Use [standard] instead
  static const Curve curveStandard = standard;

  /// @deprecated Use [emphasized] instead
  static const Curve curveEmphasized = emphasized;

  /// @deprecated Use [decelerate] instead
  static const Curve curveDecelerate = decelerate;

  /// @deprecated Use [accelerate] instead
  static const Curve curveAccelerate = accelerate;

  /// @deprecated Use [bounce] instead
  static const Curve curveBounce = bounce;

  /// @deprecated Use [elastic] instead
  static const Curve curveElastic = elastic;

  /// @deprecated Use [linear] instead
  static const Curve curveLinear = linear;

  /// @deprecated Use [fastOutSlowIn] instead
  static const Curve curveFastOutSlowIn = fastOutSlowIn;

  /// @deprecated Use [standard] instead
  static const Curve curveDefault = standard;

  /// @deprecated Use [claude] instead
  static const Curve curveButton = claude;

  /// @deprecated Use [emphasized] instead
  static const Curve curveToggle = emphasized;

  /// @deprecated Use [claude] instead
  static const Curve curveModal = claude;

  /// @deprecated Use [claude] instead
  static const Curve curvePage = claude;

  /// @deprecated Use [emphasized] instead
  static const Curve curveStagger = emphasized;

  /// @deprecated Use [claude] instead
  static const Curve curveCard = claude;

  /// @deprecated Use [gentle] instead
  static const Curve curveFortune = gentle;

  /// @deprecated Use [fadeIn] instead
  static const Duration fade = fadeIn;

  /// @deprecated Use [quick] instead
  static const Duration scale = quick;

  /// @deprecated Use [modal] instead
  static const Duration modalTransition = modal;

  /// @deprecated Use [bottomSheet] instead
  static const Duration bottomSheetSlide = bottomSheet;

  /// @deprecated Use [loading] instead
  static const Duration loadingRotation = loading;

  /// @deprecated Use [toast] instead
  static const Duration toastTransition = toast;
}

/// Animation scheme for context-based access
class DSAnimationScheme {
  const DSAnimationScheme();

  // Durations - Modern naming
  Duration get instant => DSAnimation.instant;
  Duration get micro => DSAnimation.micro;
  Duration get fast => DSAnimation.fast;
  Duration get quick => DSAnimation.quick;
  Duration get normal => DSAnimation.normal;
  Duration get page => DSAnimation.page;
  Duration get slow => DSAnimation.slow;
  Duration get long => DSAnimation.long;
  Duration get xlong => DSAnimation.xlong;

  // Curves
  Curve get claude => DSAnimation.claude;
  Curve get primary => DSAnimation.primary;
  Curve get standard => DSAnimation.standard;
  Curve get emphasized => DSAnimation.emphasized;
  Curve get gentle => DSAnimation.gentle;

  // Scales
  double get pressScale => DSAnimation.pressScale;
  double get tapScale => DSAnimation.tapScale;
  double get hoverScale => DSAnimation.hoverScale;

  // Button animations
  Duration get buttonPress => DSAnimation.buttonPress;
  Duration get buttonRelease => DSAnimation.buttonRelease;
  Curve get buttonCurve => DSAnimation.buttonReleaseCurve;

  // Card animations
  Duration get cardTap => DSAnimation.cardTap;
  Duration get cardRelease => DSAnimation.cardRelease;
  Curve get cardCurve => DSAnimation.cardReleaseCurve;

  // Content animations
  Duration get fadeIn => DSAnimation.fadeIn;
  Duration get contentReveal => DSAnimation.contentReveal;
  Duration get resultReveal => DSAnimation.resultReveal;

  // UI elements
  Duration get modal => DSAnimation.modal;
  Duration get bottomSheet => DSAnimation.bottomSheet;
  Duration get toast => DSAnimation.toast;
  Duration get loading => DSAnimation.loading;

  // Stagger
  Duration get stagger => DSAnimation.stagger;
  Duration get cardStagger => DSAnimation.cardStagger;
  Duration get contentStagger => DSAnimation.contentStagger;

  // Legacy compatibility
  Duration get breathingFade => DSAnimation.breathingFade;
  Curve get breathingCurve => DSAnimation.breathingCurve;
  Duration get inkSpread => DSAnimation.inkSpread;
  Duration get fortuneReveal => DSAnimation.fortuneReveal;
  Duration get sealPress => DSAnimation.sealPress;
  Duration get sealRelease => DSAnimation.sealRelease;
  double get sealPressScale => DSAnimation.sealPressScale;
  double get cardTapScale => DSAnimation.cardTapScale;
  Duration get staggerDelay => DSAnimation.staggerDelay;
  Duration get fortuneStaggerDelay => DSAnimation.fortuneStaggerDelay;
  Duration get loadingRotation => DSAnimation.loadingRotation;
}
