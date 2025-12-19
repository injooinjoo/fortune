import 'package:flutter/material.dart';

/// Korean Traditional Love & Compatibility Color System - 연애/궁합 전용 색상
///
/// Design Philosophy: Based on Korean traditional romantic colors
/// - Primary: 연지색 (Rouge Pink) - 사랑, 열정
/// - Secondary: 분홍 (Peach Pink) - 순수한 사랑
/// - Accent: 산호색 (Coral) - 따뜻한 인연
///
/// Usage:
/// ```dart
/// Container(color: DSLoveColors.rougePink)
/// Container(color: DSLoveColors.getPrimary(context.isDark))
/// ```
class DSLoveColors {
  DSLoveColors._();

  // ============================================
  // PRIMARY COLORS (주요 색상) - 연지색 계열
  // Rouge Pink represents passion and love
  // ============================================

  /// Primary rouge pink - 연지색 (臙脂)
  static const Color rougePink = Color(0xFFD4526E);

  /// Light rouge background
  static const Color rougePinkLight = Color(0xFFF8E8ED);

  /// Dark rouge shade
  static const Color rougePinkDark = Color(0xFF9E3A52);

  /// Muted rouge (for dark mode)
  static const Color rougePinkMuted = Color(0xFFE8A4B8);

  // ============================================
  // SECONDARY COLORS (보조 색상) - 분홍 계열
  // Peach Pink represents pure and gentle love
  // ============================================

  /// Peach pink - 분홍 (桃)
  static const Color peachPink = Color(0xFFF5B7B1);

  /// Light peach background
  static const Color peachPinkLight = Color(0xFFFDF2F1);

  /// Dark peach shade
  static const Color peachPinkDark = Color(0xFFD4918B);

  /// Muted peach (for dark mode)
  static const Color peachPinkMuted = Color(0xFFF0C0BC);

  // ============================================
  // ACCENT COLORS (강조 색상) - 산호색 계열
  // Coral represents warm destiny
  // ============================================

  /// Coral - 산호색
  static const Color coral = Color(0xFFE17055);

  /// Light coral background
  static const Color coralLight = Color(0xFFFBEBE7);

  /// Dark coral shade
  static const Color coralDark = Color(0xFFAD5642);

  /// Muted coral (for dark mode)
  static const Color coralMuted = Color(0xFFEB9178);

  // ============================================
  // YIN-YANG COLORS (음양 색상)
  // For compatibility visualization
  // ============================================

  /// Yang color (Male energy) - 양 (陽)
  static const Color yang = Color(0xFF4A90A4);

  /// Yin color (Female energy) - 음 (陰)
  static const Color yin = Color(0xFFD4526E);

  /// Harmony color - 조화
  static const Color harmony = Color(0xFF9B7BB8);

  // ============================================
  // PAPER BACKGROUNDS (한지 배경)
  // Romantic hanji colors
  // ============================================

  /// Romantic hanji cream - 연분홍 한지
  static const Color hanjiRomantic = Color(0xFFFDF8F6);

  /// Romantic hanji dark
  static const Color hanjiRomanticDark = Color(0xFF2D2528);

  // ============================================
  // COMPATIBILITY LEVEL COLORS (궁합 등급 색상)
  // ============================================

  /// Destined match - 천생연분 (天生緣分)
  static const Color compatibilityDestined = Color(0xFFD4526E);

  /// Great match - 대길 (大吉)
  static const Color compatibilityGreat = Color(0xFFE17055);

  /// Good match - 길 (吉)
  static const Color compatibilityGood = Color(0xFFB7950B);

  /// Average match - 평 (平)
  static const Color compatibilityAverage = Color(0xFF6B6B6B);

  /// Poor match - 상극 (相剋)
  static const Color compatibilityPoor = Color(0xFF4A4A4A);

  // ============================================
  // HEART COLORS (하트 색상)
  // For love-related UI elements
  // ============================================

  /// Full heart - 가득찬 사랑
  static const Color heartFull = Color(0xFFD4526E);

  /// Half heart - 반쪽 사랑
  static const Color heartHalf = Color(0xFFF5B7B1);

