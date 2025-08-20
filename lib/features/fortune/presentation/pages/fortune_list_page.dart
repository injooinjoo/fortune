import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/components/app_header.dart';
import '../widgets/fortune_list_card.dart';
import '../widgets/fortune_list_tile.dart';
// import '../../../../presentation/widgets/simple_fortune_info_sheet.dart'; // File doesn't exist
import '../../../../presentation/screens/ad_loading_screen.dart';
import '../../../../presentation/providers/providers.dart';
import '../widgets/tarot_fortune_list_card.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../../../../core/constants/soul_rates.dart';
import '../../../../presentation/widgets/ads/cross_platform_ad_widget.dart';
import '../../../../core/config/environment.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/widgets/time_based_fortune_bottom_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../presentation/providers/fortune_recommendation_provider.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';
import '../../../../data/models/fortune_card_score.dart';

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
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final Map<String, GlobalKey> _thumbnailKeys = {};
  
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
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0, // Will be used as a progress indicator
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0, // No scaling for now, will calculate dynamically
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0, // Keep opacity at 1.0 (no fade)
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut));
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

  GlobalKey _getThumbnailKey(String categoryRoute) {
    return _thumbnailKeys.putIfAbsent(categoryRoute, () => GlobalKey());
  }

  void _showAnimatedThumbnail(BuildContext context, GlobalKey cardKey, String imagePath, VoidCallback onDismiss) {
    final RenderBox? renderBox = cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final cardSize = renderBox.size;
    final cardPosition = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate the height for the top portion (60% of screen to overlap with bottom sheet),
            final topPortionHeight = screenHeight * 0.6;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final progress = _slideAnimation.value;
            
            // Interpolate position
            final currentLeft = cardPosition.dx * (1 - progress);
            final currentTop = cardPosition.dy * (1 - progress);
            final currentWidth = cardSize.width + (screenWidth - cardSize.width) * progress;
            final currentHeight = cardSize.width + (topPortionHeight - cardSize.width) * progress;
            
            // Interpolate border radius
            final borderRadius = 12.0 * (1 - progress);
            
            return Positioned(
              left: currentLeft,
              top: currentTop,
              width: currentWidth,
              height: currentHeight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3 * (1 - progress * 0.5)),
                      blurRadius: 20 + (10 * progress),
                      offset: Offset(0, 10 * (1 - progress)),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
            );
          });
      }
    );

    Overlay.of(context).insert(_overlayEntry!);
    
    // Start the animation but don't remove the overlay
    _animationController.forward();
    
    // Store the dismiss callback to be called when bottom sheet closes
    _currentDismissCallback = () {
      // Play reverse animation with faster duration
      _animationController.duration = const Duration(milliseconds: 400);
      _animationController.reverse().then((_) {
        _removeOverlay();
        _animationController.reset();
        // Reset to original duration for next forward animation
        _animationController.duration = const Duration(milliseconds: 600);
        onDismiss();
      });
    };
  }
  
  VoidCallback? _currentDismissCallback;

  static const List<FilterCategory> _filterOptions = [
    FilterCategory(
      type: FortuneCategoryType.all,
      name: '전체',
      icon: Icons.star_rounded,
      color: Color(0xFF7C3AED)),
    FilterCategory(
      type: FortuneCategoryType.love,
      name: '연애·인연',
      icon: Icons.favorite_rounded,
      color: Color(0xFFEC4899)),
    FilterCategory(
      type: FortuneCategoryType.career,
      name: '취업·사업',
      icon: Icons.work_rounded,
      color: Color(0xFF3B82F6)),
    FilterCategory(
      type: FortuneCategoryType.money,
      name: '재물·투자',
      icon: Icons.attach_money_rounded,
      color: Color(0xFFF59E0B)),
    FilterCategory(
      type: FortuneCategoryType.health,
      name: '건강·라이프',
      icon: Icons.spa_rounded,
      color: Color(0xFF10B981)),
    FilterCategory(
      type: FortuneCategoryType.traditional,
      name: '전통·사주',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFEF4444)),
    FilterCategory(
      type: FortuneCategoryType.lifestyle,
      name: '생활·운세',
      icon: Icons.calendar_today_rounded,
      color: Color(0xFF06B6D4)),
    FilterCategory(
      type: FortuneCategoryType.interactive,
      name: '인터랙티브',
      icon: Icons.touch_app_rounded,
      color: Color(0xFF9333EA)),
    FilterCategory(
      type: FortuneCategoryType.petFamily,
      name: '반려·육아',
      icon: Icons.family_restroom_rounded,
      color: Color(0xFFE11D48))];

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
      title: '성격 운세',
      route: '/personality',
      type: 'personality',
      icon: Icons.psychology_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
      description: 'MBTI/혈액형',
      category: 'lifestyle',
      isNew: true),
    FortuneCategory(
      title: '바이오리듬',
      route: '/lifestyle?type=biorhythm',
      type: 'biorhythm',
      icon: Icons.timeline_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      description: '신체, 감정, 지성 리듬 분석',
      category: 'health',
      isNew: true),

    // ==================== Relationship/Love Fortunes ====================
    FortuneCategory(
      title: '연애운',
      route: '/relationship?type=love',
      type: 'love',
      icon: Icons.favorite_rounded,
      gradientColors: [Color(0xFFEC4899), Color(0xFFDB2777)],
      description: '사랑과 연애의 운세',
      category: 'love'),
    FortuneCategory(
      title: '궁합',
      route: '/relationship?type=compatibility',
      type: 'compatibility',
      icon: Icons.people_rounded,
      gradientColors: [Color(0xFFBE185D), Color(0xFF9333EA)],
      description: '두 사람의 궁합 보기',
      category: 'love'),
    FortuneCategory(
      title: '피해야 할 사람',
      route: '/relationship?type=avoid-people',
      type: 'relationship',
      icon: Icons.person_off_rounded,
      gradientColors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
      description: '오늘 피해야 할 사람의 특징',
      category: 'love',
      isNew: true),
    FortuneCategory(
      title: '헤어진 애인',
      route: '/ex-lover-enhanced',
      type: 'ex-lover',
      icon: Icons.heart_broken_rounded,
      gradientColors: [Color(0xFF6B7280), Color(0xFF374151)],
      description: '헤어진 연인과의 재회 가능성',
      category: 'love',
      isNew: true),

    // ==================== Career/Work Fortunes (통합) ====================
    FortuneCategory(
      title: '커리어 운세',
      route: '/career',
      type: 'career',
      icon: Icons.work_rounded,
      gradientColors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
      description: '취업/직업/사업/창업 종합',
      category: 'career',
      isNew: true),
    FortuneCategory(
      title: '시험 운세',
      route: '/career?type=exam',
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
      route: '/lifestyle?type=talent',
      type: 'talent',
      icon: Icons.stars_rounded,
      gradientColors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
      description: '숨겨진 재능 발견',
      category: 'lifestyle'),
    FortuneCategory(
      title: '소원 성취',
      route: '/lifestyle?type=wish',
      type: 'wish',
      icon: Icons.star_rounded,
      gradientColors: [Color(0xFFFF4081), Color(0xFFF50057)],
      description: '소원 성취 가능성',
      category: 'lifestyle'),

    // ==================== Health/Sports Fortunes (통합) ====================
    FortuneCategory(
      title: '건강 & 운동',
      route: '/health-sports',
      type: 'health',
      icon: Icons.health_and_safety_rounded,
      gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
      description: '건강/피트니스/요가/스포츠',
      category: 'health',
      isNew: true),
    FortuneCategory(
      title: '스포츠 운세',
      route: '/enhanced-sports',
      type: 'enhanced_sports',
      icon: Icons.sports_rounded,
      gradientColors: [Color(0xFFEA580C), Color(0xFFDC2626)],
      description: '모든 스포츠 종목별 운세와 팀 승부운',
      category: 'health',
      isNew: true),
    FortuneCategory(
      title: '이사운',
      route: '/lifestyle?type=moving',
      type: 'moving',
      icon: Icons.home_work_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
      description: '이사 길일과 방향, 손없는날 분석',
      category: 'lifestyle'),

    // ==================== Interactive Fortunes ====================
    FortuneCategory(
      title: '포춘 쿠키',
      route: '/interactive?type=fortune-cookie',
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
    
    // ==================== Fortune History (프로필로 이동) ====================
    FortuneCategory(
      title: '운세 히스토리',
      route: '/history',
      type: 'history',
      icon: Icons.history_rounded,
      gradientColors: [Color(0xFF795548), Color(0xFF5D4037)],
      description: '과거 운세 기록 및 통계',
      category: 'lifestyle',
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
    final theme = Theme.of(context);
    final groupedCategories = _groupCategoriesByType();

    return Scaffold(
      backgroundColor: Colors.white, // 토스 스타일 순수 흰색 배경
      body: SafeArea(
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF191919),
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
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
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
        color: Colors.transparent,
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
                    color: Colors.white,
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF191919),
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
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF8B95A1),
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF4E5968),
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
    
    // Handle special routes with query parameters
    if (category.route.contains('?type=')) {
      final queryPart = category.route.split('?type=').last;
      fortuneType = queryPart;
    }
    
    // Check if this is time-based fortune
    if (category.route == '/time') {
      TimeBasedFortuneBottomSheet.show(
        context,
        onDismiss: () {},
      );
    } else if (category.type == 'tarot') {
      context.push('/tarot');
    } else {
      // Record visit for recommendation system
      ref.read(fortuneRecommendationProvider.notifier).recordVisit(
        fortuneType,
        category.category
      );
      
      final isPremium = ref.read(hasUnlimitedAccessProvider);
      
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AdLoadingScreen(
            fortuneType: fortuneType,
            fortuneTitle: category.title,
            fortuneRoute: category.route,
            isPremium: isPremium,
            onComplete: () {},
            onSkip: () {
              context.push('/subscription');
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 80),
        ),
      );
    }
  }


}

// 더이상 사용하지 않는 provider들 제거됨