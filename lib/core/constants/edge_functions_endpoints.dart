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
  static const String fortuneBatch = '/fortune-batch';
  static const String fortuneSystem = '/fortune-system';
  static const String fortuneRecommendations = '/fortune-recommendations';

  // ============================================================
  // 운세 함수 (23개) - 실제 존재하는 Edge Function
  // ============================================================
  // 일상 운세
  static const String dailyFortune = '/fortune-daily';
  static const String yearlyFortune = '/fortune-yearly';
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

  // 이사/생활
  static const String movingFortune = '/fortune-moving';
  static const String familyHarmonyFortune = '/fortune-family-harmony';

  // 행운 아이템
  static const String luckyItemsFortune = '/fortune-lucky-items';

  // 특별 운세
  static const String avoidPeopleFortune = '/fortune-avoid-people';
  static const String celebrityFortune = '/fortune-celebrity';

  // 반려동물
  static const String petCompatibilityFortune = '/fortune-pet-compatibility';

  // Helper method to construct full URL
  static String getFullUrl(String endpoint) {
    return '$currentBaseUrl$endpoint';
  }

  // Get endpoint for a specific fortune type
  // 실제 존재하는 Edge Function만 매핑
  static String getEndpointForType(String fortuneType) {
    final endpointMap = {
      // 일상 운세
      'daily': dailyFortune,
      'today': dailyFortune,
      'yearly': yearlyFortune,
      'time': timeFortune,
      'time_based': timeFortune,
      'biorhythm': biorhythmFortune,
      'dream': dreamFortune,
      // 전통 운세
      'traditional-saju': traditionalSaju,
      'saju': traditionalSaju,
      'face-reading': faceReadingFortune,
      // 성격/심리
      'mbti': mbtiFortune,
      'talent': talentFortune,
      // 연애/궁합
      'love': loveFortune,
      'compatibility': compatibilityFortune,
      'ex-lover': exLoverFortune,
      'blind-date': blindDateFortune,
      // 직업
      'career': careerFortune,
      'health': healthFortune,
      // 재물/투자
      'investment': investmentFortune,
      // 이사/생활
      'moving': movingFortune,
      'family-harmony': familyHarmonyFortune,
      // 행운 아이템
      'lucky-items': luckyItemsFortune,
      // 특별 운세
      'avoid-people': avoidPeopleFortune,
      'celebrity': celebrityFortune,
      // 반려동물
      'pet-compatibility': petCompatibilityFortune,
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
