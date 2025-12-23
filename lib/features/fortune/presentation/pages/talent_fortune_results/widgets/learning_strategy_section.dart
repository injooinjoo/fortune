import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/models/fortune_result.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';

class LearningStrategySection extends StatelessWidget {
  final FortuneResult? fortuneResult;
  final DSColorScheme colors;

  const LearningStrategySection({
    super.key,
    required this.fortuneResult,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final learningStrategy = fortuneResult?.data['learningStrategy'] as Map<String, dynamic>?;
    if (learningStrategy == null) {
      return Center(
        child: Text(
          '학습 전략 데이터가 없습니다',
          style: DSTypography.bodySmall.copyWith(
            color: colors.textSecondary,
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
            style: DSTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.accent,
            ),
          ),
          const SizedBox(height: 8),
          ...optimalMethods.map((method) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline, size: 16, color: DSColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    method,
                    style: DSTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
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
            style: DSTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: DSColors.success,
            ),
          ),
          const SizedBox(height: 8),
          ...resources.map((resource) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.book_outlined, size: 16, color: DSColors.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    resource,
                    style: DSTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
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
            style: DSTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: DSColors.warning,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DSColors.warning.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dailyRoutine,
              style: DSTypography.bodySmall.copyWith(
                height: 1.6,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
