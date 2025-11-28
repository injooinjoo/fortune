import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';

class LuckyItems extends StatelessWidget {
  final Map<String, dynamic> items;

  const LuckyItems({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.stars,
              size: 20,
              color: TossDesignSystem.warningOrange),
            const SizedBox(width: 8),
            Text(
              '오늘의 행운 아이템',
              style: TypographyUnified.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
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
              color: TossDesignSystem.warningOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TossDesignSystem.warningOrange.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${entry.value}',
              style: TypographyUnified.bodySmall.copyWith(
                color: TossDesignSystem.warningOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}
