import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/infographic_container.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/score_circle.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/category_bar_chart.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/lucky_item_row.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/privacy_shield.dart';

/// 점수 중심 인포그래픽 템플릿 (템플릿 A)
///
/// 18개 운세 타입에 사용:
/// - daily_calendar, weekly, monthly, yearly
/// - love, career, exam, health, exercise
/// - blind_date, ex_lover, moving, avoid-people
/// - pet, family, celebrity, fortune-cookie
///
/// 레이아웃:
/// - 상단: 원형 점수 게이지
/// - 중간: 카테고리 막대 차트 (선택)
/// - 하단: 행운 아이템 (선택)
class ScoreTemplate extends StatelessWidget {
  const ScoreTemplate({
    super.key,
    required this.title,
    required this.score,
    this.subtitle,
    this.maxScore = 100,
    this.showStars = true,
    this.starCount = 5,
    this.percentile,
    this.categories,
    this.luckyItems,
    this.keyPoints,
    this.bottomWidget,
    this.scoreLabel,
    this.showWatermark = true,
    this.isShareMode = false,
    this.animate = true,
    this.progressColor,
    this.backgroundColor,
  });

  /// 제목
  final String title;

  /// 부제목 (선택)
  final String? subtitle;

  /// 종합 점수
  final int score;

  /// 최대 점수
  final int maxScore;

  /// 별점 표시 여부
  final bool showStars;

  /// 별 개수
  final int starCount;

  /// 상위 퍼센타일 (선택)
  final int? percentile;

  /// 카테고리 목록 (선택)
  final List<CategoryData>? categories;

  /// 행운 아이템 목록 (선택)
  final List<LuckyItem>? luckyItems;

  /// 키포인트 태그 목록 (선택, 시험운 등에서 사용)
  final List<String>? keyPoints;

  /// 하단 커스텀 위젯 (선택, luckyItems 대신 사용)
  final Widget? bottomWidget;

  /// 점수 라벨 (기본: 점수 숫자만)
  final String? scoreLabel;

  /// 워터마크 표시 여부
  final bool showWatermark;

  /// 공유 모드 (개인정보 숨김)
  final bool isShareMode;

  /// 애니메이션 활성화
  final bool animate;

  /// 진행 원 색상 (선택)
  final Color? progressColor;

  /// 배경색 (선택)
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return PrivacyModeProvider(
      isShareMode: isShareMode,
      child: InfographicContainer(
        title: title,
        subtitle: subtitle,
        showWatermark: showWatermark,
        isShareMode: isShareMode,
        backgroundColor: backgroundColor,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 점수 원형 게이지
          _buildScoreSection(context),

          // 키포인트 태그 (있는 경우)
          if (keyPoints != null && keyPoints!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildKeyPointsSection(context),
          ],

          // 카테고리 막대 차트 (있는 경우)
          if (categories != null && categories!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildCategoriesSection(context),
          ],

          // 행운 아이템 또는 커스텀 위젯
          if (luckyItems != null && luckyItems!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildLuckyItemsSection(context),
          ] else if (bottomWidget != null) ...[
            const SizedBox(height: DSSpacing.md),
            bottomWidget!,
          ],
        ],
      ),
    );
  }

  Widget _buildScoreSection(BuildContext context) {
    return ScoreCircle(
      score: score,
      maxScore: maxScore,
      size: 140,
      showStars: showStars,
      starCount: starCount,
      percentile: percentile,
      animate: animate,
      progressColor: progressColor,
      label: scoreLabel,
    );
  }

  Widget _buildKeyPointsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 섹션 타이틀
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 16,
                color: progressColor ?? context.colors.accent,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '오늘의 키포인트',
                style: context.typography.labelMedium.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          // 키포인트 태그
          Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xs,
            alignment: WrapAlignment.center,
            children: keyPoints!.map((point) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: DSSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: (progressColor ?? context.colors.accent)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DSSpacing.sm),
                  border: Border.all(
                    color: (progressColor ?? context.colors.accent)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  point,
                  style: context.typography.labelSmall.copyWith(
                    color: progressColor ?? context.colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CategoryBarChart(
        categories: categories!,
        maxValue: maxScore,
        barHeight: 8,
        showValues: true,
        showIcons: true,
        animate: animate,
      ),
    );
  }

  Widget _buildLuckyItemsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 섹션 타이틀
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: context.colors.accent,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '오늘의 행운',
                style: context.typography.labelMedium.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          // 행운 아이템
          LuckyItemRow(
            items: luckyItems!,
            spacing: DSSpacing.sm,
            wrap: true,
            alignment: WrapAlignment.center,
          ),
        ],
      ),
    );
  }
}
