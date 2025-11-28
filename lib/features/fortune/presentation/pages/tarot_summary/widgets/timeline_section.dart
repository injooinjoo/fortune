import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../shared/glassmorphism/glass_container.dart';

class TimelineSection extends StatelessWidget {
  final double fontScale;
  final String timeline;

  const TimelineSection({
    super.key,
    required this.fontScale,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          TossDesignSystem.tossBlue.withValues(alpha: 0.2),
          TossDesignSystem.tossBlue.withValues(alpha: 0.2),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 36,
            color: TossDesignSystem.tossBlue,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '예상 시기',
                  style: TypographyUnified.bodyLarge.copyWith(
                    fontSize: TypographyUnified.bodyLarge.fontSize! * fontScale,
                    fontWeight: FontWeight.bold,
                    color: TossDesignSystem.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  timeline,
                  style: TypographyUnified.bodySmall.copyWith(
                    fontSize: TypographyUnified.bodySmall.fontSize! * fontScale,
                    color: TossDesignSystem.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
