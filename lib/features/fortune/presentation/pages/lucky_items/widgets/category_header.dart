import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import 'category_model.dart';

/// 카테고리 헤더 - ChatGPT 스타일 미니멀 디자인
class CategoryHeader extends StatelessWidget {
  final CategoryModel category;

  const CategoryHeader({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // 미니멀 아이콘 (그레이 톤)
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.gray800 : TossDesignSystem.gray100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            category.icon,
            size: 20,
            color: isDark ? TossDesignSystem.gray300 : TossDesignSystem.gray700,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.title,
                style: TypographyUnified.heading4.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.gray100 : TossDesignSystem.gray900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                category.description,
                style: TypographyUnified.caption.copyWith(
                  color: TossDesignSystem.gray500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
