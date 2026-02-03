import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/tokens/ds_fortune_colors.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/infographic_container.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/score_circle.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/category_bar_chart.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/lucky_item_row.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/privacy_shield.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/tip_tag_grid.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/advice_tag.dart';

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
        color: context.colors.surfaceSecondary.withOpacity(0.5),
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

/// 연애 운세용 프리셋
class LoveScoreTemplate extends StatelessWidget {
  const LoveScoreTemplate({
    super.key,
    required this.score,
    this.encounterProbability,
    this.tips,
    this.luckyPlace,
    this.luckyColor,
    this.luckyTime,
    this.luckyItem,
    this.date,
    this.isShareMode = false,
  });

  final int score;
  final int? encounterProbability;
  final List<String>? tips;
  final String? luckyPlace;
  final String? luckyColor;
  final String? luckyTime;
  final String? luckyItem;
  final DateTime? date;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '오늘의 연애운',
      score: score,
      showStars: false,
      progressColor: Colors.pinkAccent,
      bottomWidget: _buildLoveContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildLoveContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
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
                const Icon(Icons.favorite_rounded, size: 16, color: Colors.pinkAccent),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '새로운 인연 확률',
                  style: context.typography.labelMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(width: DSSpacing.sm),
                Text(
                  '$encounterProbability%',
                  style: context.typography.headingSmall.copyWith(
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
          ],

          // 2x2 럭키 아이템 그리드
          Row(
            children: [
              // 행운 색상
              Expanded(
                child: _buildLuckyCell(
                  context,
                  icon: Icons.palette_rounded,
                  label: '행운 색상',
                  value: luckyColor ?? '-',
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              // 행운 시간
              Expanded(
                child: _buildLuckyCell(
                  context,
                  icon: Icons.schedule_rounded,
                  label: '행운 시간',
                  value: luckyTime ?? '-',
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          Row(
            children: [
              // 행운 아이템
              Expanded(
                child: _buildLuckyCell(
                  context,
                  icon: Icons.auto_awesome_rounded,
                  label: '행운 아이템',
                  value: luckyItem ?? '-',
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              // 행운 장소
              Expanded(
                child: _buildLuckyCell(
                  context,
                  icon: Icons.place_rounded,
                  label: '행운 장소',
                  value: luckyPlace ?? '-',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyCell(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.pinkAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: Colors.pinkAccent),
              const SizedBox(width: 4),
              Text(
                label,
                style: context.typography.labelSmall.copyWith(
                  color: context.colors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: context.typography.labelMedium.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
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

          // 조언 태그 (텍스트 잘림 방지)
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
          // 조언 태그 (텍스트 잘림 방지)
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
          // 조언 태그 (텍스트 잘림 방지)
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
          // 조언 태그 (텍스트 잘림 방지)
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
          // 팁 태그 그리드 (텍스트 잘림 방지)
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
      showStars: false,
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
        // 권장사항 태그 그리드 (텍스트 잘림 방지)
        if (recommendations != null && recommendations!.isNotEmpty) ...[
          TipTagGrid(
            tips: TipTextMapper.mapTips(recommendations!),
            maxVisibleTags: 4,
            animate: !isShareMode,
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
      showStars: false,
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
          // 팁 태그 그리드 (텍스트 잘림 방지)
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
    this.keyPoints,
    this.summary,
    this.overallAdvice,
    this.isShareMode = false,
  });

  final int score;
  final int? successRate;
  final String? idealType;
  final List<String>? tips;
  final String? luckyPlace;

  /// 핵심 키포인트 3개 (점수 아래 표시)
  final List<String>? keyPoints;

  /// 한줄 요약 (점수 바로 아래)
  final String? summary;

  /// 종합 조언 (하단 하이라이트 박스)
  final String? overallAdvice;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '오늘의 소개팅운',
      score: score,
      showStars: false,
      progressColor: Colors.pinkAccent,
      bottomWidget: _buildContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 한줄 요약 (점수 바로 아래)
        if (summary != null && summary!.isNotEmpty) ...[
          _buildSummarySection(context),
          const SizedBox(height: DSSpacing.md),
        ],

        // 키포인트 3개
        if (keyPoints != null && keyPoints!.isNotEmpty) ...[
          _buildKeyPointsSection(context),
          const SizedBox(height: DSSpacing.md),
        ],

        // 종합 조언 하이라이트 박스
        if (overallAdvice != null && overallAdvice!.isNotEmpty) ...[
          _buildOverallAdviceSection(context),
          const SizedBox(height: DSSpacing.md),
        ],

        // 성공 예측 & 상세 정보
        Container(
          padding: const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
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
                    const Icon(Icons.emoji_events_rounded, size: 18, color: Colors.pinkAccent),
                    const SizedBox(width: DSSpacing.xs),
                    Text(
                      '성공 예측',
                      style: context.typography.labelMedium.copyWith(
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w600,
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
                      successRate! >= 50
                          ? Icons.trending_up_rounded
                          : Icons.trending_flat_rounded,
                      size: 20,
                      color: successRate! >= 50
                          ? context.colors.success
                          : context.colors.textTertiary,
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
                    const Icon(Icons.favorite_rounded, size: 14, color: Colors.pinkAccent),
                    const SizedBox(width: DSSpacing.xs),
                    Flexible(
                      child: Text(
                        '오늘의 이상형: $idealType',
                        style: context.typography.labelMedium.copyWith(
                          color: context.colors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.sm),
              ],
              // 팁 태그 그리드 (텍스트 잘림 방지)
              if (tips != null && tips!.isNotEmpty) ...[
                TipTagGrid(
                  tips: TipTextMapper.mapTips(tips!),
                  maxVisibleTags: 4,
                  animate: !isShareMode,
                ),
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
        ),
      ],
    );
  }

  /// 한줄 요약 섹션 (점수 바로 아래)
  Widget _buildSummarySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote_rounded,
            size: 16,
            color: Colors.pinkAccent.withValues(alpha: 0.6),
          ),
          const SizedBox(width: DSSpacing.xs),
          Flexible(
            child: Text(
              summary!,
              style: context.typography.bodyMedium.copyWith(
                color: context.colors.textPrimary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// 종합 조언 하이라이트 박스
  Widget _buildOverallAdviceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pinkAccent.withValues(alpha: 0.08),
            Colors.amber.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 18,
            color: Colors.pinkAccent,
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Text(
              overallAdvice!,
              style: context.typography.bodySmall.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 키포인트 3개 섹션 빌드
  Widget _buildKeyPointsSection(BuildContext context) {
    final displayPoints = keyPoints!.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: Colors.pinkAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 섹션 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: Colors.pinkAccent,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '오늘의 핵심 포인트',
                style: context.typography.labelMedium.copyWith(
                  color: Colors.pinkAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          // 키포인트 목록
          ...displayPoints.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < displayPoints.length - 1 ? DSSpacing.xs : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: context.typography.labelSmall.copyWith(
                          color: Colors.pinkAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Text(
                      point,
                      style: context.typography.bodySmall.copyWith(
                        color: context.colors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 재회 운세 프리셋 (간소화 버전 - 요약만 표시)
///
/// 인포그래픽은 요약본이므로 핵심 정보만 표시:
/// - 재회 가능성 점수
/// - 현재 상태 태그 (optional)
/// - 한 줄 위로 메시지 (optional)
///
/// 상세 분석 (hardTruth, theirPerspective, strategicAdvice, emotionalPrescription)은
/// 결과 페이지 contentText에서 표시합니다.
class ExLoverScoreTemplate extends StatelessWidget {
  const ExLoverScoreTemplate({
    super.key,
    required this.score,
    this.reunionProbability,
    this.currentStatus,
    this.advice,
    // 아래 필드들은 호환성을 위해 유지하지만 인포그래픽에서는 사용 안 함
    this.hardTruth,
    this.theirPerspective,
    this.strategicAdvice,
    this.emotionalPrescription,
    this.isShareMode = false,
  });

  final int score;
  final int? reunionProbability;
  final String? currentStatus;
  final String? advice;
  // 호환성용 - 인포그래픽에서 미사용 (결과 페이지에서 사용)
  final String? hardTruth;
  final String? theirPerspective;
  final String? strategicAdvice;
  final String? emotionalPrescription;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    // 재회 가능성을 메인 점수로 사용 (중복 방지)
    final displayScore = reunionProbability ?? score;

    return ScoreTemplate(
      title: '오늘의 재회운',
      score: displayScore,
      scoreLabel: '재회 가능성',
      showStars: false,
      progressColor: Colors.purple,
      bottomWidget: _buildContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildContent(BuildContext context) {
    // 표시할 내용이 없으면 빈 위젯
    if ((currentStatus == null || currentStatus!.isEmpty) &&
        (advice == null || advice!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 현재 상태 태그
        if (currentStatus != null && currentStatus!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
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
          if (advice != null && advice!.isNotEmpty)
            const SizedBox(height: DSSpacing.sm),
        ],

        // 조언 태그 (텍스트 잘림 방지)
        if (advice != null && advice!.isNotEmpty)
          AdviceTag.fromText(
            advice!,
            size: AdviceTagSize.medium,
            showQuotes: true,
            animate: !isShareMode,
          ),
      ],
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
      showStars: false,
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
    this.categoryCounts,
    this.luckyElements,
    this.timeStrategy,
    this.summary,
    this.isShareMode = false,
  });

  final int riskScore;
  final List<String>? targetTypes;
  final List<String>? warningSignals;
  final List<String>? protectionTips;
  final Map<String, int>? categoryCounts;
  final Map<String, String>? luckyElements;
  final Map<String, Map<String, String>>? timeStrategy;
  final String? summary;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '오늘의 경계운',
      score: riskScore,
      scoreLabel: '경계 지수',
      showStars: false,
      progressColor: context.colors.error,
      bottomWidget: _buildContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildContent(BuildContext context) {
    final hasCategories = categoryCounts != null && categoryCounts!.isNotEmpty;
    final hasLuckyElements = luckyElements != null && luckyElements!.isNotEmpty;
    final hasTimeStrategy = timeStrategy != null && timeStrategy!.isNotEmpty;

    // 아무 데이터도 없으면 빈 위젯 반환
    if (!hasCategories && !hasLuckyElements && !hasTimeStrategy &&
        (targetTypes == null || targetTypes!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 경계 카테고리 요약 (8개 카테고리 카운트)
        if (hasCategories) ...[
          _buildCategorySummary(context),
          const SizedBox(height: DSSpacing.sm),
        ],

        // 행운 요소 (색상, 숫자, 방향, 시간)
        if (hasLuckyElements) ...[
          _buildLuckyElements(context),
          const SizedBox(height: DSSpacing.sm),
        ],

        // 시간대별 전략 요약
        if (hasTimeStrategy) ...[
          _buildTimeStrategy(context),
        ],

        // 기존 경계 대상 유형 (fallback)
        if (!hasCategories && targetTypes != null && targetTypes!.isNotEmpty) ...[
          _buildTargetTypes(context),
        ],
      ],
    );
  }

  /// 경계 카테고리 요약 (아이콘 + 개수)
  Widget _buildCategorySummary(BuildContext context) {
    final categoryIcons = {
      'cautionPeople': ('👤', '인물'),
      'cautionObjects': ('📦', '사물'),
      'cautionColors': ('🎨', '색상'),
      'cautionNumbers': ('🔢', '숫자'),
      'cautionAnimals': ('🐾', '동물'),
      'cautionPlaces': ('📍', '장소'),
      'cautionTimes': ('⏰', '시간'),
      'cautionDirections': ('🧭', '방향'),
    };

    final validCategories = categoryCounts!.entries
        .where((e) => e.value > 0 && categoryIcons.containsKey(e.key))
        .toList();

    if (validCategories.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.error.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 16, color: context.colors.error),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '오늘의 경계 대상',
                style: context.typography.labelMedium.copyWith(
                  color: context.colors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.xs,
            children: validCategories.map((entry) {
              final iconData = categoryIcons[entry.key]!;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: DSSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.error.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(iconData.$1, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${iconData.$2} ${entry.value}개',
                      style: context.typography.labelSmall.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 행운 요소 (색상, 숫자, 방향, 시간, 아이템, 사람)
  Widget _buildLuckyElements(BuildContext context) {
    final elementIcons = {
      'color': ('🎨', '행운 색상'),
      'number': ('🔢', '행운 숫자'),
      'direction': ('🧭', '좋은 방향'),
      'time': ('⏰', '최고의 시간'),
      'item': ('✨', '행운 아이템'),
      'person': ('👤', '만나면 좋은 사람'),
    };

    final validElements = luckyElements!.entries
        .where((e) => e.value.isNotEmpty && elementIcons.containsKey(e.key))
        .take(4) // 최대 4개만 표시
        .toList();

    if (validElements.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.success.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 16, color: context.colors.success),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '오늘의 행운 요소',
                style: context.typography.labelMedium.copyWith(
                  color: context.colors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.xs,
            children: validElements.map((entry) {
              final iconData = elementIcons[entry.key]!;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: DSSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.success.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(iconData.$1, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      entry.value,
                      style: context.typography.labelSmall.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 시간대별 전략 요약
  Widget _buildTimeStrategy(BuildContext context) {
    final timeLabels = {
      'morning': ('🌅', '오전'),
      'afternoon': ('☀️', '오후'),
      'evening': ('🌙', '저녁'),
    };

    final validStrategies = timeStrategy!.entries
        .where((e) => timeLabels.containsKey(e.key) &&
               (e.value['caution']?.isNotEmpty == true || e.value['advice']?.isNotEmpty == true))
        .toList();

    if (validStrategies.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: context.colors.accent),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '시간대별 가이드',
                style: context.typography.labelMedium.copyWith(
                  color: context.colors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          ...validStrategies.map((entry) {
            final labelData = timeLabels[entry.key]!;
            final advice = entry.value['advice'] ?? entry.value['caution'] ?? '';
            if (advice.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(labelData.$1, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    '${labelData.$2}: ',
                    style: context.typography.labelSmall.copyWith(
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      advice.length > 30 ? '${advice.substring(0, 30)}...' : advice,
                      style: context.typography.bodySmall.copyWith(
                        color: context.colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 기존 경계 대상 유형 (fallback)
  Widget _buildTargetTypes(BuildContext context) {
    return Container(
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
      showStars: false,
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
      showStars: false,
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
    this.summaryPoints,
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

  /// 요약 포인트 (점수 아래 표시, 최대 3개)
  final List<String>? summaryPoints;

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
        // 요약 포인트 (있는 경우)
        if (summaryPoints != null && summaryPoints!.isNotEmpty) ...[
          _buildSummarySection(context),
          const SizedBox(height: DSSpacing.md),
        ],
        // 3개 리듬 바
        _buildRhythmBar(
          context,
          icon: Icons.fitness_center_rounded,
          label: '신체',
          score: physicalScore,
          phase: physicalPhase,
          color: DSFortuneColors.elementFire, // 신체 리듬 - 빨강
        ),
        const SizedBox(height: DSSpacing.sm),
        _buildRhythmBar(
          context,
          icon: Icons.favorite_rounded,
          label: '감정',
          score: emotionalScore,
          phase: emotionalPhase,
          color: DSFortuneColors.categoryLove, // 감정 리듬 - 핑크
        ),
        const SizedBox(height: DSSpacing.sm),
        _buildRhythmBar(
          context,
          icon: Icons.psychology_rounded,
          label: '지성',
          score: intellectualScore,
          phase: intellectualPhase,
          color: DSFortuneColors.categoryCareer, // 지성 리듬 - 파랑
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

  /// 요약 포인트 섹션 빌드
  Widget _buildSummarySection(BuildContext context) {
    final displayPoints = summaryPoints!.take(3).toList();
    final themeColor = DSFortuneColors.categoryBiorhythm; // 바이오리듬 테마 색상

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 섹션 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insights_rounded,
                size: 16,
                color: themeColor,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '오늘의 컨디션',
                style: context.typography.labelMedium.copyWith(
                  color: themeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          // 요약 포인트 목록
          ...displayPoints.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            final icons = ['💪', '💖', '🧠'];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < displayPoints.length - 1 ? DSSpacing.xs : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    icons[index % icons.length],
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Text(
                      point,
                      style: context.typography.bodySmall.copyWith(
                        color: context.colors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
