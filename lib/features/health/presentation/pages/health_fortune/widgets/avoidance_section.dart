import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';

class AvoidanceSection extends StatelessWidget {
  final List<String> avoidanceList;

  const AvoidanceSection({
    super.key,
    required this.avoidanceList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_rounded,
                color: DSColors.warning,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘 피해야 할 것들',
                style: context.heading3.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: avoidanceList.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: DSColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: DSColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  item,
                  style: context.bodySmall.copyWith(
                    color: DSColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
