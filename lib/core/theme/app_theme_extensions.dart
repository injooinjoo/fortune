import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom theme extension for Fortune app with TOSS design system
@immutable
class FortuneThemeExtension extends ThemeExtension<FortuneThemeExtension> {
  // 기존 Fortune 색상
  final Color scoreExcellent;
  final Color scoreGood;
  final Color scoreFair;
  final Color scorePoor;
  final Color fortuneGradientStart;
  final Color fortuneGradientEnd;
  final Color glassBackground;
  final Color glassBorder;
  final Color subtitleText;
  final Color dividerColor;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color errorColor;
  final Color successColor;
  final Color warningColor;
  final Color cardBackground;
  final Color cardSurface;
  final Color shadowColor;
  final Color primaryText;
  final Color secondaryText;
  
  // TOSS 디자인 시스템 추가
  // Micro-interactions & Animations
  final MicroInteractions microInteractions;
  final AnimationDurations animationDurations;
  final AnimationCurves animationCurves;
  
  // Loading & Error States  
  final LoadingStates loadingStates;
  final ErrorStates errorStates;
  
  // Haptic Patterns
  final HapticPatterns hapticPatterns;
  
  // Form & Input
  final FormStyles formStyles;
  final BottomSheetStyles bottomSheetStyles;
  final CardStyles cardStyles;
  final DialogStyles dialogStyles;
  
  // Data Visualization
  final DataVisualization dataVisualization;
  
  // Social & Sharing
  final SocialSharingStyles socialSharing;
  
  // Button Styles
  final ButtonStyle? ctaButtonStyle;

  const FortuneThemeExtension({
    required this.scoreExcellent,
    required this.scoreGood,
    required this.scoreFair,
    required this.scorePoor,
    required this.fortuneGradientStart,
    required this.fortuneGradientEnd,
    required this.glassBackground,
    required this.glassBorder,
    required this.subtitleText,
    required this.dividerColor,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.errorColor,
    required this.successColor,
    required this.warningColor,
    required this.cardBackground,
    required this.cardSurface,
    required this.shadowColor,
    required this.primaryText,
    required this.secondaryText,
    required this.microInteractions,
    required this.animationDurations,
    required this.animationCurves,
    required this.loadingStates,
    required this.errorStates,
    required this.hapticPatterns,
    required this.formStyles,
    required this.bottomSheetStyles,
    required this.cardStyles,
    required this.dialogStyles,
    required this.dataVisualization,
    required this.socialSharing,
    this.ctaButtonStyle,
  });

