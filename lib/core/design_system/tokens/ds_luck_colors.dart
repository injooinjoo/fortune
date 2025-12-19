import 'package:flutter/material.dart';

/// Korean Traditional Luck Color System - 행운/길흉 전용 색상
///
/// Design Philosophy: Based on Korean traditional auspicious colors
/// - Primary: 황금색 (Gold) - 복, 재물, 행운
/// - Lucky: 적색 (Red) - 길 (吉), 경사
/// - Unlucky: 흑색 (Black) - 흉 (凶), 주의
///
/// Usage:
/// ```dart
/// Container(color: DSLuckColors.fortuneGold)
/// Container(color: DSLuckColors.getLucky(context.isDark))
/// ```
class DSLuckColors {
  DSLuckColors._();

  // ============================================
  // PRIMARY COLORS (주요 색상) - 황금색 계열
  // Gold represents fortune and prosperity
  // ============================================

  /// Primary fortune gold - 황금색
  static const Color fortuneGold = Color(0xFFB7950B);

  /// Light gold background
  static const Color fortuneGoldLight = Color(0xFFFBF6E3);

  /// Dark gold shade
  static const Color fortuneGoldDark = Color(0xFF8B7209);

  /// Muted gold (for dark mode)
  static const Color fortuneGoldMuted = Color(0xFFD4AF37);

  // ============================================
  // LUCKY COLORS (길 색상) - 적색 계열
  // Red represents good fortune (吉)
  // ============================================

  /// Lucky red - 다홍색 (吉)
  static const Color luckyRed = Color(0xFFB74134);

  /// Light lucky background
  static const Color luckyRedLight = Color(0xFFFBEAE8);

  /// Dark lucky shade
  static const Color luckyRedDark = Color(0xFF8B3229);

  /// Muted lucky (for dark mode)
  static const Color luckyRedMuted = Color(0xFFD4756A);

  // ============================================
  // UNLUCKY COLORS (흉 색상) - 흑색 계열
  // Black represents misfortune (凶)
  // ============================================

  /// Unlucky charcoal - 현무색 (凶)
  static const Color unluckyCharcoal = Color(0xFF3D3D3D);

  /// Light charcoal background
  static const Color unluckyCharcoalLight = Color(0xFFE8E8E8);

  /// Dark charcoal shade
  static const Color unluckyCharcoalDark = Color(0xFF1A1A1A);

  /// Muted charcoal (for dark mode)
  static const Color unluckyCharcoalMuted = Color(0xFF6B6B6B);

  // ============================================
  // SPECIAL LUCK COLORS (특수 행운 색상)
  // For specific fortune types
  // ============================================

  /// Wealth luck - 재물운 (엽전 금색)
  static const Color wealthLuck = Color(0xFFC9A227);

  /// Career luck - 직업운 (관복 청색)
  static const Color careerLuck = Color(0xFF2C4A52);

  /// Health luck - 건강운 (비취 녹색)
  static const Color healthLuck = Color(0xFF38A169);

  /// Love luck - 연애운 (연지 분홍)
  static const Color loveLuck = Color(0xFFD4526E);

  /// Study luck - 학업운 (청출어람 청색)
  static const Color studyLuck = Color(0xFF4A90A4);

  // ============================================
  // PAPER BACKGROUNDS (한지 배경)
  // Fortune-themed hanji colors
  // ============================================

  /// Auspicious hanji - 길한 한지 (따뜻한 크림)
  static const Color hanjiAuspicious = Color(0xFFFDF8E8);

  /// Auspicious hanji dark
  static const Color hanjiAuspiciousDark = Color(0xFF2D2820);

  // ============================================
  // FORTUNE LEVEL COLORS (운세 등급 색상)
  // ============================================

  /// Supreme fortune - 대대길 (大大吉)
  static const Color levelSupreme = Color(0xFFB74134);

  /// Great fortune - 대길 (大吉)
  static const Color levelGreat = Color(0xFFDD6B20);

  /// Good fortune - 길 (吉)
  static const Color levelGood = Color(0xFFB7950B);

  /// Average - 평 (平)
  static const Color levelAverage = Color(0xFF6B8E23);

  /// Small misfortune - 소흉 (小凶)
  static const Color levelSmallBad = Color(0xFF6B6B6B);

  /// Great misfortune - 대흉 (大凶)
  static const Color levelGreatBad = Color(0xFF3D3D3D);

  // ============================================
  // LUCKY ITEM CATEGORY COLORS
  // ============================================

  /// Food category - 음식
  static const Color categoryFood = Color(0xFFDD6B20);

  /// Fashion category - 패션
  static const Color categoryFashion = Color(0xFFD4526E);

  /// Travel category - 여행
  static const Color categoryTravel = Color(0xFF4A90A4);

