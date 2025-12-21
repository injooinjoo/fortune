import 'package:flutter/material.dart';
import 'package:fortune/core/theme/fortune_design_system.dart';

class AppColors {
  // Redirect all colors to TossDesignSystem for consistency
  
  // Primary brand colors - Using Toss Design System
  static const Color tossBlue = TossDesignSystem.tossBlue;
  static const Color tossBlueDark = TossDesignSystem.tossBlue; // Use same blue
  static const Color tossBlueLight = TossDesignSystem.tossBlue;
  static const Color tossBlueBackground = TossDesignSystem.gray50;
  static const Color tossBluePale = TossDesignSystem.gray50;
  
  // Toss-style UI colors - Using Toss Design System
  static const Color tossBackground = TossDesignSystem.gray50;
  static const Color tossBackgroundDark = TossDesignSystem.grayDark900;
  static const Color tossCardBackground = TossDesignSystem.surfacePrimary;
  static const Color tossCardBackgroundDark = TossDesignSystem.grayDark800;
  static const Color tossTextPrimary = TossDesignSystem.gray900;
  static const Color tossTextPrimaryDark = TossDesignSystem.surfacePrimary;
  static const Color tossTextSecondary = TossDesignSystem.gray600;
  static const Color tossTextSecondaryDark = TossDesignSystem.gray400;
  static const Color tossIconBackground = TossDesignSystem.gray100;
  static const Color tossIconBackgroundDark = TossDesignSystem.grayDark700;
  static const Color tossBorder = TossDesignSystem.gray200;
  static const Color tossBorderDark = TossDesignSystem.grayDark600;
  static const Color tossArrow = TossDesignSystem.gray400;
  static const Color tossArrowDark = TossDesignSystem.gray600;
  
  // Primary colors - Using Toss Design System
  static const Color primary = TossDesignSystem.tossBlue;
  static const Color primaryLight = TossDesignSystem.tossBlue;
  static const Color primaryDark = TossDesignSystem.tossBlue;
  
  // Primary colors for dark mode
  static const Color primaryDarkMode = TossDesignSystem.tossBlue;
  static const Color primaryLightDarkMode = TossDesignSystem.tossBlue;
  static const Color primaryDarkDarkMode = TossDesignSystem.tossBlue;
  
  // Secondary colors - Instagram accent colors (same for both themes,
  static const Color secondary = Color(0xFFF56040); // Instagram orange
  static const Color secondaryLight = Color(0xFFFD1D1D); // Instagram red
  static const Color secondaryDark = Color(0xFFE1306C); // Instagram magenta
  
  // Background colors - Using Toss Design System
  static const Color background = TossDesignSystem.gray50;
  static const Color backgroundDark = TossDesignSystem.grayDark900;
  static const Color surface = TossDesignSystem.surfacePrimary;
  static const Color surfaceDark = TossDesignSystem.grayDark800;
  
  // Card design system colors
  static const Color cardBackground = TossDesignSystem.gray50;
  static const Color cardBackgroundDark = TossDesignSystem.grayDark900;
  static const Color cardSurface = TossDesignSystem.surfacePrimary;
  static const Color cardSurfaceDark = TossDesignSystem.grayDark800;
  
  // Text colors - Using Toss Design System
  static const Color textPrimary = TossDesignSystem.gray900;
  static const Color textPrimaryDark = TossDesignSystem.gray50;
  static const Color textPrimaryDark70 = TossDesignSystem.gray200;
  static const Color textSecondary = TossDesignSystem.gray600;
  static const Color textSecondaryDark = TossDesignSystem.gray400;
  static const Color textLight = TossDesignSystem.gray400;
  static const Color textLightDark = TossDesignSystem.gray500;
  static const Color textDark = TossDesignSystem.surfacePrimary;
  static const Color onSurface = textPrimary; // Alias for Material compatibility
  static const Color onSurfaceDark = textPrimaryDark; // Alias for dark mode
  
