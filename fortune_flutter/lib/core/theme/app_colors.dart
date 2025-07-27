import 'package:flutter/material.dart';

class AppColors {
  // Monochrome theme colors with dark mode support
  
  // Primary colors - Black and white theme
  static const Color primary = Color(0xFF000000); // Pure black
  static const Color primaryLight = Color(0xFF333333); // Dark gray
  static const Color primaryDark = Color(0xFF1A1A1A); // Very dark gray
  
  // Primary colors for dark mode
  static const Color primaryDarkMode = Color(0xFFFFFFFF); // Pure white for dark mode
  static const Color primaryLightDarkMode = Color(0xFFE0E0E0); // Light gray for dark mode
  static const Color primaryDarkDarkMode = Color(0xFFCCCCCC); // Lighter gray for dark mode
  
  // Secondary colors - Instagram accent colors (same for both themes)
  static const Color secondary = Color(0xFFF56040); // Instagram orange
  static const Color secondaryLight = Color(0xFFFD1D1D); // Instagram red
  static const Color secondaryDark = Color(0xFFE1306C); // Instagram magenta
  
  // Background colors - Clean Instagram style
  static const Color background = Color(0xFFFAFAFA); // Light gray background
  static const Color backgroundDark = Color(0xFF000000); // Pure black for dark mode
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceDark = Color(0xFF121212); // Dark surface
  
  // Card design system colors
  static const Color cardBackground = Color(0xFFF6F6F6); // Light gray background for screens with cards
  static const Color cardBackgroundDark = Color(0xFF0A0A0A); // Very dark background for dark mode
  static const Color cardSurface = Color(0xFFFFFFFF); // White card surface
  static const Color cardSurfaceDark = Color(0xFF1C1C1C); // Dark card surface
  
  // Text colors - Instagram typography
  static const Color textPrimary = Color(0xFF262626); // Instagram black
  static const Color textPrimaryDark = Color(0xFFF5F5F5); // Off-white for dark mode
  static const Color textSecondary = Color(0xFF8E8E8E); // Instagram gray
  static const Color textSecondaryDark = Color(0xFFB0B0B0); // Light gray for dark mode
  static const Color textLight = Color(0xFFC7C7C7); // Light gray
  static const Color textLightDark = Color(0xFF808080); // Medium gray for dark mode
  static const Color textDark = Color(0xFFFFFFFF); // Pure white
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
  
  // Other colors
  static const Color divider = Color(0xFFE9ECEF);
  static const Color dividerDark = Color(0xFF2D2D2D); // Dark divider
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x66000000); // Stronger shadow for dark mode
  static const Color transparent = Colors.transparent;
  
  // Monochrome theme colors
  static const Color mysticalPurple = Color(0xFF4A4A4A); // Medium gray (replacing purple)
  static const Color mysticalPurpleLight = Color(0xFF666666); // Light gray (replacing light purple)
  static const Color mysticalPurpleDark = Color(0xFF2C2C2C); // Dark gray (replacing dark purple)
  static const Color mysticalPurpleDarkMode = Color(0xFF999999); // Light gray for dark mode
  static const Color mysticalPurpleLightDarkMode = Color(0xFFB3B3B3); // Lighter gray for dark mode
  static const Color mysticalPurpleDarkDarkMode = Color(0xFF808080); // Medium gray for dark mode
  static const Color starGold = Color(0xFFE0E0E0); // Light gray (replacing gold)
  static const Color starGoldDark = Color(0xFF666666); // Darker gray for dark mode
  
  // Monochrome gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF000000), // Black
      Color(0xFF333333), // Dark gray
      Color(0xFF666666), // Medium gray
    ],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A1A), // Very dark gray
      Color(0xFF4A4A4A), // Medium gray
    ],
  );
  
  // Monochrome gradient for backgrounds
  static const LinearGradient instagramGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF000000), // Black
      Color(0xFF2C2C2C), // Dark gray
      Color(0xFF4A4A4A), // Medium gray
      Color(0xFF666666), // Light gray
    ],
  );
  
  static const LinearGradient instagramGradientLight = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFFE0E0E0), // Light gray
      Color(0xFFCCCCCC), // Lighter gray
      Color(0xFFB8B8B8), // Even lighter gray
    ],
  );
  
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
}