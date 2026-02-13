import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/category_bar_chart.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/tip_tag_grid.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/advice_tag.dart';
import '../score_template.dart';

/// 직업 운세용 프리셋
class CareerScoreTemplate extends StatelessWidget {
  const CareerScoreTemplate({
    super.key,
    required this.score,
    this.percentile,
    this.employmentScore,
    this.businessScore,
    this.promotionScore,
    this.jobChangeScore,
    this.keywords,
    this.advice,
    this.date,
    this.isShareMode = false,
  });

  final int score;
  final int? percentile;
  final int? employmentScore;
  final int? businessScore;
  final int? promotionScore;
  final int? jobChangeScore;
  final List<String>? keywords;
  final String? advice;
  final DateTime? date;
  final bool isShareMode;

  List<CategoryData> _buildCategories() {
    final categories = <CategoryData>[];

    if (employmentScore != null) {
      categories.add(CategoryData(
        label: '취업',
        value: employmentScore!,
        icon: Icons.work_outline_rounded,
      ));
    }

    if (businessScore != null) {
      categories.add(CategoryData(
        label: '사업',
        value: businessScore!,
        icon: Icons.business_center_rounded,
      ));
    }

    if (promotionScore != null) {
      categories.add(CategoryData(
        label: '승진',
        value: promotionScore!,
        icon: Icons.trending_up_rounded,
      ));
    }

    if (jobChangeScore != null) {
      categories.add(CategoryData(
        label: '이직',
        value: jobChangeScore!,
        icon: Icons.swap_horiz_rounded,
      ));
    }

    return categories;
  }

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '오늘의 직업운',
      score: score,
      percentile: percentile,
      showStars: false,
      categories: _buildCategories(),
      bottomWidget: _buildCareerContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildCareerContent(BuildContext context) {
    if (keywords == null && advice == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (keywords != null && keywords!.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.tag_rounded,
                  size: 16,
                  color: context.colors.accent,
                ),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  keywords!.map((k) => '#$k').join('  '),
                  style: context.typography.labelMedium.copyWith(
                    color: context.colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (advice != null) ...[
            const SizedBox(height: DSSpacing.sm),
            AdviceTag.fromText(
              advice!,
              size: AdviceTagSize.medium,
              showQuotes: true,
              animate: !isShareMode,
            ),
          ],
        ],
      ),
    );
  }
}

/// 시험 운세 프리셋
class ExamScoreTemplate extends StatelessWidget {
  const ExamScoreTemplate({
    super.key,
    required this.score,
    this.percentile,
    this.luckyTime,
    this.luckySubject,
    this.tips,
    this.isShareMode = false,
  });

  final int score;
  final int? percentile;
  final String? luckyTime;
  final String? luckySubject;
  final List<String>? tips;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '오늘의 시험운',
      score: score,
      percentile: percentile,
      showStars: false,
      progressColor: Colors.indigo,
      bottomWidget: _buildExamContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildExamContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (luckyTime != null)
                _buildInfoChip(
                  context,
                  icon: Icons.access_time_rounded,
                  label: luckyTime!,
                ),
              if (luckySubject != null)
                _buildInfoChip(
                  context,
                  icon: Icons.school_rounded,
                  label: luckySubject!,
                ),
            ],
          ),
          if (tips != null && tips!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            TipTagGrid(
              tips: TipTextMapper.mapTips(tips!),
              maxVisibleTags: 4,
              animate: !isShareMode,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.indigo.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.indigo),
          const SizedBox(width: DSSpacing.xs),
          Text(
            label,
            style: context.typography.labelSmall.copyWith(
              color: Colors.indigo,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