  // Status colors
  static const Color success = Color(0xFF28A745);
  static const Color successDark = Color(0xFF34D399); // Lighter green for dark mode
  static const Color error = Color(0xFFDC3545);
  static const Color errorDark = Color(0xFFF87171); // Lighter red for dark mode
  static const Color warning = Color(0xFFFFC107);
  static const Color warningDark = Color(0xFFFBBF24); // Lighter yellow for dark mode
  static const Color info = Color(0xFF17A2B8);
  static const Color infoDark = Color(0xFF60A5FA); // Lighter blue for dark mode
  
  // Gray scale - Using Toss Design System
  static const Color gray50 = TossDesignSystem.gray50;
  static const Color gray100 = TossDesignSystem.gray100;
  static const Color gray200 = TossDesignSystem.gray200;
  static const Color gray300 = TossDesignSystem.gray300;
  static const Color gray400 = TossDesignSystem.gray400;
  static const Color gray500 = TossDesignSystem.gray500;
  static const Color gray600 = TossDesignSystem.gray600;
  static const Color gray700 = TossDesignSystem.gray700;
  static const Color gray800 = TossDesignSystem.gray800;
  static const Color gray900 = TossDesignSystem.gray900;
  
  // Semantic colors - Clear purpose-driven colors
  static const Color positive = Color(0xFF00D67A); // Success green
  static const Color positiveDark = Color(0xFF00B865);
  static const Color negative = Color(0xFFFF3B30); // Error/danger red
  static const Color negativeDark = Color(0xFFFF6B66);
  static const Color caution = Color(0xFFFFB800); // Warning yellow
  static const Color cautionDark = Color(0xFFFFCC33);
  static const Color informative = Color(0xFF0064FF); // Info blue (same as tossBlue,
  static const Color informativeDark = Color(0xFF3384FF);
  
