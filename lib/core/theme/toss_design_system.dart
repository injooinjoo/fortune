import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 토스 디자인 시스템 완전 정의
/// Toss Design System Complete Definition
class TossDesignSystem {
  // ==========================================
  // 1. COLOR SYSTEM (색상 시스템)
  // ==========================================
  
  /// Primary Brand Colors
  static const Color tossBlue = Color(0xFF3182F6);  // 토스 시그니처 블루
  static const Color tossBlueDark = Color(0xFF1E5EDB);  // 다크 모드용 블루
  static const Color tossBlueLight = Color(0xFF4A9EFF);  // 라이트 블루
  
  /// Grayscale (회색 스케일)
  static const Color gray900 = Color(0xFF191F28);  // 가장 진한 회색 (주 텍스트)
  static const Color gray800 = Color(0xFF333D4B);
  static const Color gray700 = Color(0xFF4E5968);
  static const Color gray600 = Color(0xFF6B7684);
  static const Color gray500 = Color(0xFF8B95A1);
  static const Color gray400 = Color(0xFFB0B8C1);
  static const Color gray300 = Color(0xFFD1D6DB);
  static const Color gray200 = Color(0xFFE5E8EB);
  static const Color gray100 = Color(0xFFF2F4F6);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  /// Dark Mode Grayscale (다크모드 회색 스케일)
  static const Color grayDark50 = Color(0xFF17171C);   // 다크모드 배경
  static const Color grayDark100 = Color(0xFF26262E);  // 다크모드 카드
  static const Color grayDark200 = Color(0xFF3A3A42);  // 다크모드 표면
  static const Color grayDark300 = Color(0xFF404048);  // 다크모드 테두리
  static const Color grayDark400 = Color(0xFF6B7280);  // 다크모드 보조 텍스트
  static const Color grayDark500 = Color(0xFF9CA3AF);  // 다크모드 힌트
  static const Color grayDark600 = Color(0xFFB0B8C1);
  static const Color grayDark700 = Color(0xFFD1D6DB);
  static const Color grayDark800 = Color(0xFFE5E8EB);
  static const Color grayDark900 = Color(0xFFFFFFFF);  // 다크모드 주 텍스트
  
  /// Semantic Colors (의미론적 색상)
  static const Color successGreen = Color(0xFF10B981);  // 성공, 긍정
  static const Color warningOrange = Color(0xFFF59E0B);  // 경고, 주의
  static const Color errorRed = Color(0xFFEF4444);    // 에러, 실패
  static const Color infoBlue = Color(0xFF3182F6);     // 정보
  static const Color purple = Color(0xFF8B5CF6);       // 보라색
  
  /// Dark Mode Semantic Colors (다크모드 의미론적 색상)
  static const Color successGreenDark = Color(0xFF34D399);
  static const Color warningOrangeDark = Color(0xFFFBBF24);
  static const Color errorRedDark = Color(0xFFF87171);
  static const Color infoBlueDark = Color(0xFF60A5FA);
  
  /// Background Colors (배경 색상)
  static const Color backgroundPrimary = white;
  static const Color backgroundSecondary = gray50;
  static const Color backgroundTertiary = gray100;
  static const Color backgroundElevated = white;
  
  /// Surface Colors (표면 색상)
  static const Color surfacePrimary = white;
  static const Color surfaceSecondary = gray50;
  static const Color surfaceOverlay = Color(0x99000000);  // 60% black
  
  // ==========================================
  // 2. TYPOGRAPHY SYSTEM (타이포그래피)
  // ==========================================
  
  /// Font Families
  static const String fontFamilyKorean = 'TossProductSans';  // 토스 전용 폰트
  static const String fontFamilyEnglish = 'SF Pro Display';
  static const String fontFamilyNumber = 'TossFace';  // 금액 표시용
  
  /// Display Styles (큰 제목)
  static const TextStyle display1 = TextStyle(
    fontSize: 48,
    height: 56 / 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
    fontFamily: fontFamilyKorean,
  );
  
