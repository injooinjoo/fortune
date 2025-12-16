import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ds_colors.dart';

/// Korean Traditional "Saaju" typography system
///
/// Design Philosophy: Calligraphy meets modern readability
///
/// Font Strategy:
/// - Display/Headline: Gowun Batang (고운바탕) - Traditional calligraphy feel
/// - Body: Noto Serif KR - Clean, readable serif for fortune content
/// - UI/Labels: Pretendard - Modern sans for UI elements
///
/// Usage:
/// ```dart
/// Text('Title', style: DSTypography.headingLarge)
/// // or with context
/// Text('Title', style: context.typography.headingLarge)
/// ```
class DSTypography {
  DSTypography._();

  /// Headline font family - Calligraphy style (고운바탕)
  static String get headlineFamily => GoogleFonts.gowunBatang().fontFamily!;

  /// Body font family - Serif for fortune content
  static String get bodyFamily => GoogleFonts.notoSerifKr().fontFamily!;

  /// UI font family - Modern sans for readability
  static const String uiFamily = 'Pretendard';

  /// Number font family (for tabular figures)
  static const String numberFamily = 'Pretendard';

  /// Default font family for theme (used in TextTheme)
  static const String fontFamily = 'Pretendard';

  // ============================================
  // DISPLAY STYLES (Fortune titles, hero text)
  // Using Gowun Batang for traditional feel
  // ============================================

  /// Display Large - 32px, Bold - Fortune titles
  static TextStyle get displayLarge => GoogleFonts.gowunBatang(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: 0,
      );

  /// Display Medium - 28px, SemiBold - Section headers
  static TextStyle get displayMedium => GoogleFonts.gowunBatang(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: 0,
      );

  /// Display Small - 24px, SemiBold
  static TextStyle get displaySmall => GoogleFonts.gowunBatang(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
      );

  // ============================================
  // HEADING STYLES (Page titles, card headers)
  // Using Gowun Batang for traditional aesthetic
  // ============================================

  /// Heading Large - 24px, SemiBold - Page titles
  static TextStyle get headingLarge => GoogleFonts.gowunBatang(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: 0,
      );

  /// Heading Medium - 20px, Medium - Card headers
  static TextStyle get headingMedium => GoogleFonts.gowunBatang(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
      );

  /// Heading Small - 18px, Medium
  static TextStyle get headingSmall => GoogleFonts.gowunBatang(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0,
      );

  // ============================================
  // BODY STYLES (Fortune content, descriptions)
  // Using Noto Serif KR for readability
  // ============================================

  /// Body Large - 16px, Regular - Main fortune content
  static TextStyle get bodyLarge => GoogleFonts.notoSerifKr(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.7,
        letterSpacing: 0,
      );

  /// Body Medium - 14px, Regular - Secondary content
  static TextStyle get bodyMedium => GoogleFonts.notoSerifKr(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.65,
        letterSpacing: 0,
      );

  /// Body Small - 13px, Regular - Fine print
  static TextStyle get bodySmall => GoogleFonts.notoSerifKr(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.6,
        letterSpacing: 0,
      );

  // ============================================
  // LABEL STYLES (UI labels, navigation)
  // Using Pretendard for modern UI
  // ============================================

  /// Label Large - 16px, Medium
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0,
    fontFamily: uiFamily,
  );

  /// Label Medium - 14px, Medium
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0,
    fontFamily: uiFamily,
  );

  /// Label Small - 12px, Medium
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
    fontFamily: uiFamily,
  );

  /// Label Tiny - 11px, Medium (badges, etc)
  static const TextStyle labelTiny = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
    fontFamily: uiFamily,
  );

  // ============================================
  // SECTION HEADER (Traditional style)
  // ============================================

  /// Section Header - 12px, SemiBold
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
    fontFamily: uiFamily,
  );

  // ============================================
  // BUTTON STYLES (Seal/stamp buttons)
  // ============================================

  /// Button Large - 17px, SemiBold
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    fontFamily: uiFamily,
  );

  /// Button Medium - 16px, SemiBold
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    fontFamily: uiFamily,
  );

  /// Button Small - 14px, SemiBold
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    fontFamily: uiFamily,
  );

  // ============================================
  // NUMBER STYLES (for amounts, statistics)
  // ============================================

  /// Number Large - 32px, Bold
  static const TextStyle numberLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.02,
    fontFamily: numberFamily,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Number Medium - 24px, SemiBold
  static const TextStyle numberMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: -0.01,
    fontFamily: numberFamily,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Number Small - 18px, SemiBold
  static const TextStyle numberSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    fontFamily: numberFamily,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ============================================
  // INPUT STYLES
  // ============================================

  /// Input text style - Using serif for traditional feel
  static TextStyle get input => GoogleFonts.notoSerifKr(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
      );

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
  static TextStyle get fortuneTitle => GoogleFonts.gowunBatang(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.35,
        letterSpacing: 0,
      );

  /// Fortune subtitle - Medium calligraphy
  static TextStyle get fortuneSubtitle => GoogleFonts.gowunBatang(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0,
      );

  /// Fortune content - Serif body for readability
  static TextStyle get fortuneContent => GoogleFonts.notoSerifKr(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.8,
        letterSpacing: 0.2,
      );

  /// Fortune quote - Elegant serif for special text
  static TextStyle get fortuneQuote => GoogleFonts.notoSerifKr(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.75,
        letterSpacing: 0.1,
        fontStyle: FontStyle.italic,
      );
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
