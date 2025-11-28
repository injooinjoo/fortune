import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';

class TalentInputTitle extends StatelessWidget {
  const TalentInputTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '당신의 숨은 재능을\n찾아드릴게요',
          style: TypographyUnified.heading1.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '사주팔자와 성향을 분석해서\n맞춤 재능 가이드를 제공해드려요',
          style: TypographyUnified.bodySmall.copyWith(
            color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray600,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
