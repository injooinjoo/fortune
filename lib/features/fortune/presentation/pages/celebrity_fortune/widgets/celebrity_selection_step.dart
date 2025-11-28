import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/toss_theme.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../data/models/celebrity_simple.dart';
import '../../../../../../presentation/providers/celebrity_provider.dart';
import '../../../../../../core/utils/logger.dart';
import '../../../widgets/fortune_loading_skeleton.dart';
import '../../../widgets/fortune_card.dart';
import '../../../../../../core/widgets/unified_button.dart';

class CelebritySelectionStep extends ConsumerStatefulWidget {
  final CelebrityType? selectedCategory;
  final Celebrity? selectedCelebrity;
  final ValueChanged<Celebrity?> onCelebritySelected;

  const CelebritySelectionStep({
    super.key,
    required this.selectedCategory,
    required this.selectedCelebrity,
    required this.onCelebritySelected,
  });

  @override
  ConsumerState<CelebritySelectionStep> createState() => _CelebritySelectionStepState();
}

class _CelebritySelectionStepState extends ConsumerState<CelebritySelectionStep> {
  final _searchController = TextEditingController();
  List<Celebrity> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final searchNotifier = ref.read(celebritySearchProvider.notifier);
    await searchNotifier.search(query: query, limit: 20);

    final searchResults = ref.read(celebritySearchProvider);
    searchResults.when(
      data: (results) {
        setState(() {
          _searchResults = results;
        });
      },
      loading: () {},
      error: (error, stack) {
        Logger.error('Celebrity search failed', error);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final celebritiesAsyncValue = widget.selectedCategory != null
        ? ref.watch(celebritiesByCategoryProvider(widget.selectedCategory!))
        : ref.watch(allCelebritiesProvider);

    return celebritiesAsyncValue.when(
      data: (celebrities) => _buildContent(celebrities),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildContent(List<Celebrity> celebrities) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayCelebrities = _searchResults.isNotEmpty
        ? _searchResults.take(20).toList()
        : celebrities.take(20).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '궁합을 보고 싶은\n유명인을 선택해주세요',
            style: TypographyUnified.heading1.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '선택한 유명인과의 운세를 분석해드려요',
            style: TypographyUnified.bodySmall.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          // Search bar
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              style: TypographyUnified.bodySmall.copyWith(
                color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
              ),
              decoration: InputDecoration(
                hintText: '이름으로 검색',
                hintStyle: TypographyUnified.bodySmall.copyWith(
                  color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray400,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray400,
                  size: 20,
                ),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                _performSearch(value);
              },
            ),
          ),
          const SizedBox(height: 20),

          // Celebrity grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: displayCelebrities.length,
            itemBuilder: (context, index) {
              final celebrity = displayCelebrities[index];
              final isSelected = widget.selectedCelebrity?.id == celebrity.id;

              return CelebrityGridItem(
                celebrity: celebrity,
                isSelected: isSelected,
                onTap: () => widget.onCelebritySelected(celebrity),
              );
            },
          ),
          const SizedBox(height: 100), // 버튼 높이만큼 여백
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1);
  }

  Widget _buildLoadingState() {
    return FortuneLoadingSkeleton(
      itemCount: 2,
      showHeader: false,
      loadingMessages: [
        '유명인 정보를 불러오고 있어요...',
        '데이터베이스에서 검색 중...',
        '인기 유명인을 찾는 중...',
      ],
    );
  }

  Widget _buildErrorState(dynamic error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: FortuneCard(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
            ),
            SizedBox(height: 24),
            Text(
              '유명인 정보를 불러올 수 없어요',
              style: TypographyUnified.heading4.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              '잠시 후 다시 시도해주세요',
              style: TypographyUnified.bodySmall.copyWith(
                color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            UnifiedButton.retry(
              onPressed: () {
                ref.invalidate(allCelebritiesProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CelebrityGridItem extends StatelessWidget {
  final Celebrity celebrity;
  final bool isSelected;
  final VoidCallback onTap;

  const CelebrityGridItem({
    super.key,
    required this.celebrity,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? TossTheme.primaryBlue.withValues(alpha: 0.08) : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundWhite),
          border: Border.all(
            color: isSelected ? TossTheme.primaryBlue : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Celebrity avatar
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: _getCelebrityColor(celebrity.name),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      celebrity.name.substring(0, 1),
                      style: TypographyUnified.displayLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: TossDesignSystem.white,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: TossDesignSystem.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: TossTheme.primaryBlue,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Celebrity info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      celebrity.name,
                      style: TypographyUnified.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? TossTheme.primaryBlue : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      celebrity.celebrityType.displayName,
                      style: TypographyUnified.labelMedium.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray500,
                      ),
                    ),
                    ...[
                    SizedBox(height: 2),
                    Text(
                      '${celebrity.age}세',
                      style: TypographyUnified.labelMedium.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray400,
                      ),
                    ),
                  ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCelebrityColor(String name) {
    final colors = [
      Color(0xFFFF6B6B), Color(0xFF4ECDC4), Color(0xFF45B7D1),
      Color(0xFF96CEB4), Color(0xFFDDA0DD), Color(0xFFFFD93D),
      Color(0xFF6C5CE7), Color(0xFFFD79A8), Color(0xFF00B894),
    ];
    return colors[name.hashCode % colors.length];
  }
}
