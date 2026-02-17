import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/character/data/services/character_proactive_context_service.dart';
import 'package:fortune/features/character/domain/models/character_chat_message.dart';

void main() {
  group('CharacterProactiveContextService', () {
    final service = CharacterProactiveContextService();

    test('meal context requires keyword and meal time', () {
      final result = service.resolve(
        messages: [
          CharacterChatMessage.user('점심 뭐 먹을지 고민 중이에요'),
        ],
        now: DateTime(2026, 2, 17, 12, 15),
      );

      expect(result, isNotNull);
      expect(result!.category, CharacterMediaCategory.meal);
    });

    test('workout context requires keyword and workout time', () {
      final result = service.resolve(
        messages: [
          CharacterChatMessage.user('오늘 헬스장 가서 운동 마쳤어요'),
        ],
        now: DateTime(2026, 2, 17, 19, 10),
      );

      expect(result, isNotNull);
      expect(result!.category, CharacterMediaCategory.workout);
    });

    test('keyword alone without matching time does not trigger', () {
      final result = service.resolve(
        messages: [
          CharacterChatMessage.user('점심은 먹었는데 아직 안 자요'),
        ],
        now: DateTime(2026, 2, 17, 2, 5),
      );

      expect(result, isNull);
    });

    test('matching time alone without keyword does not trigger', () {
      final result = service.resolve(
        messages: [
          CharacterChatMessage.user('오늘 일정이 많네요'),
        ],
        now: DateTime(2026, 2, 17, 12, 30),
      );

      expect(result, isNull);
    });
  });
}
