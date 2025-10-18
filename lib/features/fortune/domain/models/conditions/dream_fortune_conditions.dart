import '../fortune_conditions.dart';

/// 꿈 해몽 운세 조건
class DreamFortuneConditions extends FortuneConditions {
  final String dreamContent;
  final DateTime dreamDate;
  final String? dreamEmotion;

  DreamFortuneConditions({
    required this.dreamContent,
    required this.dreamDate,
    this.dreamEmotion,
  });

  @override
  String generateHash() {
    final parts = <String>[
      'dream:${dreamContent.hashCode}',
      'date:${_formatDate(dreamDate)}',
      if (dreamEmotion != null) 'emotion:${dreamEmotion!.hashCode}',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'dream_content': dreamContent,
      'dream_date': dreamDate.toIso8601String(),
      if (dreamEmotion != null) 'dream_emotion': dreamEmotion,
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'dream_date': _formatDate(dreamDate),
      'dream_emotion': dreamEmotion,
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'dream_content': dreamContent,
      'dream_date': dreamDate.toIso8601String(),
      if (dreamEmotion != null) 'dream_emotion': dreamEmotion,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DreamFortuneConditions &&
          runtimeType == other.runtimeType &&
          dreamContent == other.dreamContent &&
          dreamDate == other.dreamDate &&
          dreamEmotion == other.dreamEmotion;

  @override
  int get hashCode =>
      dreamContent.hashCode ^ dreamDate.hashCode ^ dreamEmotion.hashCode;
}
