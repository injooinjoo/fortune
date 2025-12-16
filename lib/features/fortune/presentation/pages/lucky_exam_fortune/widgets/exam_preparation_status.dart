import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/components/app_card.dart';

class ExamPreparationStatus extends StatelessWidget {
  final String studyPeriod;
  final String confidence;
  final String difficulty;
  final List<String> studyPeriods;
  final List<String> confidenceLevels;
  final List<String> difficultyLevels;
  final ValueChanged<String> onStudyPeriodChanged;
  final ValueChanged<String> onConfidenceChanged;
  final ValueChanged<String> onDifficultyChanged;

  const ExamPreparationStatus({
    super.key,
    required this.studyPeriod,
    required this.confidence,
    required this.difficulty,
    required this.studyPeriods,
    required this.confidenceLevels,
    required this.difficultyLevels,
    required this.onStudyPeriodChanged,
    required this.onConfidenceChanged,
    required this.onDifficultyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추가 정보 (선택사항)',
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
              // 공부 기간
              Text(
                '공부 기간',
                style: DSTypography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: studyPeriods.map((period) {
                  final isSelected = studyPeriod == period;
                  return GestureDetector(
                    onTap: () => onStudyPeriodChanged(period),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.accent.withValues(alpha: 0.2)
                            : colors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: colors.accent)
                            : null,
                      ),
                      child: Text(
                        period,
                        style: DSTypography.labelSmall.copyWith(
                          color: isSelected
                              ? colors.accent
                              : colors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // 자신감
              Text(
                '자신감',
                style: DSTypography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: confidenceLevels.map((level) {
                  final isSelected = confidence == level;
                  return GestureDetector(
                    onTap: () => onConfidenceChanged(level),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? DSColors.success.withValues(alpha: 0.2)
                            : colors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: DSColors.success)
                            : null,
                      ),
                      child: Text(
                        level,
                        style: DSTypography.labelSmall.copyWith(
                          color: isSelected
                              ? DSColors.success
                              : colors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // 난이도
              Text(
                '예상 난이도',
                style: DSTypography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: difficultyLevels.map((level) {
                  final isSelected = difficulty == level;
                  return GestureDetector(
                    onTap: () => onDifficultyChanged(level),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? DSColors.warning.withValues(alpha: 0.2)
                            : colors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: DSColors.warning)
                            : null,
                      ),
                      child: Text(
                        level,
                        style: DSTypography.labelSmall.copyWith(
                          color: isSelected
                              ? DSColors.warning
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
        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),
      ],
    );
  }
}
