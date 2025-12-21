import 'package:flutter/material.dart';
import 'package:fortune/core/theme/typography_unified.dart';

/// ⚠️ DEPRECATED: FortuneTheme은 이제 사용하지 않습니다!
///
/// 색상은 FortuneDesignSystem을 사용하세요.
/// 타이포그래피는 TypographyUnified를 사용하세요.
///
/// 마이그레이션 가이드:
/// - Colors → FortuneDesignSystem
/// - TextStyles → TypographyUnified
/// - Spacing → FortuneDesignSystem
class FortuneTheme {
  // Colors
  static const Color primaryBlue = Color(0xFF0066FF);
  static const Color brandBlue = Color(0xFF0066FF);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF8F9FA);
  static const Color textBlack = Color(0xFF000000);
  static const Color textGray600 = Color(0xFF666666);
  static const Color textGray500 = Color(0xFF888888);
  static const Color textGray400 = Color(0xFF999999);
  static const Color borderGray300 = Color(0xFFDDDDDD);
  static const Color borderGray200 = Color(0xFFEEEEEE);
  static const Color borderPrimary = Color(0xFFDDDDDD);
  static const Color disabledGray = Color(0xFFCCCCCC);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // ⚠️ DEPRECATED: fontFamily는 TypographyUnified를 사용하세요
  /// @deprecated Use TypographyUnified.fontFamilyKorean instead
  static const String fontFamily = 'Pretendard';

  // ⚠️ DEPRECATED: Text Styles는 TypographyUnified를 사용하세요
  /// @deprecated Use TypographyUnified.displaySmall instead
  static TextStyle get heading1 => TypographyUnified.displaySmall.copyWith(color: textBlack);

  /// @deprecated Use TypographyUnified.heading1 instead
  static TextStyle get heading2 => TypographyUnified.heading1.copyWith(color: textBlack);

  /// @deprecated Use TypographyUnified.heading3 instead
  static TextStyle get heading3 => TypographyUnified.heading3.copyWith(color: textBlack);

  /// @deprecated Use TypographyUnified.buttonMedium instead
  static TextStyle get heading4 => TypographyUnified.buttonMedium.copyWith(color: textBlack);

  /// @deprecated Use TypographyUnified.bodySmall instead
  static TextStyle get heading5 => TypographyUnified.bodySmall.copyWith(color: textBlack);

  /// @deprecated Use TypographyUnified.heading4 instead
  static TextStyle get subtitle1 => TypographyUnified.heading4.copyWith(color: textGray600);

  /// @deprecated Use TypographyUnified.buttonMedium instead
  static TextStyle get subtitle2 => TypographyUnified.buttonMedium.copyWith(color: textGray600);

  /// @deprecated Use TypographyUnified.heading2 instead (크기 다름 주의)
  static TextStyle get body1 => TypographyUnified.heading2.copyWith(color: textBlack);

  /// @deprecated Use TypographyUnified.heading3 instead
  static TextStyle get body2 => TypographyUnified.heading3.copyWith(color: textBlack);

  /// @deprecated Use TypographyUnified.buttonMedium instead
  static TextStyle get body3 => TypographyUnified.buttonMedium.copyWith(color: textBlack);

  /// @deprecated Use TypographyUnified.bodySmall instead
  static TextStyle get caption => TypographyUnified.bodySmall.copyWith(color: textGray600);

  /// @deprecated Use TypographyUnified.heading4 instead
  static TextStyle get button => TypographyUnified.heading4.copyWith(fontWeight: FontWeight.w700);

  // Input Styles
  static TextStyle get inputStyle => body1;

  static TextStyle get hintStyle => body1.copyWith(
    color: textGray400,
    fontWeight: FontWeight.w400,
  );
  
  // Spacing
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXL = 32;
  static const double spacingXXL = 40;
  
  // Border Radius
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 20;
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 600);
  
  // Button Styles
  static ButtonStyle primaryButtonStyle(bool isEnabled) {
    return ElevatedButton.styleFrom(
      backgroundColor: isEnabled ? primaryBlue : disabledGray,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusL),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      textStyle: button,
    );
  }
  
  // Input Decoration
  static InputDecoration inputDecoration({
    required String hintText,
    required bool hasFocus,
    required bool isValid,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
    );
  }
  
  // Input Border
  static Border inputBorder({
    required bool hasFocus,
    required bool isValid,
  }) {
    Color borderColor;
    double borderWidth;
    
    if (hasFocus || isValid) {
      borderColor = primaryBlue;
      borderWidth = 2.0;
    } else {
      borderColor = borderGray300;
      borderWidth = 1.0;
    }
    
    return Border(
      bottom: BorderSide(
        color: borderColor,
        width: borderWidth,
      ),
    );
  }
  
  // Progress Indicator Style
  static BoxDecoration progressBarDecoration({required bool isActive}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(2),
      color: isActive ? primaryBlue : borderGray200,
    );
  }
}

// Theme Extension for easier access
extension FortuneThemeExtension on BuildContext {
  FortuneTheme get fortuneTheme => FortuneTheme();
}

/// @deprecated Use FortuneThemeExtension instead
extension TossThemeExtension on BuildContext {
  FortuneTheme get tossTheme => FortuneTheme();
}

/// @deprecated Use FortuneTheme instead
typedef TossTheme = FortuneTheme;