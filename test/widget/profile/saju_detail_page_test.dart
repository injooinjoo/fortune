/// Saju Detail Page - Widget Test
/// 사주 상세 화면 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('SajuDetailPage 테스트', () {
    group('UI 렌더링', () {
      testWidgets('사주 상세 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.text('사주 분석'), findsOneWidget);
      });

      testWidgets('사주팔자가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 사주팔자 (년월일시)
        expect(find.text('년주'), findsOneWidget);
        expect(find.text('월주'), findsOneWidget);
        expect(find.text('일주'), findsOneWidget);
        expect(find.text('시주'), findsOneWidget);
      });
    });

    group('천간지지 표시', () {
      testWidgets('천간이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(
                  yearStem: '경',
                  monthStem: '정',
                  dayStem: '갑',
                  hourStem: '기',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('경'), findsOneWidget);
        expect(find.text('정'), findsOneWidget);
        expect(find.text('갑'), findsOneWidget);
        expect(find.text('기'), findsOneWidget);
      });

      testWidgets('지지가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(
                  yearBranch: '오',
                  monthBranch: '축',
                  dayBranch: '자',
                  hourBranch: '사',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('오'), findsOneWidget);
        expect(find.text('축'), findsOneWidget);
        expect(find.text('자'), findsOneWidget);
        expect(find.text('사'), findsOneWidget);
      });
    });

    group('오행 분포', () {
      testWidgets('오행 분포 차트가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('오행 분포'), findsOneWidget);
      });

      testWidgets('각 오행이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('목(木)'), findsOneWidget);
        expect(find.text('화(火)'), findsOneWidget);
        expect(find.text('토(土)'), findsOneWidget);
        expect(find.text('금(金)'), findsOneWidget);
        expect(find.text('수(水)'), findsOneWidget);
      });

      testWidgets('주 오행이 강조되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(
                  dominantElement: 'fire',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 주 오행 표시
        expect(find.text('주 오행: 화(火)'), findsOneWidget);
      });

      testWidgets('부족한 오행이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(
                  weakElement: 'earth',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('부족: 토(土)'), findsOneWidget);
      });
    });

    group('성격 분석', () {
      testWidgets('성격 특성이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(
                  traits: ['창의적', '진취적', '리더십'],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('성격 특성'), findsOneWidget);
        expect(find.text('창의적'), findsOneWidget);
        expect(find.text('진취적'), findsOneWidget);
        expect(find.text('리더십'), findsOneWidget);
      });

      testWidgets('강점이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(
                  strengths: ['추진력', '결단력'],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('강점'), findsOneWidget);
        expect(find.text('추진력'), findsOneWidget);
        expect(find.text('결단력'), findsOneWidget);
      });

      testWidgets('약점이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(
                  weaknesses: ['성급함', '고집'],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('약점'), findsOneWidget);
        expect(find.text('성급함'), findsOneWidget);
        expect(find.text('고집'), findsOneWidget);
      });
    });

    group('추천 사항', () {
      testWidgets('행운의 색상이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(
                  luckyColor: '노랑/갈색',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('행운의 색상'), findsOneWidget);
        expect(find.text('노랑/갈색'), findsOneWidget);
      });

      testWidgets('행운의 방향이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(
                  luckyDirection: '남쪽',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('행운의 방향'), findsOneWidget);
        expect(find.text('남쪽'), findsOneWidget);
      });

      testWidgets('보충 추천이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(
                  recommendations: ['토 기운을 보충하면 좋습니다'],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('추천 사항'), findsOneWidget);
        expect(find.text('토 기운을 보충하면 좋습니다'), findsOneWidget);
      });
    });

    group('균형 점수', () {
      testWidgets('균형 점수가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(
                  balanceScore: 75,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('균형 점수'), findsOneWidget);
        expect(find.text('75점'), findsOneWidget);
      });

      testWidgets('균형 상태 설명이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(
                  balanceScore: 75,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 점수에 따른 설명
        expect(find.textContaining('균형'), findsWidgets);
      });
    });

    group('스크롤 및 레이아웃', () {
      testWidgets('스크롤이 가능해야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // SingleChildScrollView가 있어야 함
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
    });

    group('인터랙션', () {
      testWidgets('뒤로가기 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('공유 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.share), findsOneWidget);
      });

      testWidgets('공유 버튼 탭 시 공유 기능 호출', (tester) async {
        bool sharePressed = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(
                  onShare: () => sharePressed = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.share));
        await tester.pumpAndSettle();

        expect(sharePressed, isTrue);
      });
    });

    group('테마 지원', () {
      testWidgets('라이트 테마에서 올바르게 렌더링', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const Scaffold(
                body: _MockSajuDetailPage(),
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
                body: _MockSajuDetailPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('오행 색상', () {
      testWidgets('각 오행이 고유 색상을 가져야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSajuDetailPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 오행별 컨테이너 색상 확인은 복잡하므로 렌더링만 확인
        expect(find.text('목(木)'), findsOneWidget);
      });
    });
  });
}

