import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/character/presentation/utils/character_chat_fortune_payload_utils.dart';

void main() {
  group('character chat fortune payload utils', () {
    test('api params include userId without polluting cache params', () {
      final normalizedAnswers = <String, dynamic>{
        'deckId': 'golden_dawn_cicero',
        'spreadType': 'threeCard',
        'selectedCardIndices': [55, 44, 26],
      };
      final userProfile = <String, dynamic>{
        'name': '김인주',
        'mbti': 'ENTJ',
      };

      final params = buildCharacterChatFortuneParams(
        normalizedAnswers: normalizedAnswers,
        userProfile: userProfile,
      );
      final apiParams = buildCharacterChatFortuneApiParams(
        normalizedAnswers: normalizedAnswers,
        userProfile: userProfile,
        userId: 'user-123',
      );

      expect(params['userId'], isNull);
      expect(params['selectedCardIndices'], [55, 44, 26]);

      expect(apiParams['userId'], 'user-123');
      expect(apiParams['name'], '김인주');
      expect(apiParams['selectedCardIndices'], [55, 44, 26]);
    });
  });
}
