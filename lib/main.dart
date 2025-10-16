import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config/environment.dart';
import 'core/utils/logger.dart';
import 'routes/route_config.dart';
import 'core/theme/toss_design_system.dart';
// // import 'presentation/providers/app_providers.dart'; // Has syntax errors
import 'presentation/providers/theme_provider.dart';
//     if (dart.library.html) 'core/utils/url_cleaner_web.dart';
import 'services/ad_service.dart';
import 'services/remote_config_service.dart';
import 'presentation/providers/font_size_provider.dart';
import 'core/services/test_auth_service.dart';
import 'core/services/supabase_connection_service.dart';
import 'core/utils/route_observer_logger.dart';

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
        await dotenv.dotenv.load(fileName: ".env.test");
        debugPrint('🔧 [TEST] Test environment variables loaded');
      } catch (e) {
        debugPrint('🔧 [TEST] Test env not found, falling back to .env: $e');
        await dotenv.dotenv.load(fileName: ".env");
      }
      TestAuthService.enableTestLogging();
    } else {
      await dotenv.dotenv.load(fileName: ".env");
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

  // Firebase is initialized automatically by the firebase_core plugin
  // No manual initialization needed here
  debugPrint('🚀 [STARTUP] Using Firebase (auto-initialized by plugin)');

  // Initialize Supabase with enhanced connection management
  try {
    debugPrint('🚀 [STARTUP] Initializing Supabase...');
    final success = await SupabaseConnectionService.initialize(
      maxRetries: 3,
      timeout: Duration(seconds: 10),
      retryDelay: Duration(seconds: 2),
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

  // Initialize Firebase Remote Config (after Firebase initialization)
  Future(() async {
    try {
      debugPrint('🚀 [STARTUP] Initializing Firebase Remote Config...');
      await RemoteConfigService().initialize();
      debugPrint('🚀 [STARTUP] Remote Config initialized successfully');
      Logger.info('Remote Config initialized successfully');
    } catch (e) {
      debugPrint('⚠️ [STARTUP] Remote Config initialization failed: $e');
      Logger.warning('Remote Config initialization failed (using default values): $e');
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

  debugPrint('🚀 [STARTUP] All initializations complete, starting app...');
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
  debugPrint('🚀 [STARTUP] App started successfully');
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
