import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortune/core/theme/font_size_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';
import '../tokens/ds_colors.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_typography.dart';

/// ChatGPT-inspired theme generator
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: DSTheme.light(),
///   darkTheme: DSTheme.dark(),
///   themeMode: ThemeMode.system,
/// )
/// ```
class DSTheme {
  DSTheme._();

  /// Generate light theme
  static ThemeData light({double fontScale = 1.0}) {
    return _buildTheme(
      brightness: Brightness.light,
      fontScale: fontScale,
    );
  }

  /// Generate dark theme
  static ThemeData dark({double fontScale = 1.0}) {
    return _buildTheme(
      brightness: Brightness.dark,
      fontScale: fontScale,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    double fontScale = 1.0,
  }) {
    final isDark = brightness == Brightness.dark;
    final colors = DSColorScheme(brightness);
    final baseTextTheme = TypographyUnified.materialTextTheme(
      brightness: brightness,
    );
    final scaleFactor = fontScale / FontSizeSystem.scaleFactor;
    final textTheme = scaleFactor == 1.0
        ? baseTextTheme
        : baseTextTheme.apply(fontSizeFactor: scaleFactor);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: colors.accent,
      scaffoldBackgroundColor: colors.background,
      fontFamily: DSTypography.fontFamily,

      // Font scale
      textTheme: textTheme,

      // Color Scheme
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.accent,
        onPrimary: colors.ctaForeground,
        secondary: colors.accent,
        onSecondary: colors.ctaForeground,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        error: colors.error,
        onError: colors.ctaForeground,
        outline: colors.border,
        shadow: isDark ? Colors.black : DSColors.textPrimary.withValues(alpha: 0.1),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: DSTypography.headingSmall.copyWith(
          color: colors.textPrimary,
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      // Elevated Button Theme (for non-DS buttons)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.ctaBackground,
          foregroundColor: colors.ctaForeground,
          disabledBackgroundColor: colors.textDisabled,
          disabledForegroundColor: colors.textTertiary,
          elevation: 0,
          shadowColor: Colors.transparent,
          fixedSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadius.button),
          ),
          textStyle: DSTypography.buttonMedium,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accent,
          disabledForegroundColor: colors.textDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadius.button),
          ),
          textStyle: DSTypography.buttonMedium,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          disabledForegroundColor: colors.textDisabled,
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadius.button),
          ),
          textStyle: DSTypography.buttonMedium,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.backgroundTertiary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.inputHorizontal,
          vertical: DSSpacing.inputVertical,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadius.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadius.input),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadius.input),
          borderSide: BorderSide(color: colors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadius.input),
          borderSide: BorderSide(color: colors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadius.input),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        hintStyle: DSTypography.input.copyWith(color: colors.textTertiary),
        errorStyle: DSTypography.labelSmall.copyWith(color: colors.error),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.card),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 0.5,
        space: 0,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.accent,
        unselectedItemColor: colors.textTertiary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.modal),
        ),
        titleTextStyle: DSTypography.headingSmall.copyWith(
          color: colors.textPrimary,
        ),
        contentTextStyle: DSTypography.bodyMedium.copyWith(
          color: colors.textSecondary,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: DSRadius.bottomSheetBorder,
        ),
        modalBackgroundColor: colors.surface,
        modalElevation: 0,
      ),

      // Switch Theme (iOS-style green)
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(DSColors.toggleThumb),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.toggleActive;
          }
          return colors.toggleInactive;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.toggleActive;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(DSColors.toggleThumb),
        side: BorderSide(color: colors.border, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.xs),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.toggleActive;
          }
          return colors.textTertiary;
        }),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accent,
        linearTrackColor: colors.backgroundTertiary,
        circularTrackColor: colors.backgroundTertiary,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? colors.surface : colors.ctaBackground,
        contentTextStyle: DSTypography.bodyMedium.copyWith(
          color: isDark ? colors.textPrimary : colors.ctaForeground,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? colors.surface : colors.ctaBackground,
          borderRadius: BorderRadius.circular(DSRadius.sm),
        ),
        textStyle: DSTypography.labelSmall.copyWith(
          color: isDark ? colors.textPrimary : colors.ctaForeground,
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: colors.textPrimary,
        size: 24,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.listItemHorizontal,
          vertical: DSSpacing.listItemVertical / 2,
        ),
        titleTextStyle: DSTypography.bodyMedium.copyWith(
          color: colors.textPrimary,
        ),
        subtitleTextStyle: DSTypography.labelSmall.copyWith(
          color: colors.textSecondary,
        ),
        iconColor: colors.textSecondary,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.ctaBackground,
        foregroundColor: colors.ctaForeground,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.lg),
        ),
      ),
    );
  }
}
