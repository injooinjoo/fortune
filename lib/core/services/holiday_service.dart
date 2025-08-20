import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/holiday_models.dart';
import 'package:flutter/foundation.dart';

class HolidayService {
  static final HolidayService _instance = HolidayService._internal();
  factory HolidayService() => _instance;
  HolidayService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  
  // 캐시
  Map<DateTime, CalendarEventInfo>? _cachedEvents;
  DateTime? _cacheDate;
  
  /// 특정 월의 모든 이벤트 (공휴일, 기념일, 손없는날) 가져오기
  Future<Map<DateTime, CalendarEventInfo>> getEventsForMonth(DateTime month) async {
    try {
      final now = DateTime.now();
      final cacheKey = DateTime(month.year, month.month);
      
      // 캐시 체크 (같은 달이고 1시간 이내)
      if (_cachedEvents != null && 
          _cacheDate != null && 
          _cacheDate!.year == month.year && 
          _cacheDate!.month == month.month &&
          now.difference(_cacheDate!).inHours < 1) {
        return _cachedEvents!;
      }

      final events = <DateTime, CalendarEventInfo>{};
      
      try {
        final startOfMonth = DateTime(month.year, month.month, 1);
        final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
        
        // 공휴일/기념일 데이터 가져오기
        final holidaysResponse = await _supabase
            .from('korean_holidays')
            .select('*')
            .gte('date', startOfMonth.toIso8601String().split('T')[0])
            .lte('date', endOfMonth.toIso8601String().split('T')[0]);

        // 손없는날 데이터 가져오기
        final auspiciousResponse = await _supabase
            .from('auspicious_days')
            .select('*')
            .gte('date', startOfMonth.toIso8601String().split('T')[0])
            .lte('date', endOfMonth.toIso8601String().split('T')[0]);
        
        // 공휴일/기념일 처리
        if (holidaysResponse != null) {
          for (final holiday in holidaysResponse) {
            final date = DateTime.parse(holiday['date']);
            final normalizedDate = DateTime(date.year, date.month, date.day);
            
            final existingEvent = events[normalizedDate];
            final isHoliday = holiday['type'] == 'holiday';
            final isSpecial = holiday['type'] == 'special' || holiday['type'] == 'memorial';
            
            events[normalizedDate] = CalendarEventInfo(
              date: normalizedDate,
              holidayName: isHoliday ? holiday['name'] : existingEvent?.holidayName,
              specialName: isSpecial ? holiday['name'] : existingEvent?.specialName,
              auspiciousName: existingEvent?.auspiciousName,
              isHoliday: isHoliday || (existingEvent?.isHoliday ?? false),
              isSpecial: isSpecial || (existingEvent?.isSpecial ?? false),
              isAuspicious: existingEvent?.isAuspicious ?? false,
              auspiciousScore: existingEvent?.auspiciousScore,
              description: holiday['description'] ?? existingEvent?.description,
            );
          }
        }
        
        // 손없는날 처리
        if (auspiciousResponse != null) {
          for (final auspicious in auspiciousResponse) {
            final date = DateTime.parse(auspicious['date']);
            final normalizedDate = DateTime(date.year, date.month, date.day);
            
            final existingEvent = events[normalizedDate];
            
            events[normalizedDate] = CalendarEventInfo(
              date: normalizedDate,
              holidayName: existingEvent?.holidayName,
              specialName: existingEvent?.specialName,
              auspiciousName: auspicious['description'] ?? '손없는날',
              isHoliday: existingEvent?.isHoliday ?? false,
              isSpecial: existingEvent?.isSpecial ?? false,
              isAuspicious: true,
              auspiciousScore: auspicious['score'],
              description: auspicious['description'],
            );
          }
        }
      } catch (dbError) {
        debugPrint('Database not available, using fallback data: $dbError');
        // 데이터베이스 테이블이 없는 경우 fallback 데이터 사용
        _addFallbackEvents(events, month);
      }
      
      // 캐시 저장
      _cachedEvents = events;
      _cacheDate = cacheKey;
      
      return events;
      
    } catch (e) {
      debugPrint('Error loading holiday events: $e');
      return {};
    }
  }
  
