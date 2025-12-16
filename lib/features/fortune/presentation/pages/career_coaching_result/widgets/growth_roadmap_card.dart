import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/components/app_card.dart';

class GrowthRoadmapCard extends StatelessWidget {
  final Map<String, dynamic> growthRoadmap;
  final DSColorScheme colors;

  const GrowthRoadmapCard({
    super.key,
    required this.growthRoadmap,
    required this.colors,
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
              Icon(Icons.route, color: colors.accent, size: 24),
              const SizedBox(width: 8),
              Text(
                '성장 로드맵',
                style: DSTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
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
                    color: colors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '현재',
                        style: DSTypography.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentStage,
                        style: DSTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: Icon(Icons.arrow_forward, color: colors.accent),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.accent.withValues(alpha: 0.1),
                        DSColors.success.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.accent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '목표',
                        style: DSTypography.labelSmall.copyWith(
                          color: colors.accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextStage,
                        style: DSTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.accent,
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
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: colors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '예상 기간: $estimatedMonths개월',
                  style: DSTypography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            '핵심 마일스톤',
            style: DSTypography.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          ...keyMilestones.map((milestone) =>
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: colors.textSecondary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      milestone.toString(),
                      style: DSTypography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
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
