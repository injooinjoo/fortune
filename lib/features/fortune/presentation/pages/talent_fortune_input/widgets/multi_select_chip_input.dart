import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';

class MultiSelectChipInput extends StatelessWidget {
  final List<String> options;
  final Set<String> selectedValues;
  final Function(Set<String>) onSelectionChanged;
  final String? helperText;

  const MultiSelectChipInput({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.onSelectionChanged,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (helperText != null) ...[
          Text(
            helperText!,
            style: TypographyUnified.labelMedium.copyWith(
              color: TossDesignSystem.gray600,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            return InkWell(
              onTap: () {
                final newSelection = Set<String>.from(selectedValues);
                if (isSelected) {
                  newSelection.remove(option);
                } else {
                  newSelection.add(option);
                }
                TossDesignSystem.hapticLight();
                onSelectionChanged(newSelection);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                      : TossDesignSystem.gray100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? TossDesignSystem.tossBlue : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  option,
                  style: TypographyUnified.bodySmall.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? TossDesignSystem.tossBlue : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
