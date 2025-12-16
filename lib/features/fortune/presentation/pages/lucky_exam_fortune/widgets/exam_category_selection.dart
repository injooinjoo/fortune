import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../domain/models/conditions/lucky_exam_fortune_conditions.dart';

class ExamCategorySelection extends StatelessWidget {
  final String selectedCategory;
  final String? selectedSubType;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String?> onSubTypeChanged;

  const ExamCategorySelection({
    super.key,
    required this.selectedCategory,
    required this.selectedSubType,
    required this.onCategoryChanged,
    required this.onSubTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final categories = LuckyExamFortuneConditions.getCategoryList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시험 카테고리 선택',
          style: DSTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '어떤 시험을 준비하시나요?',
                style: DSTypography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  final isSelected = selectedCategory == category;
                  return GestureDetector(
                    onTap: () {
                      onCategoryChanged(category);
                      onSubTypeChanged(null); // 카테고리 변경 시 초기화
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.accent
                            : colors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? Border.all(
                                color: colors.accent, width: 2)
                            : null,
                      ),
                      child: Text(
                        category,
                        style: DSTypography.labelSmall.copyWith(
                          color: isSelected
                              ? Colors.white
                              : colors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // 세부 시험 선택 (카테고리 선택 시 표시)
              if (selectedCategory.isNotEmpty) ...[
                const SizedBox(height: 20),
                Divider(color: colors.border),
                const SizedBox(height: 16),
                Text(
                  '세부 시험 선택',
                  style: DSTypography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: LuckyExamFortuneConditions.getSubTypeList(
                          selectedCategory)
                      .map((subType) {
                    final isSelected = selectedSubType == subType;
                    return GestureDetector(
                      onTap: () => onSubTypeChanged(subType),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? DSColors.success
                              : colors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          subType,
                          style: DSTypography.labelSmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : colors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3),
      ],
    );
  }
}
