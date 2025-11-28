import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../core/constants/soul_rates.dart';
import '../../../../presentation/widgets/ads/cross_platform_ad_widget.dart';
import '../../../../core/config/environment.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/providers/user_settings_provider.dart';
import '../../../../presentation/providers/fortune_recommendation_provider.dart';
import '../providers/fortune_order_provider.dart';
import '../widgets/fortune_list_tile.dart';

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
  final bool hasViewedToday; // 오늘 조회 여부

  const FortuneCategory({
    required this.title,
    required this.route,
    required this.type,
    required this.icon,
    required this.gradientColors,
    required this.description,
    required this.category,
    this.isNew = false,
    this.isPremium = false,
    this.hasViewedToday = false,
  });

  // 영혼 정보 가져오기
  int get soulAmount => SoulRates.getSoulAmount(type);
  bool get isFreeFortune => soulAmount > 0;
  bool get isPremiumFortune => soulAmount < 0;
  String get soulDescription => SoulRates.getActionDescription(type);
  int get soulCost => soulAmount.abs(); // Convert to positive cost value

  // 빨간 dot 표시 여부 (새 운세 OR 오늘 안 본 운세)
  bool get shouldShowRedDot => isNew || !hasViewedToday;

  // copyWith 메서드 추가 (hasViewedToday 업데이트용)
  FortuneCategory copyWith({
    String? title,
    String? route,
    String? type,
    IconData? icon,
    List<Color>? gradientColors,
    String? description,
    String? category,
    bool? isNew,
    bool? isPremium,
    bool? hasViewedToday,
  }) {
    return FortuneCategory(
      title: title ?? this.title,
      route: route ?? this.route,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      gradientColors: gradientColors ?? this.gradientColors,
      description: description ?? this.description,
      category: category ?? this.category,
      isNew: isNew ?? this.isNew,
      isPremium: isPremium ?? this.isPremium,
      hasViewedToday: hasViewedToday ?? this.hasViewedToday,
    );
  }
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

  // 오늘 조회한 운세 타입 목록
  Set<String> _viewedTodayTypes = {};

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
      _loadViewedTodayTypes(); // 오늘 조회 여부 로드
    });
  }

  // 오늘 조회한 운세 타입 로드
  Future<void> _loadViewedTodayTypes() async {
    try {
      final user = ref.read(userProvider).value;
      if (user == null) return;

      final supabase = ref.read(supabaseClientProvider);
      final todayStart = DateTime.now().toUtc().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final response = await supabase
          .from('fortune_history')
          .select('fortune_type')
          .eq('user_id', user.id)
          .gte('created_at', todayStart.toIso8601String())
          .lt('created_at', todayEnd.toIso8601String());

      if (mounted) {
        setState(() {
          _viewedTodayTypes = (response as List)
              .map((item) => item['fortune_type'] as String)
              .toSet();
        });
      }
    } catch (e) {
      debugPrint('[FortuneList] 오늘 조회 여부 로드 실패: $e');
    }
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
      route: '/lucky-talisman',
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
      route: '/investment',
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
      route: '/talent-fortune-input',
      type: 'talent',
      icon: Icons.stars_rounded,
      gradientColors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
      description: '사주팔자 기반 재능 분석',
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

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(fortuneOrderProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typography = ref.watch(typographyThemeProvider);

    // 정렬된 전체 카테고리 리스트 가져오기 (오늘 조회 여부 포함)
    final allCategories = _categories.map((category) {
      return category.copyWith(
        hasViewedToday: _viewedTodayTypes.contains(category.type),
      );
    }).toList();
    final sortedCategories = ref.read(fortuneOrderProvider.notifier).getSortedCategories(allCategories);

    // 즐겨찾기와 일반 분리 (즐겨찾기 우선 정렬일 때)
    final favoriteCategories = sortedCategories
        .where((c) => orderState.favorites.contains(c.type))
        .toList();
    final otherCategories = sortedCategories
        .where((c) => !orderState.favorites.contains(c.type))
        .toList();

    final showFavoriteSection = orderState.currentSort == SortOption.favoriteFirst && favoriteCategories.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark
          ? TossDesignSystem.grayDark50
          : TossDesignSystem.white,
      appBar: AppBar(
        backgroundColor: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '운세',
          style: typography.headingMedium.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
          ),
        ),
        actions: [
          // 정렬 버튼
          IconButton(
            icon: Icon(
              Icons.sort_rounded,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
            onPressed: () => _showSortOptions(context),
          ),
        ],
      ),
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

            // 즐겨찾기 섹션 (즐겨찾기 우선 정렬일 때만)
            if (showFavoriteSection) ...[
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...favoriteCategories.asMap().entries.map((entry) {
                      return Row(
                        children: [
                          // ❌ 별 아이콘 제거 (요청사항)
                          // const SizedBox(width: 8),
                          // Icon(
                          //   Icons.star,
                          //   size: 20,
                          //   color: Colors.amber,
                          // ),
                          // const SizedBox(width: 4),
                          Expanded(
                            child: FortuneListTile(
                              key: ValueKey('favorite_${entry.value.type}'),
                              category: entry.value,
                              onTap: () => _handleCategoryTap(entry.value),
                            ),
                          ),
                        ],
                      );
                    }),
                    // 얇은 구분선
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: isDark
                          ? TossDesignSystem.textTertiaryDark.withValues(alpha: 0.2)
                          : TossDesignSystem.textTertiaryLight.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ),
            ],

            // 정렬된 리스트 (일반)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final categories = showFavoriteSection ? otherCategories : sortedCategories;
                  final category = categories[index];

                  return FortuneListTile(
                    key: ValueKey(category.type),
                    category: category,
                    onTap: () => _handleCategoryTap(category),
                  );
                },
                childCount: showFavoriteSection ? otherCategories.length : sortedCategories.length,
              ),
            ),
            
            // 하단 여백
            const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
          ],
        ),
      ),
    );
  }


  // 정렬 옵션 선택 바텀시트
  void _showSortOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentSort = ref.read(fortuneOrderProvider).currentSort;
    final typography = ref.read(typographyThemeProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '정렬 방식',
                style: typography.headingSmall.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 정렬 옵션들
            _buildSortOption(
              context,
              '최근 조회순',
              '최근에 본 운세가 위로',
              SortOption.recentlyViewed,
              currentSort == SortOption.recentlyViewed,
            ),
            _buildSortOption(
              context,
              '조회 가능순',
              '오늘 아직 안 본 운세가 위로',
              SortOption.availableFirst,
              currentSort == SortOption.availableFirst,
            ),
            _buildSortOption(
              context,
              '⭐',
              '즐겨찾기한 운세를 상단에 고정',
              SortOption.favoriteFirst,
              currentSort == SortOption.favoriteFirst,
            ),
            _buildSortOption(
              context,
              '사용자 지정',
              '드래그하여 순서 변경',
              SortOption.custom,
              currentSort == SortOption.custom,
            ),
          ],
        ),
      ),
    );
  }

  // 정렬 옵션 아이템
  Widget _buildSortOption(
    BuildContext context,
    String title,
    String description,
    SortOption option,
    bool isSelected,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typography = ref.watch(typographyThemeProvider);

    return InkWell(
      onTap: () {
        ref.read(fortuneOrderProvider.notifier).changeSortOption(option);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: typography.labelLarge.copyWith(
                      color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: typography.bodySmall.copyWith(
                      color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: TossDesignSystem.tossBlue,
                size: 24,
              ),
          ],
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

    // Record view for order provider
    ref.read(fortuneOrderProvider.notifier).recordView(fortuneType);

    // 모든 운세를 직접 페이지로 라우팅 (bottomsheet 제거)
    context.push(category.route);
  }


}

// 더이상 사용하지 않는 provider들 제거됨