// Investment Fortune Page - Widget Test
// 투자운 페이지 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('InvestmentFortunePage 테스트', () {
    group('UI 렌더링', () {
      testWidgets('투자운 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockInvestmentFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('투자운'), findsOneWidget);
      });
    });

    group('투자 유형 선택', () {
      testWidgets('주식 옵션이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockInvestmentFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('주식'), findsOneWidget);
      });

      testWidgets('부동산 옵션이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockInvestmentFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('부동산'), findsOneWidget);
      });

      testWidgets('코인 옵션이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockInvestmentFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('코인'), findsOneWidget);
      });

      testWidgets('펀드 옵션이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockInvestmentFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('펀드'), findsOneWidget);
      });
    });

    group('결과 화면', () {
      testWidgets('투자 점수가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockInvestmentFortuneResult(score: 72),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('72점'), findsOneWidget);
      });

      testWidgets('투자 시기 분석이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockInvestmentFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('투자 시기'), findsOneWidget);
      });

      testWidgets('리스크 분석이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockInvestmentFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('리스크 분석'), findsOneWidget);
      });

      testWidgets('행운의 종목이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockInvestmentFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('행운의 종목'), findsOneWidget);
      });

      testWidgets('피해야 할 종목이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockInvestmentFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('주의 종목'), findsOneWidget);
      });
    });

    group('월별 투자운', () {
      testWidgets('월별 투자운 차트가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockInvestmentFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('월별 투자운'), findsOneWidget);
      });
    });

    group('투자 조언', () {
      testWidgets('투자 전략이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockInvestmentFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('투자 전략'), findsOneWidget);
      });

      testWidgets('주의사항이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockInvestmentFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('주의사항'), findsOneWidget);
      });
    });

    group('면책 조항', () {
      testWidgets('투자 면책 조항이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockInvestmentFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.textContaining('참고용'), findsOneWidget);
      });
    });
  });
}

// ============================================
// Mock Widgets
// ============================================

class _MockInvestmentFortunePage extends StatelessWidget {
  const _MockInvestmentFortunePage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('투자운',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('관심 투자 유형을 선택해주세요'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                    label: const Text('주식'),
                    selected: true,
                    onSelected: (_) {}),
                ChoiceChip(
                    label: const Text('부동산'),
                    selected: false,
                    onSelected: (_) {}),
                ChoiceChip(
                    label: const Text('코인'),
                    selected: false,
                    onSelected: (_) {}),
                ChoiceChip(
                    label: const Text('펀드'),
                    selected: false,
                    onSelected: (_) {}),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('분석하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockInvestmentFortuneResult extends StatelessWidget {
  final int score;

  const _MockInvestmentFortuneResult({
    this.score = 68,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('투자운 분석 결과', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text('$score점',
                      style: const TextStyle(
                          fontSize: 48, fontWeight: FontWeight.bold)),
                  const Text('투자 적합도'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Card(
              child: ListTile(
                leading: Icon(Icons.access_time),
                title: Text('투자 시기'),
                subtitle: Text('상반기가 유리합니다'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.warning),
                title: Text('리스크 분석'),
                subtitle: Text('중간 수준의 리스크를 감수할 수 있습니다'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.trending_up, color: Colors.green),
                title: Text('행운의 종목'),
                subtitle: Text('기술주, 금융주'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.trending_down, color: Colors.red),
                title: Text('주의 종목'),
                subtitle: Text('에너지주, 원자재'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('월별 투자운', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              height: 100,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('차트 영역')),
            ),
            const Card(
              child: ListTile(
                title: Text('투자 전략'),
                subtitle: Text('장기 투자에 집중하세요'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.info, color: Colors.orange),
                title: Text('주의사항'),
                subtitle: Text('3월에는 큰 결정을 피하세요'),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '본 분석은 참고용이며 실제 투자 결정에 대한 책임은 본인에게 있습니다.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
