import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import 'device_calendar_service.dart';
import 'google_calendar_service.dart';

// Re-export CalendarEventSummary for convenience
export 'device_calendar_service.dart' show CalendarEventSummary;

/// 캘린더 소스 타입
enum CalendarSource {
  /// iOS/Android 기본 캘린더 (EventKit/ContentProvider)
  device,

  /// Google Calendar API 직접 연동
  google,
}

/// 통합 캘린더 서비스
///
/// 전문 앱들처럼 여러 캘린더 소스를 지원합니다:
/// 1. iOS EventKit / Android ContentProvider (device_calendar)
/// 2. Google Calendar API 직접 연동
///
/// 사용자가 선택한 소스에서 이벤트를 가져오고,
/// 두 소스를 동시에 사용할 수도 있습니다.
class UnifiedCalendarService {
  static final UnifiedCalendarService _instance = UnifiedCalendarService._internal();
  factory UnifiedCalendarService() => _instance;
  UnifiedCalendarService._internal();

  final DeviceCalendarService _deviceService = DeviceCalendarService();
  final GoogleCalendarService _googleService = GoogleCalendarService();

  static const String _prefKeyGoogleConnected = 'calendar_google_connected';
  static const String _prefKeyDeviceEnabled = 'calendar_device_enabled';

  /// 디바이스 캘린더 활성화 여부
  bool _deviceEnabled = true;

  /// Google Calendar 연동 여부
  bool get isGoogleConnected => _googleService.isConnected;

  /// 디바이스 캘린더 활성화 여부
  bool get isDeviceEnabled => _deviceEnabled;

  /// Google 계정 이메일
  String? get googleEmail => _googleService.currentUser?.email;

  /// 초기화 - 저장된 설정 불러오기
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _deviceEnabled = prefs.getBool(_prefKeyDeviceEnabled) ?? true;

      // Google Calendar 자동 재연결 시도
      final wasGoogleConnected = prefs.getBool(_prefKeyGoogleConnected) ?? false;
      if (wasGoogleConnected) {
        Logger.info('[UnifiedCalendar] Google Calendar 자동 재연결 시도...');
        final connected = await _googleService.connect();
        if (connected) {
          Logger.info('[UnifiedCalendar] ✅ Google Calendar 자동 재연결 성공');
        } else {
          Logger.info('[UnifiedCalendar] Google Calendar 재연결 실패 - 수동 연결 필요');
        }
      }

