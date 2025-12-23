import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/services/fortune_haptic_service.dart';

/// Section 4: 선호 나이대 (RangeSlider)
class PreferredAgeRangeInput extends ConsumerWidget {
  final RangeValues preferredAgeRange;
  final ValueChanged<RangeValues> onAgeRangeChanged;

  const PreferredAgeRangeInput({
    super.key,
    required this.preferredAgeRange,
    required this.onAgeRangeChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '18세',
              style: DSTypography.bodySmall.copyWith(
                color: colors.textTertiary,
              ),
            ),
            Text(
              '45세',
              style: DSTypography.bodySmall.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: colors.accent,
            inactiveTrackColor: colors.border,
            thumbColor: colors.accent,
            overlayColor: colors.accent.withValues(alpha: 0.2),
            rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
            trackHeight: 4,
          ),
          child: RangeSlider(
            values: preferredAgeRange,
            min: 18,
            max: 45,
            divisions: 27,
            onChanged: (newValues) {
              if (newValues.start.round() != preferredAgeRange.start.round() ||
                  newValues.end.round() != preferredAgeRange.end.round()) {
                ref.read(fortuneHapticServiceProvider).sliderSnap();
              }
              onAgeRangeChanged(newValues);
            },
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${preferredAgeRange.start.round()}세 ~ ${preferredAgeRange.end.round()}세',
              style: DSTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
