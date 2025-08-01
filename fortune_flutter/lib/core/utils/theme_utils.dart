import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_extensions.dart';

/// Utility class for theme-related operations and dark mode support
class ThemeUtils {
  /// Check if the current theme is dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get the appropriate gradient for the current theme
  static LinearGradient getPrimaryGradient(BuildContext context) {
    if (isDarkMode(context)) {
      return LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          AppColors.primaryDarkMode.withValues(alpha: 0.8),
          AppColors.primaryLightDarkMode.withValues(alpha: 0.6),
          AppColors.primaryDarkDarkMode.withValues(alpha: 0.4),
        ]
      );
    }
    return AppColors.primaryGradient;
  }

  /// Get theme-aware shadow
  static List<BoxShadow> getCardShadow(BuildContext context) {
    if (isDarkMode(context)) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Get theme-aware border
  static Border getCardBorder(BuildContext context) {
    return Border.all(
      color: isDarkMode(context) 
        ? AppColors.dividerDark.withValues(alpha: 0.3)
        : AppColors.divider.withValues(alpha: 0.5),
      width: 1,
    );
  }

  /// Get mystical gradient based on theme
  static LinearGradient getMysticalGradient(BuildContext context) {
    if (isDarkMode(context)) {
      return LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          AppColors.mysticalPurpleDarkMode,
          AppColors.mysticalPurpleLightDarkMode,
          AppColors.mysticalPurpleDarkDarkMode,
        ]
      );
    }
    return AppColors.mysticalGradient;
  }

  /// Convert hardcoded colors to theme-aware colors
  static Color getThemedPurple(BuildContext context, {double opacity = 1.0}) {
    final baseColor = isDarkMode(context) 
      ? AppColors.mysticalPurpleDarkMode 
      : AppColors.mysticalPurple;
    return opacity < 1.0 ? baseColor.withValues(alpha: opacity) : baseColor;
  }

  /// Get status color based on theme
  static Color getStatusColor(BuildContext context, StatusType type) {
    switch (type) {
      case StatusType.success:
        return isDarkMode(context) ? AppColors.successDark : AppColors.success;
      case StatusType.error:
        return isDarkMode(context) ? AppColors.errorDark : AppColors.error;
      case StatusType.warning:
        return isDarkMode(context) ? AppColors.warningDark : AppColors.warning;
      case StatusType.info:
        return isDarkMode(context) ? AppColors.infoDark : AppColors.info;
    }
  }

  /// Get shimmer colors for loading states
  static ShimmerColors getShimmerColors(BuildContext context) {
    final fortuneTheme = Theme.of(context).extension<FortuneThemeExtension>();
    return ShimmerColors(
      baseColor: fortuneTheme?.shimmerBase ?? AppColors.divider,
      highlightColor: fortuneTheme?.shimmerHighlight ?? AppColors.divider.withValues(alpha: 0.3),
    );
  }

  /// Get glass morphism colors
  static GlassColors getGlassColors(BuildContext context) {
    final fortuneTheme = Theme.of(context).extension<FortuneThemeExtension>();
    return GlassColors(
      background: fortuneTheme?.glassBackground ?? Colors.white.withValues(alpha: 0.05),
      border: fortuneTheme?.glassBorder ?? Colors.white.withValues(alpha: 0.1),
    );
  }
}

/// Status type enum for color selection
enum StatusType {
  success,
  error,
  warning,
  info,
}

/// Shimmer colors data class
class ShimmerColors {
  final Color baseColor;
  final Color highlightColor;

  const ShimmerColors({
    required this.baseColor,
    required this.highlightColor,
  });
}

/// Glass morphism colors data class
class GlassColors {
  final Color background;
  final Color border;

  const GlassColors({
    required this.background,
    required this.border,
  });
}

