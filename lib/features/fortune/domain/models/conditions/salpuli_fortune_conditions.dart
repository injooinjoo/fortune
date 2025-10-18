import '../fortune_conditions.dart';

/// 살풀이 운세 조건
class SalpuliFortuneConditions extends FortuneConditions {
  final DateTime birthDate;
  final String? concern; // 고민 사항
  final DateTime consultDate;

  SalpuliFortuneConditions({
    required this.birthDate,
    this.concern,
    required this.consultDate,
  });

  @override
  String generateHash() {
    final parts = <String>[
      'birth:${_formatDate(birthDate)}',
      if (concern != null) 'concern:${concern!.hashCode}',
      'consult:${_formatDate(consultDate)}',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'birth_date': birthDate.toIso8601String(),
      if (concern != null) 'concern': concern,
      'consult_date': consultDate.toIso8601String(),
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'birth_date': _formatDate(birthDate),
      'consult_date': _formatDate(consultDate),
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'birth_date': birthDate.toIso8601String(),
      if (concern != null) 'concern': concern,
      'consult_date': consultDate.toIso8601String(),
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalpuliFortuneConditions &&
          runtimeType == other.runtimeType &&
          birthDate == other.birthDate &&
          concern == other.concern &&
          consultDate == other.consultDate;

  @override
  int get hashCode =>
      birthDate.hashCode ^ concern.hashCode ^ consultDate.hashCode;
}
