import 'package:flutter/material.dart';

/// Modern AI Chat border radius system
///
/// Softer, more rounded corners for modern aesthetics
/// Inspired by Claude/ChatGPT UI patterns
///
/// Usage:
/// ```dart
/// BorderRadius.circular(DSRadius.md)
/// RoundedRectangleBorder(borderRadius: DSRadius.mdBorder)
/// ```
class DSRadius {
  DSRadius._();

  /// 4px - Subtle rounding
  static const double xs = 4.0;

  /// 6px - Light touch (increased from 4px)
  static const double sm = 6.0;

  /// 8px - Small containers, tags, compact elements
  static const double smd = 8.0;

  /// 12px - Standard cards, buttons (increased from 8px)
  static const double md = 12.0;

  /// 16px - Cards, grouped sections
  static const double lg = 16.0;

  /// 24px - Large cards (increased from 20px)
  static const double xl = 24.0;

  /// 28px - Modals, dialogs (increased from 24px)
  static const double xxl = 28.0;

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

  /// smd BorderRadius (8px)
  static BorderRadius get smdBorder => BorderRadius.circular(smd);

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

  /// Button radius (12px) - softer, more modern (increased from 8px)
  static const double button = md;

  /// Input field radius (10px) - slightly softer (increased from 8px)
  static const double input = 10.0;

  /// Card radius (16px)
  static const double card = lg;

  /// Grouped card radius (16px)
  static const double groupedCard = lg;

  /// Modal/dialog radius (28px) - more rounded (increased from 24px)
  static const double modal = xxl;

  /// Bottom sheet top radius (28px)
  static const double bottomSheet = xxl;

  /// Chip/badge radius (full pill)
  static const double chip = full;

  /// Avatar radius (full circle)
  static const double avatar = full;

  /// Toggle track radius (full pill)
  static const double toggle = full;

  /// Tag/compact element radius (8px)
  static const double tag = smd;

  /// Toast radius (12px)
  static const double toast = md;

  /// Message bubble radius (18px) - chat bubble style
  static const double messageBubble = 18.0;

  /// Input area radius (24px) - chat input style
  static const double inputArea = xl;

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

  /// Message bubble BorderRadius
  static BorderRadius get messageBubbleBorder =>
      BorderRadius.circular(messageBubble);

  /// Input area BorderRadius (chat style)
  static BorderRadius get inputAreaBorder => BorderRadius.circular(inputArea);
}
