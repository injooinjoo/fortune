import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/models/fortune_result.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';

class WeeklyPlanSection extends StatelessWidget {
  final FortuneResult? fortuneResult;
  final bool isDark;

  const WeeklyPlanSection({
    super.key,
    required this.fortuneResult,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final weeklyPlan = fortuneResult?.data['weeklyPlan'] as List<dynamic>? ?? [];

    if (weeklyPlan.isEmpty) {
      return Center(
        child: Text(
          '주간 계획 데이터가 없습니다',
          style: TypographyUnified.bodySmall.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
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
                color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray50,
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
                          color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TypographyUnified.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: TossDesignSystem.tossBlue,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day,
                              style: TypographyUnified.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                              ),
                            ),
                            if (timeNeeded.isNotEmpty)
                              Text(
                                timeNeeded,
                                style: TypographyUnified.labelSmall.copyWith(
                                  color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
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
                        color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '🎯 $focus',
                        style: TypographyUnified.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: TossDesignSystem.tossBlue,
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
                            style: TypographyUnified.bodySmall.copyWith(
                              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              activity,
                              style: TypographyUnified.bodySmall.copyWith(
                                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
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
                      style: TypographyUnified.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...checklist.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_box_outline_blank,
                            size: 16,
                            color: TossDesignSystem.successGreen,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item,
                              style: TypographyUnified.labelSmall.copyWith(
                                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
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
                        color: TossDesignSystem.successGreen.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: TossDesignSystem.successGreen.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.stars,
                            color: TossDesignSystem.successGreen,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              expectedOutcome,
                              style: TypographyUnified.labelSmall.copyWith(
                                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
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
