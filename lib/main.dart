import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options_secure.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config/environment.dart';
import 'core/config/feature_flags.dart';
import 'core/utils/logger.dart';
import 'core/utils/secure_storage.dart';
import 'routes/route_config.dart';
import 'core/theme/toss_design_system.dart';
import 'services/cache_service.dart';
// // import 'presentation/providers/app_providers.dart'; // Has syntax errors
import 'presentation/providers/theme_provider.dart';
import 'core/utils/url_cleaner_stub.dart';
//     if (dart.library.html) 'core/utils/url_cleaner_web.dart';
import 'services/native_features_initializer.dart';
import 'services/token_monitor_service.dart';
import 'services/screenshot_detection_service.dart';
import 'services/ad_service.dart';
import 'services/analytics_service.dart';
import 'services/remote_config_service.dart';
import 'presentation/providers/font_size_provider.dart';
import 'core/services/test_auth_service.dart';
import 'core/services/supabase_connection_service.dart';

void main() async {
  print('🚀 [STARTUP] App main() started');
  WidgetsFlutterBinding.ensureInitialized();
  print('🚀 [STARTUP] Flutter binding initialized');

  try {
    // Load environment variables - check for test environment first
    print('🚀 [STARTUP] Loading environment variables...');
    if (TestAuthService.isTestMode()) {
      print('🔧 [TEST] Running in test mode, loading test environment...');
      try {
        await dotenv.dotenv.load(fileName: ".env.test");
        print('🔧 [TEST] Test environment variables loaded');
      } catch (e) {
        print('🔧 [TEST] Test env not found, falling back to .env: $e');
        await dotenv.dotenv.load(fileName: ".env");
      }
      TestAuthService.enableTestLogging();
    } else {
      await dotenv.dotenv.load(fileName: ".env");
    }
    print('🚀 [STARTUP] Environment variables loaded');
  } catch (e) {
    print('Warning: Could not load .env file: $e');
  }

  print('🚀 [STARTUP] Initializing date formatting...');
  await initializeDateFormatting('ko_KR', null);
  print('🚀 [STARTUP] Date formatting initialized');
  
  // Initialize Hive
  try {
    print('🚀 [STARTUP] Initializing Hive...');
    await Hive.initFlutter();
    print('🚀 [STARTUP] Hive initialized successfully');
    Logger.info('Hive initialized successfully');
  } catch (e) {
    print('❌ [STARTUP] Hive initialization failed: $e');
    Logger.error('Hive initialization failed', e);
  }

  // Initialize Firebase and Firebase-dependent services in background
  Future(() async {
    try {
      print('🚀 [STARTUP] Initializing Firebase in background...');
      await Firebase.initializeApp(
        options: SecureFirebaseOptions.currentPlatform,
      );
      print('🚀 [STARTUP] Firebase initialized successfully in background');
      Logger.info('Firebase initialized successfully in background');

      // Initialize Firebase-dependent services after Firebase is ready
      try {
        await RemoteConfigService().initialize();
        Logger.info('Remote Config initialized in background');
      } catch (e) {
        Logger.error('Remote Config initialization failed in background', e);
      }

      try {
        await AnalyticsService.instance.initialize();
        Logger.info('Analytics initialized in background');
      } catch (e) {
        Logger.error('Analytics initialization failed in background', e);
      }

    } catch (e) {
      print('❌ [STARTUP] Firebase initialization failed in background: $e');
      Logger.error('Firebase initialization failed in background', e);
    }
  });

  // Initialize Supabase with enhanced connection management
  print('🚀 [STARTUP] Initializing Supabase with enhanced connection service...');
  // 백그라운드에서 Supabase 연결 초기화 (앱 시작을 막지 않도록)
  Future(() async {
    try {
      final success = await SupabaseConnectionService.initialize(
        maxRetries: 3,
        timeout: Duration(seconds: 15),
        retryDelay: Duration(seconds: 2),
      );

      if (success) {
        print('🚀 [STARTUP] Supabase 강화된 연결 서비스 초기화 성공');
        Logger.info('Supabase 강화된 연결 서비스 초기화 성공');
      } else {
        print('⚠️ [STARTUP] Supabase 연결 실패, 오프라인 모드 활성화');
        Logger.warning('Supabase 연결 실패 (선택적 기능, 오프라인 모드 사용): 네트워크 또는 설정 확인 필요');
      }
    } catch (e) {
      print('❌ [STARTUP] Supabase 연결 서비스 초기화 오류: $e');
      Logger.warning('Supabase 연결 서비스 초기화 실패 (선택적 기능, 오프라인 모드 사용): $e');
    }
  });

  // Initialize Social Login SDKs with error handling
  if (!kIsWeb) {
    try {
      // Kakao SDK
      kakao.KakaoSdk.init(
        nativeAppKey: '79a067e199f5984dd47438d057ecb0c5',
      );
      Logger.info('Kakao SDK initialized');
    } catch (e) {
      Logger.error('Kakao SDK initialization failed', e);
    }

    // Naver SDK doesn't require explicit initialization in Flutter
    // The SDK is initialized when first login is attempted
    Logger.info('Naver SDK ready (initialized on first use)');
  }
  
  // Initialize Ad Service in background - don't block app startup
  // DISABLE ADS FOR TESTING ON REAL DEVICES
  const bool DISABLE_ADS_FOR_TESTING = false; // Enable ads for release build

  if (!kIsWeb && !DISABLE_ADS_FOR_TESTING) {
    // Don't await - let it run in the background
    Future(() async {
      try {
        Logger.info('Initializing Ad Service in background...');
        await AdService.instance.initialize();
        Logger.info('Ad Service initialized successfully in background');
      } catch (e) {
        Logger.error('Ad Service initialization failed in background: $e');
      }
    });
  } else {
    Logger.info('Ad Service disabled for testing');
  }
  
  // Initialize SharedPreferences
  SharedPreferences? sharedPreferences;
  try {
    sharedPreferences = await SharedPreferences.getInstance();
  } catch (e) {
    Logger.error('SharedPreferences initialization failed', e);
  }

  // Initialize test authentication if in test mode
  if (TestAuthService.isTestMode()) {
    try {
      print('🔧 [TEST] Initializing test authentication...');
      final testAuthService = TestAuthService();
      await testAuthService.autoLoginTestAccount();
      print('🔧 [TEST] Test authentication initialized');
    } catch (e) {
      print('🔧 [TEST] Test authentication failed: $e');
    }
  }

  print('🚀 [STARTUP] All initializations complete, starting app...');
  if (sharedPreferences != null) {
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const MyApp()));
  } else {
    // Run without SharedPreferences override if it failed
    runApp(
      const ProviderScope(
        child: MyApp()));
  }
  print('🚀 [STARTUP] App started successfully');
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'Fortune - 운세 서비스',
      theme: TossDesignSystem.lightTheme(),
      darkTheme: TossDesignSystem.darkTheme(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
