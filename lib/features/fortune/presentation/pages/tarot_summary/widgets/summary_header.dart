import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import 'dart:math' as math;

class SummaryHeader extends StatelessWidget {
  final double fontScale;
  final String? question;
  final AnimationController scaleController;

  const SummaryHeader({
    super.key,
    required this.fontScale,
    this.question,
    required this.scaleController,
  });

  @override
  Widget build(BuildContext context) {
    final scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: scaleController,
      curve: Curves.easeOutBack,
    ));

    return ScaleTransition(
      scale: scaleAnimation,
      child: Column(
        children: [
          // Enhanced mystical icon with animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating aura
                  Transform.rotate(
                    angle: value * 2 * math.pi,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            const Color(0xFF9333EA).withValues(alpha: 0),
                            const Color(0xFF9333EA).withValues(alpha: 0.3),
                            const Color(0xFF3182F6).withValues(alpha: 0.3),
                            const Color(0xFF9333EA).withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Center icon
                  Icon(
                    Icons.auto_awesome,
                    size: 60,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF9333EA),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 16),
          Text(
            '리딩이 완료되었습니다',
            style: DSTypography.displayMedium.copyWith(
              fontSize: DSTypography.displayMedium.fontSize! * fontScale,
              color: Colors.white,
            ),
          ),
          if (question != null) ...[
            SizedBox(height: 8),
            Text(
              question!,
              style: DSTypography.bodyLarge.copyWith(
                fontSize: DSTypography.bodyLarge.fontSize! * fontScale,
                color: Colors.white.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
