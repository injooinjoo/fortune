import 'package:flutter/material.dart';
import 'package:fortune/core/theme/font_config.dart';
import 'package:fortune/core/theme/typography_unified.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ds_colors.dart';

/// Korean Traditional "Saaju" typography system
///
/// Design Philosophy: Calligraphy meets modern readability
///
/// Font Strategy:
/// - All text: NanumMyeongjo (나눔명조) - Traditional calligraphy feel
///
/// Usage:
/// ```dart
/// Text('Title', style: DSTypography.headingLarge)
/// // or with context
/// Text('Title', style: context.typography.headingLarge)
/// ```
class DSTypography {
  DSTypography._();

  /// Headline font family - Calligraphy style (나눔명조)
  static String get headlineFamily => GoogleFonts.nanumMyeongjo().fontFamily!;

  /// Body font family - NanumMyeongjo for fortune content
  static String get bodyFamily => GoogleFonts.nanumMyeongjo().fontFamily!;

  /// UI font family - FontConfig.primary 참조
  static const String uiFamily = FontConfig.primary;

  /// Number font family - FontConfig.number 참조
  static const String numberFamily = FontConfig.number;

  /// Default font family for theme - FontConfig.primary 참조
  static const String fontFamily = FontConfig.primary;

  // ============================================
  // DISPLAY STYLES (Fortune titles, hero text)
  // Using NanumMyeongjo for traditional feel
  // ============================================

  /// Display Large - 32px, SemiBold - Fortune titles
  /// (w700→w600 조정으로 한지 위 붓글씨 느낌)
  static TextStyle get displayLarge => TypographyUnified.displayLarge;

  /// Display Medium - 28px, SemiBold - Section headers
  static TextStyle get displayMedium => TypographyUnified.displayMedium;

  /// Display Small - 24px, SemiBold
  static TextStyle get displaySmall => TypographyUnified.displaySmall;

  // ============================================
  // HEADING STYLES (Page titles, card headers)
  // Using NanumMyeongjo for traditional aesthetic
  // ============================================

  /// Heading Large - 24px, SemiBold - Page titles
  static TextStyle get headingLarge => TypographyUnified.heading1;

  /// Heading Medium - 20px, Medium - Card headers
  static TextStyle get headingMedium => TypographyUnified.heading2;

  /// Heading Small - 18px, Medium
  static TextStyle get headingSmall => TypographyUnified.heading3;

  // ============================================
  // BODY STYLES (Fortune content, descriptions)
  // Using NanumMyeongjo for readability
  // ============================================

  /// Body Large - 16px, Regular - Main fortune content
  static TextStyle get bodyLarge => TypographyUnified.bodyLarge;

  /// Body Medium - 14px, Regular - Secondary content
  static TextStyle get bodyMedium => TypographyUnified.bodyMedium;

  /// Body Small - 13px, Regular - Fine print
  static TextStyle get bodySmall => TypographyUnified.bodySmall;

  // ============================================
  // LABEL STYLES (UI labels, navigation)
  // Using NanumMyeongjo for consistent typography
  // ============================================

  /// Label Large - 16px, Medium
  static TextStyle get labelLarge => TypographyUnified.labelLarge;

  /// Label Medium - 14px, Medium
  static TextStyle get labelMedium => TypographyUnified.labelMedium;

  /// Label Small - 12px, Medium
  static TextStyle get labelSmall => TypographyUnified.labelSmall;

  /// Label Tiny - 11px, Medium (badges, etc)
  static TextStyle get labelTiny => TypographyUnified.labelTiny;

  // ============================================
  // SECTION HEADER (Traditional style)
  // ============================================

  /// Section Header - 12px, SemiBold
  static TextStyle get sectionHeader => TypographyUnified.labelSmall.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  // ============================================
  // BUTTON STYLES (Seal/stamp buttons)
  // ============================================

  /// Button Large - 17px, SemiBold
  static TextStyle get buttonLarge => TypographyUnified.buttonLarge;

  /// Button Medium - 16px, SemiBold
  static TextStyle get buttonMedium => TypographyUnified.buttonMedium;

  /// Button Small - 14px, SemiBold
  static TextStyle get buttonSmall => TypographyUnified.buttonSmall;

  // ============================================
  // NUMBER STYLES (for amounts, statistics)
  // ============================================

  /// Number Large - 32px, SemiBold
  /// (w700→w600 조정으로 부드러운 무게감)
  static TextStyle get numberLarge => TypographyUnified.numberLarge;

  /// Number Medium - 24px, SemiBold
  static TextStyle get numberMedium => TypographyUnified.numberMedium;

  /// Number Small - 18px, SemiBold
  static TextStyle get numberSmall => TypographyUnified.numberSmall;

  // ============================================
  // INPUT STYLES
  // ============================================

  /// Input text style - Using serif for traditional feel
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
  // FORTUNE-SPECIFIC STYLES
  // ============================================

  /// Fortune title - Large calligraphy style
  /// (w700→w600 조정으로 부드러운 붓글씨 느낌)
  static TextStyle get fortuneTitle => TypographyUnified.calligraphyTitle;

  /// Fortune subtitle - Medium calligraphy
  static TextStyle get fortuneSubtitle => TypographyUnified.calligraphySubtitle;

  /// Fortune content - Serif body for readability
  static TextStyle get fortuneContent => TypographyUnified.calligraphyBody;

  /// Fortune quote - Elegant serif for special text
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

  // Fortune-specific
  TextStyle get fortuneTitle => DSTypography.fortuneTitle;
  TextStyle get fortuneSubtitle => DSTypography.fortuneSubtitle;
  TextStyle get fortuneContent => DSTypography.fortuneContent;
  TextStyle get fortuneQuote => DSTypography.fortuneQuote;
}
