import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';

class TossSectionWidget extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;

  const TossSectionWidget({
    super.key,
    required this.title,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: colors.accent,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: DSTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
