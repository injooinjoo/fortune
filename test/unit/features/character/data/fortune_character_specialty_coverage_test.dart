import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/core/fortune/fortune_type_registry.dart';
import 'package:ondo/features/character/data/fortune_characters.dart';

void main() {
  group('fortune character specialty coverage', () {
    test('every fortune expert specialty is registered', () {
      for (final character in fortuneCharacters) {
        expect(
          character.isFortuneExpert,
          isTrue,
          reason: '${character.name} should be a fortune expert',
        );
        expect(
          character.specialties,
          isNotEmpty,
          reason: '${character.name} should expose at least one specialty',
        );

        for (final specialty in character.specialties) {
          expect(
            FortuneTypeRegistry.contains(specialty),
            isTrue,
            reason:
                '${character.name} specialty "$specialty" must exist in the registry',
          );
          if (!FortuneTypeRegistry.isLocalOnly(specialty)) {
            expect(
              FortuneTypeRegistry.endpointOf(specialty),
              isNotNull,
              reason:
                  '${character.name} specialty "$specialty" must resolve to an endpoint',
            );
          }
        }
      }
    });

    test('character specialty categories remain stable', () {
      final categoryByCharacter = <String, String>{
        haneulCharacter.id: 'lifestyle',
        muhyeonCharacter.id: 'traditional',
        stellaCharacter.id: 'zodiac',
        drMindCharacter.id: 'personality',
        roseCharacter.id: 'love',
        jamesKimCharacter.id: 'career',
        luckyCharacter.id: 'lucky',
        marcoCharacter.id: 'sports',
        linaCharacter.id: 'fengshui',
        lunaCharacter.id: 'special',
      };

      for (final character in fortuneCharacters) {
        expect(
          character.specialtyCategory,
          categoryByCharacter[character.id],
          reason: '${character.name} specialty category changed unexpectedly',
        );
      }
    });
  });
}
