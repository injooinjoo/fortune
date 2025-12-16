import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/design_system/design_system.dart';

class GenderInput extends StatelessWidget {
  final String? selectedGender;
  final Function(String) onGenderSelected;

  const GenderInput({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildGenderButton('남성', 'male', context),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGenderButton('여성', 'female', context),
        ),
      ],
    );
  }

  Widget _buildGenderButton(String label, String value, BuildContext context) {
    final colors = context.colors;
    final isSelected = selectedGender == value;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onGenderSelected(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accent.withValues(alpha: 0.1)
              : colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: DSTypography.labelLarge.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? colors.accent : null,
            ),
          ),
        ),
      ),
    );
  }
}
