import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_theme.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// Section 3: 중요한 가치 (5개 슬라이더)
class ValueImportanceInput extends StatelessWidget {
  final Map<String, double> valueImportance;
  final ValueChanged<MapEntry<String, double>> onValueChanged;

  const ValueImportanceInput({
    super.key,
    required this.valueImportance,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: TossTheme.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '1~5점으로 평가',
            style: TypographyUnified.labelMedium.copyWith(
              color: TossTheme.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '각 항목이 연애할 때 얼마나 중요한지 점수를 매겨주세요',
          style: TypographyUnified.bodySmall.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
          ),
        ),
        const SizedBox(height: 20),
        ...valueImportance.entries.map((entry) {
          return _buildValueSlider(entry.key, entry.value, isDark);
        }),
      ],
    );
  }

  Widget _buildValueSlider(String label, double value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TypographyUnified.bodyMedium.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(value).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value.round()}점',
                  style: TypographyUnified.labelLarge.copyWith(
                    color: _getScoreColor(value),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _getScoreColor(value),
              inactiveTrackColor: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200,
              thumbColor: _getScoreColor(value),
              overlayColor: _getScoreColor(value).withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (newValue) {
                onValueChanged(MapEntry(label, newValue));
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score <= 2) {
      return TossTheme.textGray500;
    } else if (score <= 3) {
      return TossTheme.warning;
    } else if (score <= 4) {
      return TossTheme.success;
    } else {
      return TossTheme.primaryBlue;
    }
  }
}
