import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
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
          TossDesignSystem.warningYellow.withValues(alpha: 0.2),
          TossDesignSystem.warningOrange.withValues(alpha: 0.2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: TossDesignSystem.warningYellow.withValues(alpha: 0.3),
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
                  TossDesignSystem.warningYellow.withValues(alpha: 0.3),
                  TossDesignSystem.transparent,
                ],
              ),
            ),
            child: Icon(
              Icons.auto_stories,
              size: 48,
              color: TossDesignSystem.warningYellow,
              shadows: [
                Shadow(
                  color: TossDesignSystem.warningYellow,
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            '전체 해석',
            style: TypographyUnified.heading3.copyWith(
              fontSize: TypographyUnified.heading3.fontSize! * fontScale,
              color: TossDesignSystem.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            summary,
            style: TypographyUnified.bodyLarge.copyWith(
              fontSize: TypographyUnified.bodyLarge.fontSize! * fontScale,
              color: TossDesignSystem.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
