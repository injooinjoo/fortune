import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
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
          const Color(0xFF3182F6).withValues(alpha: 0.2),
          const Color(0xFF3182F6).withValues(alpha: 0.2),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 36,
            color: const Color(0xFF3182F6),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '예상 시기',
                  style: DSTypography.bodyLarge.copyWith(
                    fontSize: DSTypography.bodyLarge.fontSize! * fontScale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  timeline,
                  style: DSTypography.bodySmall.copyWith(
                    fontSize: DSTypography.bodySmall.fontSize! * fontScale,
                    color: Colors.white.withValues(alpha: 0.7),
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
