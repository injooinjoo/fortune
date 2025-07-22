import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fortune/presentation/providers/providers.dart';
import '../mocks/mock_services.dart';
import '../mocks/mock_factory.dart';

/// Helper class for setting up tests
class TestHelpers {
  /// Create a test app with providers
  static Widget createTestApp({
    required Widget child,
    List<Override> overrides = const [],
    ThemeData? theme,
    Locale? locale,
  }) {
    return ProviderScope(
      overrides: [
        ...overrides,
      ],
      child: MaterialApp(
        home: child,
        theme: theme ?? ThemeData.light(),
        locale: locale ?? const Locale('ko', 'KR'),
        supportedLocales: const [
          Locale('ko', 'KR'),
          Locale('en', 'US'),
        ],
      ),
    );
  }
  
  /// Create provider overrides for testing
  static List<Override> createProviderOverrides({
    MockSupabaseClient? supabaseClient,
    MockAuthService? authService,
    MockStorageService? storageService,
    MockCacheService? cacheService,
    MockFortuneApiService? fortuneApiService,
    MockTokenApiService? tokenApiService,
    User? currentUser,
    bool isAuthenticated = false,
  }) {
    final client = supabaseClient ?? MockServiceFactory.createMockSupabaseClient();
    final auth = authService ?? MockServiceFactory.createMockAuthService(
      currentUser: currentUser,
      isAuthenticated: isAuthenticated,
    );
    final storage = storageService ?? MockServiceFactory.createMockStorageService();
    final cache = cacheService ?? MockServiceFactory.createMockCacheService();
    
    return [
      supabaseClientProvider.overrideWithValue(client),
      authServiceProvider.overrideWithValue(auth),
      storageServiceProvider.overrideWithValue(storage),
      cacheServiceProvider.overrideWithValue(cache),
      if (fortuneApiService != null)
        fortuneApiServiceProvider.overrideWithValue(fortuneApiService),
      if (tokenApiService != null)
        tokenApiServiceProvider.overrideWithValue(tokenApiService),
    ];
  }
  
  /// Pump widget with all necessary setup
  static Future<void> pumpTestWidget(
    WidgetTester tester,
    Widget widget, {
    List<Override> overrides = const [],
    ThemeData? theme,
    Locale? locale,
  }) async {
    await tester.pumpWidget(
      createTestApp(
        child: widget,
        overrides: overrides,
        theme: theme,
        locale: locale,
      ),
    );
  }
  
  /// Wait for async operations to complete
  static Future<void> waitForAsync(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }
  
  /// Find and tap a widget with text
  static Future<void> tapText(WidgetTester tester, String text) async {
    final finder = find.text(text);
    expect(finder, findsOneWidget);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
  
  /// Find and enter text in a field
  static Future<void> enterText(
    WidgetTester tester,
    String text, {
    int fieldIndex = 0,
  }) async {
    final finder = find.byType(TextField);
    expect(finder, findsWidgets);
    await tester.enterText(finder.at(fieldIndex), text);
    await tester.pumpAndSettle();
  }
  
  /// Verify navigation occurred
  static void verifyNavigation<T extends Widget>(WidgetTester tester) {
    expect(find.byType(T), findsOneWidget);
  }
  
  /// Verify error message is shown
  static void verifyErrorMessage(WidgetTester tester, String message) {
    expect(find.text(message), findsOneWidget);
  }
  
  /// Verify loading indicator
  static void verifyLoading(WidgetTester tester) {
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }
  
  /// Verify no loading indicator
  static void verifyNotLoading(WidgetTester tester) {
    expect(find.byType(CircularProgressIndicator), findsNothing);
  }
  
  /// Create authenticated state
  static List<Override> createAuthenticatedState({
    String? userId,
    String? email,
    String? name,
    int tokenBalance = 100,
  }) {
    final user = MockFactory.createSupabaseUser(
      id: userId ?? 'test-user-123',
      email: email ?? 'test@example.com',
      userMetadata: {'name': name ?? 'Test User'},
    );
    
    final userProfile = MockFactory.createUserProfile(
      id: userId ?? 'test-user-123',
      email: email ?? 'test@example.com',
      name: name ?? 'Test User',
      tokenBalance: tokenBalance,
    );
    
    return createProviderOverrides(
      currentUser: user,
      isAuthenticated: true,
    );
  }
  
  /// Create unauthenticated state
  static List<Override> createUnauthenticatedState() {
    return createProviderOverrides(
      currentUser: null,
      isAuthenticated: false,
    );
  }
  
  /// Verify widget visibility
  static void verifyWidgetVisible(WidgetTester tester, Key key) {
    expect(find.byKey(key), findsOneWidget);
  }
  
  /// Verify widget not visible
  static void verifyWidgetNotVisible(WidgetTester tester, Key key) {
    expect(find.byKey(key), findsNothing);
  }
  
  /// Scroll to widget
  static Future<void> scrollToWidget(
    WidgetTester tester,
    Finder finder, {
    double delta = 300,
  }) async {
    await tester.dragUntilVisible(
      finder,
      find.byType(Scrollable).first,
      Offset(0, -delta),
    );
  }
  
  /// Verify snackbar message
  static void verifySnackbar(WidgetTester tester, String message) {
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(message), findsOneWidget);
  }
  
  /// Dismiss snackbar
  static Future<void> dismissSnackbar(WidgetTester tester) async {
    await tester.drag(find.byType(SnackBar), const Offset(0, 50));
    await tester.pumpAndSettle();
  }
  
  /// Take screenshot for golden testing
  static Future<void> takeScreenshot(
    WidgetTester tester,
    String name,
  ) async {
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
  }
}

/// Extension for common test operations
extension TestExtensions on WidgetTester {
  /// Find widget by type with index
  Finder findByTypeAt<T extends Widget>(int index) {
    return find.byType(T).at(index);
  }
  
  /// Tap and wait
  Future<void> tapAndWait(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }
  
  /// Enter text and wait
  Future<void> enterTextAndWait(Finder finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }
  
  /// Verify text exists
  void verifyText(String text) {
    expect(find.text(text), findsOneWidget);
  }
  
  /// Verify text does not exist
  void verifyNoText(String text) {
    expect(find.text(text), findsNothing);
  }
}