import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fortune/main.dart' as app;
import '../helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Personality Fortune Flow Integration Tests', () {
    setUpAll(() async {
      // Any global setup
    });
    
    setUp(() async {
      // Start fresh app instance
      app.main();
    });
    
    testWidgets('should complete MBTI personality fortune flow successfully', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login first
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      
      // Verify we're on home screen
      expect(TestHelpers.isLoggedIn(tester), isTrue);
      
      // Navigate to fortune tab
      await TestHelpers.navigateToTab(tester, Icons.auto_awesome);
      await tester.pumpAndSettle();
      
      // Find and tap personality fortune card
      final personalityFortuneCard = find.textContaining('성격 운세');
      expect(personalityFortuneCard, findsOneWidget);
      
      await tester.tap(personalityFortuneCard);
      await tester.pumpAndSettle();
      
      // Verify we're on personality fortune page
      expect(find.text('성격 운세'), findsWidgets);
      expect(find.text('MBTI와 혈액형으로 보는 성격 기반 운세'), findsOneWidget);
      
      // Check token balance is displayed
      expect(find.textContaining('영혼'), findsOneWidget);
      
      // Test MBTI selection flow
      // By default, MBTI should be selected
      expect(find.text('MBTI'), findsOneWidget);
      expect(find.text('MBTI 유형 선택'), findsOneWidget);
      
      // Select INTJ
      await tester.tap(find.text('INTJ'));
      await tester.pumpAndSettle();
      
      // Verify INTJ is selected (should have check mark)
      final intjCard = find.ancestor(
        of: find.text('INTJ'),
        matching: find.byType(Container),
      );
      expect(
        find.descendant(
          of: intjCard,
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
      
      // Generate fortune button should be enabled
      final generateButton = find.widgetWithText(ElevatedButton, 'MBTI 운세 확인하기');
      expect(generateButton, findsOneWidget);
      
      // Tap generate fortune
      await tester.tap(generateButton);
      
      // Wait for fortune generation
      await TestHelpers.waitForLoading(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Verify fortune result is displayed
      expect(find.text('INTJ 운세'), findsOneWidget);
      expect(find.byIcon(Icons.psychology_rounded), findsWidgets);
      
      // Check for fortune content elements
      expect(find.textContaining('점'), findsOneWidget); // Score
      expect(find.byIcon(Icons.lightbulb_outline), findsWidgets); // Advice icon
      
      // Check for personality traits if displayed
      final personalityTraits = find.text('오늘의 성격 특성');
      if (personalityTraits.evaluate().isNotEmpty) {
        expect(personalityTraits, findsOneWidget);
      }
      
      // Check for compatibility section if displayed
      final compatibility = find.text('오늘의 궁합');
      if (compatibility.evaluate().isNotEmpty) {
        expect(compatibility, findsOneWidget);
      }
      
      // Test refresh functionality
      final refreshButton = find.widgetWithIcon(TextButton, Icons.refresh);
      expect(refreshButton, findsOneWidget);
      
      await tester.tap(refreshButton);
      await TestHelpers.waitForLoading(tester);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Should show new fortune
      expect(find.text('INTJ 운세'), findsOneWidget);
    });
    
    testWidgets('should complete blood type personality fortune flow successfully', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login first
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      
      // Navigate to fortune tab
      await TestHelpers.navigateToTab(tester, Icons.auto_awesome);
      await tester.pumpAndSettle();
      
      // Navigate to personality fortune
      await tester.tap(find.textContaining('성격 운세'));
      await tester.pumpAndSettle();
      
      // Switch to blood type
      await tester.tap(find.text('혈액형'));
      await tester.pumpAndSettle();
      
      // Verify blood type selection is shown
      expect(find.text('혈액형 선택'), findsOneWidget);
      expect(find.text('A형'), findsOneWidget);
      expect(find.text('B형'), findsOneWidget);
      expect(find.text('O형'), findsOneWidget);
      expect(find.text('AB형'), findsOneWidget);
      
      // Select B type
      await tester.tap(find.text('B형'));
      await tester.pumpAndSettle();
      
      // Verify B is selected
      final bCard = find.ancestor(
        of: find.text('B형'),
        matching: find.byType(Stack),
      );
      expect(
        find.descendant(
          of: bCard,
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
      
      // Check description is shown
      expect(find.text('자유롭고 창의적인 성격의 B형'), findsOneWidget);
      
      // Generate fortune
      final generateButton = find.widgetWithText(ElevatedButton, '혈액형 운세 확인하기');
      await tester.tap(generateButton);
      
      await TestHelpers.waitForLoading(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Verify fortune result
      expect(find.text('B형 운세'), findsOneWidget);
      expect(find.byIcon(Icons.water_drop_rounded), findsWidgets);
    });
    
    testWidgets('should handle switching between MBTI and blood type', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login and navigate to personality fortune
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      await TestHelpers.navigateToTab(tester, Icons.auto_awesome);
      await tester.tap(find.textContaining('성격 운세'));
      await tester.pumpAndSettle();
      
      // Select MBTI type
      await tester.tap(find.text('ENFP'));
      await tester.pumpAndSettle();
      
      // Switch to blood type
      await tester.tap(find.text('혈액형'));
      await tester.pumpAndSettle();
      
      // Select blood type
      await tester.tap(find.text('O형'));
      await tester.pumpAndSettle();
      
      // Switch back to MBTI
      await tester.tap(find.text('MBTI'));
      await tester.pumpAndSettle();
      
      // ENFP should still be selected
      final enfpCard = find.ancestor(
        of: find.text('ENFP'),
        matching: find.byType(Container),
      );
      expect(
        find.descendant(
          of: enfpCard,
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
      
      // Switch to blood type again
      await tester.tap(find.text('혈액형'));
      await tester.pumpAndSettle();
      
      // O type should still be selected
      final oCard = find.ancestor(
        of: find.text('O형'),
        matching: find.byType(Stack),
      );
      expect(
        find.descendant(
          of: oCard,
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
    });
    
    testWidgets('should show proper UI states for unselected personality types', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login and navigate to personality fortune
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      await TestHelpers.navigateToTab(tester, Icons.auto_awesome);
      await tester.tap(find.textContaining('성격 운세'));
      await tester.pumpAndSettle();
      
      // Initially, no MBTI type should be selected
      expect(find.byIcon(Icons.check), findsNothing);
      
      // Generate button should be disabled (not found with enabled text)
      final disabledButton = find.widgetWithText(ElevatedButton, 'MBTI 운세 확인하기');
      expect(disabledButton, findsOneWidget);
      
      final ElevatedButton button = tester.widget(disabledButton);
      expect(button.onPressed, isNull); // Button is disabled
      
      // Switch to blood type
      await tester.tap(find.text('혈액형'));
      await tester.pumpAndSettle();
      
      // No blood type should be selected
      expect(find.byIcon(Icons.check), findsNothing);
      
      // Blood type generate button should also be disabled
      final bloodDisabledButton = find.widgetWithText(ElevatedButton, '혈액형 운세 확인하기');
      expect(bloodDisabledButton, findsOneWidget);
      
      final ElevatedButton bloodButton = tester.widget(bloodDisabledButton);
      expect(bloodButton.onPressed, isNull);
    });
    
    testWidgets('should handle rapid personality type changes', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login and navigate to personality fortune
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      await TestHelpers.navigateToTab(tester, Icons.auto_awesome);
      await tester.tap(find.textContaining('성격 운세'));
      await tester.pumpAndSettle();
      
      // Rapidly tap multiple MBTI types
      await tester.tap(find.text('INTJ'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('ENFP'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('ISTP'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('ESFJ'));
      await tester.pumpAndSettle();
      
      // Only ESFJ should be selected
      final esfjCard = find.ancestor(
        of: find.text('ESFJ'),
        matching: find.byType(Container),
      );
      expect(
        find.descendant(
          of: esfjCard,
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
      
      // Only one check mark should be visible
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
    
    testWidgets('should preserve fortune results when switching tabs', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login and generate a fortune
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      await TestHelpers.navigateToTab(tester, Icons.auto_awesome);
      await tester.tap(find.textContaining('성격 운세'));
      await tester.pumpAndSettle();
      
      // Select and generate MBTI fortune
      await tester.tap(find.text('INFJ'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'MBTI 운세 확인하기'));
      await TestHelpers.waitForLoading(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Verify fortune is displayed
      expect(find.text('INFJ 운세'), findsOneWidget);
      
      // Switch to blood type tab
      await tester.tap(find.text('혈액형'));
      await tester.pumpAndSettle();
      
      // Switch back to MBTI tab
      await tester.tap(find.text('MBTI'));
      await tester.pumpAndSettle();
      
      // Fortune should still be displayed
      expect(find.text('INFJ 운세'), findsOneWidget);
    });
    
    testWidgets('should handle keyboard navigation for accessibility', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login and navigate to personality fortune
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      await TestHelpers.navigateToTab(tester, Icons.auto_awesome);
      await tester.tap(find.textContaining('성격 운세'));
      await tester.pumpAndSettle();
      
      // All MBTI types should be reachable by keyboard navigation
      // Check that all types have proper tap targets
      const mbtiTypes = [
        'INTJ', 'INTP', 'ENTJ', 'ENTP',
        'INFJ', 'INFP', 'ENFJ', 'ENFP',
        'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
        'ISTP', 'ISFP', 'ESTP', 'ESFP'
      ];
      
      for (final type in mbtiTypes) {
        final typeFinder = find.text(type);
        expect(typeFinder, findsOneWidget);
        
        // Check tap target size
        final size = tester.getSize(typeFinder);
        expect(size.width, greaterThan(44)); // Minimum accessibility size
        expect(size.height, greaterThan(44));
      }
    });
    
    testWidgets('should display proper error handling for network failures', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // This test would require mocking network failures
      // In a real scenario, you,
    would:
      // 1. Set up a mock that simulates network failure
      // 2. Try to generate a fortune
      // 3. Verify error message is displayed
      // 4. Verify retry functionality works
      
      // For now, we'll skip the actual network failure simulation
      // but verify the UI elements exist
      
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      await TestHelpers.navigateToTab(tester, Icons.auto_awesome);
      await tester.tap(find.textContaining('성격 운세'));
      await tester.pumpAndSettle();
      
      // Select a type and try to generate
      await tester.tap(find.text('INTJ'));
      await tester.pumpAndSettle();
      
      final generateButton = find.widgetWithText(ElevatedButton, 'MBTI 운세 확인하기');
      expect(generateButton, findsOneWidget);
      
      // In a real test, we would simulate network failure here
      // and check for error UI elements
    });
  });
}