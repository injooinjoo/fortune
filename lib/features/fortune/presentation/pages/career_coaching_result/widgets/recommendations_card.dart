import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/components/app_card.dart';

class RecommendationsCard extends StatelessWidget {
  final List skills;
  final DSColorScheme colors;

  const RecommendationsCard({
    super.key,
    required this.skills,
    required this.colors,
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
              Icon(Icons.school, color: DSColors.warning, size: 24),
              const SizedBox(width: 8),
              Text(
                '추천 스킬',
                style: DSTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
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
            final priorityColor = _getPriorityColor(priority);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: priorityColor.withValues(alpha: 0.3),
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
                          style: DSTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getPriorityLabel(priority),
                          style: DSTypography.labelSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reason,
                    style: DSTypography.labelMedium.copyWith(
                      color: colors.textSecondary,
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
      case 'critical': return DSColors.error;
      case 'high': return DSColors.warning;
      case 'medium': return colors.accent;
      case 'low': return colors.textSecondary;
      default: return colors.textSecondary;
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
