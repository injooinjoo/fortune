import 'package:flutter/material.dart';

/// Custom theme extension for Fortune app specific colors
@immutable
class FortuneThemeExtension extends ThemeExtension<FortuneThemeExtension> {
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
  });

  /// Light theme extension
  static const light = FortuneThemeExtension(
    scoreExcellent: Color(0xFF10B981), // Green
    scoreGood: Color(0xFF3B82F6), // Blue
    scoreFair: Color(0xFFF59E0B), // Orange
    scorePoor: Color(0xFFEF4444), // Red
    fortuneGradientStart: Color(0xFF000000), // Black
    fortuneGradientEnd: Color(0xFF4A4A4A), // Medium gray
    glassBackground: Color(0x0AFFFFFF),
    glassBorder: Color(0x14FFFFFF),
    subtitleText: Color(0xFF6B7280),
    dividerColor: Color(0xFFE5E7EB),
    shimmerBase: Color(0xFFE5E7EB),
    shimmerHighlight: Color(0xFFF3F4F6),
    errorColor: Color(0xFFEF4444), // Red
    successColor: Color(0xFF10B981), // Green
    warningColor: Color(0xFFF59E0B), // Orange
  );

  /// Dark theme extension
  static const dark = FortuneThemeExtension(
    scoreExcellent: Color(0xFF34D399), // Lighter green for dark mode
    scoreGood: Color(0xFF60A5FA), // Lighter blue for dark mode
    scoreFair: Color(0xFFFBBF24), // Lighter orange for dark mode
    scorePoor: Color(0xFFF87171), // Lighter red for dark mode
    fortuneGradientStart: Color(0xFFE0E0E0), // Light gray
    fortuneGradientEnd: Color(0xFF999999), // Medium light gray
    glassBackground: Color(0x14FFFFFF),
    glassBorder: Color(0x1AFFFFFF),
    subtitleText: Color(0xFF9CA3AF),
    dividerColor: Color(0xFF374151),
    shimmerBase: Color(0xFF374151),
    shimmerHighlight: Color(0xFF4B5563),
    errorColor: Color(0xFFF87171), // Lighter red for dark mode
    successColor: Color(0xFF34D399), // Lighter green for dark mode
    warningColor: Color(0xFFFBBF24), // Lighter orange for dark mode
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
    );
  }
}

/// Extension method to easily access theme extension
extension FortuneThemeExtensionGetter on BuildContext {
  FortuneThemeExtension get fortuneTheme {
    return Theme.of(this).extension<FortuneThemeExtension>() ?? FortuneThemeExtension.light;
  }
}