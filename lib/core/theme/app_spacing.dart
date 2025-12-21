import 'package:flutter/material.dart';
import 'package:fortune/core/theme/fortune_design_system.dart';

/// Spacing system mapped to TossDesignSystem for consistency
class AppSpacing {
  // Base unit
  static const double unit = 4.0;

  // Spacing scale - mapped to TossDesignSystem
  static const double spacing0 = 0; // 0px
  static const double spacing1 = TossDesignSystem.spacingXXS; // 4px
  static const double spacing2 = TossDesignSystem.spacingXS; // 8px
  static const double spacing3 = TossDesignSystem.spacingS; // 12px
  static const double spacing4 = TossDesignSystem.spacingM; // 16px
  static const double spacing5 = TossDesignSystem.spacingL; // 20px
  static const double spacing6 = TossDesignSystem.spacingXL; // 24px
  static const double spacing7 = 28; // 28px - not in TossDesignSystem
  static const double spacing8 = TossDesignSystem.spacingXXL; // 32px
  static const double spacing9 = 36; // 36px - not in TossDesignSystem
  static const double spacing10 = 40; // 40px
  static const double spacing12 = 48; // 48px
  static const double spacing14 = 56; // 56px
  static const double spacing15 = 60; // 60px
  static const double spacing16 = 64; // 64px
  static const double spacing20 = 80; // 80px
  static const double spacing24 = 96; // 96px

  // Additional common spacing values
  static const double spacing60 = spacing15; // 60px
  static const double spacing80 = spacing20; // 80px

  // Semantic spacing - mapped to TossDesignSystem
  static const double none = 0;
  static const double xxxSmall = TossDesignSystem.spacingXXS; // 4px
  static const double xxSmall = TossDesignSystem.spacingXS; // 8px
  static const double xSmall = TossDesignSystem.spacingS; // 12px
  static const double small = TossDesignSystem.spacingM; // 16px
  static const double medium = TossDesignSystem.spacingL; // 20px
  static const double large = TossDesignSystem.spacingXL; // 24px
  static const double xLarge = TossDesignSystem.spacingXXL; // 32px
  static const double xxLarge = 40; // 40px
  static const double xxxLarge = 48; // 48px

  // Component-specific spacing
  static const double cardPadding = spacing4; // 16px
  static const double cardMargin = spacing3; // 12px
  static const double sectionPadding = spacing5; // 20px
  static const double screenPadding = spacing4; // 16px
  static const double screenPaddingTablet = spacing6; // 24px

  static const double buttonPaddingHorizontal = spacing8; // 32px
  static const double buttonPaddingVertical =
      spacing3; // 12px (adjusted for 48px height,
  static const double buttonSpacing = spacing3; // 12px between buttons

  static const double inputPaddingHorizontal = spacing3; // 12px
  static const double inputPaddingVertical = spacing4; // 16px

  static const double listItemPadding = spacing4; // 16px
  static const double listItemSpacing = spacing2; // 8px

  static const double iconTextSpacing = spacing2; // 8px
  static const double labelSpacing = spacing1; // 4px

  // Grid system
  static const double gridGutter = spacing4; // 16px
  static const double gridMarginMobile = spacing4; // 16px
  static const double gridMarginTablet = spacing6; // 24px

  // Safe area additions
  static const double safeAreaAddition = spacing2; // 8px
  static const double bottomNavPadding =
      spacing20; // 80px (for content under bottom nav,

  // Edge Insets helpers
  static const EdgeInsets paddingAll4 = EdgeInsets.all(spacing1);
  static const EdgeInsets paddingAll8 = EdgeInsets.all(spacing2);
  static const EdgeInsets paddingAll12 = EdgeInsets.all(spacing3);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(spacing4);
  static const EdgeInsets paddingAll20 = EdgeInsets.all(spacing5);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(spacing6);

  static const EdgeInsets paddingHorizontal16 =
      EdgeInsets.symmetric(horizontal: spacing4);
  static const EdgeInsets paddingHorizontal24 =
      EdgeInsets.symmetric(horizontal: spacing6);
  static const EdgeInsets paddingVertical8 =
      EdgeInsets.symmetric(vertical: spacing2);
  static const EdgeInsets paddingVertical16 =
      EdgeInsets.symmetric(vertical: spacing4);

  // Common padding patterns
  static const EdgeInsets screenPaddingAll = EdgeInsets.all(screenPadding);
  static const EdgeInsets screenPaddingHorizontal =
      EdgeInsets.symmetric(horizontal: screenPadding);
  static const EdgeInsets cardPaddingAll = EdgeInsets.all(cardPadding);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: buttonPaddingHorizontal,
    vertical: buttonPaddingVertical);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: inputPaddingHorizontal,
    vertical: inputPaddingVertical);

  // Responsive spacing helper
  static double getResponsiveSpacing(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop}) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024 && desktop != null) return desktop;
    if (width >= 600 && tablet != null) return tablet;
    return mobile;
  }

  // Get screen padding based on device size
  static EdgeInsets getScreenPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = width >= 600 ? screenPaddingTablet : screenPadding;
    return EdgeInsets.all(padding);
  }

  // Get horizontal screen padding based on device size
  static EdgeInsets getScreenPaddingHorizontal(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = width >= 600 ? screenPaddingTablet : screenPadding;
    return EdgeInsets.symmetric(horizontal: padding);
  }
}

/// Extension for easy EdgeInsets creation
extension SpacingExtension on double {
  EdgeInsets get all => EdgeInsets.all(this);
  EdgeInsets get horizontal => EdgeInsets.symmetric(horizontal: this);
  EdgeInsets get vertical => EdgeInsets.symmetric(vertical: this);
  EdgeInsets get left => EdgeInsets.only(left: this);
  EdgeInsets get right => EdgeInsets.only(right: this);
  EdgeInsets get top => EdgeInsets.only(top: this);
  EdgeInsets get bottom => EdgeInsets.only(bottom: this);
}

/// Spacing shortcuts for common values
class SpacingShortcuts {
  static const xxs = AppSpacing.xxSmall;
  static const xs = AppSpacing.xSmall;
  static const sm = AppSpacing.small;
  static const md = AppSpacing.medium;
  static const lg = AppSpacing.large;
  static const xl = AppSpacing.xLarge;
  static const xxl = AppSpacing.xxLarge;
  static const xxxl = AppSpacing.xxxLarge;
}

/// Extension to access spacing shortcuts
extension AppSpacingExtension on AppSpacing {
  static double get xxs => AppSpacing.xxSmall;
  static double get xs => AppSpacing.xSmall;
  static double get sm => AppSpacing.small;
  static double get md => AppSpacing.medium;
  static double get lg => AppSpacing.large;
  static double get xl => AppSpacing.xLarge;
  static double get xxl => AppSpacing.xxLarge;
  static double get xxxl => AppSpacing.xxxLarge;
}
