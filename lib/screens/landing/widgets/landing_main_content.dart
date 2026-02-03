import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/design_system/design_system.dart';
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
                ? 'assets/images/zpzg_logo_dark.png'
                : 'assets/images/zpzg_logo_light.png',
            width: 120,
            height: 120,
          ).animate().fadeIn(duration: 800.ms).scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: 600.ms,
              curve: Curves.easeOutBack),

          const SizedBox(height: 40),

          // App Name
          Text(
            'ZPZG',
            style: context.displaySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -1),
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            '매일 새로운 인사이트를 만나보세요',
            style: context.labelMedium.copyWith(
                fontWeight: FontWeight.w400,
                color: context.colors.textSecondary),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

          const SizedBox(height: 80),

          // Start Button - Traditional Seal (인장) Style
          // Custom button to avoid AnimatedDefaultTextStyle lerp issues
          _TraditionalSealButton(
            onPressed: onStartPressed,
          )
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms)
              .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.0, 1.0),
                  duration: 400.ms),
        ],
      ),
    );
  }
}

/// Traditional Korean Seal (인장/주색) Style Button
/// Custom implementation to avoid AnimatedDefaultTextStyle lerp issues
class _TraditionalSealButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const _TraditionalSealButton({
    required this.onPressed,
  });

  @override
  State<_TraditionalSealButton> createState() => _TraditionalSealButtonState();
}

class _TraditionalSealButtonState extends State<_TraditionalSealButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _isPressed
              ? colors.ctaBackground.withValues(alpha: 0.85)
              : colors.ctaBackground,
          borderRadius: BorderRadius.circular(28),
        ),
        alignment: Alignment.center,
        child: Text(
          '시작하기',
          style: context.heading4.copyWith(
            color: colors.ctaForeground,
          ),
        ),
      ),
    );
  }
}
