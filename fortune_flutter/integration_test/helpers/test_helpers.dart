import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Common test helper functions for integration tests
class TestHelpers {
  /// Perform login with test credentials
  static Future<void> performLogin(
    WidgetTester tester, {
    String email = 'test@example.com',
    String password = 'TestPassword123!',
  }) async {
    // Find and tap login button if on landing page
    final loginButton = find.text('로그인');
    if (loginButton.evaluate().isNotEmpty) {
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
    }

    // Enter credentials
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), password);
    
    // Submit login
    await tester.tap(find.text('로그인').last);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// Navigate to specific tab by icon
  static Future<void> navigateToTab(WidgetTester tester, IconData icon) async {
    final tab = find.byIcon(icon);
    await tester.tap(tab);
    await tester.pumpAndSettle();
  }

  /// Scroll until widget is visible
  static Future<void> scrollToWidget(
    WidgetTester tester,
    Finder finder, {
    double delta = 100,
  }) async {
    await tester.scrollUntilVisible(
      finder,
      delta,
      scrollable: find.byType(Scrollable).first,
    );
  }

  /// Wait for loading to complete
  static Future<void> waitForLoading(WidgetTester tester) async {
    // Wait for any CircularProgressIndicator to disappear
    while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  /// Check if user is logged in by looking for home screen elements
  static bool isLoggedIn(WidgetTester tester) {
    // Check for bottom navigation or home screen indicators
    return find.byType(BottomNavigationBar).evaluate().isNotEmpty ||
           find.byIcon(Icons.home).evaluate().isNotEmpty;
  }

  /// Logout from the app
  static Future<void> performLogout(WidgetTester tester) async {
    // Navigate to profile
    await navigateToTab(tester, Icons.person);
    
    // Find and tap logout
    await scrollToWidget(tester, find.text('로그아웃'));
    await tester.tap(find.text('로그아웃'));
    await tester.pumpAndSettle();
    
    // Confirm logout
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
  }

  /// Fill date picker
  static Future<void> selectDate(
    WidgetTester tester, {
    int day = 15,
    int? month,
    int? year,
  }) async {
    // Select day
    await tester.tap(find.text(day.toString()));
    await tester.pumpAndSettle();
    
    // TODO: Add month and year selection if needed
    
    // Confirm selection
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
  }

  /// Take screenshot for debugging
  static Future<void> takeScreenshot(
    WidgetTester tester,
    String name,
  ) async {
    // Note: Actual screenshot implementation depends on test environment
    // This is a placeholder for screenshot functionality
    debugPrint('Screenshot: $name');
  }

  /// Verify snackbar message
  static void expectSnackbar(String message) {
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text(message),
      ),
      findsOneWidget,
    );
  }

  /// Dismiss keyboard if visible
  static Future<void> dismissKeyboard(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }

  /// Check for error dialog
  static bool hasErrorDialog(WidgetTester tester) {
    return find.byType(AlertDialog).evaluate().isNotEmpty &&
           find.textContaining('오류').evaluate().isNotEmpty;
  }

  /// Dismiss dialog
  static Future<void> dismissDialog(WidgetTester tester) async {
    final closeButton = find.text('확인');
    if (closeButton.evaluate().isNotEmpty) {
      await tester.tap(closeButton);
      await tester.pumpAndSettle();
    }
  }

  /// Wait and retry action if it fails
  static Future<T> retryAction<T>(
    Future<T> Function() action, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        return await action();
      } catch (e) {
        attempts++;
        if (attempts >= maxAttempts) {
          rethrow;
        }
        await Future.delayed(delay);
      }
    }
    throw Exception('Action failed after $maxAttempts attempts');
  }
}