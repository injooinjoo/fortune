import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/components/app_card.dart';

class GrowthRoadmapCard extends StatelessWidget {
  final Map<String, dynamic> growthRoadmap;
  final bool isDark;

  const GrowthRoadmapCard({
    super.key,
    required this.growthRoadmap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final currentStage = growthRoadmap['current_stage'] as String? ?? '';
    final nextStage = growthRoadmap['next_stage'] as String? ?? '';
    final estimatedMonths = growthRoadmap['estimated_months'] as int? ?? 0;
    final keyMilestones = growthRoadmap['key_milestones'] as List? ?? [];

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route, color: TossDesignSystem.tossBlue, size: 24),
              const SizedBox(width: 8),
              Text(
                '성장 로드맵',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Journey Visual
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.gray200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '현재',
                        style: context.labelSmall.copyWith(
                          color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.gray600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentStage,
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: Icon(Icons.arrow_forward, color: TossDesignSystem.tossBlue),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                        TossDesignSystem.successGreen.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: TossDesignSystem.tossBlue,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '목표',
                        style: context.labelSmall.copyWith(
                          color: TossDesignSystem.tossBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextStage,
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: TossDesignSystem.tossBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.gray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.gray600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '예상 기간: $estimatedMonths개월',
                  style: context.bodyMedium.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.gray700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            '핵심 마일스톤',
            style: context.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: TossDesignSystem.gray600,
            ),
          ),
          const SizedBox(height: 8),

          ...keyMilestones.map((milestone) =>
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: TossDesignSystem.gray500, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      milestone.toString(),
                      style: context.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }
}
