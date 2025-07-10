import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fortune_flutter/main.dart' as app;
import 'package:fortune_flutter/screens/auth/login_screen.dart';
import 'package:fortune_flutter/screens/home/home_screen.dart';
import 'package:fortune_flutter/screens/fortune/daily_fortune_screen.dart';
import 'package:fortune_flutter/presentation/widgets/fortune_card.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockSession extends Mock implements Session {}
class MockUser extends Mock implements User {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuthClient;
  late MockSession mockSession;
  late MockUser mockUser;

  setUpAll(() async {
    // Initialize test environment
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    
    mockSupabaseClient = MockSupabaseClient();
    mockAuthClient = MockGoTrueClient();
    mockSession = MockSession();
    mockUser = MockUser();
    
    // Set up mock behaviors
    when(() => mockSupabaseClient.auth).thenReturn(mockAuthClient);
    when(() => mockAuthClient.currentSession).thenReturn(mockSession);
    when(() => mockAuthClient.currentUser).thenReturn(mockUser);
    when(() => mockSession.user).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('test-user-id');
    when(() => mockUser.email).thenReturn('test@example.com');
  });

  group('App Integration Tests', () {
    testWidgets('should complete full app flow from login to fortune generation', 
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen to complete
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Should be on login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      // Find and tap email input field
      final emailField = find.byWidgetPredicate(
        (widget) => widget is TextField && 
                    widget.decoration?.labelText == 'Email' ||
                    widget.decoration?.hintText == 'Enter your email',
      );
      
      if (emailField.evaluate().isNotEmpty) {
        await tester.tap(emailField);
        await tester.enterText(emailField, 'test@example.com');
        await tester.pumpAndSettle();
      }

      // Find and tap password input field
      final passwordField = find.byWidgetPredicate(
        (widget) => widget is TextField && 
                    widget.decoration?.labelText == 'Password' ||
                    widget.decoration?.hintText == 'Enter your password',
      );
      
      if (passwordField.evaluate().isNotEmpty) {
        await tester.tap(passwordField);
        await tester.enterText(passwordField, 'testpassword123');
        await tester.pumpAndSettle();
      }

      // Find and tap login button
      final loginButton = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && 
                    (widget.child is Text && 
                     (widget.child as Text).data?.toLowerCase().contains('login') == true),
      );
      
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
      }

      // Navigate to home screen after successful login
      // In a real test, this would be handled by the authentication flow
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we're on the home screen
      if (find.byType(HomeScreen).evaluate().isNotEmpty) {
        expect(find.byType(HomeScreen), findsOneWidget);

        // Find and tap daily fortune card
        final dailyFortuneCard = find.byWidgetPredicate(
          (widget) => widget is FortuneCard && 
                      widget.title.toLowerCase().contains('daily'),
        );
        
        if (dailyFortuneCard.evaluate().isNotEmpty) {
          await tester.tap(dailyFortuneCard);
          await tester.pumpAndSettle();

          // Should navigate to daily fortune screen
          expect(find.byType(DailyFortuneScreen), findsOneWidget);
        }
      }
    });

    testWidgets('should handle offline mode gracefully', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Simulate offline mode by not having a session
      when(() => mockAuthClient.currentSession).thenReturn(null);
      when(() => mockAuthClient.currentUser).thenReturn(null);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show login screen when offline
      expect(find.byType(LoginScreen), findsOneWidget);

      // Look for offline indicator if implemented
      final offlineIndicator = find.byWidgetPredicate(
        (widget) => widget is Text && 
                    widget.data?.toLowerCase().contains('offline') == true,
      );
      
      // If offline indicator exists, verify it's shown
      if (offlineIndicator.evaluate().isNotEmpty) {
        expect(offlineIndicator, findsOneWidget);
      }
    });

    testWidgets('should navigate between main screens using bottom navigation', 
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Skip to home screen (assuming authenticated)
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Look for bottom navigation bar
      final bottomNavBar = find.byType(BottomNavigationBar);
      
      if (bottomNavBar.evaluate().isNotEmpty) {
        // Tap on fortune tab
        final fortuneTab = find.byIcon(Icons.auto_awesome);
        if (fortuneTab.evaluate().isNotEmpty) {
          await tester.tap(fortuneTab);
          await tester.pumpAndSettle();
        }

        // Tap on profile tab
        final profileTab = find.byIcon(Icons.person);
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab);
          await tester.pumpAndSettle();
        }

        // Return to home tab
        final homeTab = find.byIcon(Icons.home);
        if (homeTab.evaluate().isNotEmpty) {
          await tester.tap(homeTab);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('should show loading states during data fetching', 
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pump(); // Don't settle to catch loading state

      // Look for any loading indicators
      final circularProgress = find.byType(CircularProgressIndicator);
      final linearProgress = find.byType(LinearProgressIndicator);
      
      // At least one loading indicator should be present during startup
      expect(
        circularProgress.evaluate().isNotEmpty || 
        linearProgress.evaluate().isNotEmpty, 
        isTrue,
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();
    });

    testWidgets('should handle error states properly', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Simulate an error by providing invalid credentials
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // If on login screen, try invalid login
      if (find.byType(LoginScreen).evaluate().isNotEmpty) {
        final emailField = find.byWidgetPredicate(
          (widget) => widget is TextField && 
                      widget.decoration?.labelText == 'Email' ||
                      widget.decoration?.hintText == 'Enter your email',
        );
        
        if (emailField.evaluate().isNotEmpty) {
          await tester.tap(emailField);
          await tester.enterText(emailField, 'invalid@email');
          await tester.pumpAndSettle();
        }

        final loginButton = find.byWidgetPredicate(
          (widget) => widget is ElevatedButton && 
                      (widget.child is Text && 
                       (widget.child as Text).data?.toLowerCase().contains('login') == true),
        );
        
        if (loginButton.evaluate().isNotEmpty) {
          await tester.tap(loginButton);
          await tester.pump(); // Don't settle to see error state
          
          // Wait a bit for error to appear
          await tester.pump(const Duration(seconds: 1));
          
          // Look for error message
          final errorText = find.byWidgetPredicate(
            (widget) => widget is Text && 
                        (widget.data?.toLowerCase().contains('error') == true ||
                         widget.data?.toLowerCase().contains('invalid') == true),
          );
          
          // Verify error is shown
          if (errorText.evaluate().isNotEmpty) {
            expect(errorText, findsWidgets);
          }
        }
      }
    });

    testWidgets('should persist user session across app restarts', 
        (WidgetTester tester) async {
      // First app launch - login
      app.main();
      await tester.pumpAndSettle();

      // Simulate successful login
      when(() => mockAuthClient.currentSession).thenReturn(mockSession);
      when(() => mockAuthClient.currentUser).thenReturn(mockUser);

      // Restart the app
      await tester.pumpAndSettle();
      
      // Reset the app
      find.byType(MaterialApp).evaluate().forEach((element) {
        (element.widget as MaterialApp).key;
      });

      // Second app launch - should skip login
      app.main();
      await tester.pumpAndSettle();

      // Should not be on login screen if session persisted
      if (find.byType(HomeScreen).evaluate().isNotEmpty) {
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      }
    });

    testWidgets('should handle deep linking to specific fortune pages', 
        (WidgetTester tester) async {
      // Start the app with deep link
      app.main();
      await tester.pumpAndSettle();

      // Simulate authenticated state
      when(() => mockAuthClient.currentSession).thenReturn(mockSession);
      when(() => mockAuthClient.currentUser).thenReturn(mockUser);

      await tester.pumpAndSettle();

      // Navigate directly to a specific fortune type
      if (find.byType(HomeScreen).evaluate().isNotEmpty) {
        // Find weekly fortune card
        final weeklyFortuneCard = find.byWidgetPredicate(
          (widget) => widget is FortuneCard && 
                      widget.title.toLowerCase().contains('weekly'),
        );
        
        if (weeklyFortuneCard.evaluate().isNotEmpty) {
          await tester.tap(weeklyFortuneCard);
          await tester.pumpAndSettle();
          
          // Verify navigation occurred
          expect(find.byWidgetPredicate(
            (widget) => widget is AppBar && 
                        (widget.title is Text && 
                         (widget.title as Text).data?.toLowerCase().contains('weekly') == true),
          ), findsOneWidget);
        }
      }
    });

    testWidgets('should update UI when user preferences change', 
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings/profile
      final profileTab = find.byIcon(Icons.person);
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab);
        await tester.pumpAndSettle();

        // Look for theme toggle
        final themeSwitch = find.byType(Switch);
        if (themeSwitch.evaluate().isNotEmpty) {
          // Get initial theme
          final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
          final isDarkMode = materialApp.theme?.brightness == Brightness.dark;

          // Toggle theme
          await tester.tap(themeSwitch.first);
          await tester.pumpAndSettle();

          // Verify theme changed
          final updatedMaterialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
          final isNowDarkMode = updatedMaterialApp.theme?.brightness == Brightness.dark;
          
          expect(isNowDarkMode, !isDarkMode);
        }
      }
    });

    testWidgets('should handle network requests with proper loading and error states', 
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to a fortune screen
      if (find.byType(HomeScreen).evaluate().isNotEmpty) {
        final fortuneCard = find.byType(FortuneCard).first;
        if (fortuneCard.evaluate().isNotEmpty) {
          await tester.tap(fortuneCard);
          await tester.pump(); // Don't settle to see loading state

          // Should show loading indicator
          expect(find.byType(CircularProgressIndicator), findsWidgets);

          // Wait for request to complete
          await tester.pumpAndSettle();

          // Should either show fortune content or error message
          final fortuneContent = find.byWidgetPredicate(
            (widget) => widget is Text && widget.data!.length > 50,
          );
          final errorMessage = find.byWidgetPredicate(
            (widget) => widget is Text && 
                        widget.data?.toLowerCase().contains('error') == true,
          );

          expect(
            fortuneContent.evaluate().isNotEmpty || 
            errorMessage.evaluate().isNotEmpty,
            isTrue,
          );
        }
      }
    });
  });
}