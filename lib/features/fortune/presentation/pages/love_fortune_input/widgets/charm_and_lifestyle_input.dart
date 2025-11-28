import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_theme.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          style: TypographyUnified.labelLarge.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '여러 개 선택 가능',
          style: TypographyUnified.labelMedium.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
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
                TossDesignSystem.hapticLight();
              },
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
                  charm,
                  style: TypographyUnified.bodySmall.copyWith(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
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
          style: TypographyUnified.labelLarge.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
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
                    TossDesignSystem.hapticLight();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                          : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
                      border: Border.all(
                        color: isSelected
                            ? TossDesignSystem.tossBlue
                            : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          lifestyleOption['emoji'] as String,
                          style: TypographyUnified.heading3,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lifestyleOption['text'] as String,
                          style: TypographyUnified.labelMedium.copyWith(
                            color: isSelected
                                ? TossDesignSystem.tossBlue
                                : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
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
