import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fortune/features/character/domain/models/character_choice.dart';
import 'package:fortune/features/character/presentation/utils/pending_chat_auth_intent.dart';

void main() {
  group('PendingChatAuthIntent', () {
    test('serializes and deserializes choice selection intent', () {
      const choice = CharacterChoice(
        id: 'choice-1',
        text: '안녕',
        affinityChange: 1,
        type: ChoiceType.positive,
      );
      final intent = PendingChatAuthIntent.choiceSelection(
        characterId: 'character-1',
        choice: choice,
      );

      final restored = PendingChatAuthIntent.fromJson(intent.toJson());

      expect(restored.type, PendingChatAuthIntentType.choiceSelection);
      expect(restored.characterId, 'character-1');
      expect(restored.choice?.id, 'choice-1');
      expect(restored.choice?.text, '안녕');
    });

    test('builds resume route with fortune type', () {
      final intent = PendingChatAuthIntent.fortuneRequest(
        characterId: 'haneul',
        fortuneType: 'daily',
      );

      expect(
        intent.buildResumeRoute(),
        '/chat?openCharacterChat=true&characterId=haneul&entrySource=auth-resume&fortuneType=daily',
      );
    });

    test('tracks image picker target and expiry state', () {
      final freshIntent = PendingChatAuthIntent.openImagePicker(
        characterId: 'character-2',
        fortuneType: 'face-reading',
        target: PendingChatImagePickerTarget.surveyFaceReading,
        imageSource: ImageSource.camera,
      );
      final expiredIntent = PendingChatAuthIntent(
        type: PendingChatAuthIntentType.textMessage,
        characterId: 'character-3',
        text: 'hello',
        createdAt: DateTime.now().subtract(const Duration(minutes: 11)),
      );

      expect(
        freshIntent.imagePickerTarget,
        PendingChatImagePickerTarget.surveyFaceReading,
      );
      expect(freshIntent.imageSource, ImageSource.camera);
      expect(expiredIntent.isExpired, isTrue);
    });
  });
}
