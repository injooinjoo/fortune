import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/design_system/design_system.dart';

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
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 나이 슬라이더
        Text(
          '나이',
          style: DSTypography.labelLarge.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: colors.accent,
            inactiveTrackColor: colors.border,
            thumbColor: colors.accent,
            overlayColor: colors.accent.withValues(alpha: 0.2),
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
              color: colors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$age세',
              style: DSTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 성별 선택
        Text(
          '성별',
          style: DSTypography.labelLarge.copyWith(
            color: colors.textPrimary,
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
                colors,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderButton(
                context,
                'female',
                '여성',
                Icons.female,
                colors,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 연애 상태 선택
        Text(
          '현재 연애 상태',
          style: DSTypography.labelLarge.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ..._buildRelationshipStatusButtons(colors),
      ],
    );
  }

  Widget _buildGenderButton(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    DSColorScheme colors,
  ) {
    final isSelected = gender == value;
    return InkWell(
      onTap: () {
        onGenderChanged(value);
        HapticFeedback.lightImpact();
        _checkComplete();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accent.withValues(alpha: 0.1)
              : colors.surface,
          border: Border.all(
            color: isSelected ? colors.accent : colors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? colors.accent : colors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: DSTypography.bodyMedium.copyWith(
                color: isSelected ? colors.accent : colors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRelationshipStatusButtons(DSColorScheme colors) {
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
            HapticFeedback.lightImpact();
            _checkComplete();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.accent.withValues(alpha: 0.1)
                  : colors.surface,
              border: Border.all(
                color: isSelected ? colors.accent : colors.border,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  status['emoji'] as String,
                  style: DSTypography.displaySmall,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    status['text'] as String,
                    style: DSTypography.bodyMedium.copyWith(
                      color: isSelected ? colors.accent : colors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: colors.accent,
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
