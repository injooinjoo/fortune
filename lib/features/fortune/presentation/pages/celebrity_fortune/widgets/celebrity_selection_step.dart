import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
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
    final colors = context.colors;
    final displayCelebrities = _searchResults.isNotEmpty
        ? _searchResults
        : celebrities;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '궁합을 보고 싶은\n유명인을 선택해주세요',
            style: DSTypography.headingLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '선택한 유명인과의 운세를 분석해드려요',
            style: DSTypography.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          // Search bar
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              style: DSTypography.bodySmall.copyWith(
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '이름으로 검색',
                hintStyle: DSTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: colors.textSecondary,
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
    return const FortuneLoadingSkeleton(
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
    final colors = context.colors;
    return Center(
      child: FortuneCard(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              '유명인 정보를 불러올 수 없어요',
              style: DSTypography.headingSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '잠시 후 다시 시도해주세요',
              style: DSTypography.bodySmall.copyWith(
                color: colors.textSecondary,
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
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? colors.accent.withValues(alpha: 0.08) : colors.surface,
          border: Border.all(
            color: isSelected ? colors.accent : colors.border,
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
                color: celebrity.characterImageUrl != null
                    ? colors.backgroundSecondary
                    : _getCelebrityColor(celebrity.name),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: celebrity.characterImageUrl != null
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Image.network(
                              celebrity.characterImageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Text(
                                celebrity.name.substring(0, 1),
                                style: DSTypography.displayLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            celebrity.name.substring(0, 1),
                            style: DSTypography.displayLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: colors.accent,
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
                      celebrity.displayName,
                      style: DSTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? colors.accent : colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      celebrity.celebrityType.displayName,
                      style: DSTypography.labelMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    ...[
                    const SizedBox(height: 2),
                    Text(
                      '${celebrity.age}세',
                      style: DSTypography.labelMedium.copyWith(
                        color: colors.textSecondary,
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
      const Color(0xFFFF6B6B), const Color(0xFF4ECDC4), const Color(0xFF45B7D1),
      const Color(0xFF96CEB4), const Color(0xFFDDA0DD), const Color(0xFFFFD93D),
      const Color(0xFF6C5CE7), const Color(0xFFFD79A8), const Color(0xFF00B894),
    ];
    return colors[name.hashCode % colors.length];
  }
}
