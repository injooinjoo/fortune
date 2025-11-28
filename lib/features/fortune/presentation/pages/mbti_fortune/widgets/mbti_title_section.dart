import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';

class MbtiTitleSection extends StatelessWidget {
  const MbtiTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '당신의 MBTI를\n선택해주세요',
          style: TypographyUnified.heading1.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '16가지 성격 유형 중 나와 맞는 유형을 선택하세요',
          style: TypographyUnified.bodySmall.copyWith(
            color: isDark
                ? TossDesignSystem.grayDark100
                : TossDesignSystem.gray600,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
