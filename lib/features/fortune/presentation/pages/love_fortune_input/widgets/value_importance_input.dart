import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/services/fortune_haptic_service.dart';

/// Section 3: 중요한 가치 (5개 슬라이더)
class ValueImportanceInput extends ConsumerWidget {
  final Map<String, double> valueImportance;
  final ValueChanged<MapEntry<String, double>> onValueChanged;

  const ValueImportanceInput({
    super.key,
    required this.valueImportance,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: DSColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '1~5점으로 평가',
            style: DSTypography.labelMedium.copyWith(
              color: DSColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '각 항목이 연애할 때 얼마나 중요한지 점수를 매겨주세요',
          style: DSTypography.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        ...valueImportance.entries.map((entry) {
          return _buildValueSlider(entry.key, entry.value, colors, ref);
        }),
      ],
    );
  }

  Widget _buildValueSlider(String label, double value, DSColorScheme colors, WidgetRef ref) {
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
                style: DSTypography.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(value, colors).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value.round()}점',
                  style: DSTypography.labelLarge.copyWith(
                    color: _getScoreColor(value, colors),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _getScoreColor(value, colors),
              inactiveTrackColor: colors.border,
              thumbColor: _getScoreColor(value, colors),
              overlayColor: _getScoreColor(value, colors).withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (newValue) {
                if (newValue.round() != value.round()) {
                  ref.read(fortuneHapticServiceProvider).sliderSnap();
                }
                onValueChanged(MapEntry(label, newValue));
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score, DSColorScheme colors) {
    if (score <= 2) {
      return colors.textSecondary;
    } else if (score <= 3) {
      return DSColors.warning;
    } else if (score <= 4) {
      return DSColors.success;
    } else {
      return colors.accent;
    }
  }
}
