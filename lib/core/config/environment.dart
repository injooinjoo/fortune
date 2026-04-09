import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 환경 설정 관리 클래스
/// 보안: 모든 API 키와 민감한 정보는 환경 변수로 관리
class Environment {
  static const String defaultEnvFile = '.env';
  static const String developmentEnvFile = '.env.development';

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
      return _readEnvValue(
        'ENVIRONMENT',
        dotenvValue: dotenv.env['ENVIRONMENT'],
        fallback: development,
      );
    } catch (e) {
      return development;
    }
  }

  // API 설정
  static String get apiBaseUrl {
    switch (current) {
      case production:
        return _readEnvValue(
          'PROD_API_BASE_URL',
          dotenvValue: dotenv.env['PROD_API_BASE_URL'],
          fallback: '$supabaseUrl/functions/v1',
        );
      case staging:
        return _readEnvValue(
          'STAGING_API_BASE_URL',
          dotenvValue: dotenv.env['STAGING_API_BASE_URL'],
          fallback: '$supabaseUrl/functions/v1',
        );
      default:
        return _readEnvValue(
          'API_BASE_URL',
          dotenvValue: dotenv.env['API_BASE_URL'],
          fallback: '$supabaseUrl/functions/v1',
        );
    }
  }

  // Supabase 설정
  static String get supabaseUrl => _readEnvValue(
        'SUPABASE_URL',
        dotenvValue: _dotenvValue('SUPABASE_URL'),
      );
  static String get supabaseAnonKey => _readEnvValue(
        'SUPABASE_ANON_KEY',
        dotenvValue: _dotenvValue('SUPABASE_ANON_KEY'),
      );

  // App Domain 설정 (공유 링크, 딥링크용)
  static String get appDomain => _readEnvValue(
        'APP_DOMAIN',
        dotenvValue: dotenv.env['APP_DOMAIN'],
        fallback: 'zpzg.co.kr',
      );
  static String get appBaseUrl => 'https://$appDomain';
  static String get defaultShareImageUrl =>
      '$appBaseUrl/images/default_share.png';

  // 결제 설정
  static String get stripePublishableKey => _readEnvValue(
        'STRIPE_PUBLISHABLE_KEY',
        dotenvValue: dotenv.env['STRIPE_PUBLISHABLE_KEY'],
      );

  // 분석 도구 설정
  static String get sentryDsn => _readEnvValue(
        'SENTRY_DSN',
        dotenvValue: dotenv.env['SENTRY_DSN'],
      );
  static String get mixpanelToken => _readEnvValue(
        'MIXPANEL_TOKEN',
        dotenvValue: dotenv.env['MIXPANEL_TOKEN'],
      );

  // 보안 설정
  static String get encryptionKey => _readEnvValue(
        'ENCRYPTION_KEY',
        dotenvValue: dotenv.env['ENCRYPTION_KEY'],
      );
  static String get jwtSecret => _readEnvValue(
        'JWT_SECRET',
        dotenvValue: dotenv.env['JWT_SECRET'],
      );

  // Weather API 설정
  static String get weatherApiKey => _readEnvValue(
        'WEATHER_API_KEY',
        dotenvValue: dotenv.env['WEATHER_API_KEY'],
        fallback: '',
      );

  // AI API 설정
  static String get openAiApiKey => _readEnvValue(
        'OPENAI_API_KEY',
        dotenvValue: dotenv.env['OPENAI_API_KEY'],
      );

  // 내부 API 키
  static String get internalApiKey => _readEnvValue(
        'INTERNAL_API_KEY',
        dotenvValue: dotenv.env['INTERNAL_API_KEY'],
      );

  // Google OAuth 설정
  static String get googleWebClientId => _readEnvValue(
        'GOOGLE_WEB_CLIENT_ID',
        dotenvValue: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      );
  static String get googleIosClientId => _readEnvValue(
        'GOOGLE_IOS_CLIENT_ID',
        dotenvValue: dotenv.env['GOOGLE_IOS_CLIENT_ID'],
      );
  static String get googleAndroidClientId => _readEnvValue(
        'GOOGLE_ANDROID_CLIENT_ID',
        dotenvValue: dotenv.env['GOOGLE_ANDROID_CLIENT_ID'],
      );

  // Social Login 설정
  static String get kakaoAppKey => _readEnvValue(
        'KAKAO_APP_KEY',
        dotenvValue: dotenv.env['KAKAO_APP_KEY'],
      );
  static String get naverClientId => _readEnvValue(
        'NAVER_CLIENT_ID',
        dotenvValue: dotenv.env['NAVER_CLIENT_ID'],
      );
  static String get naverClientSecret => _readEnvValue(
        'NAVER_CLIENT_SECRET',
        dotenvValue: dotenv.env['NAVER_CLIENT_SECRET'],
      );

  // Kakao API 설정
  static String get kakaoRestApiKey => _readEnvValue(
        'KAKAO_REST_API_KEY',
        dotenvValue: dotenv.env['KAKAO_REST_API_KEY'],
      );

  // 테스트 계정 도메인 (쉼표로 구분)
  static List<String> get testEmailDomains {
    final domains = _readEnvValue(
      'TEST_EMAIL_DOMAINS',
      dotenvValue: dotenv.env['TEST_EMAIL_DOMAINS'],
      fallback: '@test.zpzg.com',
    );
    return domains.split(',').map((d) => d.trim().toLowerCase()).toList();
  }

  // 기능 플래그
  static bool get enableAnalytics =>
      _readEnvValue(
        'ENABLE_ANALYTICS',
        dotenvValue: dotenv.env['ENABLE_ANALYTICS'],
      ).toLowerCase() ==
      'true';
  static bool get enableCrashReporting =>
      _readEnvValue(
        'ENABLE_CRASH_REPORTING',
        dotenvValue: dotenv.env['ENABLE_CRASH_REPORTING'],
      ).toLowerCase() ==
      'true';
  static bool get enablePayment =>
      _readEnvValue(
        'ENABLE_PAYMENT',
        dotenvValue: dotenv.env['ENABLE_PAYMENT'],
      ).toLowerCase() ==
      'true';

  // 환경 체크
  static bool get isProduction => current == production;
  static bool get isDevelopment => current == development;
  static bool get isStaging => current == staging;
  static bool get hasValidSupabaseConfiguration =>
      describeSupabaseConfigurationIssue() == null;

  static String resolveRuntimeEnvFile({
    required bool isTestMode,
    bool isReleaseMode = kReleaseMode,
  }) {
    if (isTestMode || isReleaseMode) {
      return defaultEnvFile;
    }

    return developmentEnvFile;
  }

  static bool shouldFallbackToDefaultEnv({
    required String loadedEnvFile,
    String? supabaseUrl,
    String? supabaseAnonKey,
  }) {
    if (loadedEnvFile != developmentEnvFile) {
      return false;
    }

    return describeSupabaseConfigurationIssue(
          supabaseUrl: supabaseUrl ?? _dotenvValue('SUPABASE_URL') ?? '',
          supabaseAnonKey:
              supabaseAnonKey ?? _dotenvValue('SUPABASE_ANON_KEY') ?? '',
        ) !=
        null;
  }

  // 환경 변수 초기화
  static Future<void> initialize({
    bool isTestMode = false,
    bool isReleaseMode = kReleaseMode,
  }) async {
    try {
      await dotenv.load(
        fileName: resolveRuntimeEnvFile(
          isTestMode: isTestMode,
          isReleaseMode: isReleaseMode,
        ),
      );
    } catch (e) {
      // 웹 환경에서 .env 파일을 찾을 수 없을 때의 대체 처리
      if (kIsWeb) {
        throw Exception('Environment file not found. '
            'Please configure environment variables via build configuration. '
            'Never hardcode API keys in source code.');
      } else {
        rethrow;
      }
    }
    _validateRequiredVariables();
  }

  // 필수 환경 변수 검증
  static void _validateRequiredVariables() {
    final supabaseConfigIssue = describeSupabaseConfigurationIssue();
    if (supabaseConfigIssue != null) {
      throw Exception(supabaseConfigIssue);
    }

    if (current == production) {
      final productionVars = [
        'PROD_API_BASE_URL',
        'SENTRY_DSN',
        'OPENAI_API_KEY',
        'ENCRYPTION_KEY',
        'JWT_SECRET',
        'INTERNAL_API_KEY'
      ];

      for (final varName in productionVars) {
        if (_readEnvValue(varName, dotenvValue: dotenv.env[varName]).isEmpty) {
          throw Exception(
              'Production environment variable $varName is not set');
        }
      }

      final prodApiUrl = _readEnvValue(
        'PROD_API_BASE_URL',
        dotenvValue: dotenv.env['PROD_API_BASE_URL'],
      );
      if (!prodApiUrl.startsWith('https://')) {
        throw Exception('Production API URL must use HTTPS');
      }

      final encryptionKey = _readEnvValue(
        'ENCRYPTION_KEY',
        dotenvValue: dotenv.env['ENCRYPTION_KEY'],
      );
      if (encryptionKey.length < 32) {
        throw Exception('Encryption key must be at least 32 characters');
      }
    }
  }

  static String? describeSupabaseConfigurationIssue({
    String? supabaseUrl,
    String? supabaseAnonKey,
  }) {
    final resolvedUrl = (supabaseUrl ?? Environment.supabaseUrl).trim();
    if (resolvedUrl.isEmpty) {
      return 'SUPABASE_URL이 설정되지 않았습니다.';
    }

    final uri = Uri.tryParse(resolvedUrl);
    if (uri == null || !uri.isAbsolute) {
      return 'SUPABASE_URL 형식이 올바르지 않습니다.';
    }

    if (isPlaceholderValue(resolvedUrl)) {
      return 'SUPABASE_URL이 placeholder 값입니다.';
    }

    final resolvedAnonKey =
        (supabaseAnonKey ?? Environment.supabaseAnonKey).trim();
    if (resolvedAnonKey.isEmpty) {
      return 'SUPABASE_ANON_KEY가 설정되지 않았습니다.';
    }

    if (isPlaceholderValue(resolvedAnonKey)) {
      return 'SUPABASE_ANON_KEY가 placeholder 값입니다.';
    }

    if (resolvedAnonKey.length < 100) {
      return 'SUPABASE_ANON_KEY 형식이 올바르지 않습니다.';
    }

    return null;
  }

  static String? describeSupabaseClientConfigurationIssue({
    required SupabaseClient supabase,
    String? expectedSupabaseUrl,
  }) {
    final actualClientUrl = normalizeSupabaseBaseUrl(supabase.rest.url);
    if (actualClientUrl == null) {
      return '현재 Supabase client URL 형식이 올바르지 않습니다.';
    }

    if (isPlaceholderValue(actualClientUrl)) {
      return '현재 Supabase client가 placeholder 값으로 초기화되었습니다.';
    }

    final expectedClientUrl = normalizeSupabaseBaseUrl(
      expectedSupabaseUrl ?? Environment.supabaseUrl,
    );

    if (expectedClientUrl != null && actualClientUrl != expectedClientUrl) {
      return '현재 Supabase client가 ENV 설정과 다른 URL로 초기화되었습니다.';
    }

    return null;
  }

  static String? normalizeSupabaseBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.isAbsolute) {
      return null;
    }

    final normalizedPath = uri.path.replaceFirst(
      RegExp(r'/(rest|auth|storage|functions)/v1/?$'),
      '',
    );

    final normalizedUri = uri.replace(
      path: normalizedPath,
      query: null,
      fragment: null,
    );

    final result = normalizedUri.toString();
    if (result.endsWith('/')) {
      return result.substring(0, result.length - 1);
    }

    return result;
  }

  static bool isPlaceholderValue(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }

    return normalized.contains('placeholder') ||
        normalized.contains('your-project') ||
        normalized.contains('your-dev-project') ||
        normalized.contains('your-prod-project') ||
        normalized.contains('not-real-key') ||
        normalized.contains('not-real') ||
        normalized.contains('example');
  }

  static String? _dotenvValue(String key) {
    if (!dotenv.isInitialized) {
      return null;
    }

    return dotenv.env[key];
  }

  static String _readEnvValue(
    String key, {
    required String? dotenvValue,
    String fallback = '',
  }) {
    final defineValue = _dartDefineValue(key);
    return resolveConfiguredValue(
      key,
      defineValue: defineValue,
      dotenvValue: dotenvValue,
      fallback: fallback,
    );
  }

  static String resolveConfiguredValue(
    String key, {
    required String defineValue,
    required String? dotenvValue,
    String fallback = '',
  }) {
    if (defineValue.isNotEmpty) {
      if (_isValidOverrideValue(key, defineValue) ||
          dotenvValue == null ||
          dotenvValue.isEmpty) {
        return defineValue;
      }
    }

    if (dotenvValue != null && dotenvValue.isNotEmpty) {
      return dotenvValue;
    }

    return fallback;
  }

  static bool _isValidOverrideValue(String key, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || isPlaceholderValue(trimmed)) {
      return false;
    }

    switch (key) {
      case 'SUPABASE_URL':
      case 'API_BASE_URL':
      case 'STAGING_API_BASE_URL':
      case 'PROD_API_BASE_URL':
        return _isValidAbsoluteUrl(trimmed);
      case 'SUPABASE_ANON_KEY':
        return _isValidSupabaseAnonKey(trimmed);
      default:
        return true;
    }
  }

  static bool _isValidAbsoluteUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && uri.isAbsolute;
  }

  static bool _isValidSupabaseAnonKey(String value) {
    return value.length >= 100;
  }

  static String _dartDefineValue(String key) {
    switch (key) {
      case 'ENVIRONMENT':
        return const String.fromEnvironment('ENVIRONMENT');
      case 'API_BASE_URL':
        return const String.fromEnvironment('API_BASE_URL');
      case 'STAGING_API_BASE_URL':
        return const String.fromEnvironment('STAGING_API_BASE_URL');
      case 'PROD_API_BASE_URL':
        return const String.fromEnvironment('PROD_API_BASE_URL');
      case 'SUPABASE_URL':
        return const String.fromEnvironment('SUPABASE_URL');
      case 'SUPABASE_ANON_KEY':
        return const String.fromEnvironment('SUPABASE_ANON_KEY');
      case 'APP_DOMAIN':
        return const String.fromEnvironment('APP_DOMAIN');
      case 'STRIPE_PUBLISHABLE_KEY':
        return const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
      case 'SENTRY_DSN':
        return const String.fromEnvironment('SENTRY_DSN');
      case 'MIXPANEL_TOKEN':
        return const String.fromEnvironment('MIXPANEL_TOKEN');
      case 'ENCRYPTION_KEY':
        return const String.fromEnvironment('ENCRYPTION_KEY');
      case 'JWT_SECRET':
        return const String.fromEnvironment('JWT_SECRET');
      case 'WEATHER_API_KEY':
        return const String.fromEnvironment('WEATHER_API_KEY');
      case 'OPENAI_API_KEY':
        return const String.fromEnvironment('OPENAI_API_KEY');
      case 'INTERNAL_API_KEY':
        return const String.fromEnvironment('INTERNAL_API_KEY');
      case 'GOOGLE_WEB_CLIENT_ID':
        return const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
      case 'GOOGLE_IOS_CLIENT_ID':
        return const String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
      case 'GOOGLE_ANDROID_CLIENT_ID':
        return const String.fromEnvironment('GOOGLE_ANDROID_CLIENT_ID');
      case 'KAKAO_APP_KEY':
        return const String.fromEnvironment('KAKAO_APP_KEY');
      case 'NAVER_CLIENT_ID':
        return const String.fromEnvironment('NAVER_CLIENT_ID');
      case 'NAVER_CLIENT_SECRET':
        return const String.fromEnvironment('NAVER_CLIENT_SECRET');
      case 'KAKAO_REST_API_KEY':
        return const String.fromEnvironment('KAKAO_REST_API_KEY');
      case 'TEST_EMAIL_DOMAINS':
        return const String.fromEnvironment('TEST_EMAIL_DOMAINS');
      case 'ENABLE_ANALYTICS':
        return const String.fromEnvironment('ENABLE_ANALYTICS');
      case 'ENABLE_CRASH_REPORTING':
        return const String.fromEnvironment('ENABLE_CRASH_REPORTING');
      case 'ENABLE_PAYMENT':
        return const String.fromEnvironment('ENABLE_PAYMENT');
      default:
        return '';
    }
  }

  // 디버그 정보 출력 (개발 환경에서만)
  static void printDebugInfo() {
    if (kDebugMode) {
      debugPrint('=== Environment Configuration ===');
      debugPrint('Environment: Production');
      debugPrint('API URL: ${_preview(apiBaseUrl)}');
      debugPrint('Supabase URL: ${_preview(supabaseUrl)}');
      debugPrint('Analytics enabled: $enableAnalytics');
      debugPrint('================================');
    }
  }

  static String _preview(String value) {
    if (value.isEmpty) {
      return '(empty)';
    }
    final end = value.length < 20 ? value.length : 20;
    return '${value.substring(0, end)}...';
  }
}
