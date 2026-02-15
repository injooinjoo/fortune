import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

/// 🎯 오늘의 액션 플랜 카드
class ActionPlanCard extends StatelessWidget {
  final List<Map<String, String>> actions;

  const ActionPlanCard({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 액션 플랜',
          style: context.heading3.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '오늘 꼭 실천할 것들',
          style: context.bodySmall.copyWith(
            color: context.colors.textPrimary.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 16),
        ...actions.map((action) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ActionItem(
                title: action['title'] ?? '',
                description: action['description'] ?? '',
                priority: action['priority'] ?? 'medium',
              ),
            )),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final String title;
  final String description;
  final String priority;

  const _ActionItem({
    required this.title,
    required this.description,
    required this.priority,
  });

  /// 전통 오방색 기반 우선순위 색상
  Color get _priorityColor {
    switch (priority) {
      case 'high':
        return const Color(0xFFDC143C); // 고유 색상 - 화(火) 긴급함
      case 'medium':
        return const Color(0xFFDAA520); // 고유 색상 - 토(土) 균형
      case 'low':
        return const Color(0xFF2E8B57); // 고유 색상 - 목(木) 여유
      default:
        return const Color(0xFF6B7280); // 고유 색상 - 기본 회색
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _priorityColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: _priorityColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.labelMedium.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: context.labelTiny.copyWith(
                    color: context.colors.textPrimary.withValues(alpha: 0.6),
                    height: 1.4,
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
