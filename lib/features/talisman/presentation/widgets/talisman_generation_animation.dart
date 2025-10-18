import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/talisman_wish.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';

class TalismanGenerationAnimation extends StatefulWidget {
  final TalismanCategory category;
  final String wishText;
  final VoidCallback? onCompleted;

  const TalismanGenerationAnimation({
    super.key,
    required this.category,
    required this.wishText,
    this.onCompleted,
  });

  @override
  State<TalismanGenerationAnimation> createState() => _TalismanGenerationAnimationState();
}

class _TalismanGenerationAnimationState extends State<TalismanGenerationAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  int _currentStep = 0;
  
  final List<String> _steps = [
    '소원을 분석하고 있어요...',
    '최적의 부적 디자인을 찾고 있어요...',
    '전통적인 의미를 담고 있어요...',
    '마지막 마법을 부리고 있어요...',
  ];

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _startStepAnimation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _startStepAnimation() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _currentStep < _steps.length - 1) {
        setState(() {
          _currentStep++;
        });
        _startStepAnimation();
      } else if (mounted && _currentStep == _steps.length - 1) {
        // Complete after final step
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            widget.onCompleted?.call();
          }
        });
      }
    });
  }

  Color get _categoryColor {
    switch (widget.category) {
      case TalismanCategory.wealth:
        return const Color(0xFFFFD700);
      case TalismanCategory.love:
        return const Color(0xFFFF6B9D);
      case TalismanCategory.career:
        return const Color(0xFF4A90E2);
      case TalismanCategory.health:
        return const Color(0xFF7ED321);
      case TalismanCategory.study:
        return const Color(0xFF9013FE);
      case TalismanCategory.relationship:
        return const Color(0xFFFF9500);
      case TalismanCategory.goal:
        return const Color(0xFF50E3C2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Category Icon with Animation
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _categoryColor.withValues(alpha: 0.3),
                  _categoryColor.withValues(alpha: 0.1),
                  TossDesignSystem.white.withValues(alpha: 0.0),
                ],
              ),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _rotateController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateController.value * 2 * 3.14159,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _categoryColor.withValues(alpha: 0.2),
                        border: Border.all(
                          color: _categoryColor.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.category.emoji,
                          style: TypographyUnified.numberLarge,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 2000.ms, color: _categoryColor.withValues(alpha: 0.3))
            .then()
            .shake(duration: 500.ms),
          
          SizedBox(height: 40),
          
          // Title
          Text(
            '부적 생성 중...',
            style: TossTheme.heading2.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
          ).animate()
            .fadeIn(duration: 400.ms),
          
          const SizedBox(height: 16),
          
          // Wish Preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.surfaceBackgroundDark : TossDesignSystem.surfaceBackgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '"${widget.wishText}"',
              style: TossTheme.body3.copyWith(
                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate(delay: 200.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: 32),
          
          // Progress Steps
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _steps[_currentStep],
              key: ValueKey(_currentStep),
              style: TossTheme.subtitle1.copyWith(
                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Progress Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_steps.length, (index) {
              final isActive = index <= _currentStep;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? _categoryColor : TossTheme.borderGray300,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 40),
          
          // Floating Particles Animation
          SizedBox(
            height: 60,
            child: Stack(
              children: List.generate(8, (index) {
                return Positioned(
                  left: (index * 40) % 280,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _categoryColor.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                    .moveY(
                      begin: 0,
                      end: -40,
                      duration: Duration(milliseconds: 1500 + (index * 200)),
                    )
                    .fadeOut()
                    .then(delay: Duration(milliseconds: index * 100))
                    .moveY(
                      begin: 40,
                      end: 0,
                      duration: Duration(milliseconds: 1500 + (index * 200)),
                    )
                    .fadeIn(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}