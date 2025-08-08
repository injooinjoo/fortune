import 'package:lunar/lunar.dart';

/// 손없는날 계산기 - 한국 전통 이사 길일 계산
class AuspiciousDaysCalculator {
  // 손없는날 기준 (음력 기준,
  // 1,2일: 동쪽 손 없음
  // 3,4일: 남쪽 손 없음  
  // 5,6일: 서쪽 손 없음
  // 7,8일: 북쪽 손 없음
  // 9,10일: 모든 방향 손 없음 (최고의 이사날)
  
  /// 특정 월의 손없는날 계산
  static List<DateTime> getAuspiciousDays(int year, int month) {
    final auspiciousDays = <DateTime>[];
    
    // 해당 월의 첫날과 마지막날
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    
    // 각 날짜를 검사
    for (var day = firstDay; day.isBefore(lastDay.add(const Duration(days: 1))); 
         day = day.add(const Duration(days: 1))) {
      final lunar = Lunar.fromDate(day);
      final lunarDay = lunar.getDay();
      
      // 음력 9일, 10일은 모든 방향 손 없음 (최고의 날,
      if (lunarDay == 9 || lunarDay == 10) {
        auspiciousDays.add(day);
      }
    }
    
    return auspiciousDays;
  }
  
  /// 특정 날짜가 손없는날인지 확인
  static bool isAuspiciousDay(DateTime date) {
    final lunar = Lunar.fromDate(date);
    final lunarDay = lunar.getDay();
    
    // 음력 9일, 10일은 모든 방향 손 없음
    return lunarDay == 9 || lunarDay == 10;
  }
  
  /// 특정 날짜의 손없는 방향 계산
  static List<String> getAuspiciousDirections(DateTime date) {
    final lunar = Lunar.fromDate(date);
    final lunarDay = lunar.getDay();
    
    switch (lunarDay) {
      case 1:
      case 2:
        return ['동쪽'];
      case 3:
      case 4:
        return ['남쪽'];
      case 5:
      case 6:
        return ['서쪽'];
      case 7:
      case 8:
        return ['북쪽'];
      case 9:
      case 10:
        return ['동쪽', '서쪽', '남쪽', '북쪽'];
    default:
        return [];
    }
  }
  
  /// 날짜별 이사 길흉 점수 계산 (0.0 ~ 1.0,
  static double getMovingLuckScore(DateTime date, String? userBirthDate) {
    double score = 0.5; // 기본 점수
    
    final lunar = Lunar.fromDate(date);
    final lunarDay = lunar.getDay();
    
    // 손없는날 가산점
    if (lunarDay == 9 || lunarDay == 10) {
      score += 0.3; // 최고의 날
    } else if (lunarDay >= 1 && lunarDay <= 8) {
      score += 0.1; // 방향별 손없는날
    }
    
    // 주말 가산점
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      score += 0.1;
    }
    
    // 월초 감점 (바쁜 시기,
    if (date.day <= 3 || date.day >= 28) {
      score -= 0.1;
    }
    
    // 음력 그믐 감점
    if (lunarDay >= 28 || lunarDay <= 2) {
      score -= 0.1;
    }
    
    // 생일 기준 길일 계산 (사주 간단 계산,
    if (userBirthDate != null) {
      try {
        final birthDate = DateTime.parse(userBirthDate);
        final birthLunar = Lunar.fromDate(birthDate);
        
        // 생일의 천간과 이사일의 천간 조화
        if (_isHarmoniousDay(birthLunar, lunar)) {
          score += 0.1;
        }
      } catch (e) {
        // 생일 파싱 실패시 무시
      }
    }
    
    // 점수 정규화 (0.0 ~ 1.0,
    return score.clamp(0.0, 1.0);
  }
  
  /// 천간 조화 확인 (간단한 버전,
  static bool _isHarmoniousDay(Lunar birthLunar, Lunar targetLunar) {
    final birthGan = birthLunar.getDayGan(); // 생일의 일간
    final targetGan = targetLunar.getDayGan(); // 이사일의 일간
    
    // 상생 관계 확인 (목->화->토->금->수->목)
    final ganCycle = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    final birthIndex = ganCycle.indexOf(birthGan);
    final targetIndex = ganCycle.indexOf(targetGan);
    
    if (birthIndex == -1 || targetIndex == -1) return false;
    
    // 같은 오행이거나 상생 관계면 true
    final diff = (targetIndex - birthIndex).abs();
    return diff == 0 || diff == 2 || diff == 8;
  }
  
  /// 음력 날짜 정보 가져오기
  static Map<String, dynamic> getLunarDateInfo(DateTime date) {
    final lunar = Lunar.fromDate(date);
    
    return {
      'lunarMonth': lunar.getMonth(),
      'lunarDay': lunar.getDay(),
      'lunarMonthInChinese': lunar.getMonthInChinese(),
      'lunarDayInChinese': lunar.getDayInChinese(),
      'yearGanZhi': '${lunar.getYearGan()}${lunar.getYearZhi()}',
      'monthGanZhi': '${lunar.getMonthGan()}${lunar.getMonthZhi()}',
      'dayGanZhi': '${lunar.getDayGan()}${lunar.getDayZhi()}',
      'isLeapMonth': lunar.getMonthInChinese().startsWith('闰')};
  }
  
  /// 절기 정보 가져오기
  static String? getSolarTerm(DateTime date) {
    final lunar = Lunar.fromDate(date);
    final jieQi = lunar.getPrevJieQi();
    return jieQi?.getName();
  }
}