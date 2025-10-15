import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경 설정 관리 클래스
/// 보안: 모든 API 키와 민감한 정보는 환경 변수로 관리
class Environment {
  static const String _envFile = '.env';
  
  // 환경 타입
  static const String development = 'development';
  static const String staging = 'staging';
  static const String production = 'production';
  
  // 현재 환경
  static String get current {
    if (kReleaseMode) {
      return production;
    }
    try {
      return dotenv.env['ENVIRONMENT'] ?? development;
    } catch (e) {
      return development;
    }
  }
  
  // API 설정
  static String get apiBaseUrl {
    switch (current) {
      case production:
        return dotenv.env['PROD_API_BASE_URL'] ?? '${supabaseUrl}/functions/v1';
      case staging:
        return dotenv.env['STAGING_API_BASE_URL'] ?? '${supabaseUrl}/functions/v1';
      default:
        return dotenv.env['API_BASE_URL'] ?? '${supabaseUrl}/functions/v1';
    }
  }
  
  // Supabase 설정
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // 결제 설정
  static String get stripePublishableKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  
  // 분석 도구 설정
  static String get sentryDsn => dotenv.env['SENTRY_DSN'] ?? '';
  static String get mixpanelToken => dotenv.env['MIXPANEL_TOKEN'] ?? '';
  
  // 광고 설정
  static String get admobAppId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return dotenv.env['ADMOB_IOS_APP_ID'] ?? '';
    }
    return dotenv.env['ADMOB_ANDROID_APP_ID'] ?? '';
  }
  
  static String get admobBannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return dotenv.env['ADMOB_IOS_BANNER_AD_UNIT_ID'] ?? '';
    }
    return dotenv.env['ADMOB_ANDROID_BANNER_AD_UNIT_ID'] ?? '';
  }
  
  static String get admobInterstitialAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return dotenv.env['ADMOB_IOS_INTERSTITIAL_AD_UNIT_ID'] ?? '';
    }
    return dotenv.env['ADMOB_ANDROID_INTERSTITIAL_AD_UNIT_ID'] ?? '';
  }
  
  static String get admobRewardedAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return dotenv.env['ADMOB_IOS_REWARDED_AD_UNIT_ID'] ?? '';
    }
    return dotenv.env['ADMOB_ANDROID_REWARDED_AD_UNIT_ID'] ?? '';
  }
  
  // 보안 설정
  static String get encryptionKey => dotenv.env['ENCRYPTION_KEY'] ?? '';
  static String get jwtSecret => dotenv.env['JWT_SECRET'] ?? '';
  
  // AI API 설정
  static String get openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  
  // Google AdSense 설정
  static String get adsenseClientId => dotenv.env['ADSENSE_CLIENT_ID'] ?? '';
  static String get adsenseSlotId => dotenv.env['ADSENSE_SLOT_ID'] ?? '';
  static String get adsenseDisplaySlot => dotenv.env['ADSENSE_DISPLAY_SLOT'] ?? '';
  
  // 내부 API 키
  static String get internalApiKey => dotenv.env['INTERNAL_API_KEY'] ?? '';
  
  // Google OAuth 설정
  static String get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
  static String get googleIosClientId => dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';
  static String get googleAndroidClientId => dotenv.env['GOOGLE_ANDROID_CLIENT_ID'] ?? '';
  
  // Social Login 설정
  static String get kakaoAppKey => dotenv.env['KAKAO_APP_KEY'] ?? '';
  static String get naverClientId => dotenv.env['NAVER_CLIENT_ID'] ?? '';
  static String get naverClientSecret => dotenv.env['NAVER_CLIENT_SECRET'] ?? '';

  // Kakao API 설정
  static String get kakaoRestApiKey => dotenv.env['KAKAO_REST_API_KEY'] ?? '';
  
  // 기능 플래그
  static bool get enableAnalytics => 
      dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';
  static bool get enableCrashReporting => 
      dotenv.env['ENABLE_CRASH_REPORTING']?.toLowerCase() == 'true';
  static bool get enableAds => 
      dotenv.env['ENABLE_ADS']?.toLowerCase() == 'true';
  static bool get enablePayment => 
      dotenv.env['ENABLE_PAYMENT']?.toLowerCase() == 'true';
  
  // 환경 체크
  static bool get isProduction => current == production;
  static bool get isDevelopment => current == development;
  static bool get isStaging => current == staging;
  
  // 환경 변수 초기화
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: _envFile);
    } catch (e) {
      // 웹 환경에서 .env 파일을 찾을 수 없을 때의 대체 처리
      if (kIsWeb) {
        // CRITICAL: .env file not found in web environment
        // Environment variables MUST be set via build configuration
        // DO NOT hardcode API keys here for security reasons
        throw Exception(
          'Environment file not found. '
          'Please configure environment variables via build configuration. '
          'Never hardcode API keys in source code.'
        );
      } else {
        rethrow;
      }
    }
    _validateRequiredVariables();
  }
  
  // 필수 환경 변수 검증
  static void _validateRequiredVariables() {
    final requiredVars = [
      'SUPABASE_URL',
      'SUPABASE_ANON_KEY'];
    
    for (final varName in requiredVars) {
      if (dotenv.env[varName] == null || dotenv.env[varName]!.isEmpty) {
        throw Exception('Required environment variable $varName is not set');
      }
    }
    
    // Production 환경에서 추가 검증
    if (current == production) {
      final productionVars = [
        'PROD_API_BASE_URL',
        'SENTRY_DSN',
        'OPENAI_API_KEY',
        'ENCRYPTION_KEY',
        'JWT_SECRET',
        'INTERNAL_API_KEY'];
      
      for (final varName in productionVars) {
        if (dotenv.env[varName] == null || dotenv.env[varName]!.isEmpty) {
          throw Exception('Production environment variable $varName is not set');
        }
      }
      
      // API URL 형식 검증
      final prodApiUrl = dotenv.env['PROD_API_BASE_URL']!;
      if (!prodApiUrl.startsWith('https://')) {
        throw Exception('Production API URL must use HTTPS');
      }
      
      // 키 길이 검증
      final encryptionKey = dotenv.env['ENCRYPTION_KEY']!;
      if (encryptionKey.length < 32) {
        throw Exception('Encryption key must be at least 32 characters');
      }
    }
  }
  
  // 디버그 정보 출력 (개발 환경에서만)
  static void printDebugInfo() {
    if (kDebugMode) {
      debugPrint('=== Environment Configuration ===');
      debugPrint('Environment: Production');
      debugPrint('API URL: ${apiBaseUrl.substring(0, 20)}...');
      debugPrint('Supabase URL: ${supabaseUrl.substring(0, 20)}...');
      debugPrint('Analytics enabled: $enableAnalytics');
      debugPrint('Ads enabled: $enableAds');
      debugPrint('================================');
    }
  }
}