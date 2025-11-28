import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onSelect(option);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue)
              : (isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue)
                : (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray200),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            option,
            style: TypographyUnified.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? TossDesignSystem.white
                  : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '당신만의 성격 DNA를\n발견해보세요',
          style: TypographyUnified.heading1.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.white : TossDesignSystem.gray900,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'MBTI, 혈액형, 별자리, 띠를 조합하여\n특별한 성격 분석 결과를 확인하세요',
          style: TypographyUnified.bodySmall.copyWith(
            color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray600,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
