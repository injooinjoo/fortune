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
      healthConcern: _readString([
            data['healthConcern'],
            data['current_condition'],
            data['currentCondition'],
          ]) ??
          '피로감',
      symptoms: _readStringList([
        data['symptoms'],
        data['concerned_body_parts'],
        data['concernedBodyParts'],
        data['concern'],
      ]),
      sleepQuality: _readInt([
            data['sleepQuality'],
            data['sleep_quality'],
          ]) ??
          3,
      exerciseFrequency: _readInt([
            data['exerciseFrequency'],
            data['exercise_frequency'],
          ]) ??
          3,
      stressLevel: _readInt([
            data['stressLevel'],
            data['stress_level'],
          ]) ??
          3,
      mealRegularity: _readInt([
            data['mealRegularity'],
            data['meal_regularity'],
          ]) ??
          3,
      hasChronicCondition: _readBool([
            data['hasChronicCondition'],
            data['has_chronic_condition'],
          ]) ??
          false,
      chronicCondition: _readString([
            data['chronicCondition'],
            data['chronic_condition'],
          ]) ??
          '',
    );
  }

  static String? _readString(List<dynamic> candidates) {
    for (final candidate in candidates) {
      if (candidate is! String) {
        continue;
      }

      final trimmed = candidate.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return null;
  }

  static int? _readInt(List<dynamic> candidates) {
    for (final candidate in candidates) {
      if (candidate is int) {
        return candidate;
      }
      if (candidate is num) {
        return candidate.toInt();
      }
      if (candidate is String) {
        final parsed = int.tryParse(candidate.trim());
        if (parsed != null) {
          return parsed;
        }
      }
    }

    return null;
  }

  static bool? _readBool(List<dynamic> candidates) {
    for (final candidate in candidates) {
      if (candidate is bool) {
        return candidate;
      }
      if (candidate is String) {
        final normalized = candidate.trim().toLowerCase();
        if (normalized == 'true') {
          return true;
        }
        if (normalized == 'false') {
          return false;
        }
      }
    }

    return null;
  }

  static List<String> _readStringList(List<dynamic> candidates) {
    for (final candidate in candidates) {
      if (candidate is List) {
        final values = candidate
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
        if (values.isNotEmpty) {
          return values;
        }
      }

      if (candidate is String) {
        final trimmed = candidate.trim();
        if (trimmed.isNotEmpty) {
          return [trimmed];
        }
      }
    }

    return const <String>[];
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
      if (hasChronicCondition)
        'chronic_hash': chronicCondition.hashCode.toString(),
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
