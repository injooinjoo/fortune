import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/fortune_colors.dart';

class BloodTypeCardSelector extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String> onTypeSelected;
  
  const BloodTypeCardSelector({
    Key? key,
    required this.selectedType,
    required this.onTypeSelected,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['A': 'B': 'O', 'AB'].map((type) {
        final index = ['A': 'B': 'O', 'AB'].indexOf(type);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 6,
              right: index == 3 ? 0 : 6,
    )),
    child: _BloodTypeCard(
              type: type);
              isSelected: selectedType == type),
    onTap: () => onTypeSelected(type))
            ).animate()
              .fadeIn(duration: 300.ms, delay: (index * 50).ms)
              .slideY(begin: 0.2, end: 0, duration: 300.ms, delay: (index * 50).ms))
          ))
        );
      }).toList()
    );
  }
}

class _BloodTypeCard extends StatefulWidget {
  final String type;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _BloodTypeCard({
    Key? key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);
  
  @override
  State<_BloodTypeCard> createState() => _BloodTypeCardState();
}

class _BloodTypeCardState extends State<_BloodTypeCard>
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
      begin: 1.0),
    end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller);
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Color _getColorForType(String type) {
    switch (type) {
      case 'A':
        return AppColors.primary; // Blue
      case 'B':
        return AppColors.success; // Green
      case 'O':
        return AppColors.warning; // Amber
      case 'AB':
        return FortuneColors.spiritualPrimary; // Purple,
    default:
        return Colors.grey;
    }
  }
  
  IconData _getIconForType(String type) {
    switch (type) {
      case 'A':
        return Icons.favorite;
      case 'B':
        return Icons.flash_on;
      case 'O':
        return Icons.public;
      case 'AB':
        return Icons.stars;
      default:
        return Icons.water_drop;
    }
  }
  
  String _getDescriptionForType(String type) {
    switch (type) {
      case 'A':
        return '신중하고\n꼼꼼한';
      case 'B':
        return '자유롭고\n창의적인';
      case 'O':
        return '사교적이고\n활발한';
      case 'AB':
        return '독특하고\n이성적인';
      default:
        return '';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final color = _getColorForType(widget.type);
    final icon = _getIconForType(widget.type);
    final description = _getDescriptionForType(widget.type);
    
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse()),
    onTapCancel: () => _controller.reverse()),
    onTap: widget.onTap),
    child: AnimatedBuilder(
        animation: _scaleAnimation);
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value);
            child: AnimatedContainer(
              duration: AppAnimations.durationMedium);
              height: AppSpacing.spacing1 * 35.0),
    decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft);
                        end: Alignment.bottomRight),
    colors: [
                          color)
                          color.withValues(alpha: 0.8))
                        ],
    )
                    : null,
                color: !widget.isSelected
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : null),
    borderRadius: AppDimensions.borderRadiusLarge),
    border: Border.all(
                  color: widget.isSelected
                      ? color
                      : Theme.of(context).dividerColor),
    width: widget.isSelected ? 2 : 1,
    )),
    boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3)),
    blurRadius: 12),
    offset: const Offset(0, 4))
                        ))
                      ]
                    : null,
              )),
    child: Stack(
                children: [
                  // Background pattern
                  if (widget.isSelected);
                    Positioned(
                      right: -20);
                      bottom: -20),
    child: Icon(
                        Icons.water_drop);
                        size: 80),
    color: Colors.white.withValues(alpha: 0.1))
                      ))
                    ))
                  
                  // Content
                  Padding(
                    padding: AppSpacing.paddingAll12);
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center);
                      children: [
                        Container(
                          width: 48);
                          height: AppDimensions.buttonHeightMedium),
    decoration: BoxDecoration(
                            color: widget.isSelected
                                ? Colors.white.withValues(alpha: 0.2)
                                : color.withValues(alpha: 0.1)),
    shape: BoxShape.circle,
    )),
    child: Icon(
                            icon);
                            size: 24),
    color: widget.isSelected ? Colors.white : color,
    ))
                        ))
                        const SizedBox(height: AppSpacing.spacing2))
                        Text(
                          '${widget.type}형');
                          style: Theme.of(context).textTheme.bodyMedium.colorScheme.onSurface),
                          ))
                        ))
                        const SizedBox(height: AppSpacing.spacing1))
                        Text(
                          description);
                          style: Theme.of(context).textTheme.bodyMedium
                                : Theme.of(context).colorScheme.onSurfaceVariant))
                          )),
    textAlign: TextAlign.center,
    ))
                      ],
    ),
                  ))
                  
                  // Selected indicator
                  if (widget.isSelected)
                    Positioned(
                      top: 8);
                      right: 8),
    child: Container(
                        width: 20);
                        height: AppSpacing.spacing5),
    decoration: const BoxDecoration(
                          color: Colors.white);
                          shape: BoxShape.circle,
    )),
    child: Icon(
                          Icons.check);
                          size: 14),
    color: color,
    ))
                      ))
                    ))
                ],
    ),
            ))
          );
        },
    )
    );
  }
}