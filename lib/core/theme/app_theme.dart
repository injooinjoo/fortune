import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme_extensions.dart';
import '../design_system/tokens/ds_obangseok_colors.dart';
import 'package:fortune/core/design_system/design_system.dart';

class AppTheme {
  // Use DSColors tokens
  static const Color primaryColor = DSColors.accentDark;
  static const Color secondaryColor = Color(0xFF3B352E);
  static const Color tertiaryColor = DSColors.textTertiaryDark;
  static const Color successColor = DSColors.success;
  static const Color warningColor = DSColors.warning;
  static const Color errorColor = DSColors.error;
  static const Color backgroundColor = DSColors.backgroundDark;
  static const Color surfaceColor = DSColors.surfaceDark;
  static const Color borderColor = DSColors.borderDark;
  static const Color textColor = DSColors.textPrimaryDark;
  static const Color textSecondaryColor = DSColors.textSecondaryDark;
  static const Color dividerColor = DSColors.borderDark;

  // Add missing color getters for backward compatibility
  static Color get textPrimary => DSColors.textPrimaryDark;
  static Color get textSecondary => DSColors.textSecondaryDark;
  static Color get success => DSColors.success;
  static Color get warning => DSColors.warning;
  static Color get error => DSColors.error;

  // Added for theme mode checking
  static bool isDarkMode = false;

  // Radius tokens (mapped to DSRadius)
  static const double radiusSmall = DSRadius.smd;
  static const double radiusMedium = DSRadius.md;
  static const double radiusLarge = DSRadius.lg;
  static const double radiusXLarge = 20.0;
  static const double radiusXXLarge = 42.0;

  // Spacing tokens (mapped to DSSpacing)
  static const double spacingXSmall = DSSpacing.xs;
  static const double spacingSmall = DSSpacing.sm;
  static const double spacingMedium = DSSpacing.md;
  static const double spacingLarge = DSSpacing.lg;
  static const double spacingXLarge = DSSpacing.xl;
  static const double spacingXXLarge = DSSpacing.xxl;

  static ThemeData lightTheme() {
    return ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: primaryColor,
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: tertiaryColor,
          error: errorColor,
          surface: Color(0xFFF3F4F6),
          // background is deprecated, use surface instead
        ),
        // 한지 배경색 (미색) - 오방색 디자인 철학 적용
        scaffoldBackgroundColor: ObangseokColors.misaek,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
          titleTextStyle: TypographyUnified.heading4.copyWith(
            color: const Color(0xFF1F2937),
          ),
        ),
        fontFamily: TypographyUnified.fontFamilyKorean,
        textTheme: TextTheme(
          displayLarge: TypographyUnified.displayLarge,
          displayMedium: TypographyUnified.displayMedium,
          displaySmall: TypographyUnified.displaySmall,
          headlineLarge: TypographyUnified.displaySmall,
          headlineMedium: TypographyUnified.heading1,
          headlineSmall: TypographyUnified.heading2,
          titleLarge: TypographyUnified.heading2,
          titleMedium: TypographyUnified.heading3,
          titleSmall: TypographyUnified.bodyLarge,
          bodyLarge: TypographyUnified.bodyLarge,
          bodyMedium: TypographyUnified.bodyMedium,
          bodySmall: TypographyUnified.bodySmall,
          labelLarge: TypographyUnified.bodyMedium,
          labelMedium: TypographyUnified.labelLarge,
          labelSmall: TypographyUnified.labelMedium,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primaryColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: TypographyUnified.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: DSColors.backgroundDark,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: DSColors.borderDark, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: DSColors.borderDark, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: DSColors.accentDark, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: DSColors.error, width: 1),
          ),
          labelStyle: TypographyUnified.bodySmall.copyWith(color: DSColors.textSecondaryDark),
          hintStyle: TypographyUnified.bodySmall.copyWith(color: DSColors.textDisabledDark),
        ),
        extensions: <ThemeExtension<dynamic>>[
          FortuneThemeExtension.light,
        ],
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _FastPageTransitionBuilder(),
            TargetPlatform.iOS: _FastPageTransitionBuilder(),
          },
        ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: DSColors.accentDark,
        colorScheme: const ColorScheme.dark(
          primary: DSColors.accentDark,
          secondary: secondaryColor,
          tertiary: DSColors.textSecondaryDark,
          error: DSColors.error,
          surface: DSColors.textPrimaryDark,
          // background is deprecated, use surface instead
        ),
        // 다크모드 한지 배경색 (흑색) - 오방색 디자인 철학 적용
        scaffoldBackgroundColor: ObangseokColors.heukLight,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: const IconThemeData(color: DSColors.textPrimary),
          titleTextStyle: TypographyUnified.heading4.copyWith(
            color: DSColors.textPrimary,
          ),
        ),
        fontFamily: TypographyUnified.fontFamilyKorean,
        textTheme: TypographyUnified.materialTextTheme(brightness: Brightness.dark),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primaryColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: TypographyUnified.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: DSColors.textPrimaryDark,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFF3B352E), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFF3B352E), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: DSColors.accentDark, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: DSColors.error, width: 1),
          ),
          labelStyle: TypographyUnified.bodySmall.copyWith(color: DSColors.textDisabledDark),
          hintStyle: TypographyUnified.bodySmall.copyWith(color: DSColors.textTertiaryDark),
        ),
        extensions: <ThemeExtension<dynamic>>[
          FortuneThemeExtension.dark,
        ],
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _FastPageTransitionBuilder(),
            TargetPlatform.iOS: _FastPageTransitionBuilder(),
          },
        ),
    );
  }
}

/// Custom page transition builder with fast animations (80ms)
class _FastPageTransitionBuilder extends PageTransitionsBuilder {
  const _FastPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeOutQuad;
    
    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );
    
    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 80);
}
