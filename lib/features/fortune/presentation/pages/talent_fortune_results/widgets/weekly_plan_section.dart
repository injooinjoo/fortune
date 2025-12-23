import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/models/fortune_result.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';

class WeeklyPlanSection extends StatelessWidget {
  final FortuneResult? fortuneResult;
  final DSColorScheme colors;

  const WeeklyPlanSection({
    super.key,
    required this.fortuneResult,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final weeklyPlan = fortuneResult?.data['weeklyPlan'] as List<dynamic>? ?? [];

    if (weeklyPlan.isEmpty) {
      return Center(
        child: Text(
          '주간 계획 데이터가 없습니다',
          style: DSTypography.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...weeklyPlan.asMap().entries.map((entry) {
          final index = entry.key;
          final dayPlan = entry.value as Map<String, dynamic>;
          final day = FortuneTextCleaner.cleanNullable(dayPlan['day'] as String?);
          final focus = FortuneTextCleaner.cleanNullable(dayPlan['focus'] as String?);
          final activities = (dayPlan['activities'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
          final timeNeeded = FortuneTextCleaner.cleanNullable(dayPlan['timeNeeded'] as String?);
          final checklist = (dayPlan['checklist'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
          final expectedOutcome = FortuneTextCleaner.cleanNullable(dayPlan['expectedOutcome'] as String?);

          return Padding(
            padding: EdgeInsets.only(bottom: index < weeklyPlan.length - 1 ? 12 : 0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: DSTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day,
                              style: DSTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                            if (timeNeeded.isNotEmpty)
                              Text(
                                timeNeeded,
                                style: DSTypography.labelSmall.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (focus.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '🎯 $focus',
                        style: DSTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.accent,
                        ),
                      ),
                    ),
                  ],
                  if (activities.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...activities.map((activity) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: DSTypography.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              activity,
                              style: DSTypography.bodySmall.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                  if (checklist.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      '✅ 체크리스트',
                      style: DSTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...checklist.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_box_outline_blank,
                            size: 16,
                            color: DSColors.success,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item,
                              style: DSTypography.labelSmall.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                  if (expectedOutcome.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: DSColors.success.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: DSColors.success.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.stars,
                            color: DSColors.success,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              expectedOutcome,
                              style: DSTypography.labelSmall.copyWith(
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
            ),
          );
        }),
      ],
    );
  }
}
