import 'package:flutter/material.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/components/app_card.dart';

/// 이벤트 카테고리 정의
enum EventCategory {
  job('직업/면접', Icons.work, TossDesignSystem.tossBlue, '취업, 면접, 이직, 승진 등 커리어 관련'),
  dating('연애/소개팅', Icons.favorite, TossDesignSystem.errorRed, '연애, 소개팅, 고백, 프러포즈 등'),
  finance('금전/계약', Icons.attach_money, TossDesignSystem.successGreen, '투자, 계약, 대출, 부동산 거래 등'),
  study('학업/시험', Icons.school, TossDesignSystem.warningOrange, '시험, 입학, 학업, 자격증 등'),
  relationship('대인관계', Icons.people, TossDesignSystem.purple, '친구, 가족, 동료와의 관계');

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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이벤트 유형 선택',
            style: TossDesignSystem.heading3.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '운세를 확인하고 싶은 일의 종류를 선택해주세요',
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
            ),
          ),
          const SizedBox(height: 20),
          ...EventCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? category.color.withValues(alpha: 0.1)
              : (isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? category.color
                : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.label,
                    style: TossDesignSystem.heading4.copyWith(
                      color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description,
                    style: TossDesignSystem.body3.copyWith(
                      color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: category.color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
