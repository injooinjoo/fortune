import '../fortune_conditions.dart';

/// 토정비결 운세 조건
class TojeongFortuneConditions extends FortuneConditions {
  final DateTime birthDate;
  final DateTime consultDate;
  final String? lunarCalendar; // 음력/양력 구분

  TojeongFortuneConditions({
    required this.birthDate,
    required this.consultDate,
    this.lunarCalendar,
  });

  @override
  String generateHash() {
    final parts = <String>[
      'birth:${_formatDate(birthDate)}',
      'consult:${_formatDate(consultDate)}',
      if (lunarCalendar != null) 'lunar:${lunarCalendar!.hashCode}',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'birth_date': birthDate.toIso8601String(),
      'consult_date': consultDate.toIso8601String(),
      if (lunarCalendar != null) 'lunar_calendar': lunarCalendar,
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'birth_date': _formatDate(birthDate),
      'consult_date': _formatDate(consultDate),
      'lunar_calendar': lunarCalendar,
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'birth_date': birthDate.toIso8601String(),
      'consult_date': consultDate.toIso8601String(),
      if (lunarCalendar != null) 'lunar_calendar': lunarCalendar,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TojeongFortuneConditions &&
          runtimeType == other.runtimeType &&
          birthDate == other.birthDate &&
          consultDate == other.consultDate &&
          lunarCalendar == other.lunarCalendar;

  @override
  int get hashCode =>
      birthDate.hashCode ^ consultDate.hashCode ^ lunarCalendar.hashCode;
}
