import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../core/constants/soul_rates.dart';
import '../../../../presentation/widgets/ads/cross_platform_ad_widget.dart';
import '../../../../core/config/environment.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/design_system/tokens/ds_fortune_colors.dart';
import '../../../../core/design_system/components/traditional/traditional_button.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../presentation/providers/fortune_recommendation_provider.dart';
import '../providers/fortune_order_provider.dart';
import '../widgets/fortune_list_tile.dart';

class FortuneCategory {
  final String title;
  final String route;
  final String type; // Fortune type for image mapping
  final IconData icon;
  final String? iconAsset; // 커스텀 아이콘 에셋 경로 (한국 전통 수묵화 스타일)
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
    this.iconAsset,
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

  // 빨간 dot 표시 여부 (오늘 안 본 운세만 표시, 조회하면 제거)
  bool get shouldShowRedDot => !hasViewedToday;

  // copyWith 메서드 추가 (hasViewedToday 업데이트용)
  FortuneCategory copyWith({
    String? title,
    String? route,
    String? type,
    IconData? icon,
    String? iconAsset,
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
      iconAsset: iconAsset ?? this.iconAsset,
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
      _triggerStaggeredHaptics(); // 카드 등장 햅틱
    });
  }

  /// 카드가 순차적으로 올라올 때 가벼운 햅틱 피드백
  Future<void> _triggerStaggeredHaptics() async {
    final haptic = ref.read(fortuneHapticServiceProvider);
    // 처음 5개 카드 등장 시 가벼운 햅틱 (stagger 간격에 맞춤)
    for (int i = 0; i < 5; i++) {
      await Future.delayed(Duration(milliseconds: 80 * i));
      if (!mounted) return;
      haptic.selection(); // 가벼운 선택 햅틱
    }
  }

  // 오늘 조회한 운세 타입 로드
  Future<void> _loadViewedTodayTypes() async {
    try {
      final user = ref.read(userProvider).value;
      if (user == null) return;

      final supabase = ref.read(supabaseClientProvider);

      // 로컬 타임존 기준 오늘 (한국 시간 기준)
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day); // 로컬 자정
      final todayEnd = todayStart.add(const Duration(days: 1));

      final response = await supabase
          .from('fortune_history')
          .select('fortune_type')
          .eq('user_id', user.id)
          .gte('created_at', todayStart.toUtc().toIso8601String())
          .lt('created_at', todayEnd.toUtc().toIso8601String());

      if (mounted) {
        setState(() {
          _viewedTodayTypes = (response as List)
              .map((item) => item['fortune_type'] as String)
              .toSet();
        });
        debugPrint('[FortuneList] 오늘 조회한 운세: $_viewedTodayTypes');
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
        // 페이지로 돌아올 때마다 오늘 조회 여부 새로고침 (빨간점 업데이트)
        _loadViewedTodayTypes();
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
      title: '달력',
      route: '/time',
      type: 'daily_calendar',  // DB 저장 값과 일치
      icon: Icons.schedule_rounded,
      iconAsset: 'assets/icons/fortune/daily.png',
      gradientColors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
      description: '오늘/내일/주간/월간/연간 운세',
      category: 'lifestyle',
      isNew: true),


    // ==================== Traditional Fortunes (통합) ====================
    FortuneCategory(
      title: '전통',
      route: '/traditional',
      type: 'traditional_saju',  // DB 저장 값과 일치
      icon: Icons.auto_awesome_rounded,
      iconAsset: 'assets/icons/fortune/traditional.png',
      gradientColors: [Color(0xFFEF4444), Color(0xFFEC4899)],
      description: '사주/토정비결',
      category: 'traditional'),

    // ==================== Tarot Fortune ====================
    FortuneCategory(
      title: '타로',
      route: '/tarot',
      type: 'tarot',
      icon: Icons.style_rounded,
      iconAsset: 'assets/icons/fortune/tarot.png',
      gradientColors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
      description: '카드가 전하는 오늘의 메시지',
      category: 'traditional',
      isNew: true),

    // ==================== Dream Interpretation ====================
    FortuneCategory(
      title: '해몽',
      route: '/dream',
      type: 'dream',
      icon: Icons.bedtime_rounded,
      iconAsset: 'assets/icons/fortune/dream.png',
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
      iconAsset: 'assets/icons/fortune/face_reading.png',
      gradientColors: [Color(0xFFEF4444), Color(0xFFDC2626)],
      description: '얼굴에 나타난 운명의 징표',
      category: 'traditional'),

    // ==================== Talisman ====================
    FortuneCategory(
      title: '부적',
      route: '/lucky-talisman',
      type: 'talisman',
      icon: Icons.shield_rounded,
      iconAsset: 'assets/icons/fortune/talisman.png',
      gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
      description: '액운을 막고 행운을 부르는 부적',
      category: 'traditional'),

    // ==================== Personal/Character-based Fortunes (통합) ====================
    FortuneCategory(
      title: '나의 성격 탐구',
      route: '/personality-dna',
      type: 'personality-dna',
      icon: Icons.biotech_rounded,
      iconAsset: 'assets/icons/fortune/personality_dna.png',
      gradientColors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
      description: 'MBTI × 혈액형 × 별자리 × 띠 조합 분석',
      category: 'lifestyle',
      isNew: true),
    FortuneCategory(
      title: 'MBTI',
      route: '/mbti',
      type: 'mbti',
      icon: Icons.psychology_rounded,
      iconAsset: 'assets/icons/fortune/mbti.png',
      gradientColors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
      description: 'MBTI 성격별 오늘의 운세',
      category: 'lifestyle',
      isNew: true),
    FortuneCategory(
      title: '바이오리듬',
      route: '/biorhythm',
      type: 'biorhythm',
      icon: Icons.timeline_rounded,
      iconAsset: 'assets/icons/fortune/biorhythm.png',
      gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      description: '신체, 감정, 지성 리듬 분석',
      category: 'health',
      isNew: true),

    // ==================== Relationship/Love Fortunes ====================
    FortuneCategory(
      title: '연애',
      route: '/love',
      type: 'love',
      icon: Icons.favorite_rounded,
      iconAsset: 'assets/icons/fortune/love.png',
      gradientColors: [Color(0xFFEC4899), Color(0xFFDB2777)],
      description: '사랑과 연애의 운세',
      category: 'love'),
    FortuneCategory(
      title: '궁합',
      route: '/compatibility',
      type: 'compatibility',
      icon: Icons.people_rounded,
      iconAsset: 'assets/icons/fortune/compatibility.png',
      gradientColors: [Color(0xFFBE185D), Color(0xFF9333EA)],
      description: '두 사람의 궁합 보기',
      category: 'love'),
    FortuneCategory(
      title: '경계대상',
      route: '/avoid-people',
      type: 'avoid-people',  // DB 저장 값과 일치
      icon: Icons.person_off_rounded,
      iconAsset: 'assets/icons/fortune/avoid_people.png',
      gradientColors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
      description: '오늘 피해야 할 사람의 특징',
      category: 'love',
      isNew: true),
    FortuneCategory(
      title: '재회',
      route: '/ex-lover-simple',
      type: 'ex_lover',  // DB 저장 값과 일치
      icon: Icons.heart_broken_rounded,
      iconAsset: 'assets/icons/fortune/ex_lover.png',
      gradientColors: [Color(0xFF6B7280), Color(0xFF374151)],
      description: '헤어진 연인과의 재회 가능성',
      category: 'love',
      isNew: true),
    FortuneCategory(
      title: '소개팅',
      route: '/blind-date',
      type: 'blind_date',  // DB 저장 값과 일치
      icon: Icons.waving_hand_rounded,
      iconAsset: 'assets/icons/fortune/blind_date.png',
      gradientColors: [Color(0xFFFF6B9D), Color(0xFFE91E63)],
      description: '오늘의 소개팅 성공 가능성',
      category: 'love',
      isNew: true),

    // ==================== Career/Work Fortunes (통합) ====================
    FortuneCategory(
      title: '직업',
      route: '/career',
      type: 'career',
      icon: Icons.work_rounded,
      iconAsset: 'assets/icons/fortune/career.png',
      gradientColors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
      description: '취업/직업/사업/창업 종합',
      category: 'career',
      isNew: true),
    FortuneCategory(
      title: '시험',
      route: '/lucky-exam',
      type: 'exam',  // DB 저장 값과 일치
      icon: Icons.school_rounded,
      iconAsset: 'assets/icons/fortune/study.png',
      gradientColors: [Color(0xFF03A9F4), Color(0xFF0288D1)],
      description: '시험과 자격증 합격 운세',
      category: 'career'),

    // ==================== Investment/Money Fortunes (통합) ====================
    FortuneCategory(
      title: '재물',
      route: '/investment',
      type: 'investment',
      icon: Icons.trending_up_rounded,
      iconAsset: 'assets/icons/fortune/investment.png',
      gradientColors: [Color(0xFF16A34A), Color(0xFF15803D)],
      description: '주식/부동산/코인/경매 등 10개 섹터',
      category: 'money',
      isPremium: true,
      isNew: true),

    // ==================== Lifestyle/Lucky Items (통합) ====================
    FortuneCategory(
      title: '행운아이템',
      route: '/lucky-items',
      type: 'lucky_items',
      icon: Icons.auto_awesome_rounded,
      iconAsset: 'assets/icons/fortune/lucky_items.png',
      gradientColors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
      description: '색깔/숫자/음식/아이템',
      category: 'lifestyle'),
    FortuneCategory(
      title: '로또',
      route: '/lotto',
      type: 'lucky-lottery',
      icon: Icons.casino_rounded,
      iconAsset: 'assets/icons/fortune/lotto.png',
      gradientColors: [Color(0xFFFFD700), Color(0xFFFFA500)],
      description: '오늘의 행운 번호',
      category: 'lifestyle',
      isNew: true),
    FortuneCategory(
      title: '재능',
      route: '/talent-fortune-input',
      type: 'talent',
      icon: Icons.stars_rounded,
      iconAsset: 'assets/icons/fortune/talent.png',
      gradientColors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
      description: '사주팔자 기반 재능 분석',
      category: 'lifestyle'),
    FortuneCategory(
      title: '소원',
      route: '/wish',
      type: 'wish',
      icon: Icons.star_rounded,
      iconAsset: 'assets/icons/fortune/wish.png',
      gradientColors: [Color(0xFFFF4081), Color(0xFFF50057)],
      description: '신에게 소원을 빌어보세요',
      category: 'lifestyle'),

    // ==================== Health & Sports Fortunes (분리) ====================
    FortuneCategory(
      title: '건강',
      route: '/health-toss',
      type: 'health',
      icon: Icons.favorite_rounded,
      iconAsset: 'assets/icons/fortune/health.png',
      gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
      description: '오늘의 건강 상태와 신체 부위별 운세',
      category: 'health',
      isNew: true),
    FortuneCategory(
      title: '운동',
      route: '/exercise',
      type: 'exercise',
      icon: Icons.fitness_center_rounded,
      iconAsset: 'assets/icons/fortune/exercise.png',
      gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
      description: '피트니스, 요가, 런닝 운세',
      category: 'health'),
    FortuneCategory(
      title: '스포츠경기',
      route: '/sports-game',
      type: 'sports_game',
      icon: Icons.sports_rounded,
      iconAsset: 'assets/icons/fortune/sports_game.png',
      gradientColors: [Color(0xFFEA580C), Color(0xFFDC2626)],
      description: '골프, 야구, 테니스 등 경기 운세',
      category: 'health'),
    FortuneCategory(
      title: '이사',
      route: '/moving',
      type: 'moving',
      icon: Icons.home_work_rounded,
      iconAsset: 'assets/icons/fortune/moving.png',
      gradientColors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
      description: '이사 길일과 방향, 손없는날 분석',
      category: 'lifestyle'),

    // ==================== Interactive Fortunes ====================
    FortuneCategory(
      title: '포춘쿠키',
      route: '/fortune-cookie',
      type: 'fortune-cookie',
      icon: Icons.cookie_rounded,
      iconAsset: 'assets/icons/fortune/fortune_cookie.png',
      gradientColors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
      description: '오늘의 행운 메시지',
      category: 'interactive',
      isNew: true),
    FortuneCategory(
      title: '유명인',
      route: '/celebrity',
      type: 'celebrity',
      icon: Icons.star_rounded,
      iconAsset: 'assets/icons/fortune/celebrity.png',
      gradientColors: [Color(0xFFFF1744), Color(0xFFE91E63)],
      description: '좋아하는 유명인과 나의 오늘 운세',
      category: 'interactive',
      isNew: true),

    // ==================== Pet Fortunes (통합) ====================
    FortuneCategory(
      title: '반려동물',
      route: '/pet',
      type: 'pet',
      icon: Icons.pets_rounded,
      iconAsset: 'assets/icons/fortune/pet.png',
      gradientColors: [Color(0xFFE11D48), Color(0xFFBE123C)],
      description: '반려동물/반려견/반려묘/궁합',
      category: 'petFamily',
      isNew: true),
    // ==================== Family Fortunes (통합) ====================
    FortuneCategory(
      title: '가족',
      route: '/family',
      type: 'family',
      icon: Icons.family_restroom_rounded,
      iconAsset: 'assets/icons/fortune/family.png',
      gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
      description: '자녀/육아/태교/가족화합',
      category: 'petFamily',
      isNew: true)];

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(fortuneOrderProvider);
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

    // 전통 한지 배경색
    final hanjiBackground = DSFortuneColors.getHanjiBackground(isDark);

    return Scaffold(
      backgroundColor: hanjiBackground,
      appBar: AppBar(
        backgroundColor: hanjiBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '運勢',
              style: TextStyle(
                fontFamily: 'GowunBatang',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: DSFortuneColors.getPrimary(isDark).withValues(alpha: 0.7),
                letterSpacing: 2,
              ),
            ),
            Text(
              '운세',
              style: TextStyle(
                fontFamily: 'GowunBatang',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: DSFortuneColors.getInk(isDark),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          // 전통 스타일 정렬 버튼
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TraditionalIconButton(
              icon: Icons.sort_rounded,
              colorScheme: TraditionalButtonColorScheme.fortune,
              size: 40,
              showBorder: false,
              onPressed: () => _showSortOptions(context),
            ),
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
                    // 얇은 구분선 (ink-wash style)
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: colors.textTertiary.withValues(alpha: 0.2),
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

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 100),
                    child: SlideAnimation(
                      verticalOffset: 20.0,
                      child: FadeInAnimation(
                        child: FortuneListTile(
                          key: ValueKey(category.type),
                          category: category,
                          onTap: () => _handleCategoryTap(category),
                        ),
                      ),
                    ),
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


  // 정렬 옵션 선택 바텀시트 (Korean Traditional style)
  void _showSortOptions(BuildContext context) {
    final currentSort = ref.read(fortuneOrderProvider).currentSort;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hanjiBackground = DSFortuneColors.getHanjiBackground(isDark);
    final inkColor = DSFortuneColors.getInk(isDark);
    final primaryColor = DSFortuneColors.getPrimary(isDark);

    showModalBottomSheet(
      context: context,
      backgroundColor: hanjiBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: hanjiBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border(
            top: BorderSide(
              color: primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 제목 (Calligraphy style with Hanja)
              Column(
                children: [
                  Text(
                    '整列',
                    style: TextStyle(
                      fontFamily: 'GowunBatang',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: primaryColor.withValues(alpha: 0.6),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '정렬 방식',
                    style: TextStyle(
                      fontFamily: 'GowunBatang',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: inkColor,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 구분선 (brush stroke style)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        primaryColor.withValues(alpha: 0.4),
                        primaryColor.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.2, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 정렬 옵션들
              _buildSortOption(
                context,
                '추천순',
                '인기 + 조회수 + 즐겨찾기 기반',
                SortOption.recommended,
                currentSort == SortOption.recommended,
              ),
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
                '즐겨찾기 우선',
                '즐겨찾기한 운세를 상단에 고정',
                SortOption.favoriteFirst,
                currentSort == SortOption.favoriteFirst,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 정렬 옵션 아이템 (Korean Traditional style with vermilion accent)
  Widget _buildSortOption(
    BuildContext context,
    String title,
    String description,
    SortOption option,
    bool isSelected,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inkColor = DSFortuneColors.getInk(isDark);
    final primaryColor = DSFortuneColors.getPrimary(isDark);
    final sealColor = DSFortuneColors.sealVermilion;

    return InkWell(
      onTap: () {
        DSHaptics.light();
        ref.read(fortuneOrderProvider.notifier).changeSortOption(option);
        Navigator.pop(context);
      },
      splashColor: primaryColor.withValues(alpha: 0.1),
      highlightColor: primaryColor.withValues(alpha: 0.05),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: isSelected
            ? BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                border: Border(
                  left: BorderSide(
                    color: sealColor,
                    width: 3,
                  ),
                ),
              )
            : null,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'GowunBatang',
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? primaryColor : inkColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      color: inkColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: sealColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '✓',
                    style: TextStyle(
                      fontFamily: 'GowunBatang',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: sealColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 카테고리 탭 처리
  void _handleCategoryTap(FortuneCategory category) {
    ref.read(fortuneHapticServiceProvider).buttonTap();
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