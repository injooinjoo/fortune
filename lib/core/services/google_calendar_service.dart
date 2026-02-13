import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import '../utils/logger.dart';
import 'device_calendar_service.dart';

/// Google Calendar API 직접 연동 서비스
///
/// iOS에서 Google Calendar 앱을 사용하는 사용자를 위해
/// Google Sign-In을 통해 직접 Calendar API에 접근합니다.
///
/// 사용 시나리오:
/// 1. iOS EventKit에 Google 계정이 없는 경우
/// 2. Google Calendar 앱만 사용하는 사용자
/// 3. 더 정확한 Google Calendar 데이터가 필요한 경우
class GoogleCalendarService {
  static final GoogleCalendarService _instance =
      GoogleCalendarService._internal();
  factory GoogleCalendarService() => _instance;
  GoogleCalendarService._internal();

  /// Google Sign-In 인스턴스 (Calendar scope 포함)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      gcal.CalendarApi.calendarReadonlyScope, // 읽기 전용
    ],
  );

  GoogleSignInAccount? _currentUser;
  gcal.CalendarApi? _calendarApi;

  /// 현재 연결된 Google 계정
  GoogleSignInAccount? get currentUser => _currentUser;

  /// Google Calendar 연동 여부
  bool get isConnected => _currentUser != null && _calendarApi != null;

  /// Google Calendar 연동 (로그인)
  ///
  /// 사용자에게 Google 로그인 화면을 보여주고 Calendar 권한을 요청합니다.
  /// 이미 로그인되어 있으면 기존 세션을 사용합니다.
  Future<bool> connect() async {
    try {
      Logger.info('[GoogleCalendar] 연동 시작...');

      // 1. 기존 로그인 확인
      _currentUser = await _googleSignIn.signInSilently();

      // 2. 새로 로그인 필요
      if (_currentUser == null) {
        Logger.info('[GoogleCalendar] 새 로그인 필요 - 로그인 화면 표시');
        _currentUser = await _googleSignIn.signIn();
      }

      if (_currentUser == null) {
        Logger.warning('[GoogleCalendar] 로그인 취소됨');
        return false;
      }

      // 3. API 클라이언트 생성
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        Logger.error('[GoogleCalendar] HTTP 클라이언트 생성 실패');
        return false;
      }

      _calendarApi = gcal.CalendarApi(httpClient);

      Logger.info('[GoogleCalendar] ✅ 연동 성공: ${_currentUser!.email}');
      return true;
    } catch (e) {
      Logger.error('[GoogleCalendar] 연동 실패', e);
      return false;
    }
  }

  /// Google Calendar 연동 해제
  Future<void> disconnect() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _calendarApi = null;
      Logger.info('[GoogleCalendar] 연동 해제됨');
    } catch (e) {
      Logger.error('[GoogleCalendar] 연동 해제 실패', e);
    }
  }

  /// 캘린더 목록 가져오기
  Future<List<GoogleCalendarInfo>> getCalendarList() async {
    if (_calendarApi == null) {
      Logger.warning('[GoogleCalendar] API 미연결 - connect() 먼저 호출 필요');
      return [];
    }

    try {
      final calendarList = await _calendarApi!.calendarList.list();
      final calendars = calendarList.items ?? [];

      Logger.info('[GoogleCalendar] ${calendars.length}개 캘린더 발견');

      return calendars
          .map((cal) => GoogleCalendarInfo(
                id: cal.id ?? '',
                name: cal.summary ?? '이름 없음',
                color: cal.backgroundColor,
                isPrimary: cal.primary ?? false,
                accessRole: cal.accessRole ?? 'reader',
              ))
          .toList();
    } catch (e) {
      Logger.error('[GoogleCalendar] 캘린더 목록 조회 실패', e);
      return [];
    }
  }

  /// 특정 날짜의 이벤트 가져오기
  Future<List<CalendarEventSummary>> getEventsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return getEventsForDateRange(startDate: startOfDay, endDate: endOfDay);
  }

  /// 날짜 범위의 이벤트 가져오기
  Future<List<CalendarEventSummary>> getEventsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? calendarId, // null이면 모든 캘린더
  }) async {
    if (_calendarApi == null) {
      Logger.warning('[GoogleCalendar] API 미연결');
      return [];
    }

    try {
      final allEvents = <CalendarEventSummary>[];

      // 대상 캘린더 목록
      List<String> calendarIds;
      if (calendarId != null) {
        calendarIds = [calendarId];
      } else {
        final calendars = await getCalendarList();
        calendarIds = calendars.map((c) => c.id).toList();
      }

      // 각 캘린더에서 이벤트 가져오기
      for (final calId in calendarIds) {
        try {
          final events = await _calendarApi!.events.list(
            calId,
            timeMin: startDate.toUtc(),
            timeMax: endDate.toUtc(),
            singleEvents: true,
            orderBy: 'startTime',
          );

          for (final event in events.items ?? []) {
            allEvents.add(_convertToEventSummary(event));
          }
        } catch (e) {
          Logger.debug('[GoogleCalendar] 캘린더 $calId 조회 실패: $e');
          continue;
        }
      }

      Logger.info(
          '[GoogleCalendar] ${allEvents.length}개 이벤트 발견 (${startDate.toString().substring(0, 10)} ~ ${endDate.toString().substring(0, 10)})');

      return allEvents;
    } catch (e) {
      Logger.error('[GoogleCalendar] 이벤트 조회 실패', e);
      return [];
    }
  }

  /// 날짜별로 그룹화된 이벤트 가져오기 (device_calendar와 동일한 형식)
  Future<Map<DateTime, List<CalendarEventSummary>>> getEventsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final events = await getEventsForDateRange(
      startDate: startDate,
      endDate: endDate,
    );

    final eventsByDate = <DateTime, List<CalendarEventSummary>>{};

    for (final event in events) {
      if (event.startTime != null) {
        final eventDate = DateTime(
          event.startTime!.year,
          event.startTime!.month,
          event.startTime!.day,
        );

        if (!eventsByDate.containsKey(eventDate)) {
          eventsByDate[eventDate] = [];
        }
        eventsByDate[eventDate]!.add(event);
      }
    }

    return eventsByDate;
  }

  /// Google Calendar Event를 CalendarEventSummary로 변환
  CalendarEventSummary _convertToEventSummary(gcal.Event event) {
    DateTime? startTime;
    DateTime? endTime;
    bool isAllDay = false;

    // 종일 이벤트 처리
    if (event.start?.date != null) {
      isAllDay = true;
      startTime = event.start!.date;
      endTime = event.end?.date;
    } else {
      startTime = event.start?.dateTime?.toLocal();
      endTime = event.end?.dateTime?.toLocal();
    }

    return CalendarEventSummary(
      title: event.summary ?? '제목 없음',
      description: event.description,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      location: event.location,
    );
  }
}

/// Google Calendar 정보
class GoogleCalendarInfo {
  final String id;
  final String name;
  final String? color;
  final bool isPrimary;
  final String accessRole;

  GoogleCalendarInfo({
    required this.id,
    required this.name,
    this.color,
    this.isPrimary = false,
    this.accessRole = 'reader',
  });

  @override
  String toString() => 'GoogleCalendar(name: $name, isPrimary: $isPrimary)';
}
