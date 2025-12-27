import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../presentation/widgets/ads/cross_platform_ad_widget.dart';
import '../../../../core/config/environment.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/design_system/tokens/ds_fortune_colors.dart';
import '../../../../core/design_system/components/traditional/traditional_button.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../core/theme/font_config.dart';
import '../../../../presentation/providers/fortune_recommendation_provider.dart';
import '../providers/fortune_order_provider.dart';
import '../providers/fortune_categories_provider.dart';
import '../widgets/fortune_list_tile.dart';
import '../widgets/fortune_entry_section.dart';
import '../widgets/fortune_search_overlay.dart';
import '../../domain/entities/fortune_category.dart';
import '../../../../shared/components/profile_header_icon.dart';

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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;

  // Scroll controller for navigation bar hiding
  late ScrollController _scrollController;
  bool _isScrollingDown = false;
  double _lastScrollPosition = 0;

  // 오늘 조회한 탐구 타입 목록
  Set<String> _viewedTodayTypes = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
      _triggerEntryHaptic(); // 진입 햅틱 (1회)
    });
  }

  /// 페이지 진입 시 가벼운 햅틱 피드백 (1회만)
  void _triggerEntryHaptic() {
    final haptic = ref.read(fortuneHapticServiceProvider);
    haptic.selection(); // 진입 시 1회만
  }

  // 오늘 조회한 탐구 타입 로드 (SharedPreferences 기반 - 진입만 해도 체크됨)
  Future<void> _loadViewedTodayTypes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayKey = 'viewed_fortunes_${now.year}_${now.month}_${now.day}';

      // SharedPreferences에서 오늘 진입한 운세 목록 로드
      final viewedTypes = prefs.getStringList(todayKey) ?? [];

      if (mounted) {
        setState(() {
          _viewedTodayTypes = viewedTypes.toSet();
        });
        debugPrint('[FortuneList] 오늘 진입한 탐구: $_viewedTodayTypes');
      }
    } catch (e) {
      debugPrint('[FortuneList] 오늘 진입 여부 로드 실패: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  /// 앱 생명주기 변화 감지 - 앱 복귀 시 빨간점 상태 새로고침
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadViewedTodayTypes();
    }
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

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(fortuneOrderProvider);
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Remote Config에서 카테고리 로드 (OTA 업데이트 지원)
    final categories = ref.watch(fortuneCategoriesProvider);

    // 정렬된 전체 카테고리 리스트 가져오기 (오늘 조회 여부 포함)
    final allCategories = categories.map((category) {
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
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Center(child: ProfileHeaderIcon()),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '探求',
              style: TextStyle(
                fontFamily: FontConfig.primary,
                fontSize: FontConfig.labelTiny,
                fontWeight: FontWeight.w400,
                color: DSFortuneColors.getPrimary(isDark).withValues(alpha: 0.7),
                letterSpacing: 2,
              ),
            ),
            Text(
              '탐구',
              style: TextStyle(
                fontFamily: FontConfig.primary,
                fontSize: FontConfig.heading3,
                fontWeight: FontWeight.w700,
                color: DSFortuneColors.getInk(isDark),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          // 검색 버튼
          TraditionalIconButton(
            icon: Icons.search_rounded,
            colorScheme: TraditionalButtonColorScheme.fortune,
            size: 40,
            showBorder: false,
            onPressed: () => _showSearchOverlay(context, categories),
          ),
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

            // 소개팅/직업 진입 카드 (상단 고정)
            SliverToBoxAdapter(
              child: FortuneEntrySection(isDark: isDark),
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

            // 정렬된 리스트 (일반) - 스크롤 성능을 위해 애니메이션 제거
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


  // 검색 오버레이 표시
  void _showSearchOverlay(BuildContext context, List<FortuneCategory> categories) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FortuneSearchOverlay(categories: categories),
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
                      fontFamily: FontConfig.primary,
                      fontSize: FontConfig.labelTiny,
                      fontWeight: FontWeight.w400,
                      color: primaryColor.withValues(alpha: 0.6),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '정렬 방식',
                    style: TextStyle(
                      fontFamily: FontConfig.primary,
                      fontSize: FontConfig.heading4,
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
                '최근에 본 항목이 위로',
                SortOption.recentlyViewed,
                currentSort == SortOption.recentlyViewed,
              ),
              _buildSortOption(
                context,
                '조회 가능순',
                '오늘 아직 안 본 항목이 위로',
                SortOption.availableFirst,
                currentSort == SortOption.availableFirst,
              ),
              _buildSortOption(
                context,
                '즐겨찾기 우선',
                '즐겨찾기한 항목을 상단에 고정',
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
                      fontFamily: FontConfig.primary,
                      fontSize: FontConfig.bodySmall,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? primaryColor : inkColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: FontConfig.primary,
                      fontSize: FontConfig.labelSmall,
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
                      fontFamily: FontConfig.primary,
                      fontSize: FontConfig.labelMedium,
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
    final String fortuneType = category.type;

    // Record visit for recommendation system
    ref.read(fortuneRecommendationProvider.notifier).recordVisit(
      fortuneType,
      category.category
    );

    // Record view for order provider
    ref.read(fortuneOrderProvider.notifier).recordView(fortuneType);

    // 진입 즉시 빨간점 제거 (UI 즉시 업데이트)
    if (!_viewedTodayTypes.contains(fortuneType)) {
      setState(() {
        _viewedTodayTypes.add(fortuneType);
      });
      // SharedPreferences에도 저장 (앱 재시작 후에도 유지)
      _saveViewedType(fortuneType);
    }

    // 모든 탐구를 직접 페이지로 라우팅 (bottomsheet 제거)
    context.push(category.route);
  }

  // 진입한 탐구 타입을 SharedPreferences에 저장
  Future<void> _saveViewedType(String fortuneType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayKey = 'viewed_fortunes_${now.year}_${now.month}_${now.day}';

      final existingTypes = prefs.getStringList(todayKey) ?? [];
      if (!existingTypes.contains(fortuneType)) {
        existingTypes.add(fortuneType);
        await prefs.setStringList(todayKey, existingTypes);
      }
    } catch (e) {
      debugPrint('[FortuneList] 진입 기록 저장 실패: $e');
    }
  }


}

// 더이상 사용하지 않는 provider들 제거됨