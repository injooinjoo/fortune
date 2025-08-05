import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme_extensions.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static const Color primaryColor = AppColors.primary;
  static const Color secondaryColor = AppColors.secondary;
  static const Color tertiaryColor =
      AppColors.mysticalPurple; // Now gray instead of purple
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = AppColors.secondaryLight;
  static const Color errorColor = Color(0xFFEF4444);
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color textColor = Color(0xFF1F2937);
  static const Color textSecondaryColor = Color(0xFF6B7280);
  static const Color dividerColor = borderColor; // Added for compatibility

  // Added for theme mode checking
  static bool isDarkMode = false;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;
  static const double radiusXXLarge = 42.0;

  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

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
        scaffoldBackgroundColor: AppColors.cardBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          iconTheme: IconThemeData(color: Color(0xFF1F2937)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.w600)),
        fontFamily: AppTypography.fontFamily,
        textTheme: AppTypography.getTextTheme(color: AppColors.textPrimary),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primaryColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  8), // Instagram uses less rounded corners
            ),
            textStyle: AppTypography.button)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.background,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6), // Instagram style,
            borderSide: const BorderSide(color: AppColors.divider, width: 1)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.divider, width: 1)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: AppColors.textPrimary, width: 1)),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.error, width: 1)),
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14),
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14)),
        extensions: <ThemeExtension<dynamic>>[
          FortuneThemeExtension.light]);
  }

  static ThemeData darkTheme() {
    return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: AppColors.primaryDarkMode,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryDarkMode,
          secondary: secondaryColor,
          tertiary: AppColors.mysticalPurpleDarkMode,
          error: AppColors.errorDark,
          surface: AppColors.surfaceDark,
          // background is deprecated, use surface instead
        ),
        scaffoldBackgroundColor: AppColors.cardBackgroundDark,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 18,
            fontWeight: FontWeight.w600)),
        fontFamily: AppTypography.fontFamily,
        textTheme: AppTypography.getTextTheme(color: AppColors.textPrimaryDark),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primaryColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  8), // Instagram uses less rounded corners
            ),
            textStyle: AppTypography.button)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceDark,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: AppColors.dividerDark, width: 1)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: AppColors.dividerDark, width: 1)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: AppColors.textPrimaryDark, width: 1)),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: AppColors.errorDark, width: 1)),
          labelStyle: TextStyle(
            color: AppColors.textSecondaryDark,
            fontSize: 14),
          hintStyle: TextStyle(
            color: AppColors.textSecondaryDark,
            fontSize: 14)),
        extensions: <ThemeExtension<dynamic>>[
          FortuneThemeExtension.dark]);
  }
}
