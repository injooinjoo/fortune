import 'package:flutter/material.dart';

/// Korean Traditional "Saaju" border radius system
///
/// Organic, brush-like corners that evoke traditional aesthetics
/// Slightly softer than modern Material design
///
/// Usage:
/// ```dart
/// BorderRadius.circular(DSRadius.md)
/// RoundedRectangleBorder(borderRadius: DSRadius.mdBorder)
/// ```
class DSRadius {
  DSRadius._();

  /// 2px - Subtle rounding
  static const double xs = 2.0;

  /// 4px - Light touch, seal buttons
  static const double sm = 4.0;

  /// 8px - Standard cards, organic feel
  static const double md = 8.0;

  /// 16px - Cards, grouped sections
  static const double lg = 16.0;

  /// 20px - Large cards
  static const double xl = 20.0;

  /// 24px - Modals, dialogs
  static const double xxl = 24.0;

  /// 32px - Extra large modals
  static const double xxxl = 32.0;

  /// 9999px - Pills, circular elements
  static const double full = 9999.0;

  // ============================================
  // BORDER RADIUS PRESETS
  // ============================================

  /// xs BorderRadius
  static BorderRadius get xsBorder => BorderRadius.circular(xs);

  /// sm BorderRadius
  static BorderRadius get smBorder => BorderRadius.circular(sm);

  /// md BorderRadius
  static BorderRadius get mdBorder => BorderRadius.circular(md);

  /// lg BorderRadius
  static BorderRadius get lgBorder => BorderRadius.circular(lg);

  /// xl BorderRadius
  static BorderRadius get xlBorder => BorderRadius.circular(xl);

  /// xxl BorderRadius
  static BorderRadius get xxlBorder => BorderRadius.circular(xxl);

  /// xxxl BorderRadius
  static BorderRadius get xxxlBorder => BorderRadius.circular(xxxl);

  /// Full/pill BorderRadius
  static BorderRadius get fullBorder => BorderRadius.circular(full);

  // ============================================
  // SEMANTIC RADIUS
  // ============================================

  /// Button radius (8px) - organic feel
  static const double button = md;

  /// Seal/stamp button radius (4px) - slightly rounded square like traditional seals (인장)
  static const double seal = sm;

  /// Input field radius (8px)
  static const double input = md;

  /// Card radius (16px)
  static const double card = lg;

  /// Grouped card radius (16px)
  static const double groupedCard = lg;

  /// Modal/dialog radius (24px)
  static const double modal = xxl;

  /// Bottom sheet top radius (24px)
  static const double bottomSheet = xxl;

  /// Chip/badge radius (full pill)
  static const double chip = full;

  /// Avatar radius (full circle)
  static const double avatar = full;

  /// Toggle track radius (full pill)
  static const double toggle = full;

  /// Toast radius (12px)
  static const double toast = md;

  // ============================================
  // BORDER RADIUS SEMANTIC PRESETS
  // ============================================

  /// Button BorderRadius
  static BorderRadius get buttonBorder => BorderRadius.circular(button);

  /// Input BorderRadius
  static BorderRadius get inputBorder => BorderRadius.circular(input);

  /// Card BorderRadius
  static BorderRadius get cardBorder => BorderRadius.circular(card);

  /// Modal BorderRadius
  static BorderRadius get modalBorder => BorderRadius.circular(modal);

  /// Bottom sheet top BorderRadius
  static BorderRadius get bottomSheetBorder => const BorderRadius.vertical(
        top: Radius.circular(bottomSheet),
      );
}
