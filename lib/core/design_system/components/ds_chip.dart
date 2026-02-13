import 'package:flutter/material.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../theme/ds_extensions.dart';
import '../utils/ds_haptics.dart';

/// Chip style variants
enum DSChipStyle {
  /// Default chip with background
  filled,

  /// Outlined chip
  outlined,

  /// Subtle chip with light background
  subtle,
}

/// ChatGPT-inspired chip component
///
/// Usage:
/// ```dart
/// DSChip(label: '태그')
/// DSChip(label: '선택됨', selected: true)
/// DSChip(label: '삭제', onDeleted: () {})
/// ```
class DSChip extends StatelessWidget {
  /// Chip label
  final String label;

  /// Is selected
  final bool selected;

  /// Tap callback
  final VoidCallback? onTap;

  /// Delete callback
  final VoidCallback? onDeleted;

  /// Chip style
  final DSChipStyle style;

  /// Leading icon
  final IconData? icon;

  /// Enable haptic feedback
  final bool enableHaptic;

  const DSChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.onDeleted,
    this.style = DSChipStyle.filled,
    this.icon,
    this.enableHaptic = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    Color backgroundColor;
    Color foregroundColor;
    Color? borderColor;

    if (selected) {
      backgroundColor = colors.ctaBackground;
      foregroundColor = colors.ctaForeground;
    } else {
      switch (style) {
        case DSChipStyle.filled:
          backgroundColor = colors.backgroundTertiary;
          foregroundColor = colors.textPrimary;
          break;
        case DSChipStyle.outlined:
          backgroundColor = Colors.transparent;
          foregroundColor = colors.textPrimary;
          borderColor = colors.border;
          break;
        case DSChipStyle.subtle:
          backgroundColor = colors.backgroundTertiary;
          foregroundColor = colors.textPrimary;
          break;
      }
    }

    final Widget chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm + 4,
        vertical: DSSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(DSRadius.full),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foregroundColor),
            const SizedBox(width: DSSpacing.xs),
          ],
          Text(
            label,
            style: typography.labelSmall.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onDeleted != null) ...[
            const SizedBox(width: DSSpacing.xs),
            GestureDetector(
              onTap: () {
                if (enableHaptic) DSHaptics.light();
                onDeleted?.call();
              },
              child: Icon(
                Icons.close,
                size: 14,
                color: foregroundColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: () {
          if (enableHaptic) DSHaptics.selection();
          onTap?.call();
        },
        child: chip,
      );
    }

    return chip;
  }
}

/// Choice chips for single selection
///
/// Usage:
/// ```dart
/// DSChoiceChips(
///   options: ['옵션1', '옵션2', '옵션3'],
///   selected: 0,
///   onSelected: (index) => setState(() => _selected = index),
/// )
/// ```
class DSChoiceChips extends StatelessWidget {
  /// List of options
  final List<String> options;

  /// Selected index
  final int? selected;

  /// Selection callback
  final ValueChanged<int> onSelected;

  /// Chip style
  final DSChipStyle style;

  /// Spacing between chips
  final double spacing;

  const DSChoiceChips({
    super.key,
    required this.options,
    this.selected,
    required this.onSelected,
    this.style = DSChipStyle.filled,
    this.spacing = DSSpacing.sm,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: List.generate(options.length, (index) {
        return DSChip(
          label: options[index],
          selected: selected == index,
          style: style,
          onTap: () => onSelected(index),
        );
      }),
    );
  }
}

/// Filter chips for multiple selection
///
/// Usage:
/// ```dart
/// DSFilterChips(
///   options: ['필터1', '필터2', '필터3'],
///   selected: {0, 2},
///   onChanged: (selected) => setState(() => _selected = selected),
/// )
/// ```
class DSFilterChips extends StatelessWidget {
  /// List of options
  final List<String> options;

  /// Selected indices
  final Set<int> selected;

  /// Selection callback
  final ValueChanged<Set<int>> onChanged;

  /// Chip style
  final DSChipStyle style;

  /// Spacing between chips
  final double spacing;

  const DSFilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.style = DSChipStyle.filled,
    this.spacing = DSSpacing.sm,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: List.generate(options.length, (index) {
        final isSelected = selected.contains(index);
        return DSChip(
          label: options[index],
          selected: isSelected,
          style: style,
          onTap: () {
            final newSelected = Set<int>.from(selected);
            if (isSelected) {
              newSelected.remove(index);
            } else {
              newSelected.add(index);
            }
            onChanged(newSelected);
          },
        );
      }),
    );
  }
}
