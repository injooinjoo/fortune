import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';

class MbtiTitleSection extends StatelessWidget {
  const MbtiTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '당신의 MBTI를\n선택해주세요',
          style: DSTypography.displayLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '16가지 성격 유형 중 나와 맞는 유형을 선택하세요',
          style: DSTypography.bodySmall.copyWith(
            color: colors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
