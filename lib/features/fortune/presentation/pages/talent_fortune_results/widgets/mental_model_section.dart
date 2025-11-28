import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/models/fortune_result.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';

class MentalModelSection extends StatelessWidget {
  final FortuneResult? fortuneResult;
  final bool isDark;

  const MentalModelSection({
    super.key,
    required this.fortuneResult,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final mentalModel = fortuneResult?.data['mentalModel'] as Map<String, dynamic>?;
    if (mentalModel == null) {
      return Center(
        child: Text(
          '멘탈 모델 데이터가 없습니다',
          style: TypographyUnified.bodySmall.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
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
            style: TypographyUnified.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: TossDesignSystem.tossBlue,
            ),
          ),
          SizedBox(height: 6),
          Text(
            thinkingStyle,
            style: TypographyUnified.bodySmall.copyWith(
              height: 1.6,
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (decisionPattern.isNotEmpty) ...[
          Text(
            '의사결정 패턴',
            style: TypographyUnified.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: TossDesignSystem.successGreen,
            ),
          ),
          SizedBox(height: 6),
          Text(
            decisionPattern,
            style: TypographyUnified.bodySmall.copyWith(
              height: 1.6,
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (learningStyle.isNotEmpty) ...[
          Text(
            '효율적인 학습 방법',
            style: TypographyUnified.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: TossDesignSystem.warningOrange,
            ),
          ),
          SizedBox(height: 6),
          Text(
            learningStyle,
            style: TypographyUnified.bodySmall.copyWith(
              height: 1.6,
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
            ),
          ),
        ],
      ],
    );
  }
}
