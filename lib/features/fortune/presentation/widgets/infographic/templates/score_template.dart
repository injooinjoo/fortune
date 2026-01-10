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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 점수 원형 게이지
        _buildScoreSection(context),

        // 카테고리 막대 차트 (있는 경우)
        if (categories != null && categories!.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          _buildCategoriesSection(context),
        ],

        // 행운 아이템 또는 커스텀 위젯
        if (luckyItems != null && luckyItems!.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          _buildLuckyItemsSection(context),
        ] else if (bottomWidget != null) ...[
          const SizedBox(height: DSSpacing.lg),
          bottomWidget!,
        ],
      ],
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

  Widget _buildCategoriesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
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
        color: context.colors.surfaceSecondary.withOpacity(0.5),
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
      showStars: true,
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

/// 연애 운세용 프리셋
class LoveScoreTemplate extends StatelessWidget {
  const LoveScoreTemplate({
    super.key,
    required this.score,
    this.encounterProbability,
    this.tips,
    this.luckyPlace,
    this.date,
    this.isShareMode = false,
  });

  final int score;
  final int? encounterProbability;
  final List<String>? tips;
  final String? luckyPlace;
  final DateTime? date;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '오늘의 연애운',
      score: score,
      showStars: true,
      progressColor: Colors.pinkAccent,
      bottomWidget: _buildLoveContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildLoveContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 인연 확률
          if (encounterProbability != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '새로운 인연 확률',
                  style: context.typography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(width: DSSpacing.sm),
                Text(
                  '$encounterProbability%',
                  style: context.typography.headingMedium.copyWith(
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: DSSpacing.xs),
                Icon(
                  encounterProbability! >= 50
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 20,
                  color: encounterProbability! >= 50
                      ? context.colors.success
                      : context.colors.error,
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.md),
          ],

          // 팁 목록
          if (tips != null && tips!.isNotEmpty) ...[
            ...tips!.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 16,
                        color: context.colors.accent,
                      ),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: Text(
                          tip,
                          style: context.typography.bodySmall.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          // 행운 장소
          if (luckyPlace != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.place_rounded,
                  size: 16,
                  color: context.colors.accent,
                ),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '행운 장소: $luckyPlace',
                  style: context.typography.labelMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

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
      showStars: true,
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
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 키워드
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

          // 조언
          if (advice != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: context.colors.textTertiary,
                ),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: Text(
                    '"$advice"',
                    style: context.typography.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 메시지 전용 템플릿 (fortune-cookie 등)
class MessageScoreTemplate extends StatelessWidget {
  const MessageScoreTemplate({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.iconColor,
    this.date,
    this.isShareMode = false,
  });

  final String title;
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final DateTime? date;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return InfographicContainer(
      title: title,
      showWatermark: true,
      isShareMode: isShareMode,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아이콘
          Icon(
            icon ?? Icons.format_quote_rounded,
            size: 48,
            color: iconColor ?? context.colors.accent,
          ),
          const SizedBox(height: DSSpacing.md),

          // 메시지
          Text(
            '"$message"',
            style: context.typography.headingSmall.copyWith(
              color: context.colors.textPrimary,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
      showStars: true,
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
        color: context.colors.surfaceSecondary.withOpacity(0.5),
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
                  '행운의 날: ${luckyDayLabel ?? '${luckyDay}일'}',
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
            Text(
              '"$advice"',
              style: context.typography.bodySmall.copyWith(
                color: context.colors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
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
      showStars: true,
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
        color: context.colors.surfaceSecondary.withOpacity(0.5),
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
                  '행운의 날: ${luckyDates!.map((d) => '${d}일').join(', ')}',
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
            Text(
              '"$advice"',
              style: context.typography.bodySmall.copyWith(
                color: context.colors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
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
      showStars: true,
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
        color: context.colors.surfaceSecondary.withOpacity(0.5),
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
                color: context.colors.accent.withOpacity(0.1),
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
                  '황금기: ${luckyMonths!.map((m) => '${m}월').join(', ')}',
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
            Text(
              '"$advice"',
              style: context.typography.bodySmall.copyWith(
                color: context.colors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
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
      showStars: true,
      progressColor: Colors.indigo,
      bottomWidget: _buildExamContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildExamContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 행운 시간/과목
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
          // 팁
          if (tips != null && tips!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            ...tips!.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 14,
                        color: Colors.indigo,
                      ),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: Text(
                          tip,
                          style: context.typography.bodySmall.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
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
        color: Colors.indigo.withOpacity(0.1),
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

/// 건강 운세 프리셋
class HealthScoreTemplate extends StatelessWidget {
  const HealthScoreTemplate({
    super.key,
    required this.score,
    this.bodyParts,
    this.recommendations,
    this.warningMessage,
    this.isShareMode = false,
  });

  final int score;
  final List<HealthBodyPart>? bodyParts;
  final List<String>? recommendations;
  final String? warningMessage;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '오늘의 건강운',
      score: score,
      showStars: true,
      progressColor: Colors.green,
      bottomWidget: _buildHealthContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildHealthContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 신체 부위별
        if (bodyParts != null && bodyParts!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.surfaceSecondary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: DSSpacing.sm,
              runSpacing: DSSpacing.sm,
              alignment: WrapAlignment.center,
              children: bodyParts!.map((part) {
                return _buildBodyPartChip(context, part);
              }).toList(),
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
        ],
        // 권장사항
        if (recommendations != null && recommendations!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.surfaceSecondary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: recommendations!.map((rec) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: Text(
                          rec,
                          style: context.typography.bodySmall.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        // 경고
        if (warningMessage != null) ...[
          const SizedBox(height: DSSpacing.sm),
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: context.colors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: context.colors.warning,
                ),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: Text(
                    warningMessage!,
                    style: context.typography.labelSmall.copyWith(
                      color: context.colors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBodyPartChip(BuildContext context, HealthBodyPart part) {
    final color = part.status == HealthStatus.good
        ? Colors.green
        : part.status == HealthStatus.warning
            ? context.colors.warning
            : context.colors.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            part.status == HealthStatus.good
                ? Icons.check_circle_rounded
                : part.status == HealthStatus.warning
                    ? Icons.error_rounded
                    : Icons.cancel_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: DSSpacing.xs),
          Text(
            part.label,
            style: context.typography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 건강 신체 부위 데이터
class HealthBodyPart {
  const HealthBodyPart({
    required this.label,
    required this.status,
  });

  final String label;
  final HealthStatus status;
}

/// 건강 상태
enum HealthStatus { good, warning, danger }

/// 운동 운세 프리셋
class ExerciseScoreTemplate extends StatelessWidget {
  const ExerciseScoreTemplate({
    super.key,
    required this.score,
    this.recommendedExercise,
    this.intensity,
    this.duration,
    this.tips,
    this.isShareMode = false,
  });

  final int score;
  final String? recommendedExercise;
  final String? intensity;
  final String? duration;
  final List<String>? tips;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '오늘의 운동운',
      score: score,
      showStars: true,
      progressColor: Colors.orange,
      bottomWidget: _buildExerciseContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildExerciseContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 추천 운동
          if (recommendedExercise != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center_rounded,
                  size: 20,
                  color: Colors.orange,
                ),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  recommendedExercise!,
                  style: context.typography.headingSmall.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          // 강도/시간
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (intensity != null)
                _buildInfoChip(context, icon: Icons.speed_rounded, label: intensity!),
              if (duration != null)
                _buildInfoChip(context, icon: Icons.timer_rounded, label: duration!),
            ],
          ),
          // 팁
          if (tips != null && tips!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            ...tips!.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates_rounded,
                        size: 14,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: Text(
                          tip,
                          style: context.typography.bodySmall.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, {required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm, vertical: DSSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.orange),
          const SizedBox(width: DSSpacing.xs),
          Text(
            label,
            style: context.typography.labelSmall.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 소개팅 운세 프리셋
class BlindDateScoreTemplate extends StatelessWidget {
  const BlindDateScoreTemplate({
    super.key,
    required this.score,
    this.successRate,
    this.idealType,
    this.tips,
    this.luckyPlace,
    this.isShareMode = false,
  });

  final int score;
  final int? successRate;
  final String? idealType;
  final List<String>? tips;
  final String? luckyPlace;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '오늘의 소개팅운',
      score: score,
      showStars: true,
      progressColor: Colors.pinkAccent,
      bottomWidget: _buildContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 성공 확률
          if (successRate != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '성공 확률',
                  style: context.typography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(width: DSSpacing.sm),
                Text(
                  '$successRate%',
                  style: context.typography.headingMedium.copyWith(
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: DSSpacing.xs),
                Icon(
                  successRate! >= 50 ? Icons.trending_up_rounded : Icons.trending_flat_rounded,
                  size: 20,
                  color: successRate! >= 50 ? context.colors.success : context.colors.textTertiary,
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          // 이상형
          if (idealType != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_rounded, size: 14, color: Colors.pinkAccent),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '오늘의 이상형: $idealType',
                  style: context.typography.labelMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          // 팁
          if (tips != null && tips!.isNotEmpty) ...[
            ...tips!.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, size: 14, color: Colors.pinkAccent),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: Text(
                          tip,
                          style: context.typography.bodySmall.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          // 행운 장소
          if (luckyPlace != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.place_rounded, size: 14, color: context.colors.accent),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '추천 장소: $luckyPlace',
                  style: context.typography.labelSmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 재회 운세 프리셋
class ExLoverScoreTemplate extends StatelessWidget {
  const ExLoverScoreTemplate({
    super.key,
    required this.score,
    this.reunionProbability,
    this.currentStatus,
    this.advice,
    this.isShareMode = false,
  });

  final int score;
  final int? reunionProbability;
  final String? currentStatus;
  final String? advice;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '재회 가능성 분석',
      score: score,
      showStars: true,
      progressColor: Colors.purple,
      bottomWidget: _buildContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 재회 확률
          if (reunionProbability != null) ...[
            Column(
              children: [
                Text(
                  '재회 가능성',
                  style: context.typography.labelSmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: DSSpacing.xs),
                Text(
                  '$reunionProbability%',
                  style: context.typography.displaySmall.copyWith(
                    color: Colors.purple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          // 현재 상태
          if (currentStatus != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                currentStatus!,
                style: context.typography.labelMedium.copyWith(
                  color: Colors.purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          // 조언
          if (advice != null)
            Text(
              '"$advice"',
              style: context.typography.bodySmall.copyWith(
                color: context.colors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

/// 이사 운세 프리셋
class MovingScoreTemplate extends StatelessWidget {
  const MovingScoreTemplate({
    super.key,
    required this.score,
    this.luckyDirection,
    this.luckyDates,
    this.warnings,
    this.isShareMode = false,
  });

  final int score;
  final String? luckyDirection;
  final List<String>? luckyDates;
  final List<String>? warnings;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '이사 길일 분석',
      score: score,
      showStars: true,
      progressColor: Colors.teal,
      bottomWidget: _buildContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 행운 방향
          if (luckyDirection != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.explore_rounded, size: 20, color: Colors.teal),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '길한 방향: $luckyDirection',
                  style: context.typography.labelMedium.copyWith(
                    color: Colors.teal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          // 길일
          if (luckyDates != null && luckyDates!.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_month_rounded, size: 16, color: context.colors.accent),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '추천 일자: ${luckyDates!.join(', ')}',
                  style: context.typography.bodySmall.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          // 주의사항
          if (warnings != null && warnings!.isNotEmpty) ...[
            ...warnings!.map((warning) => Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 14, color: context.colors.warning),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: Text(
                          warning,
                          style: context.typography.bodySmall.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

/// 경계 대상 프리셋
class AvoidPeopleScoreTemplate extends StatelessWidget {
  const AvoidPeopleScoreTemplate({
    super.key,
    required this.riskScore,
    this.targetTypes,
    this.warningSignals,
    this.protectionTips,
    this.isShareMode = false,
  });

  final int riskScore;
  final List<String>? targetTypes;
  final List<String>? warningSignals;
  final List<String>? protectionTips;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '오늘의 경계 대상',
      score: riskScore,
      scoreLabel: '위험도',
      showStars: false,
      progressColor: context.colors.error,
      bottomWidget: _buildContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 경계 대상 유형
        if (targetTypes != null && targetTypes!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_off_rounded, size: 16, color: context.colors.error),
                    const SizedBox(width: DSSpacing.xs),
                    Text(
                      '주의 대상',
                      style: context.typography.labelMedium.copyWith(
                        color: context.colors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.sm),
                Wrap(
                  spacing: DSSpacing.xs,
                  runSpacing: DSSpacing.xs,
                  children: targetTypes!.map((type) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DSSpacing.sm,
                        vertical: DSSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.colors.error.withOpacity(0.3)),
                      ),
                      child: Text(
                        type,
                        style: context.typography.labelSmall.copyWith(
                          color: context.colors.error,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
        ],
        // 경고 신호
        if (warningSignals != null && warningSignals!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.surfaceSecondary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '경고 신호',
                  style: context.typography.labelMedium.copyWith(
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DSSpacing.xs),
                ...warningSignals!.map((signal) => Padding(
                      padding: const EdgeInsets.only(bottom: DSSpacing.xxs),
                      child: Row(
                        children: [
                          Icon(Icons.warning_rounded, size: 12, color: context.colors.warning),
                          const SizedBox(width: DSSpacing.xs),
                          Expanded(
                            child: Text(
                              signal,
                              style: context.typography.bodySmall.copyWith(
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
        ],
        // 보호 팁
        if (protectionTips != null && protectionTips!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_rounded, size: 16, color: context.colors.success),
                    const SizedBox(width: DSSpacing.xs),
                    Text(
                      '보호 방법',
                      style: context.typography.labelMedium.copyWith(
                        color: context.colors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.xs),
                ...protectionTips!.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: DSSpacing.xxs),
                      child: Row(
                        children: [
                          Icon(Icons.check_rounded, size: 12, color: context.colors.success),
                          const SizedBox(width: DSSpacing.xs),
                          Expanded(
                            child: Text(
                              tip,
                              style: context.typography.bodySmall.copyWith(
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// 반려동물 운세 프리셋
class PetScoreTemplate extends StatelessWidget {
  const PetScoreTemplate({
    super.key,
    required this.score,
    this.petType,
    this.matchingRate,
    this.recommendations,
    this.luckyActivity,
    this.isShareMode = false,
  });

  final int score;
  final String? petType;
  final int? matchingRate;
  final List<String>? recommendations;
  final String? luckyActivity;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '반려동물 궁합',
      score: score,
      showStars: true,
      progressColor: Colors.amber,
      bottomWidget: _buildContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 동물 타입 & 매칭율
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (petType != null) ...[
                Icon(Icons.pets_rounded, size: 20, color: Colors.amber),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  petType!,
                  style: context.typography.labelMedium.copyWith(
                    color: Colors.amber,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              if (matchingRate != null) ...[
                const SizedBox(width: DSSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.sm,
                    vertical: DSSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '궁합 $matchingRate%',
                    style: context.typography.labelSmall.copyWith(
                      color: Colors.amber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          // 권장 활동
          if (luckyActivity != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_rounded, size: 14, color: context.colors.accent),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '추천 활동: $luckyActivity',
                  style: context.typography.bodySmall.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
          // 권장사항
          if (recommendations != null && recommendations!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            ...recommendations!.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                  child: Row(
                    children: [
                      Icon(Icons.favorite_rounded, size: 12, color: Colors.amber),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: Text(
                          rec,
                          style: context.typography.bodySmall.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

/// 가족 운세 프리셋
class FamilyScoreTemplate extends StatelessWidget {
  const FamilyScoreTemplate({
    super.key,
    required this.score,
    this.familyCategories,
    this.recommendations,
    this.luckyActivity,
    this.isShareMode = false,
  });

  final int score;
  final List<CategoryData>? familyCategories;
  final List<String>? recommendations;
  final String? luckyActivity;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '오늘의 가족운',
      score: score,
      showStars: true,
      categories: familyCategories,
      progressColor: Colors.brown,
      bottomWidget: _buildContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildContent(BuildContext context) {
    if (recommendations == null && luckyActivity == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 추천 활동
          if (luckyActivity != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.family_restroom_rounded, size: 16, color: Colors.brown),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '추천: $luckyActivity',
                  style: context.typography.labelMedium.copyWith(
                    color: Colors.brown,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          // 권장사항
          if (recommendations != null && recommendations!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            ...recommendations!.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                  child: Row(
                    children: [
                      Icon(Icons.home_rounded, size: 12, color: Colors.brown),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: Text(
                          rec,
                          style: context.typography.bodySmall.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

/// 유명인 매칭 프리셋
class CelebrityScoreTemplate extends StatelessWidget {
  const CelebrityScoreTemplate({
    super.key,
    required this.score,
    required this.celebrityName,
    this.matchingPoints,
    this.description,
    this.isShareMode = false,
  });

  final int score;
  final String celebrityName;
  final List<String>? matchingPoints;
  final String? description;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '닮은꼴 유명인',
      score: score,
      scoreLabel: '일치율',
      showStars: false,
      progressColor: context.colors.accent,
      bottomWidget: _buildContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 유명인 이름
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, size: 20, color: context.colors.accent),
              const SizedBox(width: DSSpacing.xs),
              Text(
                celebrityName,
                style: context.typography.headingSmall.copyWith(
                  color: context.colors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          // 설명
          if (description != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              description!,
              style: context.typography.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          // 매칭 포인트
          if (matchingPoints != null && matchingPoints!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              alignment: WrapAlignment.center,
              children: matchingPoints!.map((point) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.sm,
                    vertical: DSSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$point',
                    style: context.typography.labelSmall.copyWith(
                      color: context.colors.accent,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// 바이오리듬 인포그래픽 프리셋
///
/// 신체/감정/지성 3개 리듬의 점수와 상태를 표시합니다.
class BiorhythmScoreTemplate extends StatelessWidget {
  const BiorhythmScoreTemplate({
    super.key,
    required this.physicalScore,
    required this.emotionalScore,
    required this.intellectualScore,
    this.physicalPhase,
    this.emotionalPhase,
    this.intellectualPhase,
    this.overallRating = 3,
    this.advice,
    this.isShareMode = false,
  });

  /// 신체 리듬 점수 (0-100)
  final int physicalScore;

  /// 감정 리듬 점수 (0-100)
  final int emotionalScore;

  /// 지성 리듬 점수 (0-100)
  final int intellectualScore;

  /// 신체 상태 (상승기, 정점, 하강기 등)
  final String? physicalPhase;

  /// 감정 상태
  final String? emotionalPhase;

  /// 지성 상태
  final String? intellectualPhase;

  /// 종합 컨디션 별점 (1-5)
  final int overallRating;

  /// 조언
  final String? advice;

  /// 공유 모드
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    // 평균 점수 계산
    final averageScore =
        ((physicalScore + emotionalScore + intellectualScore) / 3).round();

    return ScoreTemplate(
      title: '오늘의 바이오리듬',
      score: averageScore,
      scoreLabel: '종합 컨디션',
      showStars: false,
      progressColor: _getOverallColor(context, averageScore),
      bottomWidget: _buildRhythmBars(context),
      isShareMode: isShareMode,
    );
  }

  Color _getOverallColor(BuildContext context, int score) {
    if (score >= 80) return context.colors.success;
    if (score >= 60) return context.colors.accent;
    if (score >= 40) return context.colors.warning;
    return context.colors.error;
  }

  Widget _buildRhythmBars(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 3개 리듬 바
        _buildRhythmBar(
          context,
          icon: Icons.fitness_center_rounded,
          label: '신체',
          score: physicalScore,
          phase: physicalPhase,
          color: const Color(0xFFFF6B6B),
        ),
        const SizedBox(height: DSSpacing.sm),
        _buildRhythmBar(
          context,
          icon: Icons.favorite_rounded,
          label: '감정',
          score: emotionalScore,
          phase: emotionalPhase,
          color: const Color(0xFFFF69B4),
        ),
        const SizedBox(height: DSSpacing.sm),
        _buildRhythmBar(
          context,
          icon: Icons.psychology_rounded,
          label: '지성',
          score: intellectualScore,
          phase: intellectualPhase,
          color: const Color(0xFF4A90E2),
        ),

        // 종합 별점
        const SizedBox(height: DSSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '종합 컨디션',
                style: context.typography.labelSmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: DSSpacing.xxs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final isFilled = index < overallRating;
                  return Icon(
                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 24,
                    color: isFilled
                        ? context.colors.warning
                        : context.colors.textTertiary,
                  );
                }),
              ),
              // 조언
              if (advice != null) ...[
                const SizedBox(height: DSSpacing.xs),
                Text(
                  advice!,
                  style: context.typography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRhythmBar(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int score,
    String? phase,
    required Color color,
  }) {
    return Row(
      children: [
        // 아이콘 + 라벨
        SizedBox(
          width: 60,
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: context.typography.labelSmall.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // 프로그레스 바
        Expanded(
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              color: context.colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: score / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '$score%',
                    style: context.typography.labelSmall.copyWith(
                      color: score > 50
                          ? Colors.white
                          : context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 상태
        if (phase != null) ...[
          const SizedBox(width: DSSpacing.xs),
          SizedBox(
            width: 50,
            child: Text(
              phase,
              style: context.typography.labelSmall.copyWith(
                color: context.colors.textSecondary,
                fontSize: 10,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ],
    );
  }
}
