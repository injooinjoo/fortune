import '../../../../core/models/fortune_result.dart';
import '../../../../domain/entities/fortune.dart';

/// Character chat에서 UnifiedFortuneService 결과를 Fortune 엔티티로 변환합니다.
class CharacterFortuneAdapter {
  static Fortune fromFortuneResult({
    required FortuneResult result,
    required String userId,
    required String fortuneType,
  }) {
    final data = _resolvePrimaryPayload(result.data);

    if (data.isEmpty && result.summary.isEmpty) {
      throw const FormatException('Invalid fortune result payload');
    }
    final content = _extractContent(result);

    return Fortune(
      id: result.id ?? '$fortuneType-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: fortuneType,
      content: content,
      createdAt: result.createdAt ?? DateTime.now(),
      metadata: _buildMetadata(result, data),
      category: _asString(data['category']),
      overallScore: _extractOverallScore(result),
      description: _asString(data['description']),
      scoreBreakdown: _asMap(data['scoreBreakdown']) ??
          _asMap(data['score_breakdown']) ??
          _asMap(data['scores']),
      luckyItems: _extractLuckyItems(data),
      recommendations: _extractStringList(data, [
        'recommendations',
        'advice',
      ]),
      warnings: _extractStringList(data, [
        'warnings',
        'cautions',
        'caution',
      ]),
      summary: _extractSummaryText(result),
      additionalInfo:
          _asMap(data['additionalInfo']) ?? _asMap(data['additional_info']),
      greeting: _asString(data['greeting']),
      hexagonScores:
          _asIntMap(data['hexagonScores']) ?? _asIntMap(data['hexagon_scores']),
      timeSpecificFortunes: _extractTimeSpecificFortunes(data),
      fiveElements:
          _asMap(data['fiveElements']) ?? _asMap(data['five_elements']),
      specialTip:
          _asString(data['specialTip']) ?? _asString(data['special_tip']),
      period: _asString(data['period']),
      meta: _asMap(data['meta']),
      weatherSummary:
          _asMap(data['weatherSummary']) ?? _asMap(data['weather_summary']),
      overall: _asMap(data['overall']),
      categories: _asMap(data['categories']),
      sajuInsight: _asMap(data['sajuInsight']) ?? _asMap(data['saju_insight']),
      personalActions: _extractMapList(data, [
        'personalActions',
        'personal_actions',
      ]),
      notification: _asMap(data['notification']),
      shareCard: _asMap(data['shareCard']) ?? _asMap(data['share_card']),
      uiBlocks: _extractStringList(data, ['uiBlocks', 'ui_blocks']),
      explain: _asMap(data['explain']),
      percentile: result.percentile,
      totalTodayViewers: result.totalTodayViewers,
      isPercentileValid: result.isPercentileValid,
    );
  }

  static String _extractContent(FortuneResult result) {
    final data = _resolvePrimaryPayload(result.data);
    return _asString(data['content']) ??
        _asString(data['overallReading']) ??
        _asString(data['overall_reading']) ??
        _asString(data['guidance']) ??
        _asString(data['mainMessage']) ??
        _asString(data['main_message']) ??
        _extractSummaryText(result) ??
        '운세 결과를 확인했어요.';
  }

  static int? _extractOverallScore(FortuneResult result) {
    final fromResult = result.score;
    if (fromResult != null) return fromResult;

    final data = _resolvePrimaryPayload(result.data);
    final fromData =
        data['overallScore'] ?? data['score'] ?? data['overall_score'];
    if (fromData is num) return fromData.toInt();
    return null;
  }

  static String? _extractSummaryText(FortuneResult result) {
    final data = _resolvePrimaryPayload(result.data);
    final summary = result.summary;
    return _asString(summary['message']) ??
        _asString(summary['summary']) ??
        _asString(summary['storyTitle']) ??
        _asString(data['storyTitle']) ??
        _asString(data['story_title']) ??
        _asString(data['summary']) ??
        _asString(data['overallReading']) ??
        _asString(data['overall_reading']) ??
        _asString(data['shortSummary']) ??
        _asString(data['short_summary']);
  }

  static Map<String, dynamic>? _buildMetadata(
    FortuneResult result,
    Map<String, dynamic> normalizedData,
  ) {
    final metadata = _asMap(normalizedData['metadata']) ?? <String, dynamic>{};
    return {
      ...metadata,
      'summary': result.summary,
      'raw_payload': normalizedData,
      if (!identical(normalizedData, result.data))
        'source_payload': result.data,
    };
  }

