import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';

class LuckyItems extends StatelessWidget {
  final Map<String, dynamic> items;

  const LuckyItems({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.stars,
              size: 20,
              color: DSColors.warning),
            const SizedBox(width: 8),
            Text(
              '오늘의 행운 아이템',
              style: DSTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.entries.map((entry) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: DSColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DSColors.warning.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${entry.value}',
              style: DSTypography.bodySmall.copyWith(
                color: DSColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}
