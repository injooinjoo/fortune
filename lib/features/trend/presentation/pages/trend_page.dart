import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/models/models.dart';
import '../providers/trend_providers.dart';
import '../../../../shared/components/profile_header_icon.dart';

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
    final colors = context.colors;
    final trendState = ref.watch(trendListProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: colors.accentSecondary, // Vermilion accent
          backgroundColor: colors.surface,
          onRefresh: () => ref.read(trendListProvider.notifier).refresh(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(colors),
              ),
              // Filter chips
              SliverToBoxAdapter(
                child: _buildFilterChips(colors, trendState),
              ),
              // Content list
              if (trendState.isLoading && trendState.contents.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: colors.accentSecondary,
                    ),
                  ),
                )
              else if (trendState.error != null && trendState.contents.isEmpty)
                SliverFillRemaining(
                  child: _buildErrorWidget(colors, trendState.error!),
                )
              else if (trendState.contents.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyWidget(colors),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: DSSpacing.pageHorizontal, vertical: DSSpacing.sm),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= trendState.contents.length) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(DSSpacing.md),
                              child: CircularProgressIndicator(
                                color: colors.accentSecondary,
                              ),
                            ),
                          );
                        }
                        return _buildContentCard(trendState.contents[index], colors)
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 50 * index),
                              duration: DSAnimation.durationMedium,
                            )
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

  Widget _buildHeader(DSColorScheme colors) {
    final typography = context.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.pageHorizontal, vertical: DSSpacing.sm),
      child: Row(
        children: [
          // 좌측: 프로필 아이콘
          const ProfileHeaderIcon(),
          const SizedBox(width: DSSpacing.sm),
          Text(
            '트렌드',
            style: typography.headingMedium.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.search,
              color: colors.textPrimary,
            ),
            onPressed: () {
              DSHaptics.light();
              // TODO: Search functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(DSColorScheme colors, TrendListState state) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.pageHorizontal),
        children: [
          _buildFilterChip(
            label: '전체',
            isSelected: state.selectedType == null,
            onTap: () => ref.read(trendListProvider.notifier).clearFilters(),
            colors: colors,
          ),
          const SizedBox(width: DSSpacing.sm),
          _buildFilterChip(
            label: '🧠 심리테스트',
            isSelected: state.selectedType == TrendContentType.psychologyTest,
            onTap: () => ref
                .read(trendListProvider.notifier)
                .setTypeFilter(TrendContentType.psychologyTest),
            colors: colors,
          ),
          const SizedBox(width: DSSpacing.sm),
          _buildFilterChip(
            label: '🏆 이상형 월드컵',
            isSelected: state.selectedType == TrendContentType.idealWorldcup,
            onTap: () => ref
                .read(trendListProvider.notifier)
                .setTypeFilter(TrendContentType.idealWorldcup),
            colors: colors,
          ),
          const SizedBox(width: DSSpacing.sm),
          _buildFilterChip(
            label: '⚖️ 밸런스 게임',
            isSelected: state.selectedType == TrendContentType.balanceGame,
            onTap: () => ref
                .read(trendListProvider.notifier)
                .setTypeFilter(TrendContentType.balanceGame),
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required DSColorScheme colors,
  }) {
    final typography = context.typography;
    return GestureDetector(
      onTap: () {
        DSHaptics.light();
        onTap();
      },
      child: AnimatedContainer(
        duration: DSAnimation.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm),
        decoration: BoxDecoration(
          // Korean Traditional: Vermilion for selected, hanji-like for unselected
          color: isSelected
              ? colors.accentSecondary
              : colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(DSRadius.lg),
          border: Border.all(
            color: isSelected
                ? colors.accentSecondary
                : colors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: typography.labelMedium.copyWith(
            color: isSelected
                ? Colors.white
                : colors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard(TrendContent content, DSColorScheme colors) {
    final gradients = _getGradientColors(content.type);
    final typography = context.typography;

    return Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.md),
      child: InkWell(
        onTap: () {
          DSHaptics.light();
          _navigateToContent(content);
        },
        borderRadius: BorderRadius.circular(DSRadius.lg),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradients,
            ),
            borderRadius: BorderRadius.circular(DSRadius.lg),
            // Ink-wash shadow effect
            boxShadow: [
              BoxShadow(
                color: gradients[0].withValues(alpha: 0.25),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Content
              Padding(
                padding: const EdgeInsets.all(DSSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: DSSpacing.sm + 4, vertical: DSSpacing.xs),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(DSRadius.lg),
                          ),
                          child: Text(
                            '${content.type.emoji} ${content.type.displayName}',
                            style: typography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (content.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: DSSpacing.sm, vertical: DSSpacing.xs),
                            decoration: BoxDecoration(
                              color: colors.accentTertiary, // Gold accent
                              borderRadius: BorderRadius.circular(DSRadius.sm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.white, size: 12),
                                const SizedBox(width: DSSpacing.xs),
                                Text(
                                  'PREMIUM',
                                  style: typography.labelSmall.copyWith(
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
                    const SizedBox(height: DSSpacing.md),
                    // Title and subtitle (Calligraphy style)
                    Text(
                      content.title,
                      style: typography.headingMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (content.subtitle != null) ...[
                      const SizedBox(height: DSSpacing.xs),
                      Text(
                        content.subtitle!,
                        style: typography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
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
                        const SizedBox(width: DSSpacing.md),
                        _buildStatItem(
                            Icons.favorite_outline, '${content.likeCount}'),
                      ],
                    ),
                  ],
                ),
              ),
              // Decorative elements (traditional circle motifs)
              Positioned(
                right: -20,
                bottom: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
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
                    color: Colors.white.withValues(alpha: 0.15),
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
    final typography = context.typography;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: DSSpacing.xs),
        Text(
          text,
          style: typography.labelSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Color> _getGradientColors(TrendContentType type) {
    switch (type) {
      case TrendContentType.psychologyTest:
        return [const Color(0xFF8134AF), const Color(0xFF515BD4)]; // 고유 색상: 심리테스트 브랜드 그라디언트
      case TrendContentType.idealWorldcup:
        return [const Color(0xFFF58529), const Color(0xFFDD2A7B)]; // 고유 색상: 이상형 월드컵 브랜드 그라디언트
      case TrendContentType.balanceGame:
        return [const Color(0xFF00C9B7), const Color(0xFF00B4D8)]; // 고유 색상: 밸런스 게임 브랜드 그라디언트
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

  Widget _buildErrorWidget(DSColorScheme colors, String error) {
    final typography = context.typography;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: colors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.md),
          Text(
            '콘텐츠를 불러올 수 없습니다',
            style: typography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          DSButton.secondary(
            text: '다시 시도',
            fullWidth: false,
            onPressed: () {
              DSHaptics.light();
              ref.read(trendListProvider.notifier).refresh();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(DSColorScheme colors) {
    final typography = context.typography;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🎯',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: DSSpacing.md),
          Text(
            '아직 콘텐츠가 없습니다',
            style: typography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            '곧 재미있는 콘텐츠가 추가될 예정이에요!',
            style: typography.bodySmall.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
