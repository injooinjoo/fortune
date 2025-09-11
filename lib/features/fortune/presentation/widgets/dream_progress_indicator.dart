import 'package:flutter/material.dart';
import '../../../../shared/components/toss_button.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_animations.dart';

class DreamProgressIndicator extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const DreamProgressIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
    this.onNext,
    this.onPrevious,
  }) : super(key: key);

  @override
  State<DreamProgressIndicator> createState() => _DreamProgressIndicatorState();
}

class _DreamProgressIndicatorState extends State<DreamProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (widget.currentStep + 1) / widget.totalSteps,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.primaryColor,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Step Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              widget.totalSteps,
              (index) => Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: index <= widget.currentStep
                      ? theme.primaryColor
                      : Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: index == widget.currentStep
                      ? [
                          BoxShadow(
                            color: theme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: index <= widget.currentStep
                          ? Colors.white
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: index * 100)),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Current Step Title
          if (widget.stepTitles.length > widget.currentStep)
            Text(
              widget.stepTitles[widget.currentStep],
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          
          const SizedBox(height: 20),
          
          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Button
              if (widget.currentStep > 0 && widget.onPrevious != null)
                TossButton(
                  text: '이전',
                  onPressed: widget.onPrevious,
                  style: TossButtonStyle.ghost,
                  size: TossButtonSize.medium,
                )
              else
                const SizedBox(width: 80),
              
              // Progress Text
              Text(
                '${widget.currentStep + 1} / ${widget.totalSteps}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.withValues(alpha: 0.7),
                ),
              ),
              
              // Next Button
              if (widget.currentStep < widget.totalSteps - 1 && widget.onNext != null)
                TossButton(
                  text: '다음',
                  onPressed: widget.onNext,
                  style: TossButtonStyle.primary,
                  size: TossButtonSize.medium,
                )
              else
                const SizedBox(width: 80),
            ],
          ),
        ],
      ),
    );
  }
}

class AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final Color color;
  final Duration duration;

  const AnimatedProgressBar({
    Key? key,
    required this.progress,
    required this.color,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: _animation.value,
          backgroundColor: Colors.grey.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(widget.color),
        );
      },
    );
  }
}