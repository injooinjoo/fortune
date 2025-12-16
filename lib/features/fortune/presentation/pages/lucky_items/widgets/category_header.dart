import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import 'category_model.dart';

/// 카테고리 헤더 - ChatGPT 스타일 미니멀 디자인
class CategoryHeader extends StatelessWidget {
  final CategoryModel category;

  const CategoryHeader({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        // 미니멀 아이콘 (그레이 톤)
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.backgroundSecondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            category.icon,
            size: 20,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.title,
                style: DSTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                category.description,
                style: DSTypography.labelSmall.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
