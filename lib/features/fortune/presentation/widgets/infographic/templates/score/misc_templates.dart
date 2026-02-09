import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/category_bar_chart.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/infographic_container.dart';
import '../score_template.dart';

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
        color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? Icons.format_quote_rounded,
            size: 48,
            color: iconColor ?? context.colors.accent,
          ),
          const SizedBox(height: DSSpacing.md),
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
        color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (luckyDirection != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.explore_rounded, size: 20, color: Colors.teal),
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

    if (!hasCategories && !hasLuckyElements && !hasTimeStrategy &&
        (targetTypes == null || targetTypes!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasCategories) ...[
          _buildCategorySummary(context),
          const SizedBox(height: DSSpacing.sm),
        ],
        if (hasLuckyElements) ...[
          _buildLuckyElements(context),
          const SizedBox(height: DSSpacing.sm),
        ],
        if (hasTimeStrategy) ...[
          _buildTimeStrategy(context),
        ],
        if (!hasCategories && targetTypes != null && targetTypes!.isNotEmpty) ...[
          _buildTargetTypes(context),
        ],
      ],
    );
  }

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
        color: context.colors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.error.withValues(alpha: 0.2)),
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
                  border: Border.all(color: context.colors.error.withValues(alpha: 0.3)),
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
        .take(4)
        .toList();

    if (validElements.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.success.withValues(alpha: 0.2)),
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
                  border: Border.all(color: context.colors.success.withValues(alpha: 0.3)),
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
        color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
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

  Widget _buildTargetTypes(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.error.withValues(alpha: 0.1),
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
                  color: context.colors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.error.withValues(alpha: 0.3)),
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
        color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (petType != null) ...[
                const Icon(Icons.pets_rounded, size: 20, color: Colors.amber),
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
                    color: Colors.amber.withValues(alpha: 0.1),
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
          if (recommendations != null && recommendations!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            ...recommendations!.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_rounded, size: 12, color: Colors.amber),
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
        color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (luckyActivity != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.family_restroom_rounded, size: 16, color: Colors.brown),
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
          if (recommendations != null && recommendations!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            ...recommendations!.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                  child: Row(
                    children: [
                      const Icon(Icons.home_rounded, size: 12, color: Colors.brown),
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
        color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                    color: context.colors.accent.withValues(alpha: 0.1),
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
