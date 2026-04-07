import '../../core/config/environment.dart';

/// Supabase Edge Functions API Endpoints
/// 실제 존재하는 Edge Function만 포함 (2024.11.26 정리)
///
/// 네이밍 규칙:
/// - 운세 함수: fortune-{type}
/// - 유틸리티: {동사}-{대상}
/// - 접미사 금지: -enhanced, -unified, -new, -v2 등
class EdgeFunctionsEndpoints {
  // Base URL for Supabase Edge Functions
  static String get baseUrl => '${Environment.supabaseUrl}/functions/v1';

  // Development URL for local testing
  static const String devBaseUrl = 'http://localhost:54321/functions/v1';

  // Get the appropriate base URL based on environment
  static String get currentBaseUrl {
    if (Environment.current == Environment.development &&
        !Environment.supabaseUrl.contains('supabase.co')) {
      return devBaseUrl;
    }
    return baseUrl;
  }

  // ============================================================
  // 유틸리티 함수
  // ============================================================
  static const String calculateSaju = '/calculate-saju';
  static const String fetchTickers = '/fetch-tickers';
  static const String generateFortuneStory = '/generate-fortune-story';
  static const String generateTalisman = '/generate-talisman';
  static const String analyzeWish = '/analyze-wish';
  static const String kakaoOauth = '/kakao-oauth';
  static const String naverOauth = '/naver-oauth';
  static const String mbtiEnergyTracker = '/mbti-energy-tracker';
  static const String personalityDna = '/personality-dna';
  static const String constellationFortune = '/fortune-constellation';
  static const String zodiacAnimalFortune = '/fortune-zodiac-animal';

  // ============================================================
  // Token & Payment (아직 Edge Function 미생성 - 기존 API 사용)
  // ============================================================
  static const String tokenBalance = '/token-balance';
  static const String tokenDailyClaim = '/token-daily-claim';
  static const String tokenHistory = '/token-history';
  static const String verifyPurchase = '/verify-purchase';
  static const String subscriptionStatus = '/subscription-status';
  static const String addTokens = '/add-tokens';
  static const String restorePurchases = '/payment-restore-purchases';

  // ============================================================
  // Batch & System (아직 Edge Function 미생성 - 기존 API 사용)
  // ============================================================
  static const String fortuneSystem = '/fortune-system';
  static const String fortuneRecommendations = '/fortune-recommendations';

  // ============================================================
  // 운세 함수 (23개) - 실제 존재하는 Edge Function
  // ============================================================
  // 일상 운세
  static const String dailyFortune = '/fortune-daily';
  static const String timeFortune = '/fortune-time';
  static const String biorhythmFortune = '/fortune-biorhythm';
  static const String dreamFortune = '/fortune-dream';

  // 전통 운세
  static const String traditionalSaju = '/fortune-traditional-saju';
  static const String faceReadingFortune = '/fortune-face-reading';

  // 성격/심리
  static const String mbtiFortune = '/fortune-mbti';
  static const String talentFortune = '/fortune-talent';

  // 연애/궁합
  static const String loveFortune = '/fortune-love';
  static const String compatibilityFortune = '/fortune-compatibility';
  static const String exLoverFortune = '/fortune-ex-lover';
  static const String blindDateFortune = '/fortune-blind-date';

  // 직업
  static const String careerFortune = '/fortune-career';
  static const String healthFortune = '/fortune-health';

  // 재물/투자
  static const String investmentFortune = '/fortune-investment';
  static const String wealthFortune = '/fortune-wealth';

  // 이사/생활
  static const String movingFortune = '/fortune-moving';

  // 가족 운세 (통합)
  static const String familyHealthFortune = '/fortune-family-health';
  static const String familyRelationshipFortune =
      '/fortune-family-relationship';
  static const String familyChildrenFortune = '/fortune-family-children';
  static const String familyChangeFortune = '/fortune-family-change';
  static const String familyFortune = familyHealthFortune;

