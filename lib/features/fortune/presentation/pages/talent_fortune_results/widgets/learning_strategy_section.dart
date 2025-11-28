import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/models/fortune_result.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';

class LearningStrategySection extends StatelessWidget {
  final FortuneResult? fortuneResult;
  final bool isDark;

  const LearningStrategySection({
    super.key,
    required this.fortuneResult,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final learningStrategy = fortuneResult?.data['learningStrategy'] as Map<String, dynamic>?;
    if (learningStrategy == null) {
      return Center(
        child: Text(
          '학습 전략 데이터가 없습니다',
          style: TypographyUnified.bodySmall.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
          ),
        ),
      );
    }

    final optimalMethods = (learningStrategy['optimalMethods'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
    final resources = (learningStrategy['resources'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
    final dailyRoutine = FortuneTextCleaner.cleanNullable(learningStrategy['dailyRoutine'] as String?);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (optimalMethods.isNotEmpty) ...[
          Text(
            '📌 최적의 학습 방법',
            style: TypographyUnified.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: TossDesignSystem.tossBlue,
            ),
          ),
          const SizedBox(height: 8),
          ...optimalMethods.map((method) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: TossDesignSystem.warningOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    method,
                    style: TypographyUnified.bodySmall.copyWith(
                      color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 16),
        ],
        if (resources.isNotEmpty) ...[
          Text(
            '📚 추천 리소스',
            style: TypographyUnified.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: TossDesignSystem.successGreen,
            ),
          ),
          const SizedBox(height: 8),
          ...resources.map((resource) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.book_outlined, size: 16, color: TossDesignSystem.successGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    resource,
                    style: TypographyUnified.bodySmall.copyWith(
                      color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 16),
        ],
        if (dailyRoutine.isNotEmpty) ...[
          Text(
            '⏰ 추천 루틴',
            style: TypographyUnified.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: TossDesignSystem.warningOrange,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TossDesignSystem.warningOrange.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dailyRoutine,
              style: TypographyUnified.bodySmall.copyWith(
                height: 1.6,
                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
