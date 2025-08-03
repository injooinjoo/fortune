import 'package:flutter/material.dart';

class AppColors {
  // Toss-inspired color system with clear semantic meanings
  
  // Primary brand colors - Toss Blue inspired
  static const Color tossBlue = Color(0xFF0064FF); // Toss signature blue
  static const Color tossBlueDark = Color(0xFF0050CC); // Darker for emphasis
  static const Color tossBlueLight = Color(0xFF3384FF); // Lighter for hover states
  static const Color tossBlueBackground = Color(0xFFE6F1FF); // Very light blue for backgrounds
  
  // Primary colors - Black and white theme
  static const Color primary = Color(0xFF000000); // Pure black
  static const Color primaryLight = Color(0xFF333333); // Dark gray
  static const Color primaryDark = Color(0xFF1A1A1A); // Very dark gray
  
  // Primary colors for dark mode
  static const Color primaryDarkMode = Color(0xFFFFFFFF); // Pure white for dark mode
  static const Color primaryLightDarkMode = Color(0xFFE0E0E0); // Light gray for dark mode
  static const Color primaryDarkDarkMode = Color(0xFFCCCCCC); // Lighter gray for dark mode
  
  // Secondary colors - Instagram accent colors (same for both themes,
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
  static const Color textPrimaryDark70 = Color(0xB3F5F5F5); // 70% opacity of textPrimaryDark
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
  
  // Gray scale - Toss-inspired fine-grained grays
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  
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
  static const Color divider = Color(0xFFE9ECEF);
  static const Color dividerDark = Color(0xFF2D2D2D); // Dark divider
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x66000000); // Stronger shadow for dark mode
  static const Color transparent = Colors.transparent;
  
  // Monochrome theme colors
  static const Color mysticalPurple = Color(0xFF4A4A4A); // Medium gray (replacing purple,
  static const Color mysticalPurpleLight = Color(0xFF666666); // Light gray (replacing light purple,
  static const Color mysticalPurpleDark = Color(0xFF2C2C2C); // Dark gray (replacing dark purple,
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
}