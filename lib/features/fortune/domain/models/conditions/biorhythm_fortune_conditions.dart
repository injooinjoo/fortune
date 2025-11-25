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

  /// 조건 해시 가져오기 (캐시 키로 사용)
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
      'date': formatDate(DateTime.now()),
    };
  }

  /// Equatable 호환용 속성 목록
  List<Object?> get props => [birthDate, name];
}
