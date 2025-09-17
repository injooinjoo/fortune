import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme_extensions.dart';
import 'toss_design_system.dart';

class AppTheme {
  // Use TossDesignSystem colors
  static const Color primaryColor = TossDesignSystem.tossBlue;
  static const Color secondaryColor = TossDesignSystem.gray700;
  static const Color tertiaryColor = TossDesignSystem.gray500;
  static const Color successColor = TossDesignSystem.successGreen;
  static const Color warningColor = TossDesignSystem.warningOrange;
  static const Color errorColor = TossDesignSystem.errorRed;
  static const Color backgroundColor = TossDesignSystem.gray50;
  static const Color surfaceColor = TossDesignSystem.white;
  static const Color borderColor = TossDesignSystem.gray200;
  static const Color textColor = TossDesignSystem.gray900;
  static const Color textSecondaryColor = TossDesignSystem.gray600;
  static const Color dividerColor = TossDesignSystem.gray200;

  // Add missing color getters for backward compatibility
  static Color get textPrimary => TossDesignSystem.gray900;
  static Color get textSecondary => TossDesignSystem.gray600;
  static Color get success => TossDesignSystem.successGreen;
  static Color get warning => TossDesignSystem.warningOrange;
  static Color get error => TossDesignSystem.errorRed;

  // Added for theme mode checking
  static bool isDarkMode = false;

  // Use TossDesignSystem radius
  static const double radiusSmall = TossDesignSystem.radiusS;
  static const double radiusMedium = TossDesignSystem.radiusM;
  static const double radiusLarge = TossDesignSystem.radiusL;
  static const double radiusXLarge = TossDesignSystem.radiusXL;
  static const double radiusXXLarge = 42.0;

  // Use TossDesignSystem spacing
  static const double spacingXSmall = TossDesignSystem.spacingXS;
  static const double spacingSmall = TossDesignSystem.spacingS;
  static const double spacingMedium = TossDesignSystem.spacingM;
  static const double spacingLarge = TossDesignSystem.spacingL;
  static const double spacingXLarge = TossDesignSystem.spacingXL;
  static const double spacingXXLarge = TossDesignSystem.spacingXXL;

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
        scaffoldBackgroundColor: TossDesignSystem.gray50,
        appBarTheme: const AppBarTheme(
          backgroundColor: TossDesignSystem.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          iconTheme: IconThemeData(color: Color(0xFF1F2937)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        fontFamily: TossDesignSystem.fontFamilyKorean,
        textTheme: TextTheme(
          displayLarge: TossDesignSystem.display1,
          displayMedium: TossDesignSystem.display2,
          displaySmall: TossDesignSystem.heading1,
          headlineLarge: TossDesignSystem.heading1,
          headlineMedium: TossDesignSystem.heading2,
          headlineSmall: TossDesignSystem.heading3,
          titleLarge: TossDesignSystem.heading3,
          titleMedium: TossDesignSystem.heading4,
          titleSmall: TossDesignSystem.body1,
          bodyLarge: TossDesignSystem.body1,
          bodyMedium: TossDesignSystem.body2,
          bodySmall: TossDesignSystem.body3,
          labelLarge: TossDesignSystem.body2,
          labelMedium: TossDesignSystem.caption1,
          labelSmall: TossDesignSystem.small,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: TossDesignSystem.white,
            backgroundColor: primaryColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  8), // Instagram uses less rounded corners
            ),
            textStyle: TossDesignSystem.body1.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: TossDesignSystem.gray50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6), // Instagram style
            borderSide: const BorderSide(color: TossDesignSystem.gray200, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: TossDesignSystem.gray200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: TossDesignSystem.tossBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: TossDesignSystem.errorRed, width: 1),
          ),
          labelStyle: TossDesignSystem.body3.copyWith(color: TossDesignSystem.gray600),
          hintStyle: TossDesignSystem.body3.copyWith(color: TossDesignSystem.gray400),
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
        primaryColor: TossDesignSystem.tossBlue,
        colorScheme: ColorScheme.dark(
          primary: TossDesignSystem.tossBlue,
          secondary: secondaryColor,
          tertiary: TossDesignSystem.gray600,
          error: TossDesignSystem.errorRed,
          surface: TossDesignSystem.gray900,
          // background is deprecated, use surface instead
        ),
        scaffoldBackgroundColor: TossDesignSystem.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: TossDesignSystem.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: IconThemeData(color: TossDesignSystem.white),
          titleTextStyle: TextStyle(
            color: TossDesignSystem.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        fontFamily: TossDesignSystem.fontFamilyKorean,
        textTheme: TextTheme(
          displayLarge: TossDesignSystem.display1.copyWith(color: TossDesignSystem.white),
          displayMedium: TossDesignSystem.display2.copyWith(color: TossDesignSystem.white),
          displaySmall: TossDesignSystem.heading1.copyWith(color: TossDesignSystem.white),
          headlineLarge: TossDesignSystem.heading1.copyWith(color: TossDesignSystem.white),
          headlineMedium: TossDesignSystem.heading2.copyWith(color: TossDesignSystem.white),
          headlineSmall: TossDesignSystem.heading3.copyWith(color: TossDesignSystem.white),
          titleLarge: TossDesignSystem.heading3.copyWith(color: TossDesignSystem.white),
          titleMedium: TossDesignSystem.heading4.copyWith(color: TossDesignSystem.white),
          titleSmall: TossDesignSystem.body1.copyWith(color: TossDesignSystem.white),
          bodyLarge: TossDesignSystem.body1.copyWith(color: TossDesignSystem.gray100),
          bodyMedium: TossDesignSystem.body2.copyWith(color: TossDesignSystem.gray100),
          bodySmall: TossDesignSystem.body3.copyWith(color: TossDesignSystem.gray100),
          labelLarge: TossDesignSystem.body2.copyWith(color: TossDesignSystem.gray300),
          labelMedium: TossDesignSystem.caption1.copyWith(color: TossDesignSystem.gray300),
          labelSmall: TossDesignSystem.small.copyWith(color: TossDesignSystem.gray300),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: TossDesignSystem.white,
            backgroundColor: primaryColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  8), // Instagram uses less rounded corners
            ),
            textStyle: TossDesignSystem.body1.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: TossDesignSystem.gray900,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: TossDesignSystem.gray700, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: TossDesignSystem.gray700, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: TossDesignSystem.tossBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: TossDesignSystem.errorRed, width: 1),
          ),
          labelStyle: TossDesignSystem.body3.copyWith(color: TossDesignSystem.gray400),
          hintStyle: TossDesignSystem.body3.copyWith(color: TossDesignSystem.gray500),
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
    
    var tween = Tween(begin: begin, end: end).chain(
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
