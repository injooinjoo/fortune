import 'package:flutter/material.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

class HealingProgressWidget extends StatefulWidget {
  final int currentStage;
  final double progress;
  final VoidCallback? onTap;

  const HealingProgressWidget({
    Key? key,
    required this.currentStage,
    required this.progress,
    this.onTap}) : super(key: key);

  @override
  State<HealingProgressWidget> createState() => _HealingProgressWidgetState();
}

class _HealingProgressWidgetState extends State<HealingProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  
  final stages = [
    {'name': '부정', 'icon': Icons.block, 'color': Colors.red},
    {'name': '분노', 'icon': Icons.bolt, 'color': Colors.orange},
    {'name': '타협', 'icon': Icons.handshake, 'color': Colors.yellow},
    {'name': '우울', 'icon': Icons.water_drop, 'color': Colors.blue},
    {'name': '수용', 'icon': Icons.favorite, 'color': Colors.green},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress / 100,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(HealingProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress / 100,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: AppSpacing.paddingAll20,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.8),
          borderRadius: AppDimensions.borderRadiusLarge,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '치유 진행도',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Text(
                      '${(_progressAnimation.value * 100).toInt()}%',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing6),
            
            // Progress bar with stages
            Stack(
              children: [
                // Background line
                Container(
                  height: AppSpacing.spacing2,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.1),
                    borderRadius: AppDimensions.borderRadiusSmall,
                  ),
                ),
                
                // Animated progress
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Container(
                      height: AppSpacing.spacing2,
                      width: MediaQuery.of(context).size.width * 
                             _progressAnimation.value * 0.8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        borderRadius: AppDimensions.borderRadiusSmall,
                      ),
                    );
                  },
                ),
                
                // Stage markers
                ...stages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final stage = entry.value;
                  final position = index / (stages.length - 1);
                  final isCompleted = widget.currentStage > index;
                  final isCurrent = widget.currentStage == index + 1;
                  
                  return Positioned(
                    left: MediaQuery.of(context).size.width * position * 0.75,
                    top: -16,
                    child: AnimatedContainer(
                      duration: AppAnimations.durationMedium,
                      width: 40,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted || isCurrent
                            ? (stage['color'] as Color)
                            : theme.colorScheme.surface,
                        border: Border.all(
                          color: isCompleted || isCurrent
                              ? (stage['color'] as Color)
                              : theme.colorScheme.onSurface.withOpacity(0.3),
                          width: 3,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: (stage['color'] as Color).withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          stage['icon'] as IconData,
                          size: 20,
                          color: isCompleted || isCurrent
                              ? Colors.white
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
            
            const SizedBox(height: AppSpacing.spacing8),
            
            // Stage names
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: stages.asMap().entries.map((entry) {
                final index = entry.key;
                final stage = entry.value;
                final isCompleted = widget.currentStage > index;
                final isCurrent = widget.currentStage == index + 1;
                
                return Expanded(
                  child: Text(
                    stage['name'] as String,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isCompleted || isCurrent
                          ? (stage['color'] as Color)
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: AppSpacing.spacing4),
            
            // Current stage description
            AnimatedSwitcher(
              duration: AppAnimations.durationMedium,
              child: Container(
                key: ValueKey(widget.currentStage),
                padding: AppSpacing.paddingAll12,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: AppDimensions.borderRadiusSmall),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: theme.colorScheme.primary),
                    const SizedBox(width: AppSpacing.spacing2),
                    Expanded(
                      child: Text(
                        _getStageDescription(widget.currentStage),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
}

  String _getStageDescription(int stage) {
    final descriptions = [
      '현실을 받아들이기 어려운 상태입니다. 시간이 필요해요.',
      '감정이 격해질 수 있어요. 이것도 자연스러운 과정입니다.',
      '조금씩 상황을 이해하기 시작하는 단계입니다.',
      '깊은 슬픔을 느낄 수 있지만, 치유의 과정입니다.',
      '새로운 시작을 준비할 수 있는 단계에 도달했습니다.'];
    
    if (stage > 0 && stage <= descriptions.length) {
      return descriptions[stage - 1];
    }
    return '치유의 여정을 시작하세요.';
  }
}