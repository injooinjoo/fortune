import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/components/toss_card.dart';
import '../widgets/standard_fortune_app_bar.dart';

class LuckyItemsResultsPage extends ConsumerStatefulWidget {
  const LuckyItemsResultsPage({super.key});

  @override
  ConsumerState<LuckyItemsResultsPage> createState() => _LuckyItemsResultsPageState();
}

class _LuckyItemsResultsPageState extends ConsumerState<LuckyItemsResultsPage> {
  Map<String, dynamic>? inputData;
  Map<String, dynamic> results = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // GoRouter extra에서 데이터 받기
    final extra = GoRouterState.of(context).extra;
    if (extra != null && extra is Map<String, dynamic>) {
      inputData = extra;
      _generateResults();
    }
  }

  void _generateResults() {
    if (inputData == null) return;

    final birthDate = inputData!['birthDate'] as DateTime?;
    final birthTime = inputData!['birthTime'] as TimeOfDay?;
    final gender = inputData!['gender'] as String?;
    final interests = inputData!['interests'] as List<String>?;

    // 오행 계산 (간단한 버전)
    final element = _calculateElement(birthDate);

    results = {
      'keyword': _generateKeyword(element, interests),
      'color': _generateColor(element),
      'fashion': _generateFashion(element, gender),
      'numbers': _generateNumbers(birthDate, birthTime),
      'food': _generateFood(element, interests),
      'jewelry': _generateJewelry(element),
      'material': _generateMaterial(element),
      'direction': _generateDirection(birthDate),
      'places': _generatePlaces(element, interests),
      'relationships': _generateRelationships(element, interests),
    };

    setState(() {});
  }

  String _calculateElement(DateTime? birthDate) {
    if (birthDate == null) return '금';

    // 간단한 오행 계산 (생년 끝자리 기준)
    final year = birthDate.year;
    final lastDigit = year % 10;

    switch (lastDigit) {
      case 0:
      case 1:
        return '금'; // 금(金)
      case 2:
      case 3:
        return '수'; // 수(水)
      case 4:
      case 5:
        return '목'; // 목(木)
      case 6:
      case 7:
        return '화'; // 화(火)
      case 8:
      case 9:
        return '토'; // 토(土)
      default:
        return '금';
    }
  }

  String _generateKeyword(String element, List<String>? interests) {
    final elementKeywords = {
      '금': '집중력, 결단력, 완성',
      '수': '유연성, 창의력, 소통',
      '목': '성장, 발전, 도전',
      '화': '열정, 에너지, 승리',
      '토': '안정, 신뢰, 축적',
    };

    return elementKeywords[element] ?? '행운, 기회, 성공';
  }

  String _generateColor(String element) {
    final elementColors = {
      '금': '흰색, 회색, 은색',
      '수': '검정색, 파란색, 남색',
      '목': '초록색, 청록색, 연두색',
      '화': '빨간색, 주황색, 분홍색',
      '토': '노란색, 갈색, 베이지색',
    };

    return elementColors[element] ?? '흰색, 파란색';
  }

  List<String> _generateFashion(String element, String? gender) {
    final elementFashion = {
      '금': ['메탈 액세서리', '화이트 셔츠', '실버 시계'],
      '수': ['플로우 원피스', '데님 재킷', '블루 스니커즈'],
      '목': ['그린 가디건', '내츄럴 소재 가방', '우드 액세서리'],
      '화': ['레드 립스틱', '핑크 블라우스', '화려한 스카프'],
      '토': ['베이지 코트', '브라운 가방', '골드 액세서리'],
    };

    return elementFashion[element] ?? ['편안한 옷', '심플한 액세서리'];
  }

  List<int> _generateNumbers(DateTime? birthDate, TimeOfDay? birthTime) {
    if (birthDate == null) return [3, 7, 21];

    final day = birthDate.day;
    final month = birthDate.month;
    final hour = birthTime?.hour ?? 12;

    return [day, month, hour, (day + month) % 45 + 1].take(4).toList();
  }

  List<String> _generateFood(String element, List<String>? interests) {
    final elementFood = {
      '금': ['닭고기', '무', '배', '견과류'],
      '수': ['해산물', '콩', '블루베리', '해조류'],
      '목': ['녹색 채소', '새싹', '녹차', '샐러드'],
      '화': ['토마토', '고추', '딸기', '양념 치킨'],
      '토': ['고구마', '감자', '호박', '바나나'],
    };

    return elementFood[element] ?? ['균형잡힌 식사'];
  }

  String _generateJewelry(String element) {
    final elementJewelry = {
      '금': '다이아몬드, 진주, 백수정',
      '수': '아쿠아마린, 사파이어, 흑수정',
      '목': '에메랄드, 비취, 말라카이트',
      '화': '루비, 가넷, 홍수정',
      '토': '호박, 황수정, 토파즈',
    };

    return elementJewelry[element] ?? '수정';
  }

  String _generateMaterial(String element) {
    final elementMaterial = {
      '금': '금속, 실크, 가죽',
      '수': '면, 플로우 소재, 저지',
      '목': '리넨, 대나무, 라탄',
      '화': '울, 벨벳, 퍼',
      '토': '코튼, 캔버스, 스웨이드',
    };

    return elementMaterial[element] ?? '자연 소재';
  }

  String _generateDirection(DateTime? birthDate) {
    if (birthDate == null) return '동쪽';

    final directions = ['동쪽', '서쪽', '남쪽', '북쪽'];
    return directions[birthDate.day % 4];
  }

  List<String> _generatePlaces(String element, List<String>? interests) {
    final elementPlaces = {
      '금': ['고층 빌딩', '금융가', '박물관', '명품 매장'],
      '수': ['강가', '바닷가', '분수대', '수족관'],
      '목': ['공원', '숲', '식물원', '농장'],
      '화': ['야외 축제', '공연장', '스포츠 경기장', '놀이동산'],
      '토': ['카페', '도서관', '전통 시장', '고궁'],
    };

    return elementPlaces[element] ?? ['조용한 장소'];
  }

  String _generateRelationships(String element, List<String>? interests) {
    final elementRelationships = {
      '금': '결단력 있고 리더십이 강한 사람',
      '수': '유연하고 대화가 잘 통하는 사람',
      '목': '긍정적이고 성장 지향적인 사람',
      '화': '열정적이고 에너지 넘치는 사람',
      '토': '안정적이고 신뢰할 수 있는 사람',
    };

    return elementRelationships[element] ?? '긍정적인 사람';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (inputData == null) {
      return Scaffold(
        appBar: StandardFortuneAppBar(
          title: '행운 아이템',
          onBackPressed: () => context.pop(),
        ),
        body: const Center(
          child: Text('데이터를 불러올 수 없습니다.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.white,
      appBar: StandardFortuneAppBar(
        title: '오늘의 행운 아이템',
        onBackPressed: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 카드
            _buildHeaderCard(isDark),
            const SizedBox(height: 24),

            // 1. 오늘의 행운 키워드
            _buildSection(
              isDark,
              '오늘의 행운 키워드',
              Icons.stars_rounded,
              AppTheme.primaryColor,
              [results['keyword'] ?? '행운, 기회, 성공'],
            ),
            const SizedBox(height: 16),

            // 2. 행운의 색상 + 패션
            _buildSection(
              isDark,
              '행운의 색상 & 패션',
              Icons.palette_rounded,
              const Color(0xFFFF9800),
              [
                '행운의 색상: ${results['color'] ?? '흰색'}',
                ...List<String>.from(results['fashion'] ?? []),
              ],
            ),
            const SizedBox(height: 16),

            // 3. 행운의 숫자
            _buildSection(
              isDark,
              '행운의 숫자',
              Icons.casino_rounded,
              const Color(0xFF4CAF50),
              [
                (results['numbers'] as List<int>?)?.join(', ') ?? '3, 7, 21',
              ],
            ),
            const SizedBox(height: 16),

            // 4. 행운의 음식
            _buildSection(
              isDark,
              '행운의 음식',
              Icons.restaurant_rounded,
              const Color(0xFFE91E63),
              List<String>.from(results['food'] ?? ['균형잡힌 식사']),
            ),
            const SizedBox(height: 16),

            // 5. 행운의 보석/소재
            _buildSection(
              isDark,
              '행운의 보석 & 소재',
              Icons.diamond_rounded,
              const Color(0xFF9C27B0),
              [
                '보석: ${results['jewelry'] ?? '수정'}',
                '소재: ${results['material'] ?? '자연 소재'}',
              ],
            ),
            const SizedBox(height: 16),

            // 6. 행운의 방향 & 장소
            _buildSection(
              isDark,
              '행운의 방향 & 장소',
              Icons.explore_rounded,
              const Color(0xFF2196F3),
              [
                '방향: ${results['direction'] ?? '동쪽'}',
                ...List<String>.from(results['places'] ?? ['조용한 장소']),
              ],
            ),
            const SizedBox(height: 16),

            // 7. 오늘의 좋은 인연
            _buildSection(
              isDark,
              '오늘의 좋은 인연',
              Icons.favorite_rounded,
              const Color(0xFFFF5722),
              [results['relationships'] ?? '긍정적인 사람'],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    return TossCard(
      style: TossCardStyle.elevated,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.8),
                  const Color(0xFFFFB300).withValues(alpha: 0.8),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: TossDesignSystem.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '당신만의 행운 아이템',
            style: TossDesignSystem.heading3.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '오늘 하루 행운을 높여줄 특별한 아이템들이에요',
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    bool isDark,
    String title,
    IconData icon,
    Color color,
    List<String> items,
  ) {
    return TossCard(
      style: TossCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TossDesignSystem.heading4.copyWith(
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: TossDesignSystem.body2.copyWith(
                          color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
