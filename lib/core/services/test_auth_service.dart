import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for TestAuthService
final testAuthServiceProvider = Provider<TestAuthService>((ref) {
  return TestAuthService();
});

/// Cached URL test mode flag (checked once at startup for web)
bool? _urlTestModeCache;

class TestAuthService {
  static const String _testUserIdKey = 'test_user_id';
  static const String _testSessionKey = 'test_session';
  static const String _testModeUrlParam = 'test_mode';

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Check if app is running in test mode (compile-time OR URL param for web)
  static bool isTestMode() {
    // Check compile-time environment variables first
    if (const String.fromEnvironment('FLUTTER_TEST_MODE') == 'true' ||
        const String.fromEnvironment('TEST_MODE') == 'true') {
      return true;
    }

    // Check URL parameter for web (cached for performance)
    if (kIsWeb) {
      _urlTestModeCache ??= _checkUrlTestMode();
      if (_urlTestModeCache == true) return true;
    }

    return kDebugMode && _shouldBypassAuth();
  }

  /// Check URL parameters for test_mode=true (web only)
  static bool _checkUrlTestMode() {
    if (!kIsWeb) return false;
    try {
      final uri = Uri.base;
      final testMode = uri.queryParameters[_testModeUrlParam];
      if (testMode == 'true' || testMode == '1') {
        debugPrint('🔧 [TestAuth] URL test mode detected: $uri');
        return true;
      }
    } catch (e) {
      debugPrint('🔧 [TestAuth] Error checking URL params: $e');
    }
    return false;
  }

  /// Force refresh URL test mode cache (call when URL changes)
  static void refreshUrlTestMode() {
    _urlTestModeCache = null;
  }

  /// Check if authentication should be bypassed
  static bool _shouldBypassAuth() {
    return const String.fromEnvironment('BYPASS_AUTH') == 'true';
  }

  /// Public method to check if auth should be bypassed (for testing)
  static bool shouldBypassAuth() => _shouldBypassAuth() || isTestMode();

  /// Auto-login with test account
  Future<bool> autoLoginTestAccount() async {
    if (!isTestMode()) return false;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if test session already exists
      final existingSession = prefs.getString(_testSessionKey);
      if (existingSession != null) {
        debugPrint('🔧 Test: Using existing test session');
        return true;
      }

      // Create or get test account
      final testEmail = const String.fromEnvironment('TEST_ACCOUNT_EMAIL',
          defaultValue: 'test@zpzg.com');
      final testPassword = const String.fromEnvironment('TEST_ACCOUNT_PASSWORD',
          defaultValue: 'Test123!@#');

      debugPrint('🔧 Test: Attempting auto-login with $testEmail');

      final supabase = _supabase;
      if (supabase == null) {
        debugPrint('🔧 Test: Supabase unavailable, skipping auto-login');
        return false;
      }

      // Try to sign in first
      AuthResponse? response;
      try {
        response = await supabase.auth.signInWithPassword(
          email: testEmail,
          password: testPassword,
        );
      } catch (e) {
        debugPrint('🔧 Test: Sign in failed, trying to create account: $e');
        // If sign in fails, try to create the account
        response = await supabase.auth.signUp(
          email: testEmail,
          password: testPassword,
          data: {
            'test_account': true,
            'auto_created': true,
          },
        );
      }

      if (response.user != null) {
        // Store test session info
        await prefs.setString(_testUserIdKey, response.user!.id);
        await prefs.setString(
            _testSessionKey, response.session?.accessToken ?? '');

        debugPrint(
            '🔧 Test: Auto-login successful for user ${response.user!.id}');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('🔧 Test: Auto-login failed: $e');
      return false;
    }
  }

  /// Get test session information
  Future<Map<String, String>?> getTestSession() async {
    if (!isTestMode()) return null;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_testUserIdKey);
    final sessionToken = prefs.getString(_testSessionKey);

    if (userId != null && sessionToken != null) {
      return {
        'user_id': userId,
        'access_token': sessionToken,
      };
    }

    return null;
  }

  /// Clear test session
  Future<void> clearTestSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_testUserIdKey);
    await prefs.remove(_testSessionKey);
    debugPrint('🔧 Test: Test session cleared');
  }

  /// Inject test session into app
  Future<bool> injectTestSession() async {
    if (!isTestMode()) return false;

    try {
      // First try auto-login
      final loginSuccess = await autoLoginTestAccount();
      if (!loginSuccess) return false;

      final testSession = await getTestSession();
      if (testSession == null) return false;

      // The session should already be set by autoLoginTestAccount
      final currentUser = _supabase?.auth.currentUser;
      if (currentUser?.id == testSession['user_id']) {
        debugPrint('🔧 Test: Test session successfully injected');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('🔧 Test: Failed to inject test session: $e');
      return false;
    }
  }

  /// Check if current user is test account
  bool isCurrentUserTestAccount() {
    if (!isTestMode()) return false;

    final currentUser = _supabase?.auth.currentUser;
    return currentUser?.userMetadata?['test_account'] == true ||
        currentUser?.email?.contains('test') == true;
  }

  /// Mock fortune response for testing
  Map<String, dynamic> getMockFortuneResponse(String fortuneType) {
    return {
      'id': 'test-fortune-${DateTime.now().millisecondsSinceEpoch}',
      'type': fortuneType,
      'content': '🔧 테스트 모드: 이것은 테스트용 운세입니다. 실제 운세가 아닙니다.',
      'summary': '테스트 운세 요약',
      'advice': '테스트 조언입니다.',
      'lucky_color': '#FFD700',
      'lucky_number': 7,
      'compatibility': 85,
      'created_at': DateTime.now().toIso8601String(),
      'is_test_data': true,
    };
  }

  /// Enable debug logging for tests
  static void enableTestLogging() {
    if (isTestMode()) {
      debugPrint('🔧 Test: Test mode enabled');
      debugPrint('🔧 Test: Bypass auth: ${_shouldBypassAuth()}');
      debugPrint(
          '🔧 Test: Test account: ${const String.fromEnvironment('TEST_ACCOUNT_EMAIL')}');
    }
  }
}
