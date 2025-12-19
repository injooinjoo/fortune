import 'package:flutter/material.dart';
import '../../../../core/theme/typography_unified.dart';

/// 🎯 오늘의 액션 플랜 카드
class ActionPlanCard extends StatelessWidget {
  final List<Map<String, String>> actions;
  final bool isDark;

  const ActionPlanCard({
    super.key,
    required this.actions,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 액션 플랜',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '오늘 꼭 실천할 것들',
          style: context.bodySmall.copyWith(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
          ),
        ),

        const SizedBox(height: 16),

        ...actions.map((action) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ActionItem(
            title: action['title'] ?? '',
            description: action['description'] ?? '',
            priority: action['priority'] ?? 'medium',
            isDark: isDark,
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
  final bool isDark;

  const _ActionItem({
    required this.title,
    required this.description,
    required this.priority,
    required this.isDark,
  });

  /// 전통 오방색 기반 우선순위 색상
  Color get _priorityColor {
    switch (priority) {
      case 'high':
        return const Color(0xFFDC143C); // 화(火) - 긴급함
      case 'medium':
        return const Color(0xFFDAA520); // 토(土) - 균형
      case 'low':
        return const Color(0xFF2E8B57); // 목(木) - 여유
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _priorityColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                    fontSize: 12,
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
