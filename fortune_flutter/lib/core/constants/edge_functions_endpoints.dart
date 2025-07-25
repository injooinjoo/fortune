import '../../core/config/environment.dart';

/// Supabase Edge Functions API Endpoints
/// This file maps all API endpoints to Supabase Edge Functions
class EdgeFunctionsEndpoints {
  // Base URL for Supabase Edge Functions
  static String get baseUrl => '${Environment.supabaseUrl}/functions/v1';
  
  // Development URL for local testing
  static const String devBaseUrl = 'http://localhost:54321/functions/v1';
  
  // Get the appropriate base URL based on environment
  static String get currentBaseUrl {
    if (Environment.current == Environment.development && !Environment.supabaseUrl.contains('supabase.co')) {
      return devBaseUrl;
    }
    return baseUrl;
  }

  // Token Management
  static const String tokenBalance = '/token-balance';
  static const String tokenDailyClaim = '/token-daily-claim';
  static const String tokenHistory = '/token-history';

  // Payment endpoints
  static const String verifyPurchase = '/payment-verify-purchase';
  static const String verifySubscription = '/payment-verify-subscription';
  static const String restorePurchases = '/payment-restore-purchases';

  // Batch and System endpoints
  static const String fortuneBatch = '/fortune-batch';
  static const String fortuneSystem = '/fortune-system';
  static const String fortuneRecommendations = '/fortune-recommendations';

  // Fortune endpoints - 59개 운세 타입
  // 일일/시간별 운세
  static const String dailyFortune = '/fortune-daily';
  static const String todayFortune = '/fortune-today';
  static const String tomorrowFortune = '/fortune-tomorrow';
  static const String hourlyFortune = '/fortune-hourly';
  static const String weeklyFortune = '/fortune-weekly';
  static const String monthlyFortune = '/fortune-monthly';
  static const String yearlyFortune = '/fortune-yearly';
  static const String timeFortune = '/fortune-time'; // Enhanced time-based fortune

  // 전통 운세
  static const String traditionalUnifiedFortune = '/fortune-traditional-unified'; // 통합 전통운세
  static const String sajuFortune = '/fortune-saju';
  static const String traditionalSaju = '/fortune-traditional-saju';
  static const String tojeongFortune = '/fortune-tojeong';
  static const String palmistryFortune = '/fortune-palmistry';
  static const String salpuliFortune = '/fortune-salpuli';
  static const String fiveBlessingsFortune = '/fortune-five-blessings';
  static const String physiognomyFortune = '/fortune-physiognomy';
  static const String faceReadingFortune = '/fortune-face-reading';

  // 성격/심리
  static const String mbtiFortune = '/fortune-mbti';
  static const String personalityFortune = '/fortune-personality';
  static const String bloodTypeFortune = '/fortune-blood-type';
  static const String sajuPsychologyFortune = '/fortune-saju-psychology';

  // 별자리/띠
  static const String zodiacFortune = '/fortune-zodiac';
  static const String zodiacAnimalFortune = '/fortune-zodiac-animal';
  static const String birthSeasonFortune = '/fortune-birth-season';
  static const String birthdateFortune = '/fortune-birthdate';
  static const String birthstoneFortune = '/fortune-birthstone';

  // 연애/결혼
  static const String loveFortune = '/fortune-love';
  static const String marriageFortune = '/fortune-marriage';
  static const String compatibilityFortune = '/fortune-compatibility';
  static const String traditionalCompatibilityFortune = '/fortune-traditional-compatibility';
  static const String chemistryFortune = '/fortune-chemistry';
  static const String coupleMatchFortune = '/fortune-couple-match';
  static const String exLoverFortune = '/fortune-ex-lover';
  static const String exLoverEnhancedFortune = '/fortune-ex-lover-enhanced';
  static const String blindDateFortune = '/fortune-blind-date';

  // 직업/사업
  static const String careerFortune = '/fortune-career';
  static const String careerSeekerFortune = '/fortune-career-seeker';
  static const String careerChangeFortune = '/fortune-career-change';
  static const String careerFutureFortune = '/fortune-career-future';
  static const String careerFreelanceFortune = '/fortune-career-freelance';
  static const String careerStartupFortune = '/fortune-career-startup';
  static const String careerCrisisFortune = '/fortune-career-crisis';
  static const String employmentFortune = '/fortune-employment';
  static const String businessFortune = '/fortune-business';
  static const String startupFortune = '/fortune-startup';

