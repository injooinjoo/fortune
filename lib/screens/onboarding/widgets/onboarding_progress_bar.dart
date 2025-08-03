import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

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
    // Don't show progress on first step
    if (currentStep == 0) {
      return const SizedBox.shrink();
    }
    
    // Adjust progress calculation to exclude social login step
    final adjustedCurrentStep = currentStep;
    final adjustedTotalSteps = totalSteps - 1;
    
    return Container(
      height: context.fortuneTheme.bottomSheetStyles.handleHeight,
      child: LinearProgressIndicator(
        value: adjustedCurrentStep / adjustedTotalSteps,
        backgroundColor: context.fortuneTheme.dividerColor.withValues(alpha: 0.5),
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}