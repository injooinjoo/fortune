import 'package:flutter/material.dart';

/// Korean Traditional Fortune Color System - 운세 전용 색상
///
/// Design Philosophy: Based on Korean traditional colors for fortune-telling
/// - Primary: 자주색 (Royal Purple) - 신비로운 운세의 분위기
/// - Secondary: 금색 (Gold) - 귀한 운명, 행운
/// - Accent: 먹색 (Ink Black) - 전통 서예, 낙관
///
/// Usage:
/// ```dart
/// Container(color: DSFortuneColors.mysticalPurple)
/// Container(color: DSFortuneColors.getPrimary(context.isDark))
/// ```
class DSFortuneColors {
  DSFortuneColors._();

  // ============================================
  // PRIMARY COLORS (주요 색상) - 자주색 계열
  // Royal Purple represents mystery and fortune
  // ============================================

  /// Primary mystical purple - 자주색
  static const Color mysticalPurple = Color(0xFF5D3A6E);

  /// Light purple background
  static const Color mysticalPurpleLight = Color(0xFFE8DDF0);

  /// Dark purple shade
  static const Color mysticalPurpleDark = Color(0xFF3D2347);

  /// Muted purple (for dark mode)
  static const Color mysticalPurpleMuted = Color(0xFF8B6B9C);

  // ============================================
  // SECONDARY COLORS (보조 색상) - 금색 계열
  // Gold represents fortune and prosperity
  // ============================================

  /// Primary gold - 황금색
  static const Color fortuneGold = Color(0xFFB7950B);

  /// Light gold background
  static const Color fortuneGoldLight = Color(0xFFF5EBCC);

  /// Dark gold shade
  static const Color fortuneGoldDark = Color(0xFF8B7209);

  /// Muted gold (for dark mode)
  static const Color fortuneGoldMuted = Color(0xFFD4AF37);

  // ============================================
  // INK COLORS (먹색 계열)
  // Traditional ink colors for text and decorations
  // ============================================

  /// Primary ink black - 먹색
  static const Color inkBlack = Color(0xFF2C2C2C);

  /// Ink wash light - 담묵
  static const Color inkWashLight = Color(0xFF6B6B6B);

  /// Ink wash guide - 먹 가이드
  static const Color inkWashGuide = Color(0xFFD4C9B8);

  /// Ink for dark mode
  static const Color inkLight = Color(0xFFD4D0C8);

  // ============================================
  // PAPER BACKGROUNDS (한지 배경)
  // ============================================

  /// Hanji cream - 한지 크림색 (light mode)
  static const Color hanjiCream = Color(0xFFF5F0E6);

  /// Hanji dark - 한지 다크모드
  static const Color hanjiDark = Color(0xFF2A2520);

  /// Hanji warm - 따뜻한 한지색
  static const Color hanjiWarm = Color(0xFFF8F3E8);

  // ============================================
  // SEAL STAMP COLORS (낙관 색상)
  // ============================================

  /// Traditional vermilion seal - 다홍 낙관
  static const Color sealVermilion = Color(0xFFB74134);

  /// Gold seal - 금박 낙관
  static const Color sealGold = Color(0xFFB7950B);

  /// Blue seal - 청색 낙관
  static const Color sealBlue = Color(0xFF2C4A52);

  // ============================================
  // FORTUNE RESULT COLORS (운세 결과 색상)
  // ============================================

  /// Great fortune - 대길 (大吉)
  static const Color resultGreatFortune = Color(0xFFB74134);

  /// Good fortune - 길 (吉)
  static const Color resultGoodFortune = Color(0xFFDD6B20);

  /// Neutral - 평 (平)
  static const Color resultNeutral = Color(0xFFB7950B);

  /// Caution - 소흉 (小凶)
  static const Color resultCaution = Color(0xFF6B6B6B);

  /// Bad fortune - 흉 (凶)
  static const Color resultBadFortune = Color(0xFF3D3D3D);

  // ============================================
  // ELEMENT COLORS (오행 색상)
  // Five Elements for Saju/Fortune
  // ============================================

  /// Fire element - 화 (火) - Red
  static const Color elementFire = Color(0xFFB74134);

  /// Wood element - 목 (木) - Blue/Green
  static const Color elementWood = Color(0xFF2C4A52);

