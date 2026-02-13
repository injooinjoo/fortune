class FortuneDateUtils {
  static List<int> getYearOptions() {
    final currentYear = DateTime.now().year;
    return List.generate(100, (index) => currentYear - index);
  }

  static List<int> getMonthOptions() {
    return List.generate(12, (index) => index + 1);
  }

  static List<int> getDayOptions(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return List.generate(daysInMonth, (index) => index + 1);
  }

  static List<Map<String, String>> getTimePeriodOptions() {
    return [
      {'value': 'zi', 'label': '자시 (23:00 - 01:00)'},
      {'value': 'chou', 'label': '축시 (01:00 - 03:00)'},
      {'value': 'yin', 'label': '인시 (03:00 - 05:00)'},
      {'value': 'mao', 'label': '묘시 (05:00 - 07:00)'},
      {'value': 'chen', 'label': '진시 (07:00 - 09:00)'},
      {'value': 'si', 'label': '사시 (09:00 - 11:00)'},
      {'value': 'wu', 'label': '오시 (11:00 - 13:00)'},
      {'value': 'wei', 'label': '미시 (13:00 - 15:00)'},
      {'value': 'shen', 'label': '신시 (15:00 - 17:00)'},
      {'value': 'you', 'label': '유시 (17:00 - 19:00)'},
      {'value': 'xu', 'label': '술시 (19:00 - 21:00)'},
      {'value': 'hai', 'label': '해시 (21:00 - 23:00)'}
    ];
  }
}
