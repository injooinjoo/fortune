import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/toss_design_system.dart';
import '../../../core/providers/user_settings_provider.dart';

class TossProgressIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  
  const TossProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: (isCompleted || isCurrent) ? TossDesignSystem.primaryBlue : TossDesignSystem.gray200,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Progress bar
          TossProgressIndicator(
            currentStep: currentStep,
            totalSteps: totalSteps,
          ),
          
          const SizedBox(height: 12),
          
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
                  color: TossDesignSystem.gray700,
                ),
              ),
              Text(
                '$currentStep / $totalSteps',
                style: typography.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: TossDesignSystem.gray500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}