  /// Light theme extension
  static final light = FortuneThemeExtension(
    scoreExcellent: Color(0xFF10B981), // Green,
    scoreGood: Color(0xFF3B82F6), // Blue,
    scoreFair: Color(0xFFF59E0B), // Orange,
    scorePoor: Color(0xFFEF4444), // Red,
    fortuneGradientStart: Color(0xFF000000), // Black,
    fortuneGradientEnd: Color(0xFF4A4A4A), // Medium gray,
    glassBackground: Color(0x0AFFFFFF),
    glassBorder: Color(0x14FFFFFF),
    subtitleText: Color(0xFF6B7280),
    dividerColor: Color(0xFFE5E7EB),
    shimmerBase: Color(0xFFE5E7EB),
    shimmerHighlight: Color(0xFFF3F4F6),
    errorColor: Color(0xFFEF4444), // Red,
    successColor: Color(0xFF10B981), // Green,
    warningColor: Color(0xFFF59E0B), // Orange,
    cardBackground: Color(0xFFF6F6F6), // Light gray background,
    cardSurface: Color(0xFFFFFFFF), // White surface,
    shadowColor: Color(0x1A000000), // Light shadow,
    primaryText: Color(0xFF262626), // Dark text,
    secondaryText: Color(0xFF8E8E8E), // Gray text
    // TOSS 디자인 시스템,
    microInteractions: MicroInteractions.light(),
    animationDurations: AnimationDurations.standard(),
    animationCurves: AnimationCurves.toss(),
    loadingStates: LoadingStates.light(),
    errorStates: ErrorStates.light(),
    hapticPatterns: HapticPatterns.standard(),
    formStyles: FormStyles.light(),
    bottomSheetStyles: BottomSheetStyles.light(),
    cardStyles: CardStyles.light(),
    dialogStyles: DialogStyles.light(),
    dataVisualization: DataVisualization.light(),
    socialSharing: SocialSharingStyles.light(),
    ctaButtonStyle: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  /// Dark theme extension
  static final dark = FortuneThemeExtension(
    scoreExcellent: Color(0xFF34D399), // Lighter green for dark mode,
    scoreGood: Color(0xFF60A5FA), // Lighter blue for dark mode,
    scoreFair: Color(0xFFFBBF24), // Lighter orange for dark mode,
    scorePoor: Color(0xFFF87171), // Lighter red for dark mode,
    fortuneGradientStart: Color(0xFFE0E0E0), // Light gray,
    fortuneGradientEnd: Color(0xFF999999), // Medium light gray,
    glassBackground: Color(0x1A000000), // Dark glass background,
    glassBorder: Color(0x33FFFFFF), // Lighter border for dark mode,
    subtitleText: Color(0xFFB0B0B0), // Light gray for dark mode,
    dividerColor: Color(0xFF2D2D2D), // Dark divider,
    shimmerBase: Color(0xFF1C1C1C), // Dark shimmer base,
    shimmerHighlight: Color(0xFF2D2D2D), // Dark shimmer highlight,
    errorColor: Color(0xFFF87171), // Lighter red for dark mode,
    successColor: Color(0xFF34D399), // Lighter green for dark mode,
    warningColor: Color(0xFFFBBF24), // Lighter orange for dark mode,
    cardBackground: Color(0xFF0A0A0A), // Very dark background,
    cardSurface: Color(0xFF1C1C1C), // Dark surface,
    shadowColor: Color(0x66000000), // Stronger shadow for dark mode,
    primaryText: Color(0xFFF5F5F5), // Off-white text,
    secondaryText: Color(0xFFB0B0B0), // Light gray text
    // TOSS 디자인 시스템,
    microInteractions: MicroInteractions.dark(),
    animationDurations: AnimationDurations.standard(),
    animationCurves: AnimationCurves.toss(),
    loadingStates: LoadingStates.dark(),
    errorStates: ErrorStates.dark(),
    hapticPatterns: HapticPatterns.standard(),
    formStyles: FormStyles.dark(),
    bottomSheetStyles: BottomSheetStyles.dark(),
    cardStyles: CardStyles.dark(),
    dialogStyles: DialogStyles.dark(),
    dataVisualization: DataVisualization.dark(),
    socialSharing: SocialSharingStyles.dark(),
    ctaButtonStyle: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  @override
  FortuneThemeExtension copyWith({
    Color? scoreExcellent,
    Color? scoreGood,
    Color? scoreFair,
    Color? scorePoor,
    Color? fortuneGradientStart,
    Color? fortuneGradientEnd,
    Color? glassBackground,
    Color? glassBorder,
    Color? subtitleText,
    Color? dividerColor,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? errorColor,
    Color? successColor,
    Color? warningColor,
    Color? cardBackground,
    Color? cardSurface,
    Color? shadowColor,
    Color? primaryText,
    Color? secondaryText,
    MicroInteractions? microInteractions,
    AnimationDurations? animationDurations,
    AnimationCurves? animationCurves,
    LoadingStates? loadingStates,
    ErrorStates? errorStates,
    HapticPatterns? hapticPatterns,
    FormStyles? formStyles,
    BottomSheetStyles? bottomSheetStyles,
    CardStyles? cardStyles,
    DialogStyles? dialogStyles,
    DataVisualization? dataVisualization,
    SocialSharingStyles? socialSharing,
    ButtonStyle? ctaButtonStyle,
  }) {
    return FortuneThemeExtension(
      scoreExcellent: scoreExcellent ?? this.scoreExcellent,
      scoreGood: scoreGood ?? this.scoreGood,
      scoreFair: scoreFair ?? this.scoreFair,
      scorePoor: scorePoor ?? this.scorePoor,
      fortuneGradientStart: fortuneGradientStart ?? this.fortuneGradientStart,
      fortuneGradientEnd: fortuneGradientEnd ?? this.fortuneGradientEnd,
      glassBackground: glassBackground ?? this.glassBackground,
      glassBorder: glassBorder ?? this.glassBorder,
      subtitleText: subtitleText ?? this.subtitleText,
      dividerColor: dividerColor ?? this.dividerColor,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      cardBackground: cardBackground ?? this.cardBackground,
      cardSurface: cardSurface ?? this.cardSurface,
      shadowColor: shadowColor ?? this.shadowColor,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      microInteractions: microInteractions ?? this.microInteractions,
      animationDurations: animationDurations ?? this.animationDurations,
      animationCurves: animationCurves ?? this.animationCurves,
      loadingStates: loadingStates ?? this.loadingStates,
      errorStates: errorStates ?? this.errorStates,
      hapticPatterns: hapticPatterns ?? this.hapticPatterns,
      formStyles: formStyles ?? this.formStyles,
      bottomSheetStyles: bottomSheetStyles ?? this.bottomSheetStyles,
      cardStyles: cardStyles ?? this.cardStyles,
      dialogStyles: dialogStyles ?? this.dialogStyles,
      dataVisualization: dataVisualization ?? this.dataVisualization,
      socialSharing: socialSharing ?? this.socialSharing,
      ctaButtonStyle: ctaButtonStyle ?? this.ctaButtonStyle,
    );
  }

  @override
  FortuneThemeExtension lerp(ThemeExtension<FortuneThemeExtension>? other, double t) {
    if (other is! FortuneThemeExtension) {
      return this;
    }
    return FortuneThemeExtension(
      scoreExcellent: Color.lerp(scoreExcellent, other.scoreExcellent, t)!,
      scoreGood: Color.lerp(scoreGood, other.scoreGood, t)!,
      scoreFair: Color.lerp(scoreFair, other.scoreFair, t)!,
      scorePoor: Color.lerp(scorePoor, other.scorePoor, t)!,
      fortuneGradientStart: Color.lerp(fortuneGradientStart, other.fortuneGradientStart, t)!,
      fortuneGradientEnd: Color.lerp(fortuneGradientEnd, other.fortuneGradientEnd, t)!,
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      subtitleText: Color.lerp(subtitleText, other.subtitleText, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      microInteractions: MicroInteractions.lerp(microInteractions, other.microInteractions, t),
      animationDurations: AnimationDurations.lerp(animationDurations, other.animationDurations, t),
      animationCurves: AnimationCurves.lerp(animationCurves, other.animationCurves, t),
      loadingStates: LoadingStates.lerp(loadingStates, other.loadingStates, t),
      errorStates: ErrorStates.lerp(errorStates, other.errorStates, t),
      hapticPatterns: HapticPatterns.lerp(hapticPatterns, other.hapticPatterns, t),
      formStyles: FormStyles.lerp(formStyles, other.formStyles, t),
      bottomSheetStyles: BottomSheetStyles.lerp(bottomSheetStyles, other.bottomSheetStyles, t),
      cardStyles: CardStyles.lerp(cardStyles, other.cardStyles, t),
      dialogStyles: DialogStyles.lerp(dialogStyles, other.dialogStyles, t),
      dataVisualization: DataVisualization.lerp(dataVisualization, other.dataVisualization, t),
      socialSharing: SocialSharingStyles.lerp(socialSharing, other.socialSharing, t),
      ctaButtonStyle: ButtonStyle.lerp(ctaButtonStyle, other.ctaButtonStyle, t),
    );
  }
}

/// Extension method to easily access theme extension
extension FortuneThemeExtensionGetter on BuildContext {
  FortuneThemeExtension get fortuneTheme {
    return Theme.of(this).extension<FortuneThemeExtension>() ?? FortuneThemeExtension.light;
  }
  
  /// TOSS design system shortcuts
  FortuneThemeExtension get toss => fortuneTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

// ============================================================
// TOSS Design System Classes
// ============================================================

/// Micro-interactions configuration
@immutable
class MicroInteractions {
  final double buttonPressScale;
  final double cardHoverElevation;
  final double listItemPressScale;
  final double switchThumbScale;
  final double checkboxScale;
  final double fabPressScale;
  final double iconButtonScale;
  final double chipPressScale;

  const MicroInteractions({
    required this.buttonPressScale,
    required this.cardHoverElevation,
    required this.listItemPressScale,
    required this.switchThumbScale,
    required this.checkboxScale,
    required this.fabPressScale,
    required this.iconButtonScale,
    required this.chipPressScale,
  });

  factory MicroInteractions.light() => const MicroInteractions(
        buttonPressScale: 0.98,
        cardHoverElevation: 4.0,
        listItemPressScale: 0.99,
        switchThumbScale: 1.2,
        checkboxScale: 1.15,
        fabPressScale: 0.96,
        iconButtonScale: 0.95,
        chipPressScale: 0.97,
      );

  factory MicroInteractions.dark() => const MicroInteractions(
        buttonPressScale: 0.97,
        cardHoverElevation: 6.0,
        listItemPressScale: 0.98,
        switchThumbScale: 1.25,
        checkboxScale: 1.2,
        fabPressScale: 0.95,
        iconButtonScale: 0.94,
        chipPressScale: 0.96,
      );

  static MicroInteractions lerp(MicroInteractions a, MicroInteractions b, double t) {
    return MicroInteractions(
      buttonPressScale: lerpDouble(a.buttonPressScale, b.buttonPressScale, t)!,
      cardHoverElevation: lerpDouble(a.cardHoverElevation, b.cardHoverElevation, t)!,
      listItemPressScale: lerpDouble(a.listItemPressScale, b.listItemPressScale, t)!,
      switchThumbScale: lerpDouble(a.switchThumbScale, b.switchThumbScale, t)!,
      checkboxScale: lerpDouble(a.checkboxScale, b.checkboxScale, t)!,
      fabPressScale: lerpDouble(a.fabPressScale, b.fabPressScale, t)!,
      iconButtonScale: lerpDouble(a.iconButtonScale, b.iconButtonScale, t)!,
      chipPressScale: lerpDouble(a.chipPressScale, b.chipPressScale, t)!,
    );
  }
}

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
    required this.complexAnimation,
  });

  factory AnimationDurations.standard() => const AnimationDurations(
        instant: Duration(milliseconds: 50),
        fast: Duration(milliseconds: 100),
        short: Duration(milliseconds: 200),
        medium: Duration(milliseconds: 300),
        long: Duration(milliseconds: 500),
        veryLong: Duration(milliseconds: 800),
        pageTransition: Duration(milliseconds: 300),
        complexAnimation: Duration(milliseconds: 1000),
      );

  static AnimationDurations lerp(AnimationDurations a, AnimationDurations b, double t) {
    return AnimationDurations(
      instant: Duration(milliseconds: lerpDouble(a.instant.inMilliseconds, b.instant.inMilliseconds, t)!.round()),
      fast: Duration(milliseconds: lerpDouble(a.fast.inMilliseconds, b.fast.inMilliseconds, t)!.round()),
      short: Duration(milliseconds: lerpDouble(a.short.inMilliseconds, b.short.inMilliseconds, t)!.round()),
      medium: Duration(milliseconds: lerpDouble(a.medium.inMilliseconds, b.medium.inMilliseconds, t)!.round()),
      long: Duration(milliseconds: lerpDouble(a.long.inMilliseconds, b.long.inMilliseconds, t)!.round()),
      veryLong: Duration(milliseconds: lerpDouble(a.veryLong.inMilliseconds, b.veryLong.inMilliseconds, t)!.round()),
      pageTransition: Duration(milliseconds: lerpDouble(a.pageTransition.inMilliseconds, b.pageTransition.inMilliseconds, t)!.round()),
      complexAnimation: Duration(milliseconds: lerpDouble(a.complexAnimation.inMilliseconds, b.complexAnimation.inMilliseconds, t)!.round()),
    );
  }
}

/// Animation curves
@immutable
class AnimationCurves {
  final Curve emphasize;
  final Curve decelerate;
  final Curve standard;
  final Curve accelerate;
  final Curve bounce;

