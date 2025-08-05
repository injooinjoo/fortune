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
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/config/environment.dart';
import 'core/config/feature_flags.dart';
import 'core/utils/logger.dart';
import 'core/utils/secure_storage.dart';
import 'routes/route_config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_extensions.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.dotenv.load(fileName: ".env");
  await initializeDateFormatting('ko_KR', null);
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: SecureFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    Logger.error('Firebase initialization failed', e);
  }
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  
  // Initialize Social Login SDKs
  if (!kIsWeb) {
    // Kakao SDK
    kakao.KakaoSdk.init(
      nativeAppKey: '58c7f979c3838b7c088a6bb75c887acd', // TODO: Move to .env
    );
    
    // Naver SDK - Skip for now as initSdk might not be available
    // TODO: Initialize Naver SDK when proper method is available
  }
  
  // Initialize Analytics
  await AnalyticsService.instance.initialize();
  
  // Initialize Ad Service
  if (!kIsWeb) {
    await AdService.instance.initialize();
  }
  
  runApp(
    const ProviderScope(
      child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'Fortune - 운세 서비스',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}