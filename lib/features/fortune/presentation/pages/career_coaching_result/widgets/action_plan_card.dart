import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/components/app_card.dart';

class ActionPlanCard extends StatelessWidget {
  final Map<String, dynamic> actionPlan;
  final DSColorScheme colors;

  const ActionPlanCard({
    super.key,
    required this.actionPlan,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final focusArea = actionPlan['focus_area'] as String? ?? '';
    final expectedOutcome = actionPlan['expected_outcome'] as String? ?? '';
    final weeks = actionPlan['weeks'] as List? ?? [];

    return Column(
      children: [
        // Focus Area
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag, color: DSColors.warning, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '30일 액션플랜',
                    style: DSTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                focusArea,
                style: DSTypography.bodyMedium.copyWith(
                  height: 1.5,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DSColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: DSColors.success, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '예상 성과: $expectedOutcome',
                        style: DSTypography.labelMedium.copyWith(
                          color: DSColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Weekly Actions
        ...weeks.asMap().entries.map((entry) {
          final index = entry.key;
          final week = entry.value as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: WeekCard(week: week, index: index, colors: colors),
          );
        }),
      ],
    );
  }
}

class WeekCard extends StatelessWidget {
  final Map<String, dynamic> week;
  final int index;
  final DSColorScheme colors;

  const WeekCard({
    super.key,
    required this.week,
    required this.index,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final weekNumber = week['week_number'] as int? ?? (index + 1);
    final theme = week['theme'] as String? ?? '';
    final tasks = week['tasks'] as List? ?? [];
    final milestone = week['milestone'] as String? ?? '';

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$weekNumber주',
                    style: DSTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  theme,
                  style: DSTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...tasks.map((task) =>
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colors.border,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.toString(),
                      style: DSTypography.bodyMedium.copyWith(
                        height: 1.5,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.flag_outlined, color: colors.textSecondary, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    milestone,
                    style: DSTypography.labelMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.1);
  }
}
