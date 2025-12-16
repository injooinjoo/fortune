import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/design_system/design_system.dart';

/// Section 5: 선호 성격 (다중 선택, 최대 4개)
class PreferredPersonalityInput extends StatelessWidget {
  final Set<String> selectedPersonality;
  final ValueChanged<String> onPersonalityToggled;

  const PreferredPersonalityInput({
    super.key,
    required this.selectedPersonality,
    required this.onPersonalityToggled,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final traits = [
      '활발한', '차분한', '유머러스한', '진중한', '외향적인', '내향적인',
      '모험적인', '안정적인', '로맨틱한', '현실적인', '창의적인', '체계적인'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '최대 4개까지 선택',
            style: DSTypography.labelMedium.copyWith(
              color: colors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: traits.map((trait) {
            final isSelected = selectedPersonality.contains(trait);
            final canSelect = selectedPersonality.length < 4 || isSelected;
            return InkWell(
              onTap: canSelect
                  ? () {
                      onPersonalityToggled(trait);
                      HapticFeedback.lightImpact();
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.accent.withValues(alpha: 0.1)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? colors.accent
                        : colors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  trait,
                  style: DSTypography.bodySmall.copyWith(
                    color: isSelected
                        ? colors.accent
                        : canSelect
                            ? colors.textPrimary
                            : colors.textTertiary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
