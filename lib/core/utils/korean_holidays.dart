import 'package:intl/intl.dart';

class KoreanHolidays {
  static final Map<DateTime, String> _holidays2024 = {
    DateTime(2024, 1, 1): '신정',
    DateTime(2024, 2, 9): '설날 전날',
    DateTime(2024, 2, 10): '설날',
    DateTime(2024, 2, 11): '설날 연휴',
    DateTime(2024, 2, 12): '설날 연휴',
    DateTime(2024, 3, 1): '삼일절',
    DateTime(2024, 4, 10): '국회의원선거',
    DateTime(2024, 5, 5): '어린이날',
    DateTime(2024, 5, 6): '어린이날 대체공휴일',
    DateTime(2024, 5, 15): '부처님오신날',
    DateTime(2024, 6, 6): '현충일',
    DateTime(2024, 8, 15): '광복절',
    DateTime(2024, 9, 16): '추석 연휴',
    DateTime(2024, 9, 17): '추석',
    DateTime(2024, 9, 18): '추석 연휴',
    DateTime(2024, 10, 3): '개천절',
    DateTime(2024, 10, 9): '한글날',
    DateTime(2024, 12, 25): '크리스마스',
  };

  static final Map<DateTime, String> _holidays2025 = {
    DateTime(2025, 1, 1): '신정',
    DateTime(2025, 1, 28): '설날 연휴',
    DateTime(2025, 1, 29): '설날',
    DateTime(2025, 1, 30): '설날 연휴',
    DateTime(2025, 3, 1): '삼일절',
    DateTime(2025, 3, 3): '삼일절 대체공휴일',
    DateTime(2025, 5, 5): '어린이날',
    DateTime(2025, 5, 12): '부처님오신날',
    DateTime(2025, 6, 6): '현충일',
    DateTime(2025, 8, 15): '광복절',
    DateTime(2025, 10, 5): '추석 연휴',
    DateTime(2025, 10, 6): '추석',
    DateTime(2025, 10, 7): '추석 연휴',
    DateTime(2025, 10, 8): '추석 연휴',
    DateTime(2025, 10, 3): '개천절',
    DateTime(2025, 10, 9): '한글날',
    DateTime(2025, 12, 25): '크리스마스',
  };

  // 기념일 (공휴일은 아니지만 특별한 날들)
  static final Map<DateTime, String> _specialDays = {
    DateTime(2024, 2, 14): '발렌타인데이',
    DateTime(2024, 3, 14): '화이트데이',
    DateTime(2024, 4, 14): '블랙데이',
    DateTime(2024, 5, 8): '어버이날',
    DateTime(2024, 5, 15): '스승의날',
    DateTime(2024, 11, 11): '빼빼로데이',
    DateTime(2024, 12, 24): '크리스마스이브',
    DateTime(2024, 12, 31): '연말',
    
    DateTime(2025, 2, 14): '발렌타인데이',
    DateTime(2025, 3, 14): '화이트데이',
    DateTime(2025, 4, 14): '블랙데이',
    DateTime(2025, 5, 8): '어버이날',
    DateTime(2025, 5, 15): '스승의날',
    DateTime(2025, 11, 11): '빼빼로데이',
    DateTime(2025, 12, 24): '크리스마스이브',
    DateTime(2025, 12, 31): '연말',
  };

  /// 공휴일인지 확인
  static bool isHoliday(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _holidays2024.containsKey(normalizedDate) || 
           _holidays2025.containsKey(normalizedDate);
  }

  /// 특별한 날인지 확인 (기념일)
  static bool isSpecialDay(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _specialDays.containsKey(normalizedDate);
  }

  /// 공휴일 이름 가져오기
  static String? getHolidayName(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _holidays2024[normalizedDate] ?? _holidays2025[normalizedDate];
  }

  /// 기념일 이름 가져오기
  static String? getSpecialDayName(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _specialDays[normalizedDate];
  }

  /// 특정 달의 모든 공휴일과 기념일 가져오기
  static Map<DateTime, String> getEventsForMonth(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    
    final events = <DateTime, String>{};
    
    // 공휴일 추가
    for (final holiday in _holidays2024.entries) {
      if (holiday.key.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          holiday.key.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        events[holiday.key] = holiday.value;
      }
    }
    
    for (final holiday in _holidays2025.entries) {
      if (holiday.key.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          holiday.key.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        events[holiday.key] = holiday.value;
      }
    }
    
    // 기념일 추가
    for (final special in _specialDays.entries) {
      if (special.key.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          special.key.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        events[special.key] = special.value;
      }
    }
    
    return events;
  }

  /// 주말인지 확인
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// 날짜의 특별함 정도 점수 (0.0 ~ 1.0)
  static double getSpecialScore(DateTime date) {
    if (isHoliday(date)) return 1.0;
    if (isSpecialDay(date)) return 0.8;
    if (isWeekend(date)) return 0.6;
    return 0.0;
  }

  /// 날짜 설명 텍스트
  static String getDateDescription(DateTime date) {
    final holidayName = getHolidayName(date);
    final specialName = getSpecialDayName(date);
    
    if (holidayName != null) {
      return holidayName;
    } else if (specialName != null) {
      return specialName;
    } else if (isWeekend(date)) {
      return date.weekday == DateTime.saturday ? '토요일' : '일요일';
    } else {
      return DateFormat('EEEE', 'ko_KR').format(date);
    }
  }
}