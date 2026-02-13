// Infographic Asset Paths
// 인포그래픽 에셋 경로 상수
class InfographicAssets {
  InfographicAssets._();

  static const String _basePath = 'assets/images/infographic';

  // === Backgrounds ===
  static const String bgPatternDaily =
      '$_basePath/backgrounds/bg_pattern_daily.png';
  static const String bgPatternLove =
      '$_basePath/backgrounds/bg_pattern_love.png';
  static const String bgPatternCareer =
      '$_basePath/backgrounds/bg_pattern_career.png';
  static const String bgPatternHealth =
      '$_basePath/backgrounds/bg_pattern_health.png';

  // === Decorations ===
  static const String decoCornerOrnament =
      '$_basePath/decorations/deco_corner_ornament.png';
  static const String decoDividerLine =
      '$_basePath/decorations/deco_divider_line.png';

  // === Effects ===
  static const String scoreGlowGold = '$_basePath/effects/score_glow_gold.png';
  static const String scoreGlowSilver =
      '$_basePath/effects/score_glow_silver.png';
  static const String chipBgGradient =
      '$_basePath/effects/chip_bg_gradient.png';

  // === Category Icons ===
  static const String iconLove = '$_basePath/icons/icon_love.webp';
  static const String iconHealth = '$_basePath/icons/icon_health.webp';
  static const String iconMoney = '$_basePath/icons/icon_money.webp';
  static const String iconStudy = '$_basePath/icons/icon_study.webp';
  static const String iconSocial = '$_basePath/icons/icon_social.webp';

  /// 운세 타입별 배경 패턴 반환
  static String getBackgroundForType(String fortuneType) {
    switch (fortuneType.toLowerCase()) {
      case 'love':
      case 'compatibility':
      case 'love_fortune':
        return bgPatternLove;
      case 'career':
      case 'wealth':
      case 'money':
      case 'investment':
        return bgPatternCareer;
      case 'health':
      case 'wellness':
        return bgPatternHealth;
      default:
        return bgPatternDaily;
    }
  }

  /// 카테고리별 아이콘 반환
  static String getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'love':
      case '연애':
      case '애정':
        return iconLove;
      case 'health':
      case '건강':
        return iconHealth;
      case 'money':
      case 'wealth':
      case 'career':
      case '재물':
      case '재정':
      case '직장':
        return iconMoney;
      case 'study':
      case 'education':
      case '학업':
      case '시험':
        return iconStudy;
      case 'social':
      case 'relationship':
      case '대인':
      case '인간관계':
        return iconSocial;
      default:
        return iconLove; // 기본값
    }
  }

  /// 점수에 따른 글로우 효과 반환
  static String getGlowForScore(int score) {
    if (score >= 70) {
      return scoreGlowGold;
    }
    return scoreGlowSilver;
  }
}
