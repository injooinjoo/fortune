import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class PersonalityTraitsChips extends StatelessWidget {
  final List<String> selectedTraits;
  final ValueChanged<List<String>> onTraitsChanged;
  final int maxSelection;

  const PersonalityTraitsChips({
    Key? key,
    required this.selectedTraits,
    required this.onTraitsChanged,
    this.maxSelection = 5,
  }) : super(key: key);

  static const List<String> _availableTraits = [
    '외향적인', '내향적인', '감정적인', '논리적인', '창의적인', '현실적인',
    '모험적인', '신중한', '낙관적인', '비관적인', '독립적인', '협력적인',
    '완벽주의', '자유로운', '계획적인', '즉흥적인', '리더십', '팔로워',
    '경쟁적인', '협력적인', '호기심많은', '보수적인', '유머있는', '진지한',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '나를 잘 나타내는 성격 특성을 선택하세요 (최대 ${maxSelection}개)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _availableTraits.map((trait) {
            final isSelected = selectedTraits.contains(trait);
            return FilterChip(
              label: Text(trait),
              selected: isSelected,
              onSelected: (selected) {
                List<String> newTraits = List.from(selectedTraits);
                
                if (selected) {
                  if (newTraits.length < maxSelection) {
                    newTraits.add(trait);
                  }
                } else {
                  newTraits.remove(trait);
                }
                
                onTraitsChanged(newTraits);
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: theme.primaryColor,
              side: BorderSide(
                color: isSelected
                    ? theme.primaryColor
                    : theme.colorScheme.outline.withValues(alpha: 0.5),
                width: 1,
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ).animate().fadeIn(delay: Duration(milliseconds: 50 * _availableTraits.indexOf(trait)));
          }).toList(),
        ),
        
        if (selectedTraits.length == maxSelection)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '최대 ${maxSelection}개까지 선택할 수 있습니다',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class PersonalityTraitChip extends StatelessWidget {
  final String trait;
  final bool isSelected;
  final VoidCallback onTap;
  final bool enabled;

  const PersonalityTraitChip({
    Key? key,
    required this.trait,
    required this.isSelected,
    required this.onTap,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          trait,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.primaryColor
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}