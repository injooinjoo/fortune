import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/models/holiday_models.dart';

/// 캘린더 뷰 위젯
class CalendarViewWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDate;
  final CalendarFormat calendarFormat;
  final Map<DateTime, CalendarEventInfo> events;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(CalendarFormat) onFormatChanged;
  final void Function(DateTime) onPageChanged;

  const CalendarViewWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDate,
    required this.calendarFormat,
    required this.events,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: TableCalendar<CalendarEventInfo>(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: focusedDay,
        calendarFormat: calendarFormat,
        availableCalendarFormats: const {
          CalendarFormat.month: '월',
          CalendarFormat.week: '주',
        },
        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
        eventLoader: (day) {
          final event = events[DateTime(day.year, day.month, day.day)];
          return event != null ? [event] : [];
        },
        onDaySelected: onDaySelected,
        onFormatChanged: onFormatChanged,
        onPageChanged: onPageChanged,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: const TextStyle(color: TossDesignSystem.errorRed, fontFamily: 'ZenSerif'),
          holidayTextStyle: const TextStyle(color: TossDesignSystem.errorRed, fontFamily: 'ZenSerif'),
          selectedDecoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: _buildCalendarCell,
          selectedBuilder: _buildCalendarCell,
          todayBuilder: _buildCalendarCell,
          outsideBuilder: _buildCalendarCell,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(Icons.chevron_left, color: AppTheme.primaryColor),
          rightChevronIcon: Icon(Icons.chevron_right, color: AppTheme.primaryColor),
          titleTextStyle: (theme.textTheme.titleLarge ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.bold,
          ),
          titleTextFormatter: (date, locale) => DateFormat('yyyy년 M월', 'ko_KR').format(date),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          weekendStyle: TextStyle(color: TossDesignSystem.errorRed.withValues(alpha: 0.7)),
        ),
        daysOfWeekHeight: 40,
        locale: 'ko_KR',
      ),
    );
  }

  Widget _buildCalendarCell(BuildContext context, DateTime day, DateTime focusedDay) {
    final theme = Theme.of(context);
    final isSelected = isSameDay(day, selectedDate);
    final isToday = isSameDay(day, DateTime.now());
    final isPastDate = day.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    final eventInfo = events[DateTime(day.year, day.month, day.day)];
    final isHoliday = eventInfo?.isHoliday ?? false;
    final isSpecial = eventInfo?.isSpecial ?? false;
    final isAuspicious = eventInfo?.isAuspicious ?? false;
    final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    Color textColor = theme.colorScheme.onSurface;
    Color? backgroundColor;
    Color? borderColor;

    if (isPastDate) {
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.3);
    } else if (isSelected) {
      backgroundColor = AppTheme.primaryColor;
      textColor = TossDesignSystem.white;
    } else if (isToday) {
      borderColor = AppTheme.primaryColor;
      textColor = AppTheme.primaryColor;
    } else if (isHoliday || (isWeekend && !isPastDate)) {
      textColor = TossDesignSystem.errorRed;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: borderColor != null ? Border.all(color: borderColor, width: 2) : null,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          // 이벤트 표시 점들
          if (isHoliday || isSpecial || isAuspicious) ...[
            Positioned(
              right: 2,
              top: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isHoliday)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: TossDesignSystem.errorRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (isSpecial)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(left: 2),
                      decoration: const BoxDecoration(
                        color: TossDesignSystem.warningOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (isAuspicious)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(left: 2),
                      decoration: const BoxDecoration(
                        color: TossDesignSystem.warningOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ],
          // 디바이스 캘린더 이벤트 표시 (파란색 바 + 개수)
          if (eventInfo?.hasDeviceEvents ?? false) ...[
            Positioned(
              bottom: 2,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.tossBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${eventInfo!.deviceEventCount}',
                    style: TextStyle(
                      fontSize: 8,
                      color: TossDesignSystem.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
