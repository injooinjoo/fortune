import 'package:lunar/lunar.dart';

class ZodiacCalculator {
  /// 지지(地支) → 띠 매핑
  static const Map<String, Map<String, String>> _zhiToZodiac = {
    '子': {'name': '쥐', 'emoji': '🐭'},
    '丑': {'name': '소', 'emoji': '🐮'},
    '寅': {'name': '호랑이', 'emoji': '🐯'},
    '卯': {'name': '토끼', 'emoji': '🐰'},
    '辰': {'name': '용', 'emoji': '🐲'},
    '巳': {'name': '뱀', 'emoji': '🐍'},
    '午': {'name': '말', 'emoji': '🐴'},
    '未': {'name': '양', 'emoji': '🐑'},
    '申': {'name': '원숭이', 'emoji': '🐵'},
    '酉': {'name': '닭', 'emoji': '🐓'},
    '戌': {'name': '개', 'emoji': '🐕'},
    '亥': {'name': '돼지', 'emoji': '🐷'},
  };

  /// 양력 년도 기반 띠 계산 (하위 호환용, 대략적인 계산)
  static Map<String, String> getZodiac(int year) {
    const animals = [
      {'name': '원숭이', 'emoji': '🐵'},
      {'name': '닭', 'emoji': '🐓'},
      {'name': '개', 'emoji': '🐕'},
      {'name': '돼지', 'emoji': '🐷'},
      {'name': '쥐', 'emoji': '🐭'},
      {'name': '소', 'emoji': '🐮'},
      {'name': '호랑이', 'emoji': '🐯'},
      {'name': '토끼', 'emoji': '🐰'},
      {'name': '용', 'emoji': '🐲'},
      {'name': '뱀', 'emoji': '🐍'},
      {'name': '말', 'emoji': '🐴'},
      {'name': '양', 'emoji': '🐑'},
    ];

    final zodiac = animals[year % 12];
    return {
      'name': zodiac['name']!,
      'emoji': zodiac['emoji']!,
    };
  }

  /// 생년월일 기준 띠 계산 (음력 기준, 정확한 계산)
  /// 음력 설날을 기준으로 띠가 바뀜
  static Map<String, String> getZodiacByBirthDate(DateTime birthDate) {
    final lunar = Lunar.fromDate(birthDate);
    final yearZhi = lunar.getYearZhi(); // 지지 (子丑寅卯...)

    final zodiac = _zhiToZodiac[yearZhi];
    if (zodiac != null) {
      return {
        'name': zodiac['name']!,
        'emoji': zodiac['emoji']!,
      };
    }

    // Fallback (혹시 매핑이 없는 경우)
    return getZodiac(lunar.getYear());
  }

  /// 생년월일 문자열 기준 띠 계산 (음력 기준)
  static Map<String, String> getZodiacByBirthDateString(String birthDate) {
    if (birthDate.isEmpty) {
      return {'name': '', 'emoji': ''};
    }

    try {
      final date = DateTime.parse(birthDate);
      return getZodiacByBirthDate(date);
    } catch (e) {
      return {'name': '', 'emoji': ''};
    }
  }

  /// 음력 년도 가져오기
  static int getLunarYear(DateTime birthDate) {
    final lunar = Lunar.fromDate(birthDate);
    return lunar.getYear();
  }
}