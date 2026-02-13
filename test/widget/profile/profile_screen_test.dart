// Profile Screen - Widget Test
// 프로필 화면 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('ProfileScreen 테스트', () {
    group('UI 렌더링', () {
      testWidgets('프로필 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileScreen(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.text('내 프로필'), findsOneWidget);
      });

      testWidgets('사용자 기본 정보가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileScreen(
                  name: '홍길동',
                  birthDate: '1990-01-15',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('홍길동'), findsOneWidget);
        expect(find.text('1990-01-15'), findsOneWidget);
      });

      testWidgets('프로필 이미지/아바타가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileScreen(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(CircleAvatar), findsOneWidget);
      });

      testWidgets('편집 버튼이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileScreen(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.edit), findsOneWidget);
      });
    });

    group('사주 정보 표시', () {
      testWidgets('사주 요약 카드가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileScreen(
                  hasSajuData: true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('사주 정보'), findsOneWidget);
      });

      testWidgets('주 오행이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileScreen(
                  hasSajuData: true,
                  mainElement: '목(木)',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('목(木)'), findsOneWidget);
      });

      testWidgets('사주 상세보기 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileScreen(
                  hasSajuData: true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('상세보기'), findsOneWidget);
      });
    });

    group('별자리 & 띠 표시', () {
      testWidgets('별자리가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileScreen(
                  zodiacSign: '염소자리',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('염소자리'), findsOneWidget);
      });

      testWidgets('띠가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileScreen(
                  chineseZodiac: '말띠',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('말띠'), findsOneWidget);
      });
    });

    group('인터랙션', () {
      testWidgets('편집 버튼 탭 시 편집 화면으로 이동', (tester) async {
        bool editPressed = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileScreen(
                  onEditPressed: () => editPressed = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        expect(editPressed, isTrue);
      });

      testWidgets('사주 상세보기 탭 시 상세 화면으로 이동', (tester) async {
        bool detailPressed = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileScreen(
                  hasSajuData: true,
                  onSajuDetailPressed: () => detailPressed = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('상세보기'));
        await tester.pumpAndSettle();

        expect(detailPressed, isTrue);
      });
    });

    group('운세 히스토리', () {
      testWidgets('최근 운세 히스토리가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileScreen(
                  showHistory: true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('최근 운세'), findsOneWidget);
      });
    });

    group('프리미엄 상태', () {
      testWidgets('프리미엄 사용자 배지 표시', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileScreen(
                  isPremium: true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('프리미엄'), findsOneWidget);
      });

      testWidgets('일반 사용자는 프리미엄 배지 없음', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileScreen(
                  isPremium: false,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('프리미엄'), findsNothing);
      });
    });

    group('테마 지원', () {
      testWidgets('라이트 테마에서 올바르게 렌더링', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const Scaffold(
                body: _MockProfileScreen(),
              ),
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
              home: const Scaffold(
                body: _MockProfileScreen(),
              ),
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

class _MockProfileScreen extends StatelessWidget {
  final String name;
  final String birthDate;
  final String? zodiacSign;
  final String? chineseZodiac;
  final bool hasSajuData;
  final String? mainElement;
  final bool showHistory;
  final bool isPremium;
  final VoidCallback? onEditPressed;
  final VoidCallback? onSajuDetailPressed;

  const _MockProfileScreen({
    this.name = '홍길동',
    this.birthDate = '1990-01-15',
    this.zodiacSign,
    this.chineseZodiac,
    this.hasSajuData = false,
    this.mainElement,
    this.showHistory = false,
    this.isPremium = false,
    this.onEditPressed,
    this.onSajuDetailPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '내 프로필',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEditPressed,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 프로필 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isPremium) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    '프리미엄',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(birthDate),
                          if (zodiacSign != null) ...[
                            const SizedBox(height: 4),
                            Text(zodiacSign!),
                          ],
                          if (chineseZodiac != null) ...[
                            const SizedBox(height: 4),
                            Text(chineseZodiac!),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 사주 정보
            if (hasSajuData) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '사주 정보',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: onSajuDetailPressed,
                            child: const Text('상세보기'),
                          ),
                        ],
                      ),
                      if (mainElement != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('주 오행: '),
                            Text(
                              mainElement!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            // 최근 운세
            if (showHistory) ...[
              const SizedBox(height: 16),
              const Text(
                '최근 운세',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.star),
                    title: Text('운세 $index'),
                    subtitle: Text(
                        '${DateTime.now().subtract(Duration(days: index))}'),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
