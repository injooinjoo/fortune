import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
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
          DSColors.success.withValues(alpha: 0.2),
          DSColors.success.withValues(alpha: 0.2),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.lightbulb,
            size: 36,
            color: DSColors.success,
          ),
          const SizedBox(height: 12),
          Text(
            '조언',
            style: DSTypography.headingSmall.copyWith(
              fontSize: DSTypography.headingSmall.fontSize! * fontScale,
              color: Colors.white,
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
                      style: DSTypography.bodyLarge.copyWith(
                        fontSize: DSTypography.bodyLarge.fontSize! * fontScale,
                        color: DSColors.success,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: DSTypography.bodySmall.copyWith(
                          fontSize: DSTypography.bodySmall.fontSize! * fontScale,
                          color: Colors.white,
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
