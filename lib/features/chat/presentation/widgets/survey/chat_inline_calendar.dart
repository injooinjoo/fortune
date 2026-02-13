import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/services/unified_calendar_service.dart';

/// 채팅 인라인 캘린더 위젯 (기간별 운세용)
///
/// 채팅 내에 직접 표시되는 캘린더
/// 날짜 선택 → 일정 표시 → 일정 선택 → 확인 플로우 지원
/// 다중 날짜 선택 모드 지원 (기간 또는 개별 날짜 복수 선택)
class ChatInlineCalendar extends StatefulWidget {
  final void Function(DateTime date) onDateSelected;
  final void Function(DateTime date, List<CalendarEventSummary> events)?
      onDateConfirmed;
  /// 다중 날짜 선택 시 콜백
  final void Function(List<DateTime> dates, Map<DateTime, List<CalendarEventSummary>> eventsMap)?
      onMultipleDatesConfirmed;
  final String? hintText;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool showQuickOptions;
  final bool showEventsAfterSelection;
  final bool isCalendarSynced;
  final Future<List<CalendarEventSummary>> Function(DateTime date)?
      onLoadEvents;
  /// 다중 날짜 선택 모드 활성화
  final bool allowMultipleDates;
  /// 최대 선택 가능 날짜 수
  final int maxSelectableDates;

  const ChatInlineCalendar({
    super.key,
    required this.onDateSelected,
    this.onDateConfirmed,
    this.onMultipleDatesConfirmed,
    this.hintText,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.showQuickOptions = true,
    this.showEventsAfterSelection = false,
    this.isCalendarSynced = false,
    this.onLoadEvents,
    this.allowMultipleDates = false,
    this.maxSelectableDates = 7,
  });

  @override
  State<ChatInlineCalendar> createState() => _ChatInlineCalendarState();
}