  const AnimationCurves({
    required this.emphasize,
    required this.decelerate,
    required this.standard,
    required this.accelerate,
    required this.bounce,
  });

  factory AnimationCurves.toss() => const AnimationCurves(
        emphasize: Curves.easeOutBack,
        decelerate: Curves.decelerate,
        standard: Curves.easeInOutCubic,
        accelerate: Curves.easeIn,
        bounce: Curves.elasticOut,
      );

  static AnimationCurves lerp(AnimationCurves a, AnimationCurves b, double t) {
    // Curves don't interpolate, return a or b based on t
    return t < 0.5 ? a : b;
  }
}

/// Loading states configuration
@immutable
class LoadingStates {
  final Color skeletonBase;
  final Color skeletonHighlight;
  final double skeletonOpacity;
  final Duration shimmerDuration;
  final double progressStrokeWidth;
  final double progressBarRadius;
  
  // Aliases for compatibility
  Color get skeletonBaseColor => skeletonBase;
  Color get skeletonHighlightColor => skeletonHighlight;

  const LoadingStates({
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.skeletonOpacity,
    required this.shimmerDuration,
    required this.progressStrokeWidth,
    required this.progressBarRadius,
  });

  factory LoadingStates.light() => const LoadingStates(
        skeletonBase: Color(0xFFE5E7EB),
        skeletonHighlight: Color(0xFFF3F4F6),
        skeletonOpacity: 0.12,
        shimmerDuration: Duration(milliseconds: 1500),
        progressStrokeWidth: 2.0,
        progressBarRadius: 4.0,
      );

