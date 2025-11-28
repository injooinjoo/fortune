import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/components/app_card.dart';

class RecommendationsCard extends StatelessWidget {
  final List skills;
  final bool isDark;

  const RecommendationsCard({
    super.key,
    required this.skills,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, color: TossDesignSystem.warningOrange, size: 24),
              const SizedBox(width: 8),
              Text(
                '추천 스킬',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...skills.map((skill) {
            final skillMap = skill as Map<String, dynamic>;
            final name = skillMap['name'] as String? ?? '';
            final priority = skillMap['priority'] as String? ?? '';
            final reason = skillMap['reason'] as String? ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getPriorityColor(priority).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getPriorityColor(priority).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: context.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(priority),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getPriorityLabel(priority),
                          style: context.labelSmall.copyWith(
                            color: TossDesignSystem.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reason,
                    style: context.labelMedium.copyWith(
                      color: TossDesignSystem.gray600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'critical': return TossDesignSystem.errorRed;
      case 'high': return TossDesignSystem.warningOrange;
      case 'medium': return TossDesignSystem.tossBlue;
      case 'low': return TossDesignSystem.gray600;
      default: return TossDesignSystem.gray600;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'critical': return '필수';
      case 'high': return '높음';
      case 'medium': return '중간';
      case 'low': return '낮음';
      default: return priority;
    }
  }
}
