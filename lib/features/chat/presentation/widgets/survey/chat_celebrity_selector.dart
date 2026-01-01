import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../data/models/celebrity_simple.dart';
import '../../../../../presentation/providers/celebrity_provider.dart';
import '../../../../../shared/widgets/smart_image.dart';

/// 채팅 유명인 선택 위젯
/// 검색바 + 인기 연예인 2열 그리드
class ChatCelebritySelector extends ConsumerStatefulWidget {
  final void Function(Celebrity celebrity) onSelect;

  const ChatCelebritySelector({
    super.key,
    required this.onSelect,
  });

  @override
  ConsumerState<ChatCelebritySelector> createState() =>
      _ChatCelebritySelectorState();
}

class _ChatCelebritySelectorState extends ConsumerState<ChatCelebritySelector> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    if (query.isNotEmpty) {
      ref.read(celebritySearchProvider.notifier).search(query: query, limit: 20);
    } else {
      ref.read(celebritySearchProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 검색 결과 또는 인기 연예인
    final searchResults = ref.watch(celebritySearchProvider);
    final popularCelebrities = ref.watch(popularCelebritiesProvider(null));

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 320),
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 검색바
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? colors.backgroundSecondary : colors.surface,
              borderRadius: BorderRadius.circular(DSRadius.lg),
              border: Border.all(
                color: colors.textPrimary.withValues(alpha: 0.15),
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              style: typography.bodyMedium.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: '연예인 이름 검색...',
                hintStyle: typography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: colors.textSecondary,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: colors.textSecondary,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: DSSpacing.sm,
                ),
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.sm),

          // 연예인 그리드
          Expanded(
            child: _isSearching
                ? _buildSearchResults(context, searchResults)
                : _buildPopularCelebrities(context, popularCelebrities),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    AsyncValue<List<Celebrity>> searchResults,
  ) {
    final colors = context.colors;
    final typography = context.typography;

    return searchResults.when(
      data: (celebrities) {
        if (celebrities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 40,
                  color: colors.textSecondary,
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
          );
        }
        return _buildCelebrityGrid(context, celebrities);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => Center(
        child: Text(
          '검색 중 오류가 발생했어요',
          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildPopularCelebrities(
    BuildContext context,
    AsyncValue<List<Celebrity>> popularCelebrities,
  ) {
    final colors = context.colors;
    final typography = context.typography;

    return popularCelebrities.when(
      data: (celebrities) {
        if (celebrities.isEmpty) {
          return Center(
            child: Text(
              '인기 연예인을 불러오는 중...',
              style: typography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '인기 연예인 ⭐',
              style: typography.labelMedium.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            Expanded(
              child: _buildCelebrityGrid(context, celebrities),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => Center(
        child: Text(
          '연예인 목록을 불러올 수 없어요',
          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildCelebrityGrid(
    BuildContext context,
    List<Celebrity> celebrities,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        crossAxisSpacing: DSSpacing.xs,
        mainAxisSpacing: DSSpacing.xs,
      ),
      itemCount: celebrities.length,
      itemBuilder: (context, index) {
        final celebrity = celebrities[index];
        return _CelebrityCard(
          celebrity: celebrity,
          onTap: () {
            DSHaptics.light();
            widget.onSelect(celebrity);
          },
        );
      },
    );
  }
}

class _CelebrityCard extends StatelessWidget {
  final Celebrity celebrity;
  final VoidCallback onTap;

  const _CelebrityCard({
    required this.celebrity,
    required this.onTap,
  });

  Color _getTypeColor() {
    switch (celebrity.celebrityType) {
      case CelebrityType.actor:
        return const Color(0xFFE91E63);
      case CelebrityType.soloSinger:
        return const Color(0xFF9C27B0);
      case CelebrityType.idolMember:
        return const Color(0xFF673AB7);
      case CelebrityType.athlete:
        return const Color(0xFF2196F3);
      case CelebrityType.streamer:
        return const Color(0xFF00BCD4);
      case CelebrityType.proGamer:
        return const Color(0xFF009688);
      case CelebrityType.politician:
        return const Color(0xFF607D8B);
      case CelebrityType.business:
        return const Color(0xFF795548);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.xs,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isDark ? colors.backgroundSecondary : colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.md),
            border: Border.all(
              color: colors.textPrimary.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              // 아바타
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getTypeColor().withValues(alpha: 0.15),
                  border: Border.all(
                    color: _getTypeColor().withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: celebrity.characterImageUrl != null
                      ? SmartImage(
                          path: celebrity.characterImageUrl!,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorWidget: _buildDefaultAvatar(),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
              const SizedBox(width: DSSpacing.xs),
              // 이름 및 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      celebrity.displayName,
                      style: typography.labelMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        celebrity.celebrityType.displayName,
                        style: typography.labelSmall.copyWith(
                          color: _getTypeColor(),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: _getTypeColor().withValues(alpha: 0.2),
      child: Icon(
        Icons.person,
        size: 20,
        color: _getTypeColor(),
      ),
    );
  }
}
