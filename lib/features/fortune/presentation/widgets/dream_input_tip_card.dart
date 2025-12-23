import 'package:flutter/material.dart';
import '../../../../core/components/app_card.dart';
import '../../../../core/design_system/design_system.dart';

/// 꿈 해몽 입력 도움말 카드
class DreamInputTipCard extends StatelessWidget {
  const DreamInputTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tips_and_updates,
                color: DSColors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '📝 Tip. 꿈 내용을 이렇게 작성해보세요!',
                style: DSTypography.headingSmall.copyWith(
                  color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildTipItem(
            isDark: isDark,
            number: '1',
            text: '누가 나왔는지 구체적으로 적어주세요.',
          ),
          const SizedBox(height: 8),

          _buildTipItem(
            isDark: isDark,
            number: '2',
            text: '꿈의 장소와 배경을 묘사해주세요.',
          ),
          const SizedBox(height: 8),

          _buildTipItem(
            isDark: isDark,
            number: '3',
            text: '꿈 속에서 벌어진 사건을 순서대로 적어주세요.',
          ),
          const SizedBox(height: 8),

          _buildTipItem(
            isDark: isDark,
            number: '4',
            text: '꿈에 나타난 상징적인 요소들을 빠짐없이 적어주세요.',
          ),
          const SizedBox(height: 8),

          _buildTipItem(
            isDark: isDark,
            number: '5',
            text: '꿈 속에서 & 꿈에서 깬 뒤의 감정 상태를 표현해 주세요.',
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem({
    required bool isDark,
    required String number,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: DSColors.accent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: DSTypography.bodySmall.copyWith(
                color: DSColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: DSTypography.bodySmall.copyWith(
              color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
