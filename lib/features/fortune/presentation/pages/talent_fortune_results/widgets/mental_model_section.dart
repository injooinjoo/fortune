import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/models/fortune_result.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';

class MentalModelSection extends StatelessWidget {
  final FortuneResult? fortuneResult;
  final DSColorScheme colors;

  const MentalModelSection({
    super.key,
    required this.fortuneResult,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final mentalModel = fortuneResult?.data['mentalModel'] as Map<String, dynamic>?;
    if (mentalModel == null) {
      return Center(
        child: Text(
          '멘탈 모델 데이터가 없습니다',
          style: DSTypography.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
      );
    }

    final thinkingStyle = FortuneTextCleaner.cleanNullable(mentalModel['thinkingStyle'] as String?);
    final decisionPattern = FortuneTextCleaner.cleanNullable(mentalModel['decisionPattern'] as String?);
    final learningStyle = FortuneTextCleaner.cleanNullable(mentalModel['learningStyle'] as String?);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (thinkingStyle.isNotEmpty) ...[
          Text(
            '사고 방식',
            style: DSTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            thinkingStyle,
            style: DSTypography.bodySmall.copyWith(
              height: 1.6,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (decisionPattern.isNotEmpty) ...[
          Text(
            '의사결정 패턴',
            style: DSTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: DSColors.success,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            decisionPattern,
            style: DSTypography.bodySmall.copyWith(
              height: 1.6,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (learningStyle.isNotEmpty) ...[
          Text(
            '효율적인 학습 방법',
            style: DSTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: DSColors.warning,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            learningStyle,
            style: DSTypography.bodySmall.copyWith(
              height: 1.6,
              color: colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
