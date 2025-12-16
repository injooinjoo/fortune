import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

/// 토스 스타일 단계 진행 표시기
class MovingStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const MovingStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalSteps,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: index <= currentStep 
                ? DSColors.accent 
                : DSColors.border,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}