/// Test data fixtures for consistent testing
class TestData {
  // User data
  static const testUserId = 'test-user-123';
  static const testEmail = 'test@example.com';
  static const testPassword = 'TestPassword123!';
  static const testUserName = '테스트 사용자';
  static final testBirthDate = DateTime(1990, 1, 1);
  static const testGender = 'male';
  static const testBirthTime = '14:30';
  
  // Token data
  static const defaultTokenBalance = 100;
  static const tokenPurchaseAmount = 100;
  static const tokenPrice = 5.99;
  static const tokenCurrency = 'USD';
  
  // Fortune data
  static const fortuneTypes = [
    'daily',
    'weekly',
    'monthly',
    'yearly',
    'zodiac',
    'saju',
    'compatibility',
    'tarot',
    'dream',
  ];
  
  static const fortuneContent = {
    'daily': '오늘은 행운이 가득한 날입니다. 새로운 기회가 찾아올 것입니다.',
    'weekly': '이번 주는 인간관계에서 좋은 소식이 있을 것입니다.',
    'monthly': '이번 달은 재물운이 상승하는 시기입니다.',
    'yearly': '올해는 큰 성장과 발전이 있는 해가 될 것입니다.',
    'zodiac': '당신의 별자리는 오늘 특별한 에너지를 받고 있습니다.',
    'saju': '당신의 사주는 강한 목(木)의 기운을 가지고 있습니다.',
    'compatibility': '두 사람의 궁합은 85%로 매우 좋습니다.',
    'tarot': '선택한 카드는 당신에게 새로운 시작을 알립니다.',
    'dream': '꿈은 당신의 미래에 대한 긍정적인 신호입니다.',
  };
  
  static const tokenCosts = {
    'daily': 10,
    'weekly': 15,
    'monthly': 20,
    'yearly': 30,
    'zodiac': 10,
    'saju': 25,
    'compatibility': 20,
    'tarot': 15,
    'dream': 15,
  };
  
  // Social auth data
  static const googleAuthData = {
    'provider': 'google',
    'email': 'test@gmail.com',
    'name': 'Google User',
    'idToken': 'google-id-token',
    'accessToken': 'google-access-token',
  };
  
  static const kakaoAuthData = {
    'provider': 'kakao',
    'email': 'test@kakao.com',
    'name': 'Kakao User',
    'accessToken': 'kakao-access-token',
  };
  
  static const naverAuthData = {
    'provider': 'naver',
    'email': 'test@naver.com',
    'name': 'Naver User',
    'accessToken': 'naver-access-token',
  };
  
  static const appleAuthData = {
    'provider': 'apple',
    'email': 'test@icloud.com',
    'name': 'Apple User',
    'idToken': 'apple-id-token',
    'authorizationCode': 'apple-auth-code',
  };
  
  // Error messages
  static const errorMessages = {
    'network': '네트워크 연결을 확인해주세요',
    'unauthorized': '로그인이 필요합니다',
    'server': '서버 오류가 발생했습니다',
    'invalidEmail': '올바른 이메일 형식이 아닙니다',
    'weakPassword': '비밀번호는 8자 이상이어야 합니다',
    'insufficientTokens': '토큰이 부족합니다',
    'fortuneGenerationFailed': '운세 생성에 실패했습니다',
  };
  
  // API endpoints
  static const apiEndpoints = {
    'auth': '/auth/v1',
    'fortune': '/functions/v1/fortune',
    'token': '/functions/v1/token',
    'profile': '/rest/v1/user_profiles',
  };
  
  // Product IDs for in-app purchases
  static const productIds = {
    'tokens_10': 'com.fortune.tokens.10',
    'tokens_50': 'com.fortune.tokens.50',
    'tokens_100': 'com.fortune.tokens.100',
    'tokens_200': 'com.fortune.tokens.200',
    'subscription_monthly': 'com.fortune.subscription.monthly',
    'subscription_yearly': 'com.fortune.subscription.yearly',
  };
  
  // Test timeouts
  static const shortTimeout = Duration(seconds: 5);
  static const mediumTimeout = Duration(seconds: 10);
  static const longTimeout = Duration(seconds: 30);
  
  // Date formats
  static const dateFormat = 'yyyy-MM-dd';
  static const timeFormat = 'HH:mm';
  static const dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  
  // Pagination
  static const defaultPageSize = 10;
  static const maxPageSize = 50;
  
  // Cache keys
  static const cacheKeys = {
    'userProfile': 'user_profile',
    'tokenBalance': 'token_balance',
    'fortuneHistory': 'fortune_history',
    'dailyFortune': 'daily_fortune',
  };
  
  // Storage keys
  static const storageKeys = {
    'authToken': 'auth_token',
    'refreshToken': 'refresh_token',
    'userId': 'user_id',
    'onboardingComplete': 'onboarding_complete',
    'locale': 'locale',
    'theme': 'theme',
  };
}