import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/category_bar_chart.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/lucky_item_row.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/advice_tag.dart';
import '../score_template.dart';

/// 일일 운세용 프리셋
class DailyScoreTemplate extends StatelessWidget {
  const DailyScoreTemplate({
    super.key,
    required this.score,
    required this.categories,
    this.luckyColor,
    this.luckyColorValue,
    this.luckyNumber,
    this.luckyTime,
    this.date,
    this.isShareMode = false,
  });

  final int score;
  final List<CategoryData> categories;
  final String? luckyColor;
  final Color? luckyColorValue;
  final int? luckyNumber;
  final String? luckyTime;
  final DateTime? date;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '오늘의 인사이트',
      score: score,
      showStars: false,
      categories: categories,
      luckyItems: DailyLuckyItems.fromData(
        colorName: luckyColor,
        colorValue: luckyColorValue,
        luckyNumber: luckyNumber,
        luckyTime: luckyTime,
      ),
      isShareMode: isShareMode,
    );
  }
}

/// 주간 운세 프리셋
class WeeklyScoreTemplate extends StatelessWidget {
  const WeeklyScoreTemplate({
    super.key,
    required this.score,
    required this.weekRange,
    this.categories,
    this.luckyDay,
    this.luckyDayLabel,
    this.advice,
    this.isShareMode = false,
  });

  final int score;
  final String weekRange;
  final List<CategoryData>? categories;
  final int? luckyDay;
  final String? luckyDayLabel;
  final String? advice;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '주간 인사이트',
      subtitle: weekRange,
      score: score,
      showStars: false,
      categories: categories,
      bottomWidget: _buildWeeklyContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildWeeklyContent(BuildContext context) {
    if (luckyDay == null && advice == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (luckyDay != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: context.colors.accent,
                ),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '행운의 날: ${luckyDayLabel ?? '$luckyDay일'}',
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
              size: AdviceTagSize.small,
              showQuotes: true,
              animate: !isShareMode,
            ),
          ],
        ],
      ),
    );
  }
}

/// 월간 운세 프리셋
class MonthlyScoreTemplate extends StatelessWidget {
  const MonthlyScoreTemplate({
    super.key,
    required this.score,
    required this.monthLabel,
    this.categories,
    this.luckyDates,
    this.advice,
    this.isShareMode = false,
  });

  final int score;
  final String monthLabel;
  final List<CategoryData>? categories;
  final List<int>? luckyDates;
  final String? advice;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '월간 인사이트',
      subtitle: monthLabel,
      score: score,
      showStars: false,
      categories: categories,
      bottomWidget: _buildMonthlyContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildMonthlyContent(BuildContext context) {
    if (luckyDates == null && advice == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (luckyDates != null && luckyDates!.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: context.colors.accent,
                ),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '행운의 날: ${luckyDates!.map((d) => '$d일').join(', ')}',
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
              size: AdviceTagSize.small,
              showQuotes: true,
              animate: !isShareMode,
            ),
          ],
        ],
      ),
    );
  }
}

/// 연간 운세 프리셋
class YearlyScoreTemplate extends StatelessWidget {
  const YearlyScoreTemplate({
    super.key,
    required this.score,
    required this.yearLabel,
    this.categories,
    this.luckyMonths,
    this.yearKeyword,
    this.advice,
    this.isShareMode = false,
  });

  final int score;
  final String yearLabel;
  final List<CategoryData>? categories;
  final List<int>? luckyMonths;
  final String? yearKeyword;
  final String? advice;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '연간 인사이트',
      subtitle: yearLabel,
      score: score,
      showStars: false,
      categories: categories,
      bottomWidget: _buildYearlyContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildYearlyContent(BuildContext context) {
    if (luckyMonths == null && yearKeyword == null && advice == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (yearKeyword != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: context.colors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '#$yearKeyword',
                style: context.typography.labelMedium.copyWith(
                  color: context.colors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          if (luckyMonths != null && luckyMonths!.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.celebration_rounded,
                  size: 16,
                  color: context.colors.accent,
                ),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '황금기: ${luckyMonths!.map((m) => '$m월').join(', ')}',
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
              size: AdviceTagSize.small,
              showQuotes: true,
              animate: !isShareMode,
            ),
          ],
        ],
      ),
    );
  }
}
