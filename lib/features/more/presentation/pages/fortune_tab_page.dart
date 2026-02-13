import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../chat/domain/models/recommendation_chip.dart';
import '../../../chat/domain/constants/chip_category_map.dart';

/// 운세 탭 - 검색 + 카테고리 필터 + 43+ 칩 그리드 + 인터랙티브 기능
class FortuneTabPage extends ConsumerStatefulWidget {
  const FortuneTabPage({super.key});

  @override
  ConsumerState<FortuneTabPage> createState() => _FortuneTabPageState();
}

class _FortuneTabPageState extends ConsumerState<FortuneTabPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  static const _categories = <String, String>{
    'lifestyle': '일상',
    'love': '연애',
    'career': '직업',
    'money': '재물',
    'traditional': '전통',
    'health': '건강',
    'interactive': '재미',
    'petFamily': '가족',
    'coaching': '코칭',
  };

  /// 인터랙티브 기능 카드 데이터
  static const _interactiveFeatures = [
    _InteractiveFeature(
      label: '타로 카드',
      icon: Icons.style_outlined,
      route: '/interactive/tarot',
    ),
    _InteractiveFeature(
      label: '꿈해몽',
      icon: Icons.cloud_outlined,
      route: '/interactive/dream',
    ),
    _InteractiveFeature(
      label: '관상 보기',
      icon: Icons.face_retouching_natural,
      route: '/interactive/face-reading',
    ),
    _InteractiveFeature(
      label: '걱정구슬',
      icon: Icons.bubble_chart_outlined,
      route: '/interactive/worry-bead',
    ),
  ];

  List<RecommendationChip> get _filteredChips {
    var chips = defaultChips.where((c) => c.fortuneType != 'viewAll').toList();

    // 카테고리 필터
    if (_selectedCategory != null) {
      chips = chips.where((c) {
        return getCategoryForChip(c.fortuneType) == _selectedCategory;
      }).toList();
    }

    // 검색 필터
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      chips = chips.where((c) {
        return c.label.toLowerCase().contains(query) ||
            c.fortuneType.toLowerCase().contains(query);
      }).toList();
    }

    return chips;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 헤더
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  DSSpacing.pageHorizontal,
                  DSSpacing.md,
                  DSSpacing.pageHorizontal,
                  0,
                ),
                child: Text(
                  '운세',
                  style: typography.headingLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),

            // 검색바
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  DSSpacing.pageHorizontal,
                  DSSpacing.md,
                  DSSpacing.pageHorizontal,
                  DSSpacing.sm,
                ),
                child: _buildSearchBar(colors, typography),
              ),
            ),

            // 카테고리 필터 칩
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.pageHorizontal,
                  ),
                  itemCount: _categories.length + 1, // +1 for "전체"
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: DSSpacing.xs),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildCategoryChip(
                        null,
                        '전체',
                        colors,
                        typography,
                      );
                    }
                    final entry = _categories.entries.elementAt(index - 1);
                    return _buildCategoryChip(
                      entry.key,
                      entry.value,
                      colors,
                      typography,
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: DSSpacing.md),
            ),

            // 인터랙티브 기능 캐러셀 (카테고리/검색 미적용 시)
            if (_selectedCategory == null && _searchQuery.isEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: DSSpacing.pageHorizontal,
                    bottom: DSSpacing.sm,
                  ),
                  child: Text(
                    '인터랙티브',
                    style: typography.labelMedium.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.pageHorizontal,
                    ),
                    itemCount: _interactiveFeatures.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: DSSpacing.sm),
                    itemBuilder: (context, index) {
                      final feature = _interactiveFeatures[index];
                      return _buildInteractiveCard(
                          feature, colors, typography);
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: DSSpacing.lg),
              ),
            ],

            // 칩 그리드 섹션 헤더
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: DSSpacing.pageHorizontal,
                  bottom: DSSpacing.sm,
                ),
                child: Text(
                  _selectedCategory != null
                      ? _categories[_selectedCategory] ?? '전체'
                      : _searchQuery.isNotEmpty
                          ? '검색 결과'
                          : '전체 운세',
                  style: typography.labelMedium.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // 칩 그리드
            _filteredChips.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(DSSpacing.xl),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              color: colors.textTertiary,
                              size: 48,
                            ),
                            const SizedBox(height: DSSpacing.sm),
                            Text(
                              '검색 결과가 없어요',
                              style: typography.bodyMedium.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.pageHorizontal,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: DSSpacing.sm,
                        crossAxisSpacing: DSSpacing.sm,
                        childAspectRatio: 1.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final chip = _filteredChips[index];
                          return _buildChipCard(chip, colors, typography);
                        },
                        childCount: _filteredChips.length,
                      ),
                    ),
                  ),

            // 하단 여백
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(DSColorScheme colors, DSTypographyScheme typography) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: colors.divider, width: 0.5),
      ),
      child: TextField(
        controller: _searchController,
        style: typography.bodyMedium.copyWith(color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: '운세 검색 (예: 타로, 궁합, 사주)',
          hintStyle: typography.bodyMedium.copyWith(color: colors.textTertiary),
          prefixIcon: Icon(Icons.search, color: colors.textTertiary, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child:
                      Icon(Icons.close, color: colors.textTertiary, size: 18),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildCategoryChip(
    String? category,
    String label,
    DSColorScheme colors,
    DSTypographyScheme typography,
  ) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accent.withValues(alpha: 0.15)
              : colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.full),
          border: Border.all(
            color: isSelected ? colors.accent : colors.divider,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: typography.labelMedium.copyWith(
            color: isSelected ? colors.accent : colors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveCard(
    _InteractiveFeature feature,
    DSColorScheme colors,
    DSTypographyScheme typography,
  ) {
    return GestureDetector(
      onTap: () => context.push(feature.route),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(color: colors.divider, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(feature.icon, color: colors.accent, size: 32),
            const SizedBox(height: DSSpacing.xs),
            Text(
              feature.label,
              style: typography.labelSmall.copyWith(
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipCard(
    RecommendationChip chip,
    DSColorScheme colors,
    DSTypographyScheme typography,
  ) {
    return Semantics(
      label: '${chip.label} 운세',
      button: true,
      child: GestureDetector(
        onTap: () => _navigateToFortune(chip),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.md),
            border: Border.all(color: colors.divider, width: 0.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: chip.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: Icon(chip.icon, color: chip.color, size: 24),
              ),
              const SizedBox(height: DSSpacing.xs),
              Text(
                chip.label,
                style: typography.labelSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToFortune(RecommendationChip chip) {
    // 채팅 탭으로 이동하여 칩 탭 핸들링 (기존 ChatHomePage 플로우 재사용)
    context.go('/chat?fortuneType=${chip.fortuneType}');
  }
}

class _InteractiveFeature {
  final String label;
  final IconData icon;
  final String route;

  const _InteractiveFeature({
    required this.label,
    required this.icon,
    required this.route,
  });
}
