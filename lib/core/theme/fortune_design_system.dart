import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/tokens/ds_colors.dart';
import '../design_system/tokens/ds_spacing.dart';
import '../design_system/tokens/ds_radius.dart';
import '../design_system/tokens/ds_animation.dart';
import 'font_size_system.dart';
import 'typography_unified.dart';

/// Fortune 디자인 시스템 - Neon Dark Theme
/// Fortune Design System - Neon Dark Theme
class FortuneDesignSystem {
  // ==========================================
  // 1. COLOR SYSTEM - NEON DARK THEME
  // ==========================================

  /// @deprecated Use DSColors.accent instead
  static const Color neonGreen = DSColors.accent;
  /// @deprecated Use DSColors.accentHover instead
  static const Color neonGreenDim = DSColors.accentHover;
  static const Color neonGreenBright = Color(0xFF4DFF28);

  /// Legacy aliases for compatibility
  static const Color indigo = DSColors.accent;
  /// @deprecated Use DSColors.error instead
  static const Color vermilion = DSColors.error;
  /// @deprecated Use DSColors.warning instead
  static const Color ocher = DSColors.warning;
  /// @deprecated Use DSColors.surface instead
  static const Color charcoal = DSColors.surface;
  static const Color hanjiBeige = Color(0xFFFFFFFF);

  static const Color tossBlue = DSColors.accent;
  static const Color tossBlueDark = DSColors.accent;
  static const Color tossBlueLight = DSColors.accentHover;

  /// Grayscale - Dark Theme Optimized
  /// @deprecated Use DSColors.textPrimary or context.colors.textPrimary
  static const Color gray900 = DSColors.textPrimary;
  static const Color gray800 = Color(0xFFE0E0E0);
  /// @deprecated Use DSColors.textSecondary
  static const Color gray700 = DSColors.textSecondary;
  static const Color gray600 = Color(0xFF909090);
  /// @deprecated Use DSColors.textTertiary
  static const Color gray500 = DSColors.textTertiary;
  static const Color gray400 = Color(0xFF606060);
  static const Color gray300 = Color(0xFF404040);
  /// @deprecated Use DSColors.border
  static const Color gray200 = DSColors.border;
  /// @deprecated Use DSColors.surfaceSecondary
  static const Color gray100 = DSColors.surfaceSecondary;
  /// @deprecated Use DSColors.surface
  static const Color gray50 = DSColors.surface;
  static const Color white = Color(0xFFFFFFFF);
  /// @deprecated Use DSColors.background
  static const Color black = DSColors.background;
  static const Color transparent = Color(0x00000000);

  /// Dark Mode Grayscale (Pure Black Theme)
  /// @deprecated Use DSColors tokens instead
  static const Color grayDark50 = DSColors.background;
  static const Color grayDark100 = DSColors.surface;
  static const Color grayDark200 = DSColors.surfaceSecondary;
  static const Color grayDark300 = DSColors.border;
  static const Color grayDark400 = DSColors.textSecondary;
  static const Color grayDark500 = DSColors.textTertiary;
  static const Color grayDark600 = Color(0xFFD0D0D0);
  static const Color grayDark700 = Color(0xFFE0E0E0);
  static const Color grayDark800 = Color(0xFFF0F0F0);
  static const Color grayDark900 = DSColors.textPrimary;

  /// Semantic Background Colors
  /// @deprecated Use DSColors/context.colors instead
  static const Color backgroundDark = DSColors.background;
  static const Color backgroundLight = DSColors.backgroundDark;
  static const Color cardBackgroundDark = DSColors.surface;
  static const Color cardBackgroundLight = DSColors.surfaceDark;
  static const Color surfaceBackgroundDark = DSColors.surfaceSecondary;
  static const Color surfaceBackgroundLight = DSColors.backgroundTertiaryDark;

