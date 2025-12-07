import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        onTap();
        HapticFeedback.mediumImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? TossDesignSystem.tossBlue
              : (isDark
                  ? TossDesignSystem.grayDark700
                  : TossDesignSystem.gray50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? TossDesignSystem.tossBlue
                : (isDark
                    ? TossDesignSystem.grayDark400
                    : TossDesignSystem.gray200),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: TossDesignSystem.tossBlue.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            mbti,
            style: TypographyUnified.buttonSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? TossDesignSystem.white
                  : (isDark ? TossDesignSystem.white : TossDesignSystem.gray800),
            ),
          ),
        ),
      ),
    );
  }
}
