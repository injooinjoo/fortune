import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fortune_flutter/main.dart' as app;
import 'package:fortune_flutter/features/fortune/presentation/pages/fortune_list_page.dart';
import 'package:fortune_flutter/features/fortune/presentation/pages/compatibility_page.dart';
import 'package:fortune_flutter/features/fortune/presentation/pages/marriage_fortune_page.dart';
import 'package:fortune_flutter/features/fortune/presentation/pages/chemistry_fortune_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fortune Generation Tests', () {
    setUpAll(() async {
      app.main();
    });

    testWidgets('Navigate to fortune list', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login first (assuming test user exists)
      await _performQuickLogin(tester);
      
      // Navigate to fortune section
      final fortuneTab = find.byIcon(Icons.auto_awesome);
      await tester.tap(fortuneTab);
      await tester.pumpAndSettle();
      
      // Verify fortune list page
      expect(find.byType(FortuneListPage), findsOneWidget);
    });

    testWidgets('Generate daily fortune', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to fortune section
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();
      
      // Find and tap daily fortune card
      final dailyFortuneCard = find.text('오늘의 운세');
      if (dailyFortuneCard.evaluate().isNotEmpty) {
        await tester.tap(dailyFortuneCard);
        await tester.pumpAndSettle();
        
        // Wait for fortune generation
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        // Verify fortune result elements
        expect(find.text('오늘의 운세'), findsWidgets);
        expect(find.byType(Card), findsWidgets);
      }
    });

    testWidgets('Generate compatibility fortune', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to fortune section
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();
      
      // Find and tap compatibility fortune
      final compatibilityCard = find.text('궁합');
      if (compatibilityCard.evaluate().isNotEmpty) {
        await tester.tap(compatibilityCard);
        await tester.pumpAndSettle();
        
        // Fill partner information
        await _fillPartnerInfo(tester);
        
        // Generate fortune
        await tester.tap(find.text('궁합보기'));
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        // Verify compatibility page
        expect(find.byType(CompatibilityPage), findsOneWidget);
      }
    });

    testWidgets('Generate marriage fortune', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to fortune section
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();
      
      // Find and tap marriage fortune
      final marriageCard = find.text('결혼운');
      if (marriageCard.evaluate().isNotEmpty) {
        await tester.tap(marriageCard);
        await tester.pumpAndSettle();
        
        // Generate fortune
        await tester.tap(find.text('결혼운 보기'));
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        // Verify result
        expect(find.byType(MarriageFortunePage), findsOneWidget);
        expect(find.text('결혼운'), findsWidgets);
      }
    });

    testWidgets('Check token consumption', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to fortune section
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();
      
      // Find token display
      final tokenDisplay = find.byWidgetPredicate(
        (widget) => widget is Text && 
          widget.data != null && 
          widget.data!.contains('토큰')
      );
      
      expect(tokenDisplay, findsWidgets);
      
      // Generate a fortune to test token consumption
      final dailyFortuneCard = find.text('오늘의 운세');
      if (dailyFortuneCard.evaluate().isNotEmpty) {
        // Get initial token count
        final initialTokenText = tokenDisplay.evaluate().first.widget as Text;
        
        // Generate fortune
        await tester.tap(dailyFortuneCard);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        // Go back
        await tester.pageBack();
        await tester.pumpAndSettle();
        
        // Check token count decreased
        final updatedTokenText = tokenDisplay.evaluate().first.widget as Text;
        expect(initialTokenText.data != updatedTokenText.data, true);
      }
    });

    testWidgets('Fortune history navigation', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to fortune section
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();
      
      // Look for history button
      final historyButton = find.byIcon(Icons.history);
      if (historyButton.evaluate().isNotEmpty) {
        await tester.tap(historyButton);
        await tester.pumpAndSettle();
        
        // Verify history page elements
        expect(find.text('운세 기록'), findsOneWidget);
      }
    });

    testWidgets('Share fortune result', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to fortune section and generate fortune
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();
      
      final dailyFortuneCard = find.text('오늘의 운세');
      if (dailyFortuneCard.evaluate().isNotEmpty) {
        await tester.tap(dailyFortuneCard);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        // Find share button
        final shareButton = find.byIcon(Icons.share);
        if (shareButton.evaluate().isNotEmpty) {
          await tester.tap(shareButton);
          await tester.pumpAndSettle();
          
          // Note: Actual share sheet cannot be tested in integration tests
          // as it opens system UI
        }
      }
    });

    testWidgets('Fortune type descriptions', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to fortune section
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();
      
      // Check for fortune type cards with descriptions
      expect(find.text('오늘의 운세'), findsWidgets);
      expect(find.text('궁합'), findsWidgets);
      expect(find.text('결혼운'), findsWidgets);
      
      // Tap info icon if available
      final infoIcons = find.byIcon(Icons.info_outline);
      if (infoIcons.evaluate().isNotEmpty) {
        await tester.tap(infoIcons.first);
        await tester.pumpAndSettle();
        
        // Verify description bottom sheet
        expect(find.byType(BottomSheet), findsOneWidget);
      }
    });
  });
}

// Helper functions
Future<void> _performQuickLogin(WidgetTester tester) async {
  // This assumes the app remembers login state or we're in a test environment
  // In real tests, you might need to implement actual login flow
}

Future<void> _fillPartnerInfo(WidgetTester tester) async {
  // Fill partner name
  final nameField = find.byWidgetPredicate(
    (widget) => widget is TextFormField && 
      widget.decoration?.labelText == '이름'
  );
  if (nameField.evaluate().isNotEmpty) {
    await tester.enterText(nameField, '테스트 파트너');
  }
  
  // Select birth date
  final birthDateField = find.byWidgetPredicate(
    (widget) => widget is TextFormField && 
      widget.decoration?.labelText?.contains('생년월일') == true
  );
  if (birthDateField.evaluate().isNotEmpty) {
    await tester.tap(birthDateField);
    await tester.pumpAndSettle();
    
    // Select date from date picker
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
  }
  
  // Select gender
  final genderDropdown = find.byType(DropdownButton<String>);
  if (genderDropdown.evaluate().isNotEmpty) {
    await tester.tap(genderDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('남성').last);
    await tester.pumpAndSettle();
  }
}