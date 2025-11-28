import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_theme.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// Section 2: 연애 스타일 (다중 선택)
class DatingStylesInput extends StatelessWidget {
  final Set<String> selectedStyles;
  final ValueChanged<String> onStyleToggled;

  const DatingStylesInput({
    super.key,
    required this.selectedStyles,
    required this.onStyleToggled,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final styles = [
      {'id': 'active', 'text': '적극적', 'emoji': '🔥'},
      {'id': 'passive', 'text': '소극적', 'emoji': '🌸'},
      {'id': 'emotional', 'text': '감성적', 'emoji': '💖'},
      {'id': 'logical', 'text': '이성적', 'emoji': '🧠'},
      {'id': 'independent', 'text': '독립적', 'emoji': '🦅'},
      {'id': 'dependent', 'text': '의존적', 'emoji': '🤝'},
      {'id': 'serious', 'text': '진지한', 'emoji': '💍'},
      {'id': 'casual', 'text': '가벼운', 'emoji': '😊'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '여러 개 선택 가능',
          style: TypographyUnified.labelMedium.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: styles.map((style) {
            final styleId = style['id'] as String;
            final isSelected = selectedStyles.contains(styleId);
            return InkWell(
              onTap: () {
                onStyleToggled(styleId);
                TossDesignSystem.hapticLight();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TossDesignSystem.tossBlue
                      : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      style['emoji'] as String,
                      style: TypographyUnified.heading4,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        style['text'] as String,
                        style: TypographyUnified.bodyMedium.copyWith(
                          color: isSelected
                              ? TossDesignSystem.white
                              : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
