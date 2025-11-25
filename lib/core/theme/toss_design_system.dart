import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'font_size_system.dart';

/// 토스 디자인 시스템 완전 정의
/// Toss Design System Complete Definition
class TossDesignSystem {
  // ==========================================
  // 1. COLOR SYSTEM (색상 시스템)
  // ==========================================
  
  /// Primary Brand Colors
  static const Color tossBlue = Color(0xFF1F4EF5);  // 토스 시그니처 블루 (실제 토스 앱 색상)
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
  static const Color transparent = Color(0x00000000);
  
  /// Dark Mode Grayscale (다크모드 회색 스케일) - 개선된 대비
  static const Color grayDark50 = Color(0xFF17171C);   // 다크모드 배경
  static const Color grayDark100 = Color(0xFF26262E);  // 다크모드 카드
  static const Color grayDark200 = Color(0xFF3A3A42);  // 다크모드 표면
  static const Color grayDark300 = Color(0xFF404048);  // 다크모드 테두리
  static const Color grayDark400 = Color(0xFF9CA3AF);  // 다크모드 보조 텍스트 (개선된 대비)
  static const Color grayDark500 = Color(0xFFD1D6DB);  // 다크모드 힌트 (개선된 대비)
  static const Color grayDark600 = Color(0xFFE5E8EB);  // 밝은 보조 텍스트
  static const Color grayDark700 = Color(0xFFF2F4F6);  // 매우 밝은 텍스트
  static const Color grayDark800 = Color(0xFFF9FAFB);  // 거의 화이트
  static const Color grayDark900 = Color(0xFFFFFFFF);  // 다크모드 주 텍스트

  /// Semantic Background Colors (명확한 배경색 정의)
  /// 배경색 사용 시 항상 이 상수들을 사용하세요!
  static const Color backgroundDark = grayDark50;      // 다크모드 메인 배경 (어두운 회색)
  static const Color backgroundLight = white;          // 라이트모드 메인 배경 (흰색)
  static const Color cardBackgroundDark = grayDark100; // 다크모드 카드 배경
  static const Color cardBackgroundLight = white;      // 라이트모드 카드 배경
  static const Color surfaceBackgroundDark = grayDark200; // 다크모드 서브 배경 (카드 안의 섹션)
  static const Color surfaceBackgroundLight = Color(0xFFF7F8FA); // 라이트모드 서브 배경

  /// Semantic Text Colors (명확한 텍스트색 정의)
  /// 텍스트 색상 사용 시 항상 이 상수들을 사용하세요!
  static const Color textPrimaryDark = grayDark900;    // 다크모드 주 텍스트 (흰색)
  static const Color textPrimaryLight = gray900;       // 라이트모드 주 텍스트 (검은색)
  static const Color textSecondaryDark = grayDark400;  // 다크모드 보조 텍스트
  static const Color textSecondaryLight = gray500;     // 라이트모드 보조 텍스트
  static const Color textTertiaryDark = grayDark500;   // 다크모드 3차 텍스트 (힌트, placeholder)
  static const Color textTertiaryLight = gray400;      // 라이트모드 3차 텍스트

  /// Semantic Divider & Border Colors (구분선 및 테두리 색상)
  static const Color dividerDark = grayDark300;        // 다크모드 구분선
  static const Color dividerLight = gray200;           // 라이트모드 구분선
  static const Color borderDark = grayDark300;         // 다크모드 테두리
  static const Color borderLight = gray300;            // 라이트모드 테두리

