import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/design_system/design_system.dart';

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
    final colors = context.colors;

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
          style: DSTypography.labelMedium.copyWith(
            color: colors.textSecondary,
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
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.accent
                      : colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? colors.accent
                        : colors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      style['emoji'] as String,
                      style: DSTypography.headingSmall,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        style['text'] as String,
                        style: DSTypography.bodyMedium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : colors.textPrimary,
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
