import 'package:flutter/material.dart';

/// Korean Traditional Biorhythm Color System - Obangsaek (오방색) based
///
/// Design Philosophy: Each rhythm corresponds to an element from the Five Elements (오행)
/// - Physical (신체): Fire (火/화) - Vermilion Red (다홍색)
/// - Emotional (감정): Wood (木/목) - Indigo (쪽빛)
/// - Intellectual (지적): Water (水/수) - Charcoal Black (현무색)
///
/// Usage:
/// ```dart
/// Container(color: DSBiorhythmColors.physicalPrimary)
/// Container(color: DSBiorhythmColors.getPhysical(context.isDark))
/// ```
class DSBiorhythmColors {
  DSBiorhythmColors._();

  // ============================================
  // PHYSICAL RHYTHM (신체 리듬) - 火 (Fire/불)
  // Vermilion Red (다홍색) represents vitality and energy
  // ============================================

  /// Primary physical color - Dahong (다홍)
  static const Color physicalPrimary = Color(0xFFB74134);

  /// Light physical background
  static const Color physicalLight = Color(0xFFE8D4D0);

  /// Dark physical shade
  static const Color physicalDark = Color(0xFF8B3229);

  /// Physical muted tone (for dark mode)
  static const Color physicalMuted = Color(0xFFD4756A);

  // ============================================
  // EMOTIONAL RHYTHM (감정 리듬) - 木 (Wood/나무)
  // Indigo (쪽빛) represents growth and emotion
  // ============================================

  /// Primary emotional color - Jjokbit (쪽빛)
  static const Color emotionalPrimary = Color(0xFF2C4A52);

  /// Light emotional background
  static const Color emotionalLight = Color(0xFFD4DFE2);

  /// Dark emotional shade
  static const Color emotionalDark = Color(0xFF1A2E34);

  /// Emotional muted tone (for dark mode)
  static const Color emotionalMuted = Color(0xFF5A7A85);

  // ============================================
  // INTELLECTUAL RHYTHM (지적 리듬) - 水 (Water/물)
  // Charcoal Black (현무색) represents wisdom and thought
  // ============================================

  /// Primary intellectual color - Hyeonmu (현무색/먹)
  static const Color intellectualPrimary = Color(0xFF3D3D3D);

  /// Light intellectual background
  static const Color intellectualLight = Color(0xFFE0E0E0);

  /// Dark intellectual shade
  static const Color intellectualDark = Color(0xFF1A1A1A);

  /// Intellectual muted tone (for dark mode)
  static const Color intellectualMuted = Color(0xFF6B6B6B);

  // ============================================
  // BACKGROUND & DECORATION (배경/장식)
  // ============================================

  /// Hanji paper cream - 한지 크림색
  static const Color hanjiCream = Color(0xFFF5F0E6);

  /// Hanji paper dark - 한지 다크모드
  static const Color hanjiDark = Color(0xFF2A2520);

  /// Ink bleed effect - 먹 번짐
  static const Color inkBleed = Color(0xFF2C2C2C);

  /// Ink bleed light (for dark mode) - 먹 번짐 라이트
  static const Color inkBleedLight = Color(0xFFD4D0C8);

  /// Gold accent for seals/stamps - 황금 낙관
  static const Color goldAccent = Color(0xFFB7950B);

  /// Gold accent dark mode
  static const Color goldAccentDark = Color(0xFFD4AF37);

  /// Ink wash guide line - 담묵 가이드
  static const Color inkWashGuide = Color(0xFFD4C9B8);

  /// Ink wash guide dark
  static const Color inkWashGuideDark = Color(0xFF4A4A4A);

  // ============================================
  // STATUS COLORS (상태별 색상)
  // ============================================

  /// Excellent status (80-100) - 왕성한 기운
  static const Color statusExcellent = Color(0xFF38A169);

  /// Good status (60-79) - 양호한 상태
  static const Color statusGood = Color(0xFF2C4A52);

  /// Average status (40-59) - 평균 상태
  static const Color statusAverage = Color(0xFFB7950B);

  /// Low status (20-39) - 주의 필요
  static const Color statusLow = Color(0xFFDD6B20);