  // 재물/투자
  static const String wealthFortune = '/fortune-wealth';
  static const String luckyInvestmentFortune = '/fortune-lucky-investment';
  static const String luckyRealEstateFortune = '/fortune-lucky-realestate';
  static const String luckyStockFortune = '/fortune-lucky-stock';
  static const String luckyCryptoFortune = '/fortune-lucky-crypto';
  static const String luckyLotteryFortune = '/fortune-lucky-lottery';
  static const String investmentEnhancedFortune = '/fortune-investment-enhanced';

  // 건강/운명
  static const String healthFortune = '/fortune-health';
  static const String destinyFortune = '/fortune-destiny';

  // 이사/생활
  static const String movingFortune = '/fortune-moving';
  static const String movingDateFortune = '/fortune-moving-date';
  static const String movingEnhancedFortune = '/fortune-moving-enhanced';
  static const String biorhythmFortune = '/fortune-biorhythm';

  // 행운의 아이템
  static const String luckyColorFortune = '/fortune-lucky-color';
  static const String luckyNumberFortune = '/fortune-lucky-number';
  static const String luckyItemsFortune = '/fortune-lucky-items';
  static const String luckyFoodFortune = '/fortune-lucky-food';
  static const String luckyPlaceFortune = '/fortune-lucky-place';
  static const String luckyOutfitFortune = '/fortune-lucky-outfit';
  static const String luckyJobFortune = '/fortune-lucky-job';
  static const String luckySideJobFortune = '/fortune-lucky-sidejob';
  static const String luckyExamFortune = '/fortune-lucky-exam';
  static const String luckySeriesFortune = '/fortune-lucky-series';
  static const String talismanFortune = '/fortune-talisman';

  // 스포츠 운세
  static const String luckyBaseballFortune = '/fortune-lucky-baseball';
  static const String luckyGolfFortune = '/fortune-lucky-golf';
  static const String luckyTennisFortune = '/fortune-lucky-tennis';
  static const String luckyRunningFortune = '/fortune-lucky-running';
  static const String luckyCyclingFortune = '/fortune-lucky-cycling';
  static const String luckySwimFortune = '/fortune-lucky-swim';
  static const String luckyFishingFortune = '/fortune-lucky-fishing';
  static const String luckyHikingFortune = '/fortune-lucky-hiking';
  static const String luckyFitnessFortune = '/fortune-lucky-fitness';
  static const String luckyYogaFortune = '/fortune-lucky-yoga';
  static const String luckyEsportsFortune = '/fortune-esports';

  // 특별 운세
  static const String pastLifeFortune = '/fortune-past-life';
  static const String talentFortune = '/fortune-talent';
  static const String wishFortune = '/fortune-wish';
  static const String timelineFortune = '/fortune-timeline';
  static const String newYearFortune = '/fortune-new-year';
  static const String celebrityFortune = '/fortune-celebrity';
  static const String celebrityMatchFortune = '/fortune-celebrity-match';
  static const String avoidPeopleFortune = '/fortune-avoid-people';
  static const String networkReportFortune = '/fortune-network-report';
  static const String influencerFortune = '/fortune-influencer';
  static const String politicianFortune = '/fortune-politician';
  static const String sportsPlayerFortune = '/fortune-sports-player';
  static const String dreamFortune = '/fortune-dream';

  // 반려동물/육아 운세
  static const String petFortune = '/fortune-pet';
  static const String petDogFortune = '/fortune-pet-dog';
  static const String petCatFortune = '/fortune-pet-cat';
  static const String petCompatibilityFortune = '/fortune-pet-compatibility';
  static const String childrenFortune = '/fortune-children';
  static const String parentingFortune = '/fortune-parenting';
  static const String pregnancyFortune = '/fortune-pregnancy';
  static const String familyHarmonyFortune = '/fortune-family-harmony';

  // Helper method to construct full URL
  static String getFullUrl(String endpoint) {
    return '$currentBaseUrl$endpoint';
  }

