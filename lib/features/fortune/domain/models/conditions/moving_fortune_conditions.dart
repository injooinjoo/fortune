import '../fortune_conditions.dart';

/// 이사운 조건
///
/// 특징:
/// - 날짜는 제외 (매일 새로운 운세)
/// - 현재 지역, 목표 지역, 이사 시기, 목적으로 조건 구분
///
/// 예시:
/// ```dart
/// final conditions = MovingFortuneConditions(
///   currentArea: '서울 강남구',
///   targetArea: '서울 송파구',
///   movingPeriod: '2025년 2월',
///   purpose: '직장 출근을 위해',
/// );
/// ```
class MovingFortuneConditions extends FortuneConditions {
  final String currentArea;
  final String targetArea;
  final String movingPeriod;
  final String purpose;

  MovingFortuneConditions({
    required this.currentArea,
    required this.targetArea,
    required this.movingPeriod,
    required this.purpose,
  });

  @override
  String generateHash() {
    final parts = <String>[
      'current:${currentArea.hashCode}',
      'target:${targetArea.hashCode}',
      'period:${movingPeriod.hashCode}',
      'purpose:${purpose.hashCode}',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'currentArea': currentArea,
      'targetArea': targetArea,
      'movingPeriod': movingPeriod,
      'purpose': purpose,
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      // 개인정보 보호를 위해 해시만 저장
      'current_area_hash': currentArea.hashCode.toString(),
      'target_area_hash': targetArea.hashCode.toString(),
      'moving_period_hash': movingPeriod.hashCode.toString(),
      'purpose_hash': purpose.hashCode.toString(),
      // 날짜는 포함하지 않음 (매일 변경)
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'fortune_type': 'moving',
      'current_area': currentArea,
      'target_area': targetArea,
      'moving_period': movingPeriod,
      'purpose': purpose,
      'date': _formatDate(DateTime.now()),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovingFortuneConditions &&
          runtimeType == other.runtimeType &&
          currentArea == other.currentArea &&
          targetArea == other.targetArea &&
          movingPeriod == other.movingPeriod &&
          purpose == other.purpose;

  @override
  int get hashCode =>
      currentArea.hashCode ^
      targetArea.hashCode ^
      movingPeriod.hashCode ^
      purpose.hashCode;

  /// 날짜 포맷팅 (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
