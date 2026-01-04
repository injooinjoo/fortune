import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';

/// 부적 결과 카드 (이미지 중심 UI)
/// Gemini 2.0 Flash로 생성된 부적 이미지 + 100자 설명 표시
class ChatTalismanResultCard extends ConsumerWidget {
  final String imageUrl;
  final String categoryName;
  final String shortDescription;
  final bool isBlurred;

  const ChatTalismanResultCard({
    super.key,
    required this.imageUrl,
    required this.categoryName,
    required this.shortDescription,
    this.isBlurred = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;

    return Stack(
      children: [
        Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.xl),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: UnifiedBlurWrapper(
        isBlurred: isBlurred,
        blurredSections: isBlurred ? const ['talisman'] : const [],
        sectionKey: 'talisman',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 부적 이미지 (9:16 비율)
            _buildTalismanImage(context),

            // 하단 정보
            Padding(
              padding: const EdgeInsets.all(DSSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 카테고리 태그
                  _buildCategoryTag(context),
                  const SizedBox(height: DSSpacing.md),

                  // 짧은 설명 (효능 + 사용법)
                  Text(
                    shortDescription,
                    style: typography.bodyMedium.copyWith(
                      color: colors.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    // 좋아요 + 공유 버튼 (우상단)
    Positioned(
          top: DSSpacing.sm,
          right: DSSpacing.sm + DSSpacing.md,
          child: FortuneActionButtons(
            contentId: 'talisman_${DateTime.now().millisecondsSinceEpoch}',
            contentType: 'talisman',
            shareTitle: categoryName,
            shareContent: shortDescription,
            iconSize: 20,
            iconColor: colors.textPrimary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// 부적 이미지 (9:16 비율, ClipRRect)
  Widget _buildTalismanImage(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(DSRadius.xl),
        topRight: Radius.circular(DSRadius.xl),
      ),
      child: AspectRatio(
        aspectRatio: 9 / 16, // 세로로 긴 부적 이미지
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildShimmer(context),
          errorWidget: (context, url, error) => _buildFallback(context),
        ),
      ),
    );
  }

  /// 카테고리 태그
  Widget _buildCategoryTag(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🔮',
            style: typography.labelMedium,
          ),
          const SizedBox(width: DSSpacing.xs),
          Text(
            categoryName,
            style: typography.labelMedium.copyWith(
              color: colors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 로딩 shimmer
  Widget _buildShimmer(BuildContext context) {
    final colors = context.colors;

    return Container(
      color: colors.backgroundSecondary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
            Text(
              '부적을 그리고 있어요...',
              style: context.typography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 에러 fallback
  Widget _buildFallback(BuildContext context) {
    final colors = context.colors;

    return Container(
      color: colors.backgroundSecondary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: colors.textTertiary,
            ),
            const SizedBox(height: DSSpacing.md),
            Text(
              '이미지를 불러올 수 없어요',
              style: context.typography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
