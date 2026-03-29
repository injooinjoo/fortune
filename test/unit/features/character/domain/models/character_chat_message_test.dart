import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/features/character/domain/models/character_chat_message.dart';

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

    test('toJson/fromJson keeps embedded widget payload', () {
      final original = CharacterChatMessage.character(
        '오늘의 메시지',
        'fortune_haneul',
        embeddedWidgetType: 'fortune_cookie',
        componentData: const {
          'title': '오늘의 메시지',
          'message': '행운이 가까이 있어요.',
          'luckyNumber': '7',
        },
      );

      final json = original.toJson();
      final restored = CharacterChatMessage.fromJson(json);

      expect(restored.embeddedWidgetType, 'fortune_cookie');
      expect(restored.componentData?['message'], '행운이 가까이 있어요.');
      expect(restored.hasEmbeddedWidget, isTrue);
    });
  });

  group('CharacterChatMessage UTF-16 sanitization', () {
    test('preserves valid surrogate pairs', () {
      final validEmoji = String.fromCharCodes(const [0xD83D, 0xDE0A]);

      final message =
          CharacterChatMessage.character(validEmoji, 'fortune_marco');

      expect(message.text, validEmoji);
    });

    test('replaces malformed surrogate code units in constructor input', () {
      final malformed = String.fromCharCodes(const [0xD83D, 0x0041, 0xDE0A]);

      final message =
          CharacterChatMessage.character(malformed, 'fortune_marco');

      expect(message.text, '\uFFFDA\uFFFD');
    });

    test('sanitizes malformed content when loading from json', () {
      final malformed = String.fromCharCodes(const [0xDE0A]);

      final message = CharacterChatMessage.fromJson({
        'id': 'msg-1',
        'type': CharacterChatMessageType.character.name,
        'content': malformed,
        'timestamp': DateTime(2026, 3, 6).toIso8601String(),
        'status': MessageStatus.read.name,
        'origin': MessageOrigin.aiReply.name,
      });

      expect(message.text, '\uFFFD');
    });
  });
}
