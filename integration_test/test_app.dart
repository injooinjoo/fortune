/// Test App Bootstrap
/// Integration Test를 위한 앱 초기화 모듈
///
/// 주요 기능:
/// - 테스트 모드 환경 변수 로드
/// - Mock provider overrides 적용
/// - Firebase/Social SDK 초기화 스킵

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fortune/core/theme/fortune_design_system.dart';
import 'package:fortune/core/theme/font_size_system.dart';
import 'package:fortune/routes/route_config.dart';
import 'package:fortune/presentation/providers/theme_provider.dart';
import 'package:fortune/core/providers/user_settings_provider.dart';
import 'package:fortune/core/services/test_auth_service.dart';
import 'package:fortune/core/services/supabase_connection_service.dart';

/// 테스트용 앱 초기화 함수
///
/// [skipSupabase] - Supabase 초기화 스킵 여부 (기본: false)
/// [skipHive] - Hive 초기화 스킵 여부 (기본: false)
/// [overrides] - Provider 오버라이드 목록
Future<void> initializeTestApp({
  bool skipSupabase = false,
  bool skipHive = false,
  List<Override> overrides = const [],
}) async {
  debugPrint('🧪 [TEST] Initializing test app...');

  // Load test environment
  try {
    await dotenv.dotenv.load(fileName: ".env.test");
    debugPrint('🧪 [TEST] Test environment loaded');
  } catch (e) {
    debugPrint('🧪 [TEST] Failed to load .env.test, using defaults: $e');
  }

  // Initialize date formatting
  await initializeDateFormatting('ko_KR', null);
  debugPrint('🧪 [TEST] Date formatting initialized');

  // Initialize Hive (optional)
  if (!skipHive) {
    try {
      await Hive.initFlutter();
      debugPrint('🧪 [TEST] Hive initialized');
    } catch (e) {
      debugPrint('🧪 [TEST] Hive initialization skipped: $e');
    }
  }

  // Initialize Supabase (optional)
  if (!skipSupabase) {
    try {
      await SupabaseConnectionService.initialize(
        maxRetries: 1,
        timeout: const Duration(seconds: 5),
        retryDelay: const Duration(seconds: 1),
      );
      debugPrint('🧪 [TEST] Supabase initialized');
    } catch (e) {
      debugPrint('🧪 [TEST] Supabase initialization skipped: $e');
    }
  }

  // Initialize SharedPreferences
  try {
    await SharedPreferences.getInstance();
    debugPrint('🧪 [TEST] SharedPreferences initialized');
  } catch (e) {
    debugPrint('🧪 [TEST] SharedPreferences failed: $e');
  }

  // Enable test logging
  TestAuthService.enableTestLogging();

  // Auto login test account if configured
  if (TestAuthService.shouldBypassAuth()) {
    try {
      final testAuthService = TestAuthService();
      await testAuthService.autoLoginTestAccount();
      debugPrint('🧪 [TEST] Test account auto-login completed');
    } catch (e) {
      debugPrint('🧪 [TEST] Test account auto-login failed: $e');
    }
  }

  debugPrint('🧪 [TEST] Test app initialization complete');
}

/// 테스트용 앱 위젯
///
/// Provider overrides를 적용한 테스트용 MaterialApp
class TestApp extends ConsumerWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);
    final userSettings = ref.watch(userSettingsProvider);

    FontSizeSystem.setScaleFactor(userSettings.fontScale);

    return MaterialApp.router(
      title: 'Fortune Test',
      theme: TossDesignSystem.lightTheme(fontScale: userSettings.fontScale),
      darkTheme: TossDesignSystem.darkTheme(fontScale: userSettings.fontScale),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

/// 테스트용 앱을 ProviderScope로 감싸서 실행
///
/// [overrides] - Provider 오버라이드 목록
Widget createTestApp({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: const TestApp(),
  );
}
