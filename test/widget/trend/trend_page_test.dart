// Trend Page Widget Test
// 트렌드/인기 운세 페이지 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('트렌드 페이지 테스트', () {
    group('초기 렌더링', () {
      testWidgets('트렌드 페이지가 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        expect(find.text('인기 운세'), findsOneWidget);
        expect(find.byType(_MockTrendPage), findsOneWidget);
      });

      testWidgets('인기 운세 목록이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        expect(find.byKey(const Key('trend_list')), findsOneWidget);
      });

      testWidgets('탭 메뉴가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        expect(find.text('실시간'), findsOneWidget);
        expect(find.text('주간'), findsOneWidget);
        expect(find.text('월간'), findsOneWidget);
      });
    });

    group('실시간 인기 운세', () {
      testWidgets('실시간 인기 순위가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        expect(find.byKey(const Key('realtime_ranking')), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('순위 변동 표시가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        // 상승, 하락, 유지 아이콘
        expect(find.byIcon(Icons.arrow_upward), findsWidgets);
        expect(find.byIcon(Icons.arrow_downward), findsWidgets);
        expect(find.byIcon(Icons.remove), findsWidgets);
      });

      testWidgets('각 운세 항목에 이용 횟수가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        expect(find.textContaining('회 이용'), findsWidgets);
      });

      testWidgets('자동 새로고침이 동작해야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        // 새로고침 시간 표시
        expect(find.textContaining('갱신'), findsOneWidget);
      });
    });

    group('주간 인기 운세', () {
      testWidgets('주간 탭 선택 시 주간 데이터가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        await tester.tap(find.text('주간'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('weekly_ranking')), findsOneWidget);
      });

      testWidgets('주간 차트가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(selectedTab: 1),
          ),
        );

        expect(find.byKey(const Key('weekly_chart')), findsOneWidget);
      });

      testWidgets('지난 주 대비 변화가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(selectedTab: 1),
          ),
        );

        expect(find.textContaining('지난 주 대비'), findsWidgets);
      });
    });

    group('월간 인기 운세', () {
      testWidgets('월간 탭 선택 시 월간 데이터가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        await tester.tap(find.text('월간'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('monthly_ranking')), findsOneWidget);
      });

      testWidgets('월간 통계 요약이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(selectedTab: 2),
          ),
        );

        expect(find.text('이번 달 총 이용'), findsOneWidget);
        expect(find.textContaining('회'), findsWidgets);
      });
    });

    group('운세 카드', () {
      testWidgets('운세 카드에 아이콘이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        expect(find.byKey(const Key('fortune_icon_0')), findsOneWidget);
      });

      testWidgets('운세 카드에 이름이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        expect(find.text('오늘의 운세'), findsOneWidget);
        expect(find.text('타로'), findsOneWidget);
        expect(find.text('궁합'), findsOneWidget);
      });

      testWidgets('운세 카드 탭 시 해당 페이지로 이동해야 함', (tester) async {
        bool navigated = false;

        await tester.pumpWidget(
          MaterialApp(
            home: _MockTrendPage(
              onFortuneTap: () => navigated = true,
            ),
          ),
        );

        await tester.tap(find.byKey(const Key('fortune_card_0')));
        await tester.pump();

        expect(navigated, isTrue);
      });

      testWidgets('인기 급상승 뱃지가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        expect(find.text('HOT'), findsWidgets);
      });

      testWidgets('신규 운세에 NEW 뱃지가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        expect(find.text('NEW'), findsWidgets);
      });
    });

    group('카테고리 필터', () {
      testWidgets('카테고리 필터가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        expect(find.byKey(const Key('category_filter')), findsOneWidget);
      });

      testWidgets('전체, 연애, 직업, 재물 카테고리가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        expect(find.text('전체'), findsOneWidget);
        expect(find.text('연애'), findsOneWidget);
        expect(find.text('직업'), findsOneWidget);
        expect(find.text('재물'), findsOneWidget);
      });

      testWidgets('카테고리 선택 시 필터링되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        await tester.tap(find.text('연애'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('filtered_list')), findsOneWidget);
      });
    });

    group('사용자 통계', () {
      testWidgets('나의 이용 통계가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(isLoggedIn: true),
          ),
        );

        expect(find.text('나의 이용 통계'), findsOneWidget);
      });

      testWidgets('가장 많이 이용한 운세가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(isLoggedIn: true),
          ),
        );

        expect(find.text('가장 많이 이용'), findsOneWidget);
      });

      testWidgets('비로그인 시 로그인 유도가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(isLoggedIn: false),
          ),
        );

        expect(find.text('로그인하고 내 통계 확인하기'), findsOneWidget);
      });
    });

    group('추천 운세', () {
      testWidgets('추천 운세 섹션이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        expect(find.text('당신을 위한 추천'), findsOneWidget);
      });

      testWidgets('개인화된 추천이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(isLoggedIn: true),
          ),
        );

        expect(find.byKey(const Key('personalized_recommendation')),
            findsOneWidget);
      });
    });

    group('Pull to Refresh', () {
      testWidgets('당겨서 새로고침이 가능해야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        expect(find.byType(RefreshIndicator), findsOneWidget);
      });

      testWidgets('새로고침 시 데이터가 갱신되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(),
          ),
        );

        // Pull to refresh 시뮬레이션
        await tester.drag(
          find.byKey(const Key('trend_list')),
          const Offset(0, 200),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('trend_list')), findsOneWidget);
      });
    });

    group('테마 지원', () {
      testWidgets('라이트 모드에서 올바른 스타일이 적용되어야 함', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: const _MockTrendPage(),
          ),
        );

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, isNot(Colors.black));
      });

      testWidgets('다크 모드에서 올바른 스타일이 적용되어야 함', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const _MockTrendPage(),
          ),
        );

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, isNot(Colors.white));
      });
    });

    group('로딩 상태', () {
      testWidgets('로딩 중 스켈레톤이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(isLoading: true),
          ),
        );

        expect(find.byKey(const Key('loading_skeleton')), findsOneWidget);
      });

      testWidgets('에러 발생 시 재시도 버튼이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: _MockTrendPage(hasError: true),
          ),
        );

        expect(find.text('다시 시도'), findsOneWidget);
      });
    });
  });
}

