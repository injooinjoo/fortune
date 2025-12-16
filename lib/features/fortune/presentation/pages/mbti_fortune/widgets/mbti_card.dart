import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortune/core/design_system/design_system.dart';

class MbtiCard extends StatelessWidget {
  final String mbti;
  final bool isSelected;
  final VoidCallback onTap;

  const MbtiCard({
    super.key,
    required this.mbti,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        onTap();
        HapticFeedback.mediumImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accent
              : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colors.accent
                : colors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            mbti,
            style: DSTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