  /// 데이터베이스가 없을 때 사용할 fallback 이벤트들
  void _addFallbackEvents(Map<DateTime, CalendarEventInfo> events, DateTime month) {
    // 2024년과 2025년의 주요 공휴일들
    final fallbackEvents = <Map<String, dynamic>>[
      // 2024년
      {'date': '2024-01-01', 'name': '신정', 'type': 'holiday'},
      {'date': '2024-02-10', 'name': '설날', 'type': 'holiday'},
      {'date': '2024-03-01', 'name': '삼일절', 'type': 'holiday'},
      {'date': '2024-05-05', 'name': '어린이날', 'type': 'holiday'},
      {'date': '2024-05-15', 'name': '부처님오신날', 'type': 'holiday'},
      {'date': '2024-06-06', 'name': '현충일', 'type': 'holiday'},
      {'date': '2024-08-15', 'name': '광복절', 'type': 'holiday'},
      {'date': '2024-09-17', 'name': '추석', 'type': 'holiday'},
      {'date': '2024-10-03', 'name': '개천절', 'type': 'holiday'},
      {'date': '2024-10-09', 'name': '한글날', 'type': 'holiday'},
      {'date': '2024-12-25', 'name': '크리스마스', 'type': 'holiday'},
      
      // 2025년
      {'date': '2025-01-01', 'name': '신정', 'type': 'holiday'},
      {'date': '2025-01-29', 'name': '설날', 'type': 'holiday'},
      {'date': '2025-03-01', 'name': '삼일절', 'type': 'holiday'},
      {'date': '2025-05-05', 'name': '어린이날', 'type': 'holiday'},
      {'date': '2025-05-12', 'name': '부처님오신날', 'type': 'holiday'},
      {'date': '2025-06-06', 'name': '현충일', 'type': 'holiday'},
      {'date': '2025-08-15', 'name': '광복절', 'type': 'holiday'},
      {'date': '2025-10-06', 'name': '추석', 'type': 'holiday'},
      {'date': '2025-10-03', 'name': '개천절', 'type': 'holiday'},
      {'date': '2025-10-09', 'name': '한글날', 'type': 'holiday'},
      {'date': '2025-12-25', 'name': '크리스마스', 'type': 'holiday'},
      
      // 기념일들
      {'date': '2024-02-14', 'name': '발렌타인데이', 'type': 'special'},
      {'date': '2024-05-08', 'name': '어버이날', 'type': 'memorial'},
      {'date': '2025-02-14', 'name': '발렌타인데이', 'type': 'special'},
      {'date': '2025-05-08', 'name': '어버이날', 'type': 'memorial'},
    ];
    
    // 손없는날 샘플 데이터
    final auspiciousDays = <Map<String, dynamic>>[
      {'date': '2024-08-20', 'score': 95, 'description': '손없는날 - 이사하기 매우 좋은 날'},
      {'date': '2024-09-07', 'score': 93, 'description': '손없는날 - 이사하기 매우 좋은 날'},
      {'date': '2025-01-05', 'score': 89, 'description': '손없는날 - 이사하기 매우 좋은 날'},
      {'date': '2025-02-01', 'score': 91, 'description': '손없는날 - 이사하기 매우 좋은 날'},
    ];
    
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    
    // 공휴일/기념일 처리
    for (final event in fallbackEvents) {
      final date = DateTime.parse(event['date']);
      if (date.isAfter(startOfMonth.subtract(const Duration(days: 1))) && 
          date.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final isHoliday = event['type'] == 'holiday';
        final isSpecial = event['type'] == 'special' || event['type'] == 'memorial';
        
        events[normalizedDate] = CalendarEventInfo(
          date: normalizedDate,
          holidayName: isHoliday ? event['name'] : null,
          specialName: isSpecial ? event['name'] : null,
          auspiciousName: null,
          isHoliday: isHoliday,
          isSpecial: isSpecial,
          isAuspicious: false,
          auspiciousScore: null,
          description: null,
        );
      }
    }
    
    // 손없는날 처리
    for (final day in auspiciousDays) {
      final date = DateTime.parse(day['date']);
      if (date.isAfter(startOfMonth.subtract(const Duration(days: 1))) && 
          date.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final existingEvent = events[normalizedDate];
        
        events[normalizedDate] = CalendarEventInfo(
          date: normalizedDate,
          holidayName: existingEvent?.holidayName,
          specialName: existingEvent?.specialName,
          auspiciousName: day['description'],
          isHoliday: existingEvent?.isHoliday ?? false,
          isSpecial: existingEvent?.isSpecial ?? false,
          isAuspicious: true,
          auspiciousScore: day['score'],
          description: day['description'],
        );
      }
    }
  }
  
  /// 특정 날짜의 이벤트 정보 가져오기
  Future<CalendarEventInfo?> getEventForDate(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final events = await getEventsForMonth(date);
    return events[normalizedDate];
  }
  
  /// 공휴일인지 확인
  Future<bool> isHoliday(DateTime date) async {
    final event = await getEventForDate(date);
    return event?.isHoliday ?? false;
  }
  
  /// 특별한 날인지 확인 (기념일)
  Future<bool> isSpecialDay(DateTime date) async {
    final event = await getEventForDate(date);
    return event?.isSpecial ?? false;
  }
  
  /// 손없는날인지 확인
  Future<bool> isAuspiciousDay(DateTime date) async {
    final event = await getEventForDate(date);
    return event?.isAuspicious ?? false;
  }
  
  /// 날짜의 특별함 점수 (0.0 ~ 1.0)
  Future<double> getSpecialScore(DateTime date) async {
    final event = await getEventForDate(date);
    if (event?.isHoliday == true) return 1.0;
    if (event?.isAuspicious == true && event?.auspiciousScore != null) {
      return event!.auspiciousScore! / 100.0;
    }
    if (event?.isSpecial == true) return 0.8;
    if (_isWeekend(date)) return 0.6;
    return 0.0;
  }
  
  /// 날짜 설명 텍스트 가져오기
  Future<String> getDateDescription(DateTime date) async {
    final event = await getEventForDate(date);
    
    if (event?.holidayName != null) {
      return event!.holidayName!;
    } else if (event?.auspiciousName != null) {
      return event!.auspiciousName!;
    } else if (event?.specialName != null) {
      return event!.specialName!;
    } else if (_isWeekend(date)) {
      return date.weekday == DateTime.saturday ? '토요일' : '일요일';
    } else {
      return '';
    }
  }
  
  /// 주말인지 확인
  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }
  
  /// 캐시 클리어
  void clearCache() {
    _cachedEvents = null;
    _cacheDate = null;
  }
}