  // Map old endpoints to new Edge Functions
  static String mapOldEndpoint(String oldEndpoint) {
    // Remove /api/fortune/ prefix and convert to Edge Function format
    final fortunePrefix = '/api/fortune/';
    if (oldEndpoint.startsWith(fortunePrefix)) {
      final fortuneType = oldEndpoint.substring(fortunePrefix.length);
      return '/fortune-$fortuneType';
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

  // Get endpoint for a specific fortune type
  static String getEndpointForType(String fortuneType) {
    final endpointMap = {
      'daily': dailyFortune,
      'today': dailyFortune, // Map 'today' to use the same endpoint as 'daily' for consistency
      'tomorrow': tomorrowFortune,
      'hourly': hourlyFortune,
      'weekly': weeklyFortune,
      'monthly': monthlyFortune,
      'yearly': yearlyFortune,
      'time': timeFortune,
      'time_based': timeFortune,
      'traditional': traditionalUnifiedFortune,
      'traditional-unified': traditionalUnifiedFortune,
      'saju': sajuFortune,
      'traditional-saju': traditionalSaju,
      'tojeong': tojeongFortune,
      'palmistry': palmistryFortune,
      'salpuli': salpuliFortune,
      'five-blessings': fiveBlessingsFortune,
      'physiognomy': physiognomyFortune,
      'face-reading': faceReadingFortune,
      'mbti': mbtiFortune,
      'personality': personalityFortune,
      'blood-type': bloodTypeFortune,
      'saju-psychology': sajuPsychologyFortune,
      'zodiac': zodiacFortune,
      'zodiac-animal': zodiacAnimalFortune,
      'birth-season': birthSeasonFortune,
      'birthdate': birthdateFortune,
      'birthstone': birthstoneFortune,
      'love': loveFortune,
      'marriage': marriageFortune,
      'compatibility': compatibilityFortune,
      'traditional-compatibility': traditionalCompatibilityFortune,
      'chemistry': chemistryFortune,
      'couple-match': coupleMatchFortune,
      'ex-lover': exLoverFortune,
      'ex-lover-enhanced': exLoverEnhancedFortune,
      'blind-date': blindDateFortune,
      'career': careerFortune,
      'career_seeker': careerSeekerFortune,
      'career_change': careerChangeFortune,
      'career_future': careerFutureFortune,
      'career_freelance': careerFreelanceFortune,
      'career_startup': careerStartupFortune,
      'career_crisis': careerCrisisFortune,
      'employment': employmentFortune,
      'business': businessFortune,
      'startup': startupFortune,
      'wealth': wealthFortune,
      'lucky-investment': luckyInvestmentFortune,
      'lucky-realestate': luckyRealEstateFortune,
      'lucky-stock': luckyStockFortune,
      'lucky-crypto': luckyCryptoFortune,
      'lucky-lottery': luckyLotteryFortune,
      'investment-enhanced': investmentEnhancedFortune,
      'health': healthFortune,
      'destiny': destinyFortune,
      'moving': movingFortune,
      'moving-date': movingDateFortune,
      'moving-enhanced': movingEnhancedFortune,
      'biorhythm': biorhythmFortune,
      'lucky-color': luckyColorFortune,
      'lucky-number': luckyNumberFortune,
      'lucky-items': luckyItemsFortune,
      'lucky-food': luckyFoodFortune,
      'lucky-place': luckyPlaceFortune,
      'lucky-outfit': luckyOutfitFortune,
      'lucky-job': luckyJobFortune,
      'lucky-sidejob': luckySideJobFortune,
      'lucky-exam': luckyExamFortune,
      'lucky-series': luckySeriesFortune,
      'talisman': talismanFortune,
      'lucky-baseball': luckyBaseballFortune,
      'lucky-golf': luckyGolfFortune,
      'lucky-tennis': luckyTennisFortune,
      'lucky-running': luckyRunningFortune,
      'lucky-cycling': luckyCyclingFortune,
      'lucky-swim': luckySwimFortune,
      'lucky-fishing': luckyFishingFortune,
      'lucky-hiking': luckyHikingFortune,
      'lucky-fitness': luckyFitnessFortune,
      'lucky-yoga': luckyYogaFortune,
      'lucky-esports': luckyEsportsFortune,
      'past-life': pastLifeFortune,
      'talent': talentFortune,
      'wish': wishFortune,
      'timeline': timelineFortune,
      'new-year': newYearFortune,
      'celebrity': celebrityFortune,
      'celebrity-match': celebrityMatchFortune,
      'avoid-people': avoidPeopleFortune,
      'network-report': networkReportFortune,
      'influencer': influencerFortune,
      'politician': politicianFortune,
      'sports-player': sportsPlayerFortune,
      'dream': dreamFortune,
      'pet': petFortune,
      'pet-dog': petDogFortune,
      'pet-cat': petCatFortune,
      'pet-compatibility': petCompatibilityFortune,
      'children': childrenFortune,
      'parenting': parentingFortune,
      'pregnancy': pregnancyFortune,
      'family-harmony': familyHarmonyFortune,
    };

    return endpointMap[fortuneType] ?? '/fortune-$fortuneType';
  }
}