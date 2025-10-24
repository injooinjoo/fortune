import '../fortune_conditions.dart';

/// 행운 아이템 운세 조건
class LuckyItemsFortuneConditions extends FortuneConditions {
  final DateTime birthDate;
  final String? birthTime; // "HH:MM"
  final String? gender; // "male" | "female"
  final List<String>? interests;

  LuckyItemsFortuneConditions({
    required this.birthDate,
    this.birthTime,
    this.gender,
    this.interests,
  });

  @override
  String generateHash() {
    final parts = <String>[
      'birthDate:${_formatDate(birthDate)}',
      if (birthTime != null) 'birthTime:$birthTime',
      if (gender != null) 'gender:$gender',
      if (interests != null && interests!.isNotEmpty) 'interests:${interests!.join(",")}',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'birthDate': birthDate.toIso8601String(),
      if (birthTime != null) 'birthTime': birthTime,
      if (gender != null) 'gender': gender,
      if (interests != null) 'interests': interests,
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'birth_date': _formatDate(birthDate),
      'birth_time': birthTime,
      'gender': gender,
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'birthDate': birthDate.toIso8601String(),
      if (birthTime != null) 'birthTime': birthTime,
      if (gender != null) 'gender': gender,
      if (interests != null && interests!.isNotEmpty) 'interests': interests,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LuckyItemsFortuneConditions &&
          runtimeType == other.runtimeType &&
          birthDate == other.birthDate &&
          birthTime == other.birthTime &&
          gender == other.gender;

  @override
  int get hashCode => birthDate.hashCode ^ birthTime.hashCode ^ gender.hashCode;
}
