import 'package:flutter/material.dart';

/// Fortune card thumbnail images for each fortune type
/// Instagram-style aesthetic images
class FortuneCardImages {
  static const String basePath = 'assets/images/fortune_cards/';

  /// Default image mapping for fortune types
  /// 모든 이미지를 민화(minhwa)로 통일 - fortune_cards 폴더에 에셋 없음
  static const Map<String, String> fortuneTypeImages = {
    // Love & Relationship - 연애/궁합 (원앙, 모란, 나비)
    'love': 'assets/images/minhwa/minhwa_love_peony.webp',
    'chemistry': 'assets/images/minhwa/minhwa_love_butterfly.webp',
    'marriage': 'assets/images/minhwa/minhwa_love_mandarin.webp',
    'breakup': 'assets/images/minhwa/minhwa_overall_moon.webp',
    'crush': 'assets/images/minhwa/minhwa_love_magpie_bridge.webp',
    'relationship': 'assets/images/minhwa/minhwa_love_butterfly.webp',
    'avoid-people': 'assets/images/minhwa/minhwa_overall_tiger.webp',
    'compatibility': 'assets/images/minhwa/minhwa_love_mandarin.webp',
    'blind-date': 'assets/images/minhwa/minhwa_love_butterfly.webp',
    'ex-lover': 'assets/images/minhwa/minhwa_overall_moon.webp',

    // Career & Money - 직장/재물 (매, 잉어, 보물)
    'career': 'assets/images/minhwa/minhwa_work_eagle.webp',
    'career_seeker': 'assets/images/minhwa/minhwa_work_bamboo.webp',
    'career_change': 'assets/images/minhwa/minhwa_work_waterfall.webp',
    'career_future': 'assets/images/minhwa/minhwa_work_crane.webp',
    'career_freelance': 'assets/images/minhwa/minhwa_work_bamboo.webp',
    'career_startup': 'assets/images/minhwa/minhwa_work_eagle.webp',
    'career_crisis': 'assets/images/minhwa/minhwa_work_waterfall.webp',
    'job': 'assets/images/minhwa/minhwa_work_bamboo.webp',
    'business': 'assets/images/minhwa/minhwa_money_carp.webp',
    'study': 'assets/images/minhwa/minhwa_study_owl.webp',
    'money': 'assets/images/minhwa/minhwa_money_treasure.webp',
    'investment': 'assets/images/minhwa/minhwa_money_carp.webp',

    // Traditional - 전통/사주 (사신도, 용호, 음양)
    'saju': 'assets/images/minhwa/minhwa_saju_dragon.webp',
    'zodiac': 'assets/images/minhwa/minhwa_saju_tiger_dragon.webp',
    'constellation': 'assets/images/minhwa/minhwa_overall_moon.webp',
    'tarot': 'assets/images/minhwa/minhwa_overall_moon.webp',
    'dream': 'assets/images/minhwa/minhwa_overall_moon.webp',
    'traditional': 'assets/images/minhwa/minhwa_saju_fourguardians.webp',
    'physiognomy': 'assets/images/minhwa/minhwa_saju_yin_yang.webp',
    'face-reading': 'assets/images/minhwa/minhwa_saju_yin_yang.webp',
    'talisman': 'assets/images/minhwa/minhwa_overall_phoenix.webp',

    // Daily & Personal - 일상 (호랑이, 용, 학)
    'daily': 'assets/images/minhwa/minhwa_overall_tiger.webp',
    'yearly': 'assets/images/minhwa/minhwa_overall_dragon.webp',
    'new-year': 'assets/images/minhwa/minhwa_overall_sunrise.webp',
    'time': 'assets/images/minhwa/minhwa_saju_yin_yang.webp',
    'health': 'assets/images/minhwa/minhwa_health_crane_turtle.webp',
    'health_sports': 'assets/images/minhwa/minhwa_health_deer.webp',
    'sports': 'assets/images/minhwa/minhwa_health_deer.webp',
    'enhanced_sports': 'assets/images/minhwa/minhwa_health_deer.webp',
    'travel': 'assets/images/minhwa/minhwa_overall_turtle.webp',
    'moving': 'assets/images/minhwa/minhwa_overall_sunrise.webp',
    'naming': '${basePath}naming_fortune.png', // 유일하게 존재하는 에셋
    'personality': 'assets/images/minhwa/minhwa_saju_yin_yang.webp',
    'talent': 'assets/images/minhwa/minhwa_study_brush.webp',

    // Interactive & Fun - 재미/행운 (봉황, 두꺼비, 달)
    'biorhythm': 'assets/images/minhwa/minhwa_overall_moon.webp',
    'color': 'assets/images/minhwa/minhwa_overall_phoenix.webp',
    'pet': 'assets/images/minhwa/minhwa_health_deer.webp',
    'lottery': 'assets/images/minhwa/minhwa_money_toad.webp',
    'lucky_items': 'assets/images/minhwa/minhwa_saju_fourguardians.webp',
    'fortune-cookie': '${basePath}fortune_cookie_fortune.png',
    'wish': 'assets/images/minhwa/minhwa_overall_dragon.webp',
    'ootd': 'assets/images/minhwa/minhwa_overall_phoenix.webp',

    // Family - 가족 (원앙)
    'family': 'assets/images/minhwa/minhwa_love_mandarin.webp',

    // Celebrity - 연예인 (봉황)
    'celebrity': 'assets/images/minhwa/minhwa_overall_phoenix.webp',

    // History - 히스토리 (사신도)
    'history': 'assets/images/minhwa/minhwa_saju_fourguardians.webp',

    // Default fallback - 기본 (호랑이)
    'default': 'assets/images/minhwa/minhwa_overall_tiger.webp'
  };