  /// Semantic Text Colors
  /// @deprecated Use DSColors/context.colors instead
  static const Color textPrimaryDark = DSColors.textPrimary;
  static const Color textPrimaryLight = DSColors.textPrimaryDark;
  static const Color textSecondaryDark = DSColors.textSecondary;
  static const Color textSecondaryLight = DSColors.textSecondaryDark;
  static const Color textTertiaryDark = DSColors.textTertiary;
  static const Color textTertiaryLight = DSColors.textTertiaryDark;

  /// Semantic Divider & Border Colors
  /// @deprecated Use DSColors/context.colors instead
  static const Color dividerDark = DSColors.divider;
  static const Color dividerLight = DSColors.dividerDark;
  static const Color borderDark = DSColors.border;
  static const Color borderLight = DSColors.borderDark;

  /// Semantic Colors - Neon Variants
  /// @deprecated Use DSColors instead
  static const Color successGreen = DSColors.success;
  static const Color warningOrange = DSColors.warning;
  static const Color warningYellow = DSColors.warning;
  static const Color primaryYellow = DSColors.warning;
  static const Color primaryGreen = DSColors.accent;
  static const Color primaryRed = DSColors.error;
  static const Color errorRed = DSColors.error;
  static const Color infoBlue = DSColors.info;
  static const Color purple = DSColors.accentTertiary;
  static const Color purple50 = Color(0xFF1A001A);
  static const Color teal = DSColors.accentSecondary;
  static const Color orange = DSColors.warning;
  static const Color pink = DSColors.accentTertiary;
  static const Color bluePrimary = DSColors.accent;

  // Common aliases
  static const Color success = DSColors.success;
  static const Color error = DSColors.error;
  static const Color warning = DSColors.warning;
  static const Color primaryBlue = DSColors.accent;

  // Additional semantic colors
  static const Color pinkPrimary = DSColors.accentTertiary;
  static const Color brownPrimary = Color(0xFF8B5A3C);

  /// Dark Mode Semantic Colors
  static const Color successGreenDark = DSColors.success;
  static const Color warningOrangeDark = DSColors.warning;
  static const Color errorRedDark = DSColors.error;
  static const Color infoBlueDark = DSColors.info;

  /// Background Colors (Light mode)
  /// @deprecated Use DSColors/context.colors instead
  static const Color backgroundPrimary = DSColors.backgroundDark;
  static const Color backgroundSecondary = DSColors.backgroundSecondaryDark;
  static const Color backgroundTertiary = DSColors.backgroundTertiaryDark;
  static const Color backgroundElevated = DSColors.backgroundDark;

  /// Surface Colors (Light mode)
  /// @deprecated Use DSColors/context.colors instead
  static const Color surfacePrimary = DSColors.surfaceDark;
  static const Color surfaceSecondary = DSColors.surfaceSecondaryDark;
  static const Color surfaceOverlay = DSColors.overlay;

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

  /// Font Families - GmarketSans
  static const String fontFamilyKorean = 'GmarketSans';
  static const String fontFamilyEnglish = 'GmarketSans';
  static const String fontFamilyNumber = 'GmarketSans';

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

  /// @deprecated Use DSSpacing tokens instead
  static const double spacingBase = DSSpacing.base;

  static const double spacingXXS = DSSpacing.xxs;
  static const double spacingXS = DSSpacing.xs;
  static const double spacingS = DSSpacing.sm;
  static const double spacingM = DSSpacing.md;
  static const double spacingL = DSSpacing.lg;
  static const double spacingXL = DSSpacing.xl;
  static const double spacingXXL = DSSpacing.xxl;
  static const double spacing3XL = DSSpacing.xxxl;
  static const double spacing4XL = DSSpacing.xxxxl;

  /// Page Margins
  /// @deprecated Use DSSpacing.pageHorizontal / DSSpacing.pageVertical
  static const double marginHorizontal = DSSpacing.pageHorizontal;
  static const double marginVertical = DSSpacing.pageVertical;

  // ==========================================
  // 4. RADIUS SYSTEM (모서리 반경)
  // ==========================================

