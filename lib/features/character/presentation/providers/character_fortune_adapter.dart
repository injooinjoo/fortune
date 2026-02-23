import '../../../../core/models/fortune_result.dart';
import '../../../../domain/entities/fortune.dart';

/// Character chat에서 UnifiedFortuneService 결과를 Fortune 엔티티로 변환합니다.
class CharacterFortuneAdapter {
  static Fortune fromFortuneResult({
    required FortuneResult result,
    required String userId,
    required String fortuneType,
  }) {
    if (result.data.isEmpty && result.summary.isEmpty) {
      throw const FormatException('Invalid fortune result payload');
    }

    final data = result.data;
    final content = _extractContent(result);

    return Fortune(
      id: result.id ?? '$fortuneType-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: fortuneType,
      content: content,
      createdAt: result.createdAt ?? DateTime.now(),
      metadata: _buildMetadata(result),
      category: _asString(data['category']),
      overallScore: _extractOverallScore(result),
      description: _asString(data['description']),
      scoreBreakdown: _asMap(data['scoreBreakdown']) ??
          _asMap(data['score_breakdown']) ??
          _asMap(data['scores']),
      luckyItems:
          _asMap(data['luckyItems']) ?? _asMap(data['lucky_items']) ?? {},
      recommendations: _extractStringList(data, [
        'recommendations',
        'advice',
      ]),
      warnings: _extractStringList(data, [
        'warnings',
        'cautions',
      ]),
      summary: _extractSummaryText(result),
      additionalInfo:
          _asMap(data['additionalInfo']) ?? _asMap(data['additional_info']),
      greeting: _asString(data['greeting']),
      hexagonScores:
          _asIntMap(data['hexagonScores']) ?? _asIntMap(data['hexagon_scores']),
      fiveElements:
          _asMap(data['fiveElements']) ?? _asMap(data['five_elements']),
      specialTip:
          _asString(data['specialTip']) ?? _asString(data['special_tip']),
      period: _asString(data['period']),
      percentile: result.percentile,
      totalTodayViewers: result.totalTodayViewers,
      isPercentileValid: result.isPercentileValid,
    );
  }

  static String _extractContent(FortuneResult result) {
    final data = result.data;
    return _asString(data['content']) ??
        _asString(data['mainMessage']) ??
        _asString(data['main_message']) ??
        _extractSummaryText(result) ??
        '운세 결과를 확인했어요.';
  }

  static int? _extractOverallScore(FortuneResult result) {
    final fromResult = result.score;
    if (fromResult != null) return fromResult;

    final fromData = result.data['overallScore'] ??
        result.data['score'] ??
        result.data['overall_score'];
    if (fromData is num) return fromData.toInt();
    return null;
  }

  static String? _extractSummaryText(FortuneResult result) {
    final summary = result.summary;
    return _asString(summary['message']) ??
        _asString(summary['summary']) ??
        _asString(result.data['summary']) ??
        _asString(result.data['shortSummary']) ??
        _asString(result.data['short_summary']);
  }

  static Map<String, dynamic>? _buildMetadata(FortuneResult result) {
    final metadata = _asMap(result.data['metadata']) ?? <String, dynamic>{};
    return {
      ...metadata,
      'summary': result.summary,
      'raw_payload': result.data,
    };
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, mapValue) => MapEntry(key.toString(), mapValue),
      );
    }
    return null;
  }

  static Map<String, int>? _asIntMap(dynamic value) {
    final map = _asMap(value);
    if (map == null) return null;

    final converted = <String, int>{};
    for (final entry in map.entries) {
      final raw = entry.value;
      if (raw is num) {
        converted[entry.key] = raw.toInt();
      }
    }
    return converted.isEmpty ? null : converted;
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String && value.trim().isEmpty) return null;
    return value.toString();
  }

  static List<String>? _extractStringList(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value is List) {
        final converted = value
            .where((item) => item != null && item.toString().trim().isNotEmpty)
            .map((item) => item.toString())
            .toList(growable: false);
        if (converted.isNotEmpty) return converted;
      }
      if (value is String && value.trim().isNotEmpty) {
        return <String>[value];
      }
    }
    return null;
  }
}
