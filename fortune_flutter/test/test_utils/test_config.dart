import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Base test configuration for all tests
class TestConfig {
  static void setupTestEnvironment() {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Register fallback values for mocktail
    registerFallbackValue(Uri());
    registerFallbackValue(const Duration(seconds: 1));
    registerFallbackValue(StackTrace.current);
  }
  
  /// Wrap widget with necessary providers for testing
  static Widget wrapWithProviders(
    Widget child, {
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: child,
        locale: const Locale('ko', 'KR'),
        supportedLocales: const [
          Locale('ko', 'KR'),
          Locale('en', 'US'),
        ],
      ),
    );
  }
  
  /// Create a widget tester with providers
  static Future<void> pumpWidget(
    WidgetTester tester,
    Widget widget, {
    List<Override> overrides = const [],
  }) async {
    await tester.pumpWidget(
      wrapWithProviders(widget, overrides: overrides),
    );
  }
  
  /// Common test timeout
  static const defaultTimeout = Timeout(Duration(seconds: 10));
  
  /// Integration test timeout
  static const integrationTimeout = Timeout(Duration(seconds: 30));
}

/// Extension methods for testing
extension WidgetTesterExtensions on WidgetTester {
  /// Find widget by key with type safety
  Finder findByKey<T extends Widget>(Key key) {
    return find.byKey(key);
  }
  
  /// Pump and settle with timeout
  Future<void> pumpAndSettleWithTimeout({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.build, timeout);
  }
  
  /// Enter text in a specific text field
  Future<void> enterTextByKey(Key key, String text) async {
    await enterText(find.byKey(key), text);
  }
  
  /// Tap a widget by key
  Future<void> tapByKey(Key key) async {
    await tap(find.byKey(key));
  }
  
  /// Scroll until visible with custom parameters
  Future<void> scrollUntilVisibleByKey(
    Key key, {
    double delta = 100,
    int maxScrolls = 20,
    Duration duration = const Duration(milliseconds: 50),
  }) async {
    final finder = find.byKey(key);
    var scrolls = 0;
    
    while (!finder.evaluate().isNotEmpty && scrolls < maxScrolls) {
      await drag(find.byType(Scrollable).first, Offset(0, -delta));
      await pump(duration);
      scrolls++;
    }
  }
}

/// Test keys for consistent widget identification
class TestKeys {
  // Auth keys
  static const emailField = Key('email_field');
  static const passwordField = Key('password_field');
  static const loginButton = Key('login_button');
  static const signupButton = Key('signup_button');
  static const logoutButton = Key('logout_button');
  
  // Social auth keys
  static const googleLoginButton = Key('google_login_button');
  static const kakaoLoginButton = Key('kakao_login_button');
  static const naverLoginButton = Key('naver_login_button');
  static const appleLoginButton = Key('apple_login_button');
  
  // Navigation keys
  static const homeTab = Key('home_tab');
  static const fortuneTab = Key('fortune_tab');
  static const profileTab = Key('profile_tab');
  
  // Fortune keys
  static const fortuneCard = Key('fortune_card');
  static const generateFortuneButton = Key('generate_fortune_button');
  static const fortuneContent = Key('fortune_content');
  
  // Token keys
  static const tokenBalance = Key('token_balance');
  static const purchaseTokenButton = Key('purchase_token_button');
  
  // Profile keys
  static const profileAvatar = Key('profile_avatar');
  static const profileName = Key('profile_name');
  static const editProfileButton = Key('edit_profile_button');
}

/// Common test matchers
class TestMatchers {
  /// Matcher for finding Korean text
  static Matcher containsKoreanText(String text) {
    return findsOneWidget;
  }
  
  /// Matcher for finding widgets with specific properties
  static Finder findByPredicate<T extends Widget>(bool Function(T) predicate) {
    return find.byWidgetPredicate((widget) => widget is T && predicate(widget));
  }
}