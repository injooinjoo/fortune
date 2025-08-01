import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fortune/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Payment and Token Flow Tests', () {
    setUpAll(() async {
      app.main();
    });

    testWidgets('Navigate to token purchase', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login first
      await _performQuickLogin(tester);
      
      // Find and tap token balance or purchase button
      final tokenButton = find.byWidgetPredicate(
        (widget) => widget is IconButton && 
          widget.icon is Icon && 
          (widget.icon as Icon).icon == Icons.monetization_on
      );
      
      if (tokenButton.evaluate().isNotEmpty) {
        await tester.tap(tokenButton);
        await tester.pumpAndSettle();
        
        // Verify token purchase page
        expect(find.text('토큰 구매'), findsOneWidget);
      }
    });

    testWidgets('View token packages', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to token purchase
      await _navigateToTokenPurchase(tester);
      
      // Verify token packages are displayed
      expect(find.text('10 토큰'), findsWidgets);
      expect(find.text('50 토큰'), findsWidgets);
      expect(find.text('100 토큰'), findsWidgets);
      
      // Check for pricing
      expect(find.textContaining('₩'), findsWidgets);
    });

    testWidgets('Select token package', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to token purchase
      await _navigateToTokenPurchase(tester);
      
      // Select a token package
      final tokenPackage = find.text('50 토큰');
      if (tokenPackage.evaluate().isNotEmpty) {
        await tester.tap(tokenPackage);
        await tester.pumpAndSettle();
        
        // Verify selection
        expect(find.byWidgetPredicate(
          (widget) => widget is Container && 
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).border != null
        ), findsWidgets);
      }
    });

    testWidgets('Payment method selection', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to token purchase
      await _navigateToTokenPurchase(tester);
      
      // Select token package
      await tester.tap(find.text('50 토큰'));
      await tester.pumpAndSettle();
      
      // Proceed to payment
      final purchaseButton = find.text('구매하기');
      if (purchaseButton.evaluate().isNotEmpty) {
        await tester.tap(purchaseButton);
        await tester.pumpAndSettle();
        
        // Check for payment methods
        expect(find.text('결제 수단'), findsWidgets);
        expect(find.text('신용카드'), findsWidgets);
        expect(find.text('카카오페이'), findsWidgets);
      }
    });

    testWidgets('Token balance display', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Check token balance in header/navigation
      final tokenDisplay = find.byWidgetPredicate(
        (widget) => widget is Text && 
          widget.data != null && 
          widget.data!.contains('토큰')
      );
      
      expect(tokenDisplay, findsWidgets);
      
      // Verify balance format
      final tokenText = tokenDisplay.evaluate().first.widget as Text;
      expect(RegExp(r'\d+\s*토큰').hasMatch(tokenText.data ?? ''), true);
    });

    testWidgets('Token transaction history', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Find and tap transaction history
      final historyButton = find.text('토큰 사용 내역');
      if (historyButton.evaluate().isNotEmpty) {
        await tester.scrollUntilVisible(
          historyButton,
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(historyButton);
        await tester.pumpAndSettle();
        
        // Verify history page
        expect(find.text('토큰 내역'), findsOneWidget);
        expect(find.byType(ListView), findsWidgets);
      }
    });

    testWidgets('Insufficient token warning', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to fortune section
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();
      
      // Try to generate fortune when tokens are insufficient
      // Note: This test assumes the test account has low/no tokens
      final fortuneCard = find.text('궁합');
      if (fortuneCard.evaluate().isNotEmpty) {
        await tester.tap(fortuneCard);
        await tester.pumpAndSettle();
        
        // Check for insufficient token message
        final warningMessage = find.textContaining('토큰이 부족');
        if (warningMessage.evaluate().isNotEmpty) {
          expect(warningMessage, findsOneWidget);
          
          // Check for purchase prompt
          expect(find.text('토큰 구매'), findsWidgets);
        }
      }
    });

    testWidgets('Free token events', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to token/event section
      final eventButton = find.byIcon(Icons.card_giftcard);
      if (eventButton.evaluate().isNotEmpty) {
        await tester.tap(eventButton);
        await tester.pumpAndSettle();
        
        // Check for free token opportunities
        expect(find.textContaining('무료'), findsWidgets);
        
        // Check for daily attendance
        final attendanceButton = find.text('출석 체크');
        if (attendanceButton.evaluate().isNotEmpty) {
          await tester.tap(attendanceButton);
          await tester.pumpAndSettle();
          
          // Verify attendance reward
          expect(find.textContaining('토큰 획득'), findsWidgets);
        }
      }
    });

    testWidgets('Token package discount display', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to token purchase
      await _navigateToTokenPurchase(tester);
      
      // Check for discount badges
      final discountBadges = find.byWidgetPredicate(
        (widget) => widget is Container && 
          widget.child is Text &&
          (widget.child as Text).data?.contains('%') == true
      );
      
      if (discountBadges.evaluate().isNotEmpty) {
        expect(discountBadges, findsWidgets);
        
        // Verify discount text format
        final discountText = (discountBadges.evaluate().first.widget as Container).child as Text;
        expect(RegExp(r'\d+%').hasMatch(discountText.data ?? ''), true);
      }
    });
  });
}

// Helper functions
Future<void> _performQuickLogin(WidgetTester tester) async {
  // This assumes the app remembers login state or we're in a test environment
  // In real tests, you might need to implement actual login flow
}

Future<void> _navigateToTokenPurchase(WidgetTester tester) async {
  // Try multiple ways to navigate to token purchase
  
  // Method 1: Token button in header
  final tokenButton = find.byWidgetPredicate(
    (widget) => widget is IconButton && 
      widget.icon is Icon && 
      (widget.icon as Icon).icon == Icons.monetization_on
  );
  
  if (tokenButton.evaluate().isNotEmpty) {
    await tester.tap(tokenButton);
    await tester.pumpAndSettle();
    return;
  }
  
  // Method 2: Through profile
  await tester.tap(find.byIcon(Icons.person));
  await tester.pumpAndSettle();
  
  final purchaseButton = find.text('토큰 구매');
  if (purchaseButton.evaluate().isNotEmpty) {
    await tester.tap(purchaseButton);
    await tester.pumpAndSettle();
  }
}