import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}
