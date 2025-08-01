import 'package:flutter/material.dart';
import 'package:fortune/core/theme/app_colors.dart';

/// Utility class for fortune-specific colors that are theme-aware
class FortuneColors {
  FortuneColors._();

  // Love-related colors (replacing pink,
  static const Color love = Color(0xFFE91E63); // Material pink
  static const Color loveDark = Color(0xFFFF6090); // Lighter for dark mode
  
  // Spiritual/mystical colors (replacing purple)
  static const Color spiritual = Color(0xFF7C3AED); // Purple
  static const Color spiritualDark = Color(0xFFA78BFA); // Lighter for dark mode
  
  // Energy colors (replacing amber)
  static const Color energy = Color(0xFFF59E0B); // Amber
  static const Color energyDark = Color(0xFFFBBF24); // Lighter for dark mode
  
  // Earth/nature colors (replacing brown)
  static const Color earth = Color(0xFF8B6F47); // Brown
  static const Color earthDark = Color(0xFFBCA08E); // Lighter for dark mode
  
  // Fortune type specific gradients
  static const LinearGradient loveGradient = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFFC2185B)])
    begin: Alignment.topLeft,
    end: Alignment.bottomRight
  );
  
  static const LinearGradient loveGradientDark = LinearGradient(
    colors: [Color(0xFFFF6090), Color(0xFFFF80AB)])
    begin: Alignment.topLeft,
    end: Alignment.bottomRight
  );
  
  static const LinearGradient spiritualGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)])
    begin: Alignment.topLeft,
    end: Alignment.bottomRight
  );
  
  static const LinearGradient spiritualGradientDark = LinearGradient(
    colors: [Color(0xFFA78BFA), Color(0xFFC4B5FD)])
    begin: Alignment.topLeft,
    end: Alignment.bottomRight
  );
  
  static const LinearGradient energyGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)])
    begin: Alignment.topLeft,
    end: Alignment.bottomRight
  );
  
  static const LinearGradient energyGradientDark = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFFCD34D)])
    begin: Alignment.topLeft,
    end: Alignment.bottomRight
  );
  
  static const LinearGradient earthGradient = LinearGradient(
    colors: [Color(0xFF8B6F47), Color(0xFF6F5637)])
    begin: Alignment.topLeft,
    end: Alignment.bottomRight
  );
  
  static const LinearGradient earthGradientDark = LinearGradient(
    colors: [Color(0xFFBCA08E), Color(0xFFD4B5A0)])
    begin: Alignment.topLeft,
    end: Alignment.bottomRight
  );
  
  // Sports team colors (theme-aware)
  static const Color sportsRed = Color(0xFFE53E3E);
  static const Color sportsRedDark = Color(0xFFF56565);
  static const Color sportsBlue = Color(0xFF2B6CB0);
  static const Color sportsBlueDark = Color(0xFF63B3ED);
  static const Color sportsGreen = Color(0xFF48BB78);
  static const Color sportsGreenDark = Color(0xFF68D391);
  
  // Element colors for Saju (Five Elements)
  static const Map<String, Color> elementColors = {
    '목': Color(0xFF48BB78), // Wood - Green
    '화': Color(0xFFE53E3E), // Fire - Red
    '토': Color(0xFFF59E0B), // Earth - Yellow/Amber
    '금': Color(0xFF718096), // Metal - Gray
    '수': Color(0xFF3182CE), // Water - Blue
  };
  
  static const Map<String, Color> elementColorsDark = {
    '목': Color(0xFF68D391), // Wood - Light Green
    '화': Color(0xFFF56565), // Fire - Light Red
    '토': Color(0xFFFBBF24), // Earth - Light Yellow
    '금': Color(0xFFA0AEC0), // Metal - Light Gray
    '수': Color(0xFF63B3ED), // Water - Light Blue
  };
  
  // Helper methods for theme-aware colors
  static Color getLove(BuildContext context) {
    return AppColors.getThemedColor(context, love, loveDark);
  }
  
  static Color getSpiritual(BuildContext context) {
    return AppColors.getThemedColor(context, spiritual, spiritualDark);
  }
  
  static Color getEnergy(BuildContext context) {
    return AppColors.getThemedColor(context, energy, energyDark);
  }
  
  static Color getEarth(BuildContext context) {
    return AppColors.getThemedColor(context, earth, earthDark);
  }
  
  static LinearGradient getLoveGradient(BuildContext context) {
    return AppColors.isDarkMode(context) ? loveGradientDark : loveGradient;
  }
  
  static LinearGradient getSpiritualGradient(BuildContext context) {
    return AppColors.isDarkMode(context) ? spiritualGradientDark : spiritualGradient;
  }
  
  static LinearGradient getEnergyGradient(BuildContext context) {
    return AppColors.isDarkMode(context) ? energyGradientDark : energyGradient;
  }
  
  static LinearGradient getEarthGradient(BuildContext context) {
    return AppColors.isDarkMode(context) ? earthGradientDark : earthGradient;
  }
  
  static Color getSportsRed(BuildContext context) {
    return AppColors.getThemedColor(context, sportsRed, sportsRedDark);
  }
  
  static Color getSportsBlue(BuildContext context) {
    return AppColors.getThemedColor(context, sportsBlue, sportsBlueDark);
  }
  
  static Color getSportsGreen(BuildContext context) {
    return AppColors.getThemedColor(context, sportsGreen, sportsGreenDark);
  }
  
  static Color getElementColor(BuildContext context, String element) {
    final colors = AppColors.isDarkMode(context) ? elementColorsDark : elementColors;
    return colors[element] ?? AppColors.getTextPrimary(context);
  }
  
  // Score-based color selection
  static Color getScoreColor(BuildContext context, int score) {
    if (score >= 80) {
      return AppColors.getThemedColor(context, AppColors.success, AppColors.successDark);
    } else if (score >= 60) {
      return AppColors.getThemedColor(context, AppColors.warning, AppColors.warningDark);
    } else {
      return AppColors.getThemedColor(context, AppColors.error, AppColors.errorDark);
    }
  }
}