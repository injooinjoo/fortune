import 'package:flutter/material.dart';
import 'micro_interactions.dart';
import 'animation_durations.dart';
import 'animation_curves.dart';
import 'loading_states.dart';
import 'error_states.dart';
import 'haptic_patterns.dart';
import 'form_styles.dart';
import 'bottom_sheet_styles.dart';
import 'card_styles.dart';
import 'dialog_styles.dart';
import 'data_visualization.dart';
import 'social_sharing_styles.dart';

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
    scoreExcellent: const Color(0xFF10B981), // Green,
    scoreGood: const Color(0xFF3B82F6), // Blue,
    scoreFair: const Color(0xFFF59E0B), // Orange,
    scorePoor: const Color(0xFFEF4444), // Red,
    fortuneGradientStart: const Color(0xFF000000), // Black,
    fortuneGradientEnd: const Color(0xFF4A4A4A), // Medium gray,
    glassBackground: const Color(0x0AFFFFFF),
    glassBorder: const Color(0x14FFFFFF),
    subtitleText: const Color(0xFF6B7280),
    dividerColor: const Color(0xFFE5E7EB),
    shimmerBase: const Color(0xFFE5E7EB),
    shimmerHighlight: const Color(0xFFF3F4F6),
    errorColor: const Color(0xFFEF4444), // Red,
    successColor: const Color(0xFF10B981), // Green,
    warningColor: const Color(0xFFF59E0B), // Orange,
    cardBackground: const Color(0xFFF6F6F6), // Light gray background,
    cardSurface: const Color(0xFFFFFFFF), // White surface,
    shadowColor: const Color(0x1A000000), // Light shadow,
    primaryText: const Color(0xFF262626), // Dark text,
    secondaryText: const Color(0xFF8E8E8E), // Gray text,
    // TOSS 디자인 시스템
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  /// Dark theme extension
  static final dark = FortuneThemeExtension(
    scoreExcellent: const Color(0xFF34D399), // Lighter green for dark mode,
    scoreGood: const Color(0xFF60A5FA), // Lighter blue for dark mode,
    scoreFair: const Color(0xFFFBBF24), // Lighter orange for dark mode,
    scorePoor: const Color(0xFFF87171), // Lighter red for dark mode,
    fortuneGradientStart: const Color(0xFFE0E0E0), // Light gray,
    fortuneGradientEnd: const Color(0xFF999999), // Medium light gray,
    glassBackground: const Color(0x1A000000), // Dark glass background,
    glassBorder: const Color(0x33FFFFFF), // Lighter border for dark mode,
    subtitleText: const Color(0xFFB0B0B0), // Light gray for dark mode,
    dividerColor: const Color(0xFF2D2D2D), // Dark divider,
    shimmerBase: const Color(0xFF1C1C1C), // Dark shimmer base,
    shimmerHighlight: const Color(0xFF2D2D2D), // Dark shimmer highlight,
    errorColor: const Color(0xFFF87171), // Lighter red for dark mode,
    successColor: const Color(0xFF34D399), // Lighter green for dark mode,
    warningColor: const Color(0xFFFBBF24), // Lighter orange for dark mode,
    cardBackground: const Color(0xFF0A0A0A), // Very dark background,
    cardSurface: const Color(0xFF1C1C1C), // Dark surface,
    shadowColor: const Color(0x66000000), // Stronger shadow for dark mode,
    primaryText: const Color(0xFFF5F5F5), // Off-white text,
    secondaryText: const Color(0xFFB0B0B0), // Light gray text,
    // TOSS 디자인 시스템
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
      padding: const EdgeInsets.symmetric(vertical: 16),
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
    ButtonStyle? ctaButtonStyle}) {
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
      ctaButtonStyle: ctaButtonStyle ?? this.ctaButtonStyle);
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
      ctaButtonStyle: ButtonStyle.lerp(ctaButtonStyle, other.ctaButtonStyle, t));
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
