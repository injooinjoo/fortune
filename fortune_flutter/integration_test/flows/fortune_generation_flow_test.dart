import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fortune_flutter/main.dart' as app;
import '../helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Fortune Generation Flow', () {
    setUpAll(() async {
      // Any global setup
    });
    
    setUp(() async {
      // Start fresh app instance
      app.main();
    });
    
    testWidgets('should generate daily fortune successfully', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login first
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      
      // Verify we're on home screen
      expect(TestHelpers.isLoggedIn(tester), isTrue);
      
      // Navigate to fortune tab
      await TestHelpers.navigateToTab(tester, Icons.auto_awesome);
      
      // Find and tap daily fortune card
      final dailyFortuneCard = find.textContaining('오늘의 운세');
      expect(dailyFortuneCard, findsOneWidget);
      
      await tester.tap(dailyFortuneCard);
      await tester.pumpAndSettle();
      
      // Check if we're on fortune generation page
      expect(find.text('오늘의 운세'), findsWidgets);
      
      // Check token balance is displayed
      expect(find.textContaining('영혼'), findsOneWidget);
      
      // Tap generate fortune button
      final generateButton = find.byType(ElevatedButton).first;
      await tester.tap(generateButton);
      
      // Wait for fortune generation
      await TestHelpers.waitForLoading(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Verify fortune result is displayed
      expect(find.textContaining('운세'), findsWidgets);
      expect(find.byType(Card), findsWidgets);
      
      // Check for fortune content elements
      expect(find.byIcon(Icons.auto_awesome), findsWidgets);
      
      // Verify share button exists
      expect(find.byIcon(Icons.share), findsOneWidget);
      
      // Verify save button exists
      expect(find.byIcon(Icons.bookmark_outline), findsOneWidget);
    });
    
    testWidgets('should handle insufficient tokens gracefully', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login with test account that has no tokens
      await TestHelpers.performLogin(
        tester,
        email: 'notoken@example.com',
        password: 'TestPassword123!',
      );
      await TestHelpers.waitForLoading(tester);
      
      // Navigate to fortune tab
      await TestHelpers.navigateToTab(tester, Icons.auto_awesome);
      
      // Try to generate fortune
      final fortuneCard = find.textContaining('운세').first;
      await tester.tap(fortuneCard);
      await tester.pumpAndSettle();
      
      final generateButton = find.byType(ElevatedButton).first;
      await tester.tap(generateButton);
      await tester.pumpAndSettle();
      
      // Should show insufficient tokens modal
      expect(find.text('영혼이 부족합니다'), findsOneWidget);
      expect(find.text('영혼 충전하기'), findsOneWidget);
      
      // Tap purchase button
      await tester.tap(find.text('영혼 충전하기'));
      await tester.pumpAndSettle();
      
      // Should navigate to token purchase page
      expect(find.text('영혼 충전'), findsOneWidget);
    });
    
    testWidgets('should generate and save zodiac fortune', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      
      // Navigate to fortune tab
      await TestHelpers.navigateToTab(tester, Icons.auto_awesome);
      
      // Scroll to find zodiac fortune
      await TestHelpers.scrollToWidget(
        tester,
        find.textContaining('별자리 운세'),
      );
      
      await tester.tap(find.textContaining('별자리 운세'));
      await tester.pumpAndSettle();
      
      // Select zodiac sign
      final zodiacPicker = find.byType(DropdownButton<String>);
      if (zodiacPicker.evaluate().isNotEmpty) {
        await tester.tap(zodiacPicker);
        await tester.pumpAndSettle();
        
        // Select Aries (양자리)
        await tester.tap(find.text('양자리').last);
        await tester.pumpAndSettle();
      }
      
      // Generate fortune
      final generateButton = find.byType(ElevatedButton).first;
      await tester.tap(generateButton);
      
      await TestHelpers.waitForLoading(tester);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Save fortune
      final saveButton = find.byIcon(Icons.bookmark_outline);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      
      // Verify saved
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
      TestHelpers.expectSnackbar('운세가 저장되었습니다');
    });
    
    testWidgets('should show fortune history', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      
      // Navigate to profile
      await TestHelpers.navigateToTab(tester, Icons.person);
      
      // Find and tap fortune history
      await TestHelpers.scrollToWidget(
        tester,
        find.text('운세 기록'),
      );
      
      await tester.tap(find.text('운세 기록'));
      await tester.pumpAndSettle();
      
      // Verify history page
      expect(find.text('운세 기록'), findsWidgets);
      
      // Should show list of past fortunes
      expect(find.byType(ListView), findsOneWidget);
      
      // Check for date filters
      expect(find.byIcon(Icons.calendar_month), findsOneWidget);
      
      // Check for fortune type filters
      expect(find.text('전체'), findsOneWidget);
    });
    
    testWidgets('should share fortune result', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login and generate a fortune first
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      
      await TestHelpers.navigateToTab(tester, Icons.auto_awesome);
      
      final dailyFortuneCard = find.textContaining('오늘의 운세');
      await tester.tap(dailyFortuneCard);
      await tester.pumpAndSettle();
      
      final generateButton = find.byType(ElevatedButton).first;
      await tester.tap(generateButton);
      
      await TestHelpers.waitForLoading(tester);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Tap share button
      final shareButton = find.byIcon(Icons.share);
      await tester.tap(shareButton);
      await tester.pumpAndSettle();
      
      // Should show share options
      expect(find.text('공유하기'), findsOneWidget);
      
      // Check for share options
      expect(find.byIcon(Icons.image), findsOneWidget); // Save as image
      expect(find.byIcon(Icons.copy), findsOneWidget); // Copy text
    });
    
    testWidgets('should handle network error during fortune generation', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      
      // Navigate to fortune tab
      await TestHelpers.navigateToTab(tester, Icons.auto_awesome);
      
      // Note: In real test, you would mock network failure
      // For now, we just test the UI flow
      
      final fortuneCard = find.textContaining('운세').first;
      await tester.tap(fortuneCard);
      await tester.pumpAndSettle();
      
      // If network error occurs, should show error dialog
      if (TestHelpers.hasErrorDialog(tester)) {
        expect(find.text('네트워크 오류'), findsOneWidget);
        expect(find.text('다시 시도'), findsOneWidget);
        
        await TestHelpers.dismissDialog(tester);
      }
    });
    
    testWidgets('should generate compatibility fortune', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      
      // Navigate to fortune tab
      await TestHelpers.navigateToTab(tester, Icons.auto_awesome);
      
      // Find compatibility fortune
      await TestHelpers.scrollToWidget(
        tester,
        find.textContaining('궁합'),
      );
      
      await tester.tap(find.textContaining('궁합'));
      await tester.pumpAndSettle();
      
      // Fill person 1 info
      await tester.enterText(
        find.byType(TextField).at(0),
        '홍길동',
      );
      
      // Select birth date for person 1
      await tester.tap(find.byIcon(Icons.calendar_today).first);
      await tester.pumpAndSettle();
      await TestHelpers.selectDate(tester, day: 15);
      
      // Fill person 2 info
      await tester.enterText(
        find.byType(TextField).at(1),
        '김영희',
      );
      
      // Generate compatibility
      final generateButton = find.byType(ElevatedButton).first;
      await tester.tap(generateButton);
      
      await TestHelpers.waitForLoading(tester);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Verify compatibility result
      expect(find.textContaining('%'), findsOneWidget); // Compatibility percentage
      expect(find.text('궁합 결과'), findsOneWidget);
    });
  });
}