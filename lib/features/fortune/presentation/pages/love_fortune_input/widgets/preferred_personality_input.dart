import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_theme.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            color: TossTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '최대 4개까지 선택',
            style: TypographyUnified.labelMedium.copyWith(
              color: TossTheme.primaryBlue,
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
                      TossDesignSystem.hapticLight();
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                      : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  trait,
                  style: TypographyUnified.bodySmall.copyWith(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : canSelect
                            ? (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack)
                            : TossTheme.textGray400,
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
