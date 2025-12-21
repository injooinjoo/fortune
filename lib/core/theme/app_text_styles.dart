import 'package:flutter/material.dart';
import 'package:fortune/core/theme/typography_unified.dart';
import 'package:fortune/core/theme/fortune_design_system.dart';

/// ⚠️ DEPRECATED: AppTextStyles는 이제 사용하지 않습니다!
///
/// TypographyUnified를 사용하세요.
///
/// 마이그레이션 가이드:
/// - headline1 → TypographyUnified.displaySmall
/// - headline2 → TypographyUnified.heading1
/// - headline3 → TypographyUnified.heading2
/// - headline4 → TypographyUnified.heading3
/// - bodyLarge → TypographyUnified.buttonMedium
/// - bodyMedium → TypographyUnified.bodySmall
/// - bodySmall → TypographyUnified.labelMedium
///
/// 사용 예시:
/// ```dart
/// // ❌ 기존
/// Text('제목', style: AppTextStyles.headline1)
///
/// // ✅ 신규
/// Text('제목', style: TypographyUnified.displaySmall)
/// Text('제목', style: context.typo.displaySmall)
/// ```
class AppTextStyles {
  // Headline styles → TypographyUnified로 리다이렉트
  /// @deprecated Use TypographyUnified.displaySmall instead
  static TextStyle get headline1 => TypographyUnified.displaySmall.copyWith(
    color: TossDesignSystem.gray900,
  );

  /// @deprecated Use TypographyUnified.heading1 instead
  static TextStyle get headline2 => TypographyUnified.heading1.copyWith(
    color: TossDesignSystem.gray900,
  );

  /// @deprecated Use TypographyUnified.heading2 instead
  static TextStyle get headline3 => TypographyUnified.heading2.copyWith(
    color: TossDesignSystem.gray900,
  );

  /// @deprecated Use TypographyUnified.heading3 instead
  static TextStyle get headline4 => TypographyUnified.heading3.copyWith(
    color: TossDesignSystem.gray900,
  );

  /// @deprecated Use TypographyUnified.heading4 instead
  static TextStyle get headline5 => TypographyUnified.heading4.copyWith(
    color: TossDesignSystem.gray900,
  );

  /// @deprecated Use TypographyUnified.buttonMedium instead
  static TextStyle get headline6 => TypographyUnified.buttonMedium.copyWith(
    color: TossDesignSystem.gray900,
  );

  // Body styles → TypographyUnified로 리다이렉트
  /// @deprecated Use TypographyUnified.buttonMedium instead
  static TextStyle get bodyLarge => TypographyUnified.buttonMedium.copyWith(
    color: TossDesignSystem.gray900,
  );

  /// @deprecated Use TypographyUnified.bodySmall instead
  static TextStyle get bodyMedium => TypographyUnified.bodySmall.copyWith(
    color: TossDesignSystem.gray900,
  );

  /// @deprecated Use TypographyUnified.labelMedium instead
  static TextStyle get bodySmall => TypographyUnified.labelMedium.copyWith(
    color: TossDesignSystem.gray600,
  );

  // Label styles → TypographyUnified로 리다이렉트
  /// @deprecated Use TypographyUnified.bodySmall instead
  static TextStyle get labelLarge => TypographyUnified.bodySmall.copyWith(
    color: TossDesignSystem.gray900,
    fontWeight: FontWeight.w500,
  );

  /// @deprecated Use TypographyUnified.labelMedium instead
  static TextStyle get labelMedium => TypographyUnified.labelMedium.copyWith(
    color: TossDesignSystem.gray900,
  );

  /// @deprecated Use TypographyUnified.labelSmall instead
  static TextStyle get labelSmall => TypographyUnified.labelSmall.copyWith(
    color: TossDesignSystem.gray600,
  );

  // Button styles → TypographyUnified로 리다이렉트
  /// @deprecated Use TypographyUnified.buttonMedium instead
  static TextStyle get buttonLarge => TypographyUnified.buttonMedium;

  /// @deprecated Use TypographyUnified.buttonSmall instead
  static TextStyle get buttonMedium => TypographyUnified.buttonSmall;

  /// @deprecated Use TypographyUnified.labelMedium instead
  static TextStyle get buttonSmall => TypographyUnified.labelMedium.copyWith(
    fontWeight: FontWeight.w600,
  );

  // Caption styles → TypographyUnified로 리다이렉트
  /// @deprecated Use TypographyUnified.labelMedium instead
  static TextStyle get caption => TypographyUnified.labelMedium.copyWith(
    color: TossDesignSystem.gray400,
  );

  /// @deprecated Use TypographyUnified.labelTiny instead
  static TextStyle get overline => TypographyUnified.labelTiny.copyWith(
    color: TossDesignSystem.gray400,
    letterSpacing: 1.5,
  );

  // Aliases for backward compatibility
  static TextStyle get body1 => bodyMedium;
  static TextStyle get body2 => bodySmall;
  static TextStyle get heading2 => headline2;
  static TextStyle get heading3 => headline3;
  static TextStyle get headlineLarge => headline1;
  static TextStyle get headlineMedium => headline3;
}
