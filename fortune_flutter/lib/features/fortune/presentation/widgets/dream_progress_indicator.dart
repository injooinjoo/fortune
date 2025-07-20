import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    this.onStepTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.deepPurple.shade900.withValues(alpha: 0.3),
            Colors.deepPurple.shade900.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
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
                      duration: const Duration(milliseconds: 300),
                      width: isCurrent ? 50 : 40,
                      height: isCurrent ? 50 : 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isActive
                            ? LinearGradient(
                                colors: [
                                  Colors.deepPurple.shade400,
                                  Colors.deepPurple.shade600,
                                ],
                              )
                            : null,
                        color: isActive ? null : Colors.grey.shade800,
                        border: Border.all(
                          color: isCurrent 
                              ? Colors.deepPurple.shade300
                              : isActive 
                                  ? Colors.deepPurple.shade400
                                  : Colors.grey.shade700,
                          width: isCurrent ? 3 : 2,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: Colors.deepPurple.shade400.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: _buildStepIcon(index, isActive, isCurrent),
                      ),
                    ).animate(
                      effects: isCurrent
                          ? [
                              const ScaleEffect(
                                duration: Duration(seconds: 2),
                                curve: Curves.easeInOut,
                                begin: Offset(0.95, 0.95),
                                end: Offset(1.05, 1.05),
                              ),
                            ]
                          : [],
                      onPlay: (controller) => controller.repeat(reverse: true),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        stepTitles[index],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isActive
                              ? Colors.deepPurple.shade300
                              : Colors.grey.shade600,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          // Progress line
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Stack(
              children: [
                // Background line
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Progress line
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 4,
                  width: MediaQuery.of(context).size.width * 
                      (currentStep / (totalSteps - 1)) * 0.8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade400,
                        Colors.deepPurple.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.shade400.withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ).animate().shimmer(
                  duration: 2.seconds,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ],
      ),
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
      color: isActive ? Colors.white : Colors.grey.shade600,
      size: isCurrent ? 28 : 22,
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
    this.totalSteps = 6,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step ${currentStep + 1} of $totalSteps',
                style: TextStyle(
                  color: Colors.deepPurple.shade300,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ...List.generate(totalSteps, (index) {
                final isActive = index <= currentStep;
                return Container(
                  margin: const EdgeInsets.only(left: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Colors.deepPurple.shade400
                        : Colors.grey.shade700,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (currentStep + 1) / totalSteps,
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.deepPurple.shade400,
            ),
          ),
        ],
      ),
    );
  }
}