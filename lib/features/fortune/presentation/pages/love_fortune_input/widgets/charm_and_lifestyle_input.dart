import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/design_system/design_system.dart';

/// Section 7: 나의 매력 & 라이프스타일
class CharmAndLifestyleInput extends StatelessWidget {
  final Set<String> selectedCharmPoints;
  final String? lifestyle;
  final ValueChanged<String> onCharmPointToggled;
  final ValueChanged<String> onLifestyleChanged;

  const CharmAndLifestyleInput({
    super.key,
    required this.selectedCharmPoints,
    required this.lifestyle,
    required this.onCharmPointToggled,
    required this.onLifestyleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final charmOptions = [
      '유머감각', '배려심', '경제력', '외모', '성실함', '지적능력',
      '사교성', '요리실력', '운동신경', '예술감각', '리더십', '따뜻함'
    ];

    final lifestyles = [
      {'id': 'employee', 'text': '직장인', 'emoji': '💼'},
      {'id': 'student', 'text': '학생', 'emoji': '📚'},
      {'id': 'freelancer', 'text': '프리랜서', 'emoji': '💻'},
      {'id': 'business', 'text': '사업가', 'emoji': '🏢'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 매력 포인트
        Text(
          '나의 매력 포인트',
          style: DSTypography.labelLarge.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '여러 개 선택 가능',
          style: DSTypography.labelMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: charmOptions.map((charm) {
            final isSelected = selectedCharmPoints.contains(charm);
            return InkWell(
              onTap: () {
                onCharmPointToggled(charm);
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.accent.withValues(alpha: 0.1)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? colors.accent : colors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  charm,
                  style: DSTypography.bodySmall.copyWith(
                    color: isSelected ? colors.accent : colors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // 라이프스타일
        Text(
          '라이프스타일',
          style: DSTypography.labelLarge.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: lifestyles.map((lifestyleOption) {
            final lifestyleId = lifestyleOption['id'] as String;
            final isSelected = lifestyle == lifestyleId;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    onLifestyleChanged(lifestyleId);
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.accent.withValues(alpha: 0.1)
                          : colors.surface,
                      border: Border.all(
                        color: isSelected ? colors.accent : colors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          lifestyleOption['emoji'] as String,
                          style: DSTypography.headingMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lifestyleOption['text'] as String,
                          style: DSTypography.labelMedium.copyWith(
                            color: isSelected ? colors.accent : colors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
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
