import 'dart:convert';

import '../fortune_conditions.dart';

/// 캐릭터 호기심 탭 운세 전용 조건 모델
///
/// - fortuneType + merged params를 안정적으로 정규화해 해시를 생성합니다.
/// - 대용량/민감 이미지 필드는 원문 대신 해시로 치환합니다.
class CharacterChatFortuneConditions extends FortuneConditions {
  static const _sensitiveKeyHints = <String>{
    'image',
    'photo',
    'base64',
    'selfie',
    'screenshot',
  };

  static const int _largeTextThreshold = 2048;

  final String fortuneType;
  final Map<String, dynamic> answers;
  final Map<String, dynamic> userProfileMergedParams;

  CharacterChatFortuneConditions({
    required this.fortuneType,
    required this.answers,
    required this.userProfileMergedParams,
  });

  @override
  String generateHash() {
    final normalized = _normalizedPayload();
    return sha256Hash({
      'fortune_type': fortuneType,
      'payload': normalized,
    });
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'fortune_type': fortuneType,
      'payload': _normalizedPayload(),
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    final normalized = _normalizedPayload();
    final keys = normalized.keys.toList()..sort();
    return {
      'fortune_type': fortuneType,
      'top_level_keys': keys,
      'field_count': keys.length,
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return _normalizedPayload();
  }

  Map<String, dynamic> _normalizedPayload() {
    return _normalizeMap(userProfileMergedParams);
  }

  Map<String, dynamic> _normalizeMap(Map<String, dynamic> source) {
    final sortedKeys = source.keys.toList()..sort();
    final normalized = <String, dynamic>{};

    for (final key in sortedKeys) {
      normalized[key] = _normalizeValue(
        source[key],
        keyContext: key.toLowerCase(),
      );
    }

    return normalized;
  }

  dynamic _normalizeValue(
    dynamic value, {
    required String keyContext,
  }) {
    if (value is Map<String, dynamic>) {
      return _normalizeMap(value);
    }

    if (value is Map) {
      final casted = <String, dynamic>{};
      for (final entry in value.entries) {
        final key = entry.key.toString();
        casted[key] = _normalizeValue(
          entry.value,
          keyContext: key.toLowerCase(),
        );
      }
      return _normalizeMap(casted);
    }

    if (value is List) {
      return value
          .map((item) => _normalizeValue(
                item,
                keyContext: keyContext,
              ))
          .toList(growable: false);
    }

    if (_shouldHashValue(keyContext, value)) {
      return _toHashedDescriptor(value);
    }

    return value;
  }

  bool _shouldHashValue(String keyContext, dynamic value) {
    final hasSensitiveKey =
        _sensitiveKeyHints.any((hint) => keyContext.contains(hint));
    if (hasSensitiveKey) {
      return true;
    }

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.length < _largeTextThreshold) {
        return false;
      }

      if (trimmed.startsWith('data:image/')) {
        return true;
      }

      if (_looksLikeBase64(trimmed)) {
        return true;
      }
    }

    return false;
  }

  bool _looksLikeBase64(String value) {
    if (value.length < _largeTextThreshold || value.length % 4 != 0) {
      return false;
    }
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/=\s]+$');
    return base64Pattern.hasMatch(value);
  }

  Map<String, dynamic> _toHashedDescriptor(dynamic original) {
    final asText = original is String ? original : jsonEncode(original);
    return {
      '__normalized': 'hashed',
      'sha256_16': sha256Hash(asText),
      'length': asText.length,
    };
  }
}
