import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, kReleaseMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'l10n/app_localizations.dart';

import 'core/config/environment.dart';
import 'core/utils/logger.dart';
import 'firebase_options_secure.dart';
import 'routes/route_config.dart';
import 'core/design_system/theme/ds_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'core/theme/font_size_system.dart';
import 'services/remote_config_service.dart';
import 'core/services/test_auth_service.dart';
import 'services/notification/fcm_service.dart';
import 'core/services/supabase_connection_service.dart';
import 'core/utils/route_observer_logger.dart';
import 'core/services/error_reporter_service.dart';
import 'core/providers/user_settings_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/services/fortune_haptic_service.dart';
import 'core/services/chat_sync_service.dart';
import 'core/services/user_scope_service.dart';
import 'core/services/fortune_type_local_migration_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'services/deep_link_service.dart';
import 'presentation/providers/app_providers.dart';
import 'features/character/data/services/character_chat_local_service.dart';
import 'features/character/data/services/character_affinity_service.dart';
import 'core/cache/cache_service.dart' as core_cache;

void main() async {
  debugPrint('🚀 [STARTUP] App main() started');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🚀 [STARTUP] Flutter binding initialized');

  try {
    // Load environment variables - check for test environment first
    debugPrint('🚀 [STARTUP] Loading environment variables...');
    final isTestMode = TestAuthService.isTestMode();
    final envFile = Environment.resolveRuntimeEnvFile(
      isTestMode: isTestMode,
      isReleaseMode: kReleaseMode,
    );
    if (isTestMode) {
      debugPrint('🔧 [TEST] Running in test mode...');
      // CI copies test env values into .env; always load .env
      await dotenv.dotenv.load(fileName: envFile);
      TestAuthService.enableTestLogging();
    } else {
      await dotenv.dotenv.load(fileName: envFile);
      if (Environment.shouldFallbackToDefaultEnv(loadedEnvFile: envFile)) {
        debugPrint(
          '⚠️ [STARTUP] $envFile has placeholder Supabase config, falling back to ${Environment.defaultEnvFile}',
        );
        await dotenv.dotenv.load(fileName: Environment.defaultEnvFile);
      }
    }
    final resolvedEnvFile = !isTestMode &&
            Environment.shouldFallbackToDefaultEnv(loadedEnvFile: envFile)
        ? Environment.defaultEnvFile
        : envFile;
    debugPrint(
      '🚀 [STARTUP] Environment variables loaded from $resolvedEnvFile',
    );
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
  }

  debugPrint('🚀 [STARTUP] Initializing date formatting...');
  await Future.wait([
    initializeDateFormatting('ko_KR', null),
    initializeDateFormatting('en_US', null),
    initializeDateFormatting('ja_JP', null),
  ]);
  debugPrint('🚀 [STARTUP] Date formatting initialized (ko, en, ja)');

  // Initialize Hive
  try {
    debugPrint('🚀 [STARTUP] Initializing Hive...');
    await Hive.initFlutter();
    debugPrint('🚀 [STARTUP] Hive initialized successfully');
    Logger.info('Hive initialized successfully');

    // Initialize Character Chat Local Storage (카카오톡 스타일)
    debugPrint('🚀 [STARTUP] Initializing Character Chat Local Storage...');
    await CharacterChatLocalService.initialize();
    debugPrint('🚀 [STARTUP] Character Chat Local Storage initialized');

    // Initialize Character Affinity Service (호감도 영속성)
    debugPrint('🚀 [STARTUP] Initializing Character Affinity Service...');
    await CharacterAffinityService.initialize();
    debugPrint('🚀 [STARTUP] Character Affinity Service initialized');

    debugPrint('🚀 [STARTUP] Initializing Core Cache Service...');
    await core_cache.CacheService().initialize();
    debugPrint('🚀 [STARTUP] Core Cache Service initialized');
  } catch (e) {
    debugPrint('❌ [STARTUP] Hive initialization failed: $e');
    Logger.error('Hive initialization failed', e);
  }

  // Initialize Firebase
  var isFirebaseReady = false;
  try {
    debugPrint('🚀 [STARTUP] Initializing Firebase...');
    if (Firebase.apps.isNotEmpty) {
      isFirebaseReady = true;
      debugPrint('🚀 [STARTUP] Firebase already initialized');
      Logger.info('Firebase already initialized');
    } else if (!SecureFirebaseOptions.isCurrentPlatformConfigured) {
      final missingKeys = SecureFirebaseOptions.missingCurrentPlatformKeys;
      final message =
          'Firebase config missing for ${SecureFirebaseOptions.currentPlatformLabel}: ${missingKeys.join(', ')}';

      if (kReleaseMode) {
        throw Exception(
            '$message. Release startup requires Firebase configuration.');
      }

      debugPrint(
          '⚠️ [STARTUP] $message - skipping Firebase initialization in dev/test mode');
      Logger.warning('$message - Firebase disabled for dev/test startup');
    } else {
      await Firebase.initializeApp(
        options: SecureFirebaseOptions.currentPlatform,
      );
      isFirebaseReady = Firebase.apps.isNotEmpty;
      debugPrint('🚀 [STARTUP] Firebase initialized successfully');
      Logger.info('Firebase initialized successfully');
    }
  } catch (e) {
    debugPrint('❌ [STARTUP] Firebase initialization failed: $e');
    Logger.error('Firebase initialization failed', e);
    // 실패해도 앱은 계속 실행 (Remote Config, FCM 등 일부 기능 제한)
  }

  var isSupabaseReady = false;

  // Initialize Supabase with enhanced connection management
  try {
    debugPrint('🚀 [STARTUP] Initializing Supabase...');
    final success = await SupabaseConnectionService.initialize(
      maxRetries: 3,
      timeout: const Duration(seconds: 15),
      retryDelay: const Duration(seconds: 2),
    );

    if (success) {
      isSupabaseReady = true;
      debugPrint('🚀 [STARTUP] Supabase initialized successfully');
      Logger.info('Supabase initialized successfully');
    } else {
      debugPrint(
          '⚠️ [STARTUP] Supabase connection failed, offline mode enabled');
      Logger.warning(
          'Supabase connection failed (optional feature, using offline mode)');
    }
  } catch (e) {
    debugPrint('❌ [STARTUP] Supabase initialization error: $e');
    Logger.warning(
        'Supabase initialization failed (optional feature, using offline mode): $e');
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

  debugPrint(
      '🚀 [STARTUP] Critical initializations complete, starting app UI...');

  // Initialize provider overrides (SharedPreferences, etc.)
  final providerOverrides = await initializeProviders();
  debugPrint('🚀 [STARTUP] Provider overrides initialized');

  if (!kIsWeb) {
    try {
      debugPrint(
          '🔗 [STARTUP] Initializing Deep Link Service before runApp...');
      await DeepLinkService().initialize();
      debugPrint(
          '🔗 [STARTUP] Deep Link Service initialized successfully before runApp');
      Logger.info('Deep Link Service initialized before runApp');
    } catch (e) {
      debugPrint('⚠️ [STARTUP] Deep Link Service initialization failed: $e');
      Logger.warning(
          'Deep Link Service initialization failed before runApp: $e');
    }
  }

  runApp(
    ProviderScope(
      overrides: providerOverrides,
      child: const MyApp(),
    ),
  );
  debugPrint('🚀 [STARTUP] App started successfully');

  // Optional services are initialized after the first frame to avoid iOS
  // launch watchdog termination during `flutter run`.
  unawaited(_runDeferredInitializations(
    supabaseReady: isSupabaseReady,
    firebaseReady: isFirebaseReady,
  ));
}

Future<void> _runDeferredInitializations({
  required bool supabaseReady,
  required bool firebaseReady,
}) async {
  await WidgetsBinding.instance.endOfFrame;

  try {
    debugPrint('🚀 [POST_STARTUP] Initializing Haptic Service...');
    await FortuneHapticService.initialize();
    debugPrint('🚀 [POST_STARTUP] Haptic Service initialized');
  } catch (e) {
    debugPrint('⚠️ [POST_STARTUP] Haptic Service initialization failed: $e');
  }

  try {
    await FortuneTypeLocalMigrationService.runOnce();
  } catch (e) {
    debugPrint('⚠️ [POST_STARTUP] Fortune type local migration failed: $e');
  }

  if (supabaseReady) {
    try {
      debugPrint('🚀 [POST_STARTUP] Initializing User Scope Service...');
      await UserScopeService.instance.initialize();
      debugPrint('🚀 [POST_STARTUP] User Scope Service initialized');
    } catch (e) {
      debugPrint(
          '⚠️ [POST_STARTUP] User Scope Service initialization failed: $e');
    }

    try {
      debugPrint('🚀 [POST_STARTUP] Initializing Chat Sync Service...');
      await ChatSyncService.instance.initialize();
      debugPrint('🚀 [POST_STARTUP] Chat Sync Service initialized');
    } catch (e) {
      debugPrint(
          '⚠️ [POST_STARTUP] Chat Sync Service initialization failed: $e');
      Logger.warning('Chat Sync Service initialization failed: $e');
    }
  }

  try {
    debugPrint('🎭 [POST_STARTUP] Checking guest mode...');
    final prefs = await SharedPreferences.getInstance();
    final hasSession = supabaseReady
        ? SupabaseConnectionService.tryGetCurrentSession() != null
        : false;
    await prefs.setBool('isGuestMode', !hasSession);

    if (!hasSession) {
      debugPrint('🎭 [POST_STARTUP] Guest mode enabled (no session)');
    } else {
      debugPrint('🎭 [POST_STARTUP] Guest mode disabled (session exists)');
    }
  } catch (e) {
    debugPrint('⚠️ [POST_STARTUP] Guest mode check failed: $e');
  }

  if (firebaseReady) {
    try {
      debugPrint('🚀 [POST_STARTUP] Initializing Firebase Remote Config...');
      await RemoteConfigService().initialize();
      debugPrint('🚀 [POST_STARTUP] Remote Config initialized successfully');
      Logger.info('Remote Config initialized successfully');
    } catch (e) {
      debugPrint('⚠️ [POST_STARTUP] Remote Config initialization failed: $e');
      Logger.warning(
          'Remote Config initialization failed (using default values): $e');
    }
  } else {
    debugPrint(
        '⚠️ [POST_STARTUP] Firebase unavailable, skipping Remote Config initialization');
    Logger.warning(
        'Remote Config initialization skipped: Firebase unavailable');
  }

  if (kDebugMode) {
    try {
      debugPrint('🔍 [POST_STARTUP] Initializing RouteObserver Logger...');
      await RouteObserverLogger().loadFromFile();
      debugPrint('🔍 [POST_STARTUP] RouteObserver Logger initialized');
    } catch (e) {
      debugPrint(
          '⚠️ [POST_STARTUP] RouteObserver Logger initialization failed: $e');
    }
  }

  try {
    debugPrint('🚨 [POST_STARTUP] Initializing Error Reporter Service...');
    await ErrorReporterService().initialize();
    debugPrint('🚨 [POST_STARTUP] Error Reporter Service initialized');
    Logger.info('Real-time error monitoring enabled');
  } catch (e) {
    debugPrint(
        '⚠️ [POST_STARTUP] Error Reporter Service initialization failed: $e');
    Logger.error('Error Reporter Service initialization failed', e);
  }

  if (!kIsWeb) {
    if (firebaseReady) {
      try {
        debugPrint('🔔 [POST_STARTUP] Initializing FCM Service...');
        await FCMService().initialize(requestPermissions: false);
        debugPrint('🔔 [POST_STARTUP] FCM Service initialized successfully');
        Logger.info('FCM Service initialized successfully');
      } catch (e) {
        debugPrint('⚠️ [POST_STARTUP] FCM Service initialization failed: $e');
        Logger.warning(
            'FCM Service initialization failed (optional feature): $e');
      }
    } else {
      debugPrint(
          '⚠️ [POST_STARTUP] Firebase unavailable, skipping FCM Service initialization');
      Logger.warning(
          'FCM Service initialization skipped: Firebase unavailable');
    }
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);
    // 🎯 사용자 폰트 설정을 앱 전체에 적용
    final userSettings = ref.watch(userSettingsProvider);
    // 🌐 언어 설정
    final locale = ref.watch(localeProvider);

    if (SupabaseConnectionService.isInitialized) {
      ref.read(notificationDeviceSyncProvider);

      // 위젯 데이터 준비 프로바이더 활성화 (auth 상태 변경 시 자동 실행)
      ref.read(widgetDataPreparationProvider);

      // 채팅 데이터 복원 프로바이더 활성화 (로그인 시 서버에서 대화 복원)
      ref.read(chatRestorationProvider);
    }

    // FontSizeSystem에 스케일 팩터 동기화 (TypographyUnified용)
    FontSizeSystem.setScaleFactor(userSettings.fontScale);

    return MaterialApp.router(
      title: 'ZPZG',
      theme: DSTheme.light(fontScale: userSettings.fontScale),
      darkTheme: DSTheme.dark(fontScale: userSettings.fontScale),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      // Localization
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      // 🎯 디바이스 시스템 폰트 크기 설정 반영 (접근성)
      // 레이아웃 깨짐 방지를 위해 0.8 ~ 1.5 범위로 제한
      builder: (context, child) {
        final deviceTextScaler = MediaQuery.textScalerOf(context);
        final clampedScaler = deviceTextScaler.clamp(
          minScaleFactor: 0.8,
          maxScaleFactor: 1.5,
        );
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: clampedScaler),
          child: child!,
        );
      },
    );
  }
}
