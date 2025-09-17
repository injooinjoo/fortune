import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/toss_design_system.dart';

import '../../../../presentation/providers/auth_provider.dart';
import '../../../../services/weather_service.dart';
import 'dart:math';

class LuckyItemsResultsPage extends ConsumerStatefulWidget {
  const LuckyItemsResultsPage({super.key});

  @override
  ConsumerState<LuckyItemsResultsPage> createState() => _LuckyItemsResultsPageState();
}

class _LuckyItemsResultsPageState extends ConsumerState<LuckyItemsResultsPage> {
  final Random _random = Random();
  late Map<String, dynamic> _generatedResults;
  bool _isLoading = true;

  // 8개 카테고리 정의
  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'lotto',
      'title': '로또 번호',
      'icon': Icons.casino,
      'color': Color(0xFFFFB300),
      'description': '행운의 번호와 최적 구매 시간'
    },
    {
      'id': 'shopping',
      'title': '쇼핑',
      'icon': Icons.shopping_bag,
      'color': Color(0xFFE91E63),
      'description': '오늘의 럭키 아이템과 구매 팁'
    },
    {
      'id': 'game',
      'title': '게임',
      'icon': Icons.games,
      'color': Color(0xFF9C27B0),
      'description': '승부운을 높이는 게임 추천'
    },
    {
      'id': 'food',
      'title': '음식',
      'icon': Icons.restaurant,
      'color': Color(0xFFFF5722),
      'description': '행운을 부르는 오늘의 음식'
    },
    {
      'id': 'travel',
      'title': '여행',
      'icon': Icons.flight,
      'color': Color(0xFF2196F3),
      'description': '운이 좋은 여행지와 방향'
    },
    {
      'id': 'health',
      'title': '건강',
      'icon': Icons.health_and_safety,
      'color': Color(0xFF4CAF50),
      'description': '건강 운세와 주의사항'
    },
    {
      'id': 'fashion',
      'title': '패션',
      'icon': Icons.checkroom,
      'color': Color(0xFFFF9800),
      'description': '오늘의 럭키 컬러와 스타일'
    },
    {
      'id': 'lifestyle',
      'title': '라이프스타일',
      'icon': Icons.home,
      'color': Color(0xFF607D8B),
      'description': '일상의 행운을 높이는 팁'
    },
  ];

  @override
  void initState() {
    super.initState();
    _generateResults();
  }

  void _generateResults() {
    final today = DateTime.now();
    final dateString = '${today.year}-${today.month}-${today.day}';
    
    // 1. 각 카테고리별 점수와 데이터 생성
    final categoryResults = _categories.map((category) {
      final score = 60 + _random.nextInt(35); // 60-94점
      return {
        'id': category['id'],
        'title': category['title'],
        'icon': category['icon'],
        'color': category['color'],
        'description': category['description'],
        'score': score,
        'items': _generateCategoryItems(category['id']),
        'recommendation': _generateRecommendation(category['id']),
      };
    }).toList();

    // 2. 종합 점수 계산 (8개 카테고리 점수의 평균값)
    final totalScore = categoryResults.fold<int>(
      0, (sum, category) => sum + (category['score'] as int)
    );
    final overallScore = (totalScore / categoryResults.length).round();

    // 3. 최고 점수 카테고리 찾기
    final bestCategory = categoryResults.reduce((a, b) =>
      (a['score'] as int) > (b['score'] as int) ? a : b
    );
    
    _generatedResults = {
      'date': dateString,
      'categories': categoryResults,
      'overallScore': overallScore,
      'bestCategory': bestCategory['title'],
      'dailyTip': _generateDailyTip(),
    };

    setState(() {
      _isLoading = false;
    });
  }

  List<String> _generateCategoryItems(String categoryId) {
    switch (categoryId) {
      case 'lotto':
        return [
          '행운 번호: ${_generateLottoNumbers()}',
          '구매 시간: ${_generateTime()}',
          '구매 장소: ${_generateLocation()}',
          '추천 복권: ${_generateLotteryType()}'
        ];
      case 'shopping':
        return [
          '럭키 아이템: ${_generateShoppingItem()}',
          '쇼핑 시간: ${_generateTime()}',
          '추천 브랜드: ${_generateBrand()}',
          '할인 정보: ${_generateDiscount()}'
        ];
      case 'game':
        return [
          '추천 게임: ${_generateGame()}',
          '플레이 시간: ${_generateTime()}',
          '승부 운세: ${_generateGameLuck()}',
          '팀 운세: ${_generateTeamLuck()}'
        ];
      case 'food':
        return [
          '행운 음식: ${_generateFood()}',
          '식사 시간: ${_generateMealTime()}',
          '요리 방법: ${_generateCookingMethod()}',
          '맛 조합: ${_generateFlavor()}'
        ];
      case 'travel':
        return [
          '행운 방향: ${_generateDirection()}',
          '추천 장소: ${_generateTravelPlace()}',
          '여행 시간: ${_generateTravelTime()}',
          '교통수단: ${_generateTransport()}'
        ];
      case 'health':
        return [
          '건강 포인트: ${_generateHealthPoint()}',
          '운동 추천: ${_generateExercise()}',
          '주의사항: ${_generateHealthWarning()}',
          '영양소: ${_generateNutrient()}'
        ];
      case 'fashion':
        return [
          '럭키 컬러: ${_generateColor()}',
          '스타일 팁: ${_generateStyle()}',
          '액세서리: ${_generateAccessory()}',
          '소재 추천: ${_generateMaterial()}'
        ];
      case 'lifestyle':
        return [
          '생활 팁: ${_generateLifestyleTip()}',
          '인테리어: ${_generateInterior()}',
          '습관 개선: ${_generateHabit()}',
          '시간 관리: ${_generateTimeManagement()}'
        ];
      default:
        return ['정보 없음'];
    }
  }

  String _generateRecommendation(String categoryId) {
    final recommendations = {
      'lotto': '오늘은 직감을 믿고 번호를 선택하세요. 평소보다 30% 높은 당첨 확률이 예상됩니다.',
      'shopping': '오전 시간대에 쇼핑하면 더 좋은 할인 혜택을 받을 수 있어요.',
      'game': '팀플레이보다는 개인전에서 더 좋은 성과를 낼 수 있는 날입니다.',
      'food': '새로운 요리에 도전해보세요. 예상치 못한 맛의 발견이 있을 거예요.',
      'travel': '가까운 곳보다는 조금 멀리 나가는 것이 더 큰 행운을 가져다줄 것 같아요.',
      'health': '평소보다 30분 일찍 잠자리에 들면 내일이 더욱 활기찰 거예요.',
      'fashion': '평소와 다른 스타일에 도전해보세요. 새로운 매력을 발견할 수 있어요.',
      'lifestyle': '작은 변화가 큰 행운을 가져다줄 수 있는 날입니다.'
    };
    return recommendations[categoryId] ?? '오늘은 새로운 시도를 해보세요.';
  }

  String _generateDailyTip() {
    final tips = [
      '오늘은 직감을 믿고 행동하는 것이 좋겠어요.',
      '새로운 사람과의 만남이 예상치 못한 기회를 가져다줄 수 있어요.',
      '평소보다 조금 일찍 일어나면 더 많은 행운을 만날 수 있어요.',
      '오늘 하루는 감사한 마음으로 보내보세요.',
      '작은 친절이 큰 행운으로 돌아올 수 있는 날입니다.'
    ];
    return tips[_random.nextInt(tips.length)];
  }

  // Helper methods for generating random content
  String _generateLottoNumbers() {
    List<int> numbers = [];
    while (numbers.length < 6) {
      int num = 1 + _random.nextInt(45);
      if (!numbers.contains(num)) {
        numbers.add(num);
      }
    }
    numbers.sort();
    return numbers.join(', ');
  }

  String _generateTime() {
    final hours = ['09:00-11:00', '14:00-16:00', '19:00-21:00'];
    return hours[_random.nextInt(hours.length)];
  }

  String _generateLocation() {
    final locations = ['편의점', '대형마트', '온라인', '동네 상점'];
    return locations[_random.nextInt(locations.length)];
  }

  String _generateLotteryType() {
    final types = ['로또6/45', '연금복권', '스크래치'];
    return types[_random.nextInt(types.length)];
  }

  String _generateShoppingItem() {
    final items = ['향수', '지갑', '신발', '가방', '액세서리'];
    return items[_random.nextInt(items.length)];
  }

  String _generateBrand() {
    final brands = ['명품 브랜드', '로컬 브랜드', '신생 브랜드', '빈티지 브랜드'];
    return brands[_random.nextInt(brands.length)];
  }

  String _generateDiscount() {
    return '${10 + _random.nextInt(30)}% 할인';
  }

  String _generateGame() {
    final games = ['보드게임', '카드게임', '스포츠게임', '퍼즐게임'];
    return games[_random.nextInt(games.length)];
  }

  String _generateGameLuck() {
    final luck = ['상승', '보통', '하강'];
    return luck[_random.nextInt(luck.length)];
  }

  String _generateTeamLuck() {
    final teamLuck = ['팀워크 상승', '개인플레이 유리', '균형 잡힌 플레이'];
    return teamLuck[_random.nextInt(teamLuck.length)];
  }

  String _generateFood() {
    final foods = ['한식', '중식', '일식', '양식', '분식'];
    return foods[_random.nextInt(foods.length)];
  }

  String _generateMealTime() {
    final times = ['아침 7-9시', '점심 12-2시', '저녁 6-8시'];
    return times[_random.nextInt(times.length)];
  }

  String _generateCookingMethod() {
    final methods = ['찜', '볶음', '구이', '튀김'];
    return methods[_random.nextInt(methods.length)];
  }

  String _generateFlavor() {
    final flavors = ['매콤한 맛', '달콤한 맛', '새콤한 맛', '담백한 맛'];
    return flavors[_random.nextInt(flavors.length)];
  }

  String _generateDirection() {
    final directions = ['동쪽', '서쪽', '남쪽', '북쪽', '동남쪽', '서남쪽'];
    return directions[_random.nextInt(directions.length)];
  }

  String _generateTravelPlace() {
    final places = ['카페', '공원', '박물관', '쇼핑몰', '영화관'];
    return places[_random.nextInt(places.length)];
  }

  String _generateTravelTime() {
    final times = ['오전', '오후', '저녁', '밤'];
    return times[_random.nextInt(times.length)];
  }

  String _generateTransport() {
    final transport = ['지하철', '버스', '택시', '도보', '자전거'];
    return transport[_random.nextInt(transport.length)];
  }

  String _generateHealthPoint() {
    final points = ['수면', '운동', '식단', '스트레스 관리'];
    return points[_random.nextInt(points.length)];
  }

  String _generateExercise() {
    final exercises = ['요가', '산책', '스트레칭', '수영', '사이클링'];
    return exercises[_random.nextInt(exercises.length)];
  }

  String _generateHealthWarning() {
    final warnings = ['과식 주의', '충분한 수면', '수분 섭취', '스트레스 관리'];
    return warnings[_random.nextInt(warnings.length)];
  }

  String _generateNutrient() {
    final nutrients = ['비타민 C', '오메가3', '칼슘', '철분', '마그네슘'];
    return nutrients[_random.nextInt(nutrients.length)];
  }

  String _generateColor() {
    final colors = ['파란색', '빨간색', '노란색', '초록색', '보라색', '분홍색'];
    return colors[_random.nextInt(colors.length)];
  }

  String _generateStyle() {
    final styles = ['캐주얼', '포멀', '스포티', '빈티지', '미니멀'];
    return styles[_random.nextInt(styles.length)];
  }

  String _generateAccessory() {
    final accessories = ['목걸이', '귀걸이', '팔찌', '반지', '시계'];
    return accessories[_random.nextInt(accessories.length)];
  }

  String _generateMaterial() {
    final materials = ['면', '실크', '울', '린넨', '폴리에스터'];
    return materials[_random.nextInt(materials.length)];
  }

  String _generateLifestyleTip() {
    final tips = ['정리정돈', '미니멀 라이프', '취미 활동', '독서', '명상'];
    return tips[_random.nextInt(tips.length)];
  }

  String _generateInterior() {
    final interior = ['식물 키우기', '향초', '조명 바꾸기', '쿠션 교체'];
    return interior[_random.nextInt(interior.length)];
  }

  String _generateHabit() {
    final habits = ['일찍 일어나기', '운동하기', '독서하기', '일기쓰기'];
    return habits[_random.nextInt(habits.length)];
  }

  String _generateTimeManagement() {
    final time = ['투두리스트 작성', '시간 블록', '우선순위 정하기', '휴식 시간 확보'];
    return time[_random.nextInt(time.length)];
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final userName = user.value?.name ?? '당신';

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('오늘의 행운 아이템'),
          backgroundColor: TossDesignSystem.white,
          foregroundColor: TossDesignSystem.black,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: TossDesignSystem.gray50,
      appBar: AppBar(
        title: const Text('오늘의 행운 아이템'),
        backgroundColor: TossDesignSystem.white,
        foregroundColor: TossDesignSystem.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // 공유 기능
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF667EEA),
                    Color(0xFF764BA2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: TossDesignSystem.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$userName님의',
                    style: TextStyle(
                      fontSize: 16,
                      color: TossDesignSystem.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '오늘의 행운 종합 점수',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: TossDesignSystem.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '${_generatedResults['overallScore']}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: TossDesignSystem.white,
                        ),
                      ),
                      Text(
                        '점',
                        style: TextStyle(
                          fontSize: 24,
                          color: TossDesignSystem.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '오늘의 최고 운: ${_generatedResults['bestCategory']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: TossDesignSystem.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

            const SizedBox(height: 20),

            // 오늘의 팁 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TossDesignSystem.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: TossDesignSystem.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF9C4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lightbulb,
                      color: Color(0xFFF57F17),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '오늘의 행운 팁',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF191F28),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _generatedResults['dailyTip'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4E5968),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),

            const SizedBox(height: 24),

            // 카테고리 섹션 제목
            const Text(
              '8가지 행운 카테고리',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191F28),
              ),
            ),
            const SizedBox(height: 16),

            // 카테고리 리스트
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _generatedResults['categories'].length,
              itemBuilder: (context, index) {
                final category = _generatedResults['categories'][index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildCategoryCard(category, index),
                ).animate().fadeIn(delay: (600 + index * 100).ms).slideX(begin: 0.3, end: 0);
              },
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, int index) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: category['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category['icon'],
                  color: category['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          category['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF191F28),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getScoreColor(category['score']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${category['score']}점',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getScoreColor(category['score']),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category['description'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8B95A1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 추천사항
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              category['recommendation'],
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4E5968),
                height: 1.4,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 상세 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              category['items'].length,
              (itemIndex) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: category['color'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category['items'][itemIndex],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4E5968),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 85) return const Color(0xFF4CAF50);
    if (score >= 70) return const Color(0xFF2196F3);
    if (score >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }
}