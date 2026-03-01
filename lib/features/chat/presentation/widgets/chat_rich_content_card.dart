import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../shared/widgets/smart_image.dart';
import '../../domain/models/rich_content_data.dart';
import 'chat_saju_result_card.dart';
import 'chat_tarot_result_card.dart';

/// 리치 컨텐츠 카드 위젯
///
/// RichContentType에 따라 다른 레이아웃 렌더링:
/// - imageCard: 상단 이미지 + 제목 + 설명 + 버튼
/// - actionCard: 제목 + 설명 + 버튼 행
/// - carousel: 가로 스크롤 카드
/// - statsCard: 아이콘 + 숫자 그리드
class ChatRichContentCard extends StatelessWidget {
  final RichContentData content;
  final Function(RichContentAction)? onActionTap;

  const ChatRichContentCard({
    super.key,
    required this.content,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: DSSpacing.xs,
        horizontal: DSSpacing.md,
      ),
      child: switch (content.type) {
        RichContentType.imageCard => _buildImageCard(context),
        RichContentType.actionCard => _buildActionCard(context),
        RichContentType.carousel => _buildCarousel(context),
        RichContentType.statsCard => _buildStatsCard(context),
        RichContentType.customWidget => _buildCustomWidget(context),
      },
    );
  }

  /// 커스텀 위젯 렌더링
  Widget _buildCustomWidget(BuildContext context) {
    final widgetType = content.widgetType;
    final data = content.widgetData ?? {};

    if (widgetType == null) {
      return const SizedBox.shrink();
    }

    return switch (widgetType) {
      CustomWidgetType.saju => ChatSajuResultCard(sajuData: data),
      CustomWidgetType.tarotSpread => _buildTarotWidget(context, data),
      CustomWidgetType.fiveElements => _buildFiveElementsWidget(context, data),
      CustomWidgetType.compatibilityChart =>
        _buildCompatibilityWidget(context, data),
      CustomWidgetType.fortuneGraph => _buildFortuneGraphWidget(context, data),
      CustomWidgetType.emotionChart => _buildEmotionChartWidget(context, data),
    };
  }

  /// 타로 스프레드 위젯
  Widget _buildTarotWidget(BuildContext context, Map<String, dynamic> data) {
    return ChatTarotResultCard(
      data: data,
      question: data['question'] as String?,
    );
  }

  /// 오행 차트 위젯 (향후 구현)
  Widget _buildFiveElementsWidget(
      BuildContext context, Map<String, dynamic> data) {
    // TODO: FiveElementsChartWidget 구현
    return _buildPlaceholderWidget(context, '오행 분석', Icons.pie_chart_rounded);
  }

  /// 궁합 차트 위젯 (향후 구현)
  Widget _buildCompatibilityWidget(
      BuildContext context, Map<String, dynamic> data) {
    // TODO: CompatibilityChartWidget 구현
    return _buildPlaceholderWidget(context, '궁합 분석', Icons.favorite_rounded);
  }

  /// 운세 그래프 위젯 (향후 구현)
  Widget _buildFortuneGraphWidget(
      BuildContext context, Map<String, dynamic> data) {
    // TODO: FortuneGraphWidget 구현
    return _buildPlaceholderWidget(context, '운세 그래프', Icons.show_chart_rounded);
  }

  /// 감정 차트 위젯 (향후 구현)
  Widget _buildEmotionChartWidget(
      BuildContext context, Map<String, dynamic> data) {
    // TODO: EmotionChartWidget 구현
    return _buildPlaceholderWidget(
        context, '감정 분석', Icons.sentiment_satisfied_rounded);
  }

  /// 플레이스홀더 위젯 (미구현 커스텀 위젯용)
  Widget _buildPlaceholderWidget(
      BuildContext context, String label, IconData icon) {
    final colors = context.colors;
    return DSCard(
      style: DSCardStyle.glassmorphism,
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: colors.textTertiary),
          const SizedBox(height: DSSpacing.sm),
          Text(
            label,
            style: context.bodyMedium.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: DSSpacing.xxs),
          Text(
            '준비 중입니다',
            style: context.labelSmall.copyWith(color: colors.textTertiary),
          ),
        ],
      ),
    );
  }

  /// 이미지 카드 (상단 이미지 + 제목 + 설명 + 버튼)
  Widget _buildImageCard(BuildContext context) {
    final colors = context.colors;

    return DSCard(
      style: DSCardStyle.glassmorphism,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 이미지
          if (content.hasImage)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(DSRadius.lg),
              ),
              child: SmartImage(
                path: content.imagePath!,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),

          // 컨텐츠 영역
          Padding(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                if (content.title != null)
                  Text(
                    content.title!,
                    style: context.heading3.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),

                // 부제목
                if (content.subtitle != null) ...[
                  const SizedBox(height: DSSpacing.xxs),
                  Text(
                    content.subtitle!,
                    style: context.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],

                // 설명
                if (content.description != null) ...[
                  const SizedBox(height: DSSpacing.sm),
                  Text(
                    content.description!,
                    style: context.bodyMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],

                // 액션 버튼들
                if (content.actions != null && content.actions!.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildActions(context, content.actions!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 액션 카드 (제목 + 설명 + 버튼 행)
  Widget _buildActionCard(BuildContext context) {
    final colors = context.colors;

    return DSCard(
      style: DSCardStyle.glassmorphism,
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 제목
          if (content.title != null)
            Text(
              content.title!,
              style: context.heading3.copyWith(
                color: colors.textPrimary,
              ),
            ),

          // 설명
          if (content.description != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              content.description!,
              style: context.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],

          // 액션 버튼들
          if (content.actions != null && content.actions!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildActions(context, content.actions!),
          ],
        ],
      ),
    );
  }

  /// 캐러셀 (가로 스크롤 카드)
  Widget _buildCarousel(BuildContext context) {
    final colors = context.colors;
    final items = content.carouselItems ?? [];

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 제목
        if (content.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.sm),
            child: Text(
              content.title!,
              style: context.heading3.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),

        // 가로 스크롤 카드
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: DSSpacing.sm),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildCarouselItem(context, item);
            },
          ),
        ),
      ],
    );
  }

  /// 캐러셀 아이템
  Widget _buildCarouselItem(BuildContext context, CarouselItem item) {
    final colors = context.colors;

    return GestureDetector(
      onTap: item.deepLink != null ? () => context.push(item.deepLink!) : null,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            if (item.hasImage)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(DSRadius.md),
                ),
                child: SmartImage(
                  path: item.imageUrl ?? item.imageAsset!,
                  width: 140,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),

            // 텍스트
            Padding(
              padding: const EdgeInsets.all(DSSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.title != null)
                    Text(
                      item.title!,
                      style: context.labelMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: context.labelSmall.copyWith(
                        color: colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 통계 카드 (아이콘 + 숫자 그리드)
  Widget _buildStatsCard(BuildContext context) {
    final colors = context.colors;
    final stats = content.statsItems ?? [];

    if (stats.isEmpty) return const SizedBox.shrink();

    return DSCard(
      style: DSCardStyle.glassmorphism,
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 제목
          if (content.title != null) ...[
            Text(
              content.title!,
              style: context.heading3.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],

          // 통계 그리드
          Wrap(
            spacing: DSSpacing.md,
            runSpacing: DSSpacing.md,
            children:
                stats.map((stat) => _buildStatItem(context, stat)).toList(),
          ),
        ],
      ),
    );
  }

  /// 통계 아이템
  Widget _buildStatItem(BuildContext context, StatsItem stat) {
    final colors = context.colors;
    final statColor = stat.color != null
        ? Color(int.parse(stat.color!.replaceFirst('#', '0xFF')))
        : colors.accent;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: statColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.sm),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아이콘 또는 값
          Text(
            stat.value,
            style: context.heading2.copyWith(
              color: statColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.xxs),
          // 라벨
          Text(
            stat.label,
            style: context.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 액션 버튼 빌드
  Widget _buildActions(BuildContext context, List<RichContentAction> actions) {
    final colors = context.colors;

    return Wrap(
      spacing: DSSpacing.sm,
      runSpacing: DSSpacing.sm,
      children: actions.map((action) {
        return GestureDetector(
          onTap: () {
            if (onActionTap != null) {
              onActionTap!(action);
            } else if (action.deepLink != null) {
              context.push(action.deepLink!);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.accent,
              borderRadius: BorderRadius.circular(DSRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (action.iconName != null) ...[
                  Icon(
                    _getIconFromName(action.iconName!),
                    size: 16,
                    color: colors.ctaForeground,
                  ),
                  const SizedBox(width: DSSpacing.xxs),
                ],
                Text(
                  action.label,
                  style: context.labelMedium.copyWith(
                    color: colors.ctaForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 아이콘 이름으로 IconData 반환
  IconData _getIconFromName(String iconName) {
    // 일반적인 아이콘 매핑
    return switch (iconName) {
      'arrow-right' => Icons.arrow_forward_rounded,
      'check' => Icons.check_rounded,
      'star' => Icons.star_rounded,
      'heart' => Icons.favorite_rounded,
      'share' => Icons.share_rounded,
      'bookmark' => Icons.bookmark_rounded,
      'link' => Icons.link_rounded,
      'external-link' => Icons.open_in_new_rounded,
      'refresh' => Icons.refresh_rounded,
      'plus' => Icons.add_rounded,
      'minus' => Icons.remove_rounded,
      'info' => Icons.info_outline_rounded,
      'settings' => Icons.settings_rounded,
      _ => Icons.touch_app_rounded,
    };
  }
}
