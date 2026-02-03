import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/services/fortune_haptic_service.dart';
import '../../../../../domain/entities/fortune.dart';
import '../../../../../shared/widgets/smart_image.dart';

/// 유명인 운명의시기 전용 카드
///
/// 6개 상세 항목:
/// - 만남 최적기
/// - 고백 최적기
/// - 관계 이정표
/// - 피해야 할 시기
/// - 운명적 날짜
/// - 계절별 조언
class CelebrityTimingCard extends ConsumerStatefulWidget {
  final Fortune fortune;
  final String? celebrityName;
  final String? celebrityImageUrl;

  const CelebrityTimingCard({
    super.key,
    required this.fortune,
    this.celebrityName,
    this.celebrityImageUrl,
  });

  @override
  ConsumerState<CelebrityTimingCard> createState() =>
      _CelebrityTimingCardState();
}

class _CelebrityTimingCardState extends ConsumerState<CelebrityTimingCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(fortuneHapticServiceProvider).mysticalReveal();
      }
    });
  }

  // 데이터 추출 헬퍼
  Map<String, dynamic> get _additionalInfo =>
      widget.fortune.additionalInfo ?? {};

  Map<String, dynamic>? get _meetingTiming =>
      _additionalInfo['meeting_timing'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _confessionTiming =>
      _additionalInfo['confession_timing'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _relationshipMilestones =>
      _additionalInfo['relationship_milestones'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _avoidPeriods =>
      _additionalInfo['avoid_periods'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _destinedDates =>
      _additionalInfo['destined_dates'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _seasonalAdvice =>
      _additionalInfo['seasonal_advice'] as Map<String, dynamic>?;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? colors.backgroundSecondary : colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          _buildHeader(context).animate().fadeIn(duration: 400.ms),

          // 메인 메시지
          _buildMainMessage(context)
              .animate()
              .fadeIn(duration: 500.ms, delay: 100.ms),

          // 1. 만남 최적기
          if (_meetingTiming != null)
            _buildMeetingSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 200.ms),

          // 2. 고백 최적기
          if (_confessionTiming != null)
            _buildConfessionSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 300.ms),

          // 3. 관계 이정표
          if (_relationshipMilestones != null)
            _buildMilestonesSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 400.ms),

          // 4. 피해야 할 시기
          if (_avoidPeriods != null)
            _buildAvoidSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 500.ms),

          // 5. 운명적 날짜
          if (_destinedDates != null)
            _buildDestinedDatesSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 600.ms),

          // 6. 계절별 조언
          if (_seasonalAdvice != null)
            _buildSeasonalSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 700.ms),

          const SizedBox(height: DSSpacing.md),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final score = widget.fortune.score;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DSFortuneColors.categoryLotto.withValues(alpha: 0.15), // 골드/오렌지 계열
            DSFortuneColors.elementEarth.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Row(
        children: [
          // 유명인 아바타 + 시계
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DSFortuneColors.categoryLotto.withValues(alpha: 0.2),
                  border: Border.all(
                    color: DSFortuneColors.categoryLotto.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: widget.celebrityImageUrl != null
                      ? SmartImage(
                          path: widget.celebrityImageUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorWidget: _buildDefaultAvatar(),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.textPrimary.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Text('⏰', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
          const SizedBox(width: DSSpacing.md),

          // 이름 + 타입
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.celebrityName ?? '유명인'}과의 운명의 시기',
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '⏰ 타이밍 분석',
                  style: typography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 점수 배지 (시계 모양)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.sm,
              vertical: DSSpacing.xs,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DSFortuneColors.categoryLotto, DSFortuneColors.elementEarth],
              ),
              borderRadius: BorderRadius.circular(DSRadius.full),
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '$score',
                  style: typography.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMessage(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final message = widget.fortune.content;

    return Padding(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: DSFortuneColors.categoryLotto.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: DSFortuneColors.categoryLotto.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          message,
          style: typography.bodyMedium.copyWith(
            color: colors.textPrimary,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildMeetingSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _meetingTiming!;

    return _buildSection(
      context,
      icon: '🤝',
      title: '만남 최적기',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 연/월 배지들
          Row(
            children: [
              if (data['best_year'] != null)
                _buildTimeBadge(context, '📅', data['best_year'], DSFortuneColors.categoryFamily),
              const SizedBox(width: DSSpacing.sm),
              if (data['best_month'] != null)
                _buildTimeBadge(context, '🗓️', data['best_month'], DSFortuneColors.categoryMoney),
            ],
          ),
          if (data['best_day_type'] != null) ...[
            const SizedBox(height: DSSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: DSFortuneColors.categoryLuckyItems.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Text(
                '💫 ${data['best_day_type']}',
                style: typography.labelSmall.copyWith(
                  color: DSFortuneColors.categoryLuckyItems,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          if (data['interpretation'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              data['interpretation'],
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeBadge(BuildContext context, String emoji, String text, Color color) {
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            text,
            style: typography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfessionSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _confessionTiming!;

    return _buildSection(
      context,
      icon: '💌',
      title: '고백 최적기',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['optimal_period'] != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DSFortuneColors.categoryLove.withValues(alpha: 0.1),
                    DSFortuneColors.categoryBlindDate.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Column(
                children: [
                  const Text('💘', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    data['optimal_period'],
                    style: typography.labelLarge.copyWith(
                      color: DSFortuneColors.categoryLove,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          if (data['favorable_conditions'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.textPrimary.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✨'),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      data['favorable_conditions'],
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (data['approach_tips'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: DSFortuneColors.categoryGratitude.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡'),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      data['approach_tips'],
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMilestonesSection(BuildContext context) {
    final data = _relationshipMilestones!;

    return _buildSection(
      context,
      icon: '🎯',
      title: '관계 이정표',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMilestoneItem(context, '💕', '연애 시작', data['dating_start']),
          _buildMilestoneItem(context, '💍', '진지한 약속', data['commitment']),
          _buildMilestoneItem(context, '🎊', '결혼 운명의 때', data['marriage_timing']),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem(BuildContext context, String emoji, String label, String? content) {
    if (content == null) return const SizedBox.shrink();

    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: colors.textPrimary.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(DSRadius.sm),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content,
                    style: typography.bodySmall.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvoidSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _avoidPeriods!;
    final badTimes = data['bad_times'] as List? ?? [];
    final reasons = data['reasons'] as List? ?? [];

    return _buildSection(
      context,
      icon: '⚠️',
      title: '피해야 할 시기',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: DSFortuneColors.categoryNewYear.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DSRadius.sm),
              border: Border.all(
                color: DSFortuneColors.categoryNewYear.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...badTimes.asMap().entries.take(2).map((entry) {
                  final index = entry.key;
                  final time = entry.value;
                  final reason = index < reasons.length ? reasons[index] : '';
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < badTimes.length - 1 ? DSSpacing.xs : 0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🚫', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: DSSpacing.xs),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                time.toString(),
                                style: typography.labelSmall.copyWith(
                                  color: DSFortuneColors.categoryNewYear,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (reason.toString().isNotEmpty)
                                Text(
                                  reason.toString(),
                                  style: typography.labelSmall.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          if (data['alternatives'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: DSFortuneColors.categoryMoney.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✅'),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      data['alternatives'],
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDestinedDatesSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _destinedDates!;
    final dates = data['special_dates'] as List? ?? [];
    final significances = data['significance'] as List? ?? [];

    return _buildSection(
      context,
      icon: '⭐',
      title: '운명적 날짜',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...dates.asMap().entries.take(3).map((entry) {
            final index = entry.key;
            final date = entry.value;
            final significance = index < significances.length
                ? significances[index]
                : '';
            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Container(
                padding: const EdgeInsets.all(DSSpacing.sm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DSFortuneColors.fortuneGoldMuted.withValues(alpha: 0.1),
                      DSFortuneColors.resultGoodFortune.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: DSFortuneColors.fortuneGoldMuted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: typography.labelSmall.copyWith(
                          color: DSFortuneColors.fortuneGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: DSSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date.toString(),
                            style: typography.labelMedium.copyWith(
                              color: DSFortuneColors.fortuneGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (significance.toString().isNotEmpty)
                            Text(
                              significance.toString(),
                              style: typography.labelSmall.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (data['how_to_prepare'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📝'),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: Text(
                    data['how_to_prepare'],
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeasonalSection(BuildContext context) {
    final data = _seasonalAdvice!;

    return _buildSection(
      context,
      icon: '🌸',
      title: '계절별 인연 운세',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSeasonCard(
                  context,
                  '🌸',
                  '봄',
                  data['spring'],
                  DSFortuneColors.categoryBlindDate,
                ),
              ),
              const SizedBox(width: DSSpacing.xs),
              Expanded(
                child: _buildSeasonCard(
                  context,
                  '🌊',
                  '여름',
                  data['summer'],
                  DSFortuneColors.categoryFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _buildSeasonCard(
                  context,
                  '🍂',
                  '가을',
                  data['autumn'],
                  DSFortuneColors.categoryLotto,
                ),
              ),
              const SizedBox(width: DSSpacing.xs),
              Expanded(
                child: _buildSeasonCard(
                  context,
                  '❄️',
                  '겨울',
                  data['winter'],
                  DSFortuneColors.categoryLuckyItems,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonCard(
    BuildContext context,
    String emoji,
    String season,
    String? content,
    Color color,
  ) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                season,
                style: typography.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (content != null) ...[
            const SizedBox(height: 4),
            Text(
              content,
              style: typography.labelSmall.copyWith(
                color: colors.textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String icon,
    required String title,
    required Widget child,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: DSSpacing.xs),
              Text(
                title,
                style: typography.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          child,
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: DSFortuneColors.categoryLotto.withValues(alpha: 0.3),
      child: const Center(
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
