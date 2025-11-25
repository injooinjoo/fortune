import 'package:flutter/material.dart';
import 'package:fortune/core/theme/typography_unified.dart';

/// ⚠️ DEPRECATED: AppTypography는 이제 사용하지 않습니다!
///
/// TypographyUnified를 사용하세요.
///
/// 마이그레이션 가이드:
/// - displayLarge → TypographyUnified.heading1
/// - headlineMedium → TypographyUnified.heading2
/// - bodyLarge → TypographyUnified.bodySmall
/// - numberLarge → TypographyUnified.numberLarge
///
/// 사용 예시:
/// ```dart
/// // ❌ 기존
/// Text('제목', style: AppTypography.headlineLarge)
///
/// // ✅ 신규
/// Text('제목', style: TypographyUnified.heading1)
/// Text('제목', style: context.typo.heading1)
/// ```
class AppTypography {
  // Font family - TypographyUnified로 통합
  /// @deprecated Use TypographyUnified.fontFamilyEnglish instead
  static const String fontFamily = 'SF Pro Display';

  // Display styles → TypographyUnified로 리다이렉트
  /// @deprecated Use TypographyUnified.heading1 instead
  static TextStyle get displayLarge => TypographyUnified.heading1;

  /// @deprecated Use TypographyUnified.heading1 instead
  static TextStyle get displayMedium => TypographyUnified.heading1;

  /// @deprecated Use TypographyUnified.heading1 instead
  static TextStyle get displaySmall => TypographyUnified.heading1;

  // Headline styles → TypographyUnified로 리다이렉트
  /// @deprecated Use TypographyUnified.heading1 instead
  static TextStyle get headlineLarge => TypographyUnified.heading1;

  /// @deprecated Use TypographyUnified.heading2 instead
  static TextStyle get headlineMedium => TypographyUnified.heading2;

  /// @deprecated Use TypographyUnified.heading3 instead
  static TextStyle get headlineSmall => TypographyUnified.heading3;

  // Title styles → TypographyUnified로 리다이렉트
  /// @deprecated Use TypographyUnified.heading3 instead
  static TextStyle get titleLarge => TypographyUnified.heading3;

  /// @deprecated Use TypographyUnified.bodyLarge instead
  static TextStyle get titleMedium => TypographyUnified.bodyLarge;

  /// @deprecated Use TypographyUnified.bodyMedium instead
  static TextStyle get titleSmall => TypographyUnified.bodyMedium;

  // Body styles → TypographyUnified로 리다이렉트
  /// @deprecated Use TypographyUnified.bodySmall instead
  static TextStyle get bodyLarge => TypographyUnified.bodySmall;

  /// @deprecated Use TypographyUnified.bodySmall instead
  static TextStyle get bodyMedium => TypographyUnified.bodySmall;

  /// @deprecated Use TypographyUnified.labelLarge instead
  static TextStyle get bodySmall => TypographyUnified.labelLarge;

  // Label styles → TypographyUnified로 리다이렉트
  /// @deprecated Use TypographyUnified.buttonMedium instead
  static TextStyle get labelLarge => TypographyUnified.buttonMedium;

  /// @deprecated Use TypographyUnified.buttonMedium instead
  static TextStyle get labelMedium => TypographyUnified.buttonMedium;

  /// @deprecated Use TypographyUnified.labelLarge instead
  static TextStyle get labelSmall => TypographyUnified.labelLarge;

  // Caption styles → TypographyUnified로 리다이렉트
  /// @deprecated Use TypographyUnified.labelLarge instead
  static TextStyle get captionLarge => TypographyUnified.labelLarge;

  /// @deprecated Use TypographyUnified.labelLarge instead
  static TextStyle get captionMedium => TypographyUnified.labelLarge;

  /// @deprecated Use TypographyUnified.labelLarge instead
  static TextStyle get captionSmall => TypographyUnified.labelLarge;

  // Extra small label → TypographyUnified로 리다이렉트
  /// @deprecated Use TypographyUnified.labelTiny instead
  static TextStyle get labelXSmall => TypographyUnified.labelTiny;

  // Special styles → TypographyUnified로 리다이렉트
  /// @deprecated Use TypographyUnified.buttonMedium instead
  static TextStyle get button => TypographyUnified.buttonMedium;

  /// @deprecated Use TypographyUnified.buttonSmall instead
  static TextStyle get buttonSmall => TypographyUnified.buttonSmall;

  /// @deprecated Use TypographyUnified.labelMedium instead
  static TextStyle get overline => TypographyUnified.labelMedium.copyWith(
    fontWeight: FontWeight.w600,
    letterSpacing: 0.04,
  );

  // Numeric styles → TypographyUnified로 리다이렉트
  /// @deprecated Use TypographyUnified.numberXLarge instead
  static TextStyle get numberXLarge => TypographyUnified.numberXLarge;

  /// @deprecated Use TypographyUnified.numberLarge instead
  static TextStyle get numberLarge => TypographyUnified.numberLarge;

  /// @deprecated Use TypographyUnified.numberMedium instead
  static TextStyle get numberMedium => TypographyUnified.numberMedium;

  /// @deprecated Use TypographyUnified.numberSmall instead
  static TextStyle get numberSmall => TypographyUnified.numberSmall;

  // Get text theme for Material Theme
  /// @deprecated Build TextTheme manually with TypographyUnified instead
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
  /// @deprecated Responsive sizing is now handled by FontSizeSystem
  static double responsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0; // Based on iPhone 11 Pro width
    return baseSize * scaleFactor.clamp(0.85, 1.15);
  }
}

/// Extension for easy access to typography styles
/// @deprecated Use TypographyUnifiedExtension instead
extension TypographyExtension on BuildContext {
  AppTypography get typography => AppTypography();

  TextStyle get displayLarge => TypographyUnified.heading1;
  TextStyle get displayMedium => TypographyUnified.heading1;
  TextStyle get displaySmall => TypographyUnified.heading1;

  TextStyle get headlineLarge => TypographyUnified.heading1;
  TextStyle get headlineMedium => TypographyUnified.heading2;
  TextStyle get headlineSmall => TypographyUnified.heading3;

  TextStyle get titleLarge => TypographyUnified.heading2;
  TextStyle get titleMedium => TypographyUnified.heading3;
  TextStyle get titleSmall => TypographyUnified.heading4;

  TextStyle get bodyLarge => TypographyUnified.bodyLarge;
  TextStyle get bodyMedium => TypographyUnified.bodyMedium;
  TextStyle get bodySmall => TypographyUnified.bodySmall;

  TextStyle get labelLarge => TypographyUnified.buttonMedium;
  TextStyle get labelMedium => TypographyUnified.labelLarge;
  TextStyle get labelSmall => TypographyUnified.labelLarge;

  TextStyle get captionLarge => AppTypography.captionLarge;
  TextStyle get captionMedium => AppTypography.captionMedium;
  TextStyle get captionSmall => AppTypography.captionSmall;

  TextStyle get labelXSmall => AppTypography.labelXSmall;

  TextStyle get button => AppTypography.button;
  TextStyle get buttonMedium => AppTypography.button; // Alias for button
  TextStyle get buttonSmall => AppTypography.buttonSmall;

  TextStyle get overline => AppTypography.overline;

  TextStyle get numberXLarge => AppTypography.numberXLarge;
  TextStyle get numberLarge => AppTypography.numberLarge;
  TextStyle get numberMedium => AppTypography.numberMedium;
  TextStyle get numberSmall => AppTypography.numberSmall;
}
