import 'package:flutter/material.dart';
import 'ds_colors.dart';

/// Korean Traditional "Saaju" shadow/ink-wash system
///
/// Design Philosophy: Replace drop shadows with ink-wash (번짐) effects
/// that simulate ink bleeding on hanji paper
///
/// Usage:
/// ```dart
/// Container(
///   decoration: DSShadows.inkWashDecoration(),
/// )
/// // or for box shadows only
/// Container(
///   decoration: BoxDecoration(
///     boxShadow: DSShadows.inkWash,
///   ),
/// )
/// ```
class DSShadows {
  DSShadows._();

  // ============================================
  // INK-WASH EFFECTS (Light Mode)
  // Simulates ink bleeding on paper
  // ============================================

  /// Extra subtle ink wash - minimal presence
  static List<BoxShadow> get inkWashXs => [
        BoxShadow(
          color: DSColors.textPrimary.withValues(alpha: 0.06),
          offset: Offset.zero,
          blurRadius: 1,
          spreadRadius: 0,
        ),
      ];

  /// Subtle ink wash - light ink bleed
  static List<BoxShadow> get inkWashSm => [
        BoxShadow(
          color: DSColors.textPrimary.withValues(alpha: 0.08),
          offset: Offset.zero,
          blurRadius: 2,
          spreadRadius: 0,
        ),
      ];

  /// Standard ink wash - default cards
  static List<BoxShadow> get inkWash => [
        BoxShadow(
          color: DSColors.textPrimary.withValues(alpha: 0.10),
          offset: Offset.zero,
          blurRadius: 3,
          spreadRadius: 0,
        ),
      ];

