import 'package:flutter/material.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/design_system/design_system.dart';

/// 성별 및 연령대 선택 위젯
/// 관상 분석 시 성별/연령에 따른 맞춤 결과를 제공하기 위해 사용합니다.
class GenderSelectionWidget extends StatefulWidget {
  /// 초기 성별 값
  final String? initialGender;

  /// 초기 연령대 값
  final String? initialAgeGroup;

  /// 성별 변경 콜백
  final ValueChanged<String> onGenderChanged;

  /// 연령대 변경 콜백
  final ValueChanged<String?>? onAgeGroupChanged;

  /// 연령대 선택 표시 여부
  final bool showAgeGroup;

  /// 컴팩트 모드 (한 줄 표시)
  final bool compact;

  const GenderSelectionWidget({
    super.key,
    this.initialGender,
    this.initialAgeGroup,
    required this.onGenderChanged,
    this.onAgeGroupChanged,
    this.showAgeGroup = true,
    this.compact = false,
  });

  @override
  State<GenderSelectionWidget> createState() => _GenderSelectionWidgetState();
}

class _GenderSelectionWidgetState extends State<GenderSelectionWidget> {
  late String? _selectedGender;
  late String? _selectedAgeGroup;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.initialGender;
    _selectedAgeGroup = widget.initialAgeGroup;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactView(context);
    }
    return _buildExpandedView(context);
  }

  Widget _buildCompactView(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GenderButton(
            gender: 'female',
            label: '여성',
            emoji: '👩',
            isSelected: _selectedGender == 'female',
            onTap: () => _selectGender('female'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GenderButton(
            gender: 'male',
            label: '남성',
            emoji: '👨',
            isSelected: _selectedGender == 'male',
            onTap: () => _selectGender('male'),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 성별 선택 섹션
        Text(
          '성별을 선택해주세요',
          style: context.heading4.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '성별에 따라 맞춤 분석 결과를 제공해드려요',
          style: context.bodySmall.copyWith(
            color: DSColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // 성별 버튼들
        Row(
          children: [
            Expanded(
              child: _GenderCard(
                gender: 'female',
                label: '여성',
                emoji: '👩',
                description: '연애운, 결혼운, 메이크업 추천',
                isSelected: _selectedGender == 'female',
                onTap: () => _selectGender('female'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _GenderCard(
                gender: 'male',
                label: '남성',
                emoji: '👨',
                description: '직업운, 리더십, 비즈니스 운세',
                isSelected: _selectedGender == 'male',
                onTap: () => _selectGender('male'),
              ),
            ),
          ],
        ),

        // 연령대 선택 섹션
        if (widget.showAgeGroup && _selectedGender != null) ...[
          const SizedBox(height: 32),
          Text(
            '연령대를 선택해주세요',
            style: context.heading4.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '더 정확한 분석을 위해 알려주세요 (선택)',
            style: context.bodySmall.copyWith(
              color: DSColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildAgeGroupSelector(context),
        ],
      ],
    );
  }

  Widget _buildAgeGroupSelector(BuildContext context) {
    final ageGroups = [
      ('10s', '10대'),
      ('20s', '20대'),
      ('30s', '30대'),
      ('40s', '40대'),
      ('50+', '50대+'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ageGroups.map((group) {
        final isSelected = _selectedAgeGroup == group.$1;
        return GestureDetector(
          onTap: () => _selectAgeGroup(group.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? DSColors.accent.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? DSColors.accent
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              group.$2,
              style: context.buttonSmall.copyWith(
                color: isSelected ? DSColors.accent : DSColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _selectGender(String gender) {
    setState(() => _selectedGender = gender);
    widget.onGenderChanged(gender);
  }

  void _selectAgeGroup(String ageGroup) {
    setState(() {
      if (_selectedAgeGroup == ageGroup) {
        _selectedAgeGroup = null;
      } else {
        _selectedAgeGroup = ageGroup;
      }
    });
    widget.onAgeGroupChanged?.call(_selectedAgeGroup);
  }
}

/// 성별 버튼 (컴팩트 모드용)
class _GenderButton extends StatelessWidget {
  final String gender;
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.gender,
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? DSColors.accent.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? DSColors.accent : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: context.buttonMedium.copyWith(
                color: isSelected ? DSColors.accent : DSColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 성별 카드 (확장 모드용)
class _GenderCard extends StatelessWidget {
  final String gender;
  final String label;
  final String emoji;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.gender,
    required this.label,
    required this.emoji,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? DSColors.accent.withOpacity(isDark ? 0.2 : 0.1)
              : isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? DSColors.accent
                : isDark
                    ? Colors.grey.shade700
                    : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: DSColors.accent.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // 이모지
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 12),

            // 라벨
            Text(
              label,
              style: context.heading4.copyWith(
                color: isSelected ? DSColors.accent : null,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // 설명
            Text(
              description,
              textAlign: TextAlign.center,
              style: context.labelSmall.copyWith(
                color: DSColors.textSecondary,
                height: 1.4,
              ),
            ),

            // 체크 표시
            if (isSelected) ...[
              const SizedBox(height: 12),
              Icon(
                Icons.check_circle,
                color: DSColors.accent,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
