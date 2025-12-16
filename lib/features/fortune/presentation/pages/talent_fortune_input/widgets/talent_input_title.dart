import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';

class TalentInputTitle extends StatelessWidget {
  const TalentInputTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '당신의 숨은 재능을\n찾아드릴게요',
          style: DSTypography.headingLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '사주팔자와 성향을 분석해서\n맞춤 재능 가이드를 제공해드려요',
          style: DSTypography.bodySmall.copyWith(
            color: colors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
