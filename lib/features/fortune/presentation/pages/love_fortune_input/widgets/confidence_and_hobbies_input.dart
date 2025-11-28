import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_theme.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// Section 8: 외모 자신감 & 취미
class ConfidenceAndHobbiesInput extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          style: TypographyUnified.labelLarge.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '1점 (전혀 자신 없음) ~ 10점 (매우 자신 있음)',
          style: TypographyUnified.labelSmall.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
          ),
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: _getConfidenceColor(appearanceConfidence),
            inactiveTrackColor: TossTheme.borderGray200,
            thumbColor: _getConfidenceColor(appearanceConfidence),
            overlayColor: _getConfidenceColor(appearanceConfidence).withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            trackHeight: 6,
          ),
          child: Slider(
            value: appearanceConfidence,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: onConfidenceChanged,
          ),
        ),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(appearanceConfidence),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${appearanceConfidence.round()}점',
                  style: TypographyUnified.bodyMedium.copyWith(
                    color: TossDesignSystem.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getConfidenceText(appearanceConfidence),
                style: TypographyUnified.labelMedium.copyWith(
                  color: _getConfidenceColor(appearanceConfidence),
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
          style: TypographyUnified.labelLarge.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '여러 개 선택 가능',
          style: TypographyUnified.labelMedium.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
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
                TossDesignSystem.hapticLight();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                      : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hobby['emoji'] as String,
                      style: TypographyUnified.bodyMedium,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hobby['text'] as String,
                      style: TypographyUnified.bodySmall.copyWith(
                        color: isSelected
                            ? TossDesignSystem.tossBlue
                            : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
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

  Color _getConfidenceColor(double confidence) {
    if (confidence <= 3) {
      return TossTheme.error;
    } else if (confidence <= 5) {
      return TossTheme.warning;
    } else if (confidence <= 7) {
      return TossTheme.success;
    } else {
      return TossTheme.primaryBlue;
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