  /// Semantic Colors (의미론적 색상)
  static const Color successGreen = Color(0xFF10B981);  // 성공, 긍정
  static const Color warningOrange = Color(0xFFF59E0B);  // 경고, 주의
  static const Color warningYellow = Color(0xFFEAB308);  // 황색 경고
  static const Color primaryYellow = Color(0xFFEAB308); // 프라이머리 황색 (warningYellow와 동일)
  static const Color primaryGreen = Color(0xFF10B981); // 프라이머리 녹색 (successGreen과 동일)
  static const Color primaryRed = Color(0xFFEF4444);   // 프라이머리 빨강 (errorRed와 동일)
  static const Color errorRed = Color(0xFFEF4444);    // 에러, 실패
  static const Color infoBlue = Color(0xFF3182F6);     // 정보
  static const Color purple = Color(0xFF8B5CF6);       // 보라색
  static const Color purple50 = Color(0xFFF5F3FF);     // 매우 연한 보라색
  static const Color teal = Color(0xFF06B6D4);         // 틸
  static const Color orange = Color(0xFFF97316);       // 오렌지
  static const Color pink = Color(0xFFEC4899);         // 핑크
  static const Color bluePrimary = Color(0xFF3182F6);  // 블루 프라이머리

  // Common aliases for Colors.* mapping
  static const Color success = successGreen;
  static const Color error = errorRed;
  static const Color warning = warningOrange;
  static const Color primaryBlue = tossBlue;  // Alias for Colors.blue mapping

  // Additional semantic colors for fortune app
  static const Color pinkPrimary = Color(0xFFEC4899);
  static const Color brownPrimary = Color(0xFF8B5A3C);
  
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

  /// ⚠️ DEPRECATED: 타이포그래피는 이제 TypographyTheme을 사용하세요!
  /// import 'package:fortune/core/theme/typography_theme.dart';
  ///
  /// 사용 예시:
  /// Text('제목', style: context.typography.headingLarge)
  /// Text('본문', style: context.typography.bodyMedium)
  ///
  /// 이 상수들은 하위 호환성을 위해 유지되지만, 신규 코드에서는 사용하지 마세요.
  ///
  /// 마이그레이션 가이드:
  /// - display1 → displayLarge
  /// - display2 → displayMedium
  /// - heading1 → displaySmall
  /// - heading2 → headingLarge
  /// - heading3 → headingMedium
  /// - heading4 → headingSmall
  /// - body1 → bodyLarge
  /// - body2 → bodyMedium
  /// - body3 → bodySmall
  /// - caption/caption1 → labelMedium
  /// - small → labelSmall
  /// - button → labelLarge
  /// - amountLarge → numberLarge
  /// - amountMedium → numberMedium

  /// ⚠️ 주의: 이 상수들은 이제 사용자 폰트 설정을 반영하지 않습니다!
  /// 사용자 설정을 반영하려면 반드시 TypographyTheme을 사용하세요.
  ///
  /// 하위 호환성을 위해 유지되는 고정 크기 상수입니다.

  /// Font Families (deprecated - 고정값)
  static const String fontFamilyKorean = 'Pretendard';
  static const String fontFamilyEnglish = 'SF Pro Display';
  static const String fontFamilyNumber = 'TossFace';

  /// Display Styles (deprecated - 고정 크기, 사용자 설정 반영 안 됨)
  static const TextStyle display1 = TextStyle(
    fontSize: FontSizeSystem.displayLarge,
    height: 1.17,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
    fontFamily: fontFamilyKorean,
  );

  static const TextStyle display2 = TextStyle(
    fontSize: FontSizeSystem.displayMedium,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
    fontFamily: fontFamilyKorean,
  );

  /// Heading Styles (deprecated - 고정 크기, 사용자 설정 반영 안 됨)
  static const TextStyle heading1 = TextStyle(
    fontSize: FontSizeSystem.displaySmall,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    fontFamily: fontFamilyKorean,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: FontSizeSystem.heading1,
    height: 1.29,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    fontFamily: fontFamilyKorean,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: FontSizeSystem.heading2,
    height: 1.33,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFamily: fontFamilyKorean,
  );

  static const TextStyle heading4 = TextStyle(
    fontSize: FontSizeSystem.heading3,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFamily: fontFamilyKorean,
  );

