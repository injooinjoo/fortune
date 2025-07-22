import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/shared/components/soul_earn_animation.dart';
import 'package:fortune/shared/components/soul_consume_animation.dart';

void main() {
  group('Soul Animation Tests', () {
    testWidgets('SoulEarnAnimation shows and hides correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    SoulEarnAnimation.show(
                      context: context,
                      soulAmount: 5,
                    );
                  },
                  child: const Text('Show Animation'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap button to show animation
      await tester.tap(find.text('Show Animation'));
      await tester.pump();

      // Check if animation overlay is shown
      expect(find.text('+5'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);

      // Wait for animation to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check if animation is removed
      expect(find.text('+5'), findsNothing);
    });

    testWidgets('SoulConsumeAnimation shows and hides correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    SoulConsumeAnimation.show(
                      context: context,
                      soulAmount: 10,
                    );
                  },
                  child: const Text('Show Consume Animation'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap button to show animation
      await tester.tap(find.text('Show Consume Animation'));
      await tester.pump();

      // Check if animation overlay is shown
      expect(find.text('-10'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);

      // Wait for animation to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check if animation is removed
      expect(find.text('-10'), findsNothing);
    });
  });
}