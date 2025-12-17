import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/design_system/design_system.dart';

class GridSelectionWidget extends StatelessWidget {
  final List<String> options;
  final int columns;
  final String? selectedValue;
  final Function(String) onSelect;

  const GridSelectionWidget({
    super.key,
    required this.options,
    required this.columns,
    required this.onSelect,
    this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      childAspectRatio: 2.2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: options.map((option) {
        final isSelected = option == selectedValue;
        return OptionChip(
          option: option,
          isSelected: isSelected,
          onSelect: onSelect,
        );
      }).toList(),
    );
  }
}

class OptionChip extends StatelessWidget {
  final String option;
  final bool isSelected;
  final Function(String) onSelect;

  const OptionChip({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onSelect(option);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? colors.accent : colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.accent : colors.border,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            option,
            style: DSTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : colors.textPrimary,
            ),
          ),
        ),
      ).animate()
        .scale(
          duration: 100.ms,
          begin: const Offset(1, 1),
          end: const Offset(0.95, 0.95),
        )
        .then()
        .scale(
          duration: 100.ms,
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
        ),
    );
  }
}

class TitleSection extends StatelessWidget {
  const TitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🧬 나만의 성격 DNA',
          style: DSTypography.displayLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'MBTI × 혈액형 × 별자리 × 띠\n4가지 조합으로 만드는 특별한 나',
          style: DSTypography.bodySmall.copyWith(
            color: colors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
