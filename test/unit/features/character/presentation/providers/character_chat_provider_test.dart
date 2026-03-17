import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/features/character/domain/models/character_affinity.dart';
import 'package:fortune/features/character/domain/models/character_chat_message.dart';
import 'package:fortune/features/character/presentation/providers/active_chat_provider.dart';
import 'package:fortune/features/character/presentation/providers/character_chat_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'test-anon-key',
    );
  });

  group('CharacterChatNotifier read/unread regression', () {
    test('markPendingUserMessagesAsRead marks all pending user messages', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(characterChatProvider('luts').notifier);
      addTearDown(notifier.cancelFollowUp);

      notifier.addUserMessage('안녕하세요');
      notifier.addUserMessage('김민주라고 합니다');

      final before = container.read(characterChatProvider('luts'));
      final sentUsersBefore = before.messages.where((message) {
        return message.type == CharacterChatMessageType.user &&
            message.status == MessageStatus.sent;
      }).length;
      expect(sentUsersBefore, 2);

      notifier.markPendingUserMessagesAsRead();

      final after = container.read(characterChatProvider('luts'));
      final sentUsersAfter = after.messages.where((message) {
        return message.type == CharacterChatMessageType.user &&
            message.status == MessageStatus.sent;
      }).length;
      final readUsersAfter = after.messages.where((message) {
        return message.type == CharacterChatMessageType.user &&
            message.status == MessageStatus.read;
      }).length;

      expect(sentUsersAfter, 0);
      expect(readUsersAfter, 2);
    });

    test('active chat does not increment unreadCount for character message',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(activeCharacterChatProvider.notifier).state = 'luts';
      final notifier = container.read(characterChatProvider('luts').notifier);
      addTearDown(notifier.cancelFollowUp);

      notifier.addCharacterMessage(
        '반가워요.',
        scheduleReadIdleIcebreaker: false,
      );
      notifier.cancelFollowUp();

      final activeState = container.read(characterChatProvider('luts'));
      expect(activeState.unreadCount, 0);

      container.read(activeCharacterChatProvider.notifier).state = null;
      notifier.addCharacterMessage(
        '혹시 지금 시간 괜찮으세요?',
        scheduleReadIdleIcebreaker: false,
      );
      notifier.cancelFollowUp();

      final inactiveState = container.read(characterChatProvider('luts'));
      expect(inactiveState.unreadCount, 1);
    });

    test(
        'startFreshFortuneSession archives previous timeline and preserves affinity',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(activeCharacterChatProvider.notifier).state = 'luts';
      final notifier = container.read(characterChatProvider('luts').notifier);
      addTearDown(notifier.cancelFollowUp);

      notifier.setAffinity(
        const CharacterAffinity(
          lovePoints: 320,
          phase: AffinityPhase.friend,
        ),
      );
      notifier.addCharacterMessage(
        '이전 캐릭터 메시지',
        scheduleReadIdleIcebreaker: false,
      );
      notifier.addUserMessage('이전 사용자 메시지');

      final anchorId = notifier.startFreshFortuneSession(
        introMessage: '좋아요. 오늘 흐름을 빠르게 정리해볼게요.',
        requestMessage: '오늘 하루 흐름이 궁금해요.',
      );

      final state = container.read(characterChatProvider('luts'));
      expect(state.messages, hasLength(2));
      expect(state.archivedMessages, hasLength(2));
      expect(state.archivedMessages.first.text, '이전 캐릭터 메시지');
      expect(state.archivedMessages.last.text, '이전 사용자 메시지');
      expect(state.messages.first.text, '좋아요. 오늘 흐름을 빠르게 정리해볼게요.');
      expect(state.messages.last.text, '오늘 하루 흐름이 궁금해요.');
      expect(state.messages.last.type, CharacterChatMessageType.user);
      expect(state.messages.last.id, anchorId);
      expect(state.persistedMessages, hasLength(4));
      expect(state.affinity.lovePoints, 320);
      expect(state.affinity.phase, AffinityPhase.friend);
    });

    test('startFreshUserSessionIfNeeded keeps opening only for fresh thread',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(activeCharacterChatProvider.notifier).state = 'luts';
      final notifier = container.read(characterChatProvider('luts').notifier);
      addTearDown(notifier.cancelFollowUp);

      notifier.startConversation();
      final openingText =
          container.read(characterChatProvider('luts')).messages.first.text;

      final anchorId = notifier.startFreshUserSessionIfNeeded('안녕하세요');

      final state = container.read(characterChatProvider('luts'));
      expect(anchorId, isNotNull);
      expect(state.messages, hasLength(2));
      expect(state.messages.first.text, openingText);
      expect(state.messages.last.text, '안녕하세요');
      expect(state.messages.last.id, anchorId);
    });

    test('startFreshUserSessionIfNeeded does not reset ongoing conversation',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(activeCharacterChatProvider.notifier).state = 'luts';
      final notifier = container.read(characterChatProvider('luts').notifier);
      addTearDown(notifier.cancelFollowUp);

      notifier.startConversation();
      notifier.addUserMessage('첫 질문');
      notifier.addCharacterMessage(
        '첫 답변',
        scheduleReadIdleIcebreaker: false,
      );

      final before = container.read(characterChatProvider('luts'));
      final anchorId = notifier.startFreshUserSessionIfNeeded('두 번째 질문');
      final after = container.read(characterChatProvider('luts'));

      expect(anchorId, isNull);
      expect(after.messages.length, before.messages.length);
      expect(after.messages.last.text, '첫 답변');
    });

    testWidgets(
        'idle icebreaker is not scheduled from follow-up/proactive anchor',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(activeCharacterChatProvider.notifier).state = 'luts';
      final notifier = container.read(characterChatProvider('luts').notifier);
      addTearDown(notifier.cancelFollowUp);

      notifier.addCharacterMessage(
        '반가워요.',
        origin: MessageOrigin.followUp,
      );
      notifier.cancelFollowUp();
      final afterFollowUp =
          container.read(characterChatProvider('luts')).messages.length;

      await tester.pump(const Duration(seconds: 11));
      final afterDelayFromFollowUp =
          container.read(characterChatProvider('luts')).messages.length;
      expect(afterDelayFromFollowUp, afterFollowUp);

      notifier.addProactiveMessage(
        CharacterChatMessage.characterWithImage(
          '점심 잘 챙겨 드세요.',
          'luts',
          imageAsset: 'assets/images/sample.png',
          origin: MessageOrigin.proactive,
        ),
      );
      final afterProactive =
          container.read(characterChatProvider('luts')).messages.length;

      await tester.pump(const Duration(seconds: 11));
      final afterDelayFromProactive =
          container.read(characterChatProvider('luts')).messages.length;
      expect(afterDelayFromProactive, afterProactive);
    });
  });

  group('Haneul card-first fortune flow', () {
    test('uses compact card-first flow for Haneul daily variants', () {
      expect(
        isHaneulCardFirstFortuneFlow(
          characterId: 'fortune_haneul',
          fortuneType: 'daily',
        ),
        isTrue,
      );
      expect(
        isHaneulCardFirstFortuneFlow(
          characterId: 'fortune_haneul',
          fortuneType: 'daily-calendar',
        ),
        isTrue,
      );
      expect(
        isHaneulCardFirstFortuneFlow(
          characterId: 'fortune_haneul',
          fortuneType: 'new-year',
        ),
        isTrue,
      );
      expect(
        isHaneulCardFirstFortuneFlow(
          characterId: 'fortune_haneul',
          fortuneType: 'fortune-cookie',
        ),
        isTrue,
      );
    });

    test('keeps legacy split flow outside the Haneul whitelist', () {
      expect(
        isHaneulCardFirstFortuneFlow(
          characterId: 'fortune_haneul',
          fortuneType: 'tarot',
        ),
        isFalse,
      );
      expect(
        isHaneulCardFirstFortuneFlow(
          characterId: 'fortune_love',
          fortuneType: 'daily',
        ),
        isFalse,
      );
    });
  });
}
