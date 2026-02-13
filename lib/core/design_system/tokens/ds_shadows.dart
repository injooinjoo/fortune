import 'package:flutter/material.dart';
import 'ds_colors.dart';

/// Claude-inspired Modern shadow system
///
/// Design Philosophy: Soft, Diffuse, Multi-layered Depth
///
/// Key Principles:
/// - Low Opacity: 2%-8% black (very subtle)
/// - Large Blur Radius: 8px-32px (soft edges)
/// - No Hard Edges: Natural shadow diffusion
/// - Dark Mode: Use borders instead of shadows
///
/// Claude shadow formula:
/// ```css
/// box-shadow: 0 0.25rem 1.25rem rgba(0,0,0,0.035);
/// /* = 0 4px 20px 3.5% black */
/// ```
///
/// Usage:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     boxShadow: DSShadows.card,
///   ),
/// )
/// // or use decoration builder
/// Container(
///   decoration: DSShadows.cardDecoration(),
/// )
/// ```
class DSShadows {
  DSShadows._();

  // ============================================
  // CLAUDE-STYLE SOFT SHADOWS (Light Mode)
  // Low opacity + Large blur radius
  // ============================================

  /// Extra small shadow - neutralized (flat design, no shadows)
  /// Use for: Subtle elevation, hover states
  static List<BoxShadow> get xs => [];

  /// Small shadow - neutralized (flat design, no shadows)
  /// Use for: Buttons, small cards
  static List<BoxShadow> get sm => [];

  /// Medium shadow - neutralized (flat design, no shadows)
  /// Use for: Standard cards, elevated content
  static List<BoxShadow> get md => [];

  /// Card shadow alias - same as md (Claude's main card shadow)
  static List<BoxShadow> get card => md;

  /// Large shadow - neutralized (flat design, no shadows)
  /// Use for: Hover states, elevated cards
  static List<BoxShadow> get lg => [];

  /// Extra large shadow - neutralized (flat design, no shadows)
  /// Use for: Modals, popovers
  static List<BoxShadow> get xl => [];

  /// 2XL shadow - neutralized (flat design, no shadows)
  /// Use for: Large modals, full-page overlays
  static List<BoxShadow> get xxl => [];

  // ============================================
  // DARK MODE SHADOWS
  // In dark mode, Claude uses borders instead of shadows
  // But we provide softer dark shadows for compatibility
  // ============================================

  /// Extra small shadow dark - neutralized (flat design, no shadows)
  static List<BoxShadow> get xsDark => [];

  /// Small shadow dark - neutralized (flat design, no shadows)
  static List<BoxShadow> get smDark => [];

  /// Medium shadow dark - neutralized (flat design, no shadows)
  static List<BoxShadow> get mdDark => [];

  /// Card shadow dark alias
  static List<BoxShadow> get cardDark => mdDark;

  /// Large shadow dark - neutralized (flat design, no shadows)
  static List<BoxShadow> get lgDark => [];

  /// Extra large shadow dark - neutralized (flat design, no shadows)
  static List<BoxShadow> get xlDark => [];

  /// 2XL shadow dark - neutralized (flat design, no shadows)
  static List<BoxShadow> get xxlDark => [];

  /// No shadow
  static List<BoxShadow> get none => [];

  // ============================================
  // DECORATION BUILDERS
  // Claude-style clean card decorations
  // ============================================

  /// Standard card decoration (light mode)
  /// Flat design with border only, no shadows
  static BoxDecoration cardDecoration({
    Color? backgroundColor,
    double borderRadius = 16,
    List<BoxShadow>? shadow,
  }) =>
      BoxDecoration(
        color: backgroundColor ?? DSColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: DSColors.border.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [],
      );

  /// Card decoration for dark mode
  /// Flat design with border only, no shadows
  static BoxDecoration cardDecorationDark({
    Color? backgroundColor,
    double borderRadius = 16,
    List<BoxShadow>? shadow,
    bool useBorder = true,
  }) =>
      BoxDecoration(
        color: backgroundColor ?? DSColors.surfaceDark,
        borderRadius: BorderRadius.circular(borderRadius),
        border: useBorder
            ? Border.all(
                color: DSColors.borderDark.withValues(alpha: 0.5),
                width: 1,
              )
            : null,
        boxShadow: [],
      );

