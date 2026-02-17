import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/character/domain/models/character_chat_message.dart';

void main() {
  group('CharacterChatMessage serialization', () {
    test('toJson/fromJson keeps imageUrl and mediaCategory', () {
      final original = CharacterChatMessage.character(
        '오늘 운동 끝냈어요!',
        'luts',
        imageUrl: 'https://example.com/workout.png',
        mediaCategory: CharacterMediaCategory.workout,
        origin: MessageOrigin.followUp,
      );

      final json = original.toJson();
      final restored = CharacterChatMessage.fromJson(json);

      expect(restored.imageUrl, 'https://example.com/workout.png');
      expect(restored.mediaCategory, CharacterMediaCategory.workout);
      expect(restored.hasImage, isTrue);
      expect(restored.origin, MessageOrigin.followUp);
    });

    test('fromJson keeps null media fields when absent', () {
      final restored = CharacterChatMessage.fromJson({
        'id': 'test-id',
        'type': 'character',
        'content': '텍스트만',
        'timestamp': DateTime(2026, 2, 17, 12).toIso8601String(),
        'status': 'read',
        'origin': 'aiReply',
        'characterId': 'luts',
      });

      expect(restored.imageUrl, isNull);
      expect(restored.mediaCategory, isNull);
      expect(restored.hasImage, isFalse);
    });
  });
}
