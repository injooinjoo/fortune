import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../widgets/fortune_list_card.dart';
import '../widgets/fortune_list_tile.dart';
import '../../../../presentation/widgets/simple_fortune_info_sheet.dart';
import '../../../../presentation/screens/ad_loading_screen.dart';
import '../../../../presentation/providers/providers.dart';
import '../widgets/tarot_fortune_list_card.dart';
import './tarot_enhanced_page.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../../../../core/constants/soul_rates.dart';
import '../../../../presentation/widgets/ads/cross_platform_ad_widget.dart';
import '../../../../core/config/environment.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/widgets/time_based_fortune_bottom_sheet.dart';

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
    this.isPremium = false,
  });
  
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
  petFamily,
}

enum ViewMode {
  trend,
  list,
}

class FilterCategory {
  final FortuneCategoryType type;
  final String name;
  final IconData icon;
  final Color color;

  const FilterCategory({
    required this.type,
    required this.name,
    required this.icon,
    required this.color,
  });
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0, // Will be used as a progress indicator
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0, // No scaling for now, will calculate dynamically
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0, // Keep opacity at 1.0 (no fade)
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
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
    
    // Calculate the height for the top portion (60% of screen to overlap with bottom sheet)
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
                      color: Colors.black.withValues(alpha: 0.3 * (1 - progress * 0.5)),
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
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
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
      color: Color(0xFF7C3AED),
    ),
    FilterCategory(
      type: FortuneCategoryType.love,
      name: '연애·인연',
      icon: Icons.favorite_rounded,
      color: Color(0xFFEC4899),
    ),
    FilterCategory(
      type: FortuneCategoryType.career,
      name: '취업·사업',
      icon: Icons.work_rounded,
      color: Color(0xFF3B82F6),
    ),
    FilterCategory(
      type: FortuneCategoryType.money,
      name: '재물·투자',
      icon: Icons.attach_money_rounded,
      color: Color(0xFFF59E0B),
    ),
    FilterCategory(
      type: FortuneCategoryType.health,
      name: '건강·라이프',
      icon: Icons.spa_rounded,
      color: Color(0xFF10B981),
    ),
    FilterCategory(
      type: FortuneCategoryType.traditional,
      name: '전통·사주',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFEF4444),
    ),
    FilterCategory(
      type: FortuneCategoryType.lifestyle,
      name: '생활·운세',
      icon: Icons.calendar_today_rounded,
      color: Color(0xFF06B6D4),
    ),
    FilterCategory(
      type: FortuneCategoryType.interactive,
      name: '인터랙티브',
      icon: Icons.touch_app_rounded,
      color: Color(0xFF9333EA),
    ),
    FilterCategory(
      type: FortuneCategoryType.petFamily,
      name: '반려·육아',
      icon: Icons.family_restroom_rounded,
      color: Color(0xFFE11D48),
    ),
  ];

  static const List<FortuneCategory> _categories = [
    // ==================== Time-based Fortunes (통합) ====================
    FortuneCategory(
      title: '시간별 운세',
      route: '/fortune/time',
      type: 'daily',
      icon: Icons.schedule_rounded,
      gradientColors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
      description: '오늘/내일/주간/월간/연간 운세',
      category: 'lifestyle',
      isNew: true,
    ),
    

    // ==================== Traditional Fortunes (통합) ====================
    FortuneCategory(
      title: '전통 운세',
      route: '/fortune/traditional',
      type: 'traditional',
      icon: Icons.auto_awesome_rounded,
      gradientColors: [Color(0xFFEF4444), Color(0xFFEC4899)],
      description: '사주/토정비결',
      category: 'traditional',
    ),
    
    // ==================== Tarot Fortune ====================
    FortuneCategory(
      title: '타로 카드',
      route: '/fortune/tarot',
      type: 'tarot',
      icon: Icons.style_rounded,
      gradientColors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
      description: '카드가 전하는 오늘의 메시지',
      category: 'traditional',
      isNew: true,
    ),
    
    // ==================== Dream Interpretation ====================
    FortuneCategory(
      title: '꿈해몽',
      route: '/fortune/dream',
      type: 'dream',
      icon: Icons.bedtime_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      description: '꿈이 전하는 숨겨진 의미',
      category: 'traditional',
      isNew: true,
    ),
    
    // ==================== Physiognomy ====================
    FortuneCategory(
      title: '관상',
      route: '/fortune/physiognomy',
      type: 'physiognomy',
      icon: Icons.face_rounded,
      gradientColors: [Color(0xFFEF4444), Color(0xFFDC2626)],
      description: '얼굴에 나타난 운명의 징표',
      category: 'traditional',
    ),
    
    // ==================== Talisman ====================
    FortuneCategory(
      title: '부적',
      route: '/fortune/talisman',
      type: 'talisman',
      icon: Icons.shield_rounded,
      gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
      description: '액운을 막고 행운을 부르는 부적',
      category: 'traditional',
    ),

    // ==================== Personal/Character-based Fortunes (통합) ====================
    FortuneCategory(
      title: '성격 운세',
      route: '/fortune/personality',
      type: 'personality',
      icon: Icons.psychology_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
      description: 'MBTI/혈액형',
      category: 'lifestyle',
      isNew: true,
    ),
    FortuneCategory(
      title: '바이오리듬',
      route: '/fortune/lifestyle?type=biorhythm',
      type: 'biorhythm',
      icon: Icons.timeline_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      description: '신체, 감정, 지성 리듬 분석',
      category: 'health',
      isNew: true,
    ),

    // ==================== Relationship/Love Fortunes ====================
    FortuneCategory(
      title: '연애운',
      route: '/fortune/relationship?type=love',
      type: 'love',
      icon: Icons.favorite_rounded,
      gradientColors: [Color(0xFFEC4899), Color(0xFFDB2777)],
      description: '사랑과 연애의 운세',
      category: 'love',
    ),
    FortuneCategory(
      title: '궁합',
      route: '/fortune/relationship?type=compatibility',
      type: 'compatibility',
      icon: Icons.people_rounded,
      gradientColors: [Color(0xFFBE185D), Color(0xFF9333EA)],
      description: '두 사람의 궁합 보기',
      category: 'love',
    ),
    FortuneCategory(
      title: '피해야 할 사람',
      route: '/fortune/relationship?type=avoid-people',
      type: 'relationship',
      icon: Icons.person_off_rounded,
      gradientColors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
      description: '오늘 피해야 할 사람의 특징',
      category: 'love',
      isNew: true,
    ),

    // ==================== Career/Work Fortunes (통합) ====================
    FortuneCategory(
      title: '커리어 운세',
      route: '/fortune/career',
      type: 'career',
      icon: Icons.work_rounded,
      gradientColors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
      description: '취업/직업/사업/창업 종합',
      category: 'career',
      isNew: true,
    ),
    FortuneCategory(
      title: '시험 운세',
      route: '/fortune/career?type=exam',
      type: 'study',
      icon: Icons.school_rounded,
      gradientColors: [Color(0xFF03A9F4), Color(0xFF0288D1)],
      description: '시험과 자격증 합격 운세',
      category: 'career',
    ),

    // ==================== Investment/Money Fortunes (통합) ====================
    FortuneCategory(
      title: '투자 운세',
      route: '/fortune/investment',
      type: 'investment',
      icon: Icons.trending_up_rounded,
      gradientColors: [Color(0xFF16A34A), Color(0xFF15803D)],
      description: '재물/부동산/주식/암호화폐/로또',
      category: 'money',
      isPremium: true,
    ),

    // ==================== Lifestyle/Lucky Items (통합) ====================
    FortuneCategory(
      title: '행운 아이템',
      route: '/fortune/lucky-items',
      type: 'lucky_items',
      icon: Icons.auto_awesome_rounded,
      gradientColors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
      description: '색깔/숫자/음식/아이템',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '재능 발견',
      route: '/fortune/lifestyle?type=talent',
      type: 'talent',
      icon: Icons.stars_rounded,
      gradientColors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
      description: '숨겨진 재능 발견',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '소원 성취',
      route: '/fortune/lifestyle?type=wish',
      type: 'wish',
      icon: Icons.star_rounded,
      gradientColors: [Color(0xFFFF4081), Color(0xFFF50057)],
      description: '소원 성취 가능성',
      category: 'lifestyle',
    ),

    // ==================== Health/Sports Fortunes (통합) ====================
    FortuneCategory(
      title: '건강 & 운동',
      route: '/fortune/health-sports',
      type: 'health',
      icon: Icons.health_and_safety_rounded,
      gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
      description: '건강/피트니스/요가/스포츠',
      category: 'health',
      isNew: true,
    ),
    FortuneCategory(
      title: '이사운',
      route: '/fortune/lifestyle?type=moving',
      type: 'moving',
      icon: Icons.home_work_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
      description: '이사 길일과 방향',
      category: 'lifestyle',
    ),

    // ==================== Interactive Fortunes ====================
    FortuneCategory(
      title: '포춘 쿠키',
      route: '/fortune/interactive?type=fortune-cookie',
      type: 'fortune-cookie',
      icon: Icons.cookie_rounded,
      gradientColors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
      description: '오늘의 행운 메시지',
      category: 'interactive',
      isNew: true,
    ),
    FortuneCategory(
      title: '유명인 운세',
      route: '/fortune/celebrity',
      type: 'celebrity',
      icon: Icons.star_rounded,
      gradientColors: [Color(0xFFFF1744), Color(0xFFE91E63)],
      description: '연예인/유튜버/프로게이머/축구선수 등',
      category: 'interactive',
      isNew: true,
    ),
    
    // ==================== Fortune History (프로필로 이동) ====================
    FortuneCategory(
      title: '운세 히스토리',
      route: '/profile/history',
      type: 'history',
      icon: Icons.history_rounded,
      gradientColors: [Color(0xFF795548), Color(0xFF5D4037)],
      description: '과거 운세 기록 및 통계',
      category: 'lifestyle',
      isNew: true,
    ),

    // ==================== Pet Fortunes (통합) ====================
    FortuneCategory(
      title: '반려동물 운세',
      route: '/fortune/pet',
      type: 'pet',
      icon: Icons.pets_rounded,
      gradientColors: [Color(0xFFE11D48), Color(0xFFBE123C)],
      description: '반려동물/반려견/반려묘/궁합',
      category: 'petFamily',
      isNew: true,
    ),
    // ==================== Family Fortunes (통합) ====================
    FortuneCategory(
      title: '가족 운세',
      route: '/fortune/family',
      type: 'family',
      icon: Icons.family_restroom_rounded,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
      description: '자녀/육아/태교/가족화합',
      category: 'petFamily',
      isNew: true,
    ),
  ];

  List<FortuneCategory> _filterCategories(String searchQuery, FortuneCategoryType selectedType) {
    var filtered = _categories;
    
    // Apply category filter
    if (selectedType != FortuneCategoryType.all) {
      filtered = filtered.where((category) {
        return category.category == selectedType.name;
      }).toList();
    }
    
    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((category) {
        return category.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
               category.description.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchQuery = ref.watch(_searchQueryProvider);
    final selectedCategory = ref.watch(_selectedCategoryProvider);
    final viewMode = ref.watch(_viewModeProvider);
    final filteredCategories = _filterCategories(searchQuery, selectedCategory);

    return Scaffold(
      appBar: const AppHeader(
        showBackButton: false,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCategoryFilter(context, ref),
                  const SizedBox(height: 12),
                  _buildSearchBar(context, ref),
                ],
              ),
            ),
          ),
          // Banner Ad for non-premium users
          if (Environment.enableAds && !(ref.watch(userProfileProvider).value?.isPremiumActive ?? false))
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: CommonAdPlacements.listBottomAd(),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (selectedCategory != FortuneCategoryType.all)
                    TextButton(
                      onPressed: () {
                        ref.read(_selectedCategoryProvider.notifier).state = FortuneCategoryType.all;
                      },
                      child: const Text('전체 보기'),
                    )
                  else
                    const SizedBox.shrink(),
                  _buildViewModeToggle(context, ref),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = filteredCategories[index];
                  final isLastItem = index == filteredCategories.length - 1;
                  
                  return Column(
                    children: [
                      viewMode == ViewMode.trend
                          ? (category.type == 'tarot'
                              ? TarotFortuneListCard(
                                  title: category.title,
                                  description: category.description,
                                  onTap: () {
                                    // Navigate directly to enhanced tarot page with hero animation
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => TarotEnhancedPage(
                                          heroTag: 'tarot-hero-${category.route}',
                                        ),
                                      ),
                                    );
                                  },
                                  isPremium: category.isPremium,
                                  soulCost: category.soulCost,
                                  route: category.route,
                                )
                              : FortuneListCard(
                                  category: category,
                                  thumbnailKey: _getThumbnailKey(category.route),
                                  onTap: () {
                              // Extract fortune type from route or use the type field
                              String fortuneType = category.type;
                              
                              // Handle special routes with query parameters
                              if (category.route.contains('?type=')) {
                                final queryPart = category.route.split('?type=').last;
                                fortuneType = queryPart;
                              } else if (category.route.contains('/fortune/')) {
                                // For simple routes like '/fortune/daily'
                                final segments = category.route.split('/');
                                if (segments.length > 2) {
                                  fortuneType = segments[2];
                                }
                              }
                              
                              print('[FortuneListPage] Tapped fortune: ${category.title}');
                              print('[FortuneListPage] Route: ${category.route}');
                              print('[FortuneListPage] Type: $fortuneType');
                              
                              // Check if this is time-based fortune
                              if (category.route == '/fortune/time') {
                                // Show time-based fortune bottom sheet directly without animated thumbnail
                                TimeBasedFortuneBottomSheet.show(
                                  context,
                                  onDismiss: () {
                                    // No overlay to dismiss for time-based fortune
                                  },
                                );
                              } else {
                                // Get thumbnail image path and show animation for other fortunes
                                final thumbnailPath = FortuneCardImages.getImagePath(category.type);
                                final thumbnailKey = _getThumbnailKey(category.route);
                                
                                // Show animated thumbnail
                                _showAnimatedThumbnail(context, thumbnailKey, thumbnailPath, () {
                                  // Callback when animation is dismissed
                                });
                                
                                // Show regular bottom sheet
                                SimpleFortunInfoSheet.show(
                                  context,
                                  fortuneType: fortuneType,
                                  onDismiss: () {
                                    // Call the dismiss callback to remove the overlay
                                    _currentDismissCallback?.call();
                                  },
                                  onFortuneButtonPressed: () {
                                    print('[FortuneListPage] Fortune button pressed, navigating to AdLoadingScreen');
                                    
                                    // Navigate directly to AdLoadingScreen instead of fortune page
                                    final isPremium = ref.read(hasUnlimitedAccessProvider);
                                    
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AdLoadingScreen(
                                          fortuneType: fortuneType,
                                          fortuneTitle: category.title,
                                          fortuneRoute: category.route,
                                          isPremium: isPremium,
                                          onComplete: () {
                                            // This won't be called since we're using fortuneRoute
                                          },
                                          onSkip: () {
                                            // Navigate to premium page or handle skip
                                            context.push('/subscription');
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ))
                          : FortuneListTile(
                              category: category,
                              onTap: () {
                                // Handle tarot specially
                                if (category.type == 'tarot') {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => TarotEnhancedPage(
                                        heroTag: 'tarot-hero-${category.route}',
                                      ),
                                    ),
                                  );
                                } else {
                                  // Check if this is time-based fortune
                                  if (category.route == '/fortune/time') {
                                    // Show time-based fortune bottom sheet directly
                                    TimeBasedFortuneBottomSheet.show(
                                      context,
                                      onDismiss: () {
                                        // No overlay to dismiss in list view
                                      },
                                    );
                                  } else {
                                    // Same logic as FortuneListCard
                                    String fortuneType = category.type;
                                    
                                    if (category.route.contains('?type=')) {
                                      final queryPart = category.route.split('?type=').last;
                                      fortuneType = queryPart;
                                    } else if (category.route.contains('/fortune/')) {
                                      final segments = category.route.split('/');
                                      if (segments.length > 2) {
                                        fortuneType = segments[2];
                                      }
                                    }
                                    
                                    SimpleFortunInfoSheet.show(
                                      context,
                                      fortuneType: fortuneType,
                                      onDismiss: () {
                                        // No overlay to dismiss in list view
                                      },
                                      onFortuneButtonPressed: () {
                                      final isPremium = ref.read(hasUnlimitedAccessProvider);
                                      
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => AdLoadingScreen(
                                            fortuneType: fortuneType,
                                            fortuneTitle: category.title,
                                            fortuneRoute: category.route,
                                            isPremium: isPremium,
                                            onComplete: () {},
                                            onSkip: () {
                                              context.push('/subscription');
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                  }
                                }
                              },
                            ),
                      if (!isLastItem && viewMode == ViewMode.list) 
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                        ),
                    ],
                  );
                },
                childCount: filteredCategories.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: BorderRadius.circular(16),
      blur: 10,
      child: TextField(
        onChanged: (value) {
          ref.read(_searchQueryProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: '운세 검색...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildViewModeToggle(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final viewMode = ref.watch(_viewModeProvider);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Toggle between grid and list view
          if (viewMode == ViewMode.trend) {
            ref.read(_viewModeProvider.notifier).state = ViewMode.list;
          } else {
            ref.read(_viewModeProvider.notifier).state = ViewMode.trend;
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                viewMode == ViewMode.trend 
                    ? Icons.grid_view_rounded 
                    : Icons.view_list_rounded,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 6),
              Text(
                viewMode == ViewMode.trend ? '카드' : '리스트',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedCategory = ref.watch(_selectedCategoryProvider);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = selectedCategory == filter.type;
          
          return GestureDetector(
            onTap: () {
              ref.read(_selectedCategoryProvider.notifier).state = filter.type;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [filter.color, filter.color.withValues(alpha: 0.8)],
                      )
                    : null,
                color: isSelected ? null : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    filter.icon,
                    size: 18,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}

final _searchQueryProvider = StateProvider<String>((ref) => '');
final _selectedCategoryProvider = StateProvider<FortuneCategoryType>((ref) => FortuneCategoryType.all);
final _viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.trend);