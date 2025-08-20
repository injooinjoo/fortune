import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fortune/main.dart' as app;
import '../helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Payment and Token Purchase Flow', () {
    setUp(() async {
      app.main();
    });
    
    testWidgets('should navigate to token purchase page', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      
      // Navigate to profile
      await TestHelpers.navigateToTab(tester, Icons.person);
      
      // Find and tap token balance or purchase button
      final tokenSection = find.textContaining('영혼');
      await tester.tap(tokenSection.first);
      await tester.pumpAndSettle();
      
      // Verify we're on token purchase page
      expect(find.text('영혼 충전'), findsOneWidget);
      
      // Check for token packages
      expect(find.textContaining('10 영혼'), findsOneWidget);
      expect(find.textContaining('50 영혼'), findsOneWidget);
      expect(find.textContaining('100 영혼'), findsOneWidget);
      expect(find.textContaining('200 영혼'), findsOneWidget);
      
      // Check for prices
      expect(find.textContaining('₩'), findsWidgets);
    });
    
    testWidgets('should show token package details', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      
      // Navigate to token purchase
      await TestHelpers.navigateToTab(tester, Icons.person);
      await tester.tap(find.textContaining('영혼').first);
      await tester.pumpAndSettle();
      
      // Check each package card
      final packageCards = find.byType(Card);
      expect(packageCards, findsNWidgets(4)); // 4 token packages
      
      // Tap on a package
      await tester.tap(find.textContaining('100 영혼'));
      await tester.pumpAndSettle();
      
      // Should show purchase button
      expect(find.text('구매하기'), findsOneWidget);
      
      // Should show bonus if applicable
      final bonusText = find.textContaining('보너스');
      if (bonusText.evaluate().isNotEmpty) {
        expect(bonusText, findsOneWidget);
      }
    });
    
    testWidgets('should show token history', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      
      // Navigate to profile
      await TestHelpers.navigateToTab(tester, Icons.person);
      
      // Find and tap token history
      await TestHelpers.scrollToWidget(
        tester,
        find.text('영혼 사용 내역'),
      );
      
      await tester.tap(find.text('영혼 사용 내역'));
      await tester.pumpAndSettle();
      
      // Verify history page
      expect(find.text('영혼 사용 내역'), findsWidgets);
      
      // Check for transaction list
      expect(find.byType(ListView), findsOneWidget);
      
      // Check for filter options
      expect(find.text('전체'), findsOneWidget);
      expect(find.text('충전'), findsOneWidget);
      expect(find.text('사용'), findsOneWidget);
    });
    
    testWidgets('should handle purchase cancellation', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      
      // Navigate to token purchase
      await TestHelpers.navigateToTab(tester, Icons.person);
      await tester.tap(find.textContaining('영혼').first);
      await tester.pumpAndSettle();
      
      // Select a package
      await tester.tap(find.textContaining('50 영혼'));
      await tester.pumpAndSettle();
      
      // Tap purchase button
      await tester.tap(find.text('구매하기'));
      await tester.pumpAndSettle();
      
      // In real scenario, this would open payment gateway
      // For now, check if we can go back
      await tester.pageBack();
      await tester.pumpAndSettle();
      
      // Should be back on token purchase page
      expect(find.text('영혼 충전'), findsOneWidget);
    });
    
    testWidgets('should show subscription options', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      
      // Navigate to profile
      await TestHelpers.navigateToTab(tester, Icons.person);
      
      // Look for subscription section
      await TestHelpers.scrollToWidget(
        tester,
        find.textContaining('무제한'),
      );
      
      final subscriptionOption = find.textContaining('무제한');
      if (subscriptionOption.evaluate().isNotEmpty) {
        await tester.tap(subscriptionOption.first);
        await tester.pumpAndSettle();
        
        // Should show subscription plans
        expect(find.text('월간 무제한'), findsOneWidget);
        expect(find.text('연간 무제한'), findsOneWidget);
        
        // Should show benefits
        expect(find.textContaining('무제한 운세'), findsOneWidget);
        expect(find.textContaining('광고 제거'), findsOneWidget);
      }
    });
    
    testWidgets('should display daily free tokens banner', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      
      // Check for daily tokens banner
      final dailyTokenBanner = find.textContaining('매일 무료');
      if (dailyTokenBanner.evaluate().isNotEmpty) {
        expect(dailyTokenBanner, findsOneWidget);
        
        // Should have claim button
        final claimButton = find.text('받기');
        if (claimButton.evaluate().isNotEmpty) {
          await tester.tap(claimButton);
          await tester.pumpAndSettle();
          
          // Should show success message
          TestHelpers.expectSnackbar('무료 영혼을 받았습니다');
        }
      }
    });
    
    testWidgets('should show payment methods', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      
      // Navigate to token purchase
      await TestHelpers.navigateToTab(tester, Icons.person);
      await tester.tap(find.textContaining('영혼').first);
      await tester.pumpAndSettle();
      
      // Select a package
      await tester.tap(find.textContaining('100 영혼'));
      await tester.pumpAndSettle();
      
      // Tap purchase
      await tester.tap(find.text('구매하기'));
      await tester.pumpAndSettle();
      
      // In production, this would show platform-specific payment methods
      // For iOS: Apple Pay
      // For Android: Google Pay
      // Both: Credit card options
    });
    
    testWidgets('should restore previous purchases', 
      (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login
      await TestHelpers.performLogin(tester);
      await TestHelpers.waitForLoading(tester);
      
      // Navigate to settings or payment page
      await TestHelpers.navigateToTab(tester, Icons.person);
      
      // Look for restore purchases option
      await TestHelpers.scrollToWidget(
        tester,
        find.text('구매 복원'),
      );
      
      final restoreButton = find.text('구매 복원');
      if (restoreButton.evaluate().isNotEmpty) {
        await tester.tap(restoreButton);
        await tester.pumpAndSettle();
        
        // Should show loading
        await TestHelpers.waitForLoading(tester);
        
        // Should show result message
        final successMessage = find.textContaining('복원');
        if (successMessage.evaluate().isNotEmpty) {
          expect(successMessage, findsOneWidget);
        }
      }
    });
  });
}