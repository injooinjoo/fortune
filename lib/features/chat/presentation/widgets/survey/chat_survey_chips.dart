import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../domain/models/fortune_survey_config.dart';

/// 설문조사 선택지 칩 위젯
class ChatSurveyChips extends StatelessWidget {
  final List<SurveyOption> options;
  final void Function(SurveyOption option) onSelect;
  final bool allowMultiple;
  final Set<String>? selectedIds;

  const ChatSurveyChips({
    super.key,
    required this.options,
    required this.onSelect,
    this.allowMultiple = false,
    this.selectedIds,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? colors.backgroundSecondary : colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.textPrimary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Wrap(
        spacing: DSSpacing.xs,
        runSpacing: DSSpacing.xs,
        alignment: WrapAlignment.start,
        children: options.map((option) {
          final isSelected = selectedIds?.contains(option.id) ?? false;
          return _SurveyChip(
            option: option,
            isSelected: isSelected,
            onTap: () => onSelect(option),
          );
        }).toList(),
      ),
    );
  }
}

class _SurveyChip extends StatelessWidget {
  final SurveyOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _SurveyChip({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          DSHaptics.light();
          onTap();
        },
        borderRadius: BorderRadius.circular(DSRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.accentSecondary.withValues(alpha: 0.2)
                : (isDark ? colors.backgroundSecondary : colors.surface),
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: isSelected
                  ? colors.accentSecondary
                  : colors.textPrimary.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (option.emoji != null) ...[
                Text(option.emoji!, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: DSSpacing.xs),
              ] else if (option.icon != null) ...[
                Icon(
                  option.icon,
                  size: 16,
                  color: isSelected
                      ? colors.accentSecondary
                      : colors.textSecondary,
                ),
                const SizedBox(width: DSSpacing.xs),
              ],
              Text(
                option.label,
                style: typography.labelMedium.copyWith(
                  color: isSelected
                      ? colors.accentSecondary
                      : colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: DSSpacing.xs),
                Icon(
                  Icons.check,
                  size: 14,
                  color: colors.accentSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 설문 다중 선택 칩 (multiSelect용)
class ChatSurveyMultiSelectChips extends StatefulWidget {
  final List<SurveyOption> options;
  final void Function(Set<String> selectedIds) onSelectionChanged;
  final int? maxSelections;

  const ChatSurveyMultiSelectChips({
    super.key,
    required this.options,
    required this.onSelectionChanged,
    this.maxSelections,
  });

  @override
  State<ChatSurveyMultiSelectChips> createState() =>
      _ChatSurveyMultiSelectChipsState();
}

class _ChatSurveyMultiSelectChipsState
    extends State<ChatSurveyMultiSelectChips> {
  final Set<String> _selectedIds = {};

  void _toggleSelection(SurveyOption option) {
    setState(() {
      if (_selectedIds.contains(option.id)) {
        _selectedIds.remove(option.id);
      } else {
        if (widget.maxSelections == null ||
            _selectedIds.length < widget.maxSelections!) {
          _selectedIds.add(option.id);
        }
      }
      widget.onSelectionChanged(_selectedIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChatSurveyChips(
      options: widget.options,
      onSelect: _toggleSelection,
      allowMultiple: true,
      selectedIds: _selectedIds,
    );
  }
}
