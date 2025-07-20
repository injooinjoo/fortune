import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fortune_flutter/main.dart' as app;
import 'package:fortune_flutter/screens/auth/login_page.dart';
import 'package:fortune_flutter/screens/auth/signup_screen.dart';
import 'package:fortune_flutter/screens/home/home_screen_updated.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Tests', () {
    testWidgets('Email signup flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to signup
      final signupButton = find.text('회원가입');
      await tester.tap(signupButton);
      await tester.pumpAndSettle();

      // Fill signup form
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'TestPassword123!');
      await tester.enterText(find.byType(TextFormField).at(2), 'TestPassword123!');
      
      // Submit form
      await tester.tap(find.text('가입하기'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify navigation to onboarding or home
      expect(find.byType(HomeScreenUpdated), findsOneWidget);
    });

    testWidgets('Email login flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login
      final loginButton = find.text('로그인');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
      }

      // Fill login form
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'TestPassword123!');
      
      // Submit form
      await tester.tap(find.text('로그인').last);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify successful login
      expect(find.byType(HomeScreenUpdated), findsOneWidget);
    });

    testWidgets('Social login - Google', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find and tap Google login button
      final googleLoginButton = find.byWidgetPredicate(
        (widget) => widget is Container && 
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == Colors.white
      );
      
      if (googleLoginButton.evaluate().isNotEmpty) {
        await tester.tap(googleLoginButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        // Note: Actual Google OAuth flow cannot be tested in integration tests
        // This would open external browser/webview
      }
    });

    testWidgets('Social login - Kakao', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find and tap Kakao login button
      final kakaoLoginButton = find.byWidgetPredicate(
        (widget) => widget is Container && 
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == const Color(0xFFFEE500)
      );
      
      if (kakaoLoginButton.evaluate().isNotEmpty) {
        await tester.tap(kakaoLoginButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        // Note: Actual Kakao OAuth flow cannot be tested in integration tests
        // This would open external browser/webview
      }
    });

    testWidgets('Logout flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await _performLogin(tester);

      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Find and tap logout
      await tester.scrollUntilVisible(
        find.text('로그아웃'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('로그아웃'));
      await tester.pumpAndSettle();

      // Confirm logout
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();

      // Verify back at login screen
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('Password validation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to signup
      final signupButton = find.text('회원가입');
      await tester.tap(signupButton);
      await tester.pumpAndSettle();

      // Enter weak password
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.enterText(find.byType(TextFormField).at(2), '123');
      
      // Try to submit
      await tester.tap(find.text('가입하기'));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('비밀번호는 8자 이상이어야 합니다'), findsOneWidget);
    });

    testWidgets('Email validation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to signup
      final signupButton = find.text('회원가입');
      await tester.tap(signupButton);
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.enterText(find.byType(TextFormField).at(1), 'TestPassword123!');
      await tester.enterText(find.byType(TextFormField).at(2), 'TestPassword123!');
      
      // Try to submit
      await tester.tap(find.text('가입하기'));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('올바른 이메일 형식이 아닙니다'), findsOneWidget);
    });
  });
}

// Helper function for login
Future<void> _performLogin(WidgetTester tester) async {
  final loginButton = find.text('로그인');
  if (loginButton.evaluate().isNotEmpty) {
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
  }

  await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
  await tester.enterText(find.byType(TextFormField).at(1), 'TestPassword123!');
  
  await tester.tap(find.text('로그인').last);
  await tester.pumpAndSettle(const Duration(seconds: 3));
}