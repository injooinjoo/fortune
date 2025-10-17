import 'package:flutter/material.dart';
import 'package:fortune/core/theme/font_size_system.dart';
import 'package:fortune/core/theme/toss_design_system.dart';

/// 통합 타이포그래피 시스템
///
/// FontSizeSystem을 기반으로 한 일관된 TextStyle을 제공합니다.
/// 사용자 설정에 따라 폰트 크기가 자동으로 조절됩니다.
///
/// 사용 예시:
/// ```dart
/// // BuildContext extension 사용 (권장)
/// Text('제목', style: context.typo.heading1)
/// Text('본문', style: context.typo.bodyMedium)
///
/// // 직접 사용
/// Text('제목', style: TypographyUnified.heading1)
/// Text('본문', style: TypographyUnified.bodyMedium)
/// ```
class TypographyUnified {
  // ==========================================
  // FONT FAMILIES
  // ==========================================

  /// 한글 폰트
  static const String fontFamilyKorean = 'Pretendard';

  /// 영문 폰트
  static const String fontFamilyEnglish = 'SF Pro Display';

  /// 숫자 전용 폰트 (TossFace)
  static const String fontFamilyNumber = 'TossFace';

  /// 기본 폰트 (한글)
  static const String fontFamilyDefault = fontFamilyKorean;

  // ==========================================
  // DISPLAY STYLES (대형 헤드라인)
  // ==========================================
  //
  // 스플래시, 온보딩, 메인 배너 등 큰 타이틀에 사용

  /// Display Large - 가장 큰 헤드라인 (48pt)
  static TextStyle get displayLarge => TextStyle(
        fontSize: FontSizeSystem.displayLargeScaled,
        height: 1.17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02,
        fontFamily: fontFamilyKorean,
      );

  /// Display Medium - 큰 헤드라인 (40pt)
  static TextStyle get displayMedium => TextStyle(
        fontSize: FontSizeSystem.displayMediumScaled,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02,
        fontFamily: fontFamilyKorean,
      );

  /// Display Small - 중간 헤드라인 (32pt)
  static TextStyle get displaySmall => TextStyle(
        fontSize: FontSizeSystem.displaySmallScaled,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01,
        fontFamily: fontFamilyKorean,
      );

  // ==========================================
  // HEADING STYLES (섹션 제목)
  // ==========================================
  //
  // 페이지 제목, 섹션 헤더에 사용

  /// Heading 1 - 메인 페이지 제목 (28pt)
  static TextStyle get heading1 => TextStyle(
        fontSize: FontSizeSystem.heading1Scaled,
        height: 1.29,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01,
        fontFamily: fontFamilyKorean,
      );

  /// Heading 2 - 섹션 제목 (24pt)
  static TextStyle get heading2 => TextStyle(
        fontSize: FontSizeSystem.heading2Scaled,
        height: 1.33,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        fontFamily: fontFamilyKorean,
      );

  /// Heading 3 - 서브 섹션 제목 (20pt)
  static TextStyle get heading3 => TextStyle(
        fontSize: FontSizeSystem.heading3Scaled,
        height: 1.4,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        fontFamily: fontFamilyKorean,
      );

  /// Heading 4 - 작은 섹션 제목 (18pt)
  static TextStyle get heading4 => TextStyle(
        fontSize: FontSizeSystem.heading4Scaled,
        height: 1.44,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        fontFamily: fontFamilyKorean,
      );

  // ==========================================
  // BODY STYLES (본문 텍스트)
  // ==========================================
  //
  // 일반 텍스트, 설명 등에 사용

  /// Body Large - 큰 본문 (17pt)
  static TextStyle get bodyLarge => TextStyle(
        fontSize: FontSizeSystem.bodyLargeScaled,
        height: 1.53,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        fontFamily: fontFamilyKorean,
      );

  /// Body Medium - 기본 본문 (15pt)
  static TextStyle get bodyMedium => TextStyle(
        fontSize: FontSizeSystem.bodyMediumScaled,
        height: 1.6,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        fontFamily: fontFamilyKorean,
      );

  /// Body Small - 작은 본문 (14pt)
  static TextStyle get bodySmall => TextStyle(
        fontSize: FontSizeSystem.bodySmallScaled,
        height: 1.57,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        fontFamily: fontFamilyKorean,
      );

  // ==========================================
  // LABEL STYLES (라벨, 캡션)
  // ==========================================
  //
  // 버튼 라벨, 입력 필드 힌트, 캡션 등에 사용

  /// Label Large - 큰 라벨 (13pt)
  static TextStyle get labelLarge => TextStyle(
        fontSize: FontSizeSystem.labelLargeScaled,
        height: 1.54,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        fontFamily: fontFamilyKorean,
      );

  /// Label Medium - 기본 라벨 (12pt)
  static TextStyle get labelMedium => TextStyle(
        fontSize: FontSizeSystem.labelMediumScaled,
        height: 1.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        fontFamily: fontFamilyKorean,
      );

  /// Label Small - 작은 라벨 (11pt)
  static TextStyle get labelSmall => TextStyle(
        fontSize: FontSizeSystem.labelSmallScaled,
        height: 1.45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        fontFamily: fontFamilyKorean,
      );

