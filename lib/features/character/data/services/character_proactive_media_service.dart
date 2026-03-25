import 'dart:math';

import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/logger.dart';
import '../default_characters.dart';
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
  String? timeSlot,
  String? weatherHint,
  String? locationHint,
});

/// proactive follow-up 이미지 결정 서비스
/// 1) 고정 이미지 우선 2) 실패 시 생성 함수 fallback
class CharacterProactiveMediaService {
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

  static final Set<String> _supportedCharacterIds = {
    for (final character in defaultCharacters)
      if (!character.isFortuneExpert) character.id,
  };

  static final Map<String, List<String>> _defaultGalleryAssetsByCharacterId = {
    for (final character in defaultCharacters)
      if (!character.isFortuneExpert && character.galleryAssets.isNotEmpty)
        character.id: List<String>.unmodifiable(character.galleryAssets),
  };

  final SupabaseClient? _supabase;
  final Random _random;
  final CharacterProactiveImageGenerator? _generator;
  final Map<CharacterMediaCategory, List<String>> _fixedImageCandidates;
  final Map<String, List<String>> _galleryAssetsByCharacterId;
  final Future<bool> Function(String assetPath)? _assetExistsChecker;

  CharacterProactiveMediaService({
    SupabaseClient? supabase,
    Random? random,
    CharacterProactiveImageGenerator? generator,
    Map<CharacterMediaCategory, List<String>>? fixedImageCandidates,
    Map<String, List<String>>? galleryAssetsByCharacterId,
    Future<bool> Function(String assetPath)? assetExistsChecker,
  })  : _supabase = supabase,
        _random = random ?? Random(),
        _generator = generator,
        _fixedImageCandidates =
            fixedImageCandidates ?? _defaultLutsFixedCandidates,
        _galleryAssetsByCharacterId =
            galleryAssetsByCharacterId ?? _defaultGalleryAssetsByCharacterId,
        _assetExistsChecker = assetExistsChecker;

  Future<CharacterProactiveMediaResult?> resolveFollowUpMedia({
    required String characterId,
    required CharacterMediaCategory category,
    String? contextText,
    String? styleHint,
    String? timeSlot,
    String? weatherHint,
    String? locationHint,
  }) async {
    if (!_supportedCharacterIds.contains(characterId)) {
      return null;
    }

    final staticAsset = await _pickStaticAsset(
      characterId: characterId,
      category: category,
    );
    if (staticAsset != null) {
      return CharacterProactiveMediaResult(
        category: category,
        imageAsset: staticAsset,
      );
    }

    final generatedImageUrl = await _generateWithFallback(
      characterId: characterId,
      category: category,
      contextText: contextText,
      styleHint: styleHint,
      timeSlot: timeSlot,
      weatherHint: weatherHint,
      locationHint: locationHint,
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
    String? timeSlot,
    String? weatherHint,
    String? locationHint,
  }) async {
    final generator = _generator;
    if (generator != null) {
      return generator(
        characterId: characterId,
        category: category,
        contextText: contextText,
        styleHint: styleHint,
        timeSlot: timeSlot,
        weatherHint: weatherHint,
        locationHint: locationHint,
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
          if (timeSlot != null && timeSlot.isNotEmpty) 'timeSlot': timeSlot,
          if (weatherHint != null && weatherHint.isNotEmpty)
            'weatherHint': weatherHint,
          if (locationHint != null && locationHint.isNotEmpty)
            'locationHint': locationHint,
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

  Future<String?> _pickStaticAsset({
    required String characterId,
    required CharacterMediaCategory category,
  }) async {
    final fixedCandidates = _fixedImageCandidates[category] ?? const <String>[];
    final galleryCandidates = _galleryCandidatesFor(
      category,
      _galleryAssetsByCharacterId[characterId] ?? const <String>[],
    );

    for (final candidates in [fixedCandidates, galleryCandidates]) {
      final staticAsset = await _pickExistingAsset(candidates);
      if (staticAsset != null) {
        return staticAsset;
      }
    }

    return null;
  }

  Future<String?> _pickExistingAsset(List<String> candidates) async {
    if (candidates.isEmpty) {
      return null;
    }

    final deduped = <String>[];
    final seen = <String>{};
    for (final assetPath in candidates) {
      if (assetPath.isEmpty || !seen.add(assetPath)) {
        continue;
      }
      deduped.add(assetPath);
    }

    final shuffled = List<String>.from(deduped)..shuffle(_random);
    for (final assetPath in shuffled) {
      final exists = await _assetExists(assetPath);
      if (exists) {
        return assetPath;
      }
    }

    return null;
  }

  List<String> _galleryCandidatesFor(
    CharacterMediaCategory category,
    List<String> galleryAssets,
  ) {
    if (galleryAssets.isEmpty || galleryAssets.length <= 3) {
      return galleryAssets;
    }

    final trailingWindow = min(4, galleryAssets.length);
    final head = galleryAssets.take(trailingWindow).toList();
    final middleStart = min(2, galleryAssets.length);
    final middle =
        galleryAssets.skip(middleStart).take(trailingWindow).toList();
    final tail = galleryAssets
        .skip(max(0, galleryAssets.length - trailingWindow))
        .toList();

    switch (category) {
      case CharacterMediaCategory.selfie:
        return galleryAssets;
      case CharacterMediaCategory.meal:
      case CharacterMediaCategory.cafe:
        return [...head, ...tail];
      case CharacterMediaCategory.commute:
        return [...middle, ...head, ...tail];
      case CharacterMediaCategory.workout:
      case CharacterMediaCategory.night:
        return [...tail, ...galleryAssets.reversed];
    }
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
      case CharacterMediaCategory.selfie:
        return 'selfie';
      case CharacterMediaCategory.meal:
        return 'meal';
      case CharacterMediaCategory.cafe:
        return 'cafe';
      case CharacterMediaCategory.commute:
        return 'commute';
      case CharacterMediaCategory.workout:
        return 'workout';
      case CharacterMediaCategory.night:
        return 'night';
    }
  }
}