  /// Critical status (0-19) - 휴식 필요
  static const Color statusCritical = Color(0xFFB74134);

  // ============================================
  // THEME-AWARE GETTERS
  // ============================================

  /// Get physical color based on dark mode
  static Color getPhysical(bool isDark) =>
      isDark ? physicalMuted : physicalPrimary;

  /// Get physical background based on dark mode
  static Color getPhysicalBackground(bool isDark) =>
      isDark ? physicalDark.withValues(alpha: 0.3) : physicalLight;

  /// Get emotional color based on dark mode
  static Color getEmotional(bool isDark) =>
      isDark ? emotionalMuted : emotionalPrimary;

  /// Get emotional background based on dark mode
  static Color getEmotionalBackground(bool isDark) =>
      isDark ? emotionalDark.withValues(alpha: 0.3) : emotionalLight;

  /// Get intellectual color based on dark mode
  static Color getIntellectual(bool isDark) =>
      isDark ? intellectualMuted : intellectualPrimary;

  /// Get intellectual background based on dark mode
  static Color getIntellectualBackground(bool isDark) =>
      isDark ? intellectualDark.withValues(alpha: 0.3) : intellectualLight;

  /// Get hanji background based on dark mode
  static Color getHanjiBackground(bool isDark) =>
      isDark ? hanjiDark : hanjiCream;

  /// Get ink bleed based on dark mode
  static Color getInkBleed(bool isDark) =>
      isDark ? inkBleedLight : inkBleed;

  /// Get gold accent based on dark mode
  static Color getGoldAccent(bool isDark) =>
      isDark ? goldAccentDark : goldAccent;

  /// Get ink wash guide based on dark mode
  static Color getInkWashGuide(bool isDark) =>
      isDark ? inkWashGuideDark : inkWashGuide;

  /// Get status color based on score (0-100)
  static Color getStatusColor(int score) {
    if (score >= 80) return statusExcellent;
    if (score >= 60) return statusGood;
    if (score >= 40) return statusAverage;
    if (score >= 20) return statusLow;
    return statusCritical;
  }

  /// Get status message based on score (Korean)
  static String getStatusMessage(int score) {
    if (score >= 80) return '왕성한 기운';
    if (score >= 60) return '양호한 상태';
    if (score >= 40) return '평균 상태';
    if (score >= 20) return '주의 필요';
    return '휴식 필요';
  }

  /// Get status Hanja based on score
  static String getStatusHanja(int score) {
    if (score >= 80) return '盛運';
    if (score >= 60) return '順調';
    if (score >= 40) return '平穩';
    if (score >= 20) return '愼重';
    return '休息';
  }
}

/// Theme-aware color accessor for Biorhythm
///
/// Usage with BuildContext extension:
/// ```dart
/// Container(color: context.biorhythmColors.physical)
/// ```
class DSBiorhythmColorScheme {
  final bool isDark;

  const DSBiorhythmColorScheme(this.isDark);

  Color get physical => DSBiorhythmColors.getPhysical(isDark);
  Color get physicalBackground => DSBiorhythmColors.getPhysicalBackground(isDark);

  Color get emotional => DSBiorhythmColors.getEmotional(isDark);
  Color get emotionalBackground => DSBiorhythmColors.getEmotionalBackground(isDark);

  Color get intellectual => DSBiorhythmColors.getIntellectual(isDark);
  Color get intellectualBackground => DSBiorhythmColors.getIntellectualBackground(isDark);

  Color get hanjiBackground => DSBiorhythmColors.getHanjiBackground(isDark);
  Color get inkBleed => DSBiorhythmColors.getInkBleed(isDark);
  Color get goldAccent => DSBiorhythmColors.getGoldAccent(isDark);
  Color get inkWashGuide => DSBiorhythmColors.getInkWashGuide(isDark);

  Color statusColor(int score) => DSBiorhythmColors.getStatusColor(score);
  String statusMessage(int score) => DSBiorhythmColors.getStatusMessage(score);
  String statusHanja(int score) => DSBiorhythmColors.getStatusHanja(score);
}