  /// Get image path for a fortune type
  static String getImagePath(String fortuneType) {
    return fortuneTypeImages[fortuneType] ?? fortuneTypeImages['default']!;
  }

  /// Category-based gradient overlays for better text visibility
  static Map<String, List<Color>> categoryGradients = {
    'love': [
      const Color(0x99EC4899).withValues(alpha: 0.7),
      const Color(0x99F472B6).withValues(alpha: 0.4)
    ],
    'career': [
      const Color(0x996366F1).withValues(alpha: 0.7),
      const Color(0x998B5CF6).withValues(alpha: 0.4)
    ],
    'money': [
      const Color(0x9910B981).withValues(alpha: 0.7),
      const Color(0x9984CC16).withValues(alpha: 0.4)
    ],
    'health': [
      const Color(0x99F59E0B).withValues(alpha: 0.7),
      const Color(0x99FBBF24).withValues(alpha: 0.4)
    ],
    'traditional': [
      const Color(0x99DC2626).withValues(alpha: 0.7),
      const Color(0x99EF4444).withValues(alpha: 0.4)
    ],
    'lifestyle': [
      const Color(0x993B82F6).withValues(alpha: 0.7),
      const Color(0x9960A5FA).withValues(alpha: 0.4)
    ],
    'interactive': [
      const Color(0x998B5CF6).withValues(alpha: 0.7),
      const Color(0x99A78BFA).withValues(alpha: 0.4)
    ],
    'default': [
      const Color(0x99475569).withValues(alpha: 0.7),
      const Color(0x9964748B).withValues(alpha: 0.4)
    ]
  };

