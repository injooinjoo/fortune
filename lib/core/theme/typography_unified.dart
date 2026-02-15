import 'package:flutter/material.dart';
import 'package:fortune/core/theme/font_config.dart';
import 'package:fortune/core/theme/font_size_system.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fortune/core/design_system/tokens/ds_colors.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';

/// Unified typography system - Claude-inspired neutral theme
///
/// Font Strategy:
/// - Primary: NotoSansKR (clean, readable Korean sans-serif)
/// - All text uses local NotoSansKR font files
/// - Legacy calligraphy: NanumMyeongjo (for specific traditional content)
///
/// Usage:
/// ```dart
/// // BuildContext extension (recommended)
/// Text('Title', style: context.heading1)
/// Text('Body', style: context.bodyMedium)
///
/// // Direct usage
/// Text('Title', style: TypographyUnified.heading1)
/// Text('Body', style: TypographyUnified.bodyMedium)
/// ```
class TypographyUnified {
  static const Color _textPrimaryLight = DSColors.textPrimaryDark;
  static const Color _textPrimaryDark = DSColors.textPrimary;

  // ==========================================
  // FONT FAMILIES - NotoSansKR (Local)
  // ==========================================

  /// Primary font - NotoSansKR (local)
  static const String fontFamilyPrimary = FontConfig.primary;

  /// Korean font - NotoSansKR
  static const String fontFamilyKorean = FontConfig.korean;

  /// English font - NotoSansKR
  static const String fontFamilyEnglish = FontConfig.english;

  /// Number font - NotoSansKR
  static const String fontFamilyNumber = FontConfig.number;

  /// Default font - NotoSansKR
  static const String fontFamilyDefault = FontConfig.primary;

  /// Font family fallback list
  static const List<String> fontFamilyFallback = FontConfig.fontFamilyFallback;

  // ==========================================
  // LEGACY CALLIGRAPHY STYLES (Korean Traditional)
  // ==========================================
  //
  // Kept for specific traditional content that needs serif/calligraphy feel
  // Uses NanumMyeongjo font

  /// Calligraphy Display - Fortune main title (32pt)
  static TextStyle get calligraphyDisplay => GoogleFonts.nanumMyeongjo(
        fontSize: FontSizeSystem.displaySmallScaled,
        height: 1.4,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );

  /// Calligraphy Title - Fortune section title (24pt)
  static TextStyle get calligraphyTitle => GoogleFonts.nanumMyeongjo(
        fontSize: FontSizeSystem.heading2Scaled,
        height: 1.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      );

  /// Calligraphy Subtitle - Fortune subtitle (20pt)
  static TextStyle get calligraphySubtitle => GoogleFonts.nanumMyeongjo(
        fontSize: FontSizeSystem.heading3Scaled,
        height: 1.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      );

  /// Calligraphy Body - Fortune content (17pt)
  static TextStyle get calligraphyBody => GoogleFonts.nanumMyeongjo(
        fontSize: FontSizeSystem.bodyLargeScaled,
        height: 1.8,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      );

  /// Calligraphy Quote - Fortune quote/advice (15pt)
  static TextStyle get calligraphyQuote => GoogleFonts.nanumMyeongjo(
        fontSize: FontSizeSystem.bodyMediumScaled,
        height: 1.8,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        fontStyle: FontStyle.italic,
      );

  // ==========================================
  // DISPLAY STYLES (Large Headlines)
  // ==========================================

