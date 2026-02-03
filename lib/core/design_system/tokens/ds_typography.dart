import 'package:flutter/material.dart';
import 'package:fortune/core/theme/font_config.dart';
import 'package:fortune/core/theme/typography_unified.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ds_colors.dart';

/// Modern AI Chat typography system
///
/// Design Philosophy: Clean, readable, content-focused
///
/// Font Strategy:
/// - Primary: Inter (modern sans-serif)
/// - Korean fallback: Pretendard
/// - Legacy calligraphy: NanumMyeongjo (for specific traditional content)
///
/// Usage:
/// ```dart
/// Text('Title', style: DSTypography.headingLarge)
/// // or with context
/// Text('Title', style: context.typography.headingLarge)
/// ```
class DSTypography {
  DSTypography._();

  /// Primary font family - Inter
  static String get headlineFamily => GoogleFonts.inter().fontFamily!;

  /// Body font family - Inter
  static String get bodyFamily => GoogleFonts.inter().fontFamily!;

  /// UI font family - FontConfig.primary reference
  static const String uiFamily = FontConfig.primary;

  /// Number font family - FontConfig.number reference
  static const String numberFamily = FontConfig.number;

  /// Default font family for theme - FontConfig.primary reference
  static const String fontFamily = FontConfig.primary;

  // ============================================
  // DISPLAY STYLES (Hero text, splash screens)
  // Using Inter for modern, clean look
  // ============================================

  /// Display Large - 36px, SemiBold - Page hero titles
  static TextStyle get displayLarge => TypographyUnified.displayLarge;

  /// Display Medium - 32px, SemiBold - Section headers
  static TextStyle get displayMedium => TypographyUnified.displayMedium;

  /// Display Small - 28px, SemiBold
  static TextStyle get displaySmall => TypographyUnified.displaySmall;

  // ============================================
  // HEADING STYLES (Page titles, card headers)
  // Using Inter for modern aesthetic
  // ============================================

  /// Heading Large - 28px, SemiBold - Page titles
  static TextStyle get headingLarge => TypographyUnified.heading1;

  /// Heading Medium - 24px, SemiBold - Card headers
  static TextStyle get headingMedium => TypographyUnified.heading2;

  /// Heading Small - 20px, Medium
  static TextStyle get headingSmall => TypographyUnified.heading3;

  // ============================================
  // BODY STYLES (Content, descriptions)
  // Using Inter for readability
  // ============================================

  /// Body Large - 16px, Regular - Main content
  static TextStyle get bodyLarge => TypographyUnified.bodyLarge;

  /// Body Medium - 14px, Regular - Secondary content
  static TextStyle get bodyMedium => TypographyUnified.bodyMedium;

  /// Body Small - 13px, Regular - Fine print
  static TextStyle get bodySmall => TypographyUnified.bodySmall;

  // ============================================
  // LABEL STYLES (UI labels, navigation)
  // Using Inter for UI consistency
  // ============================================

  /// Label Large - 14px, Medium
  static TextStyle get labelLarge => TypographyUnified.labelLarge;

  /// Label Medium - 13px, Medium
  static TextStyle get labelMedium => TypographyUnified.labelMedium;

  /// Label Small - 12px, Medium
  static TextStyle get labelSmall => TypographyUnified.labelSmall;

  /// Label Tiny - 11px, Medium (badges, etc)
  static TextStyle get labelTiny => TypographyUnified.labelTiny;

  // ============================================
  // SECTION HEADER
  // ============================================

  /// Section Header - 12px, SemiBold
  static TextStyle get sectionHeader => TypographyUnified.labelSmall.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  // ============================================
  // BUTTON STYLES
  // ============================================

  /// Button Large - 16px, SemiBold
  static TextStyle get buttonLarge => TypographyUnified.buttonLarge;

  /// Button Medium - 15px, SemiBold
  static TextStyle get buttonMedium => TypographyUnified.buttonMedium;

  /// Button Small - 14px, SemiBold
  static TextStyle get buttonSmall => TypographyUnified.buttonSmall;

  // ============================================
  // NUMBER STYLES (for amounts, statistics)
  // ============================================

  /// Number Large - 28px, SemiBold
  static TextStyle get numberLarge => TypographyUnified.numberLarge;

  /// Number Medium - 22px, SemiBold
  static TextStyle get numberMedium => TypographyUnified.numberMedium;

  /// Number Small - 18px, SemiBold
  static TextStyle get numberSmall => TypographyUnified.numberSmall;

  // ============================================
  // INPUT STYLES
  // ============================================

  /// Input text style
  static TextStyle get input => TypographyUnified.bodyMedium;

  /// Input placeholder style
  static TextStyle get inputPlaceholder => input.copyWith(
        color: DSColors.textTertiary,
      );

  /// Input error style
  static TextStyle inputError = labelSmall.copyWith(
    color: DSColors.error,
  );

  // ============================================
  // FORTUNE-SPECIFIC STYLES (Legacy calligraphy)
  // Using NanumMyeongjo for traditional content
  // ============================================

  /// Fortune title - Calligraphy style for traditional content
  static TextStyle get fortuneTitle => TypographyUnified.calligraphyTitle;

  /// Fortune subtitle - Calligraphy style
  static TextStyle get fortuneSubtitle => TypographyUnified.calligraphySubtitle;

  /// Fortune content - Calligraphy style for readability
  static TextStyle get fortuneContent => TypographyUnified.calligraphyBody;

  /// Fortune quote - Calligraphy style for special text
  static TextStyle get fortuneQuote => TypographyUnified.calligraphyQuote;
}

/// Typography scheme for context-based access
class DSTypographyScheme {
  const DSTypographyScheme();

  TextStyle get displayLarge => DSTypography.displayLarge;
  TextStyle get displayMedium => DSTypography.displayMedium;
  TextStyle get displaySmall => DSTypography.displaySmall;

  TextStyle get headingLarge => DSTypography.headingLarge;
  TextStyle get headingMedium => DSTypography.headingMedium;
  TextStyle get headingSmall => DSTypography.headingSmall;

  TextStyle get bodyLarge => DSTypography.bodyLarge;
  TextStyle get bodyMedium => DSTypography.bodyMedium;
  TextStyle get bodySmall => DSTypography.bodySmall;

  TextStyle get labelLarge => DSTypography.labelLarge;
  TextStyle get labelMedium => DSTypography.labelMedium;
  TextStyle get labelSmall => DSTypography.labelSmall;
  TextStyle get labelTiny => DSTypography.labelTiny;

  TextStyle get sectionHeader => DSTypography.sectionHeader;

  TextStyle get buttonLarge => DSTypography.buttonLarge;
  TextStyle get buttonMedium => DSTypography.buttonMedium;
  TextStyle get buttonSmall => DSTypography.buttonSmall;

  TextStyle get numberLarge => DSTypography.numberLarge;
  TextStyle get numberMedium => DSTypography.numberMedium;
  TextStyle get numberSmall => DSTypography.numberSmall;

  TextStyle get input => DSTypography.input;
  TextStyle get inputPlaceholder => DSTypography.inputPlaceholder;
  TextStyle get inputError => DSTypography.inputError;

  // Fortune-specific (legacy calligraphy)
  TextStyle get fortuneTitle => DSTypography.fortuneTitle;
  TextStyle get fortuneSubtitle => DSTypography.fortuneSubtitle;
  TextStyle get fortuneContent => DSTypography.fortuneContent;
  TextStyle get fortuneQuote => DSTypography.fortuneQuote;
}
