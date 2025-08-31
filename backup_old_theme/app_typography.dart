import '../../core/theme/toss_design_system.dart';
import 'package:flutter/material.dart';
import '../../core/theme/toss_design_system.dart';
import 'dart:ui';

/// Typography system using Toss Product Sans font
/// Based on Toss design system principles
class AppTypography {
  // Font family
  static const String fontFamily = 'Toss Product Sans';

  // Display styles - for large headlines
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.02);

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.02);

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.01);

  // Headline styles - for section headers
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.01);

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.005);

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0);

  // Title styles - for cards and list items
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: 0);

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0);

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0);

  // Body styles - for main content
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0);

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0);

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
    letterSpacing: 0);

  // Label styles - for buttons and form fields
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0);

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0);

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0);

  // Caption styles - for helper text
  static const TextStyle captionLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0);

  static const TextStyle captionMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0);

  static const TextStyle captionSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: 0);

  // Extra small label for tiny UI elements
  static const TextStyle labelXSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0);

  // Special styles
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0);

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0);

  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.04);

  // Numeric styles - optimized for numbers
  static const TextStyle numberXLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    fontFeatures: [FontFeature.tabularFigures()]);

  static const TextStyle numberLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.02,
    fontFeatures: [FontFeature.tabularFigures()]);

  static const TextStyle numberMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.01,
    fontFeatures: [FontFeature.tabularFigures()]);

  static const TextStyle numberSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()]);

  // Get text theme for Material Theme
  static TextTheme getTextTheme({Color? color}) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: color),
      displayMedium: displayMedium.copyWith(color: color),
      displaySmall: displaySmall.copyWith(color: color),
      headlineLarge: headlineLarge.copyWith(color: color),
      headlineMedium: headlineMedium.copyWith(color: color),
      headlineSmall: headlineSmall.copyWith(color: color),
      titleLarge: titleLarge.copyWith(color: color),
      titleMedium: titleMedium.copyWith(color: color),
      titleSmall: titleSmall.copyWith(color: color),
      bodyLarge: bodyLarge.copyWith(color: color),
      bodyMedium: bodyMedium.copyWith(color: color),
      bodySmall: bodySmall.copyWith(color: color),
      labelLarge: labelLarge.copyWith(color: color),
      labelMedium: labelMedium.copyWith(color: color),
      labelSmall: labelSmall.copyWith(color: color));
  }

  // Responsive font size calculator
  static double responsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0; // Based on iPhone 11 Pro width
    return baseSize * scaleFactor.clamp(0.85, 1.15);
  }
}

/// Extension for easy access to typography styles
extension TypographyExtension on BuildContext {
  AppTypography get typography => AppTypography();

  TextStyle get displayLarge => TossDesignSystem.heading1;
  TextStyle get displayMedium => TossDesignSystem.heading1;
  TextStyle get displaySmall => TossDesignSystem.heading2;

  TextStyle get headlineLarge => TossDesignSystem.heading1;
  TextStyle get headlineMedium => TossDesignSystem.heading2;
  TextStyle get headlineSmall => TossDesignSystem.heading3;

  TextStyle get titleLarge => TossDesignSystem.heading2;
  TextStyle get titleMedium => TossDesignSystem.heading3;
  TextStyle get titleSmall => TossDesignSystem.heading4;

  TextStyle get bodyLarge => TossDesignSystem.body1;
  TextStyle get bodyMedium => TossDesignSystem.body2;
  TextStyle get bodySmall => TossDesignSystem.body3;

  TextStyle get labelLarge => TossDesignSystem.button;
  TextStyle get labelMedium => TossDesignSystem.caption;
  TextStyle get labelSmall => TossDesignSystem.caption;

  TextStyle get captionLarge => AppTypography.captionLarge;
  TextStyle get captionMedium => AppTypography.captionMedium;
  TextStyle get captionSmall => AppTypography.captionSmall;

  TextStyle get labelXSmall => AppTypography.labelXSmall;

  TextStyle get button => AppTypography.button;
  TextStyle get buttonSmall => AppTypography.buttonSmall;

  TextStyle get overline => AppTypography.overline;

  TextStyle get numberXLarge => AppTypography.numberXLarge;
  TextStyle get numberLarge => AppTypography.numberLarge;
  TextStyle get numberMedium => AppTypography.numberMedium;
  TextStyle get numberSmall => AppTypography.numberSmall;
}