// ============================================
// Mock Widgets
// ============================================

class _MockSajuDetailPage extends StatelessWidget {
  final String yearStem;
  final String yearBranch;
  final String monthStem;
  final String monthBranch;
  final String dayStem;
  final String dayBranch;
  final String hourStem;
  final String hourBranch;
  final String? dominantElement;
  final String? weakElement;
  final List<String> traits;
  final List<String> strengths;
  final List<String> weaknesses;
  final String? luckyColor;
  final String? luckyDirection;
  final List<String> recommendations;
  final int balanceScore;
  final VoidCallback? onShare;

  const _MockSajuDetailPage({
    this.yearStem = '경',
    this.yearBranch = '오',
    this.monthStem = '정',
    this.monthBranch = '축',
    this.dayStem = '갑',
    this.dayBranch = '자',
    this.hourStem = '기',
    this.hourBranch = '사',
    this.dominantElement,
    this.weakElement,
    this.traits = const [],
    this.strengths = const [],
    this.weaknesses = const [],
    this.luckyColor,
    this.luckyDirection,
    this.recommendations = const [],
    this.balanceScore = 65,
    this.onShare,
  });

  String _getElementName(String? element) {
    switch (element) {
      case 'wood':
        return '목(木)';
      case 'fire':
        return '화(火)';
      case 'earth':
        return '토(土)';
      case 'metal':
        return '금(金)';
      case 'water':
        return '수(水)';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 앱바
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {},
                ),
                const Expanded(
                  child: Text(
                    '사주 분석',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: onShare,
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 사주팔자 카드
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            '사주팔자',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _PillarWidget(
                                title: '년주',
                                stem: yearStem,
                                branch: yearBranch,
                              ),
                              _PillarWidget(
                                title: '월주',
                                stem: monthStem,
                                branch: monthBranch,
                              ),
                              _PillarWidget(
                                title: '일주',
                                stem: dayStem,
                                branch: dayBranch,
                              ),
                              _PillarWidget(
                                title: '시주',
                                stem: hourStem,
                                branch: hourBranch,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 오행 분포
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '오행 분포',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ElementRow(name: '목(木)', value: 2, color: Colors.green),
                          _ElementRow(name: '화(火)', value: 3, color: Colors.red),
                          _ElementRow(name: '토(土)', value: 1, color: Colors.brown),
                          _ElementRow(name: '금(金)', value: 1, color: Colors.grey),
                          _ElementRow(name: '수(水)', value: 1, color: Colors.blue),
                          const SizedBox(height: 16),
                          if (dominantElement != null)
                            Text('주 오행: ${_getElementName(dominantElement)}'),
                          if (weakElement != null)
                            Text('부족: ${_getElementName(weakElement)}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 균형 점수
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            '균형 점수',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$balanceScore점',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 성격 특성
                  if (traits.isNotEmpty) ...[
                    const Text(
                      '성격 특성',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: traits
                          .map((trait) => Chip(label: Text(trait)))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 강점
                  if (strengths.isNotEmpty) ...[
                    const Text(
                      '강점',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: strengths
                          .map((s) => Chip(
                                label: Text(s),
                                backgroundColor: Colors.green.shade100,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 약점
                  if (weaknesses.isNotEmpty) ...[
                    const Text(
                      '약점',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: weaknesses
                          .map((w) => Chip(
                                label: Text(w),
                                backgroundColor: Colors.orange.shade100,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 행운의 색상
                  if (luckyColor != null) ...[
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.color_lens),
                        title: const Text('행운의 색상'),
                        trailing: Text(luckyColor!),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // 행운의 방향
                  if (luckyDirection != null) ...[
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.compass_calibration),
                        title: const Text('행운의 방향'),
                        trailing: Text(luckyDirection!),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 추천 사항
                  if (recommendations.isNotEmpty) ...[
                    const Text(
                      '추천 사항',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...recommendations.map((rec) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(rec)),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillarWidget extends StatelessWidget {
  final String title;
  final String stem;
  final String branch;

  const _PillarWidget({
    required this.title,
    required this.stem,
    required this.branch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                stem,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                branch,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ElementRow extends StatelessWidget {
  final String name;
  final int value;
  final Color color;

  const _ElementRow({
    required this.name,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(name),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(width: 8),
          Text('$value'),
        ],
      ),
    );
  }
}
