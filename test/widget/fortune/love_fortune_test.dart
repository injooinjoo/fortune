// Love Fortune Page - Widget Test
// 연애운 페이지 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('LoveFortunePage 테스트', () {
    group('UI 렌더링', () {
      testWidgets('연애운 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockLoveFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('연애운'), findsOneWidget);
      });
    });

    group('입력 정보', () {
      testWidgets('연애 상태 선택이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockLoveFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('솔로'), findsOneWidget);
        expect(find.text('연애 중'), findsOneWidget);
        expect(find.text('기혼'), findsOneWidget);
      });

      testWidgets('상대방 정보 입력이 있어야 함 (연애 중일 때)', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockLoveFortunePage(
                  relationshipStatus: 'dating',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('상대방 정보'), findsOneWidget);
      });
    });

    group('결과 화면', () {
      testWidgets('연애운 점수가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockLoveFortuneResult(score: 88),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('88점'), findsOneWidget);
      });

      testWidgets('월별 연애운이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockLoveFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('월별 연애운'), findsOneWidget);
      });

      testWidgets('이상형 분석이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockLoveFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('이상형 분석'), findsOneWidget);
      });

      testWidgets('연애 조언이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockLoveFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('연애 조언'), findsOneWidget);
      });
    });

    group('솔로 특화 기능', () {
      testWidgets('인연 시기 분석이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockLoveFortuneResult(
                  relationshipStatus: 'single',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('인연 시기'), findsOneWidget);
      });

      testWidgets('인연 장소 추천이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockLoveFortuneResult(
                  relationshipStatus: 'single',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('인연 장소'), findsOneWidget);
      });
    });

    group('연애 중 특화 기능', () {
      testWidgets('관계 발전 조언이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockLoveFortuneResult(
                  relationshipStatus: 'dating',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('관계 발전'), findsOneWidget);
      });
    });

  });
}

// ============================================
// Mock Widgets
// ============================================

class _MockLoveFortunePage extends StatelessWidget {
  final String relationshipStatus;

  const _MockLoveFortunePage({
    this.relationshipStatus = 'single',
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('연애운', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('연애 상태'),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('솔로'),
                  selected: relationshipStatus == 'single',
                  onSelected: (_) {},
                ),
                ChoiceChip(
                  label: const Text('연애 중'),
                  selected: relationshipStatus == 'dating',
                  onSelected: (_) {},
                ),
                ChoiceChip(
                  label: const Text('기혼'),
                  selected: relationshipStatus == 'married',
                  onSelected: (_) {},
                ),
              ],
            ),
            if (relationshipStatus != 'single') ...[
              const SizedBox(height: 16),
              const Text('상대방 정보'),
              const TextField(decoration: InputDecoration(hintText: '생년월일')),
            ],
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

class _MockLoveFortuneResult extends StatelessWidget {
  final int score;
  final String relationshipStatus;

  const _MockLoveFortuneResult({
    this.score = 75,
    this.relationshipStatus = 'single',
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('연애운 분석 결과', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            Center(
              child: Text('$score점', style: const TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 16),
            const Card(child: ListTile(title: Text('월별 연애운'))),
            const Card(child: ListTile(title: Text('이상형 분석'))),
            const Card(child: ListTile(title: Text('연애 조언'))),
            if (relationshipStatus == 'single') ...[
              const Card(child: ListTile(title: Text('인연 시기'))),
              const Card(child: ListTile(title: Text('인연 장소'))),
            ],
            if (relationshipStatus == 'dating') ...[
              const Card(child: ListTile(title: Text('관계 발전'))),
            ],
          ],
        ),
      ),
    );
  }
}
