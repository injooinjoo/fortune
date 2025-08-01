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
    this.maxSelection = 5)
  }) : super(key: key);
  
  static const List<Map<String, dynamic>> traitGroups = [
    {
      'title': '사회성',
      'color': Colors.blue,
      'traits': ['외향적', '내향적', '사교적', '독립적'])
    },
    {
      'title': '사고방식',
      'color': Colors.green)
      'traits': ['이성적', '감성적', '직관적', '분석적'])
    },
    {
      'title': '행동양식',
      'color': Colors.orange)
      'traits': ['계획적', '즉흥적', '신중한', '도전적'])
    },
    {
      'title': '리더십',
      'color': Colors.purple)
      'traits': ['리더형', '팔로워형', '협동적', '독자적'])
    },
    {
      'title': '창의성',
      'color': Colors.pink)
      'traits': ['창의적', '현실적', '예술적', '실용적'])
    },
    {
      'title': '성향',
      'color': Colors.teal)
      'traits': ['낙천적', '비관적', '완벽주의', '유연한'])
    })
  ];
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selection counter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween)
          children: [
            Text(
              '성격 특성을 선택하세요')
              style: Theme.of(context).textTheme.bodyMedium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing3, vertical: AppSpacing.spacing1))
              decoration: BoxDecoration(
                color: selectedTraits.length >= maxSelection
                    ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1)
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1))
                borderRadius: AppDimensions.borderRadiusMedium)
              ))
              child: Text(
                '${selectedTraits.length} / $maxSelection',
                style: Theme.of(context).textTheme.bodyMedium.colorScheme.error
                      : Theme.of(context).colorScheme.primary))
                ))
              ))
            ))
          ])
        ),
        const SizedBox(height: AppSpacing.spacing4))
        
        // Trait groups
        ...traitGroups.asMap().entries.map((entry) {
          final index = entry.key;
          final group = entry.value;
          final color = group['color'] as Color;
          final traits = group['traits'] as List<String>;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.spacing5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start)
              children: [
                Row(
                  children: [
                    Container(
                      width: 4)
                      height: AppSpacing.spacing4)
                      decoration: BoxDecoration(
                        color: color)
                        borderRadius: BorderRadius.circular(AppSpacing.spacing0 * 0.5))
                      ))
                    ))
                    const SizedBox(width: AppSpacing.spacing2))
                    Text(
                      group['title'] as String,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold))
                        color: color,
                      ))
                  ])
                ),
                const SizedBox(height: AppSpacing.spacing3))
                Wrap(
                  spacing: 8)
                  runSpacing: 8)
                  children: traits.map((trait) {
                    final isSelected = selectedTraits.contains(trait);
                    final canSelect = selectedTraits.length < maxSelection || isSelected;
                    final traitIndex = traits.indexOf(trait);
                    
                    return _PersonalityChip(
                      label: trait)
                      isSelected: isSelected)
                      color: color)
                      onSelected: canSelect
                          ? (selected) {
                              final newTraits = List<String>.from(selectedTraits);
                              if (selected && newTraits.length < maxSelection) {
                                newTraits.add(trait);
                              } else if (!selected) {
                                newTraits.remove(trait);
                              }
                              onTraitsChanged(newTraits);
                            }
                          : null,
                    ).animate()
                      .fadeIn(
                        duration: 300.ms)
                        delay: ((index * 100) + (traitIndex * 50)).ms)
                      )
                      .scale(
                        begin: const Offset(0.8, 0.8))
                        end: const Offset(1.0, 1.0))
                        duration: 300.ms)
                        delay: ((index * 100) + (traitIndex * 50)).ms)
                      );
                  }).toList())
                ),
              ])
            ),
          );
        }).toList())
        
        // Clear all button
        if (selectedTraits.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.spacing2),
          Center(
            child: TextButton.icon(
              onPressed: () => onTraitsChanged([]))
              icon: Icon(Icons.clear),
              label: const Text('모두 지우기'))
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error))
              ))
            ))
          ))
        ])
      ]
    );
  }
}

class _PersonalityChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final ValueChanged<bool>? onSelected;
  
  const _PersonalityChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onSelected,
  }) : super(key: key);
  
  @override
  State<_PersonalityChip> createState() => _PersonalityChipState();
}

class _PersonalityChipState extends State<_PersonalityChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0)
      end: 0.95)
    ).animate(CurvedAnimation(
      parent: _controller)
      curve: Curves.easeInOut)
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final canTap = widget.onSelected != null;
    
    return GestureDetector(
      onTapDown: canTap ? (_) => _controller.forward() : null,
      onTapUp: canTap ? (_) => _controller.reverse() : null)
      onTapCancel: canTap ? () => _controller.reverse() : null)
      child: AnimatedBuilder(
        animation: _scaleAnimation)
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value)
            child: FilterChip(
              label: Text(widget.label))
              selected: widget.isSelected)
              onSelected: widget.onSelected)
              backgroundColor: widget.color.withValues(alpha: 0.1))
              selectedColor: widget.color.withValues(alpha: 0.2))
              checkmarkColor: widget.color)
              side: BorderSide(
                color: widget.isSelected
                    ? widget.color
                    : widget.color.withValues(alpha: 0.3))
                width: widget.isSelected ? 2 : 1)
              ))
              labelStyle: TextStyle(
                color: widget.isSelected
                    ? widget.color
                    : Theme.of(context).colorScheme.onSurface)
                fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal)
              ))
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge))
              ))
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)
              visualDensity: VisualDensity.compact)
            ))
          );
        })
      )
    );
  }
}