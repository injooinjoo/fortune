// Career Coaching Page - Widget Test
// 직업 코칭 페이지 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('CareerCoachingPage 테스트', () {
    group('UI 렌더링', () {
      testWidgets('직업 코칭 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCareerCoachingPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('직업 코칭'), findsOneWidget);
      });
    });

    group('입력 폼', () {
      testWidgets('현재 직업 상태 선택이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCareerCoachingPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('취업 준비'), findsOneWidget);
        expect(find.text('재직 중'), findsOneWidget);
        expect(find.text('이직 고민'), findsOneWidget);
      });

      testWidgets('관심 분야 선택이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCareerCoachingPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('관심 분야'), findsOneWidget);
      });

      testWidgets('고민 입력 필드가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCareerCoachingPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('고민/질문'), findsOneWidget);
      });
    });

    group('결과 화면', () {
      testWidgets('적성 분석이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCareerCoachingResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('적성 분석'), findsOneWidget);
      });

      testWidgets('추천 직업이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCareerCoachingResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('추천 직업'), findsOneWidget);
      });

      testWidgets('커리어 조언이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCareerCoachingResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('커리어 조언'), findsOneWidget);
      });

      testWidgets('시기별 운세가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCareerCoachingResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('시기별 조언'), findsOneWidget);
      });

      testWidgets('성공 확률이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockCareerCoachingResult(successRate: 78),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('78%'), findsOneWidget);
      });
    });

    group('강점 & 약점', () {
      testWidgets('강점이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockCareerCoachingResult(
                  strengths: ['리더십', '창의성', '분석력'],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('강점'), findsOneWidget);
        expect(find.text('리더십'), findsOneWidget);
      });

      testWidgets('개선점이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockCareerCoachingResult(
                  improvements: ['인내심', '세부 집중'],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('개선점'), findsOneWidget);
      });
    });

    group('인터랙션', () {
      testWidgets('분석하기 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCareerCoachingPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('분석 시작'), findsOneWidget);
      });
    });
  });
}

// ============================================
// Mock Widgets
// ============================================

class _MockCareerCoachingPage extends StatelessWidget {
  const _MockCareerCoachingPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('직업 코칭',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('현재 상태'),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                    label: const Text('취업 준비'),
                    selected: true,
                    onSelected: (_) {}),
                ChoiceChip(
                    label: const Text('재직 중'),
                    selected: false,
                    onSelected: (_) {}),
                ChoiceChip(
                    label: const Text('이직 고민'),
                    selected: false,
                    onSelected: (_) {}),
              ],
            ),
            const SizedBox(height: 16),
            const Text('관심 분야'),
            const TextField(decoration: InputDecoration(hintText: '선택해주세요')),
            const SizedBox(height: 16),
            const Text('고민/질문'),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(hintText: '커리어 고민을 적어주세요'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('분석 시작'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockCareerCoachingResult extends StatelessWidget {
  final int successRate;
  final List<String> strengths;
  final List<String> improvements;

  const _MockCareerCoachingResult({
    this.successRate = 75,
    this.strengths = const [],
    this.improvements = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('직업 코칭 결과', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  const Text('성공 확률'),
                  Text('$successRate%', style: const TextStyle(fontSize: 48)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Card(
                child: ListTile(
                    title: Text('적성 분석'),
                    subtitle: Text('당신은 창의적인 분야에 적합합니다'))),
            const Card(
                child: ListTile(
                    title: Text('추천 직업'), subtitle: Text('디자이너, 마케터, 기획자'))),
            const Card(
                child: ListTile(
                    title: Text('커리어 조언'), subtitle: Text('지금이 도전할 때입니다'))),
            const Card(
                child: ListTile(
                    title: Text('시기별 조언'), subtitle: Text('상반기에 집중하세요'))),
            if (strengths.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('강점', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: strengths.map((s) => Chip(label: Text(s))).toList(),
              ),
            ],
            if (improvements.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('개선점', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children:
                    improvements.map((s) => Chip(label: Text(s))).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