  /// Modern gradient backgrounds for fortune types (inspired by trend page design)
  static Map<String, List<Color>> modernGradients = {
    // Love & Relationship
    'love': [const Color(0xFFEC4899), const Color(0xFFDB2777)],
    'chemistry': [const Color(0xFFBE185D), const Color(0xFF9333EA)],
    'marriage': [const Color(0xFFEC4899), const Color(0xFFBE185D)],
    'breakup': [const Color(0xFF6B7280), const Color(0xFF374151)],
    'crush': [const Color(0xFFEC4899), const Color(0xFFF472B6)],
    'relationship': [const Color(0xFFDC2626), const Color(0xFFB91C1C)],
    'avoid-people': [const Color(0xFFDC2626), const Color(0xFFB91C1C)],
    'compatibility': [const Color(0xFFBE185D), const Color(0xFF9333EA)],
    'blind-date': [const Color(0xFFEC4899), const Color(0xFF9333EA)],
    'ex-lover': [const Color(0xFF6B7280), const Color(0xFF374151)],

    // Career & Money
    'career': [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
    'career_seeker': [const Color(0xFF03A9F4), const Color(0xFF0288D1)],
    'career_change': [const Color(0xFF2563EB), const Color(0xFF1E40AF)],
    'career_future': [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
    'career_freelance': [const Color(0xFF0EA5E9), const Color(0xFF0284C7)],
    'career_startup': [const Color(0xFF059669), const Color(0xFF047857)],
    'career_crisis': [const Color(0xFFDC2626), const Color(0xFFB91C1C)],
    'job': [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
    'business': [const Color(0xFF059669), const Color(0xFF047857)],
    'study': [const Color(0xFF0EA5E9), const Color(0xFF0284C7)],
    'money': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
    'investment': [const Color(0xFF16A34A), const Color(0xFF15803D)],

    // Traditional
    'saju': [const Color(0xFFEF4444), const Color(0xFFDC2626)],
    'zodiac': [const Color(0xFF7C3AED), const Color(0xFF6D28D9)],
    'constellation': [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
    'tarot': [const Color(0xFF9333EA), const Color(0xFF7C3AED)],
    'dream': [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
    'traditional': [const Color(0xFFEF4444), const Color(0xFFEC4899)],
    'physiognomy': [const Color(0xFFEF4444), const Color(0xFFDC2626)],
    'face-reading': [const Color(0xFFEF4444), const Color(0xFFDC2626)],
    'talisman': [const Color(0xFFF59E0B), const Color(0xFFD97706)],

    // Daily & Personal
    'daily': [const Color(0xFF7C3AED), const Color(0xFF3B82F6)],
    'yearly': [const Color(0xFFEF4444), const Color(0xFFDC2626)],
    'new-year': [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
    'time': [const Color(0xFF7C3AED), const Color(0xFF3B82F6)],
    'health': [const Color(0xFF10B981), const Color(0xFF059669)],
    'health_sports': [const Color(0xFF10B981), const Color(0xFF059669)],
    'sports': [const Color(0xFFEA580C), const Color(0xFFDC2626)],
    'enhanced_sports': [const Color(0xFFEA580C), const Color(0xFFDC2626)],
    'travel': [const Color(0xFF06B6D4), const Color(0xFF0891B2)],
    'moving': [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
    'naming': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
    'personality': [const Color(0xFF6366F1), const Color(0xFF3B82F6)],
    'talent': [const Color(0xFFFFB300), const Color(0xFFFF8F00)],

    // Interactive & Fun
    'biorhythm': [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
    'color': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
    'pet': [const Color(0xFFE11D48), const Color(0xFFBE123C)],
    'lottery': [const Color(0xFFF59E0B), const Color(0xFFEA580C)],
    'lucky_items': [const Color(0xFF7C3AED), const Color(0xFF3B82F6)],
    'fortune-cookie': [const Color(0xFF9333EA), const Color(0xFF7C3AED)],
    'wish': [const Color(0xFFFF4081), const Color(0xFFF50057)],
    'ootd': [const Color(0xFF9333EA), const Color(0xFF7C3AED)],

    // Family
    'family': [const Color(0xFF3B82F6), const Color(0xFF2563EB)],

    // Celebrity
    'celebrity': [const Color(0xFFFF1744), const Color(0xFFE91E63)],

    // History
    'history': [const Color(0xFF795548), const Color(0xFF5D4037)],

    // Default fallback
    'default': [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
  };

  /// Get gradient colors for a fortune type
  static List<Color> getGradientColors(String fortuneType) {
    return modernGradients[fortuneType] ?? modernGradients['default']!;
  }

// ============================================================================
  // HERO IMAGES - Score-based backgrounds for result pages
  // ============================================================================

  /// Hero background images by fortune type and score level
  /// high: score >= 70, medium: score 40-69, low: score < 40
  static const Map<String, Map<String, String>> heroImages = {
    'daily': {
      'high': 'assets/images/fortune/heroes/daily/daily_hero_sunny.webp',
      'medium': 'assets/images/fortune/heroes/daily/daily_hero_cloudy.webp',
      'low': 'assets/images/fortune/heroes/daily/daily_hero_stormy.webp',
    },
    'love': {
      'high': 'assets/images/fortune/heroes/love/love_hero_blooming.webp',
      'medium': 'assets/images/fortune/heroes/love/love_hero_stable.webp',
      'low': 'assets/images/fortune/heroes/love/love_hero_waiting.webp',
    },
    'career': {
      'high': 'assets/images/fortune/heroes/career/career_hero_promotion.webp',
      'medium': 'assets/images/fortune/heroes/career/career_hero_stable.webp',
      'low': 'assets/images/fortune/heroes/career/career_hero_challenge.webp',
    },
    'health': {
      'high': 'assets/images/fortune/heroes/health/health_hero_vitality.webp',
      'medium': 'assets/images/fortune/heroes/health/health_hero_balance.webp',
      'low': 'assets/images/fortune/heroes/health/health_hero_caution.webp',
    },
    'investment': {
      'high': 'assets/images/fortune/heroes/investment/invest_hero_bull.webp',
      'medium':
          'assets/images/fortune/heroes/investment/invest_hero_neutral.webp',
      'low': 'assets/images/fortune/heroes/investment/invest_hero_bear.webp',
    },
    'tarot': {
      'high': 'assets/images/fortune/heroes/tarot/tarot_hero_mystical.webp',
      'medium': 'assets/images/fortune/heroes/tarot/tarot_hero_mystical.webp',
      'low': 'assets/images/fortune/heroes/tarot/tarot_hero_mystical.webp',
    },
    'dream': {
      'high': 'assets/images/fortune/heroes/dream/dream_hero_auspicious.webp',
      'medium': 'assets/images/fortune/heroes/dream/dream_hero_mysterious.webp',
      'low': 'assets/images/fortune/heroes/dream/dream_hero_warning.webp',
    },
    'exam': {
      'high': 'assets/images/fortune/heroes/exam/exam_hero_grade_a.webp',
      'medium': 'assets/images/fortune/heroes/exam/exam_hero_grade_b.webp',
      'low': 'assets/images/fortune/heroes/exam/exam_hero_grade_c.webp',
    },
    'compatibility': {
      'high':
          'assets/images/fortune/heroes/compatibility/compat_hero_perfect.webp',
      'medium':
          'assets/images/fortune/heroes/compatibility/compat_hero_good.webp',
      'low':
          'assets/images/fortune/heroes/compatibility/compat_hero_challenging.webp',
    },
    'mbti': {
      'high': 'assets/images/fortune/heroes/mbti/mbti_hero_energy.webp',
      'medium': 'assets/images/fortune/heroes/mbti/mbti_hero_balanced.webp',
      'low': 'assets/images/fortune/heroes/mbti/mbti_hero_recharge.webp',
    },
    'past-life': {
      'high': 'assets/images/fortune/heroes/past_life/pastlife_hero_royal.webp',
      'medium':
          'assets/images/fortune/heroes/past_life/pastlife_hero_scholar.webp',
      'low': 'assets/images/fortune/heroes/past_life/pastlife_hero_common.webp',
    },
    'wish': {
      'high': 'assets/images/fortune/heroes/wish/wish_hero_dragon.webp',
      'medium': 'assets/images/fortune/heroes/wish/wish_hero_star.webp',
      'low': 'assets/images/fortune/heroes/wish/wish_hero_fountain.webp',
    },
    'ootd': {
      'high': 'assets/images/fortune/bg/bg_ootd.webp',
      'medium': 'assets/images/fortune/bg/bg_ootd.webp',
      'low': 'assets/images/fortune/bg/bg_ootd.webp',
    },
  };

  /// Get hero image path based on fortune type and score
  static String getHeroImage(String fortuneType, int score) {
    final scoreLevel = score >= 70 ? 'high' : (score >= 40 ? 'medium' : 'low');
    final normalizedType = fortuneType.replaceAll('_', '-');
    return heroImages[fortuneType]?[scoreLevel] ??
        heroImages[normalizedType]?[scoreLevel] ??
        heroImages['daily']?[scoreLevel] ??
        heroImages['daily']!['medium']!;
  }

  // ============================================================================
  // MASCOT IMAGES - Mood-based characters for hero sections
  // ============================================================================

  /// Mascot images by fortune type and mood
  static const Map<String, Map<String, String>> mascotImages = {
    'daily': {
      'happy': 'assets/images/fortune/mascot/daily/mascot_dog_celebrate.webp',
      'calm': 'assets/images/fortune/mascot/daily/mascot_dog_main.webp',
      'careful': 'assets/images/fortune/mascot/daily/mascot_dog_thinking.webp',
      'sad': 'assets/images/fortune/mascot/daily/mascot_dog_sad.webp',
    },
    'career': {
      'happy': 'assets/images/fortune/career/mascot_career.webp',
      'calm': 'assets/images/fortune/career/mascot_career.webp',
      'careful': 'assets/images/fortune/career/mascot_career.webp',
    },
    'health': {
      'happy': 'assets/images/fortune/health/mascot_health.webp',
      'calm': 'assets/images/fortune/health/mascot_health.webp',
      'careful': 'assets/images/fortune/health/mascot_health.webp',
    },
    'dream': {
      'happy': 'assets/images/fortune/dream/mascot_dream.webp',
      'calm': 'assets/images/fortune/dream/mascot_dream.webp',
      'careful': 'assets/images/fortune/dream/mascot_dream.webp',
    },
    'wealth': {
      'happy': 'assets/images/fortune/wealth/mascot_wealth.webp',
      'calm': 'assets/images/fortune/wealth/mascot_wealth.webp',
      'careful': 'assets/images/fortune/wealth/mascot_wealth.webp',
    },
    'investment': {
      'happy': 'assets/images/fortune/investment/mascot_investment.webp',
      'calm': 'assets/images/fortune/investment/mascot_investment.webp',
      'careful': 'assets/images/fortune/investment/mascot_investment.webp',
    },
    'exam': {
      'happy': 'assets/images/fortune/exam/mascot_exam.webp',
      'calm': 'assets/images/fortune/exam/mascot_exam.webp',
      'careful': 'assets/images/fortune/exam/mascot_exam.webp',
    },
    'talent': {
      'happy': 'assets/images/fortune/talent/mascot_talent.webp',
      'calm': 'assets/images/fortune/talent/mascot_talent.webp',
      'careful': 'assets/images/fortune/talent/mascot_talent.webp',
    },
    'blind-date': {
      'happy': 'assets/images/fortune/blind-date/mascot_blinddate.webp',
      'calm': 'assets/images/fortune/blind-date/mascot_blinddate.webp',
      'careful': 'assets/images/fortune/blind-date/mascot_blinddate.webp',
    },
    'past-life': {
      'happy': 'assets/images/fortune/past-life/mascot_pastlife.webp',
      'calm': 'assets/images/fortune/past-life/mascot_pastlife.webp',
      'careful': 'assets/images/fortune/past-life/mascot_pastlife.webp',
    },
    'family': {
      'happy': 'assets/images/fortune/family/mascot_family.webp',
      'calm': 'assets/images/fortune/family/mascot_family.webp',
      'careful': 'assets/images/fortune/family/mascot_family.webp',
    },
    'exercise': {
      'happy': 'assets/images/fortune/exercise/mascot_exercise.webp',
      'calm': 'assets/images/fortune/exercise/mascot_exercise.webp',
      'careful': 'assets/images/fortune/exercise/mascot_exercise.webp',
    },
    'moving': {
      'happy': 'assets/images/fortune/moving/mascot_moving.webp',
      'calm': 'assets/images/fortune/moving/mascot_moving.webp',
      'careful': 'assets/images/fortune/moving/mascot_moving.webp',
    },
    'naming': {
      'happy': 'assets/images/fortune/naming/mascot_naming.webp',
      'calm': 'assets/images/fortune/naming/mascot_naming.webp',
      'careful': 'assets/images/fortune/naming/mascot_naming.webp',
    },
    'biorhythm': {
      'happy': 'assets/images/fortune/biorhythm/mascot_biorhythm.webp',
      'calm': 'assets/images/fortune/biorhythm/mascot_biorhythm.webp',
      'careful': 'assets/images/fortune/biorhythm/mascot_biorhythm.webp',
    },
    'ootd': {
      'happy': 'assets/images/fortune/ootd/mascot_ootd.webp',
      'calm': 'assets/images/fortune/ootd/mascot_ootd.webp',
      'careful': 'assets/images/fortune/ootd/mascot_ootd.webp',
    },
    'avoid-people': {
      'happy': 'assets/images/fortune/avoid-people/mascot_avoid.webp',
      'calm': 'assets/images/fortune/avoid-people/mascot_avoid.webp',
      'careful': 'assets/images/fortune/avoid-people/mascot_avoid.webp',
    },
    'ex-lover': {
      'happy': 'assets/images/fortune/ex-lover/mascot_exlover.webp',
      'calm': 'assets/images/fortune/ex-lover/mascot_exlover.webp',
      'careful': 'assets/images/fortune/ex-lover/mascot_exlover.webp',
    },
    'celebrity': {
      'happy': 'assets/images/fortune/celebrity/mascot_celebrity.webp',
      'calm': 'assets/images/fortune/celebrity/mascot_celebrity.webp',
      'careful': 'assets/images/fortune/celebrity/mascot_celebrity.webp',
    },
    'fengshui': {
      'happy': 'assets/images/fortune/fengshui/mascot_fengshui.webp',
      'calm': 'assets/images/fortune/fengshui/mascot_fengshui.webp',
      'careful': 'assets/images/fortune/fengshui/mascot_fengshui.webp',
    },
  };

  /// Get mascot image based on fortune type and score
  static String? getMascotImage(String fortuneType, int score) {
    final mood = score >= 70 ? 'happy' : (score >= 40 ? 'calm' : 'careful');
    final normalizedType = fortuneType.replaceAll('_', '-');
    return mascotImages[fortuneType]?[mood] ??
        mascotImages[normalizedType]?[mood] ??
        mascotImages['daily']?[mood];
  }

  // ============================================================================
  // LUCKY ITEM ICONS - Shared across multiple fortune types
  // ============================================================================

  /// Lucky color icons (used by daily, love, investment, lucky-items, time)
  static const Map<String, String> luckyColorIcons = {
    'red': 'assets/images/fortune/icons/lucky/lucky_color_red.webp',
    'orange': 'assets/images/fortune/icons/lucky/lucky_color_orange.webp',
    'yellow': 'assets/images/fortune/icons/lucky/lucky_color_yellow.webp',
    'green': 'assets/images/fortune/icons/lucky/lucky_color_green.webp',
    'blue': 'assets/images/fortune/icons/lucky/lucky_color_blue.webp',
    'purple': 'assets/images/fortune/icons/lucky/lucky_color_purple.webp',
    'pink': 'assets/images/fortune/icons/lucky/lucky_color_pink.webp',
    'white': 'assets/images/fortune/icons/lucky/lucky_color_white.webp',
    'black': 'assets/images/fortune/icons/lucky/lucky_color_black.webp',
    'gold': 'assets/images/fortune/icons/lucky/lucky_color_gold.webp',
    'silver': 'assets/images/fortune/icons/lucky/lucky_color_silver.webp',
    'coral': 'assets/images/fortune/icons/lucky/lucky_color_coral.webp',
  };

  /// Lucky direction icons (used by daily, investment, time, wish)
  static const Map<String, String> luckyDirectionIcons = {
    'east': 'assets/images/fortune/icons/lucky/lucky_direction_east.webp',
    'west': 'assets/images/fortune/icons/lucky/lucky_direction_west.webp',
    'south': 'assets/images/fortune/icons/lucky/lucky_direction_south.webp',
    'north': 'assets/images/fortune/icons/lucky/lucky_direction_north.webp',
    'northeast':
        'assets/images/fortune/icons/lucky/lucky_direction_northeast.webp',
    'northwest':
        'assets/images/fortune/icons/lucky/lucky_direction_northwest.webp',
    'southeast':
        'assets/images/fortune/icons/lucky/lucky_direction_southeast.webp',
    'southwest':
        'assets/images/fortune/icons/lucky/lucky_direction_southwest.webp',
  };

  /// Lucky time icons (used by daily, career, time)
  static const Map<String, String> luckyTimeIcons = {
    'morning': 'assets/images/fortune/icons/lucky/lucky_time_morning.webp',
    'afternoon': 'assets/images/fortune/icons/lucky/lucky_time_afternoon.webp',
    'evening': 'assets/images/fortune/icons/lucky/lucky_time_evening.webp',
    'night': 'assets/images/fortune/icons/lucky/lucky_time_night.webp',
    'dawn': 'assets/images/fortune/icons/lucky/lucky_time_dawn.webp',
  };

  /// Lucky number icons (0-9)
  static String getLuckyNumberIcon(int number) {
    final digit = number.abs() % 10;
    return 'assets/images/fortune/icons/lucky/lucky_number_$digit.webp';
  }

  // ============================================================================
  // ZODIAC ICONS - 12 Korean zodiac animals
  // ============================================================================

  /// Zodiac animal icons (used by compatibility, avoid-people, time)
  static const Map<String, String> zodiacIcons = {
    'rat': 'assets/images/fortune/icons/zodiac/zodiac_rat.webp',
    'ox': 'assets/images/fortune/icons/zodiac/zodiac_ox.webp',
    'tiger': 'assets/images/fortune/icons/zodiac/zodiac_tiger.webp',
    'rabbit': 'assets/images/fortune/icons/zodiac/zodiac_rabbit.webp',
    'dragon': 'assets/images/fortune/icons/zodiac/zodiac_dragon.webp',
    'snake': 'assets/images/fortune/icons/zodiac/zodiac_snake.webp',
    'horse': 'assets/images/fortune/icons/zodiac/zodiac_horse.webp',
    'sheep': 'assets/images/fortune/icons/zodiac/zodiac_sheep.webp',
    'monkey': 'assets/images/fortune/icons/zodiac/zodiac_monkey.webp',
    'rooster': 'assets/images/fortune/icons/zodiac/zodiac_rooster.webp',
    'dog': 'assets/images/fortune/icons/zodiac/zodiac_dog.webp',
    'pig': 'assets/images/fortune/icons/zodiac/zodiac_pig.webp',
    // Korean names mapping
    '쥐': 'assets/images/fortune/icons/zodiac/zodiac_rat.webp',
    '소': 'assets/images/fortune/icons/zodiac/zodiac_ox.webp',
    '호랑이': 'assets/images/fortune/icons/zodiac/zodiac_tiger.webp',
    '토끼': 'assets/images/fortune/icons/zodiac/zodiac_rabbit.webp',
    '용': 'assets/images/fortune/icons/zodiac/zodiac_dragon.webp',
    '뱀': 'assets/images/fortune/icons/zodiac/zodiac_snake.webp',
    '말': 'assets/images/fortune/icons/zodiac/zodiac_horse.webp',
    '양': 'assets/images/fortune/icons/zodiac/zodiac_sheep.webp',
    '원숭이': 'assets/images/fortune/icons/zodiac/zodiac_monkey.webp',
    '닭': 'assets/images/fortune/icons/zodiac/zodiac_rooster.webp',
    '개': 'assets/images/fortune/icons/zodiac/zodiac_dog.webp',
    '돼지': 'assets/images/fortune/icons/zodiac/zodiac_pig.webp',
  };

  // ============================================================================
  // ELEMENT ICONS - Five elements (Ohaeng/오행)
  // ============================================================================

  /// Element icons (used by health, investment, lucky-items, biorhythm)
  static const Map<String, String> elementIcons = {
    'wood': 'assets/images/fortune/icons/element/element_wood.webp',
    'fire': 'assets/images/fortune/icons/element/element_fire.webp',
    'earth': 'assets/images/fortune/icons/element/element_earth.webp',
    'metal': 'assets/images/fortune/icons/element/element_metal.webp',
    'water': 'assets/images/fortune/icons/element/element_water.webp',
    // Korean names
    '목': 'assets/images/fortune/icons/element/element_wood.webp',
    '화': 'assets/images/fortune/icons/element/element_fire.webp',
    '토': 'assets/images/fortune/icons/element/element_earth.webp',
    '금': 'assets/images/fortune/icons/element/element_metal.webp',
    '수': 'assets/images/fortune/icons/element/element_water.webp',
  };

  // ============================================================================
  // SECTION ICONS - For result page detail sections
  // ============================================================================

  /// Section header icons (brush stroke style)
  static const Map<String, String> sectionIcons = {
    // General sections
    'work': 'assets/images/fortune/icons/section/section_work.webp',
    'relationship':
        'assets/images/fortune/icons/section/section_relationship.webp',
    'health': 'assets/images/fortune/icons/section/section_health.webp',
    'money': 'assets/images/fortune/icons/section/section_money.webp',
    'study': 'assets/images/fortune/icons/section/section_study.webp',
    'rest': 'assets/images/fortune/icons/section/section_rest.webp',
    'warning': 'assets/images/fortune/icons/section/section_warning.webp',
    'advice': 'assets/images/fortune/icons/section/section_advice.webp',
    'lucky': 'assets/images/fortune/icons/section/section_lucky.webp',
    'action': 'assets/images/fortune/icons/section/section_action.webp',
    // Fortune-specific
    'charm': 'assets/images/fortune/icons/section/section_charm.webp',
    'fashion': 'assets/images/fortune/icons/section/section_lucky.webp',
    'venue': 'assets/images/fortune/icons/section/section_venue.webp',
    'timing': 'assets/images/fortune/icons/section/section_timing.webp',
    'compatibility':
        'assets/images/fortune/icons/section/section_compatibility.webp',
    'strategy': 'assets/images/fortune/icons/section/section_strategy.webp',
    'psychology': 'assets/images/fortune/icons/section/section_psychology.webp',
    'spirit': 'assets/images/fortune/icons/section/section_spirit.webp',
    'symbol': 'assets/images/fortune/icons/section/section_symbol.webp',
    'dimension': 'assets/images/fortune/icons/section/section_dimension.webp',
  };

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get lucky color icon path
  static String getLuckyColorIcon(String color) {
    final key = color.toLowerCase().replaceAll(' ', '');
    return luckyColorIcons[key] ?? luckyColorIcons['gold']!;
  }

  /// Get lucky direction icon path
  static String getLuckyDirectionIcon(String direction) {
    final key = direction.toLowerCase().replaceAll(' ', '');
    return luckyDirectionIcons[key] ?? luckyDirectionIcons['east']!;
  }

  /// Get lucky time icon path
  static String getLuckyTimeIcon(String time) {
    final key = time.toLowerCase().replaceAll(' ', '');
    return luckyTimeIcons[key] ?? luckyTimeIcons['morning']!;
  }

  /// Get zodiac icon path
  static String getZodiacIcon(String zodiac) {
    final key = zodiac.toLowerCase().replaceAll(' ', '');
    return zodiacIcons[key] ?? zodiacIcons['dragon']!;
  }

  /// Get element icon path
  static String getElementIcon(String element) {
    final key = element.toLowerCase().replaceAll(' ', '');
    return elementIcons[key] ?? elementIcons['wood']!;
  }

  /// Get section icon path
  static String getSectionIcon(String section) {
    final key = section.toLowerCase().trim();
    return sectionIcons[key] ?? sectionIcons['advice']!;
  }

  /// Instagram-style text overlays
  static const Map<String, String> instagramCaptions = {
    // Love & Relationship - 감성적이고 호기심을 자극하는 문구
    'love': '그 사람도 날 생각할까?',
    'chemistry': '우리, 천생연분일까?',
    'marriage': '운명의 반쪽을 만날 시기',
    'breakup': '이별 후 새로운 시작',
    'crush': '짝사랑, 이뤄질 수 있을까?',
    'relationship': '오늘 우리 사이 온도는?',
    'avoid-people': '오늘 조심해야 할 대상은?',
    'ex-lover': '그 사람과의 인연, 아직 끝나지 않았을까?',
    'blind-date': '오늘의 소개팅, 성공할까?',

    // Career & Money - 성공과 풍요를 암시하는 문구
    'career': '승진과 성공의 타이밍',
    'career_seeker': '꿈의 직장, 곧 만날까?',
    'career_change': '더 나은 기회가 기다려',
    'career_future': '내 커리어의 미래는?',
    'career_freelance': '자유로운 성공의 길',
    'career_startup': '도전이 기회가 되는 때',
    'career_crisis': '위기를 기회로 바꾸는 법',
    'job': '새로운 기회가 찾아올까?',
    'business': '사업 번창의 비밀',
    'study': '합격을 부르는 공부운',
    'money': '통장이 두둑해지는 날',
    'investment': '투자 타이밍 잡기',

    // Traditional - 신비롭고 전통적인 느낌
    'saju': '타고난 나의 운명은?',
    'zodiac': '띠로 보는 올해의 행운',
    'constellation': '별자리가 전하는 비밀',
    'tarot': '카드가 속삭이는 미래',
    'dream': '꿈이 알려주는 신호',

    // Daily & Personal - 일상의 관심사
    'daily': '오늘 나에게 일어날 일',
    'yearly': '올해 나에게 펼쳐질 운명',
    'new-year': '새해, 새로운 시작의 기운',
    'health': '몸이 보내는 신호 체크',
    'travel': '떠나기 좋은 날일까?',
    'moving': '새 둥지 찾기 좋은 때',
    'moving-enhanced': '완벽한 이사를 위한 상세 진단',
    'naming': '운을 부르는 이름 찾기',

    // Interactive & Fun - 재미있고 가벼운 느낌
    'compatibility': '우리 얼마나 잘 맞을까?',
    'biorhythm': '오늘 내 컨디션 점수는?',
    'color': '행운을 부르는 오늘의 컬러',
    'pet': '반려동물과의 교감도',
    'lottery': '대박의 기운이 느껴진다!',
    'ootd': '오늘의 패션, 어떤가요?',

    // Default fallback
    'default': '오늘 당신에게 필요한 메시지'
  };

  /// 카테고리별 아이콘 경로 반환
  static String? getCategoryIcon(String category) {
    final icons = {
      'love': 'assets/images/fortune/icons/categories/icon_category_love.webp',
      'money':
          'assets/images/fortune/icons/categories/icon_category_money.webp',
      'wealth':
          'assets/images/fortune/icons/categories/icon_category_money.webp',
      'career':
          'assets/images/fortune/icons/categories/icon_category_work.webp',
      'work': 'assets/images/fortune/icons/categories/icon_category_work.webp',
      'health':
          'assets/images/fortune/icons/categories/icon_category_health.webp',
      'study':
          'assets/images/fortune/icons/categories/icon_category_study.webp',
    };
    return icons[category];
  }
}
