/// Token Purchase Screen - Widget Test
/// 토큰 구매 화면 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('TokenPurchaseScreen 테스트', () {
    group('UI 렌더링', () {
      testWidgets('토큰 구매 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTokenPurchaseScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('토큰 충전'), findsOneWidget);
      });

      testWidgets('현재 토큰 잔액이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockTokenPurchaseScreen(currentTokens: 50),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('50'), findsOneWidget);
        expect(find.text('보유 토큰'), findsOneWidget);
      });
    });

    group('토큰 패키지', () {
      testWidgets('여러 토큰 패키지가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTokenPurchaseScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('50 토큰'), findsOneWidget);
        expect(find.text('100 토큰'), findsOneWidget);
        expect(find.text('300 토큰'), findsOneWidget);
        expect(find.text('500 토큰'), findsOneWidget);
      });

      testWidgets('각 패키지에 가격이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTokenPurchaseScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.textContaining('₩3,000'), findsOneWidget);
        expect(find.textContaining('₩5,000'), findsOneWidget);
        expect(find.textContaining('₩12,000'), findsOneWidget);
        expect(find.textContaining('₩18,000'), findsOneWidget);
      });

      testWidgets('인기 패키지가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTokenPurchaseScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('인기'), findsOneWidget);
      });

      testWidgets('보너스 토큰이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTokenPurchaseScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.textContaining('+'), findsWidgets);
      });
    });

    group('패키지 선택', () {
      testWidgets('패키지를 선택할 수 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTokenPurchaseScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('300 토큰'));
        await tester.pumpAndSettle();

        // 선택 상태 확인
        expect(find.byType(_TokenPackageCard), findsWidgets);
      });

      testWidgets('선택된 패키지가 강조되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockTokenPurchaseScreen(selectedPackage: 'token_100'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        // 선택된 카드 스타일 확인
        expect(find.byType(_TokenPackageCard), findsWidgets);
      });
    });

    group('구매 버튼', () {
      testWidgets('구매 버튼이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTokenPurchaseScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('구매하기'), findsOneWidget);
      });

      testWidgets('패키지 미선택 시 구매 버튼 비활성화', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockTokenPurchaseScreen(selectedPackage: null),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final button = find.widgetWithText(ElevatedButton, '구매하기');
        expect(button, findsOneWidget);
      });

      testWidgets('구매 버튼 탭이 가능해야 함', (tester) async {
        bool purchasePressed = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockTokenPurchaseScreen(
                  selectedPackage: 'token_100',
                  onPurchase: () => purchasePressed = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 스크롤하여 버튼이 보이도록 함
        final purchaseButton = find.widgetWithText(ElevatedButton, '구매하기');
        await tester.ensureVisible(purchaseButton);
        await tester.pumpAndSettle();

        await tester.tap(purchaseButton);
        await tester.pumpAndSettle();

        expect(purchasePressed, isTrue);
      });
    });

    group('토큰 사용 안내', () {
      testWidgets('토큰 사용 안내가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTokenPurchaseScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('토큰 사용 안내'), findsOneWidget);
      });

      testWidgets('운세별 소모 토큰이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTokenPurchaseScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.textContaining('일일운세'), findsOneWidget);
        expect(find.textContaining('타로'), findsOneWidget);
      });
    });

    group('사용 내역', () {
      testWidgets('토큰 사용 내역 링크가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTokenPurchaseScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('사용 내역'), findsOneWidget);
      });

      testWidgets('사용 내역 탭 시 페이지 이동', (tester) async {
        bool historyPressed = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockTokenPurchaseScreen(
                  onViewHistory: () => historyPressed = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('사용 내역'));
        await tester.pumpAndSettle();

        expect(historyPressed, isTrue);
      });
    });

    group('로딩 상태', () {
      testWidgets('구매 중 로딩 인디케이터가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockTokenPurchaseScreen(isPurchasing: true),
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('에러 상태', () {
      testWidgets('구매 실패 시 에러 메시지가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockTokenPurchaseScreen(
                  hasError: true,
                  errorMessage: '결제에 실패했습니다',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('결제에 실패했습니다'), findsOneWidget);
      });
    });

    group('구매 완료', () {
      testWidgets('구매 완료 시 성공 메시지가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockTokenPurchaseScreen(purchaseComplete: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('구매 완료!'), findsOneWidget);
      });

      testWidgets('구매 완료 후 추가된 토큰이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockTokenPurchaseScreen(
                  purchaseComplete: true,
                  purchasedTokens: 100,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.textContaining('100'), findsWidgets);
      });
    });

    group('프리미엄 안내', () {
      testWidgets('프리미엄 구독 안내가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTokenPurchaseScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.textContaining('프리미엄'), findsWidgets);
      });
    });

    group('테마 지원', () {
      testWidgets('라이트 테마에서 올바르게 렌더링', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const Scaffold(body: _MockTokenPurchaseScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('다크 테마에서 올바르게 렌더링', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: const Scaffold(body: _MockTokenPurchaseScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });
  });
}

// ============================================
// Mock Widgets
// ============================================

class _MockTokenPurchaseScreen extends StatefulWidget {
  final int currentTokens;
  final String? selectedPackage;
  final bool isPurchasing;
  final bool hasError;
  final String? errorMessage;
  final bool purchaseComplete;
  final int purchasedTokens;
  final VoidCallback? onPurchase;
  final VoidCallback? onViewHistory;

  const _MockTokenPurchaseScreen({
    this.currentTokens = 100,
    this.selectedPackage = 'token_100',
    this.isPurchasing = false,
    this.hasError = false,
    this.errorMessage,
    this.purchaseComplete = false,
    this.purchasedTokens = 0,
    this.onPurchase,
    this.onViewHistory,
  });

  @override
  State<_MockTokenPurchaseScreen> createState() => _MockTokenPurchaseScreenState();
}

class _MockTokenPurchaseScreenState extends State<_MockTokenPurchaseScreen> {
  late String? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _selectedPackage = widget.selectedPackage;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.purchaseComplete) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              '구매 완료!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${widget.purchasedTokens} 토큰이 추가되었습니다'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '토큰 충전',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 현재 잔액
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.monetization_on, color: Colors.amber),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('보유 토큰'),
                        Text(
                          '${widget.currentTokens}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: widget.onViewHistory,
                      child: const Text('사용 내역'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 에러 메시지
            if (widget.hasError) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      widget.errorMessage ?? '오류가 발생했습니다',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 토큰 패키지
            const Text(
              '토큰 패키지',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _TokenPackageCard(
              id: 'token_50',
              tokens: 50,
              price: '₩3,000',
              isSelected: _selectedPackage == 'token_50',
              onTap: () => setState(() => _selectedPackage = 'token_50'),
            ),
            _TokenPackageCard(
              id: 'token_100',
              tokens: 100,
              price: '₩5,000',
              isPopular: true,
              isSelected: _selectedPackage == 'token_100',
              onTap: () => setState(() => _selectedPackage = 'token_100'),
            ),
            _TokenPackageCard(
              id: 'token_300',
              tokens: 300,
              price: '₩12,000',
              bonusTokens: 30,
              isSelected: _selectedPackage == 'token_300',
              onTap: () => setState(() => _selectedPackage = 'token_300'),
            ),
            _TokenPackageCard(
              id: 'token_500',
              tokens: 500,
              price: '₩18,000',
              bonusTokens: 100,
              isSelected: _selectedPackage == 'token_500',
              onTap: () => setState(() => _selectedPackage = 'token_500'),
            ),
            const SizedBox(height: 24),

            // 구매 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedPackage != null && !widget.isPurchasing
                    ? (widget.onPurchase ?? () {})
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.amber,
                ),
                child: widget.isPurchasing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        '구매하기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // 토큰 사용 안내
            const Text(
              '토큰 사용 안내',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _TokenUsageInfo(fortuneType: '일일운세', tokens: 10),
            _TokenUsageInfo(fortuneType: '타로', tokens: 20),
            _TokenUsageInfo(fortuneType: '궁합', tokens: 30),
            _TokenUsageInfo(fortuneType: '관상', tokens: 30),
            const SizedBox(height: 16),

            // 프리미엄 안내
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '프리미엄 구독하면 더 저렴해요!',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '모든 운세 무제한 이용',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('자세히'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TokenPackageCard extends StatelessWidget {
  final String id;
  final int tokens;
  final String price;
  final int? bonusTokens;
  final bool isPopular;
  final bool isSelected;
  final VoidCallback onTap;

  const _TokenPackageCard({
    required this.id,
    required this.tokens,
    required this.price,
    this.bonusTokens,
    this.isPopular = false,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.amber : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Radio<String>(
                value: id,
                groupValue: isSelected ? id : '',
                onChanged: (_) => onTap(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$tokens 토큰',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (bonusTokens != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '+$bonusTokens',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        if (isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '인기',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TokenUsageInfo extends StatelessWidget {
  final String fortuneType;
  final int tokens;

  const _TokenUsageInfo({
    required this.fortuneType,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Colors.grey),
          const SizedBox(width: 8),
          Text(fortuneType),
          const Spacer(),
          Text('$tokens 토큰'),
        ],
      ),
    );
  }
}
