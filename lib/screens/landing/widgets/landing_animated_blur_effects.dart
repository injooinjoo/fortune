import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/design_system/design_system.dart';

/// Korean Traditional Ink-Wash (발묵/潑墨) animated effects for landing page
/// Design Philosophy: "Ink spreading on Hanji" (한지 위의 먹 번짐)
///
/// Uses Obangsaek (오방색) toned down colors:
/// - 청색 (Blue/Indigo): Deep indigo like 쪽빛
/// - 회먹색 (Gray-Ink): Ink wash gradients
/// - 담황색 (Light Yellow): Subtle warmth
class LandingAnimatedBlurEffects extends StatelessWidget {
  const LandingAnimatedBlurEffects({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    if (isDark) {
      return _buildDarkModeEffects();
    } else {
      return _buildLightModeEffects();
    }
  }

  /// Light Mode: Subtle ink-wash (수묵) effect on hanji paper
  Widget _buildLightModeEffects() {
    return Stack(
      children: [
        // 담묵 (Light ink wash) - Top area
        // Simulates ink gently spreading on hanji paper
        Positioned(
          top: -80,
          left: -50,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF8B9CAD)
                      .withValues(alpha: 0.12), // 고유 색상 - 담먹색 (Light ink gray)
                  const Color(0xFF8B9CAD).withValues(alpha: 0.06), // 고유 색상
                  Colors.transparent,
                ],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.15, 1.15),
                  duration: 8.seconds,
                  curve: Curves.easeInOut)
              .moveX(
                  begin: 0,
                  end: 30,
                  duration: 12.seconds,
                  curve: Curves.easeInOut),
        ),

        // 농묵 (Dense ink wash) - Bottom right
        // Simulates deeper ink pooling
        Positioned(
          bottom: -120,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6B7B8A)
                      .withValues(alpha: 0.15), // 고유 색상 - 회먹색 (Gray ink)
                  const Color(0xFF6B7B8A).withValues(alpha: 0.08), // 고유 색상
                  Colors.transparent,
                ],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.08, 1.08),
                  duration: 10.seconds,
                  curve: Curves.easeInOut)
              .moveX(
                  begin: 0,
                  end: -25,
                  duration: 14.seconds,
                  curve: Curves.easeInOut),
        ),

        // 미색 따뜻함 (Warm cream accent) - Center
        // Adds subtle warmth like aged hanji
        Positioned(
          top: 100,
          right: -150,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFD4C5A9)
                      .withValues(alpha: 0.18), // 고유 색상 - 담황색 (Light ocher)
                  const Color(0xFFD4C5A9).withValues(alpha: 0.08), // 고유 색상
                  Colors.transparent,
                ],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.12, 1.12),
                  duration: 9.seconds,
                  curve: Curves.easeInOut)
              .moveY(
                  begin: 0,
                  end: 20,
                  duration: 11.seconds,
                  curve: Curves.easeInOut),
        ),
      ],
    );
  }

  /// Dark Mode: Deep ink-stone (벼루) and moon-lit paper effect
  Widget _buildDarkModeEffects() {
    return Stack(
      children: [
        // 쪽빛 (Deep indigo) - Top left
        // Traditional Korean indigo like night sky
        Positioned(
          top: -100,
          left: -80,
          child: Container(
            width: 380,
            height: 380,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF2D3A5C)
                      .withValues(alpha: 0.25), // 고유 색상 - 쪽빛 (Deep indigo)
                  const Color(0xFF2D3A5C).withValues(alpha: 0.12), // 고유 색상
                  Colors.transparent,
                ],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.1, 1.1),
                  duration: 12.seconds,
                  curve: Curves.easeInOut)
              .moveX(
                  begin: 0,
                  end: 25,
                  duration: 16.seconds,
                  curve: Curves.easeInOut),
        ),

        // 현무색 (Charcoal black) - Bottom
        // Deep ink-stone aesthetic
        Positioned(
          bottom: -130,
          right: -120,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF1F2937)
                      .withValues(alpha: 0.30), // 고유 색상 - 현무색 (Charcoal)
                  const Color(0xFF1F2937).withValues(alpha: 0.15), // 고유 색상
                  Colors.transparent,
                ],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveX(
                  begin: 0,
                  end: -20,
                  duration: 18.seconds,
                  curve: Curves.easeInOut)
              .moveY(
                  begin: 0,
                  end: -15,
                  duration: 20.seconds,
                  curve: Curves.easeInOut),
        ),

        // 은은한 달빛 (Subtle moonlight) - Center right
        // Moon-lit paper effect
        Positioned(
          top: 150,
          right: -100,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4A5568)
                      .withValues(alpha: 0.15), // 고유 색상 - 회색 (Subtle gray)
                  const Color(0xFF4A5568).withValues(alpha: 0.06), // 고유 색상
                  Colors.transparent,
                ],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.08, 1.08),
                  duration: 10.seconds,
                  curve: Curves.easeInOut),
        ),
      ],
    );
  }
}