  /// Body Styles (deprecated - 고정 크기, 사용자 설정 반영 안 됨)
  static const TextStyle body1 = TextStyle(
    fontSize: FontSizeSystem.bodyLarge,
    height: 1.53,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: fontFamilyKorean,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: FontSizeSystem.bodyMedium,
    height: 1.6,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: fontFamilyKorean,
  );

  static const TextStyle body3 = TextStyle(
    fontSize: FontSizeSystem.bodySmall,
    height: 1.57,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: fontFamilyKorean,
  );

  /// Caption & Small (deprecated - 고정 크기, 사용자 설정 반영 안 됨)
  static const TextStyle caption = TextStyle(
    fontSize: FontSizeSystem.labelLarge,
    height: 1.54,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: fontFamilyKorean,
  );

  static const TextStyle caption1 = TextStyle(
    fontSize: FontSizeSystem.labelLarge,
    height: 1.54,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: fontFamilyKorean,
  );

  static const TextStyle small = TextStyle(
    fontSize: FontSizeSystem.labelMedium,
    height: 1.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: fontFamilyKorean,
  );

  /// Button Style (deprecated - 고정 크기, 사용자 설정 반영 안 됨)
  static const TextStyle button = TextStyle(
    fontSize: FontSizeSystem.buttonMedium,
    height: 1.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFamily: fontFamilyKorean,
  );

