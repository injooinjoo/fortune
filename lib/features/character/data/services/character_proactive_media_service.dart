import 'dart:math';

import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/models/character_chat_message.dart';

class CharacterProactiveMediaResult {
  final CharacterMediaCategory category;
  final String? imageAsset;
  final String? imageUrl;

  const CharacterProactiveMediaResult({
    required this.category,
    this.imageAsset,
    this.imageUrl,
  });
}

typedef CharacterProactiveImageGenerator = Future<String?> Function({
  required String characterId,
  required CharacterMediaCategory category,
  String? contextText,
  String? styleHint,
});

/// proactive follow-up 이미지 결정 서비스
/// 1) 고정 이미지 우선 2) 실패 시 생성 함수 fallback
class CharacterProactiveMediaService {
  static const String _supportedCharacterId = 'luts';

  static const Map<CharacterMediaCategory, List<String>>
      _defaultLutsFixedCandidates = {
    CharacterMediaCategory.meal: [
      'assets/images/character/gallery/luts/luts_1.webp',
      'assets/images/character/gallery/luts/luts_2.webp',
      'assets/images/character/gallery/luts/luts_3.webp',
      'assets/images/character/gallery/luts/luts_4.webp',
      'assets/images/character/gallery/luts/luts_5.webp',
    ],
    CharacterMediaCategory.workout: [
      'assets/images/character/gallery/luts/luts_6.webp',
      'assets/images/character/gallery/luts/luts_7.webp',
      'assets/images/character/gallery/luts/luts_8.webp',
      'assets/images/character/gallery/luts/luts_9.webp',
    ],
  };

  final SupabaseClient? _supabase;
  final Random _random;
  final CharacterProactiveImageGenerator? _generator;
  final Map<CharacterMediaCategory, List<String>> _fixedImageCandidates;
  final Future<bool> Function(String assetPath)? _assetExistsChecker;

  CharacterProactiveMediaService({
    SupabaseClient? supabase,
    Random? random,
    CharacterProactiveImageGenerator? generator,
    Map<CharacterMediaCategory, List<String>>? fixedImageCandidates,
    Future<bool> Function(String assetPath)? assetExistsChecker,
  })  : _supabase = supabase,
        _random = random ?? Random(),
        _generator = generator,
        _fixedImageCandidates =
            fixedImageCandidates ?? _defaultLutsFixedCandidates,
        _assetExistsChecker = assetExistsChecker;

  Future<CharacterProactiveMediaResult?> resolveFollowUpMedia({
    required String characterId,
    required CharacterMediaCategory category,
    String? contextText,
    String? styleHint,
  }) async {
    if (characterId != _supportedCharacterId) {
      return null;
    }

    final fixedAsset = await _pickFixedAsset(category);
    if (fixedAsset != null) {
      return CharacterProactiveMediaResult(
        category: category,
        imageAsset: fixedAsset,
      );
    }

    final generatedImageUrl = await _generateWithFallback(
      characterId: characterId,
      category: category,
      contextText: contextText,
      styleHint: styleHint,
    );

    if (generatedImageUrl == null || generatedImageUrl.isEmpty) {
      return null;
    }

    return CharacterProactiveMediaResult(
      category: category,
      imageUrl: generatedImageUrl,
    );
  }

  Future<String?> _generateWithFallback({
    required String characterId,
    required CharacterMediaCategory category,
    String? contextText,
    String? styleHint,
  }) async {
    final generator = _generator;
    if (generator != null) {
      return generator(
        characterId: characterId,
        category: category,
        contextText: contextText,
        styleHint: styleHint,
      );
    }

    try {
      final supabase = _supabase ?? Supabase.instance.client;
      final response = await supabase.functions.invoke(
        'generate-character-proactive-image',
        body: {
          'characterId': characterId,
          'category': _categoryToWireValue(category),
          if (contextText != null && contextText.isNotEmpty)
            'contextText': contextText,
          if (styleHint != null && styleHint.isNotEmpty) 'styleHint': styleHint,
        },
      );

      if (response.status != 200) {
        Logger.warning(
          '[CharacterProactiveMedia] image generation request failed: ${response.status}',
        );
        return null;
      }

      final data = response.data as Map<String, dynamic>?;
      if (data == null || data['success'] != true) {
        Logger.warning(
          '[CharacterProactiveMedia] image generation response invalid',
          {'response': response.data},
        );
        return null;
      }

      final imageUrl = data['imageUrl'] as String?;
      if (imageUrl == null || imageUrl.isEmpty) {
        return null;
      }

      return imageUrl;
    } catch (error) {
      Logger.warning('[CharacterProactiveMedia] image generation error', {
        'error': error.toString(),
      });
      return null;
    }
  }

  Future<String?> _pickFixedAsset(CharacterMediaCategory category) async {
    final candidates = _fixedImageCandidates[category] ?? const <String>[];
    if (candidates.isEmpty) {
      return null;
    }

    final shuffled = List<String>.from(candidates)..shuffle(_random);
    for (final assetPath in shuffled) {
      final exists = await _assetExists(assetPath);
      if (exists) {
        return assetPath;
      }
    }

    return null;
  }

  Future<bool> _assetExists(String assetPath) async {
    final assetExistsChecker = _assetExistsChecker;
    if (assetExistsChecker != null) {
      return assetExistsChecker(assetPath);
    }

    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  String _categoryToWireValue(CharacterMediaCategory category) {
    switch (category) {
      case CharacterMediaCategory.meal:
        return 'meal';
      case CharacterMediaCategory.workout:
        return 'workout';
    }
  }
}
