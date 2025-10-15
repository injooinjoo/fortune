import 'package:flutter/material.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../presentation/providers/auth_provider.dart';
import 'dart:math';

class LuckyItemsUnifiedPage extends BaseFortunePage {
  const LuckyItemsUnifiedPage({
    Key? key}) : super(
          key: key,
          title: '오늘의 행운 가이드',
          description: '로또부터 라이프스타일까지, 실용적인 행운 정보를 확인하세요',
          fortuneType: 'lucky_guide',
          requiresUserInfo: true
        );

  @override
  ConsumerState<LuckyItemsUnifiedPage> createState() => _LuckyItemsUnifiedPageState();
}

class _LuckyItemsUnifiedPageState extends BaseFortunePageState<LuckyItemsUnifiedPage> {
  Fortune? _fortuneResult;
  int _selectedCategoryIndex = 0;
  
  // 8개 메인 카테고리 정의 (투자/학습 제거)
  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'lotto',
      'title': '로또/복권',
      'icon': '🎰',
      'description': '행운의 번호와 구매 장소',
      'color': const Color(0xFFFF6B6B),
      'subItems': ['추천번호', '구매장소', '구매시간', '복권종류']
    },
    {
      'id': 'shopping',
      'title': '쇼핑/구매',
      'icon': '🛍️',
      'description': '쇼핑 운과 구매 타이밍',
      'color': const Color(0xFFAB47BC),
      'subItems': ['행운아이템', '쇼핑장소', '온라인딜', '브랜드추천']
    },
    {
      'id': 'game',
      'title': '게임/엔터테인먼트',
      'icon': '🎮',
      'description': '게임과 엔터테인먼트 가이드',
      'color': const Color(0xFF45B7D1),
      'subItems': ['게임추천', '영화드라마', '음악', '취미활동']
    },
    {
      'id': 'food',
      'title': '음식/맛집',
      'icon': '🍜',
      'description': '행운의 음식과 맛집',
      'color': const Color(0xFF66BB6A),
      'subItems': ['행운음식', '맛집추천', '카페', '배달음식']
    },
    {
      'id': 'travel',
      'title': '여행/장소',
      'icon': '✈️',
      'description': '행운의 장소와 여행지',
      'color': const Color(0xFF4ECDC4),
      'subItems': ['데이트장소', '드라이브코스', '산책장소', '핫플레이스']
    },
    {
      'id': 'health',
      'title': '운동/건강',
      'icon': '💪',
      'description': '건강 운과 운동 가이드',
      'color': const Color(0xFF42A5F5),
      'subItems': ['운동종류', '운동시간', '헬스장요가', '건강관리']
    },
    {
      'id': 'fashion',
      'title': '패션/뷰티',
      'icon': '👗',
      'description': '오늘의 스타일링',
      'color': const Color(0xFFEC407A),
      'subItems': ['럭키컬러', '스타일링', '액세서리', '뷰티']
    },
    {
      'id': 'lifestyle',
      'title': '라이프스타일',
      'icon': '🌟',
      'description': '일상 속 행운 가이드',
      'color': const Color(0xFF26A69A),
      'subItems': ['취미활동', '만남', 'SNS', '일상팁']
    },
  ];

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    // 사용자 프로필 정보 가져오기
    final userProfile = await ref.read(userProfileProvider.future);
    if (userProfile == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    // 행운 가이드 데이터 생성
    final luckyGuide = await _generateLuckyGuide(userProfile, DateTime.now());
    
    setState(() {
      _fortuneResult = luckyGuide;
    });
    
    return luckyGuide;
  }
  
  /// 실용적인 행운 가이드 데이터 생성
  Future<Fortune> _generateLuckyGuide(dynamic userProfile, DateTime date) async {
    final birthDay = userProfile.birthDate?.day ?? 1;
    final seedValue = date.day + date.month + (birthDay is int ? birthDay : birthDay.toInt());
    final random = Random(seedValue.toInt());
    
    // 오늘의 운세에서 실제 점수 가져오기
    int actualScore = 75; // 기본값
    try {
      final dailyFortuneState = ref.read(dailyFortuneProvider);
      if (dailyFortuneState.fortune != null) {
        actualScore = dailyFortuneState.fortune!.overallScore ?? 75;
      }
    } catch (e) {
      // 에러 시 기본값 사용
      print('Error getting daily fortune score: $e');
    }
    
    // 로또 번호 생성
    final lottoNumbers = _generateLottoNumbers(userProfile, date, random);
    
    // 각 카테고리별 데이터 생성
    final categoryData = <String, Map<String, dynamic>>{};
    
    for (final category in _categories) {
      categoryData[category['id']] = _generateCategoryData(category, userProfile, date, random);
    }
    
    // 오늘의 TOP 5 추천 생성
    final topRecommendations = _generateTopRecommendations(categoryData, random);
    
    // 현재 날짜 정보 생성
    final now = DateTime.now();
    final dateString = '${now.year}년 ${now.month}월 ${now.day}일';
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[now.weekday % 7];
    
    final description = '''오늘은 $dateString ($weekday요일) 입니다.

🌟 오늘의 행운 가이드

${topRecommendations.join('\n')}

각 카테고리를 선택하여 더 자세한 정보를 확인하세요!''';
    
    return Fortune(
      id: 'lucky_guide_${date.millisecondsSinceEpoch}',
      userId: userProfile.id,
      type: 'lucky_guide',
      content: description,
      createdAt: date,
      category: 'lucky-guide',
      overallScore: actualScore,
      scoreBreakdown: {
        '종합 운세': actualScore,
        '로또 운': (actualScore * 0.9 + random.nextInt(10)).round(),
        '투자 운': (actualScore * 0.85 + random.nextInt(15)).round(),
        '만남 운': (actualScore * 1.1 - random.nextInt(5)).round().clamp(0, 100),
      },
      description: description,
      luckyItems: {
        'lotto_numbers': lottoNumbers,
        'categories': categoryData,
        'top_recommendations': topRecommendations,
      },
      recommendations: [
        '중요한 결정은 오후 2-4시 사이에 내리세요',
        '새로운 사람과의 만남을 적극적으로 시도하세요',
        '직감을 믿고 행동하는 것이 좋겠습니다',
        '작은 투자나 도전을 해보는 것을 추천합니다',
      ],
      metadata: {
        'generated_date': date.toIso8601String(),
        'user_birth_date': userProfile.birthDate?.toIso8601String(),
        'categories': _categories.length,
      },
    );
  }
  
  /// 로또 번호 생성 (생년월일 + 오늘 날짜 기반)
  List<int> _generateLottoNumbers(dynamic userProfile, DateTime date, Random random) {
    final birthDate = userProfile.birthDate ?? DateTime.now();
    
    // 개인 행운수 계산
    final personalLucky = (birthDate.day + birthDate.month + birthDate.year % 100) % 45 + 1;
    
    // 오늘의 에너지
    final dailyLucky = (date.day + date.month + date.weekday) % 45 + 1;
    
    // MBTI 기반 라켤 번호
    int mbtiLucky = 7; // 기본값
    if (userProfile.mbtiType != null) {
      final mbtiHash = userProfile.mbtiType.hashCode;
      mbtiLucky = (mbtiHash.abs() % 45) + 1;
    }
    
    // 혈액형 기반 에너지
    int bloodLucky = 21;
    if (userProfile.bloodType != null) {
      switch (userProfile.bloodType) {
        case 'A': bloodLucky = 3; break;
        case 'B': bloodLucky = 12; break;
        case 'AB': bloodLucky = 27; break;
        case 'O': bloodLucky = 33; break;
      }
    }
    
    Set<int> numbers = {personalLucky, dailyLucky, mbtiLucky};
    
    // 6개 번호가 될 때까지 추가
    while (numbers.length < 6) {
      final newNumber = random.nextInt(45) + 1;
      if (!numbers.contains(newNumber)) {
        numbers.add(newNumber);
      }
    }
    
    final result = numbers.toList()..sort();
    return result;
  }
  
  /// 카테고리별 데이터 생성 (8개 카테고리)
  Map<String, dynamic> _generateCategoryData(Map<String, dynamic> category, dynamic userProfile, DateTime date, Random random) {
    switch (category['id']) {
      case 'lotto':
        return _generateLottoData(userProfile, date, random);
      case 'shopping':
        return _generateShoppingData(userProfile, date, random);
      case 'game':
        return _generateGameData(userProfile, date, random);
      case 'food':
        return _generateFoodData(userProfile, date, random);
      case 'travel':
        return _generateTravelData(userProfile, date, random);
      case 'health':
        return _generateHealthData(userProfile, date, random);
      case 'fashion':
        return _generateFashionData(userProfile, date, random);
      case 'lifestyle':
        return _generateLifestyleData(userProfile, date, random);
      default:
        return {};
    }
  }
  
  /// TOP 5 추천 생성 (8개 카테고리)
  List<String> _generateTopRecommendations(Map<String, Map<String, dynamic>> categoryData, Random random) {
    return [
      '🎰 로또 번호: ${(categoryData['lotto']?['numbers'] as List<int>?)?.take(5).join(', ') ?? '7, 14, 21, 28, 35'}',
      '🛍️ 행운 쇼핑: ${categoryData['shopping']?['lucky_item'] ?? '블루 톤 액세서리'}',
      '🎮 추천 콘텐츠: ${categoryData['game']?['content'] ?? '여행 다큐멘터리'}',
      '🍜 행운 메뉴: ${categoryData['food']?['lucky_food'] ?? '매콤한 국물 요리'}',
      '✈️ 추천 장소: ${categoryData['travel']?['spot'] ?? '한강공원 산책로'}',
    ];
  }

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        // 카테고리 탭
        if (_fortuneResult != null)
          _buildCategoryTabs(),
        
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                _buildHeaderCard()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.1, end: 0),
                const SizedBox(height: 24),
                
                if (_fortuneResult == null) ...[
                  // Generate Button
                  _buildGenerateButton()
                ] else ...[
                  // 선택된 카테고리 컨텐츠
                  _buildCategoryContent(),
                  const SizedBox(height: 24),
                  
                  // Refresh Button
                  _buildRefreshButton(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// 카테고리 탭 빌드
  Widget _buildCategoryTabs() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategoryIndex == index;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected 
                    ? category['color'].withValues(alpha: 0.2) 
                    : TossDesignSystem.gray100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected 
                      ? category['color'] 
                      : const Color(0xFFE5E5E5),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category['icon'],
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category['title'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected 
                          ? FontWeight.w600 
                          : FontWeight.w400,
                      color: isSelected 
                          ? category['color'] 
                          : const Color(0xFF666666),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  /// 선택된 카테고리 컨텐츠 빌드
  Widget _buildCategoryContent() {
    if (_fortuneResult?.luckyItems?['categories'] == null) {
      return const SizedBox.shrink();
    }
    
    final selectedCategory = _categories[_selectedCategoryIndex];
    final categoryId = selectedCategory['id'];
    final categoryData = _fortuneResult!.luckyItems!['categories'][categoryId] as Map<String, dynamic>?;
    
    if (categoryData == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 카테고리 헤더
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: selectedCategory['color'].withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selectedCategory['color'].withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Text(
                selectedCategory['icon'],
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedCategory['title'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: selectedCategory['color'],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedCategory['description'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // 카테고리별 상세 데이터
        _buildCategoryDetail(categoryId, categoryData, selectedCategory),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F4EF5),
            Color(0xFF8B5CF6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F4EF5).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 48,
            color: TossDesignSystem.gray100,
          ),
          const SizedBox(height: 12),
          const Text(
            '오늘의 행운 가이드',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: TossDesignSystem.gray100,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '로또부터 투자까지, 실용적인 행운 정보를 얻어보세요',
            style: TextStyle(
              fontSize: 14,
              color: TossDesignSystem.gray100.withValues(alpha: 0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          // 결과가 있을 때 TOP 5 미리보기
          if (_fortuneResult != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TossDesignSystem.gray100.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '👇 아래 카테고리를 선택하여 상세 정보를 확인하세요',
                style: TextStyle(
                  fontSize: 12,
                  color: TossDesignSystem.gray100,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return TossButton(
      text: '행운 가이드 확인하기',
      onPressed: _onGenerateFortune,
      style: TossButtonStyle.primary,
      size: TossButtonSize.large,
    );
  }

  Widget _buildLuckyItemsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildLuckyItemCard(
                title: '행운의 색깔',
                icon: Icons.palette_rounded,
                value: _fortuneResult?.luckyColor ?? '',
                gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                delay: 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLuckyItemCard(
                title: '행운의 숫자',
                icon: Icons.looks_one_rounded,
                value: _fortuneResult?.luckyNumber?.toString() ?? '',
                gradientColors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                delay: 100,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildLuckyItemCard(
                title: '행운의 음식',
                icon: Icons.restaurant_rounded,
                value: _fortuneResult?.luckyItems?['food'] as String? ?? '',
                gradientColors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                delay: 200,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLuckyItemCard(
                title: '행운의 아이템',
                icon: Icons.diamond_rounded,
                value: _fortuneResult?.luckyItems?['item'] as String? ?? '',
                gradientColors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                delay: 300,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLuckyItemCard({
    required String title,
    required IconData icon,
    required String value,
    required List<Color> gradientColors,
    required int delay}) {
    // Special handling for color
    Widget valueWidget;
    if (title == '행운의 색깔' && value.isNotEmpty) {
      // Try to parse color name to actual color
      Color? displayColor = _getColorFromName(value);
      if (displayColor != null) {
        valueWidget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: displayColor,
                shape: BoxShape.circle,
                border: Border.all(color: TossDesignSystem.gray100, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: displayColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TossDesignSystem.gray100,
              ),
            ),
          ],
        );
      } else {
        valueWidget = Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: TossDesignSystem.gray100,
          ),
        );
      }
    } else {
      valueWidget = Text(
        value,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: TossDesignSystem.gray100),
        textAlign: TextAlign.center
      );
    }

    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: TossDesignSystem.gray100.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: TossDesignSystem.gray100.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(child: valueWidget),
        ],
      ),
    ).animate(delay: delay.ms)
      .fadeIn(duration: 500.ms)
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }

  Widget _buildOverallMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Color(0xFF7C3AED),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '종합 운세',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _fortuneResult!.message,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppTheme.textColor,
            ),
          ),
          if (_fortuneResult!.advice != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF7C3AED).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: Color(0xFF7C3AED),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _fortuneResult!.advice!,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms, delay: 400.ms)
      .slideY(begin: 0.1, end: 0);
  }

  Widget _buildRefreshButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _onGenerateFortune,
        icon: const Icon(Icons.refresh),
        label: const Text('다시 보기'),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF1F4EF5),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  void _onGenerateFortune() {
    final profile = userProfile;
    if (profile != null) {
      setState(() {
        _fortuneResult = null;
        _selectedCategoryIndex = 0; // 리셋
      });
      final params = {
        'userId': profile.id,
        'name': profile.name,
        'birthDate': profile.birthDate?.toIso8601String(),
        'gender': profile.gender,
      };
      generateFortuneAction(params: params);
    }
  }

  /// 카테고리별 상세 데이터 빌드
  Widget _buildCategoryDetail(String categoryId, Map<String, dynamic> data, Map<String, dynamic> category) {
    switch (categoryId) {
      case 'lotto':
        return _buildLottoDetail(data, category);
      case 'location':
        return _buildLocationDetail(data, category);
      case 'game':
        return _buildGameDetail(data, category);
      case 'finance':
        return _buildFinanceDetail(data, category);
      case 'food':
        return _buildFoodDetail(data, category);
      case 'transport':
        return _buildTransportDetail(data, category);
      case 'meeting':
        return _buildMeetingDetail(data, category);
      case 'shopping':
        return _buildShoppingDetail(data, category);
      case 'work':
        return _buildWorkDetail(data, category);
      case 'health':
        return _buildHealthDetail(data, category);
      default:
        return const SizedBox.shrink();
    }
  }
  
  /// 로또 데이터 생성
  Map<String, dynamic> _generateLottoData(dynamic userProfile, DateTime date, Random random) {
    final numbers = _generateLottoNumbers(userProfile, date, random);
    final stores = ['백수 민럽점', 'GS25 강남대로점', '세븐일레븐 역삼점', '로또리아 선릉점'];
    final times = ['오전 10:00-11:00', '오후 2:00-3:00', '오후 6:00-7:00', '오후 8:00-9:00'];
    
    return {
      'numbers': numbers,
      'store': stores[random.nextInt(stores.length)],
      'time': times[random.nextInt(times.length)],
      'confidence': 70 + random.nextInt(25),
      'tip': '개인 행운수 ${numbers.first}번이 특히 강한 날입니다',
    };
  }
  
  /// 장소 데이터 생성
  Map<String, dynamic> _generateLocationData(dynamic userProfile, DateTime date, Random random) {
    final powerSpots = ['강남역 주변', '경복궁 근처', '남산타워 주변', '여의도 한강공원'];
    final cafes = ['스타벅스 강남역점', '블루보틀 성수', '엔트러사이트 한남', '테라로사 광화문'];
    final restaurants = ['일식당 (초밥,라면)', '한식당 (국밥,찌개)', '양식당 (파스타,스테이크)', '중식당 (지지장,탕수육)'];
    
    return {
      'power_spot': powerSpots[random.nextInt(powerSpots.length)],
      'cafe': cafes[random.nextInt(cafes.length)],
      'restaurant': restaurants[random.nextInt(restaurants.length)],
      'direction': ['동쪽', '서쪽', '남쪽', '북쪽'][random.nextInt(4)],
      'tip': '오늘은 물가 있는 곳에서 더 좋은 기운이 느껴질 것입니다',
    };
  }
  
  /// 게임 데이터 생성
  Map<String, dynamic> _generateGameData(dynamic userProfile, DateTime date, Random random) {
    final onlineGames = ['리그오브레전드', '배틀그라운드', '오버워치', '에이팩스'];
    final mobileGames = ['원신', '쿠키런', '마블피컬공백전', '내여신에게 물어봐'];
    final strategies = ['공격적 전략', '수비적 전략', '밸런스 전략', '서포터 역할'];
    
    return {
      'online_game': onlineGames[random.nextInt(onlineGames.length)],
      'mobile_game': mobileGames[random.nextInt(mobileGames.length)],
      'strategy': strategies[random.nextInt(strategies.length)],
      'lucky_time': '${19 + random.nextInt(4)}:00-${21 + random.nextInt(2)}:00',
      'tip': '팀플레이보다는 솔로 플레이가 오늘 더 좋습니다',
    };
  }
  
  /// 금융 데이터 생성
  Map<String, dynamic> _generateFinanceData(dynamic userProfile, DateTime date, Random random) {
    final sectors = ['IT/반도체', '바이오', '엔터테인먼트', '차량/전기차', '금융'];
    final strategies = ['단기 매매', '장기 투자', '분할 매수', '지수 투자'];
    final timings = ['오전 9:30-10:00', '오후 2:30-3:00', '오후 3:00-3:20'];
    
    return {
      'sector': sectors[random.nextInt(sectors.length)],
      'strategy': strategies[random.nextInt(strategies.length)],
      'timing': timings[random.nextInt(timings.length)],
      'risk_level': random.nextInt(5) + 1,
      'tip': '오늘은 안정적인 종목보다는 성장주가 좋습니다',
    };
  }
  
  /// 음식 데이터 생성
  Map<String, dynamic> _generateFoodData(dynamic userProfile, DateTime date, Random random) {
    final restaurantTypes = ['일식 (초밥,라면)', '한식 (국밥,찌개)', '양식 (파스타,스테이크)', '중식 (지지장,탕수육)'];
    final drinks = ['소주 3병', '맥주 500cc x 4잔', '와인 (레드)', '위스키 드림'];
    final cafeMenus = ['아메리카노', '카페라떼', '디카페인', '거품만 스마트워터'];
    
    return {
      'restaurant_type': restaurantTypes[random.nextInt(restaurantTypes.length)],
      'drink': drinks[random.nextInt(drinks.length)],
      'cafe_menu': cafeMenus[random.nextInt(cafeMenus.length)],
      'discount_chance': 45 + random.nextInt(40),
      'tip': '오늘은 신메뉴보다 정통 메뉴가 더 맛있습니다',
    };
  }
  
  /// 교통 데이터 생성
  Map<String, dynamic> _generateTransportData(dynamic userProfile, DateTime date, Random random) {
    final taxiApps = ['카카오T', '땅시', '로댔엑', '우버'];
    final parkingTips = ['지상 동쪽 구역', '지하 B2층', '길거리 편의점 앞', '백화점 지하'];
    final directions = ['제주/부산', '동남아', '일본', '유럽'];
    
    return {
      'taxi_app': taxiApps[random.nextInt(taxiApps.length)],
      'taxi_chance': 75 + random.nextInt(20),
      'parking_tip': parkingTips[random.nextInt(parkingTips.length)],
      'travel_direction': directions[random.nextInt(directions.length)],
      'tip': '대중교통보다는 개인 차량이 오늘 좋습니다',
    };
  }
  
  /// 만남 데이터 생성
  Map<String, dynamic> _generateMeetingData(dynamic userProfile, DateTime date, Random random) {
    final mbtiTypes = ['ENTJ', 'ENTP', 'INTJ', 'INTP', 'ENFJ', 'ENFP'];
    final bloodTypes = ['A', 'B', 'AB', 'O'];
    final industries = ['IT', '금융', '미디어', '학술', '비즈니스'];
    
    return {
      'good_mbti': mbtiTypes[random.nextInt(mbtiTypes.length)],
      'good_blood': bloodTypes[random.nextInt(bloodTypes.length)],
      'industry': industries[random.nextInt(industries.length)],
      'meeting_time': '${19 + random.nextInt(3)}:00-${21 + random.nextInt(2)}:00',
      'match_chance': 65 + random.nextInt(25),
      'tip': '오늘은 실내에서의 만남이 실외보다 좋습니다',
    };
  }
  
  /// 쇼핑 데이터 생성
  Map<String, dynamic> _generateShoppingData(dynamic userProfile, DateTime date, Random random) {
    final items = ['전자제품 (이어폰, 케이스)', '의류 (청바지, 운동화)', '도서 (자기계발, 에세이)', '미용 (스킨케어, 화장품)'];
    final platforms = ['11번가', '쿠팡', '올리브', '당근마켓'];
    final timings = ['09:00', '15:00', '23:00'];
    
    return {
      'recommended_item': items[random.nextInt(items.length)],
      'platform': platforms[random.nextInt(platforms.length)],
      'best_time': timings[random.nextInt(timings.length)],
      'discount_chance': 35 + random.nextInt(40),
      'tip': '오늘은 중고거래에서의 발견이 좋습니다',
    };
  }
  
  /// 업무 데이터 생성
  Map<String, dynamic> _generateWorkData(dynamic userProfile, DateTime date, Random random) {
    final focusTimes = ['09:00-11:00', '14:00-16:00', '10:00-12:00'];
    final tasks = ['기획서 작성', '프레젠테이션', '브레인스토밍', '데이터 분석'];
    final meetings = ['새로운 프로젝트', '팀 회의', '고객 상담', '성과 발표'];
    
    return {
      'focus_time': focusTimes[random.nextInt(focusTimes.length)],
      'best_task': tasks[random.nextInt(tasks.length)],
      'meeting_type': meetings[random.nextInt(meetings.length)],
      'productivity': 75 + random.nextInt(20),
      'tip': '오늘은 새로운 아이디어가 떠오르기 좋은 날입니다',
    };
  }
  
  /// 건강 데이터 생성
  Map<String, dynamic> _generateHealthData(dynamic userProfile, DateTime date, Random random) {
    final exercises = ['러닝 (5km)', '웨이트 트레이닝', '요가/필라테스', '수영', '자전거'];
    final timings = ['06:00-08:00', '18:00-20:00', '19:00-21:00'];
    final supplements = ['비타민D', '오메가3', '유산균', '마그네슘'];
    
    return {
      'exercise': exercises[random.nextInt(exercises.length)],
      'best_time': timings[random.nextInt(timings.length)],
      'supplement': supplements[random.nextInt(supplements.length)],
      'condition': 80 + random.nextInt(15),
      'steps_goal': 6000 + random.nextInt(6000),
      'tip': '오늘은 상체 운동보다 하체 운동이 더 효과적입니다',
    };
  }
  
  /// 로또 상세 카드
  Widget _buildLottoDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    final numbers = data['numbers'] as List<int>;
    
    return Column(
      children: [
        // 로또 번호 카드
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TossDesignSystem.gray100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0F0F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.confirmation_number, color: Color(0xFFFF6B6B)),
                  const SizedBox(width: 8),
                  Text(
                    '추천 번호',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: category['color'],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: numbers.map((number) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1F4EF5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        number.toString(),
                        style: const TextStyle(
                          color: TossDesignSystem.gray100,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Color(0xFF666666)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data['tip'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // 구매 정보 카드
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TossDesignSystem.gray100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF0F0F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('추천 매장', style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
                    Text(data['store'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('추천 시간', style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
                    Text(data['time'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// 기본 카드 형태 (다른 카테고리에서 공통 사용)
  Widget _buildBasicCard(String title, Map<String, dynamic> data, Map<String, dynamic> category) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TossDesignSystem.gray100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: category['color'],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: category['color'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...data.entries.map((entry) {
            if (entry.key == 'tip') {
              return Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFF666666)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      _formatFieldName(entry.key),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF191F28),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  String _formatFieldName(String key) {
    final nameMap = {
      'store': '매장',
      'time': '시간',
      'confidence': '신뢰도',
      'power_spot': '파워스팟',
      'cafe': '카페',
      'restaurant': '맛집',
      'direction': '방향',
      'online_game': '온라인',
      'mobile_game': '모바일',
      'strategy': '전략',
      'lucky_time': '행운타임',
      'sector': '섹터',
      'timing': '타이밍',
      'risk_level': '리스크',
      'restaurant_type': '음식종류',
      'drink': '술',
      'cafe_menu': '카페메뉴',
      'discount_chance': '할인확률',
      'taxi_app': '택시앱',
      'taxi_chance': '택시확률',
      'parking_tip': '주차팁',
      'travel_direction': '여행방향',
      'good_mbti': '좋은MBTI',
      'good_blood': '좋은혈액형',
      'industry': '업종',
      'meeting_time': '만남시간',
      'match_chance': '매칭확률',
      'recommended_item': '추천상품',
      'platform': '플랫폼',
      'best_time': '최적시간',
      'focus_time': '집중시간',
      'best_task': '추천업무',
      'meeting_type': '미팅종류',
      'productivity': '생산성',
      'exercise': '운동',
      'supplement': '보충제',
      'condition': '컨디션',
      'steps_goal': '방무목표',
    };
    return nameMap[key] ?? key;
  }
  
  // 나머지 카테고리별 상세 빌드 메서드들
  Widget _buildLocationDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    return _buildBasicCard('장소 가이드', data, category);
  }
  
  Widget _buildGameDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    return _buildBasicCard('게임 가이드', data, category);
  }
  
  Widget _buildFinanceDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    return _buildBasicCard('투자 가이드', data, category);
  }
  
  Widget _buildFoodDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    return _buildBasicCard('음식 가이드', data, category);
  }
  
  Widget _buildTransportDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    return _buildBasicCard('교통 가이드', data, category);
  }
  
  Widget _buildMeetingDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    return _buildBasicCard('만남 가이드', data, category);
  }
  
  Widget _buildShoppingDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    return _buildBasicCard('쇼핑 가이드', data, category);
  }
  
  Widget _buildWorkDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    return _buildBasicCard('업무 가이드', data, category);
  }
  
  Widget _buildHealthDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    return _buildBasicCard('건강 가이드', data, category);
  }
  
  /// 색상 이름을 Color 객체로 변환
  Color? _getColorFromName(String colorName) {
    final colorMap = {
      '빨강': TossDesignSystem.errorRed,
      '파랑': TossDesignSystem.tossBlue,
      '노랑': TossDesignSystem.warningOrange,
      '초록': TossDesignSystem.successGreen,
      '보라': const Color(0xFF9C27B0),
      '핑크': const Color(0xFFE91E63),
      '주황': const Color(0xFFFF9800),
      '검정': TossDesignSystem.gray900,
      '흰색': TossDesignSystem.gray100,
      '회색': TossDesignSystem.gray600,
      '청색': const Color(0xFF3F51B5),
      '하늘색': const Color(0xFF03A9F4),
      '연두': const Color(0xFF8BC34A),
      '갈색': const Color(0xFF795548),
      '금색': const Color(0xFFFFC107),
      '은색': const Color(0xFFE0E0E0),
    };
    
    return colorMap[colorName];
  }
  
  /// 여행/장소 데이터 생성
  Map<String, dynamic> _generateTravelData(dynamic userProfile, DateTime date, Random random) {
    final dateSpots = ['한강공원 산책로', '남산타워 전망대', '경복궁 후원', '이태원 로시길'];
    final driveCourses = ['강변북로 드라이브', '올림픽대로 야간코스', '자유로 일몰드라이브', '동해안 해안도로'];
    final walkSpots = ['청계천 산책', '뚝섬유원지', '반포한강공원', '여의도공원'];
    final hotPlaces = ['성수동 카페거리', '홍대 놀거리', '강남 가로수길', '이태원 맛집거리'];
    
    return {
      'spot': dateSpots[random.nextInt(dateSpots.length)],
      'drive_course': driveCourses[random.nextInt(driveCourses.length)],
      'walk_spot': walkSpots[random.nextInt(walkSpots.length)],
      'hot_place': hotPlaces[random.nextInt(hotPlaces.length)],
      'best_time': '${14 + random.nextInt(4)}:00-${17 + random.nextInt(3)}:00',
      'tip': '오늘은 자연과 가까운 곳에서 더 좋은 에너지를 받을 수 있습니다',
    };
  }
  
  /// 패션/뷰티 데이터 생성
  Map<String, dynamic> _generateFashionData(dynamic userProfile, DateTime date, Random random) {
    final luckyColors = ['블루', '화이트', '네이비', '베이지', '그레이', '핑크', '그린'];
    final stylings = ['캐주얼 스타일', '비즈니스 캐주얼', '페미닌 스타일', '스트릿 패션'];
    final accessories = ['실버 액세서리', '골드 체인', '가죽 벨트', '스카프', '모자'];
    final beauty = ['자연스러운 메이크업', '포인트 립스틱', '아이라이너 강조', '글로우 베이스'];
    
    return {
      'lucky_color': luckyColors[random.nextInt(luckyColors.length)],
      'styling': stylings[random.nextInt(stylings.length)],
      'accessory': accessories[random.nextInt(accessories.length)],
      'beauty': beauty[random.nextInt(beauty.length)],
      'confidence': 85 + random.nextInt(10),
      'tip': '오늘은 밝은 톤의 색상이 운기를 상승시켜 줄 것입니다',
    };
  }
  
  /// 라이프스타일 데이터 생성
  Map<String, dynamic> _generateLifestyleData(dynamic userProfile, DateTime date, Random random) {
    final hobbies = ['독서', '요리', '그림그리기', '음악감상', '사진촬영', '원예'];
    final meetings = ['새로운 사람', '오랜 친구', '직장 동료', '가족'];
    final sns = ['인스타그램 포스팅', '페이스북 업데이트', '유튜브 시청', '블로그 작성'];
    final tips = ['새로운 루틴 시작', '정리 정돈', '감사 인사', '운동 습관'];
    
    return {
      'hobby': hobbies[random.nextInt(hobbies.length)],
      'meeting': meetings[random.nextInt(meetings.length)],
      'sns': sns[random.nextInt(sns.length)],
      'tip': tips[random.nextInt(tips.length)],
      'best_time': '${19 + random.nextInt(3)}:00-${21 + random.nextInt(2)}:00',
      'energy': 75 + random.nextInt(20),
    };
  }
}