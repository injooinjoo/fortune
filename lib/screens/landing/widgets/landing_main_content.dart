import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/toss_design_system.dart';
import '../../../core/theme/typography_unified.dart';

/// Main content area of landing page with logo, title, and start button
class LandingMainContent extends StatelessWidget {
  final VoidCallback onStartPressed;

  const LandingMainContent({
    super.key,
    required this.onStartPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App Logo
          Image.asset(
            Theme.of(context).brightness == Brightness.dark
                ? 'assets/images/flower_transparent_white.png'
                : 'assets/images/flower_transparent.png',
            width: 100,
            height: 100,
          ).animate().fadeIn(duration: 800.ms).scale(
              begin: Offset(0.8, 0.8),
              end: Offset(1.0, 1.0),
              duration: 600.ms,
              curve: Curves.easeOutBack),

          SizedBox(height: 40),

          // App Name
          Text(
            'Fortune',
            style: TypographyUnified.displaySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -1),
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            '매일 새로운 운세를 만나보세요',
            style: TypographyUnified.buttonMedium.copyWith(
                fontWeight: FontWeight.w400,
                color: Theme.of(context).brightness == Brightness.dark
                    ? TossDesignSystem.grayDark400
                    : TossDesignSystem.gray600),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

          const SizedBox(height: 80),

          // Start Button with Hero Animation
          Hero(
            tag: 'start-button-hero',
            child: Material(
              color: TossDesignSystem.white.withValues(alpha: 0.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onStartPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? TossDesignSystem.white
                            : TossDesignSystem.black,
                    foregroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? TossDesignSystem.black
                            : TossDesignSystem.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    '시작하기',
                    style:
                        TypographyUnified.heading4.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms)
              .scale(
                  begin: Offset(0.9, 0.9),
                  end: Offset(1.0, 1.0),
                  duration: 400.ms),
        ],
      ),
    );
  }
}
