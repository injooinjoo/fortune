import '../fortune_conditions.dart';

class BiorhythmFortuneConditions extends FortuneConditions {
  final String birthDate;
  final String name;

  BiorhythmFortuneConditions({
    required this.birthDate,
    required this.name,
  });

  @override
  String generateHash() {
    // 바이오리듬은 생년월일만 중요 (날짜는 제외)
    return 'birthDate:${birthDate.hashCode}';
  }

  @override
  String getConditionsHash() {
    // 바이오리듬은 생년월일만 중요 (날짜는 제외)
    return birthDate;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'birthDate': birthDate,
      'name': name,
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'birth_date': birthDate,
      'name_hash': name.hashCode.toString(),
      // 날짜는 포함하지 않음 (매일 변경)
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'fortune_type': 'biorhythm',
      'birthDate': birthDate,
      'name': name,
      'date': _formatDate(DateTime.now()),
    };
  }

  @override
  List<Object?> get props => [birthDate, name];

  /// 날짜 포맷팅 (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
