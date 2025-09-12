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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables
    await dotenv.dotenv.load(fileName: ".env");
  } catch (e) {
    print('Warning: Could not load .env file: $e');
  }
  
  await initializeDateFormatting('ko_KR', null);
  
  // Initialize Hive
  try {
    await Hive.initFlutter();
    Logger.info('Hive initialized successfully');
  } catch (e) {
    Logger.error('Hive initialization failed', e);
  }
  
  // Initialize Firebase - wrapped in try-catch to prevent crash
  try {
    await Firebase.initializeApp(
      options: SecureFirebaseOptions.currentPlatform,
    );
    Logger.info('Firebase initialized successfully');
  } catch (e) {
    Logger.error('Firebase initialization failed', e);
    // Continue without Firebase
  }
  
  // Initialize Supabase with error handling
  try {
    final supabaseUrl = dotenv.dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.dotenv.env['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl != null && supabaseAnonKey != null && 
        supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      Logger.info('Supabase initialized successfully');
    } else {
      Logger.error('Supabase credentials not found in environment');
    }
  } catch (e) {
    Logger.error('Supabase initialization failed', e);
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
  
  // Initialize Analytics with error handling
  try {
    await AnalyticsService.instance.initialize();
    Logger.info('Analytics initialized');
  } catch (e) {
    Logger.error('Analytics initialization failed', e);
  }
  
  // Initialize Remote Config with error handling
  try {
    await RemoteConfigService().initialize();
    Logger.info('Remote Config initialized');
  } catch (e) {
    Logger.error('Remote Config initialization failed', e);
  }
  
  // Initialize Ad Service with error handling
  if (!kIsWeb) {
    try {
      await AdService.instance.initialize();
      Logger.info('Ad Service initialized');
    } catch (e) {
      Logger.error('Ad Service initialization failed', e);
    }
  }
  
  // Initialize SharedPreferences
  SharedPreferences? sharedPreferences;
  try {
    sharedPreferences = await SharedPreferences.getInstance();
  } catch (e) {
    Logger.error('SharedPreferences initialization failed', e);
  }
  
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
