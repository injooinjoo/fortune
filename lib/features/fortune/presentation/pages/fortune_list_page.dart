import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../../../../core/constants/soul_rates.dart';
import '../../../../presentation/widgets/ads/cross_platform_ad_widget.dart';
import '../../../../core/config/environment.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../presentation/providers/fortune_recommendation_provider.dart';

class FortuneCategory {
  final String title;
  final String route;
  final String type; // Fortune type for image mapping
  final IconData icon;
  final List<Color> gradientColors;
  final String description;
  final String category;
  final bool isNew;
  final bool isPremium;

  const FortuneCategory({
    required this.title,
    required this.route,
    required this.type,
    required this.icon,
    required this.gradientColors,
    required this.description,
    required this.category,
    this.isNew = false,
    this.isPremium = false});
  
  // 영혼 정보 가져오기
  int get soulAmount => SoulRates.getSoulAmount(type);
  bool get isFreeFortune => soulAmount > 0;
  bool get isPremiumFortune => soulAmount < 0;
  String get soulDescription => SoulRates.getActionDescription(type);
  int get soulCost => soulAmount.abs(); // Convert to positive cost value
}

enum FortuneCategoryType {
  
  
  all,
  love,
  career,
  money,
  health,
  traditional,
  lifestyle,
  interactive,
  petFamily}

enum ViewMode {
  
  
  trend,
  list}

class FilterCategory {
  final FortuneCategoryType type;
  final String name;
  final IconData icon;
  final Color color;

  const FilterCategory({
    required this.type,
    required this.name,
    required this.icon,
    required this.color});
}

class FortuneListPage extends ConsumerStatefulWidget {
  const FortuneListPage({super.key});

  @override
  ConsumerState<FortuneListPage> createState() => _FortuneListPageState();
}

