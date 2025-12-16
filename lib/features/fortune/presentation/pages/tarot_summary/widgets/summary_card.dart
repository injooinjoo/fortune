import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../shared/glassmorphism/glass_container.dart';

class SummaryCard extends StatelessWidget {
  final double fontScale;
  final String summary;

  const SummaryCard({
    super.key,
    required this.fontScale,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      gradient: LinearGradient(
        colors: [
          DSColors.warning.withValues(alpha: 0.2),
          DSColors.warning.withValues(alpha: 0.25),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: DSColors.warning.withValues(alpha: 0.3),
        width: 1,
      ),
      blur: 15,
      child: Column(
        children: [
          // Enhanced icon with glow
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  DSColors.warning.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: Icon(
              Icons.auto_stories,
              size: 48,
              color: DSColors.warning,
              shadows: [
                Shadow(
                  color: DSColors.warning,
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            '전체 해석',
            style: DSTypography.headingMedium.copyWith(
              fontSize: DSTypography.headingMedium.fontSize! * fontScale,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            summary,
            style: DSTypography.bodyLarge.copyWith(
              fontSize: DSTypography.bodyLarge.fontSize! * fontScale,
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
