import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:fortune/shared/components/token_balance_widget.dart';
import 'package:fortune/presentation/providers/token_provider.dart';
import 'package:fortune/data/models/token_balance.dart';
import 'package:fortune/data/models/subscription.dart';
import '../../test_utils/test_config.dart';
import '../../test_utils/helpers/test_helpers.dart';
import '../../test_utils/fixtures/test_data.dart';

// Mock classes
class MockTokenNotifier extends StateNotifier<TokenState> with Mock
    implements TokenNotifier {
  MockTokenNotifier(TokenState state) : super(state);
}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockTokenNotifier mockTokenNotifier;
  late MockGoRouter mockGoRouter;
  
  setUp(() {
    mockTokenNotifier = MockTokenNotifier(const TokenState());
    mockGoRouter = MockGoRouter();
  });
  
  group('TokenBalanceWidget', () {
    testWidgets('should show nothing when balance is null and not loading', 
      (WidgetTester tester) async {
      // Arrange
      mockTokenNotifier.state = const TokenState(
        balance: null,
        isLoading: false,
      );
      
      // Act
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const TokenBalanceWidget(),
          overrides: [
            tokenProvider.overrideWith((ref) => mockTokenNotifier),
          ],
        ),
      );
      
      // Assert
      expect(find.byType(TokenBalanceWidget), findsOneWidget);
      expect(find.byType(GestureDetector), findsNothing);
    });
    
    testWidgets('should show loading indicator when loading', 
      (WidgetTester tester) async {
      // Arrange
      mockTokenNotifier.state = const TokenState(
        balance: null,
        isLoading: true,
      );
      
      // Act
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const TokenBalanceWidget(),
          overrides: [
            tokenProvider.overrideWith((ref) => mockTokenNotifier),
          ],
        ),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('should show token balance when available', 
      (WidgetTester tester) async {
      // Arrange
      final balance = TokenBalance(
        userId: TestData.testUserId,
        totalTokens: 100,
        usedTokens: 20,
        remainingTokens: 80,
        lastUpdated: DateTime.now(),
      );
      
      mockTokenNotifier.state = TokenState(
        balance: balance,
        isLoading: false,
      );
      
      // Act
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const TokenBalanceWidget(),
          overrides: [
            tokenProvider.overrideWith((ref) => mockTokenNotifier),
          ],
        ),
      );
      
      // Assert
      expect(find.text('80 영혼'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });
    
    testWidgets('should show unlimited when subscription is active', 
      (WidgetTester tester) async {
      // Arrange
      final subscription = Subscription(
        userId: TestData.testUserId,
        planId: 'monthly',
        status: 'active',
        currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      );
      
      mockTokenNotifier.state = TokenState(
        balance: TokenBalance(
          userId: TestData.testUserId,
          totalTokens: 100,
          usedTokens: 0,
          remainingTokens: 100,
          lastUpdated: DateTime.now(),
        ),
        subscription: subscription,
        isLoading: false,
      );
      
      // Act
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const TokenBalanceWidget(),
          overrides: [
            tokenProvider.overrideWith((ref) => mockTokenNotifier),
          ],
        ),
      );
      
      // Assert
      expect(find.text('무제한'), findsOneWidget);
      expect(find.byIcon(Icons.all_inclusive_rounded), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsNothing);
    });
    
    testWidgets('should navigate to payment history on tap', 
      (WidgetTester tester) async {
      // Arrange
      final balance = TokenBalance(
        userId: TestData.testUserId,
        totalTokens: 100,
        usedTokens: 20,
        remainingTokens: 80,
        lastUpdated: DateTime.now(),
      );
      
      mockTokenNotifier.state = TokenState(
        balance: balance,
        isLoading: false,
      );
      
      when(() => mockGoRouter.push(any())).thenAnswer((_) async => null);
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenProvider.overrideWith((ref) => mockTokenNotifier),
          ],
          child: MaterialApp.router(
            routerConfig: mockGoRouter,
            builder: (context, child) => const TokenBalanceWidget(),
          ),
        ),
      );
      
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();
      
      // Assert
      verify(() => mockGoRouter.push('/payment/history')).called(1);
    });
  });
  
  group('TokenBalanceCard', () {
    testWidgets('should show detailed token information', 
      (WidgetTester tester) async {
      // Arrange
      final balance = TokenBalance(
        userId: TestData.testUserId,
        totalTokens: 100,
        usedTokens: 30,
        remainingTokens: 70,
        lastUpdated: DateTime.now(),
      );
      
      mockTokenNotifier.state = TokenState(
        balance: balance,
        isLoading: false,
      );
      
      // Act
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const TokenBalanceCard(),
          overrides: [
            tokenProvider.overrideWith((ref) => mockTokenNotifier),
          ],
        ),
      );
      
      // Assert
      expect(find.text('영혼 포인트'), findsOneWidget);
      expect(find.text('70 영혼'), findsOneWidget);
      expect(find.text('30 영혼'), findsOneWidget);
      expect(find.text('사용률'), findsOneWidget);
      expect(find.text('30.0%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
    
    testWidgets('should show action buttons', 
      (WidgetTester tester) async {
      // Arrange
      final balance = TokenBalance(
        userId: TestData.testUserId,
        totalTokens: 100,
        usedTokens: 30,
        remainingTokens: 70,
        lastUpdated: DateTime.now(),
      );
      
      mockTokenNotifier.state = TokenState(
        balance: balance,
        isLoading: false,
      );
      
      // Act
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const TokenBalanceCard(),
          overrides: [
            tokenProvider.overrideWith((ref) => mockTokenNotifier),
          ],
        ),
      );
      
      // Assert
      expect(find.text('사용 내역'), findsOneWidget);
      expect(find.text('영혼 상태'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
    
    testWidgets('should show daily tokens claim button', 
      (WidgetTester tester) async {
      // Arrange
      final balance = TokenBalance(
        userId: TestData.testUserId,
        totalTokens: 100,
        usedTokens: 30,
        remainingTokens: 70,
        lastUpdated: DateTime.now(),
      );
      
      mockTokenNotifier.state = TokenState(
        balance: balance,
        isLoading: false,
      );
      
      when(() => mockTokenNotifier.claimDailyTokens())
          .thenAnswer((_) async {});
      
      // Act
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const TokenBalanceCard(),
          overrides: [
            tokenProvider.overrideWith((ref) => mockTokenNotifier),
          ],
        ),
      );
      
      // Assert
      expect(find.text('매일 무료 영혼을 받을 수 있어요!'), findsOneWidget);
      expect(find.text('받기'), findsOneWidget);
      
      // Tap claim button
      await tester.tap(find.text('받기'));
      await tester.pumpAndSettle();
      
      verify(() => mockTokenNotifier.claimDailyTokens()).called(1);
    });
    
    testWidgets('should show unlimited badge for active subscription', 
      (WidgetTester tester) async {
      // Arrange
      final subscription = Subscription(
        userId: TestData.testUserId,
        planId: 'monthly',
        status: 'active',
        currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      );
      
      final balance = TokenBalance(
        userId: TestData.testUserId,
        totalTokens: 100,
        usedTokens: 0,
        remainingTokens: 100,
        lastUpdated: DateTime.now(),
      );
      
      mockTokenNotifier.state = TokenState(
        balance: balance,
        subscription: subscription,
        isLoading: false,
      );
      
      // Act
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const TokenBalanceCard(),
          overrides: [
            tokenProvider.overrideWith((ref) => mockTokenNotifier),
          ],
        ),
      );
      
      // Assert
      expect(find.text('무제한'), findsOneWidget);
      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
    });
    
    testWidgets('should show loading state', 
      (WidgetTester tester) async {
      // Arrange
      mockTokenNotifier.state = const TokenState(
        balance: null,
        isLoading: true,
      );
      
      // Act
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const TokenBalanceCard(),
          overrides: [
            tokenProvider.overrideWith((ref) => mockTokenNotifier),
          ],
        ),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('보유 영혼'), findsNothing);
      expect(find.text('사용한 영혼'), findsNothing);
    });
  });
}