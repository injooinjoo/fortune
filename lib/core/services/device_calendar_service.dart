import 'package:device_calendar/device_calendar.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';

/// 디바이스 캘린더 연동 서비스
///
/// 기능:
/// - Google Calendar, Apple Calendar, Naver Calendar 이벤트 가져오기
/// - 사용자 권한 요청 및 관리
/// - 선택된 날짜의 캘린더 이벤트 제공
class DeviceCalendarService {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  /// 캘린더 권한 확인 및 요청
  Future<bool> requestCalendarPermission() async {
    try {
      // ignore: deprecated_member_use
      final permissionStatus = await Permission.calendar.status;

      if (permissionStatus.isGranted) {
        Logger.info('[DeviceCalendar] 캘린더 권한 이미 허용됨');
        return true;
      }

      if (permissionStatus.isDenied) {
        // ignore: deprecated_member_use
        final result = await Permission.calendar.request();
        if (result.isGranted) {
          Logger.info('[DeviceCalendar] 캘린더 권한 허용됨');
          return true;
        } else {
          Logger.warning('[DeviceCalendar] 캘린더 권한 거부됨');
          return false;
        }
      }

      if (permissionStatus.isPermanentlyDenied) {
        Logger.warning('[DeviceCalendar] 캘린더 권한 영구 거부됨 - 설정으로 이동 필요');
        await openAppSettings();
        return false;
      }

      return false;
    } catch (e) {
      Logger.error('[DeviceCalendar] 권한 요청 실패', e);
      return false;
    }
  }

  /// 사용 가능한 캘린더 목록 가져오기
  Future<List<Calendar>> getAvailableCalendars() async {
    try {
      final hasPermission = await requestCalendarPermission();
      if (!hasPermission) {
        Logger.warning('[DeviceCalendar] 권한 없음 - 캘린더 목록 가져올 수 없음');
        return [];
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();

      if (calendarsResult.isSuccess && calendarsResult.data != null) {
        final calendars = calendarsResult.data!;
        Logger.info('[DeviceCalendar] ${calendars.length}개 캘린더 발견');

        for (final calendar in calendars) {
          Logger.debug('[DeviceCalendar] - ${calendar.name} (${calendar.id})');
        }

        return calendars;
      } else {
        Logger.warning('[DeviceCalendar] 캘린더 목록 가져오기 실패');
        return [];
      }
    } catch (e) {
      Logger.error('[DeviceCalendar] 캘린더 목록 조회 실패', e);
      return [];
    }
  }

  /// 특정 날짜의 이벤트 가져오기
  Future<List<Event>> getEventsForDate(DateTime date) async {
    try {
      final hasPermission = await requestCalendarPermission();
      if (!hasPermission) {
        Logger.warning('[DeviceCalendar] 권한 없음 - 이벤트 가져올 수 없음');
        return [];
      }

      final calendars = await getAvailableCalendars();
      if (calendars.isEmpty) {
        Logger.warning('[DeviceCalendar] 사용 가능한 캘린더 없음');
        return [];
      }

      // 해당 날짜의 시작과 끝 시간 설정
      final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final allEvents = <Event>[];

      // 모든 캘린더에서 이벤트 가져오기
      for (final calendar in calendars) {
        try {
          final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
            calendar.id,
            RetrieveEventsParams(
              startDate: startOfDay,
              endDate: endOfDay,
            ),
          );

          if (eventsResult.isSuccess && eventsResult.data != null) {
            allEvents.addAll(eventsResult.data!);
          }
        } catch (e) {
          Logger.debug('[DeviceCalendar] ${calendar.name}에서 이벤트 가져오기 실패: $e');
          continue;
        }
      }

      Logger.info('[DeviceCalendar] ${CalendarEventSummary.formatDate(date)}에 ${allEvents.length}개 이벤트 발견');

      return allEvents;
    } catch (e) {
      Logger.error('[DeviceCalendar] 이벤트 조회 실패', e);
      return [];
    }
  }

  /// 특정 날짜의 이벤트를 간단한 형식으로 변환
  Future<List<CalendarEventSummary>> getEventSummariesForDate(DateTime date) async {
    final events = await getEventsForDate(date);

    return events.map((event) {
      return CalendarEventSummary(
        title: event.title ?? '제목 없음',
        description: event.description,
        startTime: event.start,
        endTime: event.end,
        isAllDay: event.allDay ?? false,
        location: event.location,
      );
    }).toList();
  }

  /// 여러 날짜의 이벤트를 한번에 가져오기
  Future<Map<DateTime, List<CalendarEventSummary>>> getEventsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final hasPermission = await requestCalendarPermission();
      if (!hasPermission) {
        Logger.warning('[DeviceCalendar] 권한 없음 - 이벤트 가져올 수 없음');
        return {};
      }

      final calendars = await getAvailableCalendars();
      if (calendars.isEmpty) {
        Logger.warning('[DeviceCalendar] 사용 가능한 캘린더 없음');
        return {};
      }

      final eventsByDate = <DateTime, List<CalendarEventSummary>>{};

      // 모든 캘린더에서 이벤트 가져오기
      for (final calendar in calendars) {
        try {
          final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
            calendar.id,
            RetrieveEventsParams(
              startDate: startDate,
              endDate: endDate,
            ),
          );

          if (eventsResult.isSuccess && eventsResult.data != null) {
            for (final event in eventsResult.data!) {
              if (event.start != null) {
                final eventDate = DateTime(
                  event.start!.year,
                  event.start!.month,
                  event.start!.day,
                );

                if (!eventsByDate.containsKey(eventDate)) {
                  eventsByDate[eventDate] = [];
                }

                eventsByDate[eventDate]!.add(
                  CalendarEventSummary(
                    title: event.title ?? '제목 없음',
                    description: event.description,
                    startTime: event.start,
                    endTime: event.end,
                    isAllDay: event.allDay ?? false,
                    location: event.location,
                  ),
                );
              }
            }
          }
        } catch (e) {
          Logger.debug('[DeviceCalendar] ${calendar.name}에서 이벤트 가져오기 실패: $e');
          continue;
        }
      }

      Logger.info('[DeviceCalendar] ${eventsByDate.length}일에 이벤트 발견');

      return eventsByDate;
    } catch (e) {
      Logger.error('[DeviceCalendar] 이벤트 범위 조회 실패', e);
      return {};
    }
  }
}

/// 캘린더 이벤트 요약 정보
class CalendarEventSummary {
  final String title;
  final String? description;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isAllDay;
  final String? location;

  CalendarEventSummary({
    required this.title,
    this.description,
    this.startTime,
    this.endTime,
    required this.isAllDay,
    this.location,
  });

  @override
  String toString() {
    return 'CalendarEvent(title: $title, startTime: $startTime, isAllDay: $isAllDay)';
  }

  // DateFormat helper
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