  /// @deprecated Use DSRadius tokens instead
  static const double radiusXS = DSRadius.xs;
  static const double radiusS = DSRadius.smd;
  static const double radiusM = DSRadius.md;
  static const double radiusL = DSRadius.lg;
  static const double radiusXL = 20.0; // Between DSRadius.lg(16) and DSRadius.xl(24)
  static const double radiusXXL = DSRadius.xl;
  static const double radiusFull = DSRadius.full;

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

  /// @deprecated Use DSAnimation tokens instead
  static const Duration durationMicro = DSAnimation.micro;
  static const Duration durationShort = DSAnimation.quick;
  static const Duration durationMedium = DSAnimation.normal;
  static const Duration durationLong = DSAnimation.slow;
  static const Duration durationXLong = DSAnimation.long;

  /// @deprecated Use DSAnimation curves instead
  static const Curve curveDefault = DSAnimation.standard;
  static const Curve curveEmphasized = DSAnimation.emphasized;
  static const Curve curveDecelerate = DSAnimation.decelerate;
  static const Curve curveAccelerate = DSAnimation.accelerate;

  // ==========================================
  // 7. COMPONENT STYLES (컴포넌트 스타일)
  // ==========================================

  /// Button Heights (접근성 개선)
  static const double buttonHeightLarge = 56.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightSmall = 48.0; // 40 → 48 (최소 터치 영역 보장)

  /// Touch Target Guidelines (터치 영역 가이드라인)
  /// 접근성 및 사용성을 위한 최소 터치 영역 기준
  static const double minTouchTarget = 48.0; // 최소 터치 영역 (WCAG 2.1 AA)
  static const double iconButtonSizeSmall = 48.0; // 작은 아이콘 버튼
  static const double iconButtonSizeMedium = 52.0; // 중간 아이콘 버튼
  static const double iconButtonSizeLarge = 56.0; // 큰 아이콘 버튼

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
      fixedSize: fixedSize ?? const Size.fromHeight(buttonHeightLarge),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      textStyle: TypographyUnified.buttonMedium,
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
      fixedSize: fixedSize ?? const Size.fromHeight(buttonHeightLarge),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      textStyle: TypographyUnified.buttonMedium,
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
      textStyle: TypographyUnified.buttonMedium,
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
      hintStyle: TypographyUnified.bodyMedium.copyWith(color: gray400),
      errorText: errorText,
      errorStyle: TypographyUnified.labelSmall.copyWith(color: errorRed),
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

  static TextTheme _buildTextTheme({
    required Brightness brightness,
    required double fontScale,
  }) {
    final baseTheme = TypographyUnified.materialTextTheme(
      brightness: brightness,
    );
    final scaleFactor = fontScale / FontSizeSystem.scaleFactor;
    if (scaleFactor == 1.0) {
      return baseTheme;
    }
    return baseTheme.apply(fontSizeFactor: scaleFactor);
  }

