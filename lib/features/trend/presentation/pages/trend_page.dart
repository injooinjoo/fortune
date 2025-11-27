import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../domain/models/models.dart';
import '../providers/trend_providers.dart';

class TrendPage extends ConsumerStatefulWidget {
  const TrendPage({super.key});

  @override
  ConsumerState<TrendPage> createState() => _TrendPageState();
}

class _TrendPageState extends ConsumerState<TrendPage> {
  late ScrollController _scrollController;
  double _lastScrollOffset = 0.0;
  bool _isScrollingDown = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationVisibilityProvider.notifier).show();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentScrollPosition = _scrollController.offset;
    const scrollDownThreshold = 5.0;
    const scrollUpThreshold = 1.0;

    if (currentScrollPosition <= 10.0) {
      if (_isScrollingDown) {
        _isScrollingDown = false;
        ref.read(navigationVisibilityProvider.notifier).show();
      }
      _lastScrollOffset = currentScrollPosition;
      return;
    }

    final scrollDelta = currentScrollPosition - _lastScrollOffset;

    if (scrollDelta > scrollDownThreshold && !_isScrollingDown) {
      _isScrollingDown = true;
      ref.read(navigationVisibilityProvider.notifier).hide();
    } else if (scrollDelta < -scrollUpThreshold) {
      if (_isScrollingDown) {
        _isScrollingDown = false;
        ref.read(navigationVisibilityProvider.notifier).show();
      }
    }

    // Load more when near bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(trendListProvider.notifier).loadMore();
    }

    _lastScrollOffset = currentScrollPosition;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trendState = ref.watch(trendListProvider);

    return Scaffold(
      backgroundColor:
          isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: isDark ? TossDesignSystem.white : TossDesignSystem.tossBlue,
          backgroundColor:
              isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.white,
          onRefresh: () => ref.read(trendListProvider.notifier).refresh(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(isDark),
              ),
              // Filter chips
              SliverToBoxAdapter(
                child: _buildFilterChips(isDark, trendState),
              ),
              // Content list
              if (trendState.isLoading && trendState.contents.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (trendState.error != null && trendState.contents.isEmpty)
                SliverFillRemaining(
                  child: _buildErrorWidget(isDark, trendState.error!),
                )
              else if (trendState.contents.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyWidget(isDark),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= trendState.contents.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return _buildContentCard(trendState.contents[index], isDark)
                            .animate()
                            .fadeIn(delay: Duration(milliseconds: 50 * index))
                            .slideY(begin: 0.05, end: 0);
                      },
                      childCount: trendState.contents.length +
                          (trendState.hasMore && trendState.isLoading ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Text(
            '트렌드',
            style: TypographyUnified.heading3.copyWith(
              color: isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossDesignSystem.textPrimaryLight,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossDesignSystem.textPrimaryLight,
            ),
            onPressed: () {
              // TODO: Search functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark, TrendListState state) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip(
            label: '전체',
            isSelected: state.selectedType == null,
            onTap: () => ref.read(trendListProvider.notifier).clearFilters(),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: '🧠 심리테스트',
            isSelected: state.selectedType == TrendContentType.psychologyTest,
            onTap: () => ref
                .read(trendListProvider.notifier)
                .setTypeFilter(TrendContentType.psychologyTest),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: '🏆 이상형 월드컵',
            isSelected: state.selectedType == TrendContentType.idealWorldcup,
            onTap: () => ref
                .read(trendListProvider.notifier)
                .setTypeFilter(TrendContentType.idealWorldcup),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: '⚖️ 밸런스 게임',
            isSelected: state.selectedType == TrendContentType.balanceGame,
            onTap: () => ref
                .read(trendListProvider.notifier)
                .setTypeFilter(TrendContentType.balanceGame),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? TossDesignSystem.tossBlue
              : isDark
                  ? TossDesignSystem.grayDark700
                  : TossDesignSystem.gray200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? TossDesignSystem.tossBlue
                : isDark
                    ? TossDesignSystem.grayDark600
                    : TossDesignSystem.gray300,
          ),
        ),
        child: Text(
          label,
          style: TypographyUnified.labelMedium.copyWith(
            color: isSelected
                ? TossDesignSystem.white
                : isDark
                    ? TossDesignSystem.textSecondaryDark
                    : TossDesignSystem.textSecondaryLight,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard(TrendContent content, bool isDark) {
    final gradients = _getGradientColors(content.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToContent(content),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradients,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradients[0].withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: TossDesignSystem.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${content.type.emoji} ${content.type.displayName}',
                            style: TypographyUnified.labelSmall.copyWith(
                              color: TossDesignSystem.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (content.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.white, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  'PREMIUM',
                                  style: TypographyUnified.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Title and subtitle
                    Text(
                      content.title,
                      style: TypographyUnified.heading3.copyWith(
                        color: TossDesignSystem.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (content.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        content.subtitle!,
                        style: TypographyUnified.bodySmall.copyWith(
                          color: TossDesignSystem.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    // Stats
                    Row(
                      children: [
                        _buildStatItem(
                            Icons.people_outline, '${content.participantCount}명 참여'),
                        const SizedBox(width: 16),
                        _buildStatItem(
                            Icons.favorite_outline, '${content.likeCount}'),
                      ],
                    ),
                  ],
                ),
              ),
              // Decorative elements
              Positioned(
                right: -20,
                bottom: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TossDesignSystem.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                bottom: 30,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TossDesignSystem.white.withValues(alpha: 0.15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: TossDesignSystem.white, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: TypographyUnified.labelSmall.copyWith(
            color: TossDesignSystem.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Color> _getGradientColors(TrendContentType type) {
    switch (type) {
      case TrendContentType.psychologyTest:
        return [const Color(0xFF8134AF), const Color(0xFF515BD4)];
      case TrendContentType.idealWorldcup:
        return [const Color(0xFFF58529), const Color(0xFFDD2A7B)];
      case TrendContentType.balanceGame:
        return [const Color(0xFF00C9B7), const Color(0xFF00B4D8)];
    }
  }

  void _navigateToContent(TrendContent content) {
    switch (content.type) {
      case TrendContentType.psychologyTest:
        context.push('/trend/psychology/${content.id}');
        break;
      case TrendContentType.idealWorldcup:
        context.push('/trend/worldcup/${content.id}');
        break;
      case TrendContentType.balanceGame:
        context.push('/trend/balance/${content.id}');
        break;
    }
  }

  Widget _buildErrorWidget(bool isDark, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: isDark
                ? TossDesignSystem.textSecondaryDark
                : TossDesignSystem.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            '콘텐츠를 불러올 수 없습니다',
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossDesignSystem.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(trendListProvider.notifier).refresh(),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🎯',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 콘텐츠가 없습니다',
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossDesignSystem.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '곧 재미있는 콘텐츠가 추가될 예정이에요!',
            style: TypographyUnified.bodySmall.copyWith(
              color: isDark
                  ? TossDesignSystem.textTertiaryDark
                  : TossDesignSystem.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
