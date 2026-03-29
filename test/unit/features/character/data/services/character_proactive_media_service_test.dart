import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/features/character/data/services/character_proactive_media_service.dart';
import 'package:ondo/features/character/domain/models/character_chat_message.dart';

void main() {
  group('CharacterProactiveMediaService', () {
    test('스토리 캐릭터는 갤러리 자산을 우선 사용한다', () async {
      final service = CharacterProactiveMediaService(
        galleryAssetsByCharacterId: const {
          'seo_yoonjae': ['assets/images/character/gallery/seo/seo_1.webp'],
        },
        assetExistsChecker: (_) async => true,
        generator: ({
          required String characterId,
          required CharacterMediaCategory category,
          String? contextText,
          String? styleHint,
          String? timeSlot,
          String? weatherHint,
          String? locationHint,
        }) async {
          return 'https://example.com/generated.png';
        },
      );

      final result = await service.resolveFollowUpMedia(
        characterId: 'seo_yoonjae',
        category: CharacterMediaCategory.selfie,
      );

      expect(result, isNotNull);
      expect(
          result!.imageAsset, 'assets/images/character/gallery/seo/seo_1.webp');
      expect(result.imageUrl, isNull);
    });

    test('지원되지 않는 캐릭터는 미디어를 붙이지 않는다', () async {
      final service = CharacterProactiveMediaService(
        generator: ({
          required String characterId,
          required CharacterMediaCategory category,
          String? contextText,
          String? styleHint,
          String? timeSlot,
          String? weatherHint,
          String? locationHint,
        }) async {
          return 'https://example.com/generated.png';
        },
      );

      final result = await service.resolveFollowUpMedia(
        characterId: 'unknown_character',
        category: CharacterMediaCategory.meal,
      );

      expect(result, isNull);
    });

    test('정적 자산이 없으면 생성형 fallback을 사용한다', () async {
      var generatorCalled = false;
      final service = CharacterProactiveMediaService(
        galleryAssetsByCharacterId: const {
          'luts': ['assets/images/missing.webp'],
        },
        assetExistsChecker: (_) async => false,
        generator: ({
          required String characterId,
          required CharacterMediaCategory category,
          String? contextText,
          String? styleHint,
          String? timeSlot,
          String? weatherHint,
          String? locationHint,
        }) async {
          generatorCalled = true;
          return 'https://example.com/generated-meal.png';
        },
      );

      final result = await service.resolveFollowUpMedia(
        characterId: 'luts',
        category: CharacterMediaCategory.meal,
        contextText: '점심 먹는 중',
        timeSlot: 'lunch',
        weatherHint: '서울 맑음',
        locationHint: '서울 강남구',
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
        galleryAssetsByCharacterId: const {
          'luts': ['assets/images/gallery-fallback.webp'],
        },
        assetExistsChecker: (_) async => true,
        generator: ({
          required String characterId,
          required CharacterMediaCategory category,
          String? contextText,
          String? styleHint,
          String? timeSlot,
          String? weatherHint,
          String? locationHint,
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

    test('정적 자산과 생성형 모두 실패하면 null을 반환한다', () async {
      final service = CharacterProactiveMediaService(
        galleryAssetsByCharacterId: const {
          'luts': ['assets/images/missing.webp'],
        },
        assetExistsChecker: (_) async => false,
        generator: ({
          required String characterId,
          required CharacterMediaCategory category,
          String? contextText,
          String? styleHint,
          String? timeSlot,
          String? weatherHint,
          String? locationHint,
        }) async {
          return null;
        },
      );

      final result = await service.resolveFollowUpMedia(
        characterId: 'luts',
        category: CharacterMediaCategory.night,
      );

      expect(result, isNull);
    });
  });
}
