import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../shared/glassmorphism/glass_container.dart';

class AdviceSection extends StatelessWidget {
  final double fontScale;
  final List advice;

  const AdviceSection({
    super.key,
    required this.fontScale,
    required this.advice,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          TossDesignSystem.successGreen.withValues(alpha: 0.2),
          TossDesignSystem.successGreen.withValues(alpha: 0.2),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb,
            size: 36,
            color: TossDesignSystem.successGreen,
          ),
          SizedBox(height: 12),
          Text(
            '조언',
            style: TypographyUnified.heading4.copyWith(
              fontSize: TypographyUnified.heading4.fontSize! * fontScale,
              color: TossDesignSystem.white,
            ),
          ),
          const SizedBox(height: 16),
          ...advice.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TypographyUnified.bodyLarge.copyWith(
                        fontSize: TypographyUnified.bodyLarge.fontSize! * fontScale,
                        color: TossDesignSystem.successGreen,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TypographyUnified.bodySmall.copyWith(
                          fontSize: TypographyUnified.bodySmall.fontSize! * fontScale,
                          color: TossDesignSystem.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
