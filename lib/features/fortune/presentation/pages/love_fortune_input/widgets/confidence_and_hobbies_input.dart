import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/services/fortune_haptic_service.dart';

/// Section 8: 외모 자신감 & 취미
class ConfidenceAndHobbiesInput extends ConsumerWidget {
  final double appearanceConfidence;
  final Set<String> selectedHobbies;
  final ValueChanged<double> onConfidenceChanged;
  final ValueChanged<String> onHobbyToggled;

  const ConfidenceAndHobbiesInput({
    super.key,
    required this.appearanceConfidence,
    required this.selectedHobbies,
    required this.onConfidenceChanged,
    required this.onHobbyToggled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    final hobbyOptions = [
      {'id': 'exercise', 'text': '운동', 'emoji': '🏃'},
      {'id': 'reading', 'text': '독서', 'emoji': '📖'},
      {'id': 'travel', 'text': '여행', 'emoji': '✈️'},
      {'id': 'cooking', 'text': '요리', 'emoji': '👨‍🍳'},
      {'id': 'gaming', 'text': '게임', 'emoji': '🎮'},
      {'id': 'movie', 'text': '영화', 'emoji': '🎬'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 외모 자신감
        Text(
          '외모 자신감',
          style: DSTypography.labelLarge.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '1점 (전혀 자신 없음) ~ 10점 (매우 자신 있음)',
          style: DSTypography.labelSmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: _getConfidenceColor(appearanceConfidence, colors),
            inactiveTrackColor: colors.border,
            thumbColor: _getConfidenceColor(appearanceConfidence, colors),
            overlayColor: _getConfidenceColor(appearanceConfidence, colors).withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            trackHeight: 6,
          ),
          child: Slider(
            value: appearanceConfidence,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (newValue) {
              if (newValue.round() != appearanceConfidence.round()) {
                ref.read(fortuneHapticServiceProvider).sliderSnap();
              }
              onConfidenceChanged(newValue);
            },
          ),
        ),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(appearanceConfidence, colors),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${appearanceConfidence.round()}점',
                  style: DSTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getConfidenceText(appearanceConfidence),
                style: DSTypography.labelMedium.copyWith(
                  color: _getConfidenceColor(appearanceConfidence, colors),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 취미
        Text(
          '취미',
          style: DSTypography.labelLarge.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '여러 개 선택 가능',
          style: DSTypography.labelMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: hobbyOptions.map((hobby) {
            final hobbyId = hobby['id'] as String;
            final isSelected = selectedHobbies.contains(hobbyId);
            return InkWell(
              onTap: () {
                onHobbyToggled(hobbyId);
                ref.read(fortuneHapticServiceProvider).selection();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.accent.withValues(alpha: 0.1)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? colors.accent : colors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hobby['emoji'] as String,
                      style: DSTypography.bodyMedium,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hobby['text'] as String,
                      style: DSTypography.bodySmall.copyWith(
                        color: isSelected ? colors.accent : colors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getConfidenceColor(double confidence, DSColorScheme colors) {
    if (confidence <= 3) {
      return DSColors.error;
    } else if (confidence <= 5) {
      return DSColors.warning;
    } else if (confidence <= 7) {
      return DSColors.success;
    } else {
      return colors.accent;
    }
  }

  String _getConfidenceText(double confidence) {
    if (confidence <= 3) {
      return '보완이 필요해요';
    } else if (confidence <= 5) {
      return '평범해요';
    } else if (confidence <= 7) {
      return '괜찮은 편이에요';
    } else if (confidence <= 9) {
      return '자신 있어요';
    } else {
      return '매우 자신 있어요';
    }
  }
}
