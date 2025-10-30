import 'package:flutter/material.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';

/// 꿈 해몽 입력 도움말 카드
class DreamInputTipCard extends StatelessWidget {
  const DreamInputTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TossCard(
      padding: const EdgeInsets.all(TossTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                color: TossTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: TossTheme.spacingS),
              Text(
                '📝 Tip. 꿈 내용을 이렇게 작성해보세요!',
                style: TossTheme.heading4.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: TossTheme.spacingM),

          _buildTipItem(
            isDark: isDark,
            number: '1',
            text: '누가 나왔는지 구체적으로 적어주세요.',
          ),
          const SizedBox(height: TossTheme.spacingS),

          _buildTipItem(
            isDark: isDark,
            number: '2',
            text: '꿈의 장소와 배경을 묘사해주세요.',
          ),
          const SizedBox(height: TossTheme.spacingS),

          _buildTipItem(
            isDark: isDark,
            number: '3',
            text: '꿈 속에서 벌어진 사건을 순서대로 적어주세요.',
          ),
          const SizedBox(height: TossTheme.spacingS),

          _buildTipItem(
            isDark: isDark,
            number: '4',
            text: '꿈에 나타난 상징적인 요소들을 빠짐없이 적어주세요.',
          ),
          const SizedBox(height: TossTheme.spacingS),

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
            color: TossTheme.primaryBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TossTheme.body3.copyWith(
                color: TossTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: TossTheme.spacingS),
        Expanded(
          child: Text(
            text,
            style: TossTheme.body3.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
