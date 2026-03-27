import 'package:flutter/material.dart';

/// Paper-aligned design system colors
///
/// Source of truth: Paper MCP "Fortune" design file
/// Last synced: 2026-03-27
///
/// Design Philosophy: Deep navy-black base with cool-toned grays
/// - Deep navy-black backgrounds (#0B0B10)
/// - Cool white text (#F5F6FB)
/// - Blue-gray secondary text (#9198AA)
/// - Deep blue CTA (#2043D6)
/// - Semi-transparent borders (white 8%)
/// - Pastel interest chips
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
  // DARK MODE COLORS (Primary/Default — Paper aligned)
  // ============================================

  /// Primary accent color — cool white (Paper: #F5F6FB)
  static const Color accent = Color(0xFFF5F6FB);

  /// Accent hover/pressed state
  static const Color accentHover = Color(0xFFD0D4E0);

  /// Lighter accent for backgrounds — subtle white 7% (Paper badge bg)
  static const Color accentLight = Color(0x12FFFFFF);

  /// Secondary accent — sky blue for links/info (Paper: #8FB8FF)
  static const Color accentSecondary = Color(0xFF8FB8FF);

  /// Secondary accent hover
  static const Color accentSecondaryHover = Color(0xFF7AA8FF);

  /// Tertiary accent — warm amber for highlights
  static const Color accentTertiary = Color(0xFFE0A76B);

  /// Page background — deep navy-black (Paper: #0B0B10)
  static const Color background = Color(0xFF0B0B10);

  /// Secondary background — dark surface (Paper: #1A1A1A)
  static const Color backgroundSecondary = Color(0xFF1A1A1A);

  /// Tertiary background — dark blue-gray (Paper: #151821)
  static const Color backgroundTertiary = Color(0xFF151821);

  /// Card/modal surface — dark surface (Paper: #1A1A1A)
  static const Color surface = Color(0xFF1A1A1A);

  /// Nested surface — dark blue-gray (Paper: #23232B)
  static const Color surfaceSecondary = Color(0xFF23232B);

  /// Elevated card surface — auth card background (Paper: #17171D)
  static const Color surfaceElevated = Color(0xFF17171D);

  /// Primary text — cool white (Paper: #F5F6FB)
  static const Color textPrimary = Color(0xFFF5F6FB);

  /// Secondary text — blue-gray (Paper: #9198AA)
  static const Color textSecondary = Color(0xFF9198AA);

  /// Tertiary text — lighter blue-gray (Paper: #9EA3B3)
  static const Color textTertiary = Color(0xFF9EA3B3);

  /// Disabled text — mid gray
  static const Color textDisabled = Color(0xFF48484A);

  /// Subtitle text — light cool gray (Paper: #D0D4E0)
  static const Color textSubtitle = Color(0xFFD0D4E0);

  /// User message bubble (Paper: #2C2C2E)
  static const Color userBubble = Color(0xFF2C2C2E);

  /// Subtle border — semi-transparent white 8% (Paper: #FFFFFF14)
  static const Color border = Color(0x14FFFFFF);

  /// Opaque border — for dividers needing solid color (Paper: #2C2C2E)
  static const Color borderOpaque = Color(0xFF2C2C2E);

  /// Focus border — stronger gray
  static const Color borderFocus = Color(0xFF48484A);

  /// Divider line (Paper: #2C2C2E)
  static const Color divider = Color(0xFF2C2C2E);

  /// Toggle active state — iOS system green
  static const Color toggleActive = Color(0xFF34C759);

  /// Toggle inactive state
  static const Color toggleInactive = Color(0xFF39393D);

  /// Toggle thumb
  static const Color toggleThumb = Color(0xFFFFFFFF);

  /// CTA button background — deep blue (Paper: #2043D6)
  static const Color ctaBackground = Color(0xFF2043D6);

  /// CTA button text — cool white (Paper: #F5F6FB)
  static const Color ctaForeground = Color(0xFFF5F6FB);

  /// Secondary button background (Paper: #23232B)
  static const Color secondaryBackground = Color(0xFF23232B);

  /// Secondary button text — cool white
  static const Color secondaryForeground = Color(0xFFF5F6FB);

  /// Apple auth button background (Paper: #F5F5F8)
  static const Color authAppleBackground = Color(0xFFF5F5F8);

  /// Google auth button background (Paper: #23232B)
  static const Color authGoogleBackground = Color(0xFF23232B);

  // ============================================
  // INTEREST CHIP PASTEL COLORS (Paper)
  // ============================================

  /// Selected chip — blue pastel (Paper: #E7F1FF)
  static const Color chipBlue = Color(0xFFE7F1FF);

  /// Selected chip — green pastel (Paper: #C9FFDC)
  static const Color chipGreen = Color(0xFFC9FFDC);

  /// Selected chip — peach pastel (extrapolated)
  static const Color chipPeach = Color(0xFFFFE8D6);

  /// Selected chip — lavender pastel (extrapolated)
  static const Color chipLavender = Color(0xFFE8E0FF);

  /// Chip text on pastel — dark (Paper: #122031)
  static const Color chipText = Color(0xFF122031);

  /// Chip confirmation text — sky blue (Paper: #8FB8FF)
  static const Color chipConfirmation = Color(0xFF8FB8FF);

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
  // LIGHT MODE COLORS (Paper-aligned inverse)
  // ============================================

  /// Primary accent light — dark text
  static const Color accentDark = Color(0xFF0B0B10);

  /// Accent hover light
  static const Color accentHoverDark = Color(0xFF3C3C43);

  /// Accent light background
  static const Color accentLightDark = Color(0xFFF2F2F7);

  /// Secondary accent light — deeper blue
  static const Color accentSecondaryDark = Color(0xFF2043D6);

  /// Secondary accent hover light
  static const Color accentSecondaryHoverDark = Color(0xFF1A38B8);

  /// Tertiary accent light
  static const Color accentTertiaryDark = Color(0xFFC7702F);

  /// Page background light — pure white
  static const Color backgroundDark = Color(0xFFFFFFFF);

  /// Secondary background light
  static const Color backgroundSecondaryDark = Color(0xFFF7F7F8);

  /// Tertiary background light
  static const Color backgroundTertiaryDark = Color(0xFFF0F0F2);

  /// Surface light
  static const Color surfaceDark = Color(0xFFFFFFFF);

  /// Surface secondary light
  static const Color surfaceSecondaryDark = Color(0xFFF7F7F8);

  /// Surface elevated light
  static const Color surfaceElevatedDark = Color(0xFFFFFFFF);

  /// Primary text light
  static const Color textPrimaryDark = Color(0xFF0B0B10);

  /// Secondary text light — muted blue-gray
  static const Color textSecondaryDark = Color(0xFF5C6272);

  /// Tertiary text light
  static const Color textTertiaryDark = Color(0xFF6E7585);

  /// Disabled text light
  static const Color textDisabledDark = Color(0xFFAEAEB2);

  /// Subtitle text light
  static const Color textSubtitleDark = Color(0xFF3C3C43);

  /// User message bubble light
  static const Color userBubbleDark = Color(0xFFF0F0F2);

  /// Border light — subtle gray
  static const Color borderDark = Color(0xFFE5E5EA);

  /// Opaque border light
  static const Color borderOpaqueDark = Color(0xFFE5E5EA);

  /// Focus border light
  static const Color borderFocusDark = Color(0xFFC7C7CC);

  /// Divider light
  static const Color dividerDark = Color(0xFFE5E5EA);

  /// Toggle active light
  static const Color toggleActiveDark = Color(0xFF34C759);

  /// Toggle inactive light
  static const Color toggleInactiveDark = Color(0xFFD1D1D6);

  /// Toggle thumb light
  static const Color toggleThumbDark = Color(0xFFFFFFFF);

  /// CTA background light — deep blue (consistent with dark)
  static const Color ctaBackgroundDark = Color(0xFF2043D6);

  /// CTA foreground light — white
  static const Color ctaForegroundDark = Color(0xFFFFFFFF);

  /// Secondary button background light
  static const Color secondaryBackgroundDark = Color(0xFFF0F0F2);

  /// Secondary button foreground light
  static const Color secondaryForegroundDark = Color(0xFF0B0B10);

  /// Auth apple button light
  static const Color authAppleBackgroundDark = Color(0xFF0B0B10);

  /// Auth google button light
  static const Color authGoogleBackgroundDark = Color(0xFFF0F0F2);

  // Chip colors — same across modes (pastel on dark text)
  static const Color chipBlueDark = Color(0xFFD6E4F7);
  static const Color chipGreenDark = Color(0xFFB8EDCB);
  static const Color chipPeachDark = Color(0xFFF0D9C4);
  static const Color chipLavenderDark = Color(0xFFD8D0F0);
  static const Color chipTextDark = Color(0xFF122031);
  static const Color chipConfirmationDark = Color(0xFF2043D6);

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
  Color get surfaceElevated =>
      isDark ? DSColors.surfaceElevated : DSColors.surfaceElevatedDark;

  Color get textPrimary =>
      isDark ? DSColors.textPrimary : DSColors.textPrimaryDark;
  Color get textSecondary =>
      isDark ? DSColors.textSecondary : DSColors.textSecondaryDark;
  Color get textTertiary =>
      isDark ? DSColors.textTertiary : DSColors.textTertiaryDark;
  Color get textDisabled =>
      isDark ? DSColors.textDisabled : DSColors.textDisabledDark;
  Color get textSubtitle =>
      isDark ? DSColors.textSubtitle : DSColors.textSubtitleDark;

  Color get userBubble =>
      isDark ? DSColors.userBubble : DSColors.userBubbleDark;

  Color get border => isDark ? DSColors.border : DSColors.borderDark;
  Color get borderOpaque =>
      isDark ? DSColors.borderOpaque : DSColors.borderOpaqueDark;
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

  Color get selectionBackground =>
      isDark ? DSColors.surfaceSecondary : DSColors.backgroundSecondaryDark;
  Color get selectionBorder =>
      isDark ? DSColors.borderFocus : DSColors.borderFocusDark;
  Color get selectionForeground => textPrimary;
  Color get selectionMutedForeground => textSecondary;

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

  // Auth button colors
  Color get authAppleBackground =>
      isDark ? DSColors.authAppleBackground : DSColors.authAppleBackgroundDark;
  Color get authGoogleBackground =>
      isDark ? DSColors.authGoogleBackground : DSColors.authGoogleBackgroundDark;

  // Interest chip colors
  Color get chipBlue => isDark ? DSColors.chipBlue : DSColors.chipBlueDark;
  Color get chipGreen => isDark ? DSColors.chipGreen : DSColors.chipGreenDark;
  Color get chipPeach => isDark ? DSColors.chipPeach : DSColors.chipPeachDark;
  Color get chipLavender =>
      isDark ? DSColors.chipLavender : DSColors.chipLavenderDark;
  Color get chipText => isDark ? DSColors.chipText : DSColors.chipTextDark;
  Color get chipConfirmation =>
      isDark ? DSColors.chipConfirmation : DSColors.chipConfirmationDark;
}
