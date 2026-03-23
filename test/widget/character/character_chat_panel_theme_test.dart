import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/core/navigation/fortune_chat_route.dart';
import 'package:fortune/features/character/data/fortune_characters.dart';
import 'package:fortune/features/character/presentation/pages/character_chat_panel.dart';
import 'package:fortune/features/character/presentation/providers/character_chat_provider.dart';

void main() {
  Widget buildSubject(
    CharacterChatPanel panel, {
    ProviderContainer? container,
  }) {
    final child = MaterialApp(
      theme: DSTheme.light(),
      darkTheme: DSTheme.dark(),
      home: Scaffold(body: panel),
    );

    if (container != null) {
      return UncontrolledProviderScope(
        container: container,
        child: child,
      );
    }

    return ProviderScope(child: child);
  }

  ProviderContainer createContainer() {
    final container = ProviderContainer();
    final notifier =
        container.read(characterChatProvider(haneulCharacter.id).notifier);
    addTearDown(notifier.cancelFollowUp);
    addTearDown(container.dispose);
    return container;
  }

  void cancelFollowUp(ProviderContainer container) {
    container
        .read(characterChatProvider(haneulCharacter.id).notifier)
        .cancelFollowUp();
  }

  testWidgets('seeds the preview theme from the catalog fortune type',
      (tester) async {
    final container = createContainer();

    await tester.pumpWidget(
      buildSubject(
        const CharacterChatPanel(
          character: haneulCharacter,
          catalogPreview: ChatCatalogPreview(
            state: ChatCatalogPreviewState.curiosityResult,
            fortuneType: 'daily',
          ),
        ),
        container: container,
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('character-chat-theme-fortune_haneul:daily')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('character-chat-theme-switcher')),
      findsOneWidget,
    );

    cancelFollowUp(container);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('tapping a chip switches the background immediately and keeps it',
      (tester) async {
    final container = createContainer();

    await tester.pumpWidget(
      buildSubject(
        const CharacterChatPanel(
          character: haneulCharacter,
          catalogPreview: ChatCatalogPreview(
            state: ChatCatalogPreviewState.curiosityResult,
            fortuneType: 'daily',
          ),
        ),
        container: container,
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.textContaining('새해 인사이트'));
    await tester.tap(find.textContaining('새해 인사이트'));
    await tester.pump();

    expect(
      find.byKey(
        const ValueKey('character-chat-theme-fortune_haneul:new-year'),
      ),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 700));

    expect(
      find.byKey(
        const ValueKey('character-chat-theme-fortune_haneul:new-year'),
      ),
      findsOneWidget,
    );

    cancelFollowUp(container);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('seeds the session theme from initial fortune type on entry',
      (tester) async {
    final container = createContainer();

    await tester.pumpWidget(
      buildSubject(
        const CharacterChatPanel(
          character: haneulCharacter,
          initialFortuneType: 'daily',
        ),
        container: container,
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('character-chat-theme-fortune_haneul:daily')),
      findsOneWidget,
    );
  });

  testWidgets('reopening the panel resets the previous session theme',
      (tester) async {
    final container = createContainer();

    Future<void> pumpPreview() async {
      await tester.pumpWidget(
        buildSubject(
          const CharacterChatPanel(
            character: haneulCharacter,
            catalogPreview: ChatCatalogPreview(
              state: ChatCatalogPreviewState.curiosityResult,
              fortuneType: 'daily',
            ),
          ),
          container: container,
        ),
      );
      await tester.pump();
    }

    await pumpPreview();
    await tester.ensureVisible(find.textContaining('새해 인사이트'));
    await tester.tap(find.textContaining('새해 인사이트'));
    await tester.pump();

    expect(
      find.byKey(
        const ValueKey('character-chat-theme-fortune_haneul:new-year'),
      ),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 700));
    cancelFollowUp(container);
    await tester.pump();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
    await pumpPreview();

    expect(
      find.byKey(const ValueKey('character-chat-theme-fortune_haneul:daily')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('character-chat-theme-fortune_haneul:new-year'),
      ),
      findsNothing,
    );

    cancelFollowUp(container);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });
}
