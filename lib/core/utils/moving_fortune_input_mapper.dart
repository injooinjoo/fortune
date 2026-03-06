import 'direction_calculator.dart';

class MovingFortuneInputMapper {
  static const Map<String, String> _purposeLabels = {
    'job': '직장/취업',
    'work': '직장/취업',
    'study': '교육 환경',
    'education': '교육 환경',
    'marriage': '결혼/독립',
    'family': '가족과 함께',
    'environment': '더 나은 환경',
    'better_life': '더 나은 환경',
    'investment': '투자 목적',
    'other': '기타',
  };

  static const Map<String, String> _concernLabels = {
    'direction': '방위',
    'timing': '시기',
    'adaptation': '적응',
    'neighbors': '이웃',
    'cost': '비용',
    'feng_shui': '풍수',
  };

  const MovingFortuneInputMapper._();

  static Map<String, dynamic> normalize(Map<String, dynamic> input) {
    final normalized = Map<String, dynamic>.from(input);
    final currentArea =
        extractAreaName(input['current_area'] ?? input['currentArea']);
    final targetArea =
        extractAreaName(input['target_area'] ?? input['targetArea']);
    final movingPeriod =
        normalizePeriodId(input['moving_period'] ?? input['movingPeriod']);
    final movingDate = resolveMovingDate(
      input['movingDate'] ?? input['moving_date'] ?? input['specificDate'],
      movingPeriod: movingPeriod,
    );
    final purpose = mapPurposeLabel(asTrimmedString(input['purpose']));
    final concerns = serializeConcerns(input['concerns']);
    final direction = asTrimmedString(input['direction']) ??
        _inferDirection(currentArea, targetArea);

    if (currentArea != null) {
      normalized['currentArea'] = currentArea;
      normalized['current_area'] = currentArea;
    }
    if (targetArea != null) {
      normalized['targetArea'] = targetArea;
      normalized['target_area'] = targetArea;
    }

    normalized['movingPeriod'] = movingPeriod;
    normalized['moving_period'] = movingPeriod;

    if (movingDate != null) {
      normalized['movingDate'] = movingDate;
      normalized['moving_date'] = movingDate;
    }
    if (purpose != null) {
      normalized['purpose'] = purpose;
      normalized['purposeCategory'] = purpose;
    }
    if (concerns != null) {
      normalized['concerns'] = concerns;
    }
    if (direction != null) {
      normalized['direction'] = direction;
    }

    return normalized;
  }

  static String normalizePeriodId(dynamic value) {
    final period = asTrimmedString(value) ?? 'undecided';
    switch (period) {
      case '1year':
        return 'year';
      case '1month':
      case '3months':
      case '6months':
      case 'year':
      case 'undecided':
        return period;
      default:
        return period;
    }
  }

  static String? resolveMovingDate(
    dynamic value, {
    String? movingPeriod,
    DateTime? now,
  }) {
    final explicitDate = _extractDateString(value);
    if (explicitDate != null) {
      return explicitDate;
    }

    final baseDate = now ?? DateTime.now();
    switch (normalizePeriodId(movingPeriod)) {
      case '1month':
        return _toDateString(baseDate.add(const Duration(days: 30)));
      case '3months':
        return _toDateString(baseDate.add(const Duration(days: 90)));
      case '6months':
        return _toDateString(baseDate.add(const Duration(days: 180)));
      case 'year':
        return _toDateString(baseDate.add(const Duration(days: 365)));
      case 'undecided':
      default:
        return _toDateString(baseDate.add(const Duration(days: 90)));
    }
  }

  static String? mapPurposeLabel(String? purpose) {
    final rawPurpose = asTrimmedString(purpose);
    if (rawPurpose == null) return null;
    return _purposeLabels[rawPurpose] ?? rawPurpose;
  }

  static List<String>? serializeConcerns(dynamic value) {
    if (value == null) return null;

    if (value is List) {
      final labels = value
          .map((item) => _concernLabels[item.toString()] ?? item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(growable: false);
      if (labels.isEmpty) return null;
      return labels;
    }

    final singleValue = asTrimmedString(value);
    if (singleValue == null) return null;
    return <String>[_concernLabels[singleValue] ?? singleValue];
  }

  static String? extractAreaName(dynamic value) {
    if (value is Map<String, dynamic>) {
      return _extractAreaNameFromMap(value);
    }

    if (value is Map) {
      return _extractAreaNameFromMap(
        value.map((key, mapValue) => MapEntry(key.toString(), mapValue)),
      );
    }

    return asTrimmedString(value);
  }

  static String? asTrimmedString(dynamic value) {
    if (value == null) return null;
    if (value is! String && value is! num && value is! bool) {
      return null;
    }
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return null;
    return text;
  }

  static String? _extractAreaNameFromMap(Map<String, dynamic> value) {
    final displayName = asTrimmedString(
      value['displayName'] ?? value['display_name'],
    );
    if (displayName != null) return displayName;

    final sido = asTrimmedString(value['sido']);
    final sigungu = asTrimmedString(value['sigungu']);
    if (sido != null && sigungu != null) {
      return '$sido $sigungu';
    }

    return sido ?? sigungu;
  }

  static String? _extractDateString(dynamic value) {
    if (value is Map<String, dynamic>) {
      final selectedDate = asTrimmedString(value['selectedDate']);
      if (selectedDate != null) return selectedDate;
      final dateValue = asTrimmedString(value['date']);
      if (dateValue != null) return dateValue.split('T').first;
    }

    if (value is Map) {
      return _extractDateString(
        value.map((key, mapValue) => MapEntry(key.toString(), mapValue)),
      );
    }

    final directValue = asTrimmedString(value);
    if (directValue != null) {
      return directValue.split('T').first;
    }

    return null;
  }

  static String? _inferDirection(String? currentArea, String? targetArea) {
    if (currentArea == null || targetArea == null) {
      return null;
    }
    return DirectionCalculator.inferFromRegionNames(currentArea, targetArea);
  }

  static String _toDateString(DateTime value) =>
      value.toIso8601String().split('T').first;
}
