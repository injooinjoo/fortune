import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/core/navigation/fortune_chat_route.dart';
import 'package:fortune/features/character/presentation/pages/character_list_panel.dart';

void main() {
  Widget buildSubject() {
    return ProviderScope(
      child: MaterialApp(
        theme: DSTheme.light(),
        darkTheme: DSTheme.dark(),
        home: CharacterListPanel(
          catalogPreview: const ChatCatalogPreview(
            state: ChatCatalogPreviewState.curiosityHome,
          ),
          onCharacterSelected: (_) {},
        ),
      ),
    );
  }

  testWidgets('scrolling the list hides and reveals the top chrome',
      (tester) async {
    await tester.pumpWidget(buildSubject());
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
    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 300));

    final unreadBadgeFinder = find.byType(DSBadge).first;
    final unreadBadge = tester.widget<DSBadge>(unreadBadgeFinder);
    final badgeText = tester.widget<Text>(
      find.descendant(of: unreadBadgeFinder, matching: find.text('1')).first,
    );

    expect(unreadBadge.count, 1);
    expect(badgeText.style?.color, DSColors.ctaForegroundDark);
    expect(find.text('내 차례'), findsOneWidget);
  });
}