      Logger.info('[UnifiedCalendar] 초기화 완료 - device: $_deviceEnabled, google: $isGoogleConnected');
    } catch (e) {
      Logger.error('[UnifiedCalendar] 초기화 실패', e);
    }
  }

  /// Google Calendar 연결
  Future<bool> connectGoogleCalendar() async {
    try {
      final connected = await _googleService.connect();

      if (connected) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefKeyGoogleConnected, true);
        Logger.info('[UnifiedCalendar] ✅ Google Calendar 연결 완료');
      }

      return connected;
    } catch (e) {
      Logger.error('[UnifiedCalendar] Google Calendar 연결 실패', e);
      return false;
    }
  }

  /// Google Calendar 연결 해제
  Future<void> disconnectGoogleCalendar() async {
    try {
      await _googleService.disconnect();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyGoogleConnected, false);
      Logger.info('[UnifiedCalendar] Google Calendar 연결 해제됨');
    } catch (e) {
      Logger.error('[UnifiedCalendar] Google Calendar 연결 해제 실패', e);
    }
  }

  /// 디바이스 캘린더 활성화/비활성화
  Future<void> setDeviceEnabled(bool enabled) async {
    _deviceEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyDeviceEnabled, enabled);
    Logger.info('[UnifiedCalendar] 디바이스 캘린더: ${enabled ? "활성화" : "비활성화"}');
  }

  /// 디바이스 캘린더 권한 요청
  Future<bool> requestDevicePermission() async {
    return await _deviceService.requestCalendarPermission();
  }

  /// 특정 날짜의 이벤트 가져오기 (모든 소스 통합)
  Future<List<CalendarEventSummary>> getEventsForDate(DateTime date) async {
    final allEvents = <CalendarEventSummary>[];
    final seenTitles = <String>{}; // 중복 제거용

    // 1. 디바이스 캘린더
    if (_deviceEnabled) {
      try {
        final hasPermission = await _deviceService.requestCalendarPermission();
        if (hasPermission) {
          final deviceEvents = await _deviceService.getEventSummariesForDate(date);
          for (final event in deviceEvents) {
            final key = '${event.title}_${event.startTime}';
            if (!seenTitles.contains(key)) {
              seenTitles.add(key);
              allEvents.add(event);
            }
          }
          Logger.debug('[UnifiedCalendar] 디바이스: ${deviceEvents.length}개 이벤트');
        }
      } catch (e) {
        Logger.debug('[UnifiedCalendar] 디바이스 캘린더 조회 실패: $e');
      }
    }

    // 2. Google Calendar
    if (isGoogleConnected) {
      try {
        final googleEvents = await _googleService.getEventsForDate(date);
        for (final event in googleEvents) {
          final key = '${event.title}_${event.startTime}';
          if (!seenTitles.contains(key)) {
            seenTitles.add(key);
            allEvents.add(event);
          }
        }
        Logger.debug('[UnifiedCalendar] Google: ${googleEvents.length}개 이벤트');
      } catch (e) {
        Logger.debug('[UnifiedCalendar] Google Calendar 조회 실패: $e');
      }
    }

    // 시간순 정렬
    allEvents.sort((a, b) {
      if (a.startTime == null && b.startTime == null) return 0;
      if (a.startTime == null) return 1;
      if (b.startTime == null) return -1;
      return a.startTime!.compareTo(b.startTime!);
    });

    Logger.info('[UnifiedCalendar] ${date.toString().substring(0, 10)}: 총 ${allEvents.length}개 이벤트');
    return allEvents;
  }

  /// 날짜 범위의 이벤트 가져오기 (날짜별 그룹화)
  Future<Map<DateTime, List<CalendarEventSummary>>> getEventsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final eventsByDate = <DateTime, List<CalendarEventSummary>>{};

    // 1. 디바이스 캘린더
    if (_deviceEnabled) {
      try {
        final hasPermission = await _deviceService.requestCalendarPermission();
        if (hasPermission) {
          final deviceEvents = await _deviceService.getEventsForDateRange(
            startDate: startDate,
            endDate: endDate,
          );
          _mergeEventsIntoMap(eventsByDate, deviceEvents);
          Logger.debug('[UnifiedCalendar] 디바이스: ${deviceEvents.length}일에 이벤트');
        }
      } catch (e) {
        Logger.debug('[UnifiedCalendar] 디바이스 캘린더 범위 조회 실패: $e');
      }
    }

    // 2. Google Calendar
    if (isGoogleConnected) {
      try {
        final googleEvents = await _googleService.getEventsByDateRange(
          startDate: startDate,
          endDate: endDate,
        );
        _mergeEventsIntoMap(eventsByDate, googleEvents);
        Logger.debug('[UnifiedCalendar] Google: ${googleEvents.length}일에 이벤트');
      } catch (e) {
        Logger.debug('[UnifiedCalendar] Google Calendar 범위 조회 실패: $e');
      }
    }

    Logger.info('[UnifiedCalendar] 범위 조회: ${eventsByDate.length}일에 이벤트 (${startDate.toString().substring(0, 10)} ~ ${endDate.toString().substring(0, 10)})');
    return eventsByDate;
  }

  /// 이벤트 맵 병합 (중복 제거)
  void _mergeEventsIntoMap(
    Map<DateTime, List<CalendarEventSummary>> target,
    Map<DateTime, List<CalendarEventSummary>> source,
  ) {
    for (final entry in source.entries) {
      final date = entry.key;
      final events = entry.value;

      if (!target.containsKey(date)) {
        target[date] = [];
      }

      // 중복 체크 후 추가
      for (final event in events) {
        final isDuplicate = target[date]!.any((e) =>
            e.title == event.title &&
            e.startTime?.toString() == event.startTime?.toString());

        if (!isDuplicate) {
          target[date]!.add(event);
        }
      }
    }
  }

  /// 연결된 캘린더 소스 목록
  List<ConnectedCalendarSource> getConnectedSources() {
    final sources = <ConnectedCalendarSource>[];

    if (_deviceEnabled) {
      sources.add(ConnectedCalendarSource(
        source: CalendarSource.device,
        name: 'iOS/Android 캘린더',
        description: '기기에 연동된 모든 캘린더',
        isConnected: true,
      ));
    }

    sources.add(ConnectedCalendarSource(
      source: CalendarSource.google,
      name: 'Google Calendar',
      description: isGoogleConnected
          ? googleEmail ?? 'Google 계정'
          : 'Google 계정으로 직접 연동',
      isConnected: isGoogleConnected,
    ));

    return sources;
  }

  /// 어떤 소스도 연결되지 않았는지 확인
  bool get hasNoConnectedSources => !_deviceEnabled && !isGoogleConnected;

  /// 최소 하나의 소스가 연결되었는지 확인
  bool get hasAnyConnectedSource => _deviceEnabled || isGoogleConnected;
}

/// 연결된 캘린더 소스 정보
class ConnectedCalendarSource {
  final CalendarSource source;
  final String name;
  final String description;
  final bool isConnected;

  ConnectedCalendarSource({
    required this.source,
    required this.name,
    required this.description,
    required this.isConnected,
  });
}
