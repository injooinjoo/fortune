import 'package:flutter/material.dart';

/// Neon Dark Theme - Modern cyberpunk color system
///
/// Design Philosophy: High contrast, futuristic, bold
/// "Pure black meets electric neon"
///
/// Key Principles:
/// - Pure Black Background: Maximum contrast, no warm tones
/// - Neon Green Accent: Electric, vibrant, attention-grabbing
/// - Consistent Accent: Same neon green in light/dark modes
///
/// Usage:
/// ```dart
/// // With context (recommended for theme-aware colors)
/// Container(color: context.colors.background)
///
/// // Static access for constants
/// DSColors.accent
/// ```
class DSColors {
  DSColors._();

  // ============================================
  // NEON DARK MODE COLORS (Primary/Default)
  // ============================================

  /// Primary accent color - Neon Green (#39FF14)
  static const Color accent = Color(0xFF39FF14);

  /// Accent hover/pressed state - Slightly dimmer
  static const Color accentHover = Color(0xFF32E012);

  /// Lighter accent for backgrounds - Very dark green tint
  static const Color accentLight = Color(0xFF0D2A0A);

  /// Secondary accent - Neon Cyan for links/info
  static const Color accentSecondary = Color(0xFF00D4FF);

  /// Secondary accent hover
  static const Color accentSecondaryHover = Color(0xFF00B8E0);

  /// Tertiary accent - Neon Pink
  static const Color accentTertiary = Color(0xFFFF00FF);

  /// Page background - Pure Black (#000000)
  static const Color background = Color(0xFF000000);

  /// Secondary background - Very dark gray
  static const Color backgroundSecondary = Color(0xFF0A0A0A);

  /// Tertiary background - Slightly lighter
  static const Color backgroundTertiary = Color(0xFF121212);

  /// Card/modal surface - Dark Grey (#1C1C1C)
  static const Color surface = Color(0xFF1C1C1C);

  /// Nested surface - Slightly lighter gray
  static const Color surfaceSecondary = Color(0xFF252525);

  /// Primary text - Pure White (#FFFFFF)
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text - Light gray
  static const Color textSecondary = Color(0xFFB0B0B0);

  /// Tertiary text - Medium gray
  static const Color textTertiary = Color(0xFF808080);

  /// Disabled text - Dark gray
  static const Color textDisabled = Color(0xFF505050);

  /// User message bubble - Dark gray
  static const Color userBubble = Color(0xFF2A2A2A);

  /// Subtle border - Dark border
  static const Color border = Color(0xFF333333);

  /// Focus border (neon accent)
  static const Color borderFocus = accent;

  /// Divider line
  static const Color divider = Color(0xFF222222);

  /// Toggle active state - Neon green
  static const Color toggleActive = accent;

  /// Toggle inactive state
  static const Color toggleInactive = Color(0xFF404040);

  /// Toggle thumb
  static const Color toggleThumb = Color(0xFFFFFFFF);

  /// CTA button background - Neon Green
  static const Color ctaBackground = accent;

  /// CTA button text - Black (#000000)
  static const Color ctaForeground = Color(0xFF000000);

  /// Secondary button background
  static const Color secondaryBackground = Color(0xFF2A2A2A);

  /// Secondary button text
  static const Color secondaryForeground = Color(0xFFFFFFFF);

  /// Success color - Neon Green
  static const Color success = Color(0xFF39FF14);

  /// Success background
  static const Color successBackground = Color(0xFF0D2A0A);

  /// Error color - Neon Red
  static const Color error = Color(0xFFFF3B3B);

  /// Error background
  static const Color errorBackground = Color(0xFF2A0D0D);

  /// Warning color - Neon Yellow
  static const Color warning = Color(0xFFFFE500);

  /// Warning background
  static const Color warningBackground = Color(0xFF2A2A0D);

  /// Info color - Neon Cyan
  static const Color info = Color(0xFF00D4FF);

  /// Info background
  static const Color infoBackground = Color(0xFF0D2A2A);

  /// Overlay for modals (85% black)
  static const Color overlay = Color(0xD9000000);

  // ============================================
  // NEON LIGHT MODE COLORS
  // ============================================

  /// Primary accent - Same Neon Green (consistent)
  static const Color accentDark = Color(0xFF39FF14);

  /// Accent hover light - Slightly dimmer
  static const Color accentHoverDark = Color(0xFF32E012);

  /// Accent light background (for light mode - subtle green tint)
  static const Color accentLightDark = Color(0xFFE8FFE5);

