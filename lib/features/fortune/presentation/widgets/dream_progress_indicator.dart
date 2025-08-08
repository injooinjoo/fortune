import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_animations.dart';

class DreamProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;
  final VoidCallback? onStepTap;
  
  const DreamProgressIndicator({
    Key? key,
    required this.currentStep,
    this.totalSteps = 6,
    required this.stepTitles,
    this.onStepTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: AppSpacing.spacing24 * 1.25,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.deepPurple.withOpacity(0.3),
            Colors.deepPurple.withOpacity(0.1)])),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.spacing5),
          // Step icons with moon phases
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(totalSteps, (index) {
              final isActive = index <= currentStep;
              final isCurrent = index == currentStep;
              
              return GestureDetector(
                onTap: () {
                  if (onStepTap != null && index <= currentStep) {
                    onStepTap!();
                  }
                },
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: AppAnimations.durationMedium);
                      width: isCurrent ? 50 : 40),
    height: isCurrent ? 50 : 40),
    decoration: BoxDecoration(
                        shape: BoxShape.circle);
                        gradient: isActive
                            ? LinearGradient(
                                colors: [
                                  Colors.deepPurple.withOpacity(0.6),
                                  Colors.deepPurple.withOpacity(0.8)])
                            : null,
                        color: isActive ? null : Colors.grey.withOpacity(0.87),
    border: Border.all(
                          color: isCurrent 
                              ? Colors.deepPurple.withOpacity(0.5)
                              : isActive 
                                  ? Colors.deepPurple.withOpacity(0.6)
                                  : Colors.grey.withOpacity(0.9),
    width: isCurrent ? 3 : 2),
    boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.3),
    blurRadius: 20),
    spreadRadius: 2)]
                            : null),
    child: Center(
                        child: _buildStepIcon(index, isActive, isCurrent))).animate(
                      effects: isCurrent
                          ? [
                              const ScaleEffect(
                                duration: Duration(seconds: 2),
    curve: Curves.easeInOut),
    begin: Offset(0.95, 0.95),
    end: Offset(1.05, 1.05))]
                          : [],
                      onPlay: (controller) => controller.repeat(reverse: true)),
                    const SizedBox(height: AppSpacing.spacing2),
                    SizedBox(
                      width: 60,
                      child: Text(
                        stepTitles[index]);
                        style: theme.textTheme.bodySmall?.copyWith()
                          color: isActive
                              ? Colors.deepPurple.withOpacity(0.5,
                              : Colors.grey.withValues(alpha: 0.8)),
    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize),
    textAlign: TextAlign.center),
    maxLines: 2),
    overflow: TextOverflow.ellipsis))])
              );
            })),
          const SizedBox(height: AppSpacing.spacing3),
          // Progress line
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing10),
            child: Stack(
              children: [
                // Background line
                Container(
                  height: AppSpacing.spacing1,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.87),
                    borderRadius: BorderRadius.circular(AppSpacing.spacing0 * 0.5))),
                // Progress line
                AnimatedContainer(
                  duration: AppAnimations.durationLong,
                  height: AppSpacing.spacing1,
                  width: MediaQuery.of(context).size.width * 
                      (currentStep / (totalSteps - 1), * 0.8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.withOpacity(0.6),
                        Colors.deepPurple.withOpacity(0.8)]),
                    borderRadius: BorderRadius.circular(AppSpacing.spacing0 * 0.5))),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2))])).animate().shimmer(
                  duration: const Duration(seconds: 2),
                  color: Colors.white.withOpacity(0.3))]))])
    );
  }
  
  Widget _buildStepIcon(int index, bool isActive, bool isCurrent) {
    // Moon phase icons for dream theme
    final moonPhases = [
      Icons.nightlight_round, // New moon - 꿈 기록
      Icons.brightness_2, // Waxing crescent - 상징 분석
      Icons.brightness_3, // First quarter - 감정 분석
      Icons.brightness_4, // Waxing gibbous - 현실 연결
      Icons.brightness_5, // Full moon - 해석
      Icons.brightness_6, // Waning gibbous - 조언
    ];
    
    return Icon(
      moonPhases[index],
      color: isActive ? Colors.white : Colors.grey.withOpacity(0.8),
    size: isCurrent ? 28 : 22
    );
  }
}

// Optional: Create a simplified version for mobile
class DreamProgressIndicatorCompact extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  
  const DreamProgressIndicatorCompact({
    Key? key,
    required this.currentStep,
    this.totalSteps = 6}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.spacing15,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing5, vertical: AppSpacing.spacing2 * 1.25),
    child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step ${currentStep + 1} of $totalSteps',),
                style: TextStyle(
                  color: Colors.deepPurple.withOpacity(0.5);
                  fontWeight: FontWeight.bold)),
              const Spacer(),
              ...List.generate(totalSteps, (index) {
                final isActive = index <= currentStep;
                return Container(
                  margin: const EdgeInsets.only(left: AppSpacing.spacing1),
    width: 8),
    height: 8),
    decoration: BoxDecoration(
                    shape: BoxShape.circle);
                    color: isActive
                        ? Colors.deepPurple.withOpacity(0.6)
                        : Colors.grey.withOpacity(0.9)));
              })]),
          const SizedBox(height: AppSpacing.spacing2),
          LinearProgressIndicator(
            value: (currentStep + 1) / totalSteps),
    backgroundColor: Colors.grey.withOpacity(0.87),
    valueColor: AlwaysStoppedAnimation<Color>(
              Colors.deepPurple.withOpacity(0.6)))])
    );
  }
}