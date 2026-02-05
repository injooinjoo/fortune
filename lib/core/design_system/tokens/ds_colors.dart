import 'package:flutter/material.dart';

/// ChatGPT-inspired minimal color system
///
/// Design Philosophy: Clean, minimal, content-first
/// "Pure white/black + subtle accent"
///
/// Key Principles:
/// - Pure white backgrounds (light mode)
/// - Pure black backgrounds (dark mode)
/// - Minimal accent color (purple CTA only)
/// - High contrast, no warm tints
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
  // DARK MODE COLORS (Primary/Default)
  // ============================================

  /// Primary accent color - Purple CTA
  static const Color accent = Color(0xFF7C5CFC);

  /// Accent hover/pressed state
  static const Color accentHover = Color(0xFF6B4AEB);

  /// Lighter accent for backgrounds
  static const Color accentLight = Color(0xFF1E1A2E);

  /// Secondary accent - Soft blue for links/info
  static const Color accentSecondary = Color(0xFF8FB0FF);

  /// Secondary accent hover
  static const Color accentSecondaryHover = Color(0xFF7AA0FF);

  /// Tertiary accent - Warm amber for highlights
  static const Color accentTertiary = Color(0xFFE0A76B);

  /// Page background - Pure black
  static const Color background = Color(0xFF000000);

  /// Secondary background - Near black
  static const Color backgroundSecondary = Color(0xFF1A1A1A);

  /// Tertiary background - Dark gray
  static const Color backgroundTertiary = Color(0xFF212121);

  /// Card/modal surface - Dark surface
  static const Color surface = Color(0xFF1A1A1A);

  /// Nested surface - Slightly lighter
  static const Color surfaceSecondary = Color(0xFF2C2C2E);

  /// Primary text - Pure white
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text - iOS system gray
  static const Color textSecondary = Color(0xFF8E8E93);

  /// Tertiary text - Darker gray
  static const Color textTertiary = Color(0xFF636366);

  /// Disabled text - Mid gray
  static const Color textDisabled = Color(0xFF48484A);

  /// User message bubble
  static const Color userBubble = Color(0xFF2C2C2E);

  /// Subtle border
  static const Color border = Color(0xFF2C2C2E);

  /// Focus border
  static const Color borderFocus = accent;

  /// Divider line
  static const Color divider = Color(0xFF2C2C2E);

  /// Toggle active state
  static const Color toggleActive = accent;

  /// Toggle inactive state
  static const Color toggleInactive = Color(0xFF39393D);

  /// Toggle thumb
  static const Color toggleThumb = Color(0xFFFFFFFF);

  /// CTA button background - White (dark mode)
  static const Color ctaBackground = Color(0xFFFFFFFF);

  /// CTA button text - Black (dark mode)
  static const Color ctaForeground = Color(0xFF000000);

  /// Secondary button background
  static const Color secondaryBackground = Color(0xFF2C2C2E);

  /// Secondary button text
  static const Color secondaryForeground = Color(0xFFFFFFFF);

  /// Success color
  static const Color success = Color(0xFF34C759);

  /// Success background
  static const Color successBackground = Color(0xFF0D2818);

  /// Error color
  static const Color error = Color(0xFFFF3B30);

  /// Error background
  static const Color errorBackground = Color(0xFF2D0F0D);

  /// Warning color
  static const Color warning = Color(0xFFFFCC00);

  /// Warning background
  static const Color warningBackground = Color(0xFF2D2600);

  /// Info color - Soft blue
  static const Color info = Color(0xFF007AFF);

  /// Info background
  static const Color infoBackground = Color(0xFF001A33);

  /// Overlay for modals (60% black)
  static const Color overlay = Color(0x99000000);

  // ============================================
  // LIGHT MODE COLORS
  // ============================================

  /// Primary accent light - Purple CTA
  static const Color accentDark = Color(0xFF7C5CFC);

  /// Accent hover light
  static const Color accentHoverDark = Color(0xFF6B4AEB);

  /// Accent light background
  static const Color accentLightDark = Color(0xFFF0ECFF);

  /// Secondary accent light
  static const Color accentSecondaryDark = Color(0xFF3B63D3);

  /// Secondary accent hover light
  static const Color accentSecondaryHoverDark = Color(0xFF2F55C4);

  /// Tertiary accent light
  static const Color accentTertiaryDark = Color(0xFFC7702F);

  /// Page background light - Pure white
  static const Color backgroundDark = Color(0xFFFFFFFF);

  /// Secondary background light - Light gray
  static const Color backgroundSecondaryDark = Color(0xFFF7F7F8);

  /// Tertiary background light
  static const Color backgroundTertiaryDark = Color(0xFFF0F0F0);

  /// Surface light - Pure white
  static const Color surfaceDark = Color(0xFFFFFFFF);

  /// Surface secondary light - Light gray
  static const Color surfaceSecondaryDark = Color(0xFFF7F7F8);

  /// Primary text light - Pure black
  static const Color textPrimaryDark = Color(0xFF000000);

  /// Secondary text light - iOS system gray
  static const Color textSecondaryDark = Color(0xFF6E6E73);

  /// Tertiary text light
  static const Color textTertiaryDark = Color(0xFF8E8E93);

  /// Disabled text light
  static const Color textDisabledDark = Color(0xFFAEAEB2);

  /// User message bubble light
  static const Color userBubbleDark = Color(0xFFF7F7F8);

  /// Border light
  static const Color borderDark = Color(0xFFE5E5EA);

  /// Focus border light
  static const Color borderFocusDark = accentDark;

  /// Divider light
  static const Color dividerDark = Color(0xFFE5E5EA);

  /// Toggle active light
  static const Color toggleActiveDark = accentDark;

  /// Toggle inactive light
  static const Color toggleInactiveDark = Color(0xFFD1D1D6);

  /// Toggle thumb light
  static const Color toggleThumbDark = Color(0xFFFFFFFF);

  /// CTA background light - Black
  static const Color ctaBackgroundDark = Color(0xFF000000);

  /// CTA foreground light - White
  static const Color ctaForegroundDark = Color(0xFFFFFFFF);

  /// Secondary button background light
  static const Color secondaryBackgroundDark = Color(0xFFF7F7F8);

  /// Secondary button foreground light
  static const Color secondaryForegroundDark = Color(0xFF000000);

  /// Success light
  static const Color successDark = Color(0xFF34C759);

  /// Success background light
  static const Color successBackgroundDark = Color(0xFFE8F9ED);

  /// Error light
  static const Color errorDark = Color(0xFFFF3B30);

  /// Error background light
  static const Color errorBackgroundDark = Color(0xFFFFEBEA);

  /// Warning light
  static const Color warningDark = Color(0xFFFFCC00);

  /// Warning background light
  static const Color warningBackgroundDark = Color(0xFFFFF9E0);

  /// Info light
  static const Color infoDark = Color(0xFF007AFF);

  /// Info background light
  static const Color infoBackgroundDark = Color(0xFFE5F0FF);

  /// Overlay light
  static const Color overlayDark = Color(0x4D000000);

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
