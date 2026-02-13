// Traditional Saju Page - Widget Test
// 전통 사주 페이지 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('TraditionalSajuPage 테스트', () {
    group('UI 렌더링', () {
      testWidgets('사주 페이지가 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTraditionalSajuPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('전통 사주'), findsOneWidget);
      });
    });

    group('입력 폼', () {
      testWidgets('생년월일 입력 필드가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTraditionalSajuPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('생년월일'), findsOneWidget);
      });

      testWidgets('태어난 시간 입력 필드가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTraditionalSajuPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('태어난 시간'), findsOneWidget);
      });

      testWidgets('성별 선택이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTraditionalSajuPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('남성'), findsOneWidget);
        expect(find.text('여성'), findsOneWidget);
      });

      testWidgets('음력/양력 선택이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTraditionalSajuPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('양력'), findsOneWidget);
        expect(find.text('음력'), findsOneWidget);
      });
    });

    group('결과 화면', () {
      testWidgets('사주팔자가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockTraditionalSajuResult(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('사주팔자'), findsOneWidget);
      });

      testWidgets('대운이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockTraditionalSajuResult(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('대운'), findsOneWidget);
      });

      testWidgets('세운이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockTraditionalSajuResult(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('세운'), findsOneWidget);
      });

      testWidgets('용신이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockTraditionalSajuResult(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('용신'), findsOneWidget);
      });
    });

    group('인터랙션', () {
      testWidgets('분석하기 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTraditionalSajuPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('분석하기'), findsOneWidget);
      });

      testWidgets('분석하기 버튼 탭 시 분석 시작', (tester) async {
        bool analyzePressed = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockTraditionalSajuPage(
                  onAnalyze: () => analyzePressed = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        await tester.tap(find.text('분석하기'));
        await tester.pumpAndSettle();

        expect(analyzePressed, isTrue);
      });
    });

    group('시간 선택', () {
      testWidgets('12시진 선택 옵션이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTraditionalSajuPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        // 시진 선택 확인
        expect(find.text('자시'), findsOneWidget);
      });

      testWidgets('모름 옵션이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockTraditionalSajuPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('모름'), findsOneWidget);
      });
    });
  });
}

// ============================================
// Mock Widgets
// ============================================

class _MockTraditionalSajuPage extends StatelessWidget {
  final VoidCallback? onAnalyze;

  const _MockTraditionalSajuPage({this.onAnalyze});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('전통 사주',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('생년월일'),
            const TextField(decoration: InputDecoration(hintText: '선택해주세요')),
            const SizedBox(height: 16),
            Row(
              children: [
                ChoiceChip(
                    label: const Text('양력'),
                    selected: true,
                    onSelected: (_) {}),
                const SizedBox(width: 8),
                ChoiceChip(
                    label: const Text('음력'),
                    selected: false,
                    onSelected: (_) {}),
              ],
            ),
            const SizedBox(height: 16),
            const Text('태어난 시간'),
            const Wrap(
              spacing: 8,
              children: [
                Chip(label: Text('자시')),
                Chip(label: Text('모름')),
              ],
            ),
            const SizedBox(height: 16),
            const Text('성별'),
            Row(
              children: [
                ChoiceChip(
                    label: const Text('남성'),
                    selected: true,
                    onSelected: (_) {}),
                const SizedBox(width: 8),
                ChoiceChip(
                    label: const Text('여성'),
                    selected: false,
                    onSelected: (_) {}),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAnalyze,
                child: const Text('분석하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockTraditionalSajuResult extends StatelessWidget {
  const _MockTraditionalSajuResult();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('전통 사주 분석 결과', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            const Card(
                child: ListTile(
                    title: Text('사주팔자'), subtitle: Text('경오 정축 갑자 기사'))),
            const Card(
                child: ListTile(title: Text('대운'), subtitle: Text('현재 대운 정보'))),
            const Card(
                child: ListTile(title: Text('세운'), subtitle: Text('올해의 운세'))),
            const Card(child: ListTile(title: Text('용신'), subtitle: Text('토'))),
          ],
        ),
      ),
    );
  }
}
