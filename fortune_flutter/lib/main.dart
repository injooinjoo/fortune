import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart'; // Replaced with secure version
import 'firebase_options_secure.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/config/environment.dart';
import 'core/config/feature_flags.dart';
import 'core/utils/logger.dart';
import 'core/utils/secure_storage.dart';
import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_extensions.dart';
import 'services/cache_service.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/providers/theme_provider.dart';
import 'core/utils/url_cleaner_stub.dart'
    if (dart.library.html) 'core/utils/url_cleaner_web.dart';
import 'services/native_features_initializer.dart';
import 'services/token_monitor_service.dart';
import 'services/screenshot_detection_service.dart';
import 'services/ad_service.dart';
import 'services/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 개발 진행 상황 보고
  Logger.developmentProgress(
    'Flutter App Initialization',
    'Starting app with security enhancements',
    details: 'Environment setup, secure storage, logging system',
  );
  
  try {
    // 한국어 날짜 형식 초기화
    await initializeDateFormatting('ko_KR', null);
    
    // 환경 변수 초기화
    await Environment.initialize();
    Environment.printDebugInfo();
    Logger.securityCheckpoint('Environment variables loaded');
    
    // Firebase 초기화 (보안 버전)
    await Firebase.initializeApp(
      options: SecureFirebaseOptions.currentPlatform,
    );
    Logger.securityCheckpoint('Firebase initialized');
    
    // Kakao SDK 초기화
    kakao.KakaoSdk.init(
      nativeAppKey: Environment.kakaoAppKey,
    );
    Logger.securityCheckpoint('Kakao SDK initialized');
    
    // Supabase 초기화
    try {
      await Supabase.initialize(
        url: Environment.supabaseUrl,
        anonKey: Environment.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        debug: Environment.current != Environment.production,
      );
      Logger.securityCheckpoint('Supabase initialized');
      
      // Test the connection immediately
      try {
        final testResponse = await Supabase.instance.client.auth.signInWithPassword(
          email: 'test@test.com',
          password: 'test123'
        );
      } catch (testError) {
        if (testError.toString().contains('Invalid API key')) {
          Logger.error('Supabase API key is invalid! Please check your .env file', testError);
          debugPrint('=== SUPABASE API KEY ERROR ===');
          debugPrint('URL: ${Environment.supabaseUrl}');
          debugPrint('Key prefix: ${Environment.supabaseAnonKey.substring(0, 20)}...');
          debugPrint('Please verify:');
          debugPrint('1. The Supabase project is active');
          debugPrint('2. The API keys match those in Supabase dashboard');
          debugPrint('3. The project URL is correct');
          debugPrint('==============================');
        }
      }
    } catch (e) {
      Logger.error('Failed to initialize Supabase', e);
      rethrow;
    }
    
    // Handle initial deep link if any
    final initialUri = Uri.base;
    if (initialUri.queryParameters.containsKey('code')) {
      debugPrint('Initial URI contains auth code: ${initialUri.queryParameters['code']}');
      debugPrint('Attempting immediate session recovery...');
      
      try {
        // Try to recover session immediately
        final response = await Supabase.instance.client.auth.getSessionFromUrl(initialUri);
        if (response.session != null) {
          debugPrint('Session recovered successfully in main.dart!');
          debugPrint('User: ${response.session!.user.email}');
          
          // Clean URL after processing auth code
          if (kIsWeb) {
            cleanUrlInBrowser('/');
          }
        }
      } catch (e) {
        debugPrint('Session recovery failed in main.dart: $e');
        
        // Clean URL even on failure
        if (kIsWeb) {
          cleanUrlInBrowser('/');
        }
      }
    }
    
    // Cache 서비스 초기화
    await CacheService().initialize();
    Logger.securityCheckpoint('Cache service initialized');
    
    // Feature Flags 초기화
    await FeatureFlags.instance.initialize();
    Logger.securityCheckpoint('Feature flags initialized with Edge Functions: ${FeatureFlags.instance.isEdgeFunctionsEnabled()}');
    
    // Native platform features 초기화 (widgets, notifications)
    if (!kIsWeb) {
      await NativeFeaturesInitializer.initialize();
      Logger.securityCheckpoint('Native platform features initialized');
    }
    
    // Initialize AdMob SDK
    if (!kIsWeb && Environment.enableAds) {
      await AdService.instance.initialize();
      Logger.securityCheckpoint('AdMob SDK initialized');
    }
    
    // Initialize Analytics
    if (Environment.enableAnalytics) {
      await AnalyticsService.instance.initialize();
      Logger.securityCheckpoint('Analytics initialized');
    }
    
    // Stripe 초기화 (결제 기능이 활성화된 경우)
    if (Environment.enablePayment && !kIsWeb) {
      // Stripe is only initialized on mobile platforms
      // Web payment should be handled differently (e.g., using Stripe.js)
      final stripePublishableKey = Environment.stripePublishableKey;
      if (stripePublishableKey.isNotEmpty) {
        Stripe.publishableKey = stripePublishableKey;
        await Stripe.instance.applySettings();
        Logger.securityCheckpoint('Stripe payment service initialized');
      } else {
        Logger.warning('Stripe publishable key not found');
      }
    } else if (Environment.enablePayment && kIsWeb) {
      Logger.info('Web platform detected - Stripe will be initialized on-demand');
    }
    
    // 시스템 UI 설정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: const Color(0x00000000), // transparent
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    
    // 화면 방향 고정 (세로만)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // 기존 인증 토큰 확인
    final authTokens = await SecureStorage.getAuthTokens();
    if (authTokens['accessToken'] != null) {
      Logger.info('Found existing auth session');
      
      // Start token monitoring for authenticated users
      TokenMonitorService.instance.startMonitoring();
    }
    
    // Initialize provider overrides
    final providerOverrides = await initializeProviders();
    
    runApp(
      ProviderScope(
        overrides: providerOverrides,
        child: const FortuneApp(),
      ),
    );
    
    Logger.info('App started successfully');
    
  } catch (error, stackTrace) {
    Logger.error('Failed to initialize app', error, stackTrace);
    
    // 초기화 실패 시 에러 화면 표시
    runApp(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline, 
                  size: 64, 
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  '앱을 시작할 수 없습니다',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) => Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.fortuneTheme.subtitleText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FortuneApp extends ConsumerStatefulWidget {
  const FortuneApp({super.key});

  @override
  ConsumerState<FortuneApp> createState() => _FortuneAppState();
}

class _FortuneAppState extends ConsumerState<FortuneApp> with WidgetsBindingObserver {
  late final StreamSubscription<AuthState> _authStateSubscription;
  late final ScreenshotDetectionService _screenshotDetectionService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize screenshot detection service
    _screenshotDetectionService = ref.read(screenshotDetectionServiceProvider);
    _screenshotDetectionService.initialize();
    
    // Listen to auth state changes
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      final event = data.event;
      
      if (session != null && event == AuthChangeEvent.signedIn) {
        // Start monitoring when user signs in
        TokenMonitorService.instance.startMonitoring();
        Logger.info('Started token monitoring after sign in');
      } else if (event == AuthChangeEvent.signedOut) {
        // Stop monitoring when user signs out
        TokenMonitorService.instance.stopMonitoring();
        Logger.info('Stopped token monitoring after sign out');
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        Logger.info('Token refreshed via auth state change');
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authStateSubscription.cancel();
    TokenMonitorService.instance.dispose();
    _screenshotDetectionService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Handle app lifecycle changes
    if (state == AppLifecycleState.resumed) {
      // Check token when app comes to foreground
      if (Supabase.instance.client.auth.currentSession != null) {
        TokenMonitorService.instance.forceRefresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: 'Fortune - 운세 서비스',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}