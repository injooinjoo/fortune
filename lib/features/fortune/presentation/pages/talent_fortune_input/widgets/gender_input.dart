import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';

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
    final isSelected = selectedGender == value;
    return InkWell(
      onTap: () {
        TossDesignSystem.hapticLight();
        onGenderSelected(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
        child: Center(
          child: Text(
            label,
            style: TypographyUnified.buttonMedium.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? TossDesignSystem.tossBlue : null,
            ),
          ),
        ),
      ),
    );
  }
}
