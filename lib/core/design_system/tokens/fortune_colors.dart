import 'package:flutter/material.dart';
import '../theme/ds_extensions.dart';
import 'ds_colors.dart';
import 'ds_obangseok_colors.dart';

/// Semantic fortune category colors with theme-aware helpers
/// Enhanced with Korean traditional 오방색 (Five Cardinal Colors)
/// Each color has a clear semantic meaning and purpose
class FortuneColors {
  FortuneColors._();

  // ==================== 오방색 통합 (Korean Traditional Colors) ====================
  // Re-export for convenience
  static const Color cheong = ObangseokColors.cheong; // 목/Wood - 청색
  static const Color jeok = ObangseokColors.jeok; // 화/Fire - 적색
  static const Color hwang = ObangseokColors.hwang; // 토/Earth - 황색
  static const Color baek = ObangseokColors.baek; // 금/Metal - 백색
  static const Color heuk = ObangseokColors.heuk; // 수/Water - 흑색
  static const Color inju = ObangseokColors.inju; // 인주색 (강조)
  static const Color misaek = ObangseokColors.misaek; // 미색 (배경)
  static const Color meok = ObangseokColors.meok; // 먹색

  // Semantic fortune category colors

  // Love & Relationships - Warm, emotional colors
  static const Color love =
      Color(0xFFFF3B57); // Warm red for emotional connections
  static const Color loveDark = Color(0xFFFF6B7A);
  static const Color loveBackground = Color(0xFFFFEEF1);

  // Spiritual & Mystical - Deep, mysterious colors
  static const Color mystical = Color(0xFF9333EA); // Deep purple for spiritual
  static const Color mysticalDark = Color(0xFFB266FF);
  static const Color mysticalLight = Color(0xFFD9B3FF);
  static const Color mysticalBackground = Color(0xFFF3E8FF);
  static const Color spiritualPrimary =
      mystical; // Alias for spiritual primary color
  static const Color spiritualDark =
      mysticalDark; // Alias for spiritual dark color
  static const Color spiritualLight =
      mysticalLight; // Alias for spiritual light color

  // Career & Business - Professional, trustworthy colors
  static const Color career = DSColors.accent; // Using accent for trust
  static const Color careerDark = DSColors.accentSecondary;
  static const Color careerBackground = DSColors.accentLightDark;

  // Financial & Wealth - Gold and prosperity colors
  static const Color wealth = Color(0xFFFFB800); // Bright gold
  static const Color wealthDark = Color(0xFFFFCC33);
  static const Color wealthLight = Color(0xFFFFE066);
  static const Color wealthBackground = Color(0xFFFFF8E6);
  static const Color goldLight = Color(0xFFFFD700); // Light gold color

  // Health & Wellness - Natural, calming colors
  static const Color health = Color(0xFF00D67A); // Fresh green
  static const Color healthDark = Color(0xFF00E887);
  static const Color healthLight = Color(0xFF66FFB3);
  static const Color healthBackground = Color(0xFFE6FFF4);

  // Daily Fortune - Neutral but warm
  static const Color daily = DSColors.textSecondaryDark; // Light mode gray
  static const Color dailyDark = DSColors.textTertiary; // Dark mode gray
  static const Color dailyAccent = DSColors.accent;

  // Fortune intensity levels - For showing strength/quality
  static const Color excellent = DSColors.successDark; // 90-100%
  static const Color good = Color(0xFF00D67A); // 70-89%
  static const Color moderate = DSColors.warningDark; // 50-69%
  static const Color careful = Color(0xFFFF9500); // 30-49%
  static const Color challenging = DSColors.errorDark; // 0-29%

  // Special fortune types
  static const Color tarot = Color(0xFF2D1B69); // Deep mystical purple
  static const Color tarotDark = Color(0xFF4B2D85);
  static const Color tarotDarker = Color(0xFF381F5C); // Darker tarot color
  static const Color tarotDarkest = Color(0xFF1A0F3D); // Darkest tarot color
  static const Color zodiac = Color(0xFF1A237E); // Deep cosmic blue
  static const Color zodiacDark = Color(0xFF3949AB);

  // Helper methods for getting theme-aware colors
  static Color getLove(BuildContext context) {
    return _themed(context, love, loveDark);
  }

  static Color getMystical(BuildContext context) {
    return _themed(context, mystical, mysticalDark);
  }

  static Color getCareer(BuildContext context) {
    return _themed(context, career, careerDark);
  }

  static Color getWealth(BuildContext context) {
    return _themed(context, wealth, wealthDark);
  }

  static Color getHealth(BuildContext context) {
    return _themed(context, health, healthDark);
  }

  static Color getDaily(BuildContext context) {
    return _themed(context, daily, dailyDark);
  }

  static Color getTarot(BuildContext context) {
    return _themed(context, tarot, tarotDark);
  }

  static Color getZodiac(BuildContext context) {
    return _themed(context, zodiac, zodiacDark);
  }

  /// Theme-aware color helper
  static Color _themed(BuildContext context, Color light, Color dark) {
    return context.isDark ? dark : light;
  }

  // Score-based color selection with Toss-style clarity
  static Color getScoreColor(BuildContext context, int score) {
    if (score >= 90) {
      return excellent;
    } else if (score >= 70) {
      return good;
    } else if (score >= 50) {
      return moderate;
    } else if (score >= 30) {
      return careful;
    } else {
      return challenging;
    }
  }

  // Get fortune category color based on type
  static Color getFortuneTypeColor(BuildContext context, String type) {
    switch (type.toLowerCase()) {
      case 'love':
      case 'relationship':
      case 'compatibility':
        return getLove(context);
      case 'career':
      case 'job':
      case 'work':
        return getCareer(context);
      case 'money':
      case 'wealth':
      case 'finance':
        return getWealth(context);
      case 'health':
      case 'wellness':
      case 'sports':
        return getHealth(context);
      case 'spiritual':
      case 'mystical':
      case 'saju':
        return getMystical(context);
      case 'tarot':
        return getTarot(context);
      case 'zodiac':
      case 'astrology':
        return getZodiac(context);
      default:
        return getDaily(context);
    }
  }
}
