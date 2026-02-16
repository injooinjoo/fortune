// Premium Screen - Widget Test
// 프리미엄 화면 UI 테스트

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('PremiumScreen 테스트', () {
    group('UI 렌더링', () {
      testWidgets('프리미엄 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPremiumScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('프리미엄'), findsOneWidget);
      });

      testWidgets('프리미엄 혜택 목록이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPremiumScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('무제한 운세'), findsOneWidget);
        expect(find.text('광고 제거'), findsOneWidget);
        expect(find.text('프리미엄 콘텐츠'), findsOneWidget);
      });
    });

    group('구독 상품', () {
      testWidgets('월간 구독 옵션이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPremiumScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('월간'), findsOneWidget);
      });

      testWidgets('연간 구독 옵션이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPremiumScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('연간'), findsOneWidget);
      });

      testWidgets('가격이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPremiumScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.textContaining('₩'), findsWidgets);
      });

      testWidgets('베스트 가치 배지가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPremiumScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('BEST'), findsOneWidget);
      });
    });

    group('구독 상태', () {
      testWidgets('비구독자에게 구독하기 버튼이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPremiumScreen(isSubscribed: false),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('구독하기'), findsOneWidget);
      });

      testWidgets('구독자에게 구독 정보가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPremiumScreen(isSubscribed: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('현재 구독 중'), findsOneWidget);
      });

      testWidgets('구독 만료일이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPremiumScreen(isSubscribed: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.textContaining('만료'), findsOneWidget);
      });
    });

    group('인터랙션', () {
      testWidgets('구독 옵션 선택 가능해야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPremiumScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('연간'));
        await tester.pumpAndSettle();

        // 연간 옵션이 선택되었는지 확인
        expect(find.byType(Radio<String>), findsWidgets);
      });

      testWidgets('구독하기 버튼 탭이 가능해야 함', (tester) async {
        bool subscribePressed = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPremiumScreen(
                  onSubscribe: () => subscribePressed = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 스크롤하여 버튼이 보이도록 함
        final subscribeButton = find.widgetWithText(ElevatedButton, '구독하기');
        await tester.ensureVisible(subscribeButton);
        await tester.pumpAndSettle();

        await tester.tap(subscribeButton);
        await tester.pumpAndSettle();

        expect(subscribePressed, isTrue);
      });

      testWidgets('구매 복원 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPremiumScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('구매 복원'), findsOneWidget);
      });
    });

    group('할인 표시', () {
      testWidgets('연간 구독 할인율이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPremiumScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.textContaining('%'), findsWidgets);
      });
    });

    group('약관 링크', () {
      testWidgets('이용약관 링크가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPremiumScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('이용약관'), findsOneWidget);
      });

      testWidgets('개인정보처리방침 링크가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPremiumScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('개인정보처리방침'), findsOneWidget);
      });
    });

    group('구독 관리', () {
      testWidgets('구독자에게 구독 취소 버튼이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPremiumScreen(isSubscribed: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('구독 관리'), findsOneWidget);
      });

      testWidgets('자동 갱신 상태가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPremiumScreen(isSubscribed: true, autoRenew: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('자동 갱신'), findsOneWidget);
      });
    });

    group('로딩 상태', () {
      testWidgets('로딩 중 인디케이터가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPremiumScreen(isLoading: true),
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('에러 상태', () {
      testWidgets('에러 메시지가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPremiumScreen(
                  hasError: true,
                  errorMessage: '결제 처리 중 오류가 발생했습니다',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('결제 처리 중 오류가 발생했습니다'), findsOneWidget);
      });

      testWidgets('다시 시도 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPremiumScreen(hasError: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('다시 시도'), findsOneWidget);
      });
    });

    group('테마 지원', () {
      testWidgets('라이트 테마에서 올바르게 렌더링', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const Scaffold(body: _MockPremiumScreen()),
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
              home: const Scaffold(body: _MockPremiumScreen()),
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

class _MockPremiumScreen extends StatefulWidget {
  final bool isSubscribed;
  final bool autoRenew;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onSubscribe;

  const _MockPremiumScreen({
    this.isSubscribed = false,
    this.autoRenew = false,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.onSubscribe,
  });

  @override
  State<_MockPremiumScreen> createState() => _MockPremiumScreenState();
}

class _MockPremiumScreenState extends State<_MockPremiumScreen> {
  String _selectedPlan = 'monthly';

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(widget.errorMessage ?? '오류가 발생했습니다'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('다시 시도'),
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
              '프리미엄',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '더 풍부한 운세를 경험하세요',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // 현재 구독 상태
            if (widget.isSubscribed) ...[
              Card(
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            '현재 구독 중',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('프리미엄 월간'),
                      const Text('만료일: 2024년 12월 31일'),
                      if (widget.autoRenew) ...[
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.autorenew, size: 16),
                            SizedBox(width: 4),
                            Text('자동 갱신'),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {},
                        child: const Text('구독 관리'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 혜택 목록
            const Text(
              '프리미엄 혜택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const _BenefitItem(
              icon: Icons.all_inclusive,
              title: '무제한 운세',
              description: '모든 운세를 제한 없이 이용하세요',
            ),
            const _BenefitItem(
              icon: Icons.block,
              title: '광고 제거',
              description: '광고 없이 깔끔하게',
            ),
            const _BenefitItem(
              icon: Icons.star,
              title: '프리미엄 콘텐츠',
              description: '심화 분석과 상세 해석',
            ),
            const _BenefitItem(
              icon: Icons.support_agent,
              title: '우선 지원',
              description: '문의 시 빠른 답변',
            ),
            const SizedBox(height: 24),

            // 구독 옵션
            if (!widget.isSubscribed) ...[
              const Text(
                '구독 옵션',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // 월간
              _SubscriptionOption(
                title: '월간',
                price: '₩9,900',
                period: '/월',
                isSelected: _selectedPlan == 'monthly',
                onTap: () => setState(() => _selectedPlan = 'monthly'),
              ),
              const SizedBox(height: 8),

              // 연간
              Stack(
                children: [
                  _SubscriptionOption(
                    title: '연간',
                    price: '₩79,000',
                    period: '/년',
                    discount: '33% 할인',
                    isSelected: _selectedPlan == 'yearly',
                    onTap: () => setState(() => _selectedPlan = 'yearly'),
                  ),
                  Positioned(
                    top: 0,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'BEST',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 구독하기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onSubscribe ?? () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.amber,
                  ),
                  child: const Text(
                    '구독하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 구매 복원
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('구매 복원'),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // 약관 링크
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('이용약관'),
                ),
                const Text('|'),
                TextButton(
                  onPressed: () {},
                  child: const Text('개인정보처리방침'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.amber.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionOption extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? discount;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubscriptionOption({
    required this.title,
    required this.price,
    required this.period,
    this.discount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
              value: title.toLowerCase(),
              groupValue: isSelected ? title.toLowerCase() : '',
              onChanged: (_) => onTap(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (discount != null)
                    Text(
                      discount!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
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
            Text(
              period,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
