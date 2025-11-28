import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/models/holiday_models.dart';
import '../../../../../../core/services/unified_calendar_service.dart';
import 'device_event_item.dart';

/// 선택된 날짜 정보 위젯
class DateInfoWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Map<DateTime, CalendarEventInfo> events;
  final bool isCalendarSynced;
  final List<CalendarEventSummary> deviceEvents;
  final List<CalendarEventSummary> selectedEvents;
  final ValueChanged<CalendarEventSummary> onEventToggle;

  const DateInfoWidget({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.isCalendarSynced,
    required this.deviceEvents,
    required this.selectedEvents,
    required this.onEventToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final eventInfo = events[DateTime(selectedDate.year, selectedDate.month, selectedDate.day)];

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(selectedDate),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),

          // 이벤트 정보 표시
          if (eventInfo != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (eventInfo.holidayName != null)
                  EventTag(
                    icon: Icons.celebration,
                    label: eventInfo.holidayName!,
                    color: TossDesignSystem.errorRed,
                  ),
                if (eventInfo.specialName != null)
                  EventTag(
                    icon: Icons.star,
                    label: eventInfo.specialName!,
                    color: TossDesignSystem.warningOrange,
                  ),
                if (eventInfo.auspiciousName != null)
                  EventTag(
                    icon: Icons.home,
                    label: eventInfo.auspiciousName!,
                    color: TossDesignSystem.warningOrange,
                    score: eventInfo.auspiciousScore,
                  ),
              ],
            ),
          ],

          // 디바이스 캘린더 이벤트 리스트 (연동된 경우에만 표시)
          if (isCalendarSynced) ...[
            const SizedBox(height: 16),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.event_note, color: TossDesignSystem.tossBlue, size: 18),
                const SizedBox(width: 6),
                Text(
                  deviceEvents.isEmpty
                      ? '내 캘린더 일정'
                      : '내 캘린더 일정 (${deviceEvents.length})',
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: TossDesignSystem.tossBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (deviceEvents.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      color: isDark
                          ? TossDesignSystem.textSecondaryDark
                          : TossDesignSystem.textSecondaryLight,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '선택한 날짜에 일정이 없습니다',
                      style: context.bodyMedium.copyWith(
                        color: isDark
                            ? TossDesignSystem.textSecondaryDark
                            : TossDesignSystem.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...deviceEvents.map((event) => DeviceEventItem(
                    event: event,
                    isSelected: selectedEvents.contains(event),
                    onTap: () => onEventToggle(event),
                  )),
          ],
        ],
      ),
    );
  }
}

/// 이벤트 태그 위젯
class EventTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int? score;

  const EventTag({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (score != null) ...[
            const SizedBox(width: 4),
            Text(
              '$score점',
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