  // Other colors
  static const Color divider = TossDesignSystem.gray200;
  static const Color dividerDark = TossDesignSystem.grayDark700;
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);
  static const Color transparent = Colors.transparent;
  
  // Monochrome theme colors - Using Toss grays
  static const Color mysticalPurple = TossDesignSystem.gray600;
  static const Color mysticalPurpleLight = TossDesignSystem.gray500;
  static const Color mysticalPurpleDark = TossDesignSystem.gray700;
  static const Color mysticalPurpleDarkMode = TossDesignSystem.gray400;
  static const Color mysticalPurpleLightDarkMode = TossDesignSystem.gray300;
  static const Color mysticalPurpleDarkDarkMode = TossDesignSystem.gray500;
  static const Color starGold = TossDesignSystem.warningOrange;
  static const Color starGoldDark = TossDesignSystem.warningOrange;
  
  // Monochrome gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF000000), // Black
      Color(0xFF333333), // Dark gray
      Color(0xFF666666), // Medium gray
    ]);
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A1A), // Very dark gray
      Color(0xFF4A4A4A), // Medium gray
    ]);
  
  // Monochrome gradient for backgrounds
  static const LinearGradient instagramGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF000000), // Black
      Color(0xFF2C2C2C), // Dark gray
      Color(0xFF4A4A4A), // Medium gray
      Color(0xFF666666), // Light gray
    ]);
  
  static const LinearGradient instagramGradientLight = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFFE0E0E0), // Light gray
      Color(0xFFCCCCCC), // Lighter gray
      Color(0xFFB8B8B8), // Even lighter gray
    ]);
  
  // Keep mystical gradient for backwards compatibility
  static const LinearGradient mysticalGradient = instagramGradient;
  static const LinearGradient mysticalGradientLight = instagramGradientLight;
  
  // Social login button colors
  static const Color googleButton = Color(0xFFFFFFFF);
  static const Color appleButton = Color(0xFF000000);
  static const Color kakaoButton = Color(0xFFFEE500);
  static const Color naverButton = Color(0xFF03C75A);
  
  // Instagram-style UI elements
  static const Color storyBorder = Color(0xFFE1306C); // Instagram story ring
  static const Color heartRed = Color(0xFFED4956); // Instagram heart
  static const Color linkBlue = Color(0xFF3897F0); // Instagram link blue
  
  // Additional colors for compatibility
  static const Color border = divider;
  static const Color text = textPrimary;
  
  // Eventbrite-style colors
  static const Color eventbriteBackground = Color(0xFFF5F5F0); // Light beige background
  static const Color eventbriteBackgroundDark = Color(0xFF1E1E1E); // Dark background
  static const Color eventbriteButtonBackground = Color(0xFFFFFFFF); // White button
  static const Color eventbriteButtonText = Color(0xFF1E0A3C); // Dark purple text
  static const Color eventbriteButtonBorder = Color(0xFFDBDAE3); // Light gray border
  static const Color eventbriteLink = Color(0xFF3659E3); // Blue link color
  
  // Toss-style semantic getters
  static Color getTossBlue(BuildContext context) {
    return getThemedColor(context, tossBlue, tossBlueLight);
  }
  
  static Color getPositive(BuildContext context) {
    return getThemedColor(context, positive, positiveDark);
  }
  
  static Color getNegative(BuildContext context) {
    return getThemedColor(context, negative, negativeDark);
  }
  
  static Color getCaution(BuildContext context) {
    return getThemedColor(context, caution, cautionDark);
  }
  
  static Color getGray(BuildContext context, int shade) {
    switch (shade) {
      case 50: return getThemedColor(context, gray50, gray900);
      case 100: return getThemedColor(context, gray100, gray800);
      case 200: return getThemedColor(context, gray200, gray700);
      case 300: return getThemedColor(context, gray300, gray600);
      case 400: return getThemedColor(context, gray400, gray500);
      case 500: return getThemedColor(context, gray500, gray400);
      case 600: return getThemedColor(context, gray600, gray300);
      case 700: return getThemedColor(context, gray700, gray200);
      case 800: return getThemedColor(context, gray800, gray100);
      case 900: return getThemedColor(context, gray900, gray50);
      default: return getThemedColor(context, gray500, gray400);
    }
  }
  
  // Dark mode helper methods
  static Color getThemedColor(BuildContext context, Color lightColor, Color darkColor) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? darkColor : lightColor;
  }
  
  static Color getPrimary(BuildContext context) {
    return getThemedColor(context, primary, primaryDarkMode);
  }
  
  static Color getBackground(BuildContext context) {
    return getThemedColor(context, background, backgroundDark);
  }
  
  static Color getSurface(BuildContext context) {
    return getThemedColor(context, surface, surfaceDark);
  }
  
  static Color getCardBackground(BuildContext context) {
    return getThemedColor(context, cardBackground, cardBackgroundDark);
  }
  
  static Color getCardSurface(BuildContext context) {
    return getThemedColor(context, cardSurface, cardSurfaceDark);
  }
  
  static Color getTextPrimary(BuildContext context) {
    return getThemedColor(context, textPrimary, textPrimaryDark);
  }
  
  static Color getTextSecondary(BuildContext context) {
    return getThemedColor(context, textSecondary, textSecondaryDark);
  }
  
  static Color getDivider(BuildContext context) {
    return getThemedColor(context, divider, dividerDark);
  }
  
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  // Toss-style helper methods
  static Color getTossBackground(BuildContext context) {
    return getThemedColor(context, tossBackground, tossBackgroundDark);
  }
  
  static Color getAppCardBackground(BuildContext context) {
    return getThemedColor(context, tossCardBackground, tossCardBackgroundDark);
  }
  
  static Color getTossTextPrimary(BuildContext context) {
    return getThemedColor(context, tossTextPrimary, tossTextPrimaryDark);
  }
  
  static Color getTossTextSecondary(BuildContext context) {
    return getThemedColor(context, tossTextSecondary, tossTextSecondaryDark);
  }
  
  static Color getTossIconBackground(BuildContext context) {
    return getThemedColor(context, tossIconBackground, tossIconBackgroundDark);
  }
  
  static Color getTossBorder(BuildContext context) {
    return getThemedColor(context, tossBorder, tossBorderDark);
  }
  
  static Color getTossArrow(BuildContext context) {
    return getThemedColor(context, tossArrow, tossArrowDark);
  }
}