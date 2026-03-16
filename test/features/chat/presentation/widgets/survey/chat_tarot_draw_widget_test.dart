import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/features/chat/presentation/widgets/survey/chat_tarot_draw_widget.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: DSTheme.light(),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('love tarot draw submits relationship spread with 5 cards',
      (tester) async {
    Map<String, dynamic>? payload;

    await tester.pumpWidget(
      _wrap(
        ChatTarotDrawWidget(
          deckId: 'rider_waite',
          purpose: 'love',
          onSubmit: (value) => payload = value,
          random: Random(7),
        ),
      ),
    );

    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byKey(ValueKey('tarot-slot-$i')));
      await tester.pump();
      await tester
          .ensureVisible(find.byKey(const ValueKey('tarot-draw-confirm')));
      await tester.tap(
        find.byKey(const ValueKey('tarot-draw-confirm')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 320));
    }

    expect(payload, isNotNull);
    expect(payload!['spreadType'], 'relationship');
    expect((payload!['selectedCardIndices'] as List).length, 5);
    expect(payload!['cardCount'], 5);
  });

  testWidgets('career tarot draw submits three-card spread with 3 cards',
      (tester) async {
    Map<String, dynamic>? payload;

    await tester.pumpWidget(
      _wrap(
        ChatTarotDrawWidget(
          deckId: 'rider_waite',
          purpose: 'career',
          onSubmit: (value) => payload = value,
          random: Random(11),
        ),
      ),
    );

    await tester.pumpAndSettle();

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(ValueKey('tarot-slot-$i')));
      await tester.pump();
      await tester
          .ensureVisible(find.byKey(const ValueKey('tarot-draw-confirm')));
      await tester.tap(
        find.byKey(const ValueKey('tarot-draw-confirm')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 320));
    }

    expect(payload, isNotNull);
    expect(payload!['spreadType'], 'threeCard');
    expect((payload!['selectedCardIndices'] as List).length, 3);
  });
}
