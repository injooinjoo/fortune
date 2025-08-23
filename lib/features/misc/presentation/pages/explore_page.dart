import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../presentation/providers/token_provider.dart';

// Fortune item model
class FortuneItem {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String route;
  final List<Color> gradientColors;
  final String category;
  final bool isPremium;
  final bool isNew;

  const FortuneItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.route,
    required this.gradientColors,
    required this.category,
    this.isPremium = false,
    this.isNew = false,
  });
}

// Fortune categories
final Map<String, FortuneCategory> fortuneCategories = {
  'daily': FortuneCategory(
    id: 'daily',
    label: '데일리',
    icon: Icons.today_rounded,
    color: const Color(0xFF7C3AED),
    items: [
      FortuneItem(
        id: 'today',
        name: '오늘의 운세',
        description: '오늘 하루의 전체적인 운세',
        icon: Icons.today_rounded,
        route: '/fortune/today',
        gradientColors: const [Color(0xFF7C3AED), Color(0xFF3B82F6)],
        category: 'daily',
      ),
      FortuneItem(
        id: 'tomorrow',
        name: '내일의 운세',
        description: '내일을 위한 미리보기',
        icon: Icons.event_rounded,
        route: '/fortune/tomorrow',
        gradientColors: const [Color(0xFF3B82F6), Color(0xFF06B6D4)],
        category: 'daily',
      ),
      FortuneItem(
        id: 'hourly',
        name: '시간대별 운세',
        description: '시간대별 상세 운세',
        icon: Icons.access_time_rounded,
        route: '/hourly',
        gradientColors: const [Color(0xFF06B6D4), Color(0xFF10B981)],
        category: 'daily',
        isNew: true,
      ),
    ],
  ),
  'love': FortuneCategory(
    id: 'love',
    label: '연애·인연',
    icon: Icons.favorite_rounded,
    color: const Color(0xFFEC4899),
    items: [
      FortuneItem(
        id: 'love',
        name: '연애운',
        description: '사랑과 연애의 운세',
        icon: Icons.favorite_rounded,
        route: '/fortune/love',
        gradientColors: const [Color(0xFFEC4899), Color(0xFFDB2777)],
        category: 'love',
      ),
      FortuneItem(
        id: 'marriage',
        name: '결혼운',
        description: '결혼과 배우자 운',
        icon: Icons.favorite_border_rounded,
        route: '/fortune/marriage',
        gradientColors: const [Color(0xFFDB2777), Color(0xFFBE185D)],
        category: 'love',
        isPremium: true,
      ),
      FortuneItem(
        id: 'compatibility',
        name: '궁합',
        description: '두 사람의 궁합 보기',
        icon: Icons.people_rounded,
        route: '/fortune/compatibility',
        gradientColors: const [Color(0xFFBE185D), Color(0xFF9333EA)],
        category: 'love',
      ),
    ],
  ),
  'career': FortuneCategory(
    id: 'career',
    label: '취업·사업',
    icon: Icons.work_rounded,
    color: const Color(0xFF3B82F6),
    items: [
      FortuneItem(
        id: 'career',
        name: '직업운',
        description: '커리어와 직업 운세',
        icon: Icons.work_rounded,
        route: '/fortune/career',
        gradientColors: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        category: 'career',
      ),
      FortuneItem(
        id: 'business',
        name: '사업운',
        description: '사업과 투자 운세',
        icon: Icons.business_rounded,
        route: '/fortune/business',
        gradientColors: const [Color(0xFF0891B2), Color(0xFF0E7490)],
        category: 'career',
        isPremium: true,
      ),
      FortuneItem(
        id: 'employment',
        name: '취업운',
        description: '면접운과 합격 가능성',
        icon: Icons.work_rounded,
        route: '/fortune/employment',
        gradientColors: const [Color(0xFF00ACC1), Color(0xFF0097A7)],
        category: 'career',
        isNew: true,
      ),
    ],
  ),
  'money': FortuneCategory(
    id: 'money',
    label: '재물·투자',
    icon: Icons.attach_money_rounded,
    color: const Color(0xFFF59E0B),
    items: [
      FortuneItem(
        id: 'wealth',
        name: '재물운',
        description: '금전운과 재물운',
        icon: Icons.attach_money_rounded,
        route: '/fortune/wealth',
        gradientColors: const [Color(0xFF16A34A), Color(0xFF15803D)],
        category: 'money',
      ),
      FortuneItem(
        id: 'investment',
        name: '투자 운세',
        description: '주식·암호화폐 투자 운세',
        icon: Icons.trending_up,
        route: '/fortune/lucky-investment',
        gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
        category: 'money',
        isPremium: true,
      ),
      FortuneItem(
        id: 'lottery',
        name: '로또 운세',
        description: '행운의 로또 번호',
        icon: Icons.confirmation_number_rounded,
        route: '/fortune/lucky-lottery',
        gradientColors: const [Color(0xFFFFB300), Color(0xFFF57C00)],
        category: 'money',
        isNew: true,
      ),
    ],
  ),
  'traditional': FortuneCategory(
    id: 'traditional',
    label: '전통·사주',
    icon: Icons.auto_awesome_rounded,
    color: const Color(0xFFEF4444),
    items: [
      FortuneItem(
        id: 'saju',
        name: '사주팔자',
        description: '전통 사주 명리학',
        icon: Icons.auto_awesome_rounded,
        route: '/fortune/saju',
        gradientColors: const [Color(0xFFEF4444), Color(0xFFEC4899)],
        category: 'traditional',
        isPremium: true,
      ),
      FortuneItem(
        id: 'tojeong',
        name: '토정비결',
        description: '64괘로 보는 운세',
        icon: Icons.book_rounded,
        route: '/fortune/tojeong',
        gradientColors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        category: 'traditional',
      ),
      FortuneItem(
        id: 'past-life',
        name: '전생',
        description: '전생과 현생의 과업',
        icon: Icons.history_rounded,
        route: '/fortune/past-life',
        gradientColors: const [Color(0xFF6A1B9A), Color(0xFF4A148C)],
        category: 'traditional',
        isPremium: true,
      ),
    ],
  ),
  'interactive': FortuneCategory(
    id: 'interactive',
    label: '인터랙티브',
    icon: Icons.touch_app_rounded,
    color: const Color(0xFF9333EA),
    items: [
      FortuneItem(
        id: 'tarot',
        name: '타로 카드',
        description: '타로카드 점술',
        icon: Icons.style_rounded,
        route: '/interactive/tarot',
        gradientColors: const [Color(0xFF9333EA), Color(0xFF7C3AED)],
        category: 'interactive',
        isPremium: true,
      ),
      FortuneItem(
        id: 'dream',
        name: '꿈 해몽',
        description: '꿈의 의미 해석',
        icon: Icons.bedtime_rounded,
        route: '/interactive/dream-interpretation',
        gradientColors: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
        category: 'interactive',
      ),
      FortuneItem(
        id: 'fortune-cookie',
        name: '포춘 쿠키',
        description: '오늘의 행운 메시지',
        icon: Icons.cookie_rounded,
        route: '/interactive/fortune-cookie',
        gradientColors: const [Color(0xFF9333EA), Color(0xFF7C3AED)],
        category: 'interactive',
        isNew: true,
      ),
    ],
  ),
};

