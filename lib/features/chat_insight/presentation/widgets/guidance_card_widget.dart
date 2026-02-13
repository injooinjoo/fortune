import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../data/models/chat_insight_result.dart';

/// 행동 가이드 카드 (do/don't 섹션)
class GuidanceCardWidget extends StatelessWidget {
  final InsightGuidance guidance;

  const GuidanceCardWidget({super.key, required this.guidance});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    if (guidance.doList.isEmpty && guidance.dontList.isEmpty) {
      return const SizedBox.shrink();
    }

    return DSCard.elevated(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  color: colors.textSecondary, size: 20),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '행동 가이드',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // Do 섹션
          if (guidance.doList.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.check_circle, color: colors.success, size: 16),
                const SizedBox(width: DSSpacing.xxs),
                Text(
                  '이렇게 해보세요',
                  style: typography.labelMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
            ...guidance.doList.map((item) => _buildGuidanceItem(
                  context,
                  item: item,
                  isPositive: true,
                )),
          ],

          // Don't 섹션
          if (guidance.dontList.isNotEmpty) ...[
            if (guidance.doList.isNotEmpty) ...[
              const SizedBox(height: DSSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: DSSpacing.md),
            ],
            Row(
              children: [
                Icon(Icons.cancel_outlined, color: colors.error, size: 16),
                const SizedBox(width: DSSpacing.xxs),
                Text(
                  '이건 피해주세요',
                  style: typography.labelMedium.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
            ...guidance.dontList.map((item) => _buildGuidanceItem(
                  context,
                  item: item,
                  isPositive: false,
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildGuidanceItem(
    BuildContext context, {
    required GuidanceItem item,
    required bool isPositive,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Semantics(
      label: '${isPositive ? "추천 행동" : "주의 행동"}: ${item.text}. '
          '예상 효과: ${item.expectedEffect}',
      child: Padding(
        padding: const EdgeInsets.only(bottom: DSSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.text,
              style: typography.bodyMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: DSSpacing.xxs),
            Text(
              '→ ${item.expectedEffect}',
              style: typography.bodySmall.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