  /// Number category - 숫자
  static const Color categoryNumber = Color(0xFFB7950B);

  /// Color category - 색상
  static const Color categoryColor = Color(0xFF9B7BB8);

  /// Direction category - 방향
  static const Color categoryDirection = Color(0xFF38A169);

  // ============================================
  // THEME-AWARE GETTERS
  // ============================================

  /// Get gold color based on dark mode
  static Color getGold(bool isDark) =>
      isDark ? fortuneGoldMuted : fortuneGold;

  /// Get gold background based on dark mode
  static Color getGoldBackground(bool isDark) =>
      isDark ? fortuneGoldDark.withValues(alpha: 0.3) : fortuneGoldLight;

  /// Get lucky color based on dark mode
  static Color getLucky(bool isDark) =>
      isDark ? luckyRedMuted : luckyRed;

  /// Get lucky background based on dark mode
  static Color getLuckyBackground(bool isDark) =>
      isDark ? luckyRedDark.withValues(alpha: 0.3) : luckyRedLight;

  /// Get unlucky color based on dark mode
  static Color getUnlucky(bool isDark) =>
      isDark ? unluckyCharcoalMuted : unluckyCharcoal;

  /// Get unlucky background based on dark mode
  static Color getUnluckyBackground(bool isDark) =>
      isDark ? unluckyCharcoalDark.withValues(alpha: 0.3) : unluckyCharcoalLight;

  /// Get hanji background based on dark mode
  static Color getHanjiBackground(bool isDark) =>
      isDark ? hanjiAuspiciousDark : hanjiAuspicious;

  /// Get fortune level color based on score (0-100)
  static Color getLevelColor(int score) {
    if (score >= 95) return levelSupreme;
    if (score >= 80) return levelGreat;
    if (score >= 60) return levelGood;
    if (score >= 40) return levelAverage;
    if (score >= 20) return levelSmallBad;
    return levelGreatBad;
  }

  /// Get fortune level message based on score (Korean)
  static String getLevelMessage(int score) {
    if (score >= 95) return '대대길 (大大吉)';
    if (score >= 80) return '대길 (大吉)';
    if (score >= 60) return '길 (吉)';
    if (score >= 40) return '평 (平)';
    if (score >= 20) return '소흉 (小凶)';
    return '대흉 (大凶)';
  }

  /// Get fortune level Hanja based on score
  static String getLevelHanja(int score) {
    if (score >= 95) return '大大吉';
    if (score >= 80) return '大吉';
    if (score >= 60) return '吉';
    if (score >= 40) return '平';
    if (score >= 20) return '小凶';
    return '大凶';
  }

  /// Get luck type color
  static Color getLuckTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'wealth':
      case '재물':
        return wealthLuck;
      case 'career':
      case '직업':
        return careerLuck;
      case 'health':
      case '건강':
        return healthLuck;
      case 'love':
      case '연애':
        return loveLuck;
      case 'study':
      case '학업':
        return studyLuck;
      default:
        return fortuneGold;
    }
  }

  /// Get category color
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case '음식':
        return categoryFood;
      case 'fashion':
      case '패션':
        return categoryFashion;
      case 'travel':
      case '여행':
        return categoryTravel;
      case 'number':
      case '숫자':
        return categoryNumber;
      case 'color':
      case '색상':
        return categoryColor;
      case 'direction':
      case '방향':
        return categoryDirection;
      default:
        return fortuneGold;
    }
  }
}

/// Theme-aware color accessor for Luck/Fortune
///
/// Usage:
/// ```dart
/// final colors = DSLuckColorScheme(isDark);
/// Container(color: colors.gold)
/// ```
class DSLuckColorScheme {
  final bool isDark;

  const DSLuckColorScheme(this.isDark);

  Color get gold => DSLuckColors.getGold(isDark);
  Color get goldBackground => DSLuckColors.getGoldBackground(isDark);

  Color get lucky => DSLuckColors.getLucky(isDark);
  Color get luckyBackground => DSLuckColors.getLuckyBackground(isDark);

  Color get unlucky => DSLuckColors.getUnlucky(isDark);
  Color get unluckyBackground => DSLuckColors.getUnluckyBackground(isDark);

  Color get hanjiBackground => DSLuckColors.getHanjiBackground(isDark);

  Color levelColor(int score) => DSLuckColors.getLevelColor(score);
  String levelMessage(int score) => DSLuckColors.getLevelMessage(score);
  String levelHanja(int score) => DSLuckColors.getLevelHanja(score);

  Color luckTypeColor(String type) => DSLuckColors.getLuckTypeColor(type);
  Color categoryColor(String category) => DSLuckColors.getCategoryColor(category);
}