  /// Water element - 수 (水) - Black
  static const Color elementWater = Color(0xFF3D3D3D);

  /// Metal element - 금 (金) - White/Gold
  static const Color elementMetal = Color(0xFFB7950B);

  /// Earth element - 토 (土) - Yellow
  static const Color elementEarth = Color(0xFFC9A227);

  // ============================================
  // THEME-AWARE GETTERS
  // ============================================

  /// Get primary color based on dark mode
  static Color getPrimary(bool isDark) =>
      isDark ? mysticalPurpleMuted : mysticalPurple;

  /// Get primary background based on dark mode
  static Color getPrimaryBackground(bool isDark) =>
      isDark ? mysticalPurpleDark.withValues(alpha: 0.3) : mysticalPurpleLight;

  /// Get gold color based on dark mode
  static Color getGold(bool isDark) =>
      isDark ? fortuneGoldMuted : fortuneGold;

  /// Get gold background based on dark mode
  static Color getGoldBackground(bool isDark) =>
      isDark ? fortuneGoldDark.withValues(alpha: 0.3) : fortuneGoldLight;

  /// Get ink color based on dark mode
  static Color getInk(bool isDark) =>
      isDark ? inkLight : inkBlack;

  /// Get ink wash guide based on dark mode
  static Color getInkWashGuide(bool isDark) =>
      isDark ? inkWashLight : inkWashGuide;

  /// Get hanji background based on dark mode
  static Color getHanjiBackground(bool isDark) =>
      isDark ? hanjiDark : hanjiCream;

  /// Get seal color based on dark mode (default vermilion)
  static Color getSealColor(bool isDark) =>
      isDark ? sealVermilion.withValues(alpha: 0.9) : sealVermilion;

  /// Get element color by type
  static Color getElementColor(String element) {
    switch (element.toLowerCase()) {
      case '화':
      case 'fire':
        return elementFire;
      case '목':
      case 'wood':
        return elementWood;
      case '수':
      case 'water':
        return elementWater;
      case '금':
      case 'metal':
        return elementMetal;
      case '토':
      case 'earth':
        return elementEarth;
      default:
        return inkBlack;
    }
  }

  /// Get result color based on fortune level (0-100)
  static Color getResultColor(int score) {
    if (score >= 80) return resultGreatFortune;
    if (score >= 60) return resultGoodFortune;
    if (score >= 40) return resultNeutral;
    if (score >= 20) return resultCaution;
    return resultBadFortune;
  }

  /// Get result message based on score (Korean)
  static String getResultMessage(int score) {
    if (score >= 80) return '대길 (大吉)';
    if (score >= 60) return '길 (吉)';
    if (score >= 40) return '평 (平)';
    if (score >= 20) return '소흉 (小凶)';
    return '흉 (凶)';
  }

  /// Get result Hanja based on score
  static String getResultHanja(int score) {
    if (score >= 80) return '大吉';
    if (score >= 60) return '吉';
    if (score >= 40) return '平';
    if (score >= 20) return '小凶';
    return '凶';
  }
}

/// Theme-aware color accessor for Fortune
///
/// Usage:
/// ```dart
/// final colors = DSFortuneColorScheme(isDark);
/// Container(color: colors.primary)
/// ```
class DSFortuneColorScheme {
  final bool isDark;

  const DSFortuneColorScheme(this.isDark);

  Color get primary => DSFortuneColors.getPrimary(isDark);
  Color get primaryBackground => DSFortuneColors.getPrimaryBackground(isDark);

  Color get gold => DSFortuneColors.getGold(isDark);
  Color get goldBackground => DSFortuneColors.getGoldBackground(isDark);

  Color get ink => DSFortuneColors.getInk(isDark);
  Color get inkWashGuide => DSFortuneColors.getInkWashGuide(isDark);

  Color get hanjiBackground => DSFortuneColors.getHanjiBackground(isDark);
  Color get sealColor => DSFortuneColors.getSealColor(isDark);

  Color elementColor(String element) => DSFortuneColors.getElementColor(element);
  Color resultColor(int score) => DSFortuneColors.getResultColor(score);
  String resultMessage(int score) => DSFortuneColors.getResultMessage(score);
  String resultHanja(int score) => DSFortuneColors.getResultHanja(score);
}
