import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';

/// 채팅 날짜 선택 위젯 (바이오리듬, 스포츠 경기용)
class ChatDatePicker extends StatefulWidget {
  final void Function(DateTime date) onDateSelected;
  final String? hintText;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final List<QuickDateOption>? quickOptions;

  const ChatDatePicker({
    super.key,
    required this.onDateSelected,
    this.hintText,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.quickOptions,
  });

  @override
  State<ChatDatePicker> createState() => _ChatDatePickerState();
}

class _ChatDatePickerState extends State<ChatDatePicker> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  Future<void> _openDatePicker() async {
    DSHaptics.light();

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: widget.firstDate ?? DateTime(now.year - 1),
      lastDate: widget.lastDate ?? DateTime(now.year + 1),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF7C3AED),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF7C3AED),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      widget.onDateSelected(picked);
    }
  }

  void _selectQuickOption(QuickDateOption option) {
    DSHaptics.light();
    final date = option.getDate();
    setState(() => _selectedDate = date);
    widget.onDateSelected(date);
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final defaultQuickOptions = widget.quickOptions ?? [
      QuickDateOption.today(),
      QuickDateOption.tomorrow(),
      QuickDateOption.thisWeekend(),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      // 투명 배경 - 하단 입력 영역과 일관성 유지
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.hintText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Text(
                widget.hintText!,
                style: typography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          // 빠른 선택 옵션
          Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xs,
            children: [
              ...defaultQuickOptions.map((option) => _QuickDateChip(
                    option: option,
                    isSelected: _selectedDate != null &&
                        _isSameDay(_selectedDate!, option.getDate()),
                    onTap: () => _selectQuickOption(option),
                  )),
              // 직접 선택 버튼
              _DatePickerChip(
                selectedDate: _selectedDate,
                onTap: _openDatePicker,
              ),
            ],
          ),
          // 선택된 날짜 표시
          if (_selectedDate != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colors.accentSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Text(
                '선택: ${_formatDate(_selectedDate!)}',
                style: typography.labelSmall.copyWith(
                  color: colors.accentSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _QuickDateChip extends StatelessWidget {
  final QuickDateOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickDateChip({
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
        onTap: onTap,
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
                Text(option.emoji!, style: const TextStyle(fontSize: 14)),
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

class _DatePickerChip extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const _DatePickerChip({
    this.selectedDate,
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isDark ? colors.backgroundSecondary : colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: colors.textPrimary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: colors.textSecondary,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '직접 선택',
                style: typography.labelMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 빠른 날짜 선택 옵션
class QuickDateOption {
  final String label;
  final String? emoji;
  final DateTime Function() getDate;

  const QuickDateOption({
    required this.label,
    this.emoji,
    required this.getDate,
  });

  factory QuickDateOption.today() => QuickDateOption(
        label: '오늘',
        emoji: '📅',
        getDate: () => DateTime.now(),
      );

  factory QuickDateOption.tomorrow() => QuickDateOption(
        label: '내일',
        emoji: '🌅',
        getDate: () => DateTime.now().add(const Duration(days: 1)),
      );

  factory QuickDateOption.thisWeekend() {
    return QuickDateOption(
      label: '이번 주말',
      emoji: '🎉',
      getDate: () {
        final now = DateTime.now();
        final daysUntilSaturday = (DateTime.saturday - now.weekday) % 7;
        return now.add(Duration(days: daysUntilSaturday == 0 ? 7 : daysUntilSaturday));
      },
    );
  }

  factory QuickDateOption.nextWeek() => QuickDateOption(
        label: '다음 주',
        emoji: '📆',
        getDate: () => DateTime.now().add(const Duration(days: 7)),
      );

  factory QuickDateOption.custom(String label, DateTime date, {String? emoji}) =>
      QuickDateOption(
        label: label,
        emoji: emoji,
        getDate: () => date,
      );
}
