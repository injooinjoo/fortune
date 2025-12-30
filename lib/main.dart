import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/environment.dart';
import 'core/utils/logger.dart';
import 'routes/route_config.dart';
import 'core/theme/fortune_design_system.dart';
// // import 'presentation/providers/app_providers.dart'; // Has syntax errors
import 'presentation/providers/theme_provider.dart';
import 'core/theme/font_size_system.dart';
//     if (dart.library.html) 'core/utils/url_cleaner_web.dart';
import 'services/ad_service.dart';
import 'services/att_service.dart';
import 'services/remote_config_service.dart';
// import 'presentation/providers/font_size_provider.dart'; // ⚠️ REMOVED: 이제 user_settings_provider 사용
import 'core/services/test_auth_service.dart';
import 'services/notification/fcm_service.dart';
import 'core/services/supabase_connection_service.dart';
import 'core/utils/route_observer_logger.dart';
import 'core/services/error_reporter_service.dart';
import 'core/providers/user_settings_provider.dart';
import 'core/services/fortune_haptic_service.dart';
import 'presentation/providers/auth_provider.dart';

void main() async {
  debugPrint('🚀 [STARTUP] App main() started');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🚀 [STARTUP] Flutter binding initialized');

  try {
    // Load environment variables - check for test environment first
    debugPrint('🚀 [STARTUP] Loading environment variables...');
    if (TestAuthService.isTestMode()) {
      debugPrint('🔧 [TEST] Running in test mode, loading test environment...');
      try {
        await dotenv.dotenv.load(fileName: '.env.test');
        debugPrint('🔧 [TEST] Test environment variables loaded');
      } catch (e) {
        debugPrint('🔧 [TEST] Test env not found, falling back to .env: $e');
        await dotenv.dotenv.load(fileName: '.env');
      }
      TestAuthService.enableTestLogging();
    } else {
      await dotenv.dotenv.load(fileName: '.env');
    }
    debugPrint('🚀 [STARTUP] Environment variables loaded');
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
  }

  debugPrint('🚀 [STARTUP] Initializing date formatting...');
  await initializeDateFormatting('ko_KR', null);
  debugPrint('🚀 [STARTUP] Date formatting initialized');

  // Initialize Hive
  try {
    debugPrint('🚀 [STARTUP] Initializing Hive...');
    await Hive.initFlutter();
    debugPrint('🚀 [STARTUP] Hive initialized successfully');
    Logger.info('Hive initialized successfully');
  } catch (e) {
    debugPrint('❌ [STARTUP] Hive initialization failed: $e');
    Logger.error('Hive initialization failed', e);
  }

  // Initialize Haptic Service
  try {
    debugPrint('🚀 [STARTUP] Initializing Haptic Service...');
    await FortuneHapticService.initialize();
    debugPrint('🚀 [STARTUP] Haptic Service initialized');
  } catch (e) {
    debugPrint('⚠️ [STARTUP] Haptic Service initialization failed: $e');
  }

  // Initialize Firebase
  // Firebase Core는 플러그인에 의해 자동 초기화되지만,
  // Remote Config 같은 일부 서비스는 명시적 초기화가 필요할 수 있음
  debugPrint('🚀 [STARTUP] Firebase initialized by plugin');

  // Initialize Supabase with enhanced connection management
  try {
    debugPrint('🚀 [STARTUP] Initializing Supabase...');
    final success = await SupabaseConnectionService.initialize(
      maxRetries: 3,
      timeout: const Duration(seconds: 10),
      retryDelay: const Duration(seconds: 2),
    );

    if (success) {
      debugPrint('🚀 [STARTUP] Supabase initialized successfully');
      Logger.info('Supabase initialized successfully');
    } else {
      debugPrint('⚠️ [STARTUP] Supabase connection failed, offline mode enabled');
      Logger.warning('Supabase connection failed (optional feature, using offline mode)');
    }
  } catch (e) {
    debugPrint('❌ [STARTUP] Supabase initialization error: $e');
    Logger.warning('Supabase initialization failed (optional feature, using offline mode): $e');
  }

  // Initialize Firebase Remote Config (synchronously to ensure Firebase is ready)
  try {
    debugPrint('🚀 [STARTUP] Initializing Firebase Remote Config...');
    await RemoteConfigService().initialize();
    debugPrint('🚀 [STARTUP] Remote Config initialized successfully');
    Logger.info('Remote Config initialized successfully');
  } catch (e) {
    debugPrint('⚠️ [STARTUP] Remote Config initialization failed: $e');
    Logger.warning('Remote Config initialization failed (using default values): $e');
  }

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
  
  // Initialize ATT (App Tracking Transparency) first - required before ads on iOS 14.5+
  if (!kIsWeb) {
    try {
      debugPrint('🔒 [ATT] Requesting App Tracking Transparency authorization...');
      final attStatus = await AttService.instance.requestTrackingAuthorization();
      debugPrint('🔒 [ATT] Authorization status: $attStatus');
      Logger.info('ATT authorization status: $attStatus');
    } catch (e) {
      debugPrint('⚠️ [ATT] ATT request failed: $e');
      Logger.warning('ATT request failed: $e');
    }
  }

  // Initialize Ad Service in background - don't block app startup
  // DISABLE ADS FOR TESTING ON REAL DEVICES
  const bool disableAdsForTesting = false; // Enable ads for release build

  debugPrint('🎯 [ADMOB] kIsWeb: $kIsWeb, DISABLE_ADS_FOR_TESTING: $disableAdsForTesting');
  debugPrint('🎯 [ADMOB] Environment.enableAds: ${Environment.enableAds}');
  debugPrint('🎯 [ADMOB] Environment.admobAppId: ${Environment.admobAppId}');

  if (!kIsWeb && !disableAdsForTesting) {
    // Don't await - let it run in the background
    Future(() async {
      try {
        debugPrint('🎯 [ADMOB] Starting Ad Service initialization in background...');
        Logger.info('Initializing Ad Service in background...');
        await AdService.instance.initialize();
        debugPrint('✅ [ADMOB] Ad Service initialized successfully in background');
        Logger.info('Ad Service initialized successfully in background');
      } catch (e) {
        debugPrint('❌ [ADMOB] Ad Service initialization failed in background: $e');
        Logger.error('Ad Service initialization failed in background: $e');
      }
    });
  } else {
    debugPrint('⚠️ [ADMOB] Ad Service disabled for testing');
    Logger.info('Ad Service disabled for testing');
  }
  
  // Initialize SharedPreferences (used by user settings)
  try {
    await SharedPreferences.getInstance();
  } catch (e) {
    Logger.error('SharedPreferences initialization failed', e);
  }

  // 게스트 모드 자동 활성화: 비로그인 시 게스트로 채팅 사용 가능
  try {
    debugPrint('🎭 [STARTUP] Checking guest mode...');
    final prefs = await SharedPreferences.getInstance();
    final hasSession = Supabase.instance.client.auth.currentSession != null;

    if (!hasSession) {
      // 비로그인 상태면 게스트 모드 활성화
      await prefs.setBool('isGuestMode', true);
      debugPrint('🎭 [STARTUP] Guest mode enabled (no session)');
    } else {
      // 로그인 상태면 게스트 모드 해제
      await prefs.setBool('isGuestMode', false);
      debugPrint('🎭 [STARTUP] Guest mode disabled (session exists)');
    }
  } catch (e) {
    debugPrint('⚠️ [STARTUP] Guest mode check failed: $e');
  }

  // Initialize test authentication if in test mode
  if (TestAuthService.isTestMode()) {
    try {
      debugPrint('🔧 [TEST] Initializing test authentication...');
      final testAuthService = TestAuthService();
      await testAuthService.autoLoginTestAccount();
      debugPrint('🔧 [TEST] Test authentication initialized');
    } catch (e) {
      debugPrint('🔧 [TEST] Test authentication failed: $e');
    }
  }

  // Initialize RouteObserver Logger (debug mode only)
  if (kDebugMode) {
    try {
      debugPrint('🔍 [STARTUP] Initializing RouteObserver Logger...');
      await RouteObserverLogger().loadFromFile();
      debugPrint('🔍 [STARTUP] RouteObserver Logger initialized');
    } catch (e) {
      debugPrint('⚠️ [STARTUP] RouteObserver Logger initialization failed: $e');
    }
  }

  // Initialize Error Reporter Service (all modes)
  try {
    debugPrint('🚨 [STARTUP] Initializing Error Reporter Service...');
    await ErrorReporterService().initialize();
    debugPrint('🚨 [STARTUP] Error Reporter Service initialized');
    Logger.info('Real-time error monitoring enabled');
  } catch (e) {
    debugPrint('⚠️ [STARTUP] Error Reporter Service initialization failed: $e');
    Logger.error('Error Reporter Service initialization failed', e);
  }

  // Initialize FCM Service for push notifications
  if (!kIsWeb) {
    try {
      debugPrint('🔔 [STARTUP] Initializing FCM Service...');
      await FCMService().initialize();
      debugPrint('🔔 [STARTUP] FCM Service initialized successfully');
      Logger.info('FCM Service initialized successfully');
    } catch (e) {
      debugPrint('⚠️ [STARTUP] FCM Service initialization failed: $e');
      Logger.warning('FCM Service initialization failed (optional feature): $e');
    }
  }

  debugPrint('🚀 [STARTUP] All initializations complete, starting app...');
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
  debugPrint('🚀 [STARTUP] App started successfully');
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);
    // 🎯 사용자 폰트 설정을 앱 전체에 적용
    final userSettings = ref.watch(userSettingsProvider);

    // 위젯 데이터 준비 프로바이더 활성화 (auth 상태 변경 시 자동 실행)
    ref.read(widgetDataPreparationProvider);

    // FontSizeSystem에 스케일 팩터 동기화 (TypographyUnified용)
    FontSizeSystem.setScaleFactor(userSettings.fontScale);

    return MaterialApp.router(
      title: 'ZPZG',
      theme: FortuneDesignSystem.lightTheme(fontScale: userSettings.fontScale),
      darkTheme: FortuneDesignSystem.darkTheme(fontScale: userSettings.fontScale),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
