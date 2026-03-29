import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/core/navigation/fortune_chat_route.dart';
import 'package:fortune/features/character/presentation/providers/character_chat_provider.dart';
import 'package:fortune/features/character/presentation/pages/character_list_panel.dart';

void main() {
  const previewCatalog = ChatCatalogPreview(
    state: ChatCatalogPreviewState.curiosityHome,
  );

  Widget buildSubject({
    ProviderContainer? container,
    ChatCatalogPreview? catalogPreview,
  }) {
    final child = MaterialApp(
      theme: DSTheme.light(),
      darkTheme: DSTheme.dark(),
      home: CharacterListPanel(
        catalogPreview: catalogPreview,
        onCharacterSelected: (_) {},
      ),
    );

    if (container != null) {
      return UncontrolledProviderScope(
        container: container,
        child: child,
      );
    }

    return ProviderScope(child: child);
  }

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('recently chatted character moves to the top of the story list',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final lutsNotifier = container.read(characterChatProvider('luts').notifier);
    final taeYoonNotifier =
        container.read(characterChatProvider('jung_tae_yoon').notifier);
    addTearDown(lutsNotifier.cancelFollowUp);
    addTearDown(taeYoonNotifier.cancelFollowUp);

    lutsNotifier.addUserMessage('먼저 보낸 메시지');
    await tester.pump(const Duration(milliseconds: 1));
    taeYoonNotifier.addUserMessage('가장 최근 메시지');

    await tester.pumpWidget(
      buildSubject(
        container: container,
      ),
    );
    await tester.pumpAndSettle();

    final taeYoonTop = tester.getTopLeft(find.text('정태윤').first).dy;
    final lutsTop = tester.getTopLeft(find.text('러츠').first).dy;

    expect(taeYoonTop, lessThan(lutsTop));
  });

  testWidgets('scrolling the list hides and reveals the top chrome',
      (tester) async {
    await tester.pumpWidget(
      buildSubject(
        catalogPreview: previewCatalog,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    AnimatedAlign chrome() => tester.widget<AnimatedAlign>(
          find.byType(AnimatedAlign).first,
        );

    expect(chrome().heightFactor, 1);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(chrome().heightFactor, 0);

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(chrome().heightFactor, 1);
  });

  testWidgets('shows unread count badge before your turn state',
      (tester) async {
    await tester.pumpWidget(
      buildSubject(
        catalogPreview: previewCatalog,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final unreadBadgeFinder = find.byType(DSBadge).first;
    final unreadBadge = tester.widget<DSBadge>(unreadBadgeFinder);
    final badgeText = tester.widget<Text>(
      find.descendant(of: unreadBadgeFinder, matching: find.text('1')).first,
    );

    expect(unreadBadge.count, 1);
    expect(badgeText.style?.color, DSColors.textPrimary);
    expect(find.text('내 차례'), findsOneWidget);
  });
}