  /// Amount Style (deprecated - 고정 크기, 사용자 설정 반영 안 됨)
  static const TextStyle amountLarge = TextStyle(
    fontSize: FontSizeSystem.numberLarge,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
    fontFamily: fontFamilyNumber,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle amountMedium = TextStyle(
    fontSize: FontSizeSystem.numberMedium,
    height: 1.33,
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
      color: gray900.withValues(alpha: 0.04),
      offset: const Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> shadowS = [
    BoxShadow(
      color: gray900.withValues(alpha: 0.04),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> shadowM = [
    BoxShadow(
      color: gray900.withValues(alpha: 0.08),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> shadowL = [
    BoxShadow(
      color: gray900.withValues(alpha: 0.12),
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> shadowXL = [
    BoxShadow(
      color: gray900.withValues(alpha: 0.16),
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
  
  /// Button Heights (접근성 개선)
  static const double buttonHeightLarge = 56.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightSmall = 48.0;  // 40 → 48 (최소 터치 영역 보장)

  /// Touch Target Guidelines (터치 영역 가이드라인)
  /// 접근성 및 사용성을 위한 최소 터치 영역 기준
  static const double minTouchTarget = 48.0;        // 최소 터치 영역 (WCAG 2.1 AA)
  static const double iconButtonSizeSmall = 48.0;   // 작은 아이콘 버튼
  static const double iconButtonSizeMedium = 52.0;  // 중간 아이콘 버튼
  static const double iconButtonSizeLarge = 56.0;   // 큰 아이콘 버튼

  /// Icon Sizes (아이콘 크기)
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 28.0;
  
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
      shadowColor: white.withValues(alpha: 0.0),
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
      shadowColor: white.withValues(alpha: 0.0),
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
      backgroundColor: white.withValues(alpha: 0.0),
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
  
  
  /// Text contrast ratios
  static const double contrastRatioAA = 4.5;
  static const double contrastRatioAAA = 7.0;
  
  /// Focus indicator
  static BoxDecoration focusDecoration = BoxDecoration(
    border: Border.all(color: tossBlue, width: 2),
    borderRadius: BorderRadius.circular(radiusS),
  );
  
  // ==========================================
  // 11. THEME DATA (테마 데이터)
  // ==========================================
  
  /// Light Theme
  /// [fontScale] 사용자 폰트 크기 배율 (기본값: 1.0)
  static ThemeData lightTheme({double fontScale = 1.0}) {
    final baseTheme = ThemeData.light();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: tossBlue,
      scaffoldBackgroundColor: backgroundPrimary,

      // 🎯 앱 전체 폰트 크기 조절
      textTheme: baseTheme.textTheme.apply(
        fontSizeFactor: fontScale,
        fontFamily: fontFamilyKorean,
      ),

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: tossBlue,
        secondary: tossBlue,
        surface: surfacePrimary,
        error: errorRed,
        onPrimary: white,
        onSecondary: white,
        onSurface: gray900,
        onError: white,
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundPrimary,
        foregroundColor: gray900,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: heading4.copyWith(color: gray900),
        iconTheme: const IconThemeData(color: gray900),
      ),

      // Elevated Button Theme
      // REMOVED: elevatedButtonTheme to allow per-button customization
      // Each button should define its own style using ElevatedButton.styleFrom()

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: ghostButtonStyle(),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: gray50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingM,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
          borderSide: const BorderSide(color: gray200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
          borderSide: const BorderSide(color: tossBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        hintStyle: body2.copyWith(color: gray400),
        errorStyle: caption1.copyWith(color: errorRed),
      ),
      
      // Card Theme
      cardTheme: const CardThemeData(
        color: white,
        elevation: 0,
        margin: EdgeInsets.all(0),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: gray200,
        thickness: 1,
        space: 0,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: tossBlue,
        unselectedItemColor: gray400,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
        titleTextStyle: heading4.copyWith(color: gray900),
        contentTextStyle: body2.copyWith(color: gray700),
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXL),
          ),
        ),
      ),
    );
  }
  
  /// Dark Theme
  /// [fontScale] 사용자 폰트 크기 배율 (기본값: 1.0)
  static ThemeData darkTheme({double fontScale = 1.0}) {
    final baseTheme = ThemeData.dark();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: tossBlueDark,
      scaffoldBackgroundColor: grayDark50,

      // 🎯 앱 전체 폰트 크기 조절
      textTheme: baseTheme.textTheme.apply(
        fontSizeFactor: fontScale,
        fontFamily: fontFamilyKorean,
      ),

      // Color Scheme (개선된 대비)
      colorScheme: const ColorScheme.dark(
        primary: tossBlueDark,
        secondary: tossBlueDark,
        surface: grayDark100,
        error: errorRedDark,
        onPrimary: white,
        onSecondary: white,
        onSurface: grayDark900,
        onError: white,
        outline: grayDark400,  // 개선된 테두리 색상
        shadow: grayDark300,   // 그림자 색상
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: grayDark50,
        foregroundColor: grayDark900,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: heading4.copyWith(color: grayDark900),
        iconTheme: const IconThemeData(color: grayDark900),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tossBlueDark,
          foregroundColor: white,
          disabledBackgroundColor: grayDark300,
          disabledForegroundColor: grayDark400,
          elevation: 0,
          shadowColor: white.withValues(alpha: 0.0),
          fixedSize: const Size.fromHeight(buttonHeightLarge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tossBlueDark,
          backgroundColor: white.withValues(alpha: 0.0),
          disabledForegroundColor: grayDark500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grayDark100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingM,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
          borderSide: const BorderSide(color: grayDark300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
          borderSide: const BorderSide(color: tossBlueDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
          borderSide: const BorderSide(color: errorRedDark, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
          borderSide: const BorderSide(color: errorRedDark, width: 2),
        ),
        hintStyle: body2.copyWith(color: grayDark500),
        errorStyle: caption1.copyWith(color: errorRedDark),
      ),
      
      // Card Theme
      cardTheme: const CardThemeData(
        color: grayDark100,
        elevation: 0,
        margin: EdgeInsets.all(0),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: grayDark300,
        thickness: 1,
        space: 0,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: grayDark100,
        selectedItemColor: tossBlueDark,
        unselectedItemColor: grayDark400,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: grayDark100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
        titleTextStyle: heading4.copyWith(color: grayDark900),
        contentTextStyle: body2.copyWith(color: grayDark700),
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: grayDark100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXL),
          ),
        ),
      ),
    );
  }
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