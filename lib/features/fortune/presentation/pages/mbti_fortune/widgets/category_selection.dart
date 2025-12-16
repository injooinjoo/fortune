import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortune/core/design_system/design_system.dart';

class CategorySelection extends StatelessWidget {
  final List<String> selectedCategories;
  final Function(String) onCategoryToggle;

  static const List<Map<String, dynamic>> categories = [
    {'label': '연애운', 'icon': Icons.favorite, 'color': Color(0xFFEC4899)},
    {'label': '직업운', 'icon': Icons.work, 'color': Color(0xFF3B82F6)},
    {'label': '재물운', 'icon': Icons.attach_money, 'color': Color(0xFF10B981)},
    {'label': '건강운', 'icon': Icons.health_and_safety, 'color': Color(0xFFF59E0B)},
    {'label': '대인관계', 'icon': Icons.people, 'color': Color(0xFF8B5CF6)},
    {'label': '학업운', 'icon': Icons.school, 'color': Color(0xFF06B6D4)},
  ];

  const CategorySelection({
    super.key,
    required this.selectedCategories,
    required this.onCategoryToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '어떤 운을 보고 싶으신가요?',
          style: DSTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final isSelected = selectedCategories.contains(cat['label']);
            return GestureDetector(
              onTap: () {
                onCategoryToggle(cat['label'] as String);
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (cat['color'] as Color).withValues(alpha: 0.1)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? (cat['color'] as Color)
                        : colors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 16,
                      color: isSelected
                          ? (cat['color'] as Color)
                          : colors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat['label'] as String,
                      style: DSTypography.bodySmall.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? (cat['color'] as Color)
                            : colors.textSecondary,
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
