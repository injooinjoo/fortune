import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/models/recommendation_chip.dart';

/// 운세 추천 칩 그리드
class FortuneChipGrid extends StatelessWidget {
  final List<RecommendationChip> chips;
  final void Function(RecommendationChip chip) onChipTap;

  const FortuneChipGrid({
    super.key,
    required this.chips,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: DSSpacing.sm,
      runSpacing: DSSpacing.sm,
      alignment: WrapAlignment.center,
      children: chips.map((chip) {
        return ActionChip(
          avatar: Icon(
            chip.icon,
            size: 18,
            color: chip.color,
          ),
          label: Text(
            chip.label,
            style: typography.labelMedium.copyWith(
              color: colors.textPrimary,
            ),
          ),
          backgroundColor: isDark
              ? colors.backgroundSecondary
              : colors.surface,
          side: BorderSide(
            color: chip.color.withValues(alpha: 0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadius.lg),
          ),
          onPressed: () {
            DSHaptics.light();
            onChipTap(chip);
          },
        );
      }).toList(),
    );
  }
}
