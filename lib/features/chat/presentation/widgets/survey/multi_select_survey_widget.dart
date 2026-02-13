import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../domain/models/fortune_survey_config.dart';
import 'chat_survey_chips.dart';

/// 다중 선택 설문 위젯 (완료 버튼 포함)
class MultiSelectSurveyWidget extends StatefulWidget {
  final List<SurveyOption> options;
  final int maxSelections;
  final void Function(List<String> selectedIds) onConfirm;

  const MultiSelectSurveyWidget({
    super.key,
    required this.options,
    required this.maxSelections,
    required this.onConfirm,
  });

  @override
  State<MultiSelectSurveyWidget> createState() => _MultiSelectSurveyWidgetState();
}

class _MultiSelectSurveyWidgetState extends State<MultiSelectSurveyWidget> {
  final Set<String> _selectedIds = {};

  void _toggleSelection(SurveyOption option) {
    setState(() {
      if (_selectedIds.contains(option.id)) {
        _selectedIds.remove(option.id);
      } else {
        if (_selectedIds.length < widget.maxSelections) {
          _selectedIds.add(option.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 칩 선택 영역
        ChatSurveyChips(
          options: widget.options,
          onSelect: _toggleSelection,
          allowMultiple: true,
          selectedIds: _selectedIds,
        ),
        // 완료 버튼
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.sm,
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedIds.isEmpty
                  ? null
                  : () => widget.onConfirm(_selectedIds.toList()),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.ctaBackground,
                foregroundColor: colors.ctaForeground,
                disabledBackgroundColor:
                    colors.textTertiary.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSRadius.md),
                ),
              ),
              child: Text(
                _selectedIds.isEmpty
                    ? '선택해주세요'
                    : '완료 (${_selectedIds.length}/${widget.maxSelections})',
                style: context.typography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
