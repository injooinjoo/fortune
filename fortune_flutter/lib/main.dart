import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'core/config/environment.dart';
import 'core/utils/logger.dart';
import 'core/utils/secure_storage.dart';
import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_extensions.dart';
import 'services/cache_service.dart';
import 'presentation/providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 개발 진행 상황 보고
  Logger.developmentProgress(
    'Flutter App Initialization',
    'Starting app with security enhancements',
    details: 'Environment setup, secure storage, logging system',
  );
  
  try {
    // 환경 변수 초기화
    await Environment.initialize();
    Environment.printDebugInfo();
    Logger.securityCheckpoint('Environment variables loaded');
    
    // Supabase 초기화
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      debug: Environment.current != Environment.production,
    );
    Logger.securityCheckpoint('Supabase initialized');
    
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
        }
      } catch (e) {
        debugPrint('Session recovery failed in main.dart: $e');
      }
    }
    
    // Cache 서비스 초기화
    await CacheService().initialize();
    Logger.securityCheckpoint('Cache service initialized');
    
    // Stripe 초기화 (결제 기능이 활성화된 경우)
    if (Environment.enablePayment) {
      final stripePublishableKey = Environment.stripePublishableKey;
      if (stripePublishableKey.isNotEmpty) {
        Stripe.publishableKey = stripePublishableKey;
        await Stripe.instance.applySettings();
        Logger.securityCheckpoint('Stripe payment service initialized');
      } else {
        Logger.warning('Stripe publishable key not found');
      }
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

class FortuneApp extends ConsumerWidget {
  const FortuneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'Fortune - 운세 서비스',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}