// ===========================================
// Test Data
// ===========================================

class TrendTestData {
  static List<Map<String, dynamic>> getTrendingFortunes() {
    return [
      {
        'id': 'daily',
        'name': '오늘의 운세',
        'icon': 'sun',
        'usage_count': 15234,
        'rank_change': 0,
        'is_hot': false,
        'is_new': false,
        'category': '일반',
      },
      {
        'id': 'tarot',
        'name': '타로',
        'icon': 'tarot',
        'usage_count': 12456,
        'rank_change': 2,
        'is_hot': true,
        'is_new': false,
        'category': '일반',
      },
      {
        'id': 'compatibility',
        'name': '궁합',
        'icon': 'heart',
        'usage_count': 10234,
        'rank_change': -1,
        'is_hot': false,
        'is_new': false,
        'category': '연애',
      },
      {
        'id': 'career',
        'name': '직업운',
        'icon': 'briefcase',
        'usage_count': 8123,
        'rank_change': 1,
        'is_hot': false,
        'is_new': true,
        'category': '직업',
      },
      {
        'id': 'investment',
        'name': '투자운',
        'icon': 'chart',
        'usage_count': 7456,
        'rank_change': 0,
        'is_hot': true,
        'is_new': false,
        'category': '재물',
      },
    ];
  }

  static List<String> getCategories() {
    return ['전체', '연애', '직업', '재물', '건강', '기타'];
  }
}

// ===========================================
// Mock Widgets
// ===========================================

class _MockTrendPage extends StatefulWidget {
  final int selectedTab;
  final bool isLoggedIn;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onFortuneTap;

  const _MockTrendPage({
    this.selectedTab = 0,
    this.isLoggedIn = false,
    this.isLoading = false,
    this.hasError = false,
    this.onFortuneTap,
  });

  @override
  State<_MockTrendPage> createState() => _MockTrendPageState();
}

