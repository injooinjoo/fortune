import 'package:flutter/material.dart';
import 'package:fortune/core/theme/fortune_design_system.dart';

/// Dimension constants mapped to TossDesignSystem for consistency
class AppDimensions {
  // Border radius values - mapped to TossDesignSystem
  static const double radiusXxSmall = 4.0; // Very subtle rounding
  static const double radiusXSmall = 6.0; // Minimal rounding
  static const double radiusSmall = TossDesignSystem.radiusS; // 8.0
  static const double radiusMedium = TossDesignSystem.radiusM; // 12.0
  static const double radiusLarge = TossDesignSystem.radiusL; // 16.0
  static const double radiusXLarge = TossDesignSystem.radiusXL; // 20.0
  static const double radiusXxLarge = TossDesignSystem.radiusXL; // Use XL for max
  static const double radiusCircle = 9999.0; // Full circle

  // BorderRadius helpers for backward compatibility
  static BorderRadius get borderRadiusSmall => BorderRadius.circular(radiusSmall);
  static BorderRadius get borderRadiusMedium => BorderRadius.circular(radiusMedium);
  static BorderRadius get borderRadiusLarge => BorderRadius.circular(radiusLarge);

  // Component heights
  static const double buttonHeightLarge = 56.0; // Primary buttons
  static const double buttonHeightMedium = 48.0; // Secondary buttons
  static const double buttonHeightSmall = 40.0; // Text buttons
  static const double buttonHeightXSmall = 32.0; // Chip buttons

  static const double inputHeight = 48.0; // Standard input fields
  static const double inputHeightLarge = 56.0; // Large input fields

  static const double appBarHeight = 56.0; // Standard app bar
  static const double bottomNavHeight = 56.0; // Bottom navigation
  static const double tabBarHeight = 48.0; // Tab bar

  // Icon sizes
  static const double iconSizeXxSmall = 12.0;
  static const double iconSizeXSmall = 16.0;
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0; // Default icon size
  static const double iconSizeLarge = 28.0;
  static const double iconSizeXLarge = 32.0;
  static const double iconSizeXxLarge = 40.0;
  static const double iconSizeXxxLarge = 48.0;

  // Avatar sizes
  static const double avatarSizeXSmall = 24.0;
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 40.0;
  static const double avatarSizeLarge = 56.0;
  static const double avatarSizeXLarge = 72.0;
  static const double avatarSizeXxLarge = 96.0;

  // Touch targets (minimum 44x44 for accessibility,
  static const double touchTargetMinimum = 44.0;
  static const double touchTargetRecommended = 48.0;

  // Card dimensions
  static const double cardElevation = 0.0; // Flat design (Toss style,
  static const double cardBorderWidth = 1.0; // When using borders

  // Divider dimensions
  static const double dividerThickness = 1.0;
  static const double dividerThicknessBold = 2.0;

  // Bottom sheet
  static const double bottomSheetHandleWidth = 40.0;
  static const double bottomSheetHandleHeight = 4.0;
  static const double bottomSheetMinHeight = 200.0;
  static const double bottomSheetMaxHeightRatio = 0.9; // 90% of screen

  // Dialog dimensions
  static const double dialogMaxWidth = 280.0;
  static const double dialogMinHeight = 120.0;

  // Loading indicators
  static const double progressIndicatorSize = 24.0;
  static const double progressIndicatorSizeLarge = 36.0;
  static const double progressIndicatorStrokeWidth = 2.0;

  // FAB (Floating Action Button,
  static const double fabSize = 56.0;
  static const double fabSizeMini = 40.0;

  // Toast/Snackbar
  static const double toastMaxWidth = 344.0;
  static const double toastMinHeight = 48.0;
  static const double toastBottomOffset = 80.0;

  // Skeleton loading
  static const double skeletonHeight = 20.0;
  static const double skeletonHeightSmall = 16.0;
  static const double skeletonHeightLarge = 32.0;

  // Score display
  static const double scoreCircleSize = 120.0;
  static const double scoreCircleSizeSmall = 80.0;
  static const double scoreCircleSizeLarge = 160.0;

  // Grid system
  static const int gridColumns = 12;
  static const double gridGutterWidth = 16.0;

  // Responsive breakpoints
  static const double breakpointMobile = 0.0;
  static const double breakpointTablet = 600.0;
  static const double breakpointDesktop = 1024.0;
  static const double breakpointWide = 1440.0;

  // Animation values
  static const double animationScalePressed = 0.95;
  static const double animationScaleHover = 1.05;

  // Shadow values
  static const double shadowBlurLight = 8.0;
  static const double shadowBlurMedium = 16.0;
  static const double shadowBlurHeavy = 24.0;

  // Helper methods
  static BorderRadius borderRadius(double radius) =>
      BorderRadius.circular(radius);
  static BorderRadius borderRadiusS = BorderRadius.circular(radiusSmall);
  static BorderRadius borderRadiusM = BorderRadius.circular(radiusMedium);
  static BorderRadius borderRadiusL = BorderRadius.circular(radiusLarge);

  static BorderRadius borderRadiusTop(double radius) => BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius));

  static BorderRadius borderRadiusBottom(double radius) => BorderRadius.only(
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius));

  // Device type helpers
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < breakpointTablet;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointTablet && width < breakpointDesktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= breakpointDesktop;

  // Responsive value helper
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop}) {
    final width = MediaQuery.of(context).size.width;
    if (width >= breakpointDesktop && desktop != null) return desktop;
    if (width >= breakpointTablet && tablet != null) return tablet;
    return mobile;
  }
}
