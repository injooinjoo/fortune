import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/design_system/tokens/ds_fortune_colors.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../shared/widgets/smart_image.dart';
import '../../../../core/theme/font_config.dart';
import '../../domain/entities/fortune_category.dart';
import '../providers/fortune_search_provider.dart';

/// 운세 검색 오버레이 페이지
class FortuneSearchOverlay extends ConsumerStatefulWidget {
  final List<FortuneCategory> categories;

  const FortuneSearchOverlay({
    super.key,
    required this.categories,
  });

  @override
  ConsumerState<FortuneSearchOverlay> createState() =>
      _FortuneSearchOverlayState();
}

class _FortuneSearchOverlayState extends ConsumerState<FortuneSearchOverlay> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 자동 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hanjiBackground = DSFortuneColors.getHanjiBackground(isDark);
    final inkColor = DSFortuneColors.getInk(isDark);
    final primaryColor = DSFortuneColors.getPrimary(isDark);
    final colors = context.colors;

    final searchState =
        ref.watch(fortuneSearchProvider(widget.categories));

    return Scaffold(
      backgroundColor: hanjiBackground,
      appBar: AppBar(
        backgroundColor: hanjiBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: inkColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          '검색',
          style: TextStyle(
            fontFamily: FontConfig.primary,
            fontSize: FontConfig.heading4,
            fontWeight: FontWeight.w700,
            color: inkColor,
          ),
        ),
      ),
      body: Column(
        children: [
          // 검색바
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: (value) {
                  ref
                      .read(fortuneSearchProvider(widget.categories).notifier)
                      .search(value);
                },
                style: TextStyle(
                  fontFamily: FontConfig.primary,
                  fontSize: FontConfig.bodyMedium,
                  color: inkColor,
                ),
                decoration: InputDecoration(
                  hintText: '운세를 검색하세요',
                  hintStyle: TextStyle(
                    fontFamily: FontConfig.primary,
                    fontSize: FontConfig.bodyMedium,
                    color: inkColor.withValues(alpha: 0.4),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: primaryColor.withValues(alpha: 0.6),
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: inkColor.withValues(alpha: 0.5),
                          ),
                          onPressed: () {
                            _controller.clear();
                            ref
                                .read(fortuneSearchProvider(widget.categories)
                                    .notifier)
                                .clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // 검색 결과
          Expanded(
            child: searchState.results.isEmpty
                ? _buildEmptyResult(inkColor)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 32),
                    itemCount: searchState.results.length,
                    itemBuilder: (context, index) {
                      final category = searchState.results[index];
                      return _buildSearchResultTile(
                        context,
                        category,
                        colors,
                        inkColor,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 빈 결과 UI
  Widget _buildEmptyResult(Color inkColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: inkColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              fontFamily: FontConfig.primary,
              fontSize: FontConfig.bodyMedium,
              color: inkColor.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 검색 결과 타일 (FortuneListTile 단순화 버전)
  Widget _buildSearchResultTile(
    BuildContext context,
    FortuneCategory category,
    DSColorScheme colors,
    Color inkColor,
  ) {
    return Material(
      color: colors.surface,
      child: InkWell(
        onTap: () {
          // 검색 결과 선택 햅틱
          ref.read(fortuneHapticServiceProvider).selection();

          // 검색 오버레이 닫고 해당 운세로 이동
          Navigator.of(context).pop();
          context.push(category.route);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // 아이콘
              if (category.iconAsset != null)
                CircularSmartImage(
                  path: category.iconAsset!,
                  size: 40,
                )
              else
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          FortuneCardImages.getGradientColors(category.type),
                    ),
                  ),
                  child: Icon(
                    category.icon,
                    size: 20,
                    color: Colors.white,
                  ),
                ),

              const SizedBox(width: 16),

              // 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: DSTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.description,
                      style: DSTypography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // 화살표
              Icon(
                Icons.chevron_right_rounded,
                color: inkColor.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