  /// Light Theme - Neon Light (White + Neon Green)
  /// [fontScale] 사용자 폰트 크기 배율 (기본값: 1.0)
  static ThemeData lightTheme({double fontScale = 1.0}) {
    final textTheme = _buildTextTheme(
      brightness: Brightness.light,
      fontScale: fontScale,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: neonGreen,
      scaffoldBackgroundColor: white,
      fontFamily: fontFamilyKorean,

      textTheme: textTheme,

      // Color Scheme - Neon Light
      colorScheme: const ColorScheme.light(
        primary: neonGreen,
        secondary: neonGreen,
        surface: surfacePrimary,
        error: errorRed,
        onPrimary: black, // Black text on neon green buttons
        onSecondary: black,
        onSurface: black,
        onError: white,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TypographyUnified.heading4.copyWith(color: black),
        iconTheme: const IconThemeData(color: black),
      ),

      // Elevated Button Theme - Neon Green with Black Text
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonGreen,
          foregroundColor: black,
          disabledBackgroundColor: borderLight,
          disabledForegroundColor: textSecondaryLight,
          elevation: 0,
          shadowColor: transparent,
          fixedSize: const Size.fromHeight(buttonHeightLarge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: TypographyUnified.buttonMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: neonGreen,
          backgroundColor: transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: TypographyUnified.buttonMedium,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfacePrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingM,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
          borderSide: const BorderSide(color: neonGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        hintStyle: TypographyUnified.bodyMedium.copyWith(color: textSecondaryLight),
        errorStyle: TypographyUnified.labelSmall.copyWith(color: errorRed),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: surfacePrimary,
        elevation: 0,
        margin: EdgeInsets.all(0),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerLight,
        thickness: 1,
        space: 0,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: neonGreen,
        unselectedItemColor: textSecondaryLight,
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
        titleTextStyle: TypographyUnified.heading4.copyWith(color: black),
        contentTextStyle: TypographyUnified.bodyMedium.copyWith(color: textSecondaryLight),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXL),
          ),
        ),
      ),
    );
  }

  /// Dark Theme - Neon Dark (Pure Black + Neon Green)
  /// [fontScale] 사용자 폰트 크기 배율 (기본값: 1.0)
  static ThemeData darkTheme({double fontScale = 1.0}) {
    final textTheme = _buildTextTheme(
      brightness: Brightness.dark,
      fontScale: fontScale,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: neonGreen,
      scaffoldBackgroundColor: black, // Pure black background
      fontFamily: fontFamilyKorean,

      textTheme: textTheme,

      // Color Scheme - Neon Dark
      colorScheme: const ColorScheme.dark(
        primary: neonGreen,
        secondary: neonGreen,
        surface: grayDark100, // #1C1C1C
        error: errorRedDark,
        onPrimary: black, // Black text on neon green buttons
        onSecondary: black,
        onSurface: white, // White text on dark surface
        onError: white,
        outline: grayDark300, // Border color
        shadow: grayDark200, // Shadow color
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: black,
        foregroundColor: white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TypographyUnified.heading4.copyWith(color: white),
        iconTheme: const IconThemeData(color: white),
      ),

      // Elevated Button Theme - Neon Green with Black Text
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonGreen,
          foregroundColor: black,
          disabledBackgroundColor: grayDark300,
          disabledForegroundColor: grayDark500,
          elevation: 0,
          shadowColor: transparent,
          fixedSize: const Size.fromHeight(buttonHeightLarge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: TypographyUnified.buttonMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: neonGreen,
          backgroundColor: transparent,
          disabledForegroundColor: grayDark500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: TypographyUnified.buttonMedium,
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
          borderSide: const BorderSide(color: neonGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
          borderSide: const BorderSide(color: errorRedDark, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusS),
          borderSide: const BorderSide(color: errorRedDark, width: 2),
        ),
        hintStyle: TypographyUnified.bodyMedium.copyWith(color: grayDark500),
        errorStyle: TypographyUnified.labelSmall.copyWith(color: errorRedDark),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: grayDark100, // #1C1C1C
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
        backgroundColor: black,
        selectedItemColor: neonGreen,
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
        titleTextStyle: TypographyUnified.heading4.copyWith(color: white),
        contentTextStyle: TypographyUnified.bodyMedium.copyWith(color: grayDark400),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
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
extension FortuneDesignSystemContext on BuildContext {
  FortuneDesignSystem get fortune => FortuneDesignSystem();
}

/// @deprecated Use FortuneDesignSystemContext instead
/// Legacy alias for backwards compatibility
extension TossDesignSystemContext on BuildContext {
  FortuneDesignSystem get toss => FortuneDesignSystem();
}

/// Fortune 스타일 금액 포맷터
class FortuneAmountFormatter {
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

/// @deprecated Use FortuneAmountFormatter instead
typedef TossAmountFormatter = FortuneAmountFormatter;

/// Fortune 스타일 날짜 포맷터
class FortuneDateFormatter {
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

/// @deprecated Use FortuneDateFormatter instead
typedef TossDateFormatter = FortuneDateFormatter;

/// @deprecated Use FortuneDesignSystem instead
typedef TossDesignSystem = FortuneDesignSystem;