  static Map<String, dynamic> _resolvePrimaryPayload(
      Map<String, dynamic> source) {
    final candidates = <Map<String, dynamic>>[
      source,
      if (_asMap(source['fortune']) != null) _asMap(source['fortune'])!,
      if (_asMap(source['data']) != null) _asMap(source['data'])!,
      if (_asMap(source['fortune_data']) != null)
        _asMap(source['fortune_data'])!,
      if (_asMap(source['result']) != null) _asMap(source['result'])!,
    ];

    var best = source;
    var bestScore = _payloadRichness(source);

    for (final candidate in candidates.skip(1)) {
      final score = _payloadRichness(candidate);
      if (score > bestScore) {
        best = candidate;
        bestScore = score;
      }
    }

    return best;
  }

  static int _payloadRichness(Map<String, dynamic> payload) {
    var score = 0;

    const primaryKeys = <String>[
      'content',
      'overallReading',
      'overall_reading',
      'mainMessage',
      'main_message',
      'greeting',
      'description',
      'advice',
      'caution',
      'warnings',
      'recommendations',
      'categories',
      'luckyItems',
      'lucky_items',
      'timeSlots',
      'time_slots',
      'goalFortune',
      'goal_fortune',
      'monthlyHighlights',
      'monthly_highlights',
      'actionPlan',
      'action_plan',
    ];

    for (final key in primaryKeys) {
      final value = payload[key];
      if (value is String && value.trim().isNotEmpty) {
        score += 2;
      } else if (value is List && value.isNotEmpty) {
        score += 2;
      } else if (value is Map && value.isNotEmpty) {
        score += 2;
      } else if (value != null) {
        score += 1;
      }
    }

    if (_asString(payload['summary']) != null) {
      score += 1;
    }
    if (payload['score'] is num ||
        payload['overallScore'] is num ||
        payload['overall_score'] is num) {
      score += 1;
    }

    return score;
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

  static Map<String, dynamic>? _extractLuckyItems(Map<String, dynamic> data) {
    final explicit =
        _asMap(data['luckyItems']) ?? _asMap(data['lucky_items']) ?? {};
    final flattened = <String, dynamic>{
      if (_asString(data['lucky_number']) != null)
        'number': _asString(data['lucky_number']),
      if (_asString(data['lucky_color']) != null)
        'color': _asString(data['lucky_color']),
      if (_asString(data['lucky_color_hex']) != null)
        'colorHex': _asString(data['lucky_color_hex']),
      if (_asString(data['lucky_time']) != null)
        'time': _asString(data['lucky_time']),
      if (_asString(data['lucky_direction']) != null)
        'direction': _asString(data['lucky_direction']),
      if (_asString(data['lucky_item']) != null)
        'item': _asString(data['lucky_item']),
      if (_asString(data['lucky_place']) != null)
        'place': _asString(data['lucky_place']),
      if (_asString(data['emoji']) != null) 'emoji': _asString(data['emoji']),
    };

    final merged = <String, dynamic>{
      ...explicit,
      ...flattened,
    };
    return merged.isEmpty ? null : merged;
  }

  static List<Map<String, dynamic>>? _extractMapList(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value is! List) continue;

      final converted = value
          .map(_asMap)
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
      if (converted.isNotEmpty) {
        return converted;
      }
    }
    return null;
  }

  static List<TimeSpecificFortune>? _extractTimeSpecificFortunes(
    Map<String, dynamic> data,
  ) {
    final rawList = data['timeSpecificFortunes'] ??
        data['time_specific_fortunes'] ??
        data['timeSlots'] ??
        data['time_slots'];
    if (rawList is! List) return null;

    final items = <TimeSpecificFortune>[];
    for (final item in rawList) {
      final map = _asMap(item);
      if (map == null) continue;

      final time = _asString(map['time']) ??
          _asString(map['period']) ??
          _asString(map['timeRange']) ??
          _asString(map['time_range']);
      final title = _asString(map['title']) ??
          _asString(map['traditionalName']) ??
          _asString(map['traditional_name']) ??
          time;
      final score = map['score'];
      final description = _asString(map['description']) ??
          _asString(map['reason']) ??
          _joinStringList(map['activities']);

      if (time == null ||
          title == null ||
          description == null ||
          score is! num) {
        continue;
      }

      items.add(
        TimeSpecificFortune(
          time: time,
          title: title,
          score: score.toInt(),
          description: description,
          recommendation: _asString(map['recommendation']) ??
              _asString(map['caution']) ??
              _asString(map['advice']) ??
              _asString(map['luckyAction']) ??
              _asString(map['lucky_action']),
        ),
      );
    }

    return items.isEmpty ? null : items;
  }

  static String? _joinStringList(dynamic value) {
    if (value is! List) return null;
    final items = value
        .map(_asString)
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (items.isEmpty) return null;
    return items.join(' · ');
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
