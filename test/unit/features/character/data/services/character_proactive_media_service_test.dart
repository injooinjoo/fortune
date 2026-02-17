import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/character/data/services/character_proactive_media_service.dart';
import 'package:fortune/features/character/domain/models/character_chat_message.dart';

void main() {
  group('CharacterProactiveMediaService', () {
    test('non-luts character is always gated out', () async {
      final service = CharacterProactiveMediaService(
        generator: ({
          required String characterId,
          required CharacterMediaCategory category,
          String? contextText,
          String? styleHint,
        }) async {
          return 'https://example.com/generated.png';
        },
      );

      final result = await service.resolveFollowUpMedia(
        characterId: 'seo_yoonjae',
        category: CharacterMediaCategory.meal,
      );

      expect(result, isNull);
    });

    test('uses generated image when fixed image candidates fail', () async {
      var generatorCalled = false;
      final service = CharacterProactiveMediaService(
        fixedImageCandidates: const {
          CharacterMediaCategory.meal: ['assets/images/missing.webp'],
        },
        assetExistsChecker: (_) async => false,
        generator: ({
          required String characterId,
          required CharacterMediaCategory category,
          String? contextText,
          String? styleHint,
        }) async {
          generatorCalled = true;
          return 'https://example.com/generated-meal.png';
        },
      );

      final result = await service.resolveFollowUpMedia(
        characterId: 'luts',
        category: CharacterMediaCategory.meal,
        contextText: '점심 먹는 중',
      );

      expect(generatorCalled, isTrue);
      expect(result, isNotNull);
      expect(result!.imageUrl, 'https://example.com/generated-meal.png');
      expect(result.imageAsset, isNull);
      expect(result.category, CharacterMediaCategory.meal);
    });

    test('keeps fixed image priority over generator', () async {
      var generatorCalled = false;
      final service = CharacterProactiveMediaService(
        fixedImageCandidates: const {
          CharacterMediaCategory.workout: ['assets/images/fixed.webp'],
        },
        assetExistsChecker: (_) async => true,
        generator: ({
          required String characterId,
          required CharacterMediaCategory category,
          String? contextText,
          String? styleHint,
        }) async {
          generatorCalled = true;
          return 'https://example.com/generated-workout.png';
        },
      );

      final result = await service.resolveFollowUpMedia(
        characterId: 'luts',
        category: CharacterMediaCategory.workout,
      );

      expect(result, isNotNull);
      expect(result!.imageAsset, 'assets/images/fixed.webp');
      expect(result.imageUrl, isNull);
      expect(generatorCalled, isFalse);
    });
  });
}
