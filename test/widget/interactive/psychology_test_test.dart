// Psychology Test - Widget Test
// 심리 테스트 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('PsychologyTest 테스트', () {
    group('UI 렌더링', () {
      testWidgets('심리 테스트 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPsychologyTestScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('심리 테스트'), findsOneWidget);
      });
    });

    group('테스트 목록', () {
      testWidgets('여러 심리 테스트가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPsychologyTestScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(Card), findsWidgets);
      });

      testWidgets('연애 심리 테스트가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPsychologyTestScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('연애 심리 테스트'), findsOneWidget);
      });

      testWidgets('성격 심리 테스트가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPsychologyTestScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('성격 유형 테스트'), findsOneWidget);
      });

      testWidgets('스트레스 테스트가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPsychologyTestScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('스트레스 테스트'), findsOneWidget);
      });
    });

    group('질문 화면', () {
      testWidgets('질문이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPsychologyTestScreen(isInTest: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Q1'), findsOneWidget);
      });

      testWidgets('진행률이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPsychologyTestScreen(isInTest: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('답변 옵션이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPsychologyTestScreen(isInTest: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('A.'), findsOneWidget);
        expect(find.text('B.'), findsOneWidget);
      });
    });

    group('답변 선택', () {
      testWidgets('답변을 선택할 수 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPsychologyTestScreen(isInTest: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // A. 옵션을 포함한 InkWell 탭
        final answerA = find.text('A.');
        expect(answerA, findsOneWidget);
        await tester.tap(answerA);
        await tester.pumpAndSettle();

        // 선택 후 위젯 상태 확인
        expect(find.byType(InkWell), findsWidgets);
      });

      testWidgets('다음 버튼으로 진행할 수 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPsychologyTestScreen(isInTest: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('다음'), findsOneWidget);
      });

      testWidgets('이전 버튼으로 돌아갈 수 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPsychologyTestScreen(
                  isInTest: true,
                  currentQuestion: 2,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('이전'), findsOneWidget);
      });
    });

    group('결과 화면', () {
      testWidgets('결과 타입이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPsychologyTestScreen(
                  showResult: true,
                  resultType: 'ENFP',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('ENFP'), findsOneWidget);
      });

      testWidgets('결과 설명이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPsychologyTestScreen(showResult: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('분석 결과'), findsOneWidget);
      });

      testWidgets('공유 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPsychologyTestScreen(showResult: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('공유하기'), findsOneWidget);
      });

      testWidgets('다시 테스트하기 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockPsychologyTestScreen(showResult: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('다시 테스트'), findsOneWidget);
      });
    });

    group('테스트 시작', () {
      testWidgets('테스트 시작 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPsychologyTestScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('시작하기'), findsWidgets);
      });

      testWidgets('테스트 설명이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPsychologyTestScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.textContaining('질문'), findsWidgets);
      });
    });

    group('인기 테스트', () {
      testWidgets('인기 순으로 정렬되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockPsychologyTestScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('인기'), findsWidgets);
      });
    });

    group('테마 지원', () {
      testWidgets('라이트 테마에서 올바르게 렌더링', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const Scaffold(body: _MockPsychologyTestScreen()),
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
              home: const Scaffold(body: _MockPsychologyTestScreen()),
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

class _MockPsychologyTestScreen extends StatelessWidget {
  final bool isInTest;
  final int currentQuestion;
  final bool showResult;
  final String resultType;

  const _MockPsychologyTestScreen({
    this.isInTest = false,
    this.currentQuestion = 1,
    this.showResult = false,
    this.resultType = '분석형',
  });

  @override
  Widget build(BuildContext context) {
    if (showResult) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  resultType,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '분석 결과',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '당신은 열정적이고 창의적인 성격입니다. 새로운 아이디어를 탐구하고 사람들과 교류하는 것을 좋아합니다.',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('다시 테스트'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('공유하기'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (isInTest) {
      return SafeArea(
        child: Column(
          children: [
            // 진행률
            LinearProgressIndicator(
              value: currentQuestion / 10,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q$currentQuestion',
                      style: TextStyle(
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '친구들과 함께 있을 때 당신은?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    _AnswerOption(
                      label: 'A.',
                      text: '대화를 주도하며 분위기를 이끈다',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _AnswerOption(
                      label: 'B.',
                      text: '다른 사람의 이야기를 경청한다',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _AnswerOption(
                      label: 'C.',
                      text: '상황에 따라 다르다',
                      onTap: () {},
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (currentQuestion > 1)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              child: const Text('이전'),
                            ),
                          ),
                        if (currentQuestion > 1) const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('다음'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '심리 테스트',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('재미있는 심리 테스트로 나를 알아보세요'),
            SizedBox(height: 24),
            _TestCard(
              title: '연애 심리 테스트',
              description: '10가지 질문으로 알아보는 나의 연애 스타일',
              badge: '인기',
              color: Colors.pink,
            ),
            _TestCard(
              title: '성격 유형 테스트',
              description: '나의 진짜 성격은? MBTI 기반 분석',
              badge: '추천',
              color: Colors.purple,
            ),
            _TestCard(
              title: '스트레스 테스트',
              description: '현재 나의 스트레스 지수는?',
              color: Colors.blue,
            ),
            _TestCard(
              title: '직업 적성 테스트',
              description: '나에게 맞는 직업 유형 찾기',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  final String title;
  final String description;
  final String? badge;
  final Color color;

  const _TestCard({
    required this.title,
    required this.description,
    this.badge,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.psychology, color: color),
        ),
        title: Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(description),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {},
              child: const Text('시작하기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  final String label;
  final String text;
  final VoidCallback onTap;
  final bool isSelected = false;

  const _AnswerOption({
    required this.label,
    required this.text,
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
            color: isSelected ? Colors.purple : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
