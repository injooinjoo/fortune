import 'package:flutter/material.dart';
import '../tokens/ds_colors.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_shadows.dart';
import '../tokens/ds_typography.dart';

/// BuildContext extensions for easy access to design system tokens
///
/// Usage:
/// ```dart
/// // Colors
/// Container(color: context.colors.background)
///
/// // Typography
/// Text('Hello', style: context.typography.bodyMedium)
///
/// // Shadows
/// Container(decoration: BoxDecoration(boxShadow: context.shadows.sm))
///
/// // Convenience
/// if (context.isDark) { ... }
/// ```
extension DSContextExtensions on BuildContext {
  /// Get current brightness
  Brightness get brightness => Theme.of(this).brightness;

  /// Check if dark mode
  bool get isDark => brightness == Brightness.dark;

  /// Check if light mode
  bool get isLight => brightness == Brightness.light;

  /// Theme-aware color scheme
  DSColorScheme get colors => DSColorScheme(brightness);

  /// Typography scheme
  DSTypographyScheme get typography => const DSTypographyScheme();

  /// Theme-aware shadow scheme
  DSShadowScheme get shadows => DSShadowScheme(brightness);

  /// Spacing constants
  DSSpacingScheme get spacing => const DSSpacingScheme();

  /// Radius constants
  DSRadiusScheme get radius => const DSRadiusScheme();
}

/// Spacing scheme wrapper for consistency
class DSSpacingScheme {
  const DSSpacingScheme();

  double get xxs => DSSpacing.xxs;
  double get xs => DSSpacing.xs;
  double get sm => DSSpacing.sm;
  double get md => DSSpacing.md;
  double get lg => DSSpacing.lg;
  double get xl => DSSpacing.xl;
  double get xxl => DSSpacing.xxl;
  double get xxxl => DSSpacing.xxxl;

  double get pageHorizontal => DSSpacing.pageHorizontal;
  double get pageVertical => DSSpacing.pageVertical;
  double get cardPadding => DSSpacing.cardPadding;
  double get listItemHorizontal => DSSpacing.listItemHorizontal;
  double get listItemVertical => DSSpacing.listItemVertical;
  double get modalPadding => DSSpacing.modalPadding;
  double get sectionHeaderTop => DSSpacing.sectionHeaderTop;
  double get sectionHeaderBottom => DSSpacing.sectionHeaderBottom;
  double get buttonGap => DSSpacing.buttonGap;
  double get iconTextGap => DSSpacing.iconTextGap;
}

/// Radius scheme wrapper for consistency
class DSRadiusScheme {
  const DSRadiusScheme();

  double get xs => DSRadius.xs;
  double get sm => DSRadius.sm;
  double get md => DSRadius.md;
  double get lg => DSRadius.lg;
  double get xl => DSRadius.xl;
  double get xxl => DSRadius.xxl;
  double get full => DSRadius.full;

  BorderRadius get xsBorder => DSRadius.xsBorder;
  BorderRadius get smBorder => DSRadius.smBorder;
  BorderRadius get mdBorder => DSRadius.mdBorder;
  BorderRadius get lgBorder => DSRadius.lgBorder;
  BorderRadius get xlBorder => DSRadius.xlBorder;
  BorderRadius get xxlBorder => DSRadius.xxlBorder;
  BorderRadius get fullBorder => DSRadius.fullBorder;

  double get button => DSRadius.button;
  double get input => DSRadius.input;
  double get card => DSRadius.card;
  double get modal => DSRadius.modal;
  double get bottomSheet => DSRadius.bottomSheet;

  BorderRadius get buttonBorder => DSRadius.buttonBorder;
  BorderRadius get inputBorder => DSRadius.inputBorder;
  BorderRadius get cardBorder => DSRadius.cardBorder;
  BorderRadius get modalBorder => DSRadius.modalBorder;
  BorderRadius get bottomSheetBorder => DSRadius.bottomSheetBorder;
}

/// TextStyle extensions for applying colors
extension DSTextStyleExtensions on TextStyle {
  /// Apply primary text color based on context
  TextStyle withPrimary(BuildContext context) => copyWith(
        color: context.colors.textPrimary,
      );

  /// Apply secondary text color based on context
  TextStyle withSecondary(BuildContext context) => copyWith(
        color: context.colors.textSecondary,
      );

  /// Apply tertiary text color based on context
  TextStyle withTertiary(BuildContext context) => copyWith(
        color: context.colors.textTertiary,
      );

  /// Apply accent color based on context
  TextStyle withAccent(BuildContext context) => copyWith(
        color: context.colors.accent,
      );

  /// Apply error color based on context
  TextStyle withError(BuildContext context) => copyWith(
        color: context.colors.error,
      );

  /// Apply success color based on context
  TextStyle withSuccess(BuildContext context) => copyWith(
        color: context.colors.success,
      );

  /// Apply custom color
  TextStyle withColor(Color color) => copyWith(color: color);
}
