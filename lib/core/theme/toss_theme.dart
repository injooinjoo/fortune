import 'package:flutter/material.dart';

class TossTheme {
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
  
  // Typography
  static const String fontFamily = 'Pretendard'; // Toss uses Pretendard font
  
  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: textBlack,
    height: 1.1,
    letterSpacing: -0.5,
    fontFamily: fontFamily,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textBlack,
    height: 1.2,
    letterSpacing: -0.3,
    fontFamily: fontFamily,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textBlack,
    height: 1.3,
    letterSpacing: -0.2,
    fontFamily: fontFamily,
  );
  
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: textGray600,
    letterSpacing: -0.2,
    fontFamily: fontFamily,
  );
  
  static const TextStyle subtitle2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textGray600,
    letterSpacing: -0.1,
    fontFamily: fontFamily,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textBlack,
    letterSpacing: -0.2,
    fontFamily: fontFamily,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: textBlack,
    letterSpacing: -0.1,
    fontFamily: fontFamily,
  );
  
  static const TextStyle body3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textBlack,
    letterSpacing: -0.1,
    fontFamily: fontFamily,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textGray600,
    fontFamily: fontFamily,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    fontFamily: fontFamily,
  );
  
  // Input Styles
  static TextStyle inputStyle = body1;
  
  static TextStyle hintStyle = body1.copyWith(
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
extension TossThemeExtension on BuildContext {
  TossTheme get tossTheme => TossTheme();
}