import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FortuneTypeLocalMigrationService {
  FortuneTypeLocalMigrationService._();

  static const String _migrationDoneKey = 'fortune_type_migration_v1_done';
  static const String _pendingDeepLinkKey = 'pending_deep_link_fortune_type';

  static const Map<String, String> _legacyToCanonical = {
    'daily_calendar': 'daily-calendar',
    'dailyCalendar': 'daily-calendar',
    'new_year': 'new-year',
    'newYear': 'new-year',
    'yearlyEncounter': 'yearly-encounter',
    'gameEnhance': 'game-enhance',
    'babyNickname': 'baby-nickname',
    'ex_lover': 'ex-lover',
    'exLover': 'ex-lover',
    'blindDate': 'blind-date',
    'blind_date': 'blind-date',
    'avoidPeople': 'avoid-people',
    'sportsGame': 'match-insight',
    'sports_game': 'match-insight',
    'fortuneCookie': 'fortune-cookie',
    'money': 'wealth',
    'luckyItems': 'lucky-items',
    'personalityDna': 'personality-dna',
    'mbti_dimensions': 'mbti-dimensions',
    'mbtiDimensions': 'mbti-dimensions',
    'pet': 'pet-compatibility',
    'ootdEvaluation': 'ootd-evaluation',
    'traditional': 'traditional-saju',
    'traditional_saju': 'traditional-saju',
    'daily_review': 'daily-review',
    'weekly_review': 'weekly-review',
    'chatInsight': 'chat-insight',
    'viewAll': 'view-all',
    'pastLife': 'past-life',
  };

  static Future<void> runOnce() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(_migrationDoneKey) ?? false;
    if (done) {
      return;
    }

    final pendingType = prefs.getString(_pendingDeepLinkKey);
    if (pendingType != null) {
      final canonical = _toCanonical(pendingType);
      if (canonical != pendingType) {
        await prefs.setString(_pendingDeepLinkKey, canonical);
      }
    }

    for (final key in prefs.getKeys()) {
      if (key == _migrationDoneKey) {
        continue;
      }

      final value = prefs.get(key);
      if (value is String) {
        final migrated = _migrateStringValue(value, parentKey: key);
        if (migrated != value) {
          await prefs.setString(key, migrated);
        }
        continue;
      }

      if (value is List<String>) {
        final migratedList = value
            .map((item) => _migrateStringValue(item, parentKey: key))
            .toList();
        if (!_stringListsEqual(value, migratedList)) {
          await prefs.setStringList(key, migratedList);
        }
      }
    }

    await prefs.setBool(_migrationDoneKey, true);
  }

  static String _migrateStringValue(String raw, {required String parentKey}) {
    final direct = _toCanonical(raw);
    if (direct != raw) {
      return direct;
    }

    final trimmed = raw.trimLeft();
    if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
      return raw;
    }

    try {
      final decoded = jsonDecode(raw);
      final migrated = _migrateDynamic(decoded, parentKey: parentKey);
      return jsonEncode(migrated);
    } catch (_) {
      return raw;
    }
  }

  static dynamic _migrateDynamic(dynamic value, {required String parentKey}) {
    if (value is Map) {
      final migratedMap = <String, dynamic>{};
      for (final entry in value.entries) {
        final key = entry.key.toString();
        final shouldNormalizeMapKeys = parentKey == 'fortune_type_count' ||
            parentKey == 'fortuneTypeCount';
        final nextKey = shouldNormalizeMapKeys ? _toCanonical(key) : key;

        final migratedValue = _migrateDynamic(entry.value, parentKey: key);

        if (_isFortuneTypeField(key) && migratedValue is String) {
          migratedMap[nextKey] = _toCanonical(migratedValue);
        } else {
          migratedMap[nextKey] = migratedValue;
        }
      }
      return migratedMap;
    }

    if (value is List) {
      return value
          .map((item) => _migrateDynamic(item, parentKey: parentKey))
          .toList();
    }

    if (value is String) {
      if (_isFortuneTypeField(parentKey) || parentKey == 'chipIds') {
        return _toCanonical(value);
      }
      return value;
    }

    return value;
  }

  static bool _isFortuneTypeField(String key) {
    return key == 'fortuneType' ||
        key == 'fortune_type' ||
        key == 'favorite_fortune_type' ||
        key == 'favoriteFortuneType' ||
        key == 'fortuneTypeString' ||
        key == 'type';
  }

  static String _toCanonical(String fortuneType) {
    return _legacyToCanonical[fortuneType] ?? fortuneType;
  }

  static bool _stringListsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) {
      return false;
    }

    for (var i = 0; i < a.length; i += 1) {
      if (a[i] != b[i]) {
        return false;
      }
    }

    return true;
  }
}
