import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/character/data/services/character_proactive_context_service.dart';
import 'package:fortune/features/character/domain/models/character_chat_message.dart';

void main() {
  group('CharacterProactiveContextService', () {
    final service = CharacterProactiveContextService();

    test('점심 시간의 식사 키워드는 meal로 분류한다', () {
      final result = service.resolve(
        messages: [
          CharacterChatMessage.user('점심 뭐 먹을지 고민 중이에요'),
        ],
        now: DateTime(2026, 2, 17, 12, 15),
      );

      expect(result, isNotNull);
      expect(result!.category, CharacterMediaCategory.meal);
      expect(result.timeSlot, 'lunch');
    });

    test('저녁 운동 키워드는 workout으로 분류한다', () {
      final result = service.resolve(
        messages: [
          CharacterChatMessage.user('오늘 헬스장 가서 운동 마쳤어요'),
        ],
        now: DateTime(2026, 2, 17, 19, 10),
      );

      expect(result, isNotNull);
      expect(result!.category, CharacterMediaCategory.workout);
    });

    test('출근 키워드와 아침 시간대는 commute로 분류한다', () {
      final result = service.resolve(
        messages: [
          CharacterChatMessage.user('아침부터 지하철이 너무 붐벼요'),
        ],
        now: DateTime(2026, 2, 17, 8, 5),
      );

      expect(result, isNotNull);
      expect(result!.category, CharacterMediaCategory.commute);
      expect(result.timeSlot, 'morning');
    });

    test('늦은 밤에는 관련 키워드가 있으면 night로 분류한다', () {
      final result = service.resolve(
        messages: [
          CharacterChatMessage.user('오늘은 늦게까지 안 자고 있었어요'),
        ],
        now: DateTime(2026, 2, 17, 23, 30),
      );

      expect(result, isNotNull);
      expect(result!.category, CharacterMediaCategory.night);
      expect(result.timeSlot, 'night');
    });

    test('키워드가 없어도 최근 맥락이 있으면 time-only fallback으로 동작한다', () {
      final result = service.resolve(
        messages: [
          CharacterChatMessage.user('오늘 일정이 많네요'),
        ],
        now: DateTime(2026, 2, 17, 15, 30),
      );

      expect(result, isNotNull);
      expect(result!.category, CharacterMediaCategory.cafe);
      expect(result.timeSlot, 'afternoon');
    });
  });
}
