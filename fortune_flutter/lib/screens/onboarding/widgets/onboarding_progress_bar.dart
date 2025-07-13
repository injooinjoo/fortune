import 'package:flutter/material.dart';

class OnboardingProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  
  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show progress bar for social login step (step 0)
    if (currentStep == 0) {
      return SizedBox.shrink();
    }
    
    // Adjust progress calculation to exclude social login step
    final adjustedCurrentStep = currentStep;
    final adjustedTotalSteps = totalSteps - 1;
    
    return Container(
      height: 4,
      child: LinearProgressIndicator(
        value: adjustedCurrentStep / adjustedTotalSteps,
        backgroundColor: Colors.grey[200],
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}