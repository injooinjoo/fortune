import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ondo/core/design_system/design_system.dart';
import 'package:ondo/core/navigation/fortune_chat_route.dart';
import 'package:ondo/features/character/presentation/providers/character_chat_provider.dart';
import 'package:ondo/features/character/presentation/pages/character_list_panel.dart';

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

    final taeYoonTop = tester.getTopLeft(find.text('가장 최근 메시지')).dy;
    final lutsTop = tester.getTopLeft(find.text('먼저 보낸 메시지')).dy;

    expect(taeYoonTop, lessThan(lutsTop));
  });

  testWidgets('scrolling the list keeps the top chrome visible',
      (tester) async {
    await tester.pumpWidget(
      buildSubject(
        catalogPreview: previewCatalog,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final titleFinder = find.text('메시지');
    final composeButtonFinder = find.byIcon(Icons.edit_note_outlined);

    expect(titleFinder, findsOneWidget);
    expect(composeButtonFinder, findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(titleFinder, findsOneWidget);
    expect(composeButtonFinder, findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(titleFinder, findsOneWidget);
    expect(composeButtonFinder, findsOneWidget);
  });

  testWidgets('applies stronger typography to unread conversation rows',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final taeYoonNotifier =
        container.read(characterChatProvider('jung_tae_yoon').notifier);
    addTearDown(taeYoonNotifier.cancelFollowUp);

    taeYoonNotifier.addCharacterMessage(
      '안 읽은 메시지입니다',
      suppressNotification: true,
      scheduleReadIdleIcebreaker: false,
    );

    await tester.pumpWidget(
      buildSubject(
        container: container,
      ),
    );
    await tester.pumpAndSettle();

    final nameTexts = tester.widgetList<Text>(find.text('정태윤')).toList();
    final previewText = tester.widget<Text>(find.text('안 읽은 메시지입니다'));

    expect(
      nameTexts.any((text) => text.style?.fontWeight == FontWeight.w800),
      isTrue,
    );
    expect(previewText.style?.fontWeight, FontWeight.w600);
  });

  testWidgets('keeps your turn badge on stronger label typography',
      (tester) async {
    await tester.pumpWidget(
      buildSubject(
        catalogPreview: previewCatalog,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final badgeText = tester.widget<Text>(find.text('내 차례'));

    expect(badgeText.style?.fontSize, DSTypography.labelSmall.fontSize);
    expect(badgeText.style?.fontWeight, FontWeight.w700);
    expect(badgeText.style?.color, DSColors.ctaBackground);
    expect(find.text('내 차례'), findsOneWidget);
  });
}
