import 'package:flutter/material.dart';

import '../../../../../core/design_system/design_system.dart';
import '_fortune_body_shared.dart';
import '_fortune_visual_components.dart';

/// Body widget for health/wellness fortune types:
/// health, exercise, match-insight, breathing
class HealthFortuneBody extends StatelessWidget {
  final String fortuneType;
  final Map<String, dynamic> componentData;

  const HealthFortuneBody({
    super.key,
    required this.fortuneType,
    required this.componentData,
  });

  @override
  Widget build(BuildContext context) {
    switch (fortuneType) {
      case 'health':
        return _buildHealthBody(context);
      case 'exercise':
        return _buildExerciseBody(context);
      case 'match-insight':
        return _buildGenericBody(context, emoji: '⚽');
      case 'game-enhance':
        return _buildGenericBody(context, emoji: '🎮');
      default:
        return _buildGenericBody(context, emoji: '🌬️');
    }
  }

  // ═══ Health (건강운) ═══

  Widget _buildHealthBody(BuildContext context) {
    final colors = context.colors;
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '웰니스 체크를 정리했어요.';
    final healthAnalysis = fortuneAsMap(componentData['healthAnalysis']) ??
        fortuneAsMap(componentData['health_analysis']);
    final recommendations =
        fortuneAsMap(componentData['healthRecommendations']) ??
            fortuneAsMap(componentData['recommendations']);
    final warningsList = fortuneStrList(componentData['warnings']) +
        fortuneStrList(componentData['warningSigns']) +
        fortuneStrList(componentData['warning_signs']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final highlights = fortuneStrList(componentData['highlights']);
    final specialTip = fortuneStr(componentData['specialTip']);

    // Overall score for hero card
    final overallScore = fortuneInt(componentData['score']) ??
        fortuneInt(componentData['overallScore']) ??
        fortuneInt(healthAnalysis?['overallScore']) ??
        fortuneInt(healthAnalysis?['overall_score']);
    final scoreDescription = fortuneStr(componentData['scoreDescription']) ??
        fortuneStr(componentData['scoreComment']) ??
        fortuneStr(healthAnalysis?['overallStatus']) ??
        fortuneStr(healthAnalysis?['overall_status']);

    // Health analysis sub-fields
    final overallStatus = fortuneStr(healthAnalysis?['overallStatus']) ??
        fortuneStr(healthAnalysis?['overall_status']);
    final physical = fortuneInt(healthAnalysis?['physicalCondition']) ??
        fortuneInt(healthAnalysis?['physical_condition']) ??
        fortuneInt(healthAnalysis?['physical']);
    final mental = fortuneInt(healthAnalysis?['mentalCondition']) ??
        fortuneInt(healthAnalysis?['mental_condition']) ??
        fortuneInt(healthAnalysis?['mental']);
    final energy = fortuneInt(healthAnalysis?['energyLevel']) ??
        fortuneInt(healthAnalysis?['energy_level']) ??
        fortuneInt(healthAnalysis?['energy']);
    final sleep = fortuneInt(healthAnalysis?['sleepQuality']) ??
        fortuneInt(healthAnalysis?['sleep_quality']) ??
        fortuneInt(healthAnalysis?['sleep']);
    final immunity = fortuneInt(healthAnalysis?['immunity']) ??
        fortuneInt(healthAnalysis?['immuneLevel']) ??
        fortuneInt(healthAnalysis?['immune_level']);

    // Recommendation sub-fields
    final exerciseRec = fortuneStrList(recommendations?['exercise']);
    final dietRec = fortuneStrList(recommendations?['diet']);
    final restRec = fortuneStrList(recommendations?['rest']);
    final stressRec = fortuneStrList(recommendations?['stressManagement']) +
        fortuneStrList(recommendations?['stress_management']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: '🏥', text: summary),

        if (overallStatus != null && overallScore == null) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: ['🩺 $overallStatus'])),
        ],

        if (highlights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: highlights)),
        ],

        // Score hero card
        if (overallScore != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneScoreHeroCard(
            label: '건강 점수',
            score: overallScore,
            description: scoreDescription ?? '양호한 컨디션이에요',
            accentColor: colors.success,
          ),
        ],

        // 2x2 colored metric tiles for health indicators
        if (energy != null ||
            immunity != null ||
            mental != null ||
            sleep != null ||
            physical != null) ...[
          const SizedBox(height: DSSpacing.md),
          FortuneStaggeredSection(
            index: si++,
            child: _buildHealthMetricGrid(
              context,
              energy: energy,
              immunity: immunity,
              mental: mental,
              sleep: sleep,
              physical: physical,
            ),
          ),
        ],

        // 🌿 웰니스 플랜 (exercise + diet as infograph grid)
        if (exerciseRec.isNotEmpty || dietRec.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🌿',
              title: '웰니스 플랜',
              child: FortuneInfoGraphGrid(
                items: [
                  if (exerciseRec.isNotEmpty)
                    FortuneInfoGraphItem(
                      icon: '🏃',
                      label: '운동',
                      value: exerciseRec.join(', '),
                      accentColor: colors.success,
                    ),
                  if (dietRec.isNotEmpty)
                    FortuneInfoGraphItem(
                      icon: '🍎',
                      label: '식단',
                      value: dietRec.join(', '),
                      accentColor: colors.accentTertiary,
                    ),
                ],
              ),
            ),
          ),
        ],

        // Rest recommendations
        if (restRec.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '😴',
              title: '회복 팁',
              child: FortuneBulletList(items: restRec, bullet: '🌙'),
            ),
          ),
        ],

        // Stress management
        if (stressRec.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🧘',
              title: '마음 돌봄',
              child: FortuneBulletList(items: stressRec, bullet: '🌿'),
            ),
          ),
        ],

        if (specialTip != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(emoji: '💡', text: specialTip),
          ),
        ],

        // Warnings as bullet list
        if (warningsList.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '⚠️',
              title: '주의 사항',
              child: FortuneBulletList(
                  items: warningsList, bullet: '⚠️', isWarning: true),
            ),
          ),
        ],

        // Lucky items as pills
        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '🍀',
              title: '행운 포인트',
              child: FortuneTagPillWrap(
                tags: luckyItems.entries
                    .map((e) => '${e.value}')
                    .toList(growable: false),
              ),
            ),
          ),
        ],

        // Health disclaimer (Apple 1.4.1)
        FortuneStaggeredSection(
          index: si++,
          child: const FortuneHealthDisclaimer(),
        ),
      ],
    );
  }

  /// Build 2x2 grid of colored health metric tiles
  Widget _buildHealthMetricGrid(
    BuildContext context, {
    int? energy,
    int? immunity,
    int? mental,
    int? sleep,
    int? physical,
  }) {
    final colors = context.colors;
    final tiles = <Widget>[];
    if (energy != null) {
      tiles.add(Expanded(
        child: FortuneColoredMetricTile(
          emoji: '⚡',
          label: '에너지',
          score: energy,
          backgroundColor: colors.success,
        ),
      ));
    }
    if (immunity != null) {
      tiles.add(Expanded(
        child: FortuneColoredMetricTile(
          emoji: '🛡️',
          label: '면역력',
          score: immunity,
          backgroundColor: colors.accentSecondary,
        ),
      ));
    } else if (physical != null) {
      tiles.add(Expanded(
        child: FortuneColoredMetricTile(
          emoji: '💪',
          label: '체력',
          score: physical,
          backgroundColor: colors.accentSecondary,
        ),
      ));
    }
    if (mental != null) {
      tiles.add(Expanded(
        child: FortuneColoredMetricTile(
          emoji: '🧠',
          label: '멘탈',
          score: mental,
          backgroundColor: colors.ctaBackground,
        ),
      ));
    }
    if (sleep != null) {
      tiles.add(Expanded(
        child: FortuneColoredMetricTile(
          emoji: '😴',
          label: '수면',
          score: sleep,
          backgroundColor: colors.accentTertiary,
        ),
      ));
    }

    if (tiles.isEmpty) return const SizedBox.shrink();

    // Build up to 2 rows of 2
    final row1 = tiles.take(2).toList();
    final row2 = tiles.length > 2 ? tiles.skip(2).take(2).toList() : <Widget>[];

    return Column(
      children: [
        Row(
          children: row1.length == 1
              ? [...row1, const Expanded(child: SizedBox.shrink())]
              : [row1[0], const SizedBox(width: DSSpacing.sm), row1[1]],
        ),
        if (row2.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Row(
            children: row2.length == 1
                ? [...row2, const Expanded(child: SizedBox.shrink())]
                : [row2[0], const SizedBox(width: DSSpacing.sm), row2[1]],
          ),
        ],
      ],
    );
  }

  // ═══ Exercise (운동 운세) ═══

  Widget _buildExerciseBody(BuildContext context) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '오늘의 운동 운세를 분석했어요.';
    final highlights = fortuneStrList(componentData['highlights']);

    // 3 recommendation pills (추천 운동 / 최적 시간 / 키워드)
    final recommendedExercise =
        fortuneStr(componentData['recommendedExercise']) ??
            fortuneStr(componentData['recommended_exercise']);
    final optimalTime = fortuneStr(componentData['optimalTime']) ??
        fortuneStr(componentData['optimal_time']);
    final keyword = fortuneStr(componentData['keyword']) ??
        fortuneStr(componentData['exerciseKeyword']);

    // 오늘의 루틴 (numbered workout steps)
    final routine = fortuneMapList(componentData['routine']) +
        fortuneMapList(componentData['todayRoutine']) +
        fortuneMapList(componentData['today_routine']);
    final routineSteps = fortuneStrList(componentData['routineSteps']) +
        fortuneStrList(componentData['routine_steps']);

    // 주간 운동 플랜
    final weeklyPlan = fortuneMapList(componentData['weeklyPlan']) +
        fortuneMapList(componentData['weekly_plan']);

    // 부상 예방 팁
    final injuryTips = fortuneStrList(componentData['injuryPrevention']) +
        fortuneStrList(componentData['injury_prevention']) +
        fortuneStrList(componentData['injuryTips']);
    final injuryTip = fortuneStr(componentData['injuryTip']);

    // 영양 팁
    final nutritionTips = fortuneStrList(componentData['nutritionTips']) +
        fortuneStrList(componentData['nutrition_tips']);
    final nutritionTip = fortuneStr(componentData['nutritionTip']) ??
        fortuneStr(componentData['nutrition_tip']);

    // Fallback fields
    final specialTip = fortuneStr(componentData['specialTip']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: '💪', text: summary),

        if (highlights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: highlights)),
        ],

        // 3 recommendation pills
        if (recommendedExercise != null ||
            optimalTime != null ||
            keyword != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: Row(
              children: [
                if (recommendedExercise != null)
                  Expanded(
                    child: _buildExercisePill(
                      context,
                      emoji: '🎾',
                      label: '추천 운동',
                      value: recommendedExercise,
                    ),
                  ),
                if (recommendedExercise != null && optimalTime != null)
                  const SizedBox(width: DSSpacing.sm),
                if (optimalTime != null)
                  Expanded(
                    child: _buildExercisePill(
                      context,
                      emoji: '⏰',
                      label: '최적 시간',
                      value: optimalTime,
                    ),
                  ),
                if ((recommendedExercise != null || optimalTime != null) &&
                    keyword != null)
                  const SizedBox(width: DSSpacing.sm),
                if (keyword != null)
                  Expanded(
                    child: _buildExercisePill(
                      context,
                      emoji: '🔥',
                      label: '키워드',
                      value: keyword,
                    ),
                  ),
              ],
            ),
          ),
        ],

        // 오늘의 루틴 (numbered workout steps from maps)
        if (routine.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '📋',
              title: '오늘의 루틴',
              child: _buildRoutineSteps(context, routine),
            ),
          ),
        ] else if (routineSteps.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '📋',
              title: '오늘의 루틴',
              child: _buildNumberedList(context, routineSteps),
            ),
          ),
        ],

        // 주간 운동 플랜
        if (weeklyPlan.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '📅',
              title: '이번 주 운동 플랜',
              child: _buildWeeklyPlan(context, weeklyPlan),
            ),
          ),
        ],

        // 부상 예방 팁
        if (injuryTips.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(
              emoji: '🛡️',
              text: injuryTips.join('\n'),
            ),
          ),
        ] else if (injuryTip != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(emoji: '🛡️', text: injuryTip),
          ),
        ],

        // 영양 팁
        if (nutritionTips.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(
              emoji: '🥗',
              text: nutritionTips.join('\n'),
            ),
          ),
        ] else if (nutritionTip != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(emoji: '🥗', text: nutritionTip),
          ),
        ],

        if (specialTip != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(emoji: '💡', text: specialTip),
          ),
        ],

        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '✅',
              title: '추천',
              child: FortuneBulletList(items: recommendations, bullet: '💫'),
            ),
          ),
        ],

        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneLuckyItemGrid(items: luckyItems),
          ),
        ],

        if (warnings.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '⚠️',
              title: '주의',
              child: FortuneBulletList(
                  items: warnings, bullet: '⚠️', isWarning: true),
            ),
          ),
        ],

        // Health disclaimer (Apple 1.4.1)
        FortuneStaggeredSection(
          index: si++,
          child: const FortuneHealthDisclaimer(),
        ),
      ],
    );
  }

  /// Rounded pill widget for exercise recommendations (추천 운동/최적 시간/키워드)
  Widget _buildExercisePill(
    BuildContext context, {
    required String emoji,
    required String label,
    required String value,
  }) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: DSSpacing.xxs),
          Text(
            label,
            style: context.labelSmall.copyWith(
              color: colors.textTertiary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: DSSpacing.xxs),
          Text(
            value,
            style: context.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.accent,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Numbered routine steps from list of maps
  Widget _buildRoutineSteps(
      BuildContext context, List<Map<String, dynamic>> steps) {
    final colors = context.colors;
    return Column(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final title = fortuneStr(step['title']) ??
            fortuneStr(step['name']) ??
            '단계 ${i + 1}';
        final desc = fortuneStr(step['description']) ??
            fortuneStr(step['detail']) ??
            fortuneStr(step['content']);
        return Padding(
          padding: EdgeInsets.only(
            bottom: i < steps.length - 1 ? DSSpacing.md : 0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '${i + 1}',
                  style: context.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (desc != null) ...[
                      const SizedBox(height: DSSpacing.xxs),
                      Text(
                        desc,
                        style: context.bodySmall.copyWith(
                          color: colors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(growable: false),
    );
  }

  /// Simple numbered list from strings
  Widget _buildNumberedList(BuildContext context, List<String> items) {
    final colors = context.colors;
    return Column(
      children: items.asMap().entries.map((entry) {
        final i = entry.key;
        return Padding(
          padding: EdgeInsets.only(
            bottom: i < items.length - 1 ? DSSpacing.sm : 0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '${i + 1}',
                  style: context.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Text(
                  entry.value,
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(growable: false),
    );
  }

  /// Weekly plan grid (월/화/수/목/금)
  Widget _buildWeeklyPlan(
      BuildContext context, List<Map<String, dynamic>> plan) {
    final colors = context.colors;
    return Wrap(
      spacing: DSSpacing.sm,
      runSpacing: DSSpacing.sm,
      children: plan.map((day) {
        final dayLabel =
            fortuneStr(day['day']) ?? fortuneStr(day['label']) ?? '';
        final activity = fortuneStr(day['activity']) ??
            fortuneStr(day['exercise']) ??
            fortuneStr(day['content']) ??
            '';
        final emoji = fortuneStr(day['emoji']) ?? '🏋️';
        return Container(
          width: 56,
          padding: const EdgeInsets.symmetric(
            vertical: DSSpacing.sm,
            horizontal: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.md),
            border: Border.all(
              color: colors.border.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            children: [
              Text(
                dayLabel,
                style: context.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: DSSpacing.xxs),
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: DSSpacing.xxs),
              Text(
                activity,
                style: context.labelSmall.copyWith(
                  color: colors.textTertiary,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(growable: false),
    );
  }

  // ═══ Generic fallback (match-insight, breathing) ═══

  Widget _buildGenericBody(BuildContext context, {required String emoji}) {
    final summary = fortuneStr(componentData['summary']) ??
        fortuneStr(componentData['content']) ??
        '결과를 분석했어요.';
    final highlights = fortuneStrList(componentData['highlights']);
    final luckyItems = fortuneAsMap(componentData['luckyItems']);
    final recommendations = fortuneStrList(componentData['recommendations']);
    final warnings = fortuneStrList(componentData['warnings']);
    final specialTip = fortuneStr(componentData['specialTip']);

    var si = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FortuneEmojiHeader(emoji: emoji, text: summary),
        if (highlights.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Center(child: FortuneTagPillWrap(tags: highlights)),
        ],
        if (specialTip != null) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneTipCard(emoji: '💡', text: specialTip),
          ),
        ],
        if (luckyItems != null && luckyItems.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneLuckyItemGrid(items: luckyItems),
          ),
        ],
        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '✅',
              title: '추천',
              child: FortuneBulletList(items: recommendations, bullet: '💫'),
            ),
          ),
        ],
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.lg),
          FortuneStaggeredSection(
            index: si++,
            child: FortuneSectionCard(
              emoji: '⚠️',
              title: '주의',
              child: FortuneBulletList(
                  items: warnings, bullet: '⚠️', isWarning: true),
            ),
          ),
        ],
      ],
    );
  }
}
