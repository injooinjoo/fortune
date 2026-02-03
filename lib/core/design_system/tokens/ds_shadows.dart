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

  /// Extra small shadow - 2% black, 8px blur
  /// Use for: Subtle elevation, hover states
  static List<BoxShadow> get xs => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  /// Small shadow - 3% black, 12px blur
  /// Use for: Buttons, small cards
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          offset: const Offset(0, 3),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];

  /// Medium shadow - 3.5% black, 20px blur (Claude card shadow)
  /// Use for: Standard cards, elevated content
  /// This is the signature Claude shadow
  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.035),
          offset: const Offset(0, 4),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  /// Card shadow alias - same as md (Claude's main card shadow)
  static List<BoxShadow> get card => md;

  /// Large shadow - 5% black, 24px blur
  /// Use for: Hover states, elevated cards
  static List<BoxShadow> get lg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          offset: const Offset(0, 6),
          blurRadius: 24,
          spreadRadius: 0,
        ),
      ];

  /// Extra large shadow - 8% black, 32px blur
  /// Use for: Modals, popovers
  static List<BoxShadow> get xl => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          offset: const Offset(0, 8),
          blurRadius: 32,
          spreadRadius: 0,
        ),
      ];

  /// 2XL shadow - 10% black, 40px blur
  /// Use for: Large modals, full-page overlays
  static List<BoxShadow> get xxl => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          offset: const Offset(0, 12),
          blurRadius: 40,
          spreadRadius: 0,
        ),
      ];

  // ============================================
  // DARK MODE SHADOWS
  // In dark mode, Claude uses borders instead of shadows
  // But we provide softer dark shadows for compatibility
  // ============================================

  /// Extra small shadow dark
  static List<BoxShadow> get xsDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  /// Small shadow dark
  static List<BoxShadow> get smDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.20),
          offset: const Offset(0, 3),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];

  /// Medium shadow dark
  static List<BoxShadow> get mdDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          offset: const Offset(0, 4),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  /// Card shadow dark alias
  static List<BoxShadow> get cardDark => mdDark;

  /// Large shadow dark
  static List<BoxShadow> get lgDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.30),
          offset: const Offset(0, 6),
          blurRadius: 24,
          spreadRadius: 0,
        ),
      ];

  /// Extra large shadow dark
  static List<BoxShadow> get xlDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          offset: const Offset(0, 8),
          blurRadius: 32,
          spreadRadius: 0,
        ),
      ];

  /// 2XL shadow dark
  static List<BoxShadow> get xxlDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.40),
          offset: const Offset(0, 12),
          blurRadius: 40,
          spreadRadius: 0,
        ),
      ];

  // ============================================
  // LEGACY COMPATIBILITY
  // Old ink-wash names map to new clean shadows
  // ============================================

  /// @deprecated Use [xs] instead
  static List<BoxShadow> get inkWashXs => xs;

  /// @deprecated Use [sm] instead
  static List<BoxShadow> get inkWashSm => sm;

  /// @deprecated Use [md] instead
  static List<BoxShadow> get inkWash => md;

  /// @deprecated Use [md] instead
  static List<BoxShadow> get inkWashMd => md;

  /// @deprecated Use [lg] instead
  static List<BoxShadow> get inkWashLg => lg;

  /// @deprecated Use [xsDark] instead
  static List<BoxShadow> get inkWashXsDark => xsDark;

  /// @deprecated Use [smDark] instead
  static List<BoxShadow> get inkWashSmDark => smDark;

  /// @deprecated Use [mdDark] instead
  static List<BoxShadow> get inkWashDark => mdDark;

  /// @deprecated Use [mdDark] instead
  static List<BoxShadow> get inkWashMdDark => mdDark;

  /// @deprecated Use [lgDark] instead
  static List<BoxShadow> get inkWashLgDark => lgDark;

  /// No shadow
  static List<BoxShadow> get none => [];

  // ============================================
  // DECORATION BUILDERS
  // Claude-style clean card decorations
  // ============================================

  /// Standard card decoration (light mode)
  /// Uses Claude's signature soft shadow
  static BoxDecoration cardDecoration({
    Color? backgroundColor,
    double borderRadius = 16,
    List<BoxShadow>? shadow,
  }) =>
      BoxDecoration(
        color: backgroundColor ?? DSColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadow ?? md,
      );

  /// Card decoration for dark mode
  /// Uses border instead of shadow (Claude pattern)
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
        boxShadow: shadow ?? smDark,
      );

  /// Elevated card decoration
  static BoxDecoration elevatedDecoration({
    Color? backgroundColor,
    double borderRadius = 16,
  }) =>
      BoxDecoration(
        color: backgroundColor ?? DSColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: lg,
      );

  /// Modal decoration
  static BoxDecoration modalDecoration({
    Color? backgroundColor,
    double borderRadius = 28,
  }) =>
      BoxDecoration(
        color: backgroundColor ?? DSColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: xl,
      );

  /// Subtle decoration (minimal shadow for nested content)
  static BoxDecoration subtleDecoration({
    Color? backgroundColor,
    double borderRadius = 12,
  }) =>
      BoxDecoration(
        color: backgroundColor ?? DSColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: xs,
      );

  /// @deprecated Use [cardDecoration] instead
  static BoxDecoration inkWashDecoration({
    Color? backgroundColor,
    double borderRadius = 16,
    double intensity = 0.06,
    double spread = 4,
  }) =>
      cardDecoration(
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
      );

  /// @deprecated Use [cardDecorationDark] instead
  static BoxDecoration inkWashDecorationDark({
    Color? backgroundColor,
    double borderRadius = 16,
    double intensity = 0.25,
    double spread = 4,
  }) =>
      cardDecorationDark(
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
      );

  /// @deprecated Seal decoration - no longer used in modern design
  static BoxDecoration sealDecoration({
    double borderRadius = 12,
    bool isPressed = false,
  }) =>
      BoxDecoration(
        color: isPressed ? DSColors.accentHover : DSColors.accent,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed ? [] : sm,
      );

  /// @deprecated Gold decoration - no longer used in modern design
  static BoxDecoration goldAccentDecoration({
    double borderRadius = 16,
  }) =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: DSColors.warning.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: sm,
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

  /// @deprecated Use [getMd] instead
  static List<BoxShadow> getInkWash(Brightness brightness) =>
      getMd(brightness);

  /// @deprecated Use theme-aware card decoration
  static BoxDecoration getInkWashDecoration(
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

  // Legacy compatibility (ink-wash)
  List<BoxShadow> get inkWashXs => xs;
  List<BoxShadow> get inkWashSm => sm;
  List<BoxShadow> get inkWash => md;
  List<BoxShadow> get inkWashMd => md;
  List<BoxShadow> get inkWashLg => lg;

  // Semantic shadow accessors (first shadow for single-shadow use)
  BoxShadow get cardShadow => card.first;
  BoxShadow get modalShadow => xl.first;
  BoxShadow get toastShadow => md.first;
  BoxShadow get dropdownShadow => lg.first;

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
