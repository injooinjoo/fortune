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
  // CHAT BUBBLE COLORS (채팅 말풍선)
  // Traditional cloud-style chat bubbles
  // ============================================

  /// AI bubble background (light mode) - 따뜻한 크림색
  static const Color aiBubbleLight = Color(0xFFF8F3E8);

  /// AI bubble background (dark mode)
  static const Color aiBubbleDark = Color(0xFF2D2820);

  /// User bubble background (light mode) - 깨끗한 흰색
  static const Color userBubbleLight = Color(0xFFFFFDF8);

  /// User bubble background (dark mode)
  static const Color userBubbleDark = Color(0xFF353535);

  /// Bubble border (light mode) - 담묵 테두리
  static const Color bubbleBorderLight = Color(0xFFD4C9B8);

  /// Bubble border (dark mode)
  static const Color bubbleBorderDark = Color(0xFF4A4540);

  /// Get AI bubble background based on dark mode
  static Color getAiBubbleBackground(bool isDark) =>
      isDark ? aiBubbleDark : aiBubbleLight;

  /// Get user bubble background based on dark mode
  static Color getUserBubbleBackground(bool isDark) =>
      isDark ? userBubbleDark : userBubbleLight;

  /// Get bubble border based on dark mode
  static Color getBubbleBorder(bool isDark) =>
      isDark ? bubbleBorderDark : bubbleBorderLight;

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
  // FORTUNE CATEGORY COLORS (운세 카테고리별 브랜드 색상)
  // Each fortune type has a unique identity color
  // ============================================

  // -- 시간 기반 --
  static const Color categoryDaily = Color(0xFF7C3AED);
  static const Color categoryDailyCalendar = Color(0xFF6366F1);
  static const Color categoryNewYear = Color(0xFFEF4444);

  // -- 연애/관계 --
  static const Color categoryLove = Color(0xFFEC4899);
  static const Color categoryCompatibility = Color(0xFFF43F5E);
  static const Color categoryExLover = Color(0xFF6B7280);
  static const Color categoryYearlyEncounter = Color(0xFFE11D48);
  static const Color categoryBlindDate = Color(0xFFBE185D);
  static const Color categoryAvoidPeople = Color(0xFFDC2626);

  // -- 직업/재능 --
  static const Color categoryCareer = Color(0xFF2563EB);
  static const Color categoryTalent = Color(0xFFFFB300);

  // -- 재물 --
  static const Color categoryMoney = Color(0xFF16A34A);
  static const Color categoryLuckyItems = Color(0xFF8B5CF6);
  static const Color categoryLotto = Color(0xFFF59E0B);

  // -- 전통/신비 --
  static const Color categoryTarot = Color(0xFF9333EA);
  static const Color categoryTraditional = Color(0xFFEF4444);
  static const Color categoryFaceReading = Color(0xFF06B6D4);
  static const Color categoryTalisman = Color(0xFF7C3AED);
  static const Color categoryPastLife = Color(0xFF8B4513);

  // -- 성격/개성 --
  static const Color categoryPersonalityDna = Color(0xFF6366F1);
  static const Color categoryBiorhythm = Color(0xFF0891B2);
  static const Color categoryMbti = Color(0xFF8B5CF6);

  // -- 건강/스포츠 --
  static const Color categoryHealth = Color(0xFF10B981);
  static const Color categoryExercise = Color(0xFFEA580C);
  static const Color categorySportsGame = Color(0xFFDC2626);

  // -- 인터랙티브 --
  static const Color categoryGameEnhance = Color(0xFFFF6B00);
  static const Color categoryDream = Color(0xFF6366F1);
  static const Color categoryWish = Color(0xFFFF4081);
  static const Color categoryFortuneCookie = Color(0xFF9333EA);
  static const Color categoryCelebrity = Color(0xFFFF1744);

  // -- 가족/반려동물 --
  static const Color categoryFamily = Color(0xFF3B82F6);
  static const Color categoryPet = Color(0xFFE11D48);
  static const Color categoryNaming = Color(0xFF8B5CF6);

  // -- 스타일/패션 --
  static const Color categoryOotd = Color(0xFF10B981);

  // -- 실용/결정 --
  static const Color categoryExam = Color(0xFF3B82F6);
  static const Color categoryMoving = Color(0xFF059669);

  // -- 웰니스 --
  static const Color categoryBreathing = Color(0xFF26A69A);
  static const Color categoryGratitude = Color(0xFFFFC107);

  // -- AI 코칭/저널링 --
  static const Color categoryCoaching = Color(0xFFFF6B9D);
  static const Color categoryDecision = Color(0xFF6C5CE7);
  static const Color categoryDailyReview = Color(0xFF00B894);
  static const Color categoryWeeklyReview = Color(0xFFFDAA5D);
  static const Color categoryChatInsight = Color(0xFF00BCD4);

  // -- 유명인 타입 --
  static const Color celebrityActor = Color(0xFFE91E63);
  static const Color celebritySoloSinger = Color(0xFF9C27B0);
  static const Color celebrityIdolMember = Color(0xFF673AB7);
  static const Color celebrityAthlete = Color(0xFF2196F3);
  static const Color celebrityStreamer = Color(0xFF00BCD4);
  static const Color celebrityProGamer = Color(0xFF009688);
  static const Color celebrityPolitician = Color(0xFF607D8B);
  static const Color celebrityBusiness = Color(0xFF795548);

  // -- 기타 --
  static const Color categoryViewAll = Color(0xFF6366F1);

  /// Get category color by fortune type string
  static Color getCategoryColor(String fortuneType) {
    switch (fortuneType) {
      case 'daily': return categoryDaily;
      case 'daily_calendar': return categoryDailyCalendar;
      case 'newYear': return categoryNewYear;
      case 'love': return categoryLove;
      case 'compatibility': return categoryCompatibility;
      case 'exLover': return categoryExLover;
      case 'yearlyEncounter': return categoryYearlyEncounter;
      case 'blindDate': return categoryBlindDate;
      case 'avoidPeople': return categoryAvoidPeople;
      case 'career': return categoryCareer;
      case 'talent': return categoryTalent;
      case 'money': return categoryMoney;
      case 'luckyItems': return categoryLuckyItems;
      case 'lotto': return categoryLotto;
      case 'tarot': return categoryTarot;
      case 'traditional': return categoryTraditional;
      case 'faceReading': return categoryFaceReading;
      case 'talisman': return categoryTalisman;
      case 'pastLife': return categoryPastLife;
      case 'personalityDna': return categoryPersonalityDna;
      case 'biorhythm': return categoryBiorhythm;
      case 'mbti': return categoryMbti;
      case 'health': return categoryHealth;
      case 'exercise': return categoryExercise;
      case 'sportsGame': return categorySportsGame;
      case 'gameEnhance': return categoryGameEnhance;
      case 'dream': return categoryDream;
      case 'wish': return categoryWish;
      case 'fortuneCookie': return categoryFortuneCookie;
      case 'celebrity': return categoryCelebrity;
      case 'family': return categoryFamily;
      case 'pet': return categoryPet;
      case 'naming': return categoryNaming;
      case 'ootdEvaluation': return categoryOotd;
      case 'exam': return categoryExam;
      case 'moving': return categoryMoving;
      case 'breathing': return categoryBreathing;
      case 'gratitude': return categoryGratitude;
      case 'coaching': return categoryCoaching;
      case 'decision': return categoryDecision;
      case 'daily_review': return categoryDailyReview;
      case 'weekly_review': return categoryWeeklyReview;
      case 'viewAll': return categoryViewAll;
      default: return categoryDaily;
    }
  }

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