  /// Medium ink wash - elevated elements
  static List<BoxShadow> get inkWashMd => [
        BoxShadow(
          color: DSColors.textPrimary.withValues(alpha: 0.12),
          offset: Offset.zero,
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ];

  /// Large ink wash - prominent elements
  static List<BoxShadow> get inkWashLg => [
        BoxShadow(
          color: DSColors.textPrimary.withValues(alpha: 0.15),
          offset: Offset.zero,
          blurRadius: 6,
          spreadRadius: 0,
        ),
      ];

  // ============================================
  // INK-WASH EFFECTS (Dark Mode)
  // Lighter effect on dark background
  // ============================================

  /// Extra subtle ink wash dark
  static List<BoxShadow> get inkWashXsDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          offset: Offset.zero,
          blurRadius: 1,
          spreadRadius: 0,
        ),
      ];

  /// Subtle ink wash dark
  static List<BoxShadow> get inkWashSmDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.30),
          offset: Offset.zero,
          blurRadius: 2,
          spreadRadius: 0,
        ),
      ];

  /// Standard ink wash dark
  static List<BoxShadow> get inkWashDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          offset: Offset.zero,
          blurRadius: 3,
          spreadRadius: 0,
        ),
      ];

  /// Medium ink wash dark
  static List<BoxShadow> get inkWashMdDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.40),
          offset: Offset.zero,
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ];

  /// Large ink wash dark
  static List<BoxShadow> get inkWashLgDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.45),
          offset: Offset.zero,
          blurRadius: 6,
          spreadRadius: 0,
        ),
      ];

  // ============================================
  // LEGACY SHADOWS (for compatibility)
  // Keeping old shadows for gradual migration
  // ============================================

  static List<BoxShadow> get xs => inkWashXs;
  static List<BoxShadow> get sm => inkWashSm;
  static List<BoxShadow> get md => inkWashMd;
  static List<BoxShadow> get lg => inkWashLg;
  static List<BoxShadow> get xl => inkWashLg;
  static List<BoxShadow> get xxl => inkWashLg;

  static List<BoxShadow> get xsDark => inkWashXsDark;
  static List<BoxShadow> get smDark => inkWashSmDark;
  static List<BoxShadow> get mdDark => inkWashMdDark;
  static List<BoxShadow> get lgDark => inkWashLgDark;
  static List<BoxShadow> get xlDark => inkWashLgDark;
  static List<BoxShadow> get xxlDark => inkWashLgDark;

  /// No shadow
  static List<BoxShadow> get none => [];

  // ============================================
  // DECORATION BUILDERS
  // Complete BoxDecoration with ink-wash effect
  // ============================================

  /// Standard ink-wash card decoration
  static BoxDecoration inkWashDecoration({
    Color? backgroundColor,
    double borderRadius = 8,
    double intensity = 0.10,
    double spread = 3,
  }) =>
      BoxDecoration(
        color: backgroundColor ?? DSColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: DSColors.textPrimary.withValues(alpha: intensity),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: DSColors.textPrimary.withValues(alpha: intensity * 0.5),
            blurRadius: spread,
            spreadRadius: 0,
          ),
        ],
      );

  /// Ink-wash card decoration for dark mode
  static BoxDecoration inkWashDecorationDark({
    Color? backgroundColor,
    double borderRadius = 8,
    double intensity = 0.25,
    double spread = 3,
  }) =>
      BoxDecoration(
        color: backgroundColor ?? DSColors.surfaceDark,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: DSColors.borderDark,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: intensity * 0.5),
            blurRadius: spread,
            spreadRadius: 0,
          ),
        ],
      );

  /// Seal/stamp button decoration (vermilion)
  static BoxDecoration sealDecoration({
    double borderRadius = 4,
    bool isPressed = false,
  }) =>
      BoxDecoration(
        color: isPressed
            ? DSColors.accentSecondaryHover
            : DSColors.accentSecondary,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: DSColors.accentSecondary.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: isPressed
            ? []
            : [
                BoxShadow(
                  color: DSColors.accentSecondary.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      );

  /// Gold accent decoration (for premium elements)
  static BoxDecoration goldAccentDecoration({
    double borderRadius = 8,
  }) =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: DSColors.accentTertiary.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: DSColors.accentTertiary.withValues(alpha: 0.2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      );

  // ============================================
  // THEME-AWARE GETTERS
  // ============================================

  static List<BoxShadow> getXs(Brightness brightness) =>
      brightness == Brightness.dark ? inkWashXsDark : inkWashXs;

  static List<BoxShadow> getSm(Brightness brightness) =>
      brightness == Brightness.dark ? inkWashSmDark : inkWashSm;

  static List<BoxShadow> getMd(Brightness brightness) =>
      brightness == Brightness.dark ? inkWashMdDark : inkWashMd;

  static List<BoxShadow> getLg(Brightness brightness) =>
      brightness == Brightness.dark ? inkWashLgDark : inkWashLg;

  static List<BoxShadow> getXl(Brightness brightness) =>
      brightness == Brightness.dark ? inkWashLgDark : inkWashLg;

  static List<BoxShadow> getXxl(Brightness brightness) =>
      brightness == Brightness.dark ? inkWashLgDark : inkWashLg;

  static List<BoxShadow> getInkWash(Brightness brightness) =>
      brightness == Brightness.dark ? inkWashDark : inkWash;

  static BoxDecoration getInkWashDecoration(
    Brightness brightness, {
    Color? backgroundColor,
    double borderRadius = 8,
  }) =>
      brightness == Brightness.dark
          ? inkWashDecorationDark(
              backgroundColor: backgroundColor,
              borderRadius: borderRadius,
            )
          : inkWashDecoration(
              backgroundColor: backgroundColor,
              borderRadius: borderRadius,
            );
}

/// Theme-aware shadow accessor
class DSShadowScheme {
  final Brightness brightness;

  const DSShadowScheme(this.brightness);

  bool get isDark => brightness == Brightness.dark;

  // Ink-wash shadows
  List<BoxShadow> get inkWashXs =>
      isDark ? DSShadows.inkWashXsDark : DSShadows.inkWashXs;
  List<BoxShadow> get inkWashSm =>
      isDark ? DSShadows.inkWashSmDark : DSShadows.inkWashSm;
  List<BoxShadow> get inkWash =>
      isDark ? DSShadows.inkWashDark : DSShadows.inkWash;
  List<BoxShadow> get inkWashMd =>
      isDark ? DSShadows.inkWashMdDark : DSShadows.inkWashMd;
  List<BoxShadow> get inkWashLg =>
      isDark ? DSShadows.inkWashLgDark : DSShadows.inkWashLg;

  // Legacy compatibility
  List<BoxShadow> get xs => isDark ? DSShadows.xsDark : DSShadows.xs;
  List<BoxShadow> get sm => isDark ? DSShadows.smDark : DSShadows.sm;
  List<BoxShadow> get md => isDark ? DSShadows.mdDark : DSShadows.md;
  List<BoxShadow> get lg => isDark ? DSShadows.lgDark : DSShadows.lg;
  List<BoxShadow> get xl => isDark ? DSShadows.xlDark : DSShadows.xl;
  List<BoxShadow> get xxl => isDark ? DSShadows.xxlDark : DSShadows.xxl;
  List<BoxShadow> get none => DSShadows.none;

  // Semantic shadow accessors
  BoxShadow get card => inkWash.first;
  BoxShadow get modal => inkWashLg.first;
  BoxShadow get toast => inkWashMd.first;
  BoxShadow get dropdown => inkWashMd.first;

  // Decoration builders
  BoxDecoration cardDecoration({Color? backgroundColor, double borderRadius = 8}) =>
      isDark
          ? DSShadows.inkWashDecorationDark(
              backgroundColor: backgroundColor,
              borderRadius: borderRadius,
            )
          : DSShadows.inkWashDecoration(
              backgroundColor: backgroundColor,
              borderRadius: borderRadius,
            );
}
