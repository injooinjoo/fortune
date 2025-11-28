import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_theme.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// Section 4: 선호 나이대 (RangeSlider)
class PreferredAgeRangeInput extends StatelessWidget {
  final RangeValues preferredAgeRange;
  final ValueChanged<RangeValues> onAgeRangeChanged;

  const PreferredAgeRangeInput({
    super.key,
    required this.preferredAgeRange,
    required this.onAgeRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '18세',
              style: TypographyUnified.bodySmall.copyWith(
                color: isDark ? TossDesignSystem.textTertiaryDark : TossTheme.textGray500,
              ),
            ),
            Text(
              '45세',
              style: TypographyUnified.bodySmall.copyWith(
                color: isDark ? TossDesignSystem.textTertiaryDark : TossTheme.textGray500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: preferredAgeRange,
          min: 18,
          max: 45,
          divisions: 27,
          activeColor: TossDesignSystem.tossBlue,
          inactiveColor: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200,
          onChanged: onAgeRangeChanged,
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${preferredAgeRange.start.round()}세 ~ ${preferredAgeRange.end.round()}세',
              style: TypographyUnified.bodyMedium.copyWith(
                color: TossDesignSystem.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
