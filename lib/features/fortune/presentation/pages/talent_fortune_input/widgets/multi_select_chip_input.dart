import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/design_system/design_system.dart';

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
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (helperText != null) ...[
          Text(
            helperText!,
            style: DSTypography.labelMedium.copyWith(
              color: colors.textSecondary,
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
                HapticFeedback.lightImpact();
                onSelectionChanged(newSelection);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.accent.withValues(alpha: 0.1)
                      : colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? colors.accent : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  option,
                  style: DSTypography.bodySmall.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? colors.accent : null,
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
