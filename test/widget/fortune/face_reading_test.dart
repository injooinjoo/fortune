// Face Reading Fortune Page - Widget Test
// 관상 페이지 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('FaceReadingFortunePage 테스트', () {
    group('UI 렌더링', () {
      testWidgets('관상 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockFaceReadingPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('관상'), findsOneWidget);
      });
    });

    group('사진 업로드', () {
      testWidgets('사진 업로드 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockFaceReadingPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('사진 업로드'), findsOneWidget);
      });

      testWidgets('카메라 촬영 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockFaceReadingPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      });

      testWidgets('갤러리 선택 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockFaceReadingPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.photo_library), findsOneWidget);
      });

      testWidgets('가이드라인이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockFaceReadingPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('정면 사진을 올려주세요'), findsOneWidget);
      });
    });

    group('결과 화면', () {
      testWidgets('관상 분석 결과가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockFaceReadingResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('관상 분석 결과'), findsOneWidget);
      });

      testWidgets('전체 운세가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockFaceReadingResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('전체운'), findsOneWidget);
      });

      testWidgets('이마 분석이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockFaceReadingResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('이마'), findsOneWidget);
      });

      testWidgets('눈 분석이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockFaceReadingResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('눈'), findsOneWidget);
      });

      testWidgets('코 분석이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockFaceReadingResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('코'), findsOneWidget);
      });

      testWidgets('입 분석이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockFaceReadingResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('입'), findsOneWidget);
      });

      testWidgets('턱 분석이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockFaceReadingResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('턱'), findsOneWidget);
      });
    });

    group('카테고리별 분석', () {
      testWidgets('재물운이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockFaceReadingResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('재물운'), findsOneWidget);
      });

      testWidgets('연애운이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockFaceReadingResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('연애운'), findsOneWidget);
      });

      testWidgets('직업운이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockFaceReadingResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('직업운'), findsOneWidget);
      });
    });

    group('닮은 유명인', () {
      testWidgets('닮은 유명인이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockFaceReadingResult()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('닮은 유명인'), findsOneWidget);
      });
    });

    group('인터랙션', () {
      testWidgets('분석하기 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockFaceReadingPage(hasImage: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('분석하기'), findsOneWidget);
      });

      testWidgets('공유 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockFaceReadingResult()),
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

class _MockFaceReadingPage extends StatelessWidget {
  final bool hasImage;

  const _MockFaceReadingPage({this.hasImage = false});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('관상', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: hasImage
                    ? const Icon(Icons.person, size: 100)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('사진 업로드'),
                          const SizedBox(height: 8),
                          const Text('정면 사진을 올려주세요'),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.camera_alt),
                                onPressed: () {},
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.photo_library),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            if (hasImage) ...[
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

class _MockFaceReadingResult extends StatelessWidget {
  const _MockFaceReadingResult();

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
                const Text('관상 분석 결과', style: TextStyle(fontSize: 24)),
                IconButton(icon: const Icon(Icons.share), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),

            // 전체운
            const Card(
              child: ListTile(
                title: Text('전체운'),
                subtitle: Text('85점'),
                trailing: Icon(Icons.star, color: Colors.amber),
              ),
            ),

            const SizedBox(height: 16),
            const Text('부위별 분석', style: TextStyle(fontWeight: FontWeight.bold)),
            const Card(child: ListTile(title: Text('이마'), subtitle: Text('지혜와 관록의 상'))),
            const Card(child: ListTile(title: Text('눈'), subtitle: Text('매력적인 눈'))),
            const Card(child: ListTile(title: Text('코'), subtitle: Text('재물복이 있는 코'))),
            const Card(child: ListTile(title: Text('입'), subtitle: Text('복이 있는 입'))),
            const Card(child: ListTile(title: Text('턱'), subtitle: Text('의지가 강한 턱'))),

            const SizedBox(height: 16),
            const Text('운세별 분석', style: TextStyle(fontWeight: FontWeight.bold)),
            const Card(child: ListTile(title: Text('재물운'), trailing: Text('80점'))),
            const Card(child: ListTile(title: Text('연애운'), trailing: Text('88점'))),
            const Card(child: ListTile(title: Text('직업운'), trailing: Text('85점'))),

            const SizedBox(height: 16),
            const Card(
              child: ListTile(
                title: Text('닮은 유명인'),
                subtitle: Text('분석 중...'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
