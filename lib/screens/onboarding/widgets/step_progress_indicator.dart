import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/providers/user_settings_provider.dart';

class StepProgressIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const StepProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.lg),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;

          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < totalSteps - 1 ? DSSpacing.sm : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: (isCompleted || isCurrent) ? colors.accent : colors.border,
              ),
            ).animate(delay: Duration(milliseconds: index * 100))
             .scaleX(begin: 0, duration: 400.ms, curve: Curves.easeOut),
          );
        }),
      ),
    );
  }
}

class TossStepIndicator extends ConsumerWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;

  const TossStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepTitles = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(typographyThemeProvider);
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg, vertical: DSSpacing.md),
      child: Column(
        children: [
          // Progress bar
          StepProgressIndicator(
            currentStep: currentStep,
            totalSteps: totalSteps,
          ),

          const SizedBox(height: DSSpacing.md),

          // Step counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stepTitles.isNotEmpty && currentStep <= stepTitles.length
                  ? stepTitles[currentStep - 1]
                  : '단계 $currentStep',
                style: typography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                '$currentStep / $totalSteps',
                style: typography.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}