  /// Secondary accent light - Cyan
  static const Color accentSecondaryDark = Color(0xFF00B8E0);

  /// Secondary accent hover light
  static const Color accentSecondaryHoverDark = Color(0xFF00A0C8);

  /// Tertiary accent light - Pink
  static const Color accentTertiaryDark = Color(0xFFE000E0);

  /// Page background light - Pure White (#FFFFFF)
  static const Color backgroundDark = Color(0xFFFFFFFF);

  /// Secondary background light - Light gray
  static const Color backgroundSecondaryDark = Color(0xFFF5F5F5);

  /// Tertiary background light
  static const Color backgroundTertiaryDark = Color(0xFFEEEEEE);

  /// Surface light - Very light gray
  static const Color surfaceDark = Color(0xFFF5F5F5);

  /// Surface secondary light
  static const Color surfaceSecondaryDark = Color(0xFFFFFFFF);

  /// Primary text light - Black
  static const Color textPrimaryDark = Color(0xFF000000);

  /// Secondary text light - Dark gray
  static const Color textSecondaryDark = Color(0xFF606060);

  /// Tertiary text light
  static const Color textTertiaryDark = Color(0xFF909090);

  /// Disabled text light
  static const Color textDisabledDark = Color(0xFFB0B0B0);

  /// User message bubble light
  static const Color userBubbleDark = Color(0xFFE0E0E0);

  /// Border light
  static const Color borderDark = Color(0xFFDDDDDD);

  /// Focus border light
  static const Color borderFocusDark = accentDark;

  /// Divider light
  static const Color dividerDark = Color(0xFFEEEEEE);

  /// Toggle active light
  static const Color toggleActiveDark = accentDark;

  /// Toggle inactive light
  static const Color toggleInactiveDark = Color(0xFFD0D0D0);

  /// Toggle thumb light
  static const Color toggleThumbDark = Color(0xFFFFFFFF);

  /// CTA background light - Same neon green
  static const Color ctaBackgroundDark = accentDark;

  /// CTA foreground light - Black text on neon
  static const Color ctaForegroundDark = Color(0xFF000000);

  /// Secondary button background light
  static const Color secondaryBackgroundDark = Color(0xFFE8E8E8);

  /// Secondary button foreground light
  static const Color secondaryForegroundDark = Color(0xFF1A1A1A);

  /// Success light
  static const Color successDark = Color(0xFF28CC10);

  /// Success background light
  static const Color successBackgroundDark = Color(0xFFE5FFE0);

  /// Error light
  static const Color errorDark = Color(0xFFE53535);

  /// Error background light
  static const Color errorBackgroundDark = Color(0xFFFFE5E5);

  /// Warning light
  static const Color warningDark = Color(0xFFE5C800);

  /// Warning background light
  static const Color warningBackgroundDark = Color(0xFFFFFDE5);

  /// Info light
  static const Color infoDark = Color(0xFF00B8E0);

  /// Info background light
  static const Color infoBackgroundDark = Color(0xFFE5FAFF);

  /// Overlay light
  static const Color overlayDark = Color(0x80000000);

  // ============================================
  // THEME-AWARE GETTERS (for use with context)
  // ============================================

  /// Get accent color based on brightness
  static Color getAccent(Brightness brightness) =>
      brightness == Brightness.light ? accentDark : accent;

  /// Get secondary accent based on brightness
  static Color getAccentSecondary(Brightness brightness) =>
      brightness == Brightness.light ? accentSecondaryDark : accentSecondary;

  /// Get tertiary accent based on brightness
  static Color getAccentTertiary(Brightness brightness) =>
      brightness == Brightness.light ? accentTertiaryDark : accentTertiary;

  /// Get background color based on brightness
  static Color getBackground(Brightness brightness) =>
      brightness == Brightness.light ? backgroundDark : background;

  /// Get surface color based on brightness
  static Color getSurface(Brightness brightness) =>
      brightness == Brightness.light ? surfaceDark : surface;

  /// Get primary text color based on brightness
  static Color getTextPrimary(Brightness brightness) =>
      brightness == Brightness.light ? textPrimaryDark : textPrimary;

  /// Get secondary text color based on brightness
  static Color getTextSecondary(Brightness brightness) =>
      brightness == Brightness.light ? textSecondaryDark : textSecondary;

  /// Get border color based on brightness
  static Color getBorder(Brightness brightness) =>
      brightness == Brightness.light ? borderDark : border;

  /// Get divider color based on brightness
  static Color getDivider(Brightness brightness) =>
      brightness == Brightness.light ? dividerDark : divider;