class FortuneCategory {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final List<FortuneItem> items;

  const FortuneCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.items,
  });
}

// Providers
final selectedCategoryProvider = StateProvider<String>((ref) => 'daily');
final searchQueryProvider = StateProvider<String>((ref) => '');

class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    // Filter items based on search
    List<FortuneItem> filteredItems = [];
    if (searchQuery.isEmpty) {
      filteredItems = fortuneCategories[selectedCategory]?.items ?? [];
    } else {
      // Search across all categories
      for (final category in fortuneCategories.values) {
        filteredItems.addAll(
          category.items.where((item) =>
              item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              item.description.toLowerCase().contains(searchQuery.toLowerCase()),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppHeader(
        title: '운세 탐색',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
              style: theme.textTheme.bodyLarge?.copyWith(fontSize: fontSize.value),
              decoration: InputDecoration(
                hintText: '운세 검색...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Category Tabs
          if (searchQuery.isEmpty)
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: fortuneCategories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final categoryKey = fortuneCategories.keys.elementAt(index);
                  final category = fortuneCategories[categoryKey]!;
                  final isSelected = selectedCategory == categoryKey;

                  return GestureDetector(
                    onTap: () {
                      ref.read(selectedCategoryProvider.notifier).state = categoryKey;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  category.color,
                                  category.color.withValues(alpha: 0.8),
                                ],
                              )
                            : null,
                        color: isSelected ? null : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.icon,
                            size: 20,
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: fontSize.value - 2,
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
            ),
          const SizedBox(height: 16),

          // Results Count
          if (searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '결과: ${filteredItems.length}개',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: fontSize.value - 2,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

          // Fortune Items Grid
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          searchQuery.isNotEmpty
                              ? Icons.search_off_rounded
                              : Icons.category_rounded,
                          size: 80,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isNotEmpty
                              ? '검색 결과가 없습니다'
                              : '카테고리가 비어있습니다',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: fontSize.value + 2,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _FortuneItemCard(item: item, fontSize: fontSize.value);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FortuneItemCard extends ConsumerWidget {
  final FortuneItem item;
  final double fontSize;

  const _FortuneItemCard({
    required this.item,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        // Direct navigation for all fortune types
        context.push(item.route);
      },
      child: Stack(
        children: [
          GlassContainer(
            borderRadius: BorderRadius.circular(20),
            blur: 15,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: item.gradientColors
                  .map((color) => color.withValues(alpha: 0.1))
                  .toList(),
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
                        colors: item.gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      item.icon,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: fontSize - 4,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // Badges
          if (item.isNew)
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
                child: Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize - 6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (item.isPremium)
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
                child: Icon(
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