  /// Elevated card decoration - flat design with border only
  static BoxDecoration elevatedDecoration({
    Color? backgroundColor,
    double borderRadius = 16,
  }) =>
      BoxDecoration(
        color: backgroundColor ?? DSColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: DSColors.border.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [],
      );

  /// Modal decoration - flat design, no shadows
  static BoxDecoration modalDecoration({
    Color? backgroundColor,
    double borderRadius = 28,
  }) =>
      BoxDecoration(
        color: backgroundColor ?? DSColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [],
      );

  /// Subtle decoration - flat design, no shadows
  static BoxDecoration subtleDecoration({
    Color? backgroundColor,
    double borderRadius = 12,
  }) =>
      BoxDecoration(
        color: backgroundColor ?? DSColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [],
      );

  // ============================================
  // THEME-AWARE GETTERS
  // ============================================

  static List<BoxShadow> getXs(Brightness brightness) =>
      brightness == Brightness.dark ? xsDark : xs;

  static List<BoxShadow> getSm(Brightness brightness) =>
      brightness == Brightness.dark ? smDark : sm;

  static List<BoxShadow> getMd(Brightness brightness) =>
      brightness == Brightness.dark ? mdDark : md;

  static List<BoxShadow> getCard(Brightness brightness) =>
      brightness == Brightness.dark ? cardDark : card;

  static List<BoxShadow> getLg(Brightness brightness) =>
      brightness == Brightness.dark ? lgDark : lg;

  static List<BoxShadow> getXl(Brightness brightness) =>
      brightness == Brightness.dark ? xlDark : xl;

  static List<BoxShadow> getXxl(Brightness brightness) =>
      brightness == Brightness.dark ? xxlDark : xxl;

  /// Get card decoration based on brightness
  static BoxDecoration getCardDecoration(
    Brightness brightness, {
    Color? backgroundColor,
    double borderRadius = 16,
  }) =>
      brightness == Brightness.dark
          ? cardDecorationDark(
              backgroundColor: backgroundColor,
              borderRadius: borderRadius,
            )
          : cardDecoration(
              backgroundColor: backgroundColor,
              borderRadius: borderRadius,
            );
}

/// Theme-aware shadow accessor
class DSShadowScheme {
  final Brightness brightness;

  const DSShadowScheme(this.brightness);

  bool get isDark => brightness == Brightness.dark;

  // Clean shadows
  List<BoxShadow> get xs => isDark ? DSShadows.xsDark : DSShadows.xs;
  List<BoxShadow> get sm => isDark ? DSShadows.smDark : DSShadows.sm;
  List<BoxShadow> get md => isDark ? DSShadows.mdDark : DSShadows.md;
  List<BoxShadow> get card => isDark ? DSShadows.cardDark : DSShadows.card;
  List<BoxShadow> get lg => isDark ? DSShadows.lgDark : DSShadows.lg;
  List<BoxShadow> get xl => isDark ? DSShadows.xlDark : DSShadows.xl;
  List<BoxShadow> get xxl => isDark ? DSShadows.xxlDark : DSShadows.xxl;
  List<BoxShadow> get none => DSShadows.none;

  // Semantic shadow accessors - neutralized (flat design, no shadows)
  BoxShadow get cardShadow => const BoxShadow(color: Color(0x00000000));
  BoxShadow get modalShadow => const BoxShadow(color: Color(0x00000000));
  BoxShadow get toastShadow => const BoxShadow(color: Color(0x00000000));
  BoxShadow get dropdownShadow => const BoxShadow(color: Color(0x00000000));

  // List accessors for semantic shadows
  List<BoxShadow> get modal => xl;
  List<BoxShadow> get toast => md;
  List<BoxShadow> get dropdown => lg;

  // Decoration builders
  BoxDecoration cardDecoration({
    Color? backgroundColor,
    double borderRadius = 16,
  }) =>
      isDark
          ? DSShadows.cardDecorationDark(
              backgroundColor: backgroundColor,
              borderRadius: borderRadius,
            )
          : DSShadows.cardDecoration(
              backgroundColor: backgroundColor,
              borderRadius: borderRadius,
            );
}
