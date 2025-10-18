import '../fortune_conditions.dart';

/// 행운 아이템 운세 조건
class LuckyItemsFortuneConditions extends FortuneConditions {
  final DateTime date;
  final String? category; // optional category filter

  LuckyItemsFortuneConditions({
    required this.date,
    this.category,
  });

  @override
  String generateHash() {
    final parts = <String>[
      'date:${_formatDate(date)}',
      if (category != null) 'category:${category!.hashCode}',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      if (category != null) 'category': category,
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'date': _formatDate(date),
      'category': category,
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'date': date.toIso8601String(),
      if (category != null) 'category': category,
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
          date == other.date &&
          category == other.category;

  @override
  int get hashCode => date.hashCode ^ category.hashCode;
}
