// ChatGPT-inspired spacing system
//
// Based on 4px base unit with semantic naming
//
// Usage:
// ```dart
// Padding(padding: EdgeInsets.all(DSSpacing.md))
// SizedBox(height: DSSpacing.lg)
// ```
class DSSpacing {
  DSSpacing._();

  /// Base unit (4px)
  static const double base = 4.0;

  /// 2px - Micro spacing
  static const double xxs = 2.0;

  /// 4px - Tight spacing
  static const double xs = 4.0;

  /// 8px - Small spacing
  static const double sm = 8.0;

  /// 16px - Default/Medium spacing
  static const double md = 16.0;

  /// 24px - Large spacing
  static const double lg = 24.0;

  /// 32px - Extra large spacing
  static const double xl = 32.0;

  /// 40px - Section spacing
  static const double xxl = 40.0;

  /// 48px - Large section spacing
  static const double xxxl = 48.0;

  /// 64px - Page level spacing
  static const double xxxxl = 64.0;

  // ============================================
  // SEMANTIC SPACING
  // ============================================

  /// Horizontal page margin (20px)
  static const double pageHorizontal = 20.0;

  /// Vertical page margin (16px)
  static const double pageVertical = 16.0;

  /// Card internal padding (16px)
  static const double cardPadding = 16.0;

  /// Card internal padding large (24px)
  static const double cardPaddingLarge = 24.0;

  /// List item horizontal padding (16px)
  static const double listItemHorizontal = 16.0;

  /// List item vertical padding (16px)
  static const double listItemVertical = 16.0;

  /// Button horizontal padding (24px)
  static const double buttonHorizontal = 24.0;

  /// Button vertical padding (16px)
  static const double buttonVertical = 16.0;

  /// Input horizontal padding (16px)
  static const double inputHorizontal = 16.0;

  /// Input vertical padding (14px)
  static const double inputVertical = 14.0;

  /// Modal padding (24px)
  static const double modalPadding = 24.0;

  /// Bottom sheet padding (20px)
  static const double bottomSheetPadding = 20.0;

  /// Section header top margin (24px)
  static const double sectionHeaderTop = 24.0;

  /// Section header bottom margin (8px)
  static const double sectionHeaderBottom = 8.0;

  /// Gap between inline elements (8px)
  static const double inlineGap = 8.0;

  /// Gap between stacked elements (16px)
  static const double stackGap = 16.0;

  /// Gap between buttons (12px)
  static const double buttonGap = 12.0;

  /// Icon to text gap (12px)
  static const double iconTextGap = 12.0;
}
