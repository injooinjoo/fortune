import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/toss_theme.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: TossTheme.spacingL),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < totalSteps - 1 ? TossTheme.spacingS : 0),
              decoration: TossTheme.progressBarDecoration(
                isActive: isCompleted || isCurrent,
              ),
            ).animate(delay: Duration(milliseconds: index * 100))
             .scaleX(begin: 0, duration: 400.ms, curve: Curves.easeOut),
          );
        }),
      ),
    );
  }
}

class TossStepIndicator extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '$currentStep / $totalSteps',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}