import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/toss_design_system.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추가 정보 (선택사항)',
          style: TossDesignSystem.body1.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? TossDesignSystem.textPrimaryDark : null,
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
                style: TossDesignSystem.caption.copyWith(
                  color: isDark
                      ? TossDesignSystem.textSecondaryDark
                      : TossDesignSystem.gray600,
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
                            ? TossDesignSystem.tossBlue.withValues(alpha: 0.2)
                            : (isDark
                                ? TossDesignSystem.cardBackgroundDark
                                : TossDesignSystem.gray100),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: TossDesignSystem.tossBlue)
                            : null,
                      ),
                      child: Text(
                        period,
                        style: TossDesignSystem.caption.copyWith(
                          color: isSelected
                              ? TossDesignSystem.tossBlue
                              : (isDark
                                  ? TossDesignSystem.textPrimaryDark
                                  : TossDesignSystem.gray700),
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
                style: TossDesignSystem.caption.copyWith(
                  color: isDark
                      ? TossDesignSystem.textSecondaryDark
                      : TossDesignSystem.gray600,
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
                            ? TossDesignSystem.successGreen
                                .withValues(alpha: 0.2)
                            : (isDark
                                ? TossDesignSystem.cardBackgroundDark
                                : TossDesignSystem.gray100),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: TossDesignSystem.successGreen)
                            : null,
                      ),
                      child: Text(
                        level,
                        style: TossDesignSystem.caption.copyWith(
                          color: isSelected
                              ? TossDesignSystem.successGreen
                              : (isDark
                                  ? TossDesignSystem.textPrimaryDark
                                  : TossDesignSystem.gray700),
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
                style: TossDesignSystem.caption.copyWith(
                  color: isDark
                      ? TossDesignSystem.textSecondaryDark
                      : TossDesignSystem.gray600,
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
                            ? TossDesignSystem.warningOrange
                                .withValues(alpha: 0.2)
                            : (isDark
                                ? TossDesignSystem.cardBackgroundDark
                                : TossDesignSystem.gray100),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: TossDesignSystem.warningOrange)
                            : null,
                      ),
                      child: Text(
                        level,
                        style: TossDesignSystem.caption.copyWith(
                          color: isSelected
                              ? TossDesignSystem.warningOrange
                              : (isDark
                                  ? TossDesignSystem.textPrimaryDark
                                  : TossDesignSystem.gray700),
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