  /// Get CTA background based on brightness
  static Color getCtaBackground(Brightness brightness) =>
      brightness == Brightness.light ? ctaBackgroundDark : ctaBackground;

  /// Get CTA foreground based on brightness
  static Color getCtaForeground(Brightness brightness) =>
      brightness == Brightness.light ? ctaForegroundDark : ctaForeground;

  /// Get user bubble color based on brightness
  static Color getUserBubble(Brightness brightness) =>
      brightness == Brightness.light ? userBubbleDark : userBubble;
}

/// Theme-aware color accessor
///
/// Usage with BuildContext extension:
/// ```dart
/// Container(color: context.colors.background)
/// ```
class DSColorScheme {
  final Brightness brightness;

  const DSColorScheme(this.brightness);

  bool get isDark => brightness == Brightness.dark;

  Color get accent => isDark ? DSColors.accent : DSColors.accentDark;
  Color get accentHover =>
      isDark ? DSColors.accentHover : DSColors.accentHoverDark;
  Color get accentLight =>
      isDark ? DSColors.accentLight : DSColors.accentLightDark;
  Color get accentSecondary =>
      isDark ? DSColors.accentSecondary : DSColors.accentSecondaryDark;
  Color get accentSecondaryHover => isDark
      ? DSColors.accentSecondaryHover
      : DSColors.accentSecondaryHoverDark;
  Color get accentTertiary =>
      isDark ? DSColors.accentTertiary : DSColors.accentTertiaryDark;

  Color get background =>
      isDark ? DSColors.background : DSColors.backgroundDark;
  Color get backgroundSecondary =>
      isDark ? DSColors.backgroundSecondary : DSColors.backgroundSecondaryDark;
  Color get backgroundTertiary =>
      isDark ? DSColors.backgroundTertiary : DSColors.backgroundTertiaryDark;

  Color get surface => isDark ? DSColors.surface : DSColors.surfaceDark;
  Color get surfaceSecondary =>
      isDark ? DSColors.surfaceSecondary : DSColors.surfaceSecondaryDark;

  Color get textPrimary =>
      isDark ? DSColors.textPrimary : DSColors.textPrimaryDark;
  Color get textSecondary =>
      isDark ? DSColors.textSecondary : DSColors.textSecondaryDark;
  Color get textTertiary =>
      isDark ? DSColors.textTertiary : DSColors.textTertiaryDark;
  Color get textDisabled =>
      isDark ? DSColors.textDisabled : DSColors.textDisabledDark;

  Color get userBubble =>
      isDark ? DSColors.userBubble : DSColors.userBubbleDark;

  Color get border => isDark ? DSColors.border : DSColors.borderDark;
  Color get borderFocus =>
      isDark ? DSColors.borderFocus : DSColors.borderFocusDark;
  Color get divider => isDark ? DSColors.divider : DSColors.dividerDark;

  Color get toggleActive =>
      isDark ? DSColors.toggleActive : DSColors.toggleActiveDark;
  Color get toggleInactive =>
      isDark ? DSColors.toggleInactive : DSColors.toggleInactiveDark;
  Color get toggleThumb =>
      isDark ? DSColors.toggleThumb : DSColors.toggleThumbDark;

  Color get ctaBackground =>
      isDark ? DSColors.ctaBackground : DSColors.ctaBackgroundDark;
  Color get ctaForeground =>
      isDark ? DSColors.ctaForeground : DSColors.ctaForegroundDark;
  Color get secondaryBackground =>
      isDark ? DSColors.secondaryBackground : DSColors.secondaryBackgroundDark;
  Color get secondaryForeground =>
      isDark ? DSColors.secondaryForeground : DSColors.secondaryForegroundDark;

  Color get success => isDark ? DSColors.success : DSColors.successDark;
  Color get successBackground =>
      isDark ? DSColors.successBackground : DSColors.successBackgroundDark;
  Color get error => isDark ? DSColors.error : DSColors.errorDark;
  Color get errorBackground =>
      isDark ? DSColors.errorBackground : DSColors.errorBackgroundDark;
  Color get warning => isDark ? DSColors.warning : DSColors.warningDark;
  Color get warningBackground =>
      isDark ? DSColors.warningBackground : DSColors.warningBackgroundDark;
  Color get info => isDark ? DSColors.info : DSColors.infoDark;
  Color get infoBackground =>
      isDark ? DSColors.infoBackground : DSColors.infoBackgroundDark;

  Color get overlay => isDark ? DSColors.overlay : DSColors.overlayDark;
}