  static const TextStyle display2 = TextStyle(
    fontSize: 40,
    height: 48 / 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
    fontFamily: fontFamilyKorean,
  );
  
  /// Heading Styles (제목)
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    fontFamily: fontFamilyKorean,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    fontFamily: fontFamilyKorean,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFamily: fontFamilyKorean,
  );
  
  static const TextStyle heading4 = TextStyle(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFamily: fontFamilyKorean,
  );
  
  /// Body Styles (본문)
  static const TextStyle body1 = TextStyle(
    fontSize: 17,
    height: 26 / 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: fontFamilyKorean,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 15,
    height: 24 / 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: fontFamilyKorean,
  );
  
  static const TextStyle body3 = TextStyle(
    fontSize: 14,
    height: 22 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: fontFamilyKorean,
  );
  
  /// Caption & Small (캡션)
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    height: 20 / 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: fontFamilyKorean,
  );
  
  static const TextStyle caption1 = TextStyle(
    fontSize: 13,
    height: 20 / 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: fontFamilyKorean,
  );
  
  static const TextStyle small = TextStyle(
    fontSize: 12,
    height: 18 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: fontFamilyKorean,
  );
  
  /// Button Style
  static const TextStyle button = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFamily: fontFamilyKorean,
  );
  
  /// Amount Style (금액 표시)
  static TextStyle amountLarge = const TextStyle(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
    fontFamily: fontFamilyNumber,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  
  static TextStyle amountMedium = const TextStyle(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01,
    fontFamily: fontFamilyNumber,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  
  // ==========================================
  // 3. SPACING SYSTEM (간격 시스템)
  // ==========================================
  
  /// Base unit: 4px
  static const double spacingBase = 4.0;
  
  static const double spacingXXS = 2.0;   // 2px
  static const double spacingXS = 4.0;    // 4px
  static const double spacingS = 8.0;     // 8px
  static const double spacingM = 16.0;    // 16px
  static const double spacingL = 24.0;    // 24px
  static const double spacingXL = 32.0;   // 32px
  static const double spacingXXL = 40.0;  // 40px
  static const double spacing3XL = 48.0;  // 48px
  static const double spacing4XL = 64.0;  // 64px
  
  /// Page Margins
  static const double marginHorizontal = 20.0;
  static const double marginVertical = 16.0;
  
  // ==========================================
  // 4. RADIUS SYSTEM (모서리 반경)
  // ==========================================
  
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusFull = 9999.0;
  
  // ==========================================
  // 5. ELEVATION & SHADOWS (그림자)
  // ==========================================
  
  static List<BoxShadow> shadowXS = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      offset: const Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> shadowS = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> shadowM = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> shadowL = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> shadowXL = [
    BoxShadow(
      color: Colors.black.withOpacity(0.16),
      offset: const Offset(0, 12),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];
  
  // ==========================================
  // 6. ANIMATION (애니메이션)
  // ==========================================
  
  /// Duration
  static const Duration durationMicro = Duration(milliseconds: 100);
  static const Duration durationShort = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationLong = Duration(milliseconds: 500);
  static const Duration durationXLong = Duration(milliseconds: 800);
  
  /// Curves
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveEmphasized = Curves.easeOutCubic;
  static const Curve curveDecelerate = Curves.decelerate;
  static const Curve curveAccelerate = Curves.easeIn;
  
  // ==========================================
  // 7. COMPONENT STYLES (컴포넌트 스타일)
  // ==========================================
  
  /// Button Heights
  static const double buttonHeightLarge = 56.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightSmall = 40.0;
  
  /// Input Field Heights
  static const double inputHeightDefault = 48.0;
  static const double inputHeightLarge = 56.0;
  
  /// Card Styles
  static BoxDecoration cardDecoration({
    Color? backgroundColor,
    List<BoxShadow>? shadows,
    Border? border,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? white,
      borderRadius: BorderRadius.circular(radiusM),
      boxShadow: shadows ?? shadowS,
      border: border,
    );
  }
  
  /// Button Styles
  static ButtonStyle primaryButtonStyle({
    bool isEnabled = true,
    Size? fixedSize,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: isEnabled ? tossBlue : gray300,
      foregroundColor: white,
      disabledBackgroundColor: gray300,
      disabledForegroundColor: gray500,
      elevation: 0,
      shadowColor: Colors.transparent,
      fixedSize: fixedSize ?? Size.fromHeight(buttonHeightLarge),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      textStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    );
  }
  
  static ButtonStyle secondaryButtonStyle({
    bool isEnabled = true,
    Size? fixedSize,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: gray100,
      foregroundColor: isEnabled ? gray900 : gray500,
      disabledBackgroundColor: gray100,
      disabledForegroundColor: gray400,
      elevation: 0,
      shadowColor: Colors.transparent,
      fixedSize: fixedSize ?? Size.fromHeight(buttonHeightLarge),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      textStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    );
  }
  
  static ButtonStyle ghostButtonStyle({
    bool isEnabled = true,
    Size? fixedSize,
  }) {
    return TextButton.styleFrom(
      foregroundColor: isEnabled ? tossBlue : gray400,
      backgroundColor: Colors.transparent,
      disabledForegroundColor: gray400,
      fixedSize: fixedSize,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
    );
  }
  
  /// Input Decoration
  static InputDecoration inputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isFocused = false,
    bool hasError = false,
    String? errorText,
  }) {
    Color borderColor;
    if (hasError) {
      borderColor = errorRed;
    } else if (isFocused) {
      borderColor = tossBlue;
    } else {
      borderColor = gray200;
    }
    
    return InputDecoration(
      hintText: hintText,
      hintStyle: body2.copyWith(color: gray400),
      errorText: errorText,
      errorStyle: caption1.copyWith(color: errorRed),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isFocused ? white : gray50,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingM,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: BorderSide(color: borderColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: BorderSide(color: borderColor, width: 2),
      ),
    );
  }
  
  // ==========================================
  // 8. HAPTIC FEEDBACK (햅틱 피드백)
  // ==========================================
  
  static void hapticLight() {
    HapticFeedback.lightImpact();
  }
  
  static void hapticMedium() {
    HapticFeedback.mediumImpact();
  }
  
  static void hapticHeavy() {
    HapticFeedback.heavyImpact();
  }
  
  static void hapticSelection() {
    HapticFeedback.selectionClick();
  }
  
  // ==========================================
  // 9. RESPONSIVE BREAKPOINTS
  // ==========================================
  
  static const double breakpointMobile = 360.0;
  static const double breakpointTablet = 768.0;
  static const double breakpointDesktop = 1024.0;
  static const double maxContentWidth = 640.0;
  
  // ==========================================
  // 10. ACCESSIBILITY (접근성)
  // ==========================================
  
  /// Minimum touch target size
  static const double minTouchTarget = 44.0;
  static const double recommendedTouchTarget = 48.0;
  
  /// Text contrast ratios
  static const double contrastRatioAA = 4.5;
  static const double contrastRatioAAA = 7.0;
  
  /// Focus indicator
  static BoxDecoration focusDecoration = BoxDecoration(
    border: Border.all(color: tossBlue, width: 2),
    borderRadius: BorderRadius.circular(radiusS),
  );
}

/// Extension for easy access
extension TossDesignSystemContext on BuildContext {
  TossDesignSystem get toss => TossDesignSystem();
}

/// 토스 스타일 금액 포맷터
class TossAmountFormatter {
  static String format(int amount, {bool showCurrency = true}) {
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return showCurrency ? '$formatted원' : formatted;
  }
  
  static String formatCompact(int amount) {
    if (amount >= 100000000) {
      return '${(amount / 100000000).toStringAsFixed(1)}억';
    } else if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(1)}만';
    }
    return format(amount, showCurrency: false);
  }
}

/// 토스 스타일 날짜 포맷터
class TossDateFormatter {
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return '방금 전';
        }
        return '${difference.inMinutes}분 전';
      }
      return '${difference.inHours}시간 전';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}주 전';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}개월 전';
    }
    return '${(difference.inDays / 365).floor()}년 전';
  }
  
  static String formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
  
  static String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}