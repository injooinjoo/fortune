import '../fortune_conditions.dart';

/// 재능 발견 운세 조건
///
/// 캐시/DB 재사용 판단 기준:
/// - 같은 날짜
/// - 같은 생년월일 + 성별
/// - 같은 고민분야/관심분야
/// - 같은 성향 (업무스타일, 에너지충전, 문제해결, 선호역할)
class TalentFortuneConditions extends FortuneConditions {
  final DateTime birthDate;
  final String birthTime; // HH:mm 형식
  final String gender;
  final String? birthCity;
  final String? currentOccupation;
  final List<String> concernAreas;
  final List<String> interestAreas;
  final String? selfStrengths;
  final String? selfWeaknesses;
  final String workStyle;
  final String energySource;
  final String problemSolving;
  final String preferredRole;
  final DateTime date; // 오늘 날짜 (캐시 키)

  TalentFortuneConditions({
    required this.birthDate,
    required this.birthTime,
    required this.gender,
    this.birthCity,
    this.currentOccupation,
    required this.concernAreas,
    required this.interestAreas,
    this.selfStrengths,
    this.selfWeaknesses,
    required this.workStyle,
    required this.energySource,
    required this.problemSolving,
    required this.preferredRole,
    required this.date,
  });

  /// inputConditions Map에서 생성
  factory TalentFortuneConditions.fromInputData(Map<String, dynamic> data) {
    return TalentFortuneConditions(
      birthDate: DateTime.parse(data['birth_date'] as String),
      birthTime: data['birth_time'] as String,
      gender: data['gender'] as String,
      birthCity: data['birth_city'] as String?,
      currentOccupation: data['current_occupation'] as String?,
      concernAreas: List<String>.from(data['concern_areas'] as List? ?? []),
      interestAreas: List<String>.from(data['interest_areas'] as List? ?? []),
      selfStrengths: data['self_strengths'] as String?,
      selfWeaknesses: data['self_weaknesses'] as String?,
      workStyle: data['work_style'] as String,
      energySource: data['energy_source'] as String,
      problemSolving: data['problem_solving'] as String,
      preferredRole: data['preferred_role'] as String,
      date: DateTime.now(),
    );
  }

  @override
  String generateHash() {
    // 핵심 조건만 해시에 포함 (같은 날 동일 조건이면 재사용)
    final parts = <String>[
      'date:${formatDate(date)}',
      'birth:${formatDate(birthDate)}',
      'gender:$gender',
      'concerns:${sha256Hash(concernAreas..sort())}',
      'interests:${sha256Hash(interestAreas..sort())}',
      'style:$workStyle|$energySource|$problemSolving|$preferredRole',
    ];
    return parts.join('_');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'birth_date': formatDate(birthDate),
      'birth_time': birthTime,
      'gender': gender,
      if (birthCity != null) 'birth_city': birthCity,
      if (currentOccupation != null) 'current_occupation': currentOccupation,
      'concern_areas': concernAreas,
      'interest_areas': interestAreas,
      if (selfStrengths != null) 'self_strengths': selfStrengths,
      if (selfWeaknesses != null) 'self_weaknesses': selfWeaknesses,
      'work_style': workStyle,
      'energy_source': energySource,
      'problem_solving': problemSolving,
      'preferred_role': preferredRole,
      'date': formatDate(date),
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'birth_date': formatDate(birthDate),
      'gender': gender,
      'date': formatDate(date),
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'birth_date': formatDate(birthDate),
      'birth_time': birthTime,
      'gender': gender,
      if (birthCity != null) 'birth_city': birthCity,
      if (currentOccupation != null) 'current_occupation': currentOccupation,
      'concern_areas': concernAreas,
      'interest_areas': interestAreas,
      if (selfStrengths != null) 'self_strengths': selfStrengths,
      if (selfWeaknesses != null) 'self_weaknesses': selfWeaknesses,
      'work_style': workStyle,
      'energy_source': energySource,
      'problem_solving': problemSolving,
      'preferred_role': preferredRole,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TalentFortuneConditions &&
          runtimeType == other.runtimeType &&
          birthDate == other.birthDate &&
          gender == other.gender &&
          _listEquals(concernAreas, other.concernAreas) &&
          _listEquals(interestAreas, other.interestAreas) &&
          workStyle == other.workStyle &&
          energySource == other.energySource &&
          problemSolving == other.problemSolving &&
          preferredRole == other.preferredRole &&
          formatDate(date) == formatDate(other.date);

  @override
  int get hashCode =>
      birthDate.hashCode ^
      gender.hashCode ^
      concernAreas.hashCode ^
      interestAreas.hashCode ^
      workStyle.hashCode ^
      energySource.hashCode ^
      problemSolving.hashCode ^
      preferredRole.hashCode ^
      date.hashCode;

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
