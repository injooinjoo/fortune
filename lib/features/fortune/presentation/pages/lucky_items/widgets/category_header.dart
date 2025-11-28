import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import 'category_model.dart';

/// 카테고리 헤더
class CategoryHeader extends StatelessWidget {
  final CategoryModel category;

  const CategoryHeader({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: category.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(category.icon, style: TypographyUnified.displayLarge),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  style: TypographyUnified.heading3.copyWith(
                    fontWeight: FontWeight.w700,
                    color: category.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category.description,
                  style: TypographyUnified.bodySmall.copyWith(
                    color: TossDesignSystem.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
