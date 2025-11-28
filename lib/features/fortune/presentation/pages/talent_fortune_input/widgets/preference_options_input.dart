import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';

class PreferenceOptionsInput extends StatelessWidget {
  final List<String> options;
  final String? selectedValue;
  final Function(String) onSelect;

  const PreferenceOptionsInput({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        final isSelected = selectedValue == option;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              TossDesignSystem.hapticLight();
              onSelect(option);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                    : TossDesignSystem.gray100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? TossDesignSystem.tossBlue : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: TypographyUnified.buttonMedium.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? TossDesignSystem.tossBlue : null,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: TossDesignSystem.tossBlue,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
