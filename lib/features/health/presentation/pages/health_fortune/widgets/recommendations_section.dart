import 'package:flutter/material.dart';
import '../../../../../../core/theme/fortune_theme.dart';
import '../../../../../../core/theme/fortune_design_system.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../domain/models/health_fortune_model.dart';

class RecommendationsSection extends StatelessWidget {
  final List<HealthRecommendation> recommendations;
  final bool isDark;

  const RecommendationsSection({
    super.key,
    required this.recommendations,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 건강 관리',
            style: TossTheme.heading3.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
            ),
          ),
          const SizedBox(height: 16),

          ...recommendations.map((rec) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? TossDesignSystem.surfaceBackgroundDark : TossTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    rec.type.emoji,
                    style: DSTypography.headingSmall,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec.title,
                          style: TossTheme.body2.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          rec.description,
                          style: TossTheme.body3.copyWith(
                            color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