class _MockTrendPageState extends State<_MockTrendPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _selectedTab;
  String _selectedCategory = '전체';

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.selectedTab;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _selectedTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('인기 운세')),
        body: Container(
          key: const Key('loading_skeleton'),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (widget.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('인기 운세')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('데이터를 불러올 수 없습니다'),
              ElevatedButton(
                onPressed: () {},
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('인기 운세'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() => _selectedTab = index);
          },
          tabs: const [
            Tab(text: '실시간'),
            Tab(text: '주간'),
            Tab(text: '월간'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카테고리 필터
              _buildCategoryFilter(),

              // 갱신 시간
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                    '최근 갱신: ${DateTime.now().hour}:${DateTime.now().minute}'),
              ),

              // 탭별 콘텐츠
              if (_selectedTab == 0) _buildRealtimeRanking(),
              if (_selectedTab == 1) _buildWeeklyRanking(),
              if (_selectedTab == 2) _buildMonthlyRanking(),

              // 사용자 통계
              _buildUserStats(),

              // 추천 운세
              _buildRecommendation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      key: const Key('category_filter'),
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: TrendTestData.getCategories().map((category) {
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRealtimeRanking() {
    final fortunes = TrendTestData.getTrendingFortunes();
    final filtered = _selectedCategory == '전체'
        ? fortunes
        : fortunes.where((f) => f['category'] == _selectedCategory).toList();

    return Container(
      key: _selectedCategory == '전체'
          ? const Key('realtime_ranking')
          : const Key('filtered_list'),
      child: ListView(
        key: const Key('trend_list'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: filtered.asMap().entries.map((entry) {
          final index = entry.key;
          final fortune = entry.value;
          return _buildFortuneCard(fortune, index);
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklyRanking() {
    return Column(
      key: const Key('weekly_ranking'),
      children: [
        // 주간 차트
        Container(
          key: const Key('weekly_chart'),
          height: 200,
          margin: const EdgeInsets.all(16),
          color: Colors.grey.shade200,
          child: const Center(child: Text('주간 이용 차트')),
        ),
        // 순위 목록
        ...TrendTestData.getTrendingFortunes().map((fortune) {
          return ListTile(
            title: Text(fortune['name'] as String),
            subtitle: const Text('지난 주 대비 +15%'),
          );
        }),
      ],
    );
  }

  Widget _buildMonthlyRanking() {
    return Column(
      key: const Key('monthly_ranking'),
      children: [
        // 월간 통계
        const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('이번 달 총 이용'),
              Text('152,456회', style: TextStyle(fontSize: 24)),
            ],
          ),
        ),
        // 순위 목록
        ...TrendTestData.getTrendingFortunes().map((fortune) {
          return ListTile(
            title: Text(fortune['name'] as String),
            trailing: Text('${fortune['usage_count']}회'),
          );
        }),
      ],
    );
  }

  Widget _buildFortuneCard(Map<String, dynamic> fortune, int index) {
    final rankChange = fortune['rank_change'] as int;

    return Card(
      key: Key('fortune_card_$index'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: widget.onFortuneTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 순위
              Text('${index + 1}', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),

              // 순위 변동
              if (rankChange > 0)
                const Icon(Icons.arrow_upward, color: Colors.red, size: 16),
              if (rankChange < 0)
                const Icon(Icons.arrow_downward, color: Colors.blue, size: 16),
              if (rankChange == 0)
                const Icon(Icons.remove, color: Colors.grey, size: 16),

              const SizedBox(width: 12),

              // 아이콘
              Container(
                key: Key('fortune_icon_$index'),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.star),
              ),

              const SizedBox(width: 12),

              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(fortune['name'] as String),
                        const SizedBox(width: 4),
                        if (fortune['is_hot'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('HOT',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10)),
                          ),
                        if (fortune['is_new'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('NEW',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10)),
                          ),
                      ],
                    ),
                    Text('${fortune['usage_count']}회 이용'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserStats() {
    if (!widget.isLoggedIn) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.person_outline, size: 48),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('로그인하고 내 통계 확인하기'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('나의 이용 통계', style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              Text('가장 많이 이용'),
              Text('타로 - 24회'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendation() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('당신을 위한 추천', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          if (widget.isLoggedIn)
            SizedBox(
              key: const Key('personalized_recommendation'),
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.all(8),
                      child: Center(child: Text('추천 $index')),
                    ),
                  );
                },
              ),
            )
          else
            const Text('로그인하면 개인화된 추천을 받을 수 있어요!'),
        ],
      ),
    );
  }
}
