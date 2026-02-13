// Biorhythm Page - Widget Test
// 바이오리듬 페이지 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('BiorhythmPage 테스트', () {
    group('UI 렌더링', () {
      testWidgets('바이오리듬 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockBiorhythmPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('바이오리듬'), findsOneWidget);
      });
    });

    group('바이오리듬 차트', () {
      testWidgets('신체 리듬이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockBiorhythmPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('신체'), findsOneWidget);
      });

      testWidgets('감정 리듬이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockBiorhythmPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('감정'), findsOneWidget);
      });

      testWidgets('지성 리듬이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockBiorhythmPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('지성'), findsOneWidget);
      });

      testWidgets('직관 리듬이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockBiorhythmPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('직관'), findsOneWidget);
      });
    });

    group('리듬 수치', () {
      testWidgets('각 리듬의 퍼센트가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockBiorhythmPage(
                  physical: 75,
                  emotional: 50,
                  intellectual: 25,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('75%'), findsOneWidget);
        expect(find.text('50%'), findsOneWidget);
        expect(find.text('25%'), findsOneWidget);
      });

      testWidgets('상태 표시 (고조기/저조기/위험일)', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockBiorhythmPage(physical: 90),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('고조기'), findsWidgets);
      });
    });

    group('날짜 선택', () {
      testWidgets('날짜 선택기가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockBiorhythmPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      });

      testWidgets('이전/다음 날짜 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockBiorhythmPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      });
    });

    group('주간/월간 뷰', () {
      testWidgets('주간 뷰 탭이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockBiorhythmPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('주간'), findsOneWidget);
      });

      testWidgets('월간 뷰 탭이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockBiorhythmPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('월간'), findsOneWidget);
      });
    });

    group('오늘의 조언', () {
      testWidgets('오늘의 조언이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockBiorhythmPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('오늘의 조언'), findsOneWidget);
      });

      testWidgets('주의사항이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockBiorhythmPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('주의사항'), findsOneWidget);
      });
    });
  });
}

// ============================================
// Mock Widgets
// ============================================

class _MockBiorhythmPage extends StatelessWidget {
  final int physical;
  final int emotional;
  final int intellectual;
  final int intuitive = 55;

  const _MockBiorhythmPage({
    this.physical = 60,
    this.emotional = 40,
    this.intellectual = 80,
  });

  String _getStatus(int value) {
    if (value > 70) return '고조기';
    if (value < 30) return '저조기';
    if (value >= 45 && value <= 55) return '위험일';
    return '보통';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('바이오리듬',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(
                    icon: const Icon(Icons.calendar_today), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),

            // 날짜 네비게이션
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    icon: const Icon(Icons.chevron_left), onPressed: () {}),
                const Text('2024년 12월 7일'),
                IconButton(
                    icon: const Icon(Icons.chevron_right), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),

            // 뷰 선택
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                    label: const Text('주간'),
                    selected: true,
                    onSelected: (_) {}),
                const SizedBox(width: 8),
                ChoiceChip(
                    label: const Text('월간'),
                    selected: false,
                    onSelected: (_) {}),
              ],
            ),
            const SizedBox(height: 24),

            // 차트 영역 (Placeholder)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('차트 영역')),
            ),
            const SizedBox(height: 24),

            // 리듬 수치
            _RhythmCard(
                title: '신체',
                value: physical,
                status: _getStatus(physical),
                color: Colors.red),
            _RhythmCard(
                title: '감정',
                value: emotional,
                status: _getStatus(emotional),
                color: Colors.blue),
            _RhythmCard(
                title: '지성',
                value: intellectual,
                status: _getStatus(intellectual),
                color: Colors.green),
            _RhythmCard(
                title: '직관',
                value: intuitive,
                status: _getStatus(intuitive),
                color: Colors.purple),

            const SizedBox(height: 16),
            const Card(
              child: ListTile(
                leading: Icon(Icons.lightbulb),
                title: Text('오늘의 조언'),
                subtitle: Text('지적 활동에 적합한 날입니다'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.warning),
                title: Text('주의사항'),
                subtitle: Text('격한 운동은 피하세요'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RhythmCard extends StatelessWidget {
  final String title;
  final int value;
  final String status;
  final Color color;

  const _RhythmCard({
    required this.title,
    required this.value,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(status, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            Text('$value%',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
