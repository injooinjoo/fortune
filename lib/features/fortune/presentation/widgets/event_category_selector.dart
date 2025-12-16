import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/components/app_card.dart';

/// 이벤트 카테고리 정의
enum EventCategory {
  job('직업/면접', Icons.work, DSColors.accent, '취업, 면접, 이직, 승진 등 커리어 관련'),
  dating('연애/소개팅', Icons.favorite, DSColors.error, '연애, 소개팅, 고백, 프러포즈 등'),
  finance('금전/계약', Icons.attach_money, DSColors.success, '투자, 계약, 대출, 부동산 거래 등'),
  study('학업/시험', Icons.school, DSColors.warning, '시험, 입학, 학업, 자격증 등'),
  relationship('대인관계', Icons.people, DSColors.accentSecondary, '친구, 가족, 동료와의 관계');

  final String label;
  final IconData icon;
  final Color color;
  final String description;

  const EventCategory(this.label, this.icon, this.color, this.description);
}

/// 이벤트 카테고리 선택 위젯
class EventCategorySelector extends StatelessWidget {
  final EventCategory? selectedCategory;
  final ValueChanged<EventCategory> onCategorySelected;

  const EventCategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '이벤트 유형 선택',
              style: DSTypography.headingMedium.copyWith(
                color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '운세를 확인하고 싶은 일의 종류를 선택해주세요',
              style: DSTypography.bodyMedium.copyWith(
                color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...EventCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CategoryCard(
                category: category,
                isSelected: selectedCategory == category,
                onTap: () => onCategorySelected(category),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final EventCategory category;
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? category.color.withValues(alpha: 0.08)
              : (isDark ? DSColors.surface.withValues(alpha: 0.5) : DSColors.backgroundSecondary),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? category.color
                : (isDark ? DSColors.border : DSColors.border),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.label,
                    style: DSTypography.headingSmall.copyWith(
                      color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    category.description,
                    style: DSTypography.bodySmall.copyWith(
                      color: DSColors.textTertiary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: category.color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
