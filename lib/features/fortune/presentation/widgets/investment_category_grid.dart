import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design_system/design_system.dart';
import '../../data/models/investment_ticker.dart';

/// ChatGPT 스타일의 투자 카테고리 선택 그리드
class InvestmentCategoryGrid extends StatelessWidget {
  final InvestmentCategory? selectedCategory;
  final ValueChanged<InvestmentCategory> onCategorySelected;

  const InvestmentCategoryGrid({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            '어떤 투자에 관심이 있으신가요?',
            style: DSTypography.headingMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: DSColors.textPrimary,
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: InvestmentCategory.values.map((category) {
            final isSelected = selectedCategory == category;
            return _CategoryCard(
              category: category,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.lightImpact();
                onCategorySelected(category);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final InvestmentCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ChatGPT 스타일 색상
    final backgroundColor = isSelected
        ? (isDark
            ? DSColors.accent.withValues(alpha: 0.15)
            : DSColors.accent.withValues(alpha: 0.08))
        : (isDark ? DSColors.surface : Colors.white);

    final borderColor = isSelected ? DSColors.accent : DSColors.border;

    final textColor = isSelected ? DSColors.accent : DSColors.textPrimary;

    final descColor = DSColors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Image.asset(
                  category.imagePath,
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: DSColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              category.label,
              style: DSTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              category.description,
              style: DSTypography.labelSmall.copyWith(
                color: descColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
