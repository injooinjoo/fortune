import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';

class FortuneCategory {
  final String title;
  final String route;
  final IconData icon;
  final List<Color> gradientColors;
  final String description;
  final String category;
  final bool isNew;
  final bool isPremium;

  const FortuneCategory({
    required this.title,
    required this.route,
    required this.icon,
    required this.gradientColors,
    required this.description,
    required this.category,
    this.isNew = false,
    this.isPremium = false,
  });
}

enum FortuneCategoryType {
  all,
  love,
  career,
  money,
  health,
  traditional,
  lifestyle,
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

class FortuneListPage extends ConsumerWidget {
  const FortuneListPage({super.key});

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
  ];

  static const List<FortuneCategory> _categories = [
    // Daily/Time-based
    FortuneCategory(
      title: '오늘의 운세',
      route: '/fortune/today',
      icon: Icons.today_rounded,
      gradientColors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
      description: '오늘 하루의 전체적인 운세',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '내일의 운세',
      route: '/fortune/tomorrow',
      icon: Icons.event_rounded,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
      description: '내일을 위한 미리보기',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '시간대별 운세',
      route: '/fortune/hourly',
      icon: Icons.access_time_rounded,
      gradientColors: [Color(0xFF06B6D4), Color(0xFF10B981)],
      description: '시간대별 상세 운세',
      category: 'lifestyle',
      isNew: true,
    ),
    FortuneCategory(
      title: '주간 운세',
      route: '/fortune/weekly',
      icon: Icons.date_range_rounded,
      gradientColors: [Color(0xFF10B981), Color(0xFF14B8A6)],
      description: '이번 주 전체 운세',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '월간 운세',
      route: '/fortune/monthly',
      icon: Icons.calendar_month_rounded,
      gradientColors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
      description: '이번 달 종합 운세',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '연간 운세',
      route: '/fortune/yearly',
      icon: Icons.calendar_today_rounded,
      gradientColors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
      description: '올해 전체 운세',
      category: 'lifestyle',
      isPremium: true,
    ),

    // Personal/Character
    FortuneCategory(
      title: '사주팔자',
      route: '/fortune/saju',
      icon: Icons.auto_awesome_rounded,
      gradientColors: [Color(0xFFEF4444), Color(0xFFEC4899)],
      description: '전통 사주 명리학',
      category: 'traditional',
      isPremium: true,
    ),
    FortuneCategory(
      title: '생일 운세',
      route: '/fortune/birthdate',
      icon: Icons.cake_rounded,
      gradientColors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
      description: '생일 기반 운세',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '별자리 운세',
      route: '/fortune/zodiac',
      icon: Icons.stars_rounded,
      gradientColors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      description: '서양 별자리 운세',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '띠 운세',
      route: '/fortune/zodiac-animal',
      icon: Icons.pets_rounded,
      gradientColors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
      description: '12간지 띠 운세',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: 'MBTI 운세',
      route: '/fortune/mbti',
      icon: Icons.psychology_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
      description: 'MBTI 성격 기반 운세',
      category: 'lifestyle',
      isNew: true,
    ),
    FortuneCategory(
      title: '혈액형 운세',
      route: '/fortune/blood-type',
      icon: Icons.water_drop_rounded,
      gradientColors: [Color(0xFFDC2626), Color(0xFFEF4444)],
      description: '혈액형별 성격과 운세',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '바이오리듬',
      route: '/fortune/biorhythm',
      icon: Icons.timeline_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      description: '신체, 감정, 지성 리듬 분석',
      category: 'health',
      isNew: true,
    ),

    // Relationship
    FortuneCategory(
      title: '연애운',
      route: '/fortune/love',
      icon: Icons.favorite_rounded,
      gradientColors: [Color(0xFFEC4899), Color(0xFFDB2777)],
      description: '사랑과 연애의 운세',
      category: 'love',
    ),
    FortuneCategory(
      title: '결혼운',
      route: '/fortune/marriage',
      icon: Icons.favorite_border_rounded,
      gradientColors: [Color(0xFFDB2777), Color(0xFFBE185D)],
      description: '결혼과 배우자 운',
      category: 'love',
      isPremium: true,
    ),
    FortuneCategory(
      title: '궁합',
      route: '/fortune/compatibility',
      icon: Icons.people_rounded,
      gradientColors: [Color(0xFFBE185D), Color(0xFF9333EA)],
      description: '두 사람의 궁합 보기',
      category: 'love',
    ),
    FortuneCategory(
      title: '소울메이트',
      route: '/fortune/couple-match',
      icon: Icons.connect_without_contact_rounded,
      gradientColors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
      description: '운명의 짝 찾기',
      category: 'love',
      isNew: true,
    ),
    FortuneCategory(
      title: '피해야 할 사람',
      route: '/fortune/avoid-people',
      icon: Icons.person_off_rounded,
      gradientColors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
      description: '오늘 피해야 할 사람의 특징',
      category: 'love',
      isNew: true,
    ),

    // Career/Wealth
    FortuneCategory(
      title: '직업운',
      route: '/fortune/career',
      icon: Icons.work_rounded,
      gradientColors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
      description: '커리어와 직업 운세',
      category: 'career',
    ),
    FortuneCategory(
      title: '재물운',
      route: '/fortune/wealth',
      icon: Icons.attach_money_rounded,
      gradientColors: [Color(0xFF16A34A), Color(0xFF15803D)],
      description: '금전운과 재물운',
      category: 'money',
    ),
    FortuneCategory(
      title: '사업운',
      route: '/fortune/business',
      icon: Icons.business_rounded,
      gradientColors: [Color(0xFF0891B2), Color(0xFF0E7490)],
      description: '사업과 투자 운세',
      category: 'career',
      isPremium: true,
    ),
    FortuneCategory(
      title: '부동산운',
      route: '/fortune/lucky-realestate',
      icon: Icons.home_rounded,
      gradientColors: [Color(0xFF059669), Color(0xFF047857)],
      description: '부동산 투자 운세',
      category: 'money',
      isPremium: true,
    ),
    FortuneCategory(
      title: '투자 운세',
      route: '/fortune/lucky-investment',
      icon: Icons.trending_up,
      gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
      description: '주식·암호화폐 투자 운세',
      category: 'money',
      isPremium: true,
    ),

    // Lucky Items
    FortuneCategory(
      title: '행운의 색깔',
      route: '/fortune/lucky-color',
      icon: Icons.palette_rounded,
      gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
      description: '오늘의 행운 색상',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '행운의 숫자',
      route: '/fortune/lucky-number',
      icon: Icons.looks_one_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
      description: '행운을 부르는 숫자',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '행운의 음식',
      route: '/fortune/lucky-food',
      icon: Icons.restaurant_rounded,
      gradientColors: [Color(0xFFEF4444), Color(0xFFDC2626)],
      description: '운을 높이는 음식',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '행운의 아이템',
      route: '/fortune/lucky-items',
      icon: Icons.diamond_rounded,
      gradientColors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      description: '행운을 부르는 물건',
      category: 'lifestyle',
    ),

    // Sports/Activities
    FortuneCategory(
      title: '운동 운세',
      route: '/fortune/lucky-sports',
      icon: Icons.sports_rounded,
      gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
      description: '스포츠별 운세',
      category: 'health',
      isNew: true,
    ),
    FortuneCategory(
      title: '골프 운세',
      route: '/fortune/lucky-golf',
      icon: Icons.golf_course_rounded,
      gradientColors: [Color(0xFF059669), Color(0xFF047857)],
      description: '골프 스코어 운세',
      category: 'health',
    ),
    FortuneCategory(
      title: '테니스 운세',
      route: '/fortune/lucky-tennis',
      icon: Icons.sports_tennis,
      gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
      description: '테니스 승리 운세',
      category: 'health',
    ),
    FortuneCategory(
      title: '런닝 운세',
      route: '/fortune/lucky-running',
      icon: Icons.directions_run,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
      description: '러닝 레코드 운세',
      category: 'health',
    ),
    FortuneCategory(
      title: '자전거 운세',
      route: '/fortune/lucky-cycling',
      icon: Icons.directions_bike,
      gradientColors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
      description: '라이딩 안전 운세',
      category: 'health',
    ),
    FortuneCategory(
      title: '수영 운세',
      route: '/fortune/lucky-swim',
      icon: Icons.pool,
      gradientColors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
      description: '수영 기록 운세',
      category: 'health',
    ),
    FortuneCategory(
      title: '낚시 운세',
      route: '/fortune/lucky-fishing',
      icon: Icons.phishing_rounded,
      gradientColors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
      description: '낚시 대박 운세',
      category: 'health',
    ),

    // Special
    FortuneCategory(
      title: '타로 카드',
      route: '/interactive/tarot',
      icon: Icons.style_rounded,
      gradientColors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
      description: '타로카드 점술',
      category: 'traditional',
      isPremium: true,
    ),
    FortuneCategory(
      title: '꿈 해몽',
      route: '/interactive/dream',
      icon: Icons.bedtime_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
      description: '꿈의 의미 해석',
      category: 'traditional',
    ),
    FortuneCategory(
      title: '관상',
      route: '/physiognomy',
      icon: Icons.face_rounded,
      gradientColors: [Color(0xFFEC4899), Color(0xFFDB2777)],
      description: '얼굴로 보는 운세',
      category: 'traditional',
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final searchQuery = ref.watch(_searchQueryProvider);
    final selectedCategory = ref.watch(_selectedCategoryProvider);
    final filteredCategories = _filterCategories(searchQuery, selectedCategory);

    return Scaffold(
      appBar: const AppHeader(
        title: '운세 카테고리',
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '전체 ${filteredCategories.length}개 운세',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  if (selectedCategory != FortuneCategoryType.all)
                    TextButton(
                      onPressed: () {
                        ref.read(_selectedCategoryProvider.notifier).state = FortuneCategoryType.all;
                      },
                      child: const Text('전체 보기'),
                    ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = filteredCategories[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: _buildCategoryCard(context, category),
                      ),
                    ),
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
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                        colors: [filter.color, filter.color.withOpacity(0.8)],
                      )
                    : null,
                color: isSelected ? null : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : theme.colorScheme.outline.withOpacity(0.3),
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

  Widget _buildCategoryCard(BuildContext context, FortuneCategory category) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.push(category.route),
      child: Stack(
        children: [
          ShimmerGlass(
            shimmerColor: category.gradientColors.first,
            borderRadius: BorderRadius.circular(20),
            child: GlassContainer(
              borderRadius: BorderRadius.circular(20),
              blur: 15,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: category.gradientColors.map((color) => 
                  color.withOpacity(0.1)
                ).toList(),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: category.gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        category.icon,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (category.isNew)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (category.isPremium)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

final _searchQueryProvider = StateProvider<String>((ref) => '');
final _selectedCategoryProvider = StateProvider<FortuneCategoryType>((ref) => FortuneCategoryType.all);