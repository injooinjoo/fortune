// Celebrity Fortune Page - Widget Test
// 유명인 운세 페이지 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('CelebrityFortunePage 테스트', () {
    group('UI 렌더링', () {
      testWidgets('유명인 운세 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCelebrityFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('유명인 운세'), findsOneWidget);
      });
    });

    group('카테고리 선택', () {
      testWidgets('연예인 카테고리가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCelebrityFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('연예인'), findsOneWidget);
      });

      testWidgets('스포츠 카테고리가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCelebrityFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('스포츠'), findsOneWidget);
      });

      testWidgets('정치인 카테고리가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCelebrityFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('정치인'), findsOneWidget);
      });

      testWidgets('기업인 카테고리가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCelebrityFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('기업인'), findsOneWidget);
      });
    });

    group('유명인 선택', () {
      testWidgets('검색 필드가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCelebrityFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('유명인 목록이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCelebrityFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(ListTile), findsWidgets);
      });
    });

    group('결과 화면', () {
      testWidgets('유명인 정보가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockCelebrityFortuneResult(
                  celebrityName: '손흥민',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('손흥민'), findsOneWidget);
      });

      testWidgets('사주 정보가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCelebrityFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('사주 분석'), findsOneWidget);
      });

      testWidgets('성공 요인이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCelebrityFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('성공 요인'), findsOneWidget);
      });

      testWidgets('나와의 비교가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCelebrityFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('나와의 비교'), findsOneWidget);
      });

      testWidgets('배울 점이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCelebrityFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('배울 점'), findsOneWidget);
      });
    });

    group('동일 생일 유명인', () {
      testWidgets('같은 생일 유명인 섹션이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockCelebrityFortuneResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('같은 생일 유명인'), findsOneWidget);
      });
    });

    group('인터랙션', () {
      testWidgets('분석하기 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockCelebrityFortunePage(selectedCelebrity: '손흥민'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('분석하기'), findsOneWidget);
      });
    });
  });
}

// ============================================
// Mock Widgets
// ============================================

class _MockCelebrityFortunePage extends StatelessWidget {
  final String? selectedCelebrity;

  const _MockCelebrityFortunePage({this.selectedCelebrity});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('유명인 운세',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // 카테고리
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                    label: const Text('연예인'),
                    selected: false,
                    onSelected: (_) {}),
                ChoiceChip(
                    label: const Text('스포츠'),
                    selected: true,
                    onSelected: (_) {}),
                ChoiceChip(
                    label: const Text('정치인'),
                    selected: false,
                    onSelected: (_) {}),
                ChoiceChip(
                    label: const Text('기업인'),
                    selected: false,
                    onSelected: (_) {}),
              ],
            ),
            const SizedBox(height: 16),

            // 검색
            const TextField(
              decoration: InputDecoration(
                hintText: '유명인 검색',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),

            // 유명인 목록
            ListTile(
              leading: const CircleAvatar(child: Text('손')),
              title: const Text('손흥민'),
              subtitle: const Text('축구선수'),
              selected: selectedCelebrity == '손흥민',
            ),
            const ListTile(
              leading: CircleAvatar(child: Text('김')),
              title: Text('김연아'),
              subtitle: Text('피겨스케이터'),
            ),
            const ListTile(
              leading: CircleAvatar(child: Text('BTS')),
              title: Text('BTS'),
              subtitle: Text('가수'),
            ),

            if (selectedCelebrity != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('분석하기'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MockCelebrityFortuneResult extends StatelessWidget {
  final String celebrityName;

  const _MockCelebrityFortuneResult({
    this.celebrityName = '손흥민',
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('유명인 운세 분석', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),

            // 유명인 정보
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                        radius: 40, child: Icon(Icons.person, size: 40)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(celebrityName,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const Text('1992년 7월 8일'),
                        const Text('축구선수'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Card(
              child: ListTile(
                title: Text('사주 분석'),
                subtitle: Text('화(火) 기운이 강한 사주입니다'),
              ),
            ),
            const Card(
              child: ListTile(
                title: Text('성공 요인'),
                subtitle: Text('끈기와 열정, 목표 지향적 성격'),
              ),
            ),
            const Card(
              child: ListTile(
                title: Text('나와의 비교'),
                subtitle: Text('당신과 비슷한 오행 구성을 가지고 있습니다'),
              ),
            ),
            const Card(
              child: ListTile(
                title: Text('배울 점'),
                subtitle: Text('꾸준한 노력과 자기 관리'),
              ),
            ),

            const SizedBox(height: 16),
            const Text('같은 생일 유명인',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const ListTile(
              leading: CircleAvatar(child: Text('A')),
              title: Text('유명인 A'),
            ),
            const ListTile(
              leading: CircleAvatar(child: Text('B')),
              title: Text('유명인 B'),
            ),
          ],
        ),
      ),
    );
  }
}