  factory LoadingStates.dark() => const LoadingStates(
        skeletonBase: Color(0xFF2D2D2D),
        skeletonHighlight: Color(0xFF3D3D3D),
        skeletonOpacity: 0.08,
        shimmerDuration: Duration(milliseconds: 1500),
        progressStrokeWidth: 2.0,
        progressBarRadius: 4.0,
      );

  static LoadingStates lerp(LoadingStates a, LoadingStates b, double t) {
    return LoadingStates(
      skeletonBase: Color.lerp(a.skeletonBase, b.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(a.skeletonHighlight, b.skeletonHighlight, t)!,
      skeletonOpacity: lerpDouble(a.skeletonOpacity, b.skeletonOpacity, t)!,
      shimmerDuration: Duration(milliseconds: lerpDouble(a.shimmerDuration.inMilliseconds, b.shimmerDuration.inMilliseconds, t)!.round()),
      progressStrokeWidth: lerpDouble(a.progressStrokeWidth, b.progressStrokeWidth, t)!,
      progressBarRadius: lerpDouble(a.progressBarRadius, b.progressBarRadius, t)!,
    );
  }
}

/// Error states configuration
@immutable
class ErrorStates {
  final Color errorBackground;
  final Color errorBorder;
  final IconData errorIcon;
  final double errorIconSize;
  final Duration errorAnimationDuration;

  const ErrorStates({
    required this.errorBackground,
    required this.errorBorder,
    required this.errorIcon,
    required this.errorIconSize,
    required this.errorAnimationDuration,
  });

  factory ErrorStates.light() => const ErrorStates(
        errorBackground: Color(0xFFFEE2E2),
        errorBorder: Color(0xFFFCA5A5),
        errorIcon: Icons.error_outline,
        errorIconSize: 48.0,
        errorAnimationDuration: Duration(milliseconds: 300),
      );

  factory ErrorStates.dark() => const ErrorStates(
        errorBackground: Color(0xFF2D1B1B),
        errorBorder: Color(0xFF991B1B),
        errorIcon: Icons.error_outline,
        errorIconSize: 48.0,
        errorAnimationDuration: Duration(milliseconds: 300),
      );

  static ErrorStates lerp(ErrorStates a, ErrorStates b, double t) {
    return ErrorStates(
      errorBackground: Color.lerp(a.errorBackground, b.errorBackground, t)!,
      errorBorder: Color.lerp(a.errorBorder, b.errorBorder, t)!,
      errorIcon: t < 0.5 ? a.errorIcon : b.errorIcon,
      errorIconSize: lerpDouble(a.errorIconSize, b.errorIconSize, t)!,
      errorAnimationDuration: Duration(milliseconds: lerpDouble(a.errorAnimationDuration.inMilliseconds, b.errorAnimationDuration.inMilliseconds, t)!.round()),
    );
  }
}

/// Haptic patterns
@immutable
class HapticPatterns {
  final HapticType buttonTap;
  final HapticType success;
  final HapticType warning;
  final HapticType error;
  final HapticType selection;

  const HapticPatterns({
    required this.buttonTap,
    required this.success,
    required this.warning,
    required this.error,
    required this.selection,
  });

  factory HapticPatterns.standard() => const HapticPatterns(
        buttonTap: HapticType.light,
        success: HapticType.medium,
        warning: HapticType.medium,
        error: HapticType.heavy,
        selection: HapticType.selection,
      );

