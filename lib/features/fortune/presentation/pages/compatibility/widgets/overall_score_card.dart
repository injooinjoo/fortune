import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/domain/entities/fortune.dart';
import '../compatibility_utils.dart';

class OverallScoreCard extends StatelessWidget {
  final String person1Name;
  final String person2Name;
  final double overallScore;
  final Fortune fortune;

  const OverallScoreCard({
    super.key,
    required this.person1Name,
    required this.person2Name,
    required this.overallScore,
    required this.fortune,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$person1Name ❤️ $person2Name',
                style: DSTypography.headingMedium.copyWith(
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (fortune.metadata?['name_compatibility'] != null) ...[
                SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DSColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '이름 ${fortune.metadata!['name_compatibility']}%',
                    style: DSTypography.labelSmall.copyWith(
                      color: DSColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          CircularPercentIndicator(
            radius: 80.0,
            lineWidth: 12.0,
            percent: overallScore,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(overallScore * 100).round()}점',
                  style: DSTypography.displayLarge.copyWith(
                    color: CompatibilityUtils.getScoreColor(overallScore),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  CompatibilityUtils.getScoreText(overallScore),
                  style: DSTypography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            progressColor: CompatibilityUtils.getScoreColor(overallScore),
            backgroundColor: colors.border,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 1200,
          ),

          SizedBox(height: 16),

          Text(
            fortune.summary ?? '궁합 분석 결과',
            style: DSTypography.bodyLarge.copyWith(
              color: CompatibilityUtils.getScoreColor(overallScore),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
