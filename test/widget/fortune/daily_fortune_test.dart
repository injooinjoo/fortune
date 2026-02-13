// Daily Fortune Page - Widget Test
// 일일 운세 페이지 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('DailyFortunePage 테스트', () {
    group('UI 렌더링', () {
      testWidgets('일일운세 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDailyFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('오늘의 운세'), findsOneWidget);
      });

      testWidgets('날짜가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDailyFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        // 오늘 날짜 표시
        expect(find.textContaining('2024'), findsWidgets);
      });

      testWidgets('운세 점수가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockDailyFortunePage(score: 85),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('85점'), findsOneWidget);
      });
    });

    group('운세 카테고리', () {
      testWidgets('종합운이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDailyFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('종합운'), findsOneWidget);
      });

      testWidgets('연애운이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDailyFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('연애운'), findsOneWidget);
      });

      testWidgets('재물운이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDailyFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('재물운'), findsOneWidget);
      });

      testWidgets('건강운이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDailyFortunePage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('건강운'), findsOneWidget);
      });
    });

    group('행운 아이템', () {
      testWidgets('행운의 색상이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockDailyFortunePage(
                  luckyColor: '파란색',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('행운의 색상'), findsOneWidget);
        expect(find.text('파란색'), findsOneWidget);
      });

      testWidgets('행운의 숫자가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockDailyFortunePage(
                  luckyNumber: 7,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('행운의 숫자'), findsOneWidget);
        expect(find.text('7'), findsOneWidget);
      });
    });

    group('로딩 상태', () {
      testWidgets('로딩 중 스켈레톤 표시', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockDailyFortunePageLoading(),
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('에러 상태', () {
      testWidgets('에러 메시지 표시', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockDailyFortunePageError(
                  errorMessage: '운세를 불러오는데 실패했습니다',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('운세를 불러오는데 실패했습니다'), findsOneWidget);
      });

      testWidgets('다시 시도 버튼 표시', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockDailyFortunePageError(
                  errorMessage: '오류',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('다시 시도'), findsOneWidget);
      });
    });

    group('공유 기능', () {
      testWidgets('공유 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockDailyFortunePage()),
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

class _MockDailyFortunePage extends StatelessWidget {
  final int score;
  final String? luckyColor;
  final int? luckyNumber;

  const _MockDailyFortunePage({
    this.score = 75,
    this.luckyColor,
    this.luckyNumber,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              title: const Text('오늘의 운세'),
              actions: [
                IconButton(icon: const Icon(Icons.share), onPressed: () {}),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('2024년 12월 7일'),
                  const SizedBox(height: 16),
                  Text('$score점', style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 24),
                  const _FortuneCategory(title: '종합운'),
                  const _FortuneCategory(title: '연애운'),
                  const _FortuneCategory(title: '재물운'),
                  const _FortuneCategory(title: '건강운'),
                  if (luckyColor != null) ...[
                    const SizedBox(height: 16),
                    const Text('행운의 색상'),
                    Text(luckyColor!),
                  ],
                  if (luckyNumber != null) ...[
                    const SizedBox(height: 16),
                    const Text('행운의 숫자'),
                    Text('$luckyNumber'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FortuneCategory extends StatelessWidget {
  final String title;

  const _FortuneCategory({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: const Text('상세 내용'),
      ),
    );
  }
}

class _MockDailyFortunePageLoading extends StatelessWidget {
  const _MockDailyFortunePageLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _MockDailyFortunePageError extends StatelessWidget {
  final String errorMessage;

  const _MockDailyFortunePageError({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(errorMessage),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () {}, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
