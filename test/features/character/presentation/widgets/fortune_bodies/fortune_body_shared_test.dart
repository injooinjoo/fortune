import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/core/design_system/design_system.dart';
import 'package:ondo/features/character/presentation/widgets/fortune_bodies/_fortune_body_shared.dart';

Widget _wrapInScrollableSliver(Widget child) {
  return MaterialApp(
    theme: DSTheme.light(),
    home: Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(DSSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                child,
              ]),
            ),
          ),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets(
    'FortuneSectionCard lays out inside sliver content without infinite height errors',
    (tester) async {
      await tester.pumpWidget(
        _wrapInScrollableSliver(
          const FortuneSectionCard(
            emoji: '🌙',
            title: '루나의 한마디',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('감정의 흐름을 천천히 읽어보세요.'),
                SizedBox(height: DSSpacing.sm),
                Text('서두르지 않을수록 더 선명해져요.'),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('루나의 한마디'), findsOneWidget);
      expect(find.text('감정의 흐름을 천천히 읽어보세요.'), findsOneWidget);
    },
  );
}
