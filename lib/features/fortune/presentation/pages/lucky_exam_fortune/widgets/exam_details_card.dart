import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../../../core/widgets/date_picker/numeric_date_input.dart';
import '../../../../domain/models/conditions/lucky_exam_fortune_conditions.dart';

class ExamDetailsCard extends StatelessWidget {
  final DateTime? selectedExamDate;
  final String? targetScore;
  final String preparationStatus;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String> onTargetScoreChanged;
  final ValueChanged<String> onPreparationStatusChanged;

  const ExamDetailsCard({
    super.key,
    required this.selectedExamDate,
    required this.targetScore,
    required this.preparationStatus,
    required this.onDateChanged,
    required this.onTargetScoreChanged,
    required this.onPreparationStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시험 정보',
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
              // 시험 예정일
              NumericDateInput(
                label: '시험 예정일',
                selectedDate: selectedExamDate,
                onDateChanged: onDateChanged,
                minDate: DateTime(1900),
                maxDate: DateTime(2300),
              ),

              const SizedBox(height: 20),

              // 목표 점수/등급 (선택사항)
              Text(
                '목표 점수/등급 (선택사항)',
                style: DSTypography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: onTargetScoreChanged,
                decoration: InputDecoration(
                  hintText: '예: 1등급, 900점, 70점 이상',
                  hintStyle: DSTypography.bodyMedium.copyWith(
                    color: colors.textTertiary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.accent),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 준비 상태
              Text(
                '현재 준비 상태',
                style: DSTypography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: LuckyExamFortuneConditions.preparationStatusOptions
                    .map((status) {
                  final isSelected = preparationStatus == status;
                  return GestureDetector(
                    onTap: () => onPreparationStatusChanged(status),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? DSColors.warning
                            : colors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
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
            ],
          ),
        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),
      ],
    );
  }
}
