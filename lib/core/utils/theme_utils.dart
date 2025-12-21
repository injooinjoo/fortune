import 'package:flutter/material.dart';
import 'package:fortune/core/theme/fortune_design_system.dart';
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
          TossDesignSystem.tossBlueDark.withValues(alpha: 0.8),
          TossDesignSystem.tossBlueDark.withValues(alpha: 0.6),
          TossDesignSystem.tossBlueDark.withValues(alpha: 0.4)]
      );
    }
    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        TossDesignSystem.tossBlue.withValues(alpha: 0.8),
        TossDesignSystem.tossBlue.withValues(alpha: 0.6),
        TossDesignSystem.tossBlue.withValues(alpha: 0.4)]
    );
  }

  /// Get theme-aware shadow
  static List<BoxShadow> getCardShadow(BuildContext context) {
    if (isDarkMode(context)) {
      return [
        BoxShadow(
          color: TossDesignSystem.black.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2))];
    }
    return [
      BoxShadow(
        color: TossDesignSystem.black.withValues(alpha: 0.04),
        blurRadius: 10,
        offset: const Offset(0, 2))];
  }

  /// Get theme-aware border
  static Border getCardBorder(BuildContext context) {
    return Border.all(
      color: isDarkMode(context) 
        ? TossDesignSystem.grayDark200.withValues(alpha: 0.3)
        : TossDesignSystem.gray200.withValues(alpha: 0.5),
      width: 1);
  }

  /// Get mystical gradient based on theme
  static LinearGradient getMysticalGradient(BuildContext context) {
    if (isDarkMode(context)) {
      return LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          TossDesignSystem.purple.withValues(alpha: 0.8),
          TossDesignSystem.purple.withValues(alpha: 0.6),
          TossDesignSystem.purple.withValues(alpha: 0.4)]
      );
    }
    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        TossDesignSystem.purple.withValues(alpha: 0.8),
        TossDesignSystem.purple.withValues(alpha: 0.6),
        TossDesignSystem.purple.withValues(alpha: 0.4)]
    );
  }

  /// Convert hardcoded colors to theme-aware colors
  static Color getThemedPurple(BuildContext context, {double opacity = 1.0}) {
    final baseColor = TossDesignSystem.purple;
    return opacity < 1.0 ? baseColor.withValues(alpha: opacity) : baseColor;
  }

  /// Get status color based on theme
  static Color getStatusColor(BuildContext context, StatusType type) {
    switch (type) {
      case StatusType.success:
        return isDarkMode(context) ? TossDesignSystem.successGreenDark : TossDesignSystem.successGreen;
      case StatusType.error:
        return isDarkMode(context) ? TossDesignSystem.errorRedDark : TossDesignSystem.errorRed;
      case StatusType.warning:
        return isDarkMode(context) ? TossDesignSystem.warningOrangeDark : TossDesignSystem.warningOrange;
      case StatusType.info:
        return isDarkMode(context) ? TossDesignSystem.infoBlueDark : TossDesignSystem.infoBlue;
    }
  }

  /// Get shimmer colors for loading states
  static ShimmerColors getShimmerColors(BuildContext context) {
    final fortuneTheme = Theme.of(context).extension<FortuneThemeExtension>();
    return ShimmerColors(
      baseColor: fortuneTheme?.shimmerBase ?? TossDesignSystem.gray200,
      highlightColor: fortuneTheme?.shimmerHighlight ?? TossDesignSystem.gray200.withValues(alpha: 0.3));
  }

  /// Get glass morphism colors
  static GlassColors getGlassColors(BuildContext context) {
    final fortuneTheme = Theme.of(context).extension<FortuneThemeExtension>();
    return GlassColors(
      background: fortuneTheme?.glassBackground ?? TossDesignSystem.white.withValues(alpha: 0.05),
      border: fortuneTheme?.glassBorder ?? TossDesignSystem.white.withValues(alpha: 0.1));
  }
}

/// Status type enum for color selection
enum StatusType {
  
  
  success,
  error,
  warning,
  info}

/// Shimmer colors data class
class ShimmerColors {
  final Color baseColor;
  final Color highlightColor;

  const ShimmerColors({
    required this.baseColor,
    required this.highlightColor});
}

/// Glass morphism colors data class
class GlassColors {
  final Color background;
  final Color border;

  const GlassColors({
    required this.background,
    required this.border});
}