class _FortuneListPageState extends ConsumerState<FortuneListPage> 
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;

  // Scroll controller for navigation bar hiding
  late ScrollController _scrollController;
  bool _isScrollingDown = false;
  double _lastScrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this
    );
    
    // Initialize scroll controller
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    
    // Ensure navigation is visible when this page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationVisibilityProvider.notifier).show();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }
  
  void _handleScroll() {
    final currentScrollPosition = _scrollController.position.pixels;
    const scrollDownThreshold = 10.0; // Minimum scroll down distance
    const scrollUpThreshold = 3.0; // Ultra sensitive scroll up detection
    
    // Always show navigation when at the top
    if (currentScrollPosition <= 10.0) {
      if (_isScrollingDown) {
        _isScrollingDown = false;
        ref.read(navigationVisibilityProvider.notifier).show();
      }
      _lastScrollPosition = currentScrollPosition;
      return;
    }
    
    if (currentScrollPosition > _lastScrollPosition + scrollDownThreshold && !_isScrollingDown) {
      // Scrolling down - hide navigation
      _isScrollingDown = true;
      ref.read(navigationVisibilityProvider.notifier).hide();
    } else if (currentScrollPosition < _lastScrollPosition - scrollUpThreshold && _isScrollingDown) {
      // Scrolling up - show navigation (very sensitive)
      _isScrollingDown = false;
      ref.read(navigationVisibilityProvider.notifier).show();
    }
    
    _lastScrollPosition = currentScrollPosition;
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure navigation is visible when returning to this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(navigationVisibilityProvider.notifier).show();
      }
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }



  static const List<FortuneCategory> _categories = [
    // ==================== Time-based Fortunes (통합) ====================
    FortuneCategory(
      title: '시간별 운세',
      route: '/time',
      type: 'daily',
      icon: Icons.schedule_rounded,
      gradientColors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
      description: '오늘/내일/주간/월간/연간 운세',
      category: 'lifestyle',
      isNew: true),
    

    // ==================== Traditional Fortunes (통합) ====================
    FortuneCategory(
      title: '전통 운세',
      route: '/traditional',
      type: 'traditional',
      icon: Icons.auto_awesome_rounded,
      gradientColors: [Color(0xFFEF4444), Color(0xFFEC4899)],
      description: '사주/토정비결',
      category: 'traditional'),
    
    // ==================== Tarot Fortune ====================
    FortuneCategory(
      title: '타로 카드',
      route: '/tarot',
      type: 'tarot',
      icon: Icons.style_rounded,
      gradientColors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
      description: '카드가 전하는 오늘의 메시지',
      category: 'traditional',
      isNew: true),
    
    // ==================== Dream Interpretation ====================
    FortuneCategory(
      title: '꿈해몽',
      route: '/dream',
      type: 'dream',
      icon: Icons.bedtime_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      description: '꿈이 전하는 숨겨진 의미',
      category: 'traditional',
      isNew: true),
    
    // ==================== Physiognomy ====================
    FortuneCategory(
      title: '관상',
      route: '/face-reading',
      type: 'face-reading',
      icon: Icons.face_rounded,
      gradientColors: [Color(0xFFEF4444), Color(0xFFDC2626)],
      description: '얼굴에 나타난 운명의 징표',
      category: 'traditional'),
    
    // ==================== Talisman ====================
    FortuneCategory(
      title: '부적',
      route: '/talisman',
      type: 'talisman',
      icon: Icons.shield_rounded,
      gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
      description: '액운을 막고 행운을 부르는 부적',
      category: 'traditional'),

    // ==================== Personal/Character-based Fortunes (통합) ====================
    FortuneCategory(
      title: '성격 DNA',
      route: '/personality-dna',
      type: 'personality-dna',
      icon: Icons.biotech_rounded,
      gradientColors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
      description: '4가지 조합으로 만드는 당신만의 DNA',
      category: 'lifestyle',
      isNew: true),
    FortuneCategory(
      title: 'MBTI 운세',
      route: '/mbti',
      type: 'mbti',
      icon: Icons.psychology_rounded,
      gradientColors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
      description: 'MBTI 성격별 오늘의 운세',
      category: 'lifestyle',
      isNew: true),
    FortuneCategory(
      title: '바이오리듬',
      route: '/biorhythm',
      type: 'biorhythm',
      icon: Icons.timeline_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      description: '신체, 감정, 지성 리듬 분석',
      category: 'health',
      isNew: true),

    // ==================== Relationship/Love Fortunes ====================
    FortuneCategory(
      title: '연애운',
      route: '/love',
      type: 'love',
      icon: Icons.favorite_rounded,
      gradientColors: [Color(0xFFEC4899), Color(0xFFDB2777)],
      description: '사랑과 연애의 운세',
      category: 'love'),
    FortuneCategory(
      title: '궁합',
      route: '/compatibility',
      type: 'compatibility',
      icon: Icons.people_rounded,
      gradientColors: [Color(0xFFBE185D), Color(0xFF9333EA)],
      description: '두 사람의 궁합 보기',
      category: 'love'),
    FortuneCategory(
      title: '피해야 할 사람',
      route: '/avoid-people',
      type: 'relationship',
      icon: Icons.person_off_rounded,
      gradientColors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
      description: '오늘 피해야 할 사람의 특징',
      category: 'love',
      isNew: true),
    FortuneCategory(
      title: '헤어진 애인',
      route: '/ex-lover-simple',
      type: 'ex-lover',
      icon: Icons.heart_broken_rounded,
      gradientColors: [Color(0xFF6B7280), Color(0xFF374151)],
      description: '헤어진 연인과의 재회 가능성',
      category: 'love',
      isNew: true),
    FortuneCategory(
      title: '소개팅 운세',
      route: '/blind-date',
      type: 'blind-date',
      icon: Icons.waving_hand_rounded,
      gradientColors: [Color(0xFFFF6B9D), Color(0xFFE91E63)],
      description: '오늘의 소개팅 성공 가능성',
      category: 'love',
      isNew: true),

    // ==================== Career/Work Fortunes (통합) ====================
    FortuneCategory(
      title: '직업 운세',
      route: '/career',
      type: 'career',
      icon: Icons.work_rounded,
      gradientColors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
      description: '취업/직업/사업/창업 종합',
      category: 'career',
      isNew: true),
    FortuneCategory(
      title: '시험 운세',
      route: '/lucky-exam',
      type: 'study',
      icon: Icons.school_rounded,
      gradientColors: [Color(0xFF03A9F4), Color(0xFF0288D1)],
      description: '시험과 자격증 합격 운세',
      category: 'career'),

    // ==================== Investment/Money Fortunes (통합) ====================
    FortuneCategory(
      title: '투자 운세',
      route: '/investment-enhanced',
      type: 'investment',
      icon: Icons.trending_up_rounded,
      gradientColors: [Color(0xFF16A34A), Color(0xFF15803D)],
      description: '주식/부동산/코인/경매 등 10개 섹터',
      category: 'money',
      isPremium: true,
      isNew: true),

    // ==================== Lifestyle/Lucky Items (통합) ====================
    FortuneCategory(
      title: '행운 아이템',
      route: '/lucky-items',
      type: 'lucky_items',
      icon: Icons.auto_awesome_rounded,
      gradientColors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
      description: '색깔/숫자/음식/아이템',
      category: 'lifestyle'),
    FortuneCategory(
      title: '재능 발견',
      route: '/talent',
      type: 'talent',
      icon: Icons.stars_rounded,
      gradientColors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
      description: '숨겨진 재능 발견',
      category: 'lifestyle'),
    FortuneCategory(
      title: '소원 빌기',
      route: '/wish',
      type: 'wish',
      icon: Icons.star_rounded,
      gradientColors: [Color(0xFFFF4081), Color(0xFFF50057)],
      description: '신에게 소원을 빌어보세요',
      category: 'lifestyle'),

    // ==================== Health & Sports Fortunes (분리) ====================
    FortuneCategory(
      title: '건강운세',
      route: '/health-toss',
      type: 'health',
      icon: Icons.favorite_rounded,
      gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
      description: '오늘의 건강 상태와 신체 부위별 운세',
      category: 'health',
      isNew: true),
    FortuneCategory(
      title: '운동운세',
      route: '/exercise',
      type: 'exercise',
      icon: Icons.fitness_center_rounded,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
      description: '피트니스, 요가, 런닝 운세',
      category: 'health'),
    FortuneCategory(
      title: '스포츠경기',
      route: '/sports-game',
      type: 'sports_game',
      icon: Icons.sports_rounded,
      gradientColors: [Color(0xFFEA580C), Color(0xFFDC2626)],
      description: '골프, 야구, 테니스 등 경기 운세',
      category: 'health'),
    FortuneCategory(
      title: '이사운',
      route: '/moving',
      type: 'moving',
      icon: Icons.home_work_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
      description: '이사 길일과 방향, 손없는날 분석',
      category: 'lifestyle'),

    // ==================== Interactive Fortunes ====================
    FortuneCategory(
      title: '포춘 쿠키',
      route: '/fortune-cookie',
      type: 'fortune-cookie',
      icon: Icons.cookie_rounded,
      gradientColors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
      description: '오늘의 행운 메시지',
      category: 'interactive',
      isNew: true),
    FortuneCategory(
      title: '유명인 운세',
      route: '/celebrity',
      type: 'celebrity',
      icon: Icons.star_rounded,
      gradientColors: [Color(0xFFFF1744), Color(0xFFE91E63)],
      description: '좋아하는 유명인과 나의 오늘 운세',
      category: 'interactive',
      isNew: true),

    // ==================== Pet Fortunes (통합) ====================
    FortuneCategory(
      title: '반려동물 운세',
      route: '/pet',
      type: 'pet',
      icon: Icons.pets_rounded,
      gradientColors: [Color(0xFFE11D48), Color(0xFFBE123C)],
      description: '반려동물/반려견/반려묘/궁합',
      category: 'petFamily',
      isNew: true),
    // ==================== Family Fortunes (통합) ====================
    FortuneCategory(
      title: '가족 운세',
      route: '/family',
      type: 'family',
      icon: Icons.family_restroom_rounded,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
      description: '자녀/육아/태교/가족화합',
      category: 'petFamily',
      isNew: true)];

  // 토스 스타일 카테고리 그룹핑
  Map<String, List<FortuneCategory>> _groupCategoriesByType() {
    final Map<String, List<FortuneCategory>> grouped = {};
    
    // 카테고리별 그룹핑
    for (final category in _categories) {
      final categoryType = category.category;
      if (!grouped.containsKey(categoryType)) {
        grouped[categoryType] = [];
      }
      grouped[categoryType]!.add(category);
    }
    
    return grouped;
  }

  // 카테고리 타입명을 한글로 변환
  String _getCategoryDisplayName(String categoryType) {
    switch (categoryType) {
      case 'love':
        return '연애·인연';
      case 'career':
        return '취업·사업';
      case 'money':
        return '재물·투자';
      case 'health':
        return '건강·라이프';
      case 'traditional':
        return '전통·사주';
      case 'lifestyle':
        return '생활·운세';
      case 'interactive':
        return '인터랙티브';
      case 'petFamily':
        return '반려·육아';
      default:
        return categoryType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedCategories = _groupCategoriesByType();

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? TossDesignSystem.grayDark50
          : TossDesignSystem.white,
      body: SafeArea(
        bottom: false, // 하단 네비게이션 바는 침범 허용
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Banner Ad for non-premium users
            if (Environment.enableAds && !(ref.watch(userProfileProvider).value?.isPremiumActive ?? false))
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: CommonAdPlacements.listBottomAd()),
              ),
            
            // 토스 스타일 섹션별 리스트
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final categoryTypes = groupedCategories.keys.toList();
                  final categoryType = categoryTypes[index];
                  final categories = groupedCategories[categoryType]!;
                  final categoryDisplayName = _getCategoryDisplayName(categoryType);
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 섹션 제목 (토스 스타일)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                        child: Text(
                          categoryDisplayName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? TossDesignSystem.white
                                : const Color(0xFF191919),
                            height: 1.2,
                          ),
                        ),
                      ),
                      
                      // 섹션의 아이템들
                      ...categories.asMap().entries.map((entry) {
                        final itemIndex = entry.key;
                        final category = entry.value;
                        
                        return _buildTossStyleListItem(
                          context,
                          category,
                          isLastInSection: itemIndex == categories.length - 1,
                        );
                      }),
                    ],
                  );
                },
                childCount: groupedCategories.length,
              ),
            ),
            
            // 하단 여백
            const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
          ],
        ),
      ),
    );
  }

  // 토스 스타일 리스트 아이템 생성
  Widget _buildTossStyleListItem(
    BuildContext context,
    FortuneCategory category,
    {required bool isLastInSection}
  ) {
    return Container(
      margin: EdgeInsets.only(
        bottom: isLastInSection ? 0 : 0, // 토스는 여백으로 구분
      ),
      child: Material(
        color: TossDesignSystem.white.withValues(alpha: 0.0),
        child: InkWell(
          onTap: () => _handleCategoryTap(category),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                // 좌측 아이콘 (토스 스타일 원형 배경)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: FortuneCardImages.getGradientColors(category.type),
                    ),
                  ),
                  child: Icon(
                    category.icon,
                    size: 20,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? TossDesignSystem.grayDark100
                        : TossDesignSystem.white,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // 중앙 텍스트 영역
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              category.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? TossDesignSystem.white
                                    : const Color(0xFF191919),
                                height: 1.3,
                              ),
                            ),
                          ),
                          // NEW 배지
                          if (category.isNew) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B6B),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? TossDesignSystem.grayDark100
                                      : TossDesignSystem.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 2),
                      
                      // 부제목 (설명)
                      Text(
                        category.description,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? TossDesignSystem.grayDark600
                              : const Color(0xFF8B95A1),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // 우측 액션 텍스트 (토스 스타일)
                Text(
                  category.isFreeFortune ? '포인트 받기' : '${category.soulCost}원 받기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? TossDesignSystem.grayDark700
                        : const Color(0xFF4E5968),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 카테고리 탭 처리
  void _handleCategoryTap(FortuneCategory category) {
    String fortuneType = category.type;

    // Record visit for recommendation system
    ref.read(fortuneRecommendationProvider.notifier).recordVisit(
      fortuneType,
      category.category
    );

    // 모든 운세를 직접 페이지로 라우팅 (bottomsheet 제거)
    context.push(category.route);
  }


}

// 더이상 사용하지 않는 provider들 제거됨