import 'package:flutter/material.dart';
import '../../../../../../core/theme/fortune_theme.dart';
import '../../../../../../core/theme/fortune_design_system.dart';

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
        color: TossDesignSystem.white,
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
          Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: TossTheme.warning,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '오늘 피해야 할 것들',
                style: TossTheme.heading3.copyWith(
                  color: TossTheme.textBlack,
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
                  color: TossTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: TossTheme.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  item,
                  style: TossTheme.caption.copyWith(
                    color: TossTheme.warning,
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