  /// Display Large - Largest headline
  static TextStyle get displayLarge => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: FontSizeSystem.displayLargeScaled,
        height: 1.22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      );

  /// Display Medium - Large headline
  static TextStyle get displayMedium => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: FontSizeSystem.displayMediumScaled,
        height: 1.24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      );

  /// Display Small - Medium headline
  static TextStyle get displaySmall => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: FontSizeSystem.displaySmallScaled,
        height: 1.28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.15,
      );

  // ==========================================
  // HEADING STYLES (Section Titles)
  // ==========================================

  /// Heading 1 - Main page title
  static TextStyle get heading1 => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: FontSizeSystem.heading1Scaled,
        height: 1.32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      );

  /// Heading 2 - Section title
  static TextStyle get heading2 => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: FontSizeSystem.heading2Scaled,
        height: 1.34,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.05,
      );

  /// Heading 3 - Sub section title
  static TextStyle get heading3 => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: FontSizeSystem.heading3Scaled,
        height: 1.4,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  /// Heading 4 - Small section title
  static TextStyle get heading4 => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: FontSizeSystem.heading4Scaled,
        height: 1.42,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  // ==========================================
  // BODY STYLES (Body Text)
  // ==========================================

  /// Body Large - Large body text
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: FontSizeSystem.bodyLargeScaled,
        height: 1.58,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  /// Body Medium - Default body text
  static TextStyle get bodyMedium => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: FontSizeSystem.bodyMediumScaled,
        height: 1.56,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  /// Body Small - Small body text
  static TextStyle get bodySmall => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: FontSizeSystem.bodySmallScaled,
        height: 1.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  // ==========================================
  // LABEL STYLES (Labels, Captions)
  // ==========================================

  /// Label Large - Large label
  static TextStyle get labelLarge => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: FontSizeSystem.labelLargeScaled,
        height: 1.45,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  /// Label Medium - Default label
  static TextStyle get labelMedium => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: FontSizeSystem.labelMediumScaled,
        height: 1.4,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  /// Label Small - Small label
  static TextStyle get labelSmall => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: FontSizeSystem.labelSmallScaled,
        height: 1.35,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  /// Label Tiny - Very small label
  static TextStyle get labelTiny => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: FontSizeSystem.labelTinyScaled,
        height: 1.32,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  // ==========================================
  // BUTTON STYLES (Button Text)
  // ==========================================

  /// Button Large - Large button (16pt)
  static TextStyle get buttonLarge => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: FontSizeSystem.buttonLargeScaled,
        height: 1.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  /// Button Medium - Default button (15pt)
  static TextStyle get buttonMedium => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: FontSizeSystem.buttonMediumScaled,
        height: 1.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  /// Button Small - Small button (14pt)
  static TextStyle get buttonSmall => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: FontSizeSystem.buttonSmallScaled,
        height: 1.45,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  /// Button Tiny - Very small button (13pt)
  static TextStyle get buttonTiny => TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: FontSizeSystem.buttonTinyScaled,
        height: 1.4,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  // ==========================================
  // NUMBER STYLES (Numbers Only)
  // ==========================================

  /// Number XLarge - Very large number (36pt)
  static TextStyle get numberXLarge => TextStyle(
        fontFamily: fontFamilyNumber,
        fontSize: FontSizeSystem.numberXLargeScaled,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Number Large - Large number (28pt)
  static TextStyle get numberLarge => TextStyle(
        fontFamily: fontFamilyNumber,
        fontSize: FontSizeSystem.numberLargeScaled,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Number Medium - Medium number (22pt)
  static TextStyle get numberMedium => TextStyle(
        fontFamily: fontFamilyNumber,
        fontSize: FontSizeSystem.numberMediumScaled,
        height: 1.3,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Number Small - Small number (18pt)
  static TextStyle get numberSmall => TextStyle(
        fontFamily: fontFamilyNumber,
        fontSize: FontSizeSystem.numberSmallScaled,
        height: 1.4,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // ==========================================
  // BACKWARD COMPATIBILITY ALIASES
  // ==========================================

  /// @deprecated Use [bodyLarge] instead
  static TextStyle get body1 => bodyLarge;

  /// @deprecated Use [bodyMedium] instead
  static TextStyle get body2 => bodyMedium;

  /// @deprecated Use [bodySmall] instead
  static TextStyle get body3 => bodySmall;

  /// @deprecated Use [labelLarge] instead
  static TextStyle get caption => labelLarge;

  /// @deprecated Use [labelLarge] instead
  static TextStyle get caption1 => labelLarge;

  /// @deprecated Use [labelMedium] instead
  static TextStyle get small => labelMedium;

  /// @deprecated Use [buttonMedium] instead
  static TextStyle get button => buttonMedium;

  /// @deprecated Use [numberLarge] instead
  static TextStyle get amountLarge => numberLarge;

  /// @deprecated Use [numberMedium] instead
  static TextStyle get amountMedium => numberMedium;

  // ==========================================
  // COLOR HELPERS
  // ==========================================

  /// Light mode TextStyle
  static TextStyle withLightColor(TextStyle style, {Color? color}) {
    return style.copyWith(
      color: color ?? _textPrimaryLight,
    );
  }

  /// Dark mode TextStyle
  static TextStyle withDarkColor(TextStyle style, {Color? color}) {
    return style.copyWith(
      color: color ?? _textPrimaryDark,
    );
  }

  /// Theme-aware TextStyle
  static TextStyle withThemeColor(
    TextStyle style,
    BuildContext context, {
    Color? lightColor,
    Color? darkColor,
  }) {
    final isDark = context.isDark;
    if (isDark) {
      return withDarkColor(style, color: darkColor);
    } else {
      return withLightColor(style, color: lightColor);
    }
  }

  /// Material TextTheme mapped to unified typography
  static TextTheme materialTextTheme({required Brightness brightness}) {
    final textColor =
        brightness == Brightness.dark ? _textPrimaryDark : _textPrimaryLight;

    return TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: heading1,
      headlineMedium: heading2,
      headlineSmall: heading3,
      titleLarge: heading4,
      titleMedium: bodyLarge,
      titleSmall: bodyMedium,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    ).apply(
      bodyColor: textColor,
      displayColor: textColor,
    );
  }
}

/// BuildContext extension for easy typography access
///
/// Usage:
/// ```dart
/// Text('Title', style: context.heading1)
/// Text('Body', style: context.bodyMedium.withColor(context))
/// ```
extension TypographyUnifiedExtension on BuildContext {
  /// TypographyUnified instance access
  TypographyUnified get typo => TypographyUnified();

  // Calligraphy Styles (NanumMyeongjo - Korean traditional)
  TextStyle get calligraphyDisplay => TypographyUnified.calligraphyDisplay;
  TextStyle get calligraphyTitle => TypographyUnified.calligraphyTitle;
  TextStyle get calligraphySubtitle => TypographyUnified.calligraphySubtitle;
  TextStyle get calligraphyBody => TypographyUnified.calligraphyBody;
  TextStyle get calligraphyQuote => TypographyUnified.calligraphyQuote;

  // Display Styles
  TextStyle get displayLarge => TypographyUnified.displayLarge;
  TextStyle get displayMedium => TypographyUnified.displayMedium;
  TextStyle get displaySmall => TypographyUnified.displaySmall;

  // Heading Styles
  TextStyle get heading1 => TypographyUnified.heading1;
  TextStyle get heading2 => TypographyUnified.heading2;
  TextStyle get heading3 => TypographyUnified.heading3;
  TextStyle get heading4 => TypographyUnified.heading4;

  // Heading Aliases (Material naming compatibility)
  TextStyle get headingLarge => TypographyUnified.heading1;
  TextStyle get headingMedium => TypographyUnified.heading2;
  TextStyle get headingSmall => TypographyUnified.heading3;

  // Headline Aliases (Material TextTheme compatibility)
  TextStyle get headlineLarge => TypographyUnified.heading1;
  TextStyle get headlineMedium => TypographyUnified.heading2;
  TextStyle get headlineSmall => TypographyUnified.heading3;

  // Body Styles
  TextStyle get bodyLarge => TypographyUnified.bodyLarge;
  TextStyle get bodyMedium => TypographyUnified.bodyMedium;
  TextStyle get bodySmall => TypographyUnified.bodySmall;

  // Label Styles
  TextStyle get labelLarge => TypographyUnified.labelLarge;
  TextStyle get labelMedium => TypographyUnified.labelMedium;
  TextStyle get labelSmall => TypographyUnified.labelSmall;
  TextStyle get labelTiny => TypographyUnified.labelTiny;

  // Button Styles
  TextStyle get buttonLarge => TypographyUnified.buttonLarge;
  TextStyle get buttonMedium => TypographyUnified.buttonMedium;
  TextStyle get buttonSmall => TypographyUnified.buttonSmall;
  TextStyle get buttonTiny => TypographyUnified.buttonTiny;

  // Number Styles
  TextStyle get numberXLarge => TypographyUnified.numberXLarge;
  TextStyle get numberLarge => TypographyUnified.numberLarge;
  TextStyle get numberMedium => TypographyUnified.numberMedium;
  TextStyle get numberSmall => TypographyUnified.numberSmall;
}

/// TextStyle extension for theme color application
///
/// Usage:
/// ```dart
/// Text('Title', style: TypographyUnified.heading1.withColor(context))
/// Text('Body', style: context.bodyMedium.withColor(context))
/// ```
extension TextStyleThemeColor on TextStyle {
  /// Apply theme-aware text color
  TextStyle withColor(BuildContext context,
      {Color? lightColor, Color? darkColor}) {
    return TypographyUnified.withThemeColor(
      this,
      context,
      lightColor: lightColor,
      darkColor: darkColor,
    );
  }

  /// Apply light mode color
  TextStyle withLightColor({Color? color}) {
    return TypographyUnified.withLightColor(this, color: color);
  }

  /// Apply dark mode color
  TextStyle withDarkColor({Color? color}) {
    return TypographyUnified.withDarkColor(this, color: color);
  }
}
