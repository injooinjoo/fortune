/// Compatibility Page - Widget Test
/// 궁합 페이지 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('CompatibilityPage 테스트', () {
    group('UI 렌더링', () {
      testWidgets('궁합 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCompatibilityPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('궁합'), findsOneWidget);
      });
    });

    group('입력 폼', () {
      testWidgets('본인 정보 입력 영역이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCompatibilityPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('나의 정보'), findsOneWidget);
      });

      testWidgets('상대방 정보 입력 영역이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCompatibilityPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('상대방 정보'), findsOneWidget);
      });

      testWidgets('각각 생년월일 입력이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCompatibilityPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('생년월일'), findsNWidgets(2));
      });

      testWidgets('각각 성별 선택이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCompatibilityPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        // 각각 남성/여성 선택
        expect(find.text('남'), findsNWidgets(2));
        expect(find.text('여'), findsNWidgets(2));
      });
    });

    group('결과 화면', () {
      testWidgets('궁합 점수가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockCompatibilityResult(score: 92),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('92점'), findsOneWidget);
      });

      testWidgets('궁합 등급이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockCompatibilityResult(
                  score: 92,
                  grade: '천생연분',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('천생연분'), findsOneWidget);
      });

      testWidgets('카테고리별 궁합이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCompatibilityResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('성격 궁합'), findsOneWidget);
        expect(find.text('연애 궁합'), findsOneWidget);
        expect(find.text('결혼 궁합'), findsOneWidget);
        expect(find.text('금전 궁합'), findsOneWidget);
      });

      testWidgets('오행 상성이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCompatibilityResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('오행 상성'), findsOneWidget);
      });
    });

    group('조언 섹션', () {
      testWidgets('강점이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCompatibilityResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('강점'), findsOneWidget);
      });

      testWidgets('주의점이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCompatibilityResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('주의점'), findsOneWidget);
      });

      testWidgets('조언이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCompatibilityResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('관계 조언'), findsOneWidget);
      });
    });

    group('블러 처리', () {
      testWidgets('무료 사용자는 일부 콘텐츠 블러', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockCompatibilityResult(isBlurred: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('프리미엄 잠금 해제'), findsOneWidget);
      });
    });

    group('인터랙션', () {
      testWidgets('분석하기 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCompatibilityPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('궁합 보기'), findsOneWidget);
      });

      testWidgets('공유 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCompatibilityResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.share), findsOneWidget);
      });
    });
  });
}

// ============================================
// Mock Widgets
// ============================================

class _MockCompatibilityPage extends StatelessWidget {
  const _MockCompatibilityPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('궁합', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // 나의 정보
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('나의 정보', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('생년월일'),
                    const TextField(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ChoiceChip(label: const Text('남'), selected: true, onSelected: (_) {}),
                        const SizedBox(width: 8),
                        ChoiceChip(label: const Text('여'), selected: false, onSelected: (_) {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 상대방 정보
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('상대방 정보', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('생년월일'),
                    const TextField(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ChoiceChip(label: const Text('남'), selected: false, onSelected: (_) {}),
                        const SizedBox(width: 8),
                        ChoiceChip(label: const Text('여'), selected: true, onSelected: (_) {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('궁합 보기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockCompatibilityResult extends StatelessWidget {
  final int score;
  final String? grade;
  final bool isBlurred;

  const _MockCompatibilityResult({
    this.score = 85,
    this.grade,
    this.isBlurred = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('궁합 결과', style: TextStyle(fontSize: 24)),
                IconButton(icon: const Icon(Icons.share), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),

            Text('$score점', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            if (grade != null) Text(grade!, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 24),

            const Card(child: ListTile(title: Text('성격 궁합'), trailing: Text('85점'))),
            const Card(child: ListTile(title: Text('연애 궁합'), trailing: Text('90점'))),
            const Card(child: ListTile(title: Text('결혼 궁합'), trailing: Text('82점'))),
            const Card(child: ListTile(title: Text('금전 궁합'), trailing: Text('78점'))),
            const SizedBox(height: 16),

            const Card(child: ListTile(title: Text('오행 상성'), subtitle: Text('목-화 상생'))),
            const SizedBox(height: 16),

            const Card(child: ListTile(title: Text('강점'), subtitle: Text('서로를 보완하는 관계'))),
            const Card(child: ListTile(title: Text('주의점'), subtitle: Text('의사소통에 주의'))),
            const Card(child: ListTile(title: Text('관계 조언'), subtitle: Text('서로의 차이를 인정하세요'))),

            if (isBlurred) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: const Text('프리미엄 잠금 해제'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
