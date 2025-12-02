import 'package:flutter/material.dart';

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
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 13,
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

  Color get _priorityColor {
    switch (priority) {
      case 'high':
        return const Color(0xFF3B82F6);
      case 'medium':
        return const Color(0xFF10B981);
      case 'low':
        return const Color(0xFF6B7280);
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _priorityColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
