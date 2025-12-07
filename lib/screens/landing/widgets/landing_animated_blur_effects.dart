import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/toss_design_system.dart';

/// Animated blur effects for landing page background
class LandingAnimatedBlurEffects extends StatelessWidget {
  const LandingAnimatedBlurEffects({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return _buildDarkModeEffects();
    } else {
      return _buildLightModeEffects();
    }
  }

  Widget _buildLightModeEffects() {
    return Stack(
      children: [
        // Purple blur effect - top left
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0xFFE8B4FF).withValues(alpha: 0.6), // 보라색 (진하게)
                  Color(0xFFE8B4FF).withValues(alpha: 0.3),
                  TossDesignSystem.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                  begin: Offset(1.0, 1.0),
                  end: Offset(1.2, 1.2),
                  duration: 4.seconds,
                  curve: Curves.easeInOut)
              .moveX(
                  begin: 0,
                  end: 60,
                  duration: 8.seconds,
                  curve: Curves.easeInOut)
              .moveY(
                  begin: 0,
                  end: 40,
                  duration: 10.seconds,
                  curve: Curves.easeInOut),
        ),
        // Pink blur effect - bottom right
        Positioned(
          bottom: -150,
          right: -150,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0xFFFFB4B4).withValues(alpha: 0.6), // 분홍색 (진하게)
                  Color(0xFFFFB4B4).withValues(alpha: 0.3),
                  TossDesignSystem.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                  begin: Offset(1.0, 1.0),
                  end: Offset(1.1, 1.1),
                  duration: 5.seconds,
                  curve: Curves.easeInOut)
              .moveX(
                  begin: 0,
                  end: -50,
                  duration: 9.seconds,
                  curve: Curves.easeInOut)
              .moveY(
                  begin: 0,
                  end: -50,
                  duration: 11.seconds,
                  curve: Curves.easeInOut),
        ),
        // Yellow blur effect - center left
        Positioned(
          top: 0,
          left: -200,
          child: Builder(builder: (context) {
            return Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFFFE4B4).withValues(alpha: 0.5), // 노란색 (진하게)
                    Color(0xFFFFE4B4).withValues(alpha: 0.25),
                    TossDesignSystem.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                    begin: Offset(1.0, 1.0),
                    end: Offset(1.15, 1.15),
                    duration: 6.seconds,
                    curve: Curves.easeInOut)
                .moveX(
                    begin: 0,
                    end: 70,
                    duration: 12.seconds,
                    curve: Curves.easeInOut)
                .moveY(
                    begin: 0,
                    end: -40,
                    duration: 10.seconds,
                    curve: Curves.easeInOut);
          }),
        ),
      ],
    );
  }

  Widget _buildDarkModeEffects() {
    return Stack(
      children: [
        // Purple blur effect - top left
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0xFF6B46C1).withValues(alpha: 0.15), // 보라색
                  Color(0xFF6B46C1).withValues(alpha: 0.08),
                  TossDesignSystem.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveX(
                  begin: 0,
                  end: 50,
                  duration: 15.seconds,
                  curve: Curves.easeInOut)
              .moveY(
                  begin: 0,
                  end: 30,
                  duration: 20.seconds,
                  curve: Curves.easeInOut),
        ),
        // Blue blur effect - bottom right
        Positioned(
          bottom: -150,
          right: -150,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0xFF2563EB).withValues(alpha: 0.15), // 파란색
                  Color(0xFF2563EB).withValues(alpha: 0.08),
                  TossDesignSystem.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveX(
                  begin: 0,
                  end: -40,
                  duration: 18.seconds,
                  curve: Curves.easeInOut)
              .moveY(
                  begin: 0,
                  end: -40,
                  duration: 22.seconds,
                  curve: Curves.easeInOut),
        ),
      ],
    );
  }
}
