class TimePeriod {
  final String value;
  final String label;
  final String time;
  final String description;

  const TimePeriod({
    required this.value,
    required this.label,
    required this.time,
    required this.description,
  });
}

// 12시진(時辰) 시스템
const List<TimePeriod> timePeriods = [
  TimePeriod(value: "자시", label: "자시 (子時)", time: "23:00-01:00", description: "밤 11시 ~ 새벽 1시"),
  TimePeriod(value: "축시", label: "축시 (丑時)", time: "01:00-03:00", description: "새벽 1시 ~ 새벽 3시"),
  TimePeriod(value: "인시", label: "인시 (寅時)", time: "03:00-05:00", description: "새벽 3시 ~ 새벽 5시"),
  TimePeriod(value: "묘시", label: "묘시 (卯時)", time: "05:00-07:00", description: "새벽 5시 ~ 오전 7시"),
  TimePeriod(value: "진시", label: "진시 (辰時)", time: "07:00-09:00", description: "오전 7시 ~ 오전 9시"),
  TimePeriod(value: "사시", label: "사시 (巳時)", time: "09:00-11:00", description: "오전 9시 ~ 오전 11시"),
  TimePeriod(value: "오시", label: "오시 (午時)", time: "11:00-13:00", description: "오전 11시 ~ 오후 1시"),
  TimePeriod(value: "미시", label: "미시 (未時)", time: "13:00-15:00", description: "오후 1시 ~ 오후 3시"),
  TimePeriod(value: "신시", label: "신시 (申時)", time: "15:00-17:00", description: "오후 3시 ~ 오후 5시"),
  TimePeriod(value: "유시", label: "유시 (酉時)", time: "17:00-19:00", description: "오후 5시 ~ 오후 7시"),
  TimePeriod(value: "술시", label: "술시 (戌時)", time: "19:00-21:00", description: "오후 7시 ~ 오후 9시"),
  TimePeriod(value: "해시", label: "해시 (亥時)", time: "21:00-23:00", description: "오후 9시 ~ 오후 11시"),
];

class FortuneDateUtils {
  // 년도 옵션 생성 (1900-현재년도)
  static List<int> getYearOptions() {
    final currentYear = DateTime.now().year;
    return List<int>.generate(
      currentYear - 1899, 
      (i) => currentYear - i
    );
  }

  // 월 옵션 생성 (1-12)
  static List<int> getMonthOptions() {
    return List<int>.generate(12, (i) => i + 1);
  }

  // 일 옵션 생성 (해당 년월에 맞는 일수)
  static List<int> getDayOptions(int? year, int? month) {
    if (year == null || month == null) {
      return List<int>.generate(31, (i) => i + 1);
    }
    
    // 해당 월의 마지막 날 계산
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return List<int>.generate(daysInMonth, (i) => i + 1);
  }

  // 날짜 포맷팅 (0000년 00월 00일)
  static String formatKoreanDate(String year, String month, String day) {
    if (year.isEmpty || month.isEmpty || day.isEmpty) return "";
    return '${year.padLeft(4, '0')}년 ${month.padLeft(2, '0')}월 ${day.padLeft(2, '0')}일';
  }

  // 한국식 날짜를 ISO 형식으로 변환
  static String koreanToIsoDate(String year, String month, String day) {
    if (year.isEmpty || month.isEmpty || day.isEmpty) return "";
    final yearStr = year.padLeft(4, '0');
    final monthStr = month.padLeft(2, '0');
    final dayStr = day.padLeft(2, '0');
    return '$yearStr-$monthStr-$dayStr';
  }

  // 생년월일에서 별자리 계산
  static String getZodiacSign(String birthDate) {
    if (birthDate.isEmpty) return '';
    
    final date = DateTime.parse(birthDate);
    final month = date.month;
    final day = date.day;
    
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return '양자리';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return '황소자리';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return '쌍둥이자리';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return '게자리';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return '사자자리';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return '처녀자리';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return '천칭자리';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return '전갈자리';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return '사수자리';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return '염소자리';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return '물병자리';
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return '물고기자리';
    
    return '';
  }

  // 생년월일에서 띠 계산
  static String getChineseZodiac(String birthDate) {
    if (birthDate.isEmpty) return '';
    
    final year = DateTime.parse(birthDate).year;
    const animals = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양'];
    return animals[year % 12];
  }

  // 현재 시간을 기준으로 해당하는 시진 찾기
  static String getCurrentTimePeriod() {
    final hour = DateTime.now().hour;
    
    if (hour >= 23 || hour < 1) return "자시";
    if (hour >= 1 && hour < 3) return "축시";
    if (hour >= 3 && hour < 5) return "인시";
    if (hour >= 5 && hour < 7) return "묘시";
    if (hour >= 7 && hour < 9) return "진시";
    if (hour >= 9 && hour < 11) return "사시";
    if (hour >= 11 && hour < 13) return "오시";
    if (hour >= 13 && hour < 15) return "미시";
    if (hour >= 15 && hour < 17) return "신시";
    if (hour >= 17 && hour < 19) return "유시";
    if (hour >= 19 && hour < 21) return "술시";
    if (hour >= 21 && hour < 23) return "해시";
    
    return "자시"; // 기본값
  }
}