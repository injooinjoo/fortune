// 📅 날짜 선택기 공통 유틸리티
//
// **기능**:
// - 나이 계산 (만 나이)
// - 음력 날짜 변환 (향후 구현)
// - 요일 계산
// - 날짜 포맷팅
class DatePickerUtils {
  DatePickerUtils._();

  /// 만 나이 계산
  ///
  /// **파라미터**:
  /// - `birthDate`: 생년월일
  /// - `baseDate`: 기준 날짜 (기본값: 오늘)
  ///
  /// **반환값**: 만 나이
  static int calculateAge(DateTime birthDate, {DateTime? baseDate}) {
    final now = baseDate ?? DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// 해당 월의 일수 계산
  ///
  /// **파라미터**:
  /// - `year`: 년도
  /// - `month`: 월 (1-12)
  ///
  /// **반환값**: 해당 월의 일수
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// 날짜 유효성 검사
  ///
  /// **파라미터**:
  /// - `year`: 년도
  /// - `month`: 월 (1-12)
  /// - `day`: 일
  ///
  /// **반환값**: 유효한 날짜인지 여부
  static bool isValidDate(int year, int month, int day) {
    if (month < 1 || month > 12) return false;
    if (day < 1) return false;

    final daysInMonth = getDaysInMonth(year, month);
    return day <= daysInMonth;
  }

  /// 날짜를 안전하게 생성 (유효하지 않으면 마지막 날로 조정)
  ///
  /// **파라미터**:
  /// - `year`: 년도
  /// - `month`: 월 (1-12)
  /// - `day`: 일
  ///
  /// **반환값**: 안전한 DateTime 객체
  static DateTime createSafeDate(int year, int month, int day) {
    final daysInMonth = getDaysInMonth(year, month);
    final safeDay = day > daysInMonth ? daysInMonth : day;
    return DateTime(year, month, safeDay);
  }

  /// 한국어 요일 변환
  ///
  /// **파라미터**:
  /// - `date`: 날짜
  ///
  /// **반환값**: 한국어 요일 (예: "월", "화")
  static String getKoreanWeekday(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }

  /// 한국어 요일 변환 (전체)
  ///
  /// **파라미터**:
  /// - `date`: 날짜
  ///
  /// **반환값**: 한국어 요일 (예: "월요일", "화요일")
  static String getKoreanWeekdayFull(DateTime date) {
    const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return weekdays[date.weekday - 1];
  }

  /// 주말 여부 확인
  ///
  /// **파라미터**:
  /// - `date`: 날짜
  ///
  /// **반환값**: 주말(토/일) 여부
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// 날짜 범위 체크
  ///
  /// **파라미터**:
  /// - `date`: 체크할 날짜
  /// - `minDate`: 최소 날짜 (nullable)
  /// - `maxDate`: 최대 날짜 (nullable)
  ///
  /// **반환값**: 범위 내에 있는지 여부
  static bool isInRange(DateTime date, {DateTime? minDate, DateTime? maxDate}) {
    if (minDate != null && date.isBefore(minDate)) return false;
    if (maxDate != null && date.isAfter(maxDate)) return false;
    return true;
  }

  /// 날짜를 정규화 (시간 제거)
  ///
  /// **파라미터**:
  /// - `date`: 날짜
  ///
  /// **반환값**: 시간이 00:00:00으로 설정된 날짜
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 두 날짜가 같은 날인지 비교
  ///
  /// **파라미터**:
  /// - `date1`: 첫 번째 날짜
  /// - `date2`: 두 번째 날짜
  ///
  /// **반환값**: 같은 날인지 여부
  static bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 년도 범위 생성
  ///
  /// **파라미터**:
  /// - `startYear`: 시작 년도 (기본값: 100년 전)
  /// - `endYear`: 끝 년도 (기본값: 올해)
  ///
  /// **반환값**: 년도 리스트
  static List<int> generateYearRange({int? startYear, int? endYear}) {
    final currentYear = DateTime.now().year;
    final start = startYear ?? (currentYear - 99);
    final end = endYear ?? currentYear;

    return List.generate(
      end - start + 1,
      (index) => start + index,
    );
  }

  /// 월 리스트 생성 (1-12)
  static List<int> generateMonths() {
    return List.generate(12, (index) => index + 1);
  }

  /// 해당 월의 일 리스트 생성
  ///
  /// **파라미터**:
  /// - `year`: 년도
  /// - `month`: 월 (1-12)
  ///
  /// **반환값**: 일 리스트
  static List<int> generateDays(int year, int month) {
    final daysInMonth = getDaysInMonth(year, month);
    return List.generate(daysInMonth, (index) => index + 1);
  }

  /// 한국식 날짜 포맷팅 (YYYY년 MM월 DD일)
  ///
  /// **파라미터**:
  /// - `date`: 날짜
  /// - `showWeekday`: 요일 표시 여부 (기본값: false)
  ///
  /// **반환값**: 포맷팅된 날짜 문자열
  static String formatKorean(DateTime date, {bool showWeekday = false}) {
    final base = '${date.year}년 ${date.month}월 ${date.day}일';
    if (showWeekday) {
      return '$base (${getKoreanWeekday(date)})';
    }
    return base;
  }

  /// 숫자 포맷팅 (YYYY.MM.DD)
  ///
  /// **파라미터**:
  /// - `date`: 날짜
  ///
  /// **반환값**: 포맷팅된 날짜 문자열
  static String formatNumeric(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
  }

  /// ISO 8601 포맷팅 (YYYY-MM-DD)
  ///
  /// **파라미터**:
  /// - `date`: 날짜
  ///
  /// **반환값**: ISO 8601 날짜 문자열
  static String formatISO(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// 음력 날짜 변환 (향후 구현)
  ///
  /// **TODO**: 음력 변환 라이브러리 통합
  ///
  /// **파라미터**:
  /// - `solarDate`: 양력 날짜
  ///
  /// **반환값**: 음력 날짜 (임시로 null 반환)
  static DateTime? convertToLunar(DateTime solarDate) {
    // TODO: 음력 변환 라이브러리 통합
    return null;
  }

  /// 음력 날짜 → 양력 날짜 변환 (향후 구현)
  ///
  /// **TODO**: 음력 변환 라이브러리 통합
  ///
  /// **파라미터**:
  /// - `lunarDate`: 음력 날짜
  ///
  /// **반환값**: 양력 날짜 (임시로 null 반환)
  static DateTime? convertToSolar(DateTime lunarDate) {
    // TODO: 음력 변환 라이브러리 통합
    return null;
  }
}