  static HapticPatterns lerp(HapticPatterns a, HapticPatterns b, double t) {
    return t < 0.5 ? a : b;
  }
  
  /// Execute haptic feedback
  static Future<void> execute(HapticType type) async {
    switch (type) {
      case HapticType.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
        await HapticFeedback.heavyImpact();
        break;
      case HapticType.selection:
        await HapticFeedback.selectionClick();
        break;
    }
  }
}

/// Haptic feedback types
enum HapticType {
  light,
  medium,
  heavy,
  selection,
  
  
}

/// Form styles
@immutable
class FormStyles {
  final double inputHeight;
  final double inputBorderRadius;
  final double inputBorderWidth;
  final EdgeInsets inputPadding;
  final double labelFontSize;
  final Duration focusAnimationDuration;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color errorBorderColor;
  final double focusBorderWidth;

  const FormStyles({
    required this.inputHeight,
    required this.inputBorderRadius,
    required this.inputBorderWidth,
    required this.inputPadding,
    required this.labelFontSize,
    required this.focusAnimationDuration,
    required this.borderColor,
    required this.focusedBorderColor,
    required this.errorBorderColor,
    required this.focusBorderWidth,
  });

  factory FormStyles.light() => const FormStyles(
        inputHeight: 56.0,
        inputBorderRadius: 12.0,
        inputBorderWidth: 1.0,
        inputPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelFontSize: 14.0,
        focusAnimationDuration: Duration(milliseconds: 200),
        borderColor: Color(0xFFE5E7EB),
        focusedBorderColor: Color(0xFF000000),
        errorBorderColor: Color(0xFFEF4444),
        focusBorderWidth: 2.0,
      );

  factory FormStyles.dark() => const FormStyles(
        inputHeight: 56.0,
        inputBorderRadius: 12.0,
        inputBorderWidth: 1.0,
        inputPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelFontSize: 14.0,
        focusAnimationDuration: Duration(milliseconds: 200),
        borderColor: Color(0xFF2D2D2D),
        focusedBorderColor: Color(0xFFFFFFFF),
        errorBorderColor: Color(0xFFF87171),
        focusBorderWidth: 2.0,
      );

  static FormStyles lerp(FormStyles a, FormStyles b, double t) {
    return FormStyles(
      inputHeight: lerpDouble(a.inputHeight, b.inputHeight, t)!,
      inputBorderRadius: lerpDouble(a.inputBorderRadius, b.inputBorderRadius, t)!,
      inputBorderWidth: lerpDouble(a.inputBorderWidth, b.inputBorderWidth, t)!,
      inputPadding: EdgeInsets.lerp(a.inputPadding, b.inputPadding, t)!,
      labelFontSize: lerpDouble(a.labelFontSize, b.labelFontSize, t)!,
      focusAnimationDuration: Duration(milliseconds: lerpDouble(a.focusAnimationDuration.inMilliseconds, b.focusAnimationDuration.inMilliseconds, t)!.round()),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t)!,
      focusedBorderColor: Color.lerp(a.focusedBorderColor, b.focusedBorderColor, t)!,
      errorBorderColor: Color.lerp(a.errorBorderColor, b.errorBorderColor, t)!,
      focusBorderWidth: lerpDouble(a.focusBorderWidth, b.focusBorderWidth, t)!,
    );
  }
}

/// Bottom sheet styles
@immutable
class BottomSheetStyles {
  final double handleWidth;
  final double handleHeight;
  final double handleOpacity;
  final double maxHeight;
  final double borderRadius;
  final Duration animationDuration;
  final double handleTopMargin;
  final EdgeInsets contentPadding;
  final double titleFontSize;
  final double messageFontSize;
  final double optionFontSize;
  final double subtitleFontSize;
  final double iconSize;
  final double spacing;
  final double largeSpacing;
  final double buttonHeight;
  final double buttonBorderRadius;
  final double barrierOpacity;
  final Duration slideAnimationDuration;
  final Duration fadeAnimationDuration;

  const BottomSheetStyles({
    required this.handleWidth,
    required this.handleHeight,
    required this.handleOpacity,
    required this.maxHeight,
    required this.borderRadius,
    required this.animationDuration,
    required this.handleTopMargin,
    required this.contentPadding,
    required this.titleFontSize,
    required this.messageFontSize,
    required this.optionFontSize,
    required this.subtitleFontSize,
    required this.iconSize,
    required this.spacing,
    required this.largeSpacing,
    required this.buttonHeight,
    required this.buttonBorderRadius,
    required this.barrierOpacity,
    required this.slideAnimationDuration,
    required this.fadeAnimationDuration,
  });

  factory BottomSheetStyles.light() => const BottomSheetStyles(
        handleWidth: 40.0,
        handleHeight: 4.0,
        handleOpacity: 0.4,
        maxHeight: 0.9,
        borderRadius: 24.0,
        animationDuration: Duration(milliseconds: 300),
        handleTopMargin: 12.0,
        contentPadding: EdgeInsets.all(24),
        titleFontSize: 20.0,
        messageFontSize: 15.0,
        optionFontSize: 16.0,
        subtitleFontSize: 14.0,
        iconSize: 24.0,
        spacing: 12.0,
        largeSpacing: 24.0,
        buttonHeight: 52.0,
        buttonBorderRadius: 12.0,
        barrierOpacity: 0.5,
        slideAnimationDuration: Duration(milliseconds: 350),
        fadeAnimationDuration: Duration(milliseconds: 300),
      );

  factory BottomSheetStyles.dark() => const BottomSheetStyles(
        handleWidth: 40.0,
        handleHeight: 4.0,
        handleOpacity: 0.6,
        maxHeight: 0.9,
        borderRadius: 24.0,
        animationDuration: Duration(milliseconds: 300),
        handleTopMargin: 12.0,
        contentPadding: EdgeInsets.all(24),
        titleFontSize: 20.0,
        messageFontSize: 15.0,
        optionFontSize: 16.0,
        subtitleFontSize: 14.0,
        iconSize: 24.0,
        spacing: 12.0,
        largeSpacing: 24.0,
        buttonHeight: 52.0,
        buttonBorderRadius: 12.0,
        barrierOpacity: 0.5,
        slideAnimationDuration: Duration(milliseconds: 350),
        fadeAnimationDuration: Duration(milliseconds: 300),
      );

  static BottomSheetStyles lerp(BottomSheetStyles a, BottomSheetStyles b, double t) {
    return BottomSheetStyles(
      handleWidth: lerpDouble(a.handleWidth, b.handleWidth, t)!,
      handleHeight: lerpDouble(a.handleHeight, b.handleHeight, t)!,
      handleOpacity: lerpDouble(a.handleOpacity, b.handleOpacity, t)!,
      maxHeight: lerpDouble(a.maxHeight, b.maxHeight, t)!,
      borderRadius: lerpDouble(a.borderRadius, b.borderRadius, t)!,
      animationDuration: Duration(milliseconds: lerpDouble(a.animationDuration.inMilliseconds, b.animationDuration.inMilliseconds, t)!.round()),
      handleTopMargin: lerpDouble(a.handleTopMargin, b.handleTopMargin, t)!,
      contentPadding: EdgeInsets.lerp(a.contentPadding, b.contentPadding, t)!,
      titleFontSize: lerpDouble(a.titleFontSize, b.titleFontSize, t)!,
      messageFontSize: lerpDouble(a.messageFontSize, b.messageFontSize, t)!,
      optionFontSize: lerpDouble(a.optionFontSize, b.optionFontSize, t)!,
      subtitleFontSize: lerpDouble(a.subtitleFontSize, b.subtitleFontSize, t)!,
      iconSize: lerpDouble(a.iconSize, b.iconSize, t)!,
      spacing: lerpDouble(a.spacing, b.spacing, t)!,
      largeSpacing: lerpDouble(a.largeSpacing, b.largeSpacing, t)!,
      buttonHeight: lerpDouble(a.buttonHeight, b.buttonHeight, t)!,
      buttonBorderRadius: lerpDouble(a.buttonBorderRadius, b.buttonBorderRadius, t)!,
      barrierOpacity: lerpDouble(a.barrierOpacity, b.barrierOpacity, t)!,
      slideAnimationDuration: Duration(milliseconds: lerpDouble(a.slideAnimationDuration.inMilliseconds, b.slideAnimationDuration.inMilliseconds, t)!.round()),
      fadeAnimationDuration: Duration(milliseconds: lerpDouble(a.fadeAnimationDuration.inMilliseconds, b.fadeAnimationDuration.inMilliseconds, t)!.round()),
    );
  }
}

/// Dialog styles - TOSS design system dialogs
@immutable
class DialogStyles {
  final EdgeInsets contentPadding;
  final EdgeInsets wrapperPadding;
  final double borderRadius;
  final double barrierOpacity;
  final double titleFontSize;
  final double messageFontSize;
  final double iconSize;
  final double iconContainerSize;
  final double spacing;
  final double largeSpacing;
  final double loadingSize;
  final double loadingStrokeWidth;
  final Duration scaleAnimationDuration;
  final Duration fadeAnimationDuration;
  final Duration shakeAnimationDuration;
  final Duration shimmerDuration;

  const DialogStyles({
    required this.contentPadding,
    required this.wrapperPadding,
    required this.borderRadius,
    required this.barrierOpacity,
    required this.titleFontSize,
    required this.messageFontSize,
    required this.iconSize,
    required this.iconContainerSize,
    required this.spacing,
    required this.largeSpacing,
    required this.loadingSize,
    required this.loadingStrokeWidth,
    required this.scaleAnimationDuration,
    required this.fadeAnimationDuration,
    required this.shakeAnimationDuration,
    required this.shimmerDuration,
  });

  factory DialogStyles.light() => const DialogStyles(
        contentPadding: EdgeInsets.all(24),
        wrapperPadding: EdgeInsets.symmetric(horizontal: 40),
        borderRadius: 16.0,
        barrierOpacity: 0.5,
        titleFontSize: 18.0,
        messageFontSize: 15.0,
        iconSize: 48.0,
        iconContainerSize: 72.0,
        spacing: 12.0,
        largeSpacing: 24.0,
        loadingSize: 48.0,
        loadingStrokeWidth: 3.0,
        scaleAnimationDuration: Duration(milliseconds: 200),
        fadeAnimationDuration: Duration(milliseconds: 150),
        shakeAnimationDuration: Duration(milliseconds: 300),
        shimmerDuration: Duration(milliseconds: 1500),
      );

  factory DialogStyles.dark() => const DialogStyles(
        contentPadding: EdgeInsets.all(24),
        wrapperPadding: EdgeInsets.symmetric(horizontal: 40),
        borderRadius: 16.0,
        barrierOpacity: 0.5,
        titleFontSize: 18.0,
        messageFontSize: 15.0,
        iconSize: 48.0,
        iconContainerSize: 72.0,
        spacing: 12.0,
        largeSpacing: 24.0,
        loadingSize: 48.0,
        loadingStrokeWidth: 3.0,
        scaleAnimationDuration: Duration(milliseconds: 200),
        fadeAnimationDuration: Duration(milliseconds: 150),
        shakeAnimationDuration: Duration(milliseconds: 300),
        shimmerDuration: Duration(milliseconds: 1500),
      );

  static DialogStyles lerp(DialogStyles a, DialogStyles b, double t) {
    return DialogStyles(
      contentPadding: EdgeInsets.lerp(a.contentPadding, b.contentPadding, t)!,
      wrapperPadding: EdgeInsets.lerp(a.wrapperPadding, b.wrapperPadding, t)!,
      borderRadius: lerpDouble(a.borderRadius, b.borderRadius, t)!,
      barrierOpacity: lerpDouble(a.barrierOpacity, b.barrierOpacity, t)!,
      titleFontSize: lerpDouble(a.titleFontSize, b.titleFontSize, t)!,
      messageFontSize: lerpDouble(a.messageFontSize, b.messageFontSize, t)!,
      iconSize: lerpDouble(a.iconSize, b.iconSize, t)!,
      iconContainerSize: lerpDouble(a.iconContainerSize, b.iconContainerSize, t)!,
      spacing: lerpDouble(a.spacing, b.spacing, t)!,
      largeSpacing: lerpDouble(a.largeSpacing, b.largeSpacing, t)!,
      loadingSize: lerpDouble(a.loadingSize, b.loadingSize, t)!,
      loadingStrokeWidth: lerpDouble(a.loadingStrokeWidth, b.loadingStrokeWidth, t)!,
      scaleAnimationDuration: Duration(milliseconds: lerpDouble(a.scaleAnimationDuration.inMilliseconds, b.scaleAnimationDuration.inMilliseconds, t)!.round()),
      fadeAnimationDuration: Duration(milliseconds: lerpDouble(a.fadeAnimationDuration.inMilliseconds, b.fadeAnimationDuration.inMilliseconds, t)!.round()),
      shakeAnimationDuration: Duration(milliseconds: lerpDouble(a.shakeAnimationDuration.inMilliseconds, b.shakeAnimationDuration.inMilliseconds, t)!.round()),
      shimmerDuration: Duration(milliseconds: lerpDouble(a.shimmerDuration.inMilliseconds, b.shimmerDuration.inMilliseconds, t)!.round()),
    );
  }
}

/// Card styles - TOSS design system cards
@immutable
class CardStyles {
  final EdgeInsets defaultPadding;
  final EdgeInsets sectionPadding;
  final EdgeInsets listItemPadding;
  final double defaultBorderRadius;
  final double glassBorderRadius;
  final double elevation;
  final double glassBlur;
  final double borderWidth;
  final double sectionHeaderFontSize;
  final double listItemTitleFontSize;
  final double listItemSubtitleFontSize;
  final double itemSpacing;
  final double sectionSpacing;
  final double pressScale;
  final Duration pressAnimationDuration;

  const CardStyles({
    required this.defaultPadding,
    required this.sectionPadding,
    required this.listItemPadding,
    required this.defaultBorderRadius,
    required this.glassBorderRadius,
    required this.elevation,
    required this.glassBlur,
    required this.borderWidth,
    required this.sectionHeaderFontSize,
    required this.listItemTitleFontSize,
    required this.listItemSubtitleFontSize,
    required this.itemSpacing,
    required this.sectionSpacing,
    required this.pressScale,
    required this.pressAnimationDuration,
  });

  factory CardStyles.light() => const CardStyles(
        defaultPadding: EdgeInsets.all(16),
        sectionPadding: EdgeInsets.all(20),
        listItemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        defaultBorderRadius: 16.0,
        glassBorderRadius: 24.0,
        elevation: 8.0,
        glassBlur: 20.0,
        borderWidth: 1.0,
        sectionHeaderFontSize: 18.0,
        listItemTitleFontSize: 16.0,
        listItemSubtitleFontSize: 14.0,
        itemSpacing: 16.0,
        sectionSpacing: 4.0,
        pressScale: 0.98,
        pressAnimationDuration: Duration(milliseconds: 100),
      );

  factory CardStyles.dark() => const CardStyles(
        defaultPadding: EdgeInsets.all(16),
        sectionPadding: EdgeInsets.all(20),
        listItemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        defaultBorderRadius: 16.0,
        glassBorderRadius: 24.0,
        elevation: 8.0,
        glassBlur: 20.0,
        borderWidth: 1.0,
        sectionHeaderFontSize: 18.0,
        listItemTitleFontSize: 16.0,
        listItemSubtitleFontSize: 14.0,
        itemSpacing: 16.0,
        sectionSpacing: 4.0,
        pressScale: 0.98,
        pressAnimationDuration: Duration(milliseconds: 100),
      );

