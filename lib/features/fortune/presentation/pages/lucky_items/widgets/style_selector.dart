import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';

/// 7가지 패션 스타일 선택기
/// 힙하게, 단정하게, 섹시하게, 지적이게, 내추럴, 로맨틱, 스포티
class StyleSelector extends StatelessWidget {
  final String? selectedStyle;
  final ValueChanged<String> onStyleSelected;

  const StyleSelector({
    super.key,
    this.selectedStyle,
    required this.onStyleSelected,
  });

  static const List<StyleOption> styles = [
    StyleOption(
      id: 'hip',
      label: '힙하게',
      icon: Icons.whatshot,
      description: '트렌디하고 개성 있는 스타일',
    ),
    StyleOption(
      id: 'neat',
      label: '단정하게',
      icon: Icons.business_center,
      description: '깔끔하고 정돈된 스타일',
    ),
    StyleOption(
      id: 'sexy',
      label: '섹시하게',
      icon: Icons.favorite,
      description: '매력적이고 세련된 스타일',
    ),
    StyleOption(
      id: 'intellectual',
      label: '지적이게',
      icon: Icons.school,
      description: '스마트하고 세련된 스타일',
    ),
    StyleOption(
      id: 'natural',
      label: '내추럴',
      icon: Icons.nature,
      description: '편안하고 자연스러운 스타일',
    ),
    StyleOption(
      id: 'romantic',
      label: '로맨틱',
      icon: Icons.favorite_border,
      description: '부드럽고 여성스러운 스타일',
    ),
    StyleOption(
      id: 'sporty',
      label: '스포티',
      icon: Icons.sports_basketball,
      description: '활동적이고 건강한 스타일',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 스타일 선택',
          style: DSTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: styles.map((style) {
            final isSelected = selectedStyle == style.id;
            return _buildStyleChip(context, style, isSelected, colors);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStyleChip(
    BuildContext context,
    StyleOption style,
    bool isSelected,
    DSColorScheme colors,
  ) {
    return GestureDetector(
      onTap: () => onStyleSelected(style.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.accent : colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colors.accent : colors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              style.icon,
              size: 16,
              color: isSelected ? Colors.white : colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              style.label,
              style: DSTypography.bodySmall.copyWith(
                color: isSelected ? Colors.white : colors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 스타일 옵션 모델
class StyleOption {
  final String id;
  final String label;
  final IconData icon;
  final String description;

  const StyleOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.description,
  });
}
