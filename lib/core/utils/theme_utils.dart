import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';
import '../theme/app_theme_extensions.dart';

/// Utility class for theme-related operations and dark mode support
class ThemeUtils {
  /// Check if the current theme is dark mode
  static bool isDarkMode(BuildContext context) {
    return context.isDark;
  }

  /// Get the appropriate gradient for the current theme
  static LinearGradient getPrimaryGradient(BuildContext context) {
    final accentColor =
        isDarkMode(context) ? DSColors.accent : DSColors.accentDark;
    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        accentColor.withValues(alpha: 0.8),
        accentColor.withValues(alpha: 0.6),
        accentColor.withValues(alpha: 0.4),
      ],
    );
  }

  /// Get theme-aware shadow - neutralized (flat design, no shadows)
  static List<BoxShadow> getCardShadow(BuildContext context) {
    return [];
  }

  /// Get theme-aware border
  static Border getCardBorder(BuildContext context) {
    return Border.all(
      color: isDarkMode(context)
          ? DSColors.surfaceSecondary.withValues(alpha: 0.3)
          : DSColors.borderDark.withValues(alpha: 0.5),
      width: 1,
    );
  }

  /// Get mystical gradient based on theme
  static LinearGradient getMysticalGradient(BuildContext context) {
    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        DSColors.accentTertiary.withValues(alpha: 0.8),
        DSColors.accentTertiary.withValues(alpha: 0.6),
        DSColors.accentTertiary.withValues(alpha: 0.4),
      ],
    );
  }

  /// Convert hardcoded colors to theme-aware colors
  static Color getThemedPurple(BuildContext context, {double opacity = 1.0}) {
    final baseColor = DSColors.accentTertiary;
    return opacity < 1.0 ? baseColor.withValues(alpha: opacity) : baseColor;
  }

  /// Get status color based on theme
  static Color getStatusColor(BuildContext context, StatusType type) {
    switch (type) {
      case StatusType.success:
        return DSColors.success;
      case StatusType.error:
        return DSColors.error;
      case StatusType.warning:
        return DSColors.warning;
      case StatusType.info:
        return DSColors.info;
    }
  }

  /// Get shimmer colors for loading states
  static ShimmerColors getShimmerColors(BuildContext context) {
    final fortuneTheme = Theme.of(context).extension<FortuneThemeExtension>();
    return ShimmerColors(
      baseColor: fortuneTheme?.shimmerBase ?? DSColors.borderDark,
      highlightColor: fortuneTheme?.shimmerHighlight ??
          DSColors.borderDark.withValues(alpha: 0.3),
    );
  }

  /// Get glass morphism colors
  static GlassColors getGlassColors(BuildContext context) {
    final fortuneTheme = Theme.of(context).extension<FortuneThemeExtension>();
    return GlassColors(
      background: fortuneTheme?.glassBackground ??
          DSColors.surfaceDark.withValues(alpha: 0.05),
      border: fortuneTheme?.glassBorder ??
          DSColors.surfaceDark.withValues(alpha: 0.1),
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
