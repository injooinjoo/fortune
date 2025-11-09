import '../fortune_conditions.dart';

/// 건강 운세 조건
///
/// 특징:
/// - 날짜는 제외 (매일 새로운 운세)
/// - 건강 고민, 증상, 생활습관으로 조건 구분
///
/// 예시:
/// ```dart
/// final conditions = HealthFortuneConditions(
///   healthConcern: '피로감',
///   symptoms: ['두통', '불면증'],
///   sleepQuality: 2,
///   exerciseFrequency: 1,
///   stressLevel: 4,
/// );
/// ```
class HealthFortuneConditions extends FortuneConditions {
  final String healthConcern;
  final List<String> symptoms;
  final int sleepQuality; // 1~5
  final int exerciseFrequency; // 1~5
  final int stressLevel; // 1~5
  final int mealRegularity; // 1~5
  final bool hasChronicCondition;
  final String chronicCondition;

  HealthFortuneConditions({
    required this.healthConcern,
    required this.symptoms,
    required this.sleepQuality,
    required this.exerciseFrequency,
    required this.stressLevel,
    required this.mealRegularity,
    this.hasChronicCondition = false,
    this.chronicCondition = '',
  });

  /// inputConditions Map에서 HealthFortuneConditions 생성
  factory HealthFortuneConditions.fromInputData(Map<String, dynamic> data) {
    return HealthFortuneConditions(
      healthConcern: data['healthConcern'] as String? ?? data['current_condition'] as String? ?? '피로감',
      symptoms: data['symptoms'] != null
          ? List<String>.from(data['symptoms'] as List)
          : data['concerned_body_parts'] != null
              ? List<String>.from(data['concerned_body_parts'] as List)
              : [],
      sleepQuality: data['sleepQuality'] as int? ?? data['sleep_quality'] as int? ?? 3,
      exerciseFrequency: data['exerciseFrequency'] as int? ?? data['exercise_frequency'] as int? ?? 3,
      stressLevel: data['stressLevel'] as int? ?? data['stress_level'] as int? ?? 3,
      mealRegularity: data['mealRegularity'] as int? ?? data['meal_regularity'] as int? ?? 3,
      hasChronicCondition: data['hasChronicCondition'] as bool? ?? data['has_chronic_condition'] as bool? ?? false,
      chronicCondition: data['chronicCondition'] as String? ?? data['chronic_condition'] as String? ?? '',
    );
  }

  @override
  String generateHash() {
    final parts = <String>[
      'concern:${healthConcern.hashCode}',
      'symptoms:${symptoms.join(',').hashCode}',
      'sleep:$sleepQuality',
      'exercise:$exerciseFrequency',
      'stress:$stressLevel',
      'meal:$mealRegularity',
      if (hasChronicCondition) 'chronic:${chronicCondition.hashCode}',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'healthConcern': healthConcern,
      'symptoms': symptoms,
      'sleepQuality': sleepQuality,
      'exerciseFrequency': exerciseFrequency,
      'stressLevel': stressLevel,
      'mealRegularity': mealRegularity,
      'hasChronicCondition': hasChronicCondition,
      if (chronicCondition.isNotEmpty) 'chronicCondition': chronicCondition,
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      // 개인정보 보호를 위해 해시만 저장
      'concern_hash': healthConcern.hashCode.toString(),
      'symptoms_hash': symptoms.join(',').hashCode.toString(),
      'sleep_quality': sleepQuality.toString(),
      'exercise_freq': exerciseFrequency.toString(),
      'stress_level': stressLevel.toString(),
      'meal_regularity': mealRegularity.toString(),
      'has_chronic': hasChronicCondition.toString(),
      if (hasChronicCondition) 'chronic_hash': chronicCondition.hashCode.toString(),
      // 날짜는 포함하지 않음 (매일 변경)
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'fortune_type': 'health',
      'current_condition': healthConcern, // Edge Function이 기대하는 필드명
      'concerned_body_parts': symptoms, // Edge Function이 기대하는 필드명
      'sleepQuality': sleepQuality,
      'exerciseFrequency': exerciseFrequency,
      'stressLevel': stressLevel,
      'mealRegularity': mealRegularity,
      'hasChronicCondition': hasChronicCondition,
      'chronicCondition': chronicCondition,
      'date': _formatDate(DateTime.now()),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthFortuneConditions &&
          runtimeType == other.runtimeType &&
          healthConcern == other.healthConcern &&
          _listEquals(symptoms, other.symptoms) &&
          sleepQuality == other.sleepQuality &&
          exerciseFrequency == other.exerciseFrequency &&
          stressLevel == other.stressLevel &&
          mealRegularity == other.mealRegularity &&
          hasChronicCondition == other.hasChronicCondition &&
          chronicCondition == other.chronicCondition;

  @override
  int get hashCode =>
      healthConcern.hashCode ^
      symptoms.join(',').hashCode ^
      sleepQuality.hashCode ^
      exerciseFrequency.hashCode ^
      stressLevel.hashCode ^
      mealRegularity.hashCode ^
      hasChronicCondition.hashCode ^
      chronicCondition.hashCode;

  /// 리스트 비교 헬퍼
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  /// 날짜 포맷팅 (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
