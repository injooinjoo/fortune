import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';

/// 채팅 인라인 캘린더 위젯 (기간별 운세용)
///
/// 채팅 내에 직접 표시되는 캘린더
/// BottomSheet 없이 바로 날짜 선택 가능
class ChatInlineCalendar extends StatefulWidget {
  final void Function(DateTime date) onDateSelected;
  final String? hintText;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool showQuickOptions;

  const ChatInlineCalendar({
    super.key,
    required this.onDateSelected,
    this.hintText,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.showQuickOptions = true,
  });

  @override
  State<ChatInlineCalendar> createState() => _ChatInlineCalendarState();
}

class _ChatInlineCalendarState extends State<ChatInlineCalendar> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentMonth = widget.initialDate ?? DateTime.now();
  }

  void _previousMonth() {
    DSHaptics.light();
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    DSHaptics.light();
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _selectDate(DateTime date) {
    DSHaptics.selection();
    setState(() => _selectedDate = date);
    widget.onDateSelected(date);
  }

  void _selectQuickOption(_QuickOption option) {
    DSHaptics.light();
    final date = option.getDate();
    setState(() {
      _selectedDate = date;
      _currentMonth = date;
    });
    widget.onDateSelected(date);
  }

  bool _isEnabled(DateTime date) {
    final first = widget.firstDate ?? DateTime(2020);
    final last = widget.lastDate ?? DateTime(2030);
    return !date.isBefore(first) && !date.isAfter(last);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colors.backgroundSecondary : colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.textPrimary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.hintText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.sm),
              child: Text(
                widget.hintText!,
                style: typography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),

          // 빠른 선택 옵션
          if (widget.showQuickOptions) ...[
            _buildQuickOptions(context),
            const SizedBox(height: DSSpacing.sm),
          ],

          // 캘린더 헤더 (월 네비게이션)
          _buildMonthHeader(context),
          const SizedBox(height: DSSpacing.xs),

          // 요일 헤더
          _buildWeekdayHeader(context),
          const SizedBox(height: DSSpacing.xs),

          // 캘린더 그리드
          _buildCalendarGrid(context),

          // 선택 확인 버튼
          if (_selectedDate != null) ...[
            const SizedBox(height: DSSpacing.sm),
            _buildConfirmButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickOptions(BuildContext context) {
    final options = [
      _QuickOption('오늘', '📅', () => DateTime.now()),
      _QuickOption('내일', '🌅', () => DateTime.now().add(const Duration(days: 1))),
      _QuickOption('이번주', '📆', () {
        final now = DateTime.now();
        final daysUntilSunday = DateTime.sunday - now.weekday;
        return now.add(Duration(days: daysUntilSunday));
      }),
      _QuickOption('다음주', '🗓️', () => DateTime.now().add(const Duration(days: 7))),
    ];

    return Wrap(
      spacing: DSSpacing.xs,
      runSpacing: DSSpacing.xs,
      children: options.map((option) {
        final isSelected = _selectedDate != null &&
            _isSameDay(_selectedDate!, option.getDate());
        return _QuickOptionChip(
          option: option,
          isSelected: isSelected,
          onTap: () => _selectQuickOption(option),
        );
      }).toList(),
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: Icon(
            Icons.chevron_left,
            color: colors.textSecondary,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        Text(
          '${_currentMonth.year}년 ${_currentMonth.month}월',
          style: typography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: _nextMonth,
          icon: Icon(
            Icons.chevron_right,
            color: colors.textSecondary,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.asMap().entries.map((entry) {
        final isWeekend = entry.key == 0 || entry.key == 6;
        return SizedBox(
          width: 36,
          child: Center(
            child: Text(
              entry.value,
              style: typography.labelSmall.copyWith(
                color: isWeekend
                    ? (entry.key == 0 ? Colors.red.shade300 : Colors.blue.shade300)
                    : colors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startingWeekday = firstDayOfMonth.weekday % 7; // 일요일 = 0

    final days = <Widget>[];

    // 이전 달의 빈 공간
    for (var i = 0; i < startingWeekday; i++) {
      days.add(const SizedBox(width: 36, height: 36));
    }

    // 현재 달의 날짜들
    for (var day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      days.add(_buildDayCell(context, date));
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: days,
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date) {
    final colors = context.colors;
    final typography = context.typography;

    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = _selectedDate != null && _isSameDay(date, _selectedDate!);
    final isEnabled = _isEnabled(date);

    Color textColor;
    if (!isEnabled) {
      textColor = colors.textTertiary.withValues(alpha: 0.3);
    } else if (isSelected) {
      textColor = Colors.white;
    } else if (isToday) {
      textColor = colors.accentSecondary;
    } else if (date.weekday == DateTime.sunday) {
      textColor = Colors.red.shade300;
    } else if (date.weekday == DateTime.saturday) {
      textColor = Colors.blue.shade300;
    } else {
      textColor = colors.textPrimary;
    }

    return GestureDetector(
      onTap: isEnabled ? () => _selectDate(date) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accentSecondary
              : isToday
                  ? colors.accentSecondary.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: isToday && !isSelected
              ? Border.all(color: colors.accentSecondary, width: 1)
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: typography.labelMedium.copyWith(
              color: textColor,
              fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final dateStr = _formatDate(_selectedDate!);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          DSHaptics.success();
          widget.onDateSelected(_selectedDate!);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accentSecondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadius.md),
          ),
        ),
        child: Text(
          '$dateStr 선택',
          style: typography.labelMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return '${date.month}월 ${date.day}일 (${weekdays[date.weekday % 7]})';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _QuickOption {
  final String label;
  final String emoji;
  final DateTime Function() getDate;

  const _QuickOption(this.label, this.emoji, this.getDate);
}

class _QuickOptionChip extends StatelessWidget {
  final _QuickOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickOptionChip({
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
              Text(option.emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: DSSpacing.xs),
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