  /// Label Tiny - 매우 작은 라벨 (10pt)
  /// 배지, NEW 표시 등에 사용
  static TextStyle get labelTiny => TextStyle(
        fontSize: FontSizeSystem.labelTinyScaled,
        height: 1.4,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        fontFamily: fontFamilyKorean,
      );

  // ==========================================
  // BUTTON STYLES (버튼 텍스트)
  // ==========================================
  //
  // 버튼 내부 텍스트에 사용

  /// Button Large - 큰 버튼 (17pt)
  static TextStyle get buttonLarge => TextStyle(
        fontSize: FontSizeSystem.buttonLargeScaled,
        height: 1.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        fontFamily: fontFamilyKorean,
      );

  /// Button Medium - 기본 버튼 (16pt)
  static TextStyle get buttonMedium => TextStyle(
        fontSize: FontSizeSystem.buttonMediumScaled,
        height: 1.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        fontFamily: fontFamilyKorean,
      );

  /// Button Small - 작은 버튼 (15pt)
  static TextStyle get buttonSmall => TextStyle(
        fontSize: FontSizeSystem.buttonSmallScaled,
        height: 1.47,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        fontFamily: fontFamilyKorean,
      );

  /// Button Tiny - 매우 작은 버튼 (14pt)
  static TextStyle get buttonTiny => TextStyle(
        fontSize: FontSizeSystem.buttonTinyScaled,
        height: 1.43,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        fontFamily: fontFamilyKorean,
      );

  // ==========================================
  // NUMBER STYLES (숫자 전용)
  // ==========================================
  //
  // 금액, 점수 등 숫자 표시에 사용 (TossFace 폰트)

  /// Number XLarge - 매우 큰 숫자 (40pt)
  static TextStyle get numberXLarge => TextStyle(
        fontSize: FontSizeSystem.numberXLargeScaled,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        fontFamily: fontFamilyNumber,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Number Large - 큰 숫자 (32pt)
  static TextStyle get numberLarge => TextStyle(
        fontSize: FontSizeSystem.numberLargeScaled,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02,
        fontFamily: fontFamilyNumber,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Number Medium - 중간 숫자 (24pt)
  static TextStyle get numberMedium => TextStyle(
        fontSize: FontSizeSystem.numberMediumScaled,
        height: 1.33,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01,
        fontFamily: fontFamilyNumber,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Number Small - 작은 숫자 (18pt)
  static TextStyle get numberSmall => TextStyle(
        fontSize: FontSizeSystem.numberSmallScaled,
        height: 1.44,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        fontFamily: fontFamilyNumber,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // ==========================================
  // BACKWARD COMPATIBILITY ALIASES
  // ==========================================
  //
  // 기존 코드와의 호환성을 위한 alias

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
  //
  // 다크모드 대응을 위한 색상 헬퍼

  /// 라이트모드용 TextStyle 생성
  static TextStyle withLightColor(TextStyle style, {Color? color}) {
    return style.copyWith(
      color: color ?? TossDesignSystem.textPrimaryLight,
    );
  }

  /// 다크모드용 TextStyle 생성
  static TextStyle withDarkColor(TextStyle style, {Color? color}) {
    return style.copyWith(
      color: color ?? TossDesignSystem.textPrimaryDark,
    );
  }

  /// BuildContext에서 현재 테마에 맞는 색상 적용
  static TextStyle withThemeColor(
    TextStyle style,
    BuildContext context, {
    Color? lightColor,
    Color? darkColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return withDarkColor(style, color: darkColor);
    } else {
      return withLightColor(style, color: lightColor);
    }
  }
}

/// BuildContext extension for easy access
///
/// 사용 예시:
/// ```dart
/// Text('제목', style: context.typo.heading1)
/// Text('본문', style: context.typo.bodyMedium.withColor(context))
/// ```
extension TypographyUnifiedExtension on BuildContext {
  /// TypographyUnified 인스턴스 접근
  TypographyUnified get typo => TypographyUnified();

  // Display Styles
  TextStyle get displayLarge => TypographyUnified.displayLarge;
  TextStyle get displayMedium => TypographyUnified.displayMedium;
  TextStyle get displaySmall => TypographyUnified.displaySmall;

  // Heading Styles
  TextStyle get heading1 => TypographyUnified.heading1;
  TextStyle get heading2 => TypographyUnified.heading2;
  TextStyle get heading3 => TypographyUnified.heading3;
  TextStyle get heading4 => TypographyUnified.heading4;

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
/// 사용 예시:
/// ```dart
/// Text('제목', style: TypographyUnified.heading1.withColor(context))
/// Text('본문', style: context.typo.bodyMedium.withColor(context))
/// ```
extension TextStyleThemeColor on TextStyle {
  /// 현재 테마에 맞는 텍스트 색상 적용
  TextStyle withColor(BuildContext context, {Color? lightColor, Color? darkColor}) {
    return TypographyUnified.withThemeColor(
      this,
      context,
      lightColor: lightColor,
      darkColor: darkColor,
    );
  }

  /// 라이트모드 색상 적용
  TextStyle withLightColor({Color? color}) {
    return TypographyUnified.withLightColor(this, color: color);
  }

  /// 다크모드 색상 적용
  TextStyle withDarkColor({Color? color}) {
    return TypographyUnified.withDarkColor(this, color: color);
  }
}