  /// Empty heart - 빈 마음
  static const Color heartEmpty = Color(0xFFD4D0C8);

  // ============================================
  // THEME-AWARE GETTERS
  // ============================================

  /// Get primary color based on dark mode
  static Color getPrimary(bool isDark) =>
      isDark ? rougePinkMuted : rougePink;

  /// Get primary background based on dark mode
  static Color getPrimaryBackground(bool isDark) =>
      isDark ? rougePinkDark.withValues(alpha: 0.3) : rougePinkLight;

  /// Get secondary color based on dark mode
  static Color getSecondary(bool isDark) =>
      isDark ? peachPinkMuted : peachPink;

  /// Get secondary background based on dark mode
  static Color getSecondaryBackground(bool isDark) =>
      isDark ? peachPinkDark.withValues(alpha: 0.3) : peachPinkLight;

  /// Get accent color based on dark mode
  static Color getAccent(bool isDark) =>
      isDark ? coralMuted : coral;

  /// Get hanji background based on dark mode
  static Color getHanjiBackground(bool isDark) =>
      isDark ? hanjiRomanticDark : hanjiRomantic;

  /// Get yin color based on dark mode
  static Color getYin(bool isDark) =>
      isDark ? yin.withValues(alpha: 0.9) : yin;

  /// Get yang color based on dark mode
  static Color getYang(bool isDark) =>
      isDark ? yang.withValues(alpha: 0.9) : yang;

  /// Get compatibility color based on score (0-100)
  static Color getCompatibilityColor(int score) {
    if (score >= 90) return compatibilityDestined;
    if (score >= 70) return compatibilityGreat;
    if (score >= 50) return compatibilityGood;
    if (score >= 30) return compatibilityAverage;
    return compatibilityPoor;
  }

  /// Get compatibility message based on score (Korean)
  static String getCompatibilityMessage(int score) {
    if (score >= 90) return '천생연분 (天生緣分)';
    if (score >= 70) return '좋은 인연 (吉緣)';
    if (score >= 50) return '괜찮은 만남 (良緣)';
    if (score >= 30) return '노력이 필요 (努力)';
    return '조심하세요 (相剋)';
  }

  /// Get compatibility Hanja based on score
  static String getCompatibilityHanja(int score) {
    if (score >= 90) return '緣';
    if (score >= 70) return '吉';
    if (score >= 50) return '和';
    if (score >= 30) return '愼';
    return '克';
  }

  /// Get heart fill ratio description
  static String getHeartDescription(int score) {
    if (score >= 80) return '사랑이 넘쳐요';
    if (score >= 60) return '좋은 감정이 있어요';
    if (score >= 40) return '서로 알아가는 중';
    if (score >= 20) return '아직은 조심스러워요';
    return '마음을 열어보세요';
  }
}

/// Theme-aware color accessor for Love/Compatibility
///
/// Usage:
/// ```dart
/// final colors = DSLoveColorScheme(isDark);
/// Container(color: colors.primary)
/// ```
class DSLoveColorScheme {
  final bool isDark;

  const DSLoveColorScheme(this.isDark);

  Color get primary => DSLoveColors.getPrimary(isDark);
  Color get primaryBackground => DSLoveColors.getPrimaryBackground(isDark);

  Color get secondary => DSLoveColors.getSecondary(isDark);
  Color get secondaryBackground => DSLoveColors.getSecondaryBackground(isDark);

  Color get accent => DSLoveColors.getAccent(isDark);

  Color get hanjiBackground => DSLoveColors.getHanjiBackground(isDark);

  Color get yin => DSLoveColors.getYin(isDark);
  Color get yang => DSLoveColors.getYang(isDark);

  Color compatibilityColor(int score) => DSLoveColors.getCompatibilityColor(score);
  String compatibilityMessage(int score) => DSLoveColors.getCompatibilityMessage(score);
  String compatibilityHanja(int score) => DSLoveColors.getCompatibilityHanja(score);
  String heartDescription(int score) => DSLoveColors.getHeartDescription(score);
}