  // 행운 아이템
  static const String luckyItemsFortune = '/fortune-lucky-items';

  // 특별 운세
  static const String avoidPeopleFortune = '/fortune-avoid-people';
  static const String celebrityFortune = '/fortune-celebrity';

  // 새해 운세
  static const String newYearFortune = '/fortune-new-year';

  // 반려동물
  static const String petCompatibilityFortune = '/fortune-pet-compatibility';

  // AI 추천
  static const String fortuneRecommend = '/fortune-recommend';

  // 자유 채팅
  static const String freeChat = '/free-chat';

  // ============================================================
  // 기타 운세 - 2024.12.28 추가
  // ============================================================
  static const String examFortune = '/fortune-exam';
  static const String tarotFortune = '/fortune-tarot';
  static const String homeFengshuiFortune = '/fortune-home-fengshui';

  // Helper method to construct full URL
  static String getFullUrl(String endpoint) {
    return '$currentBaseUrl$endpoint';
  }

  // Get endpoint for a specific fortune type
  // 실제 존재하는 Edge Function만 매핑
  static String getEndpointForType(String fortuneType) {
    final endpointMap = {
      // 코어 canonical 타입
      'daily': dailyFortune,
      'daily-calendar': timeFortune,
      'biorhythm': biorhythmFortune,
      'dream': dreamFortune,

      // 전통/성격
      'traditional-saju': traditionalSaju,
      'face-reading': faceReadingFortune,
      'mbti': mbtiFortune,
      'personality-dna': personalityDna,
      'talent': talentFortune,

      // 연애/관계
      'love': loveFortune,
      'compatibility': compatibilityFortune,
      'ex-lover': exLoverFortune,
      'blind-date': blindDateFortune,
      'avoid-people': avoidPeopleFortune,
      'yearly-encounter': '/fortune-yearly-encounter',

      // 직업/재물
      'career': careerFortune,
      'health': healthFortune,
      'wealth': wealthFortune,
      'lucky-items': luckyItemsFortune,
      'match-insight': '/fortune-match-insight',
      'game-enhance': '/fortune-game-enhance',
      'exercise': '/fortune-exercise',

      // 라이프스타일
      'moving': movingFortune,
      'celebrity': celebrityFortune,
      'new-year': newYearFortune,
      'ootd-evaluation': '/fortune-ootd',
      'past-life': '/fortune-past-life',
      'naming': '/fortune-naming',
      // baby-nickname은 naming으로 통합됨
      'exam': examFortune,
      'tarot': tarotFortune,

      // 가족/반려
      'family': familyFortune,
      'family-health': familyHealthFortune,
      'family-relationship': familyRelationshipFortune,
      'family-children': familyChildrenFortune,
      'family-change': familyChangeFortune,
      'pet-compatibility': petCompatibilityFortune,

      // 프로필 기반 별자리
      'zodiac': constellationFortune,
      'constellation': constellationFortune,
      'zodiac-animal': zodiacAnimalFortune,

      // 유틸/인터랙션
      'wish': analyzeWish,
      'talisman': generateTalisman,
      'decision': '/fortune-decision',
    };

    return endpointMap[fortuneType] ?? '/fortune-$fortuneType';
  }

  // Map old endpoints to new Edge Functions (for backward compatibility)
  static String mapOldEndpoint(String oldEndpoint) {
    // Remove /api/fortune/ prefix and convert to Edge Function format
    final fortunePrefix = '/api/fortune/';
    if (oldEndpoint.startsWith(fortunePrefix)) {
      final fortuneType = oldEndpoint.substring(fortunePrefix.length);
      return getEndpointForType(fortuneType);
    }

    // Handle other endpoint types
    if (oldEndpoint.contains('/api/payment/')) {
      return oldEndpoint.replaceAll('/api/payment/', '/payment-');
    }

    if (oldEndpoint.contains('/api/token/')) {
      return oldEndpoint.replaceAll('/api/token/', '/token-');
    }

    // Default: return as-is
    return oldEndpoint;
  }
}