class _ChatInlineCalendarState extends State<ChatInlineCalendar> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  /// 다중 날짜 선택을 위한 Set
  final Set<DateTime> _selectedDates = {};
  /// 날짜별 이벤트 맵
  final Map<DateTime, List<CalendarEventSummary>> _eventsPerDate = {};
  List<CalendarEventSummary> _deviceEvents = [];
  final List<CalendarEventSummary> _selectedEvents = [];
  bool _isLoadingEvents = false;
  bool _showEvents = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentMonth = widget.initialDate ?? DateTime.now();
    if (widget.initialDate != null && widget.allowMultipleDates) {
      _selectedDates.add(_normalizeDate(widget.initialDate!));
    }
  }

  /// 날짜를 시/분/초 없이 정규화
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
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

  Future<void> _selectDate(DateTime date) async {
    DSHaptics.selection();
    final normalizedDate = _normalizeDate(date);

    // 다중 날짜 선택 모드
    if (widget.allowMultipleDates) {
      setState(() {
        if (_selectedDates.contains(normalizedDate)) {
          // 이미 선택된 날짜 클릭 시 해제
          _selectedDates.remove(normalizedDate);
          _eventsPerDate.remove(normalizedDate);
        } else if (_selectedDates.length < widget.maxSelectableDates) {
          // 최대 선택 수 미만일 때만 추가
          _selectedDates.add(normalizedDate);
        } else {
          // 최대 선택 수 초과 시 햅틱 피드백
          DSHaptics.error();
          return;
        }
        _selectedDate = _selectedDates.isNotEmpty ? _selectedDates.last : null;
        _showEvents = widget.showEventsAfterSelection && _selectedDates.isNotEmpty;
      });

      // 새로 추가된 날짜에 대해 이벤트 로드
      if (_selectedDates.contains(normalizedDate) &&
          widget.showEventsAfterSelection &&
          widget.isCalendarSynced &&
          widget.onLoadEvents != null) {
        await _loadEventsForMultipleDates();
      }
    } else {
      // 단일 날짜 선택 모드 (기존 동작)
      setState(() {
        _selectedDate = date;
        _showEvents = widget.showEventsAfterSelection;
      });

      if (widget.showEventsAfterSelection &&
          widget.isCalendarSynced &&
          widget.onLoadEvents != null) {
        await _loadEventsForDate(date);
      } else if (!widget.showEventsAfterSelection) {
        // 기존 동작: 바로 콜백 호출
        widget.onDateSelected(date);
      }
    }
  }

  /// 다중 날짜에 대해 이벤트 로드
  Future<void> _loadEventsForMultipleDates() async {
    if (widget.onLoadEvents == null) return;

    setState(() => _isLoadingEvents = true);

    try {
      for (final date in _selectedDates) {
        if (!_eventsPerDate.containsKey(date)) {
          final events = await widget.onLoadEvents!(date);
          _eventsPerDate[date] = events;
        }
      }

      // 현재 선택된 마지막 날짜의 이벤트 표시
      if (_selectedDate != null) {
        final normalizedSelected = _normalizeDate(_selectedDate!);
        _deviceEvents = _eventsPerDate[normalizedSelected] ?? [];
      }

      if (mounted) {
        setState(() => _isLoadingEvents = false);
      }
    } catch (e) {
      debugPrint('Error loading events for multiple dates: $e');
      if (mounted) {
        setState(() => _isLoadingEvents = false);
      }
    }
  }

  Future<void> _loadEventsForDate(DateTime date) async {
    if (widget.onLoadEvents == null) return;

    setState(() => _isLoadingEvents = true);

    try {
      final events = await widget.onLoadEvents!(date);
      if (mounted) {
        setState(() {
          _deviceEvents = events;
          _isLoadingEvents = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
      if (mounted) {
        setState(() => _isLoadingEvents = false);
      }
    }
  }

  void _toggleEvent(CalendarEventSummary event) {
    DSHaptics.light();
    setState(() {
      if (_selectedEvents.contains(event)) {
        _selectedEvents.remove(event);
      } else {
        _selectedEvents.add(event);
      }
    });
  }

  void _confirmSelection() {
    DSHaptics.success();

    // 다중 날짜 선택 모드
    if (widget.allowMultipleDates && _selectedDates.isNotEmpty) {
      if (widget.onMultipleDatesConfirmed != null) {
        // 날짜를 정렬해서 전달
        final sortedDates = _selectedDates.toList()..sort();
        widget.onMultipleDatesConfirmed!(sortedDates, _eventsPerDate);
      } else if (widget.onDateConfirmed != null && _selectedDate != null) {
        // fallback: 첫 번째 날짜만 전달
        widget.onDateConfirmed!(_selectedDates.first, _selectedEvents);
      } else {
        widget.onDateSelected(_selectedDates.first);
      }
      return;
    }

    // 단일 날짜 선택 모드
    if (_selectedDate == null) return;

    if (widget.onDateConfirmed != null) {
      widget.onDateConfirmed!(_selectedDate!, _selectedEvents);
    } else {
      widget.onDateSelected(_selectedDate!);
    }
  }

  void _selectQuickOption(_QuickOption option) async {
    DSHaptics.light();
    final date = option.getDate();
    setState(() {
      _selectedDate = date;
      _currentMonth = date;
      _showEvents = widget.showEventsAfterSelection;
    });

    if (widget.showEventsAfterSelection &&
        widget.isCalendarSynced &&
        widget.onLoadEvents != null) {
      await _loadEventsForDate(date);
    } else if (!widget.showEventsAfterSelection) {
      widget.onDateSelected(date);
    }
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.3),
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

          // 날짜 선택 후 이벤트 표시 영역
          if (_showEvents && _selectedDate != null) ...[
            const SizedBox(height: DSSpacing.md),
            _buildSelectedDateInfo(context),
            const SizedBox(height: DSSpacing.sm),
            _buildEventsList(context),
          ],

          // 확인 버튼 (단일 또는 다중 선택)
          if (_selectedDate != null || (widget.allowMultipleDates && _selectedDates.isNotEmpty)) ...[
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
      _QuickOption(
          '내일', '🌅', () => DateTime.now().add(const Duration(days: 1))),
      _QuickOption('이번주', '📆', () {
        final now = DateTime.now();
        final daysUntilSunday = DateTime.sunday - now.weekday;
        return now.add(Duration(days: daysUntilSunday));
      }),
      _QuickOption(
          '다음주', '🗓️', () => DateTime.now().add(const Duration(days: 7))),
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
    // Row로 균등 배치 (7개 고정)
    return Row(
      children: weekdays.asMap().entries.map((entry) {
        final isWeekend = entry.key == 0 || entry.key == 6;
        return Expanded(
          child: Center(
            child: Text(
              entry.value,
              style: typography.labelSmall.copyWith(
                color: isWeekend
                    ? (entry.key == 0
                        ? Colors.red.shade300
                        : Colors.blue.shade300)
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
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startingWeekday = firstDayOfMonth.weekday % 7; // 일요일 = 0

    final days = <Widget>[];

    // 이전 달의 빈 공간
    for (var i = 0; i < startingWeekday; i++) {
      days.add(const SizedBox.shrink());
    }

    // 현재 달의 날짜들
    for (var day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      days.add(_buildDayCell(context, date));
    }

    // GridView로 정확히 7열 고정
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: days,
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date) {
    final colors = context.colors;
    final typography = context.typography;

    final isToday = _isSameDay(date, DateTime.now());
    final normalizedDate = _normalizeDate(date);

    // 다중 선택 모드에서는 _selectedDates 사용, 단일 선택 모드에서는 _selectedDate 사용
    final isSelected = widget.allowMultipleDates
        ? _selectedDates.contains(normalizedDate)
        : (_selectedDate != null && _isSameDay(date, _selectedDate!));
    final isEnabled = _isEnabled(date);

    // 선택 순서 표시 (다중 선택 모드)
    int? selectionOrder;
    if (widget.allowMultipleDates && isSelected) {
      final sortedDates = _selectedDates.toList()..sort();
      selectionOrder = sortedDates.indexOf(normalizedDate) + 1;
    }

    Color textColor;
    if (!isEnabled) {
      textColor = colors.textTertiary.withValues(alpha: 0.3);
    } else if (isSelected) {
      textColor = Colors.white;
    } else if (isToday) {
      textColor = colors.textPrimary;
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
        decoration: BoxDecoration(
          color: isSelected
              ? colors.textPrimary
              : isToday
                  ? colors.textPrimary.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: isToday && !isSelected
              ? Border.all(color: colors.textPrimary, width: 1)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${date.day}',
              style: typography.labelMedium.copyWith(
                color: textColor,
                fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            // 다중 선택 시 순서 표시 배지
            if (selectionOrder != null && _selectedDates.length > 1)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.textPrimary, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      '$selectionOrder',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateInfo(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    // 다중 날짜 선택 모드
    if (widget.allowMultipleDates && _selectedDates.length > 1) {
      final sortedDates = _selectedDates.toList()..sort();
      return Container(
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: colors.textPrimary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: colors.textPrimary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.date_range,
                  color: colors.textPrimary,
                  size: 18,
                ),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '${_selectedDates.length}일 선택됨',
                  style: typography.labelMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.xs),
            Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              children: sortedDates.map((date) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.textPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DSRadius.sm),
                  ),
                  child: Text(
                    '${date.month}/${date.day}',
                    style: typography.labelSmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    // 단일 날짜 선택
    if (_selectedDate == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.textPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: colors.textSecondary,
            size: 18,
          ),
          const SizedBox(width: DSSpacing.xs),
          Text(
            DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(_selectedDate!),
            style: typography.labelMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    if (_isLoadingEvents) {
      return Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '일정 불러오는 중...',
                style: typography.labelMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 다중 날짜 선택 모드: 모든 날짜의 이벤트 통합 표시
    if (widget.allowMultipleDates && _selectedDates.length > 1) {
      final totalEvents = _eventsPerDate.values.fold<int>(0, (sum, events) => sum + events.length);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note, color: colors.textSecondary, size: 18),
              const SizedBox(width: DSSpacing.xs),
              Text(
                totalEvents == 0
                    ? '선택한 날짜들의 일정'
                    : '선택한 날짜들의 일정 ($totalEvents개)',
                style: typography.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          if (totalEvents == 0)
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_busy_outlined,
                    color: colors.textSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Text(
                    '선택한 날짜들에 일정이 없습니다',
                    style: typography.labelMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            // 날짜별로 이벤트 그룹화해서 표시
            ..._eventsPerDate.entries.where((e) => e.value.isNotEmpty).map((entry) {
              final date = entry.key;
              final events = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
                    child: Text(
                      '${date.month}/${date.day} (${_getWeekdayName(date)})',
                      style: typography.labelSmall.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...events.map((event) => _buildEventItem(context, event)),
                ],
              );
            }),
          if (totalEvents > 0) ...[
            const SizedBox(height: DSSpacing.xs),
            Text(
              '선택한 일정이 운세에 반영됩니다',
              style: typography.labelSmall.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],
        ],
      );
    }

    // 단일 날짜 선택 모드
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event_note, color: colors.textSecondary, size: 18),
            const SizedBox(width: DSSpacing.xs),
            Text(
              _deviceEvents.isEmpty
                  ? '내 캘린더 일정'
                  : '내 캘린더 일정 (${_deviceEvents.length})',
              style: typography.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.xs),
        if (_deviceEvents.isEmpty)
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(DSRadius.md),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_busy_outlined,
                  color: colors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: DSSpacing.sm),
                Text(
                  '선택한 날짜에 일정이 없습니다',
                  style: typography.labelMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ..._deviceEvents.map((event) => _buildEventItem(context, event)),
        if (_deviceEvents.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.xs),
          Text(
            '선택한 일정이 운세에 반영됩니다',
            style: typography.labelSmall.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  String _getWeekdayName(DateTime date) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return weekdays[date.weekday % 7];
  }

  Widget _buildEventItem(BuildContext context, CalendarEventSummary event) {
    final colors = context.colors;
    final typography = context.typography;
    final isSelected = _selectedEvents.contains(event);

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
      child: InkWell(
        onTap: () => _toggleEvent(event),
        borderRadius: BorderRadius.circular(DSRadius.md),
        child: Container(
          padding: const EdgeInsets.all(DSSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.textPrimary.withValues(alpha: 0.1)
                : colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.md),
            border: Border.all(
              color: isSelected ? colors.textPrimary : colors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? colors.textPrimary : colors.textTertiary,
                size: 20,
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: typography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (event.startTime != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.isAllDay
                                ? '종일'
                                : DateFormat('HH:mm', 'ko_KR')
                                    .format(event.startTime!),
                            style: typography.labelSmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (event.location != null && event.location!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: typography.labelSmall.copyWith(
                                color: colors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    String buttonText;

    // 다중 날짜 선택 모드
    if (widget.allowMultipleDates && _selectedDates.isNotEmpty) {
      final count = _selectedDates.length;
      final totalEvents = _eventsPerDate.values.fold<int>(0, (sum, events) => sum + events.length);

      if (count == 1) {
        final dateStr = _formatDate(_selectedDates.first);
        buttonText = widget.showEventsAfterSelection
            ? (totalEvents == 0
                ? '$dateStr 운세 보기'
                : '$dateStr + $totalEvents개 일정 운세 보기')
            : '$dateStr 선택';
      } else {
        final sortedDates = _selectedDates.toList()..sort();
        final firstDate = _formatDateShort(sortedDates.first);
        final lastDate = _formatDateShort(sortedDates.last);
        buttonText = widget.showEventsAfterSelection
            ? (totalEvents == 0
                ? '$firstDate ~ $lastDate ($count일) 운세 보기'
                : '$firstDate ~ $lastDate + $totalEvents개 일정 운세 보기')
            : '$count일 선택됨';
      }
    } else {
      // 단일 날짜 선택 모드
      if (_selectedDate == null) return const SizedBox.shrink();

      final dateStr = _formatDate(_selectedDate!);
      buttonText = widget.showEventsAfterSelection
          ? (_selectedEvents.isEmpty
              ? '$dateStr 운세 보기'
              : '$dateStr + ${_selectedEvents.length}개 일정 운세 보기')
          : '$dateStr 선택';
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _confirmSelection,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.ctaBackground,
          foregroundColor: colors.ctaForeground,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadius.md),
          ),
        ),
        child: Text(
          buttonText,
          style: typography.labelMedium.copyWith(
            color: colors.ctaForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 짧은 날짜 포맷 (M/d)
  String _formatDateShort(DateTime date) {
    return '${date.month}/${date.day}';
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
    final isDark = context.isDark;

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
                ? colors.textPrimary.withValues(alpha: 0.2)
                : (isDark ? colors.backgroundSecondary : colors.surface),
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: isSelected
                  ? colors.textPrimary
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
                  color: colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: DSSpacing.xs),
                Icon(
                  Icons.check,
                  size: 14,
                  color: colors.textPrimary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
