// 레거시 API 엔드포인트 (기존 백엔드 호환용)
//
// 주의: 운세 관련 기능은 Edge Functions를 우선 사용합니다.
// Edge Functions 엔드포인트는 [EdgeFunctionsEndpoints] 클래스를 참조하세요.
//
// 이 파일은 아직 Edge Function으로 마이그레이션되지 않은 기능이나
// 레거시 호환성을 위해 유지됩니다.
class ApiEndpoints {
  // Base URL은 환경변수에서 가져옴
  static const String baseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://fortune.example.com');

  // Auth endpoints (레거시 - 현재 Supabase Auth 사용)
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
  static const String profile = '/api/profile';
  static const String tokenHistory = '/api/user/token-history';

  // Fortune endpoints - 레거시 API 경로
  // 주의: Edge Functions 사용 시 EdgeFunctionsEndpoints.getEndpointForType() 사용
  // 일일/시간별 운세
  static const String dailyFortune = '/api/fortune/daily';
  static const String today = '/api/fortune/today';
  static const String tomorrow = '/api/fortune/tomorrow';
  static const String hourly = '/api/fortune/hourly';
  static const String weekly = '/api/fortune/weekly';
  static const String monthly = '/api/fortune/monthly';
  static const String yearly = '/api/fortune/yearly';

  // 전통 운세
  static const String sajuFortune = '/api/fortune/saju';
  static const String traditionalSaju = '/api/fortune/traditional-saju';
  static const String tojeong = '/api/fortune/tojeong';
  static const String palmistry = '/api/fortune/palmistry';
  static const String salpuli = '/api/fortune/salpuli';
  static const String fiveBlessings = '/api/fortune/five-blessings';
  static const String physiognomy = '/api/fortune/physiognomy';
  static const String faceReading = '/api/fortune/face-reading';

  // 성격/심리
  static const String mbtiFortune = '/api/fortune/mbti';
  static const String personality = '/api/fortune/personality';
  static const String bloodType = '/api/fortune/blood-type';
  static const String sajuPsychology = '/api/fortune/saju-psychology';

  // 별자리/띠
  static const String zodiac = '/api/fortune/zodiac';
  static const String zodiacAnimal = '/api/fortune/zodiac-animal';
  static const String birthSeason = '/api/fortune/birth-season';
  static const String birthdate = '/api/fortune/birthdate';
  static const String birthstone = '/api/fortune/birthstone';

  // 연애/결혼
  static const String loveFortune = '/api/fortune/love';
  static const String marriage = '/api/fortune/marriage';
  static const String compatibilityFortune = '/api/fortune/compatibility';
  static const String traditionalCompatibility =
      '/api/fortune/traditional-compatibility';
  static const String chemistry = '/api/fortune/chemistry';
  static const String coupleMatch = '/api/fortune/couple-match';
  static const String exLover = '/api/fortune/ex-lover';
  static const String blindDate = '/api/fortune/blind-date';

  // 직업/사업
  static const String career = '/api/fortune/career';
  static const String employment = '/api/fortune/employment';
  static const String business = '/api/fortune/business';
  static const String startup = '/api/fortune/startup';

  // 재물/투자
  static const String wealthFortune = '/api/fortune/wealth';
  static const String luckyInvestment = '/api/fortune/lucky-investment';
  static const String luckyRealEstate = '/api/fortune/lucky-realestate';
  static const String investmentEnhanced = '/api/fortune/investment';

  // 이사/생활
  static const String moving = '/api/fortune/moving';
  static const String movingDate = '/api/fortune/moving-date';
  static const String biorhythm = '/api/fortune/biorhythm';

  // 행운의 아이템
  static const String luckyColor = '/api/fortune/lucky-color';
  static const String luckyNumber = '/api/fortune/lucky-number';
  static const String luckyItems = '/api/fortune/lucky-items';
  static const String luckyFood = '/api/fortune/lucky-food';
  static const String luckyOutfit = '/api/fortune/lucky-outfit';
  static const String luckyJob = '/api/fortune/lucky-job';
  static const String luckySideJob = '/api/fortune/lucky-sidejob';
  static const String luckyExam = '/api/fortune/lucky-exam';
  static const String luckySeries = '/api/fortune/lucky-series';
  static const String talisman = '/api/fortune/talisman';

  // 스포츠 운세
  static const String luckyBaseball = '/api/fortune/lucky-baseball';
  static const String luckyGolf = '/api/fortune/lucky-golf';
  static const String luckyTennis = '/api/fortune/lucky-tennis';
  static const String luckyRunning = '/api/fortune/lucky-running';
  static const String luckyCycling = '/api/fortune/lucky-cycling';
  static const String luckySwim = '/api/fortune/lucky-swim';
  static const String luckyFishing = '/api/fortune/lucky-fishing';
  static const String luckyHiking = '/api/fortune/lucky-hiking';

  // 특별 운세
  static const String pastLife = '/api/fortune/past-life';
  static const String destiny = '/api/fortune/destiny';
  static const String talent = '/api/fortune/talent';
  static const String wish = '/api/fortune/wish';
  static const String timeline = '/api/fortune/timeline';
  static const String newYear = '/api/fortune/new-year';
  static const String celebrity = '/api/fortune/celebrity';
  static const String celebrityMatch = '/api/fortune/celebrity-match';
  static const String avoidPeople = '/api/fortune/avoid-people';
  static const String networkReport = '/api/fortune/network-report';

  // Batch fortune
  static const String batchFortune = '/api/fortune/generate-batch';
  static const String generate = '/api/fortune/generate';
  static const String generateFortune =
      '/api/fortune/generate'; // Alias for compatibility
  static const String fortuneHistory = '/api/fortune/history';

  // Payment endpoints
  static const String createCheckout = '/api/payment/create-checkout';
  static const String stripeWebhook = '/api/payment/webhook/stripe';
  static const String verifyPurchase = '/api/payment/verify-purchase';
  static const String subscriptionStatus = '/api/payment/subscription-status';
  static const String addTokens = '/api/payment/add-tokens';

  // Admin endpoints
  static const String adminTokenStats = '/api/admin/token-stats';
  static const String tokenUsage = '/api/admin/token-usage';
  static const String tokenStats = '/api/admin/token-stats';
  static const String redisStats = '/api/admin/redis-stats';

  // Cron endpoints
  static const String dailyBatch = '/api/cron/daily-batch';
}
