import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_theme.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// Section 1: 기본 정보 (나이, 성별, 연애 상태)
class BasicInfoInput extends StatelessWidget {
  final int age;
  final String? gender;
  final String? relationshipStatus;
  final ValueChanged<int> onAgeChanged;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<String> onRelationshipStatusChanged;
  final VoidCallback onComplete;

  const BasicInfoInput({
    super.key,
    required this.age,
    required this.gender,
    required this.relationshipStatus,
    required this.onAgeChanged,
    required this.onGenderChanged,
    required this.onRelationshipStatusChanged,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 나이 슬라이더
        Text(
          '나이',
          style: TypographyUnified.labelLarge.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: TossDesignSystem.tossBlue,
            inactiveTrackColor: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200,
            thumbColor: TossDesignSystem.tossBlue,
            overlayColor: TossDesignSystem.tossBlue.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            trackHeight: 4,
          ),
          child: Slider(
            value: age.toDouble(),
            min: 18,
            max: 50,
            divisions: 32,
            onChanged: (value) => onAgeChanged(value.round()),
          ),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$age세',
              style: TypographyUnified.bodyMedium.copyWith(
                color: TossDesignSystem.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 성별 선택
        Text(
          '성별',
          style: TypographyUnified.labelLarge.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGenderButton(
                context,
                'male',
                '남성',
                Icons.male,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderButton(
                context,
                'female',
                '여성',
                Icons.female,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 연애 상태 선택
        Text(
          '현재 연애 상태',
          style: TypographyUnified.labelLarge.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ..._buildRelationshipStatusButtons(isDark),
      ],
    );
  }

  Widget _buildGenderButton(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = gender == value;
    return InkWell(
      onTap: () {
        onGenderChanged(value);
        TossDesignSystem.hapticLight();
        _checkComplete();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
              : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
          border: Border.all(
            color: isSelected
                ? TossDesignSystem.tossBlue
                : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? TossDesignSystem.tossBlue
                  : (isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TypographyUnified.bodyMedium.copyWith(
                color: isSelected
                    ? TossDesignSystem.tossBlue
                    : (isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRelationshipStatusButtons(bool isDark) {
    final statuses = [
      {'id': 'single', 'text': '싱글 (새로운 만남 희망)', 'emoji': '💫'},
      {'id': 'dating', 'text': '연애중 (관계 발전)', 'emoji': '💕'},
      {'id': 'breakup', 'text': '이별 후 (재회 또는 새출발)', 'emoji': '🌱'},
      {'id': 'crush', 'text': '짝사랑 중', 'emoji': '💘'},
    ];

    return statuses.map((status) {
      final isSelected = relationshipStatus == status['id'];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            onRelationshipStatusChanged(status['id'] as String);
            TossDesignSystem.hapticLight();
            _checkComplete();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                  : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
              border: Border.all(
                color: isSelected
                    ? TossDesignSystem.tossBlue
                    : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  status['emoji'] as String,
                  style: TypographyUnified.displaySmall,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    status['text'] as String,
                    style: TypographyUnified.bodyMedium.copyWith(
                      color: isSelected
                          ? TossDesignSystem.tossBlue
                          : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: TossDesignSystem.tossBlue,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void _checkComplete() {
    if (gender != null && relationshipStatus != null) {
      onComplete();
    }
  }
}
