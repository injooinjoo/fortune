import 'package:flutter/material.dart';

/// Korean Traditional "Saaju" color system - Obangsaek (오방색) inspired
///
/// Design Philosophy: "Beauty of Emptiness" (여백의 미) meets "Ink on Hanji" (한지 위의 먹)
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
  // LIGHT MODE COLORS - Traditional Korean (한국 전통)
  // ============================================

  /// Primary accent color - Muted Indigo (청색)
  static const Color accent = Color(0xFF4A5568);

  /// Accent hover/pressed state
  static const Color accentHover = Color(0xFF3C4759);

  /// Lighter accent for backgrounds
  static const Color accentLight = Color(0xFFE8EBF0);

  /// Secondary accent - Vermilion Red (주색) for seals/stamps
  static const Color accentSecondary = Color(0xFFC53030);

  /// Secondary accent hover
  static const Color accentSecondaryHover = Color(0xFFAB2424);

  /// Tertiary accent - Aged Gold (황금색) for highlights/badges
  static const Color accentTertiary = Color(0xFFB7950B);

  /// Page background - Hanji paper (한지색)
  static const Color background = Color(0xFFF5F0E6);

  /// Secondary background - Light tan (담황색)
  static const Color backgroundSecondary = Color(0xFFEDE7D9);

  /// Tertiary background - Subtle hanji
  static const Color backgroundTertiary = Color(0xFFE8E0D0);

  /// Card/modal surface - Clean paper (백지색)
  static const Color surface = Color(0xFFFAF7F0);

  /// Nested surface
  static const Color surfaceSecondary = Color(0xFFF5F0E6);

  /// Primary text - Ink black (먹색)
  static const Color textPrimary = Color(0xFF2C2C2C);

  /// Secondary text - Gray ink (회먹색)
  static const Color textSecondary = Color(0xFF5C5C5C);

  /// Tertiary text - Light ink (담먹색)
  static const Color textTertiary = Color(0xFF8B8B8B);

  /// Disabled text
  static const Color textDisabled = Color(0xFFB8B0A0);

  /// Subtle border - Ink wash (번짐 효과)
  static const Color border = Color(0xFFD4C9B8);

  /// Focus border (accent color)
  static const Color borderFocus = accent;

  /// Divider line
  static const Color divider = Color(0xFFE8E0D0);

  /// Toggle active state - Jade green (청록)
  static const Color toggleActive = Color(0xFF38A169);

  /// Toggle inactive state
  static const Color toggleInactive = Color(0xFFD4C9B8);

  /// Toggle thumb
  static const Color toggleThumb = Color(0xFFFAF7F0);

  /// CTA button background - Vermilion seal (주색 인장)
  static const Color ctaBackground = Color(0xFFC53030);

  /// CTA button text
  static const Color ctaForeground = Color(0xFFFAF7F0);

  /// Secondary button background
  static const Color secondaryBackground = Color(0xFFEDE7D9);

  /// Secondary button text
  static const Color secondaryForeground = Color(0xFF2C2C2C);

  /// Success color - Jade (청록)
  static const Color success = Color(0xFF38A169);

  /// Success background
  static const Color successBackground = Color(0xFFD4EDDA);

  /// Error color - Vermilion (적색)
  static const Color error = Color(0xFFC53030);

  /// Error background
  static const Color errorBackground = Color(0xFFFAE5E5);

  /// Warning color - Aged Gold (황색)
  static const Color warning = Color(0xFFD69E2E);

  /// Warning background
  static const Color warningBackground = Color(0xFFFFF3CD);

  /// Info color - Deep indigo
  static const Color info = Color(0xFF4A5568);

  /// Info background
  static const Color infoBackground = Color(0xFFE8EBF0);

  /// Overlay for modals (semi-transparent ink)
  static const Color overlay = Color(0x802C2C2C);

  // ============================================
  // DARK MODE COLORS - Night Study (야경)
  // ============================================

  /// Primary accent - Lighter indigo for contrast
  static const Color accentDark = Color(0xFF7B8FA8);

  /// Accent hover dark
  static const Color accentHoverDark = Color(0xFF8FA3BC);

  /// Accent light background dark
  static const Color accentLightDark = Color(0xFF2D3748);

  /// Secondary accent dark - Brighter vermilion
  static const Color accentSecondaryDark = Color(0xFFE05858);

  /// Secondary accent hover dark
  static const Color accentSecondaryHoverDark = Color(0xFFD34545);

  /// Tertiary accent dark - Bright gold
  static const Color accentTertiaryDark = Color(0xFFD4AF37);

  /// Page background dark - Ink stone (벼루)
  static const Color backgroundDark = Color(0xFF1A1A1A);

  /// Secondary background dark
  static const Color backgroundSecondaryDark = Color(0xFF2D2D2D);

  /// Tertiary background dark
  static const Color backgroundTertiaryDark = Color(0xFF3D3D3D);

  /// Surface dark
  static const Color surfaceDark = Color(0xFF252525);

  /// Surface secondary dark
  static const Color surfaceSecondaryDark = Color(0xFF2D2D2D);

  /// Primary text dark - Hanji white (한지색)
  static const Color textPrimaryDark = Color(0xFFF5F0E6);

  /// Secondary text dark
  static const Color textSecondaryDark = Color(0xFFB8B0A0);

  /// Tertiary text dark
  static const Color textTertiaryDark = Color(0xFF8B8B8B);

  /// Disabled text dark
  static const Color textDisabledDark = Color(0xFF5C5C5C);

  /// Border dark - Subtle ink wash
  static const Color borderDark = Color(0xFF3D3D3D);

  /// Focus border dark
  static const Color borderFocusDark = accentDark;

  /// Divider dark
  static const Color dividerDark = Color(0xFF3D3D3D);

  /// Toggle active dark
  static const Color toggleActiveDark = Color(0xFF48BB78);

  /// Toggle inactive dark
  static const Color toggleInactiveDark = Color(0xFF4A4A4A);

  /// Toggle thumb dark
  static const Color toggleThumbDark = Color(0xFFF5F0E6);

  /// CTA background dark - Brighter vermilion
  static const Color ctaBackgroundDark = Color(0xFFE05858);

  /// CTA foreground dark
  static const Color ctaForegroundDark = Color(0xFFF5F0E6);

  /// Secondary button background dark
  static const Color secondaryBackgroundDark = Color(0xFF3D3D3D);

  /// Secondary button foreground dark
  static const Color secondaryForegroundDark = Color(0xFFF5F0E6);

  /// Success dark
  static const Color successDark = Color(0xFF48BB78);

  /// Success background dark
  static const Color successBackgroundDark = Color(0xFF1C3D2E);

  /// Error dark
  static const Color errorDark = Color(0xFFFC8181);

  /// Error background dark
  static const Color errorBackgroundDark = Color(0xFF3D1C1C);

  /// Warning dark
  static const Color warningDark = Color(0xFFECC94B);

  /// Warning background dark
  static const Color warningBackgroundDark = Color(0xFF3D3518);

  /// Info dark
  static const Color infoDark = Color(0xFF7B8FA8);

  /// Info background dark
  static const Color infoBackgroundDark = Color(0xFF2D3748);

  /// Overlay dark
  static const Color overlayDark = Color(0xB31A1A1A);

  // ============================================
  // THEME-AWARE GETTERS (for use with context)
  // ============================================

  /// Get accent color based on brightness
  static Color getAccent(Brightness brightness) =>
      brightness == Brightness.dark ? accentDark : accent;

  /// Get secondary accent based on brightness
  static Color getAccentSecondary(Brightness brightness) =>
      brightness == Brightness.dark ? accentSecondaryDark : accentSecondary;

  /// Get tertiary accent based on brightness
  static Color getAccentTertiary(Brightness brightness) =>
      brightness == Brightness.dark ? accentTertiaryDark : accentTertiary;

  /// Get background color based on brightness
  static Color getBackground(Brightness brightness) =>
      brightness == Brightness.dark ? backgroundDark : background;

  /// Get surface color based on brightness
  static Color getSurface(Brightness brightness) =>
      brightness == Brightness.dark ? surfaceDark : surface;

  /// Get primary text color based on brightness
  static Color getTextPrimary(Brightness brightness) =>
      brightness == Brightness.dark ? textPrimaryDark : textPrimary;

  /// Get secondary text color based on brightness
  static Color getTextSecondary(Brightness brightness) =>
      brightness == Brightness.dark ? textSecondaryDark : textSecondary;

  /// Get border color based on brightness
  static Color getBorder(Brightness brightness) =>
      brightness == Brightness.dark ? borderDark : border;

  /// Get divider color based on brightness
  static Color getDivider(Brightness brightness) =>
      brightness == Brightness.dark ? dividerDark : divider;

  /// Get CTA background based on brightness
  static Color getCtaBackground(Brightness brightness) =>
      brightness == Brightness.dark ? ctaBackgroundDark : ctaBackground;

  /// Get CTA foreground based on brightness
  static Color getCtaForeground(Brightness brightness) =>
      brightness == Brightness.dark ? ctaForegroundDark : ctaForeground;
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

  Color get accent => isDark ? DSColors.accentDark : DSColors.accent;
  Color get accentHover => isDark ? DSColors.accentHoverDark : DSColors.accentHover;
  Color get accentLight => isDark ? DSColors.accentLightDark : DSColors.accentLight;
  Color get accentSecondary => isDark ? DSColors.accentSecondaryDark : DSColors.accentSecondary;
  Color get accentSecondaryHover => isDark ? DSColors.accentSecondaryHoverDark : DSColors.accentSecondaryHover;
  Color get accentTertiary => isDark ? DSColors.accentTertiaryDark : DSColors.accentTertiary;

  Color get background => isDark ? DSColors.backgroundDark : DSColors.background;
  Color get backgroundSecondary => isDark ? DSColors.backgroundSecondaryDark : DSColors.backgroundSecondary;
  Color get backgroundTertiary => isDark ? DSColors.backgroundTertiaryDark : DSColors.backgroundTertiary;

  Color get surface => isDark ? DSColors.surfaceDark : DSColors.surface;
  Color get surfaceSecondary => isDark ? DSColors.surfaceSecondaryDark : DSColors.surfaceSecondary;

  Color get textPrimary => isDark ? DSColors.textPrimaryDark : DSColors.textPrimary;
  Color get textSecondary => isDark ? DSColors.textSecondaryDark : DSColors.textSecondary;
  Color get textTertiary => isDark ? DSColors.textTertiaryDark : DSColors.textTertiary;
  Color get textDisabled => isDark ? DSColors.textDisabledDark : DSColors.textDisabled;

  Color get border => isDark ? DSColors.borderDark : DSColors.border;
  Color get borderFocus => isDark ? DSColors.borderFocusDark : DSColors.borderFocus;
  Color get divider => isDark ? DSColors.dividerDark : DSColors.divider;

  Color get toggleActive => isDark ? DSColors.toggleActiveDark : DSColors.toggleActive;
  Color get toggleInactive => isDark ? DSColors.toggleInactiveDark : DSColors.toggleInactive;
  Color get toggleThumb => isDark ? DSColors.toggleThumbDark : DSColors.toggleThumb;

  Color get ctaBackground => isDark ? DSColors.ctaBackgroundDark : DSColors.ctaBackground;
  Color get ctaForeground => isDark ? DSColors.ctaForegroundDark : DSColors.ctaForeground;
  Color get secondaryBackground => isDark ? DSColors.secondaryBackgroundDark : DSColors.secondaryBackground;
  Color get secondaryForeground => isDark ? DSColors.secondaryForegroundDark : DSColors.secondaryForeground;

  Color get success => isDark ? DSColors.successDark : DSColors.success;
  Color get successBackground => isDark ? DSColors.successBackgroundDark : DSColors.successBackground;
  Color get error => isDark ? DSColors.errorDark : DSColors.error;
  Color get errorBackground => isDark ? DSColors.errorBackgroundDark : DSColors.errorBackground;
  Color get warning => isDark ? DSColors.warningDark : DSColors.warning;
  Color get warningBackground => isDark ? DSColors.warningBackgroundDark : DSColors.warningBackground;
  Color get info => isDark ? DSColors.infoDark : DSColors.info;
  Color get infoBackground => isDark ? DSColors.infoBackgroundDark : DSColors.infoBackground;

  Color get overlay => isDark ? DSColors.overlayDark : DSColors.overlay;
}