  static CardStyles lerp(CardStyles a, CardStyles b, double t) {
    return CardStyles(
      defaultPadding: EdgeInsets.lerp(a.defaultPadding, b.defaultPadding, t)!,
      sectionPadding: EdgeInsets.lerp(a.sectionPadding, b.sectionPadding, t)!,
      listItemPadding: EdgeInsets.lerp(a.listItemPadding, b.listItemPadding, t)!,
      defaultBorderRadius: lerpDouble(a.defaultBorderRadius, b.defaultBorderRadius, t)!,
      glassBorderRadius: lerpDouble(a.glassBorderRadius, b.glassBorderRadius, t)!,
      elevation: lerpDouble(a.elevation, b.elevation, t)!,
      glassBlur: lerpDouble(a.glassBlur, b.glassBlur, t)!,
      borderWidth: lerpDouble(a.borderWidth, b.borderWidth, t)!,
      sectionHeaderFontSize: lerpDouble(a.sectionHeaderFontSize, b.sectionHeaderFontSize, t)!,
      listItemTitleFontSize: lerpDouble(a.listItemTitleFontSize, b.listItemTitleFontSize, t)!,
      listItemSubtitleFontSize: lerpDouble(a.listItemSubtitleFontSize, b.listItemSubtitleFontSize, t)!,
      itemSpacing: lerpDouble(a.itemSpacing, b.itemSpacing, t)!,
      sectionSpacing: lerpDouble(a.sectionSpacing, b.sectionSpacing, t)!,
      pressScale: lerpDouble(a.pressScale, b.pressScale, t)!,
      pressAnimationDuration: Duration(milliseconds: lerpDouble(a.pressAnimationDuration.inMilliseconds, b.pressAnimationDuration.inMilliseconds, t)!.round()),
    );
  }
}

/// Data visualization styles
@immutable
class DataVisualization {
  final List<Color> chartColors;
  final double chartLineWidth;
  final double chartPointSize;
  final bool chartShowGrid;
  final Duration chartAnimationDuration;

  const DataVisualization({
    required this.chartColors,
    required this.chartLineWidth,
    required this.chartPointSize,
    required this.chartShowGrid,
    required this.chartAnimationDuration,
  });

  factory DataVisualization.light() => const DataVisualization(
        chartColors: [
          Color(0xFF3B82F6),
          Color(0xFF10B981),
          Color(0xFFF59E0B),
          Color(0xFFEF4444),
          Color(0xFF8B5CF6),
        ],
        chartLineWidth: 2.0,
        chartPointSize: 4.0,
        chartShowGrid: true,
        chartAnimationDuration: Duration(milliseconds: 1000),
      );

  factory DataVisualization.dark() => const DataVisualization(
        chartColors: [
          Color(0xFF60A5FA),
          Color(0xFF34D399),
          Color(0xFFFBBF24),
          Color(0xFFF87171),
          Color(0xFFA78BFA),
        ],
        chartLineWidth: 2.0,
        chartPointSize: 4.0,
        chartShowGrid: true,
        chartAnimationDuration: Duration(milliseconds: 1000),
      );

  static DataVisualization lerp(DataVisualization a, DataVisualization b, double t) {
    return DataVisualization(
      chartColors: List.generate(
        a.chartColors.length,
        (i) => Color.lerp(a.chartColors[i], b.chartColors[i], t)!,
      ),
      chartLineWidth: lerpDouble(a.chartLineWidth, b.chartLineWidth, t)!,
      chartPointSize: lerpDouble(a.chartPointSize, b.chartPointSize, t)!,
      chartShowGrid: t < 0.5 ? a.chartShowGrid : b.chartShowGrid,
      chartAnimationDuration: Duration(milliseconds: lerpDouble(a.chartAnimationDuration.inMilliseconds, b.chartAnimationDuration.inMilliseconds, t)!.round()),
    );
  }
}

/// Social sharing styles
@immutable
class SocialSharingStyles {
  final double shareButtonSize;
  final double shareIconSize;
  final EdgeInsets sharePadding;
  final Duration shareAnimationDuration;

  const SocialSharingStyles({
    required this.shareButtonSize,
    required this.shareIconSize,
    required this.sharePadding,
    required this.shareAnimationDuration,
  });

  factory SocialSharingStyles.light() => const SocialSharingStyles(
        shareButtonSize: 56.0,
        shareIconSize: 24.0,
        sharePadding: EdgeInsets.all(16),
        shareAnimationDuration: Duration(milliseconds: 200),
      );

  factory SocialSharingStyles.dark() => const SocialSharingStyles(
        shareButtonSize: 56.0,
        shareIconSize: 24.0,
        sharePadding: EdgeInsets.all(16),
        shareAnimationDuration: Duration(milliseconds: 200),
      );

  static SocialSharingStyles lerp(SocialSharingStyles a, SocialSharingStyles b, double t) {
    return SocialSharingStyles(
      shareButtonSize: lerpDouble(a.shareButtonSize, b.shareButtonSize, t)!,
      shareIconSize: lerpDouble(a.shareIconSize, b.shareIconSize, t)!,
      sharePadding: EdgeInsets.lerp(a.sharePadding, b.sharePadding, t)!,
      shareAnimationDuration: Duration(milliseconds: lerpDouble(a.shareAnimationDuration.inMilliseconds, b.shareAnimationDuration.inMilliseconds, t)!.round()),
    );
  }
}

// Helper function for lerping doubles
double? lerpDouble(num? a, num? b, double t) {
  if (a == null || b == null) return null;
  return a + (b - a) * t;
}