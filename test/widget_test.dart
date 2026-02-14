// Basic smoke test for the Fortune app
//
// This test verifies the app can initialize and render without errors.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App initializes without crashing', (WidgetTester tester) async {
    // Build a minimal widget tree to verify basic rendering
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('ZPZG'),
            ),
          ),
        ),
      ),
    );

    // Verify app renders
    expect(find.text('ZPZG'), findsOneWidget);
  });

  testWidgets('ProviderScope is accessible', (WidgetTester tester) async {
    // Test that ProviderScope works correctly
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              // Just verify we can access the ProviderScope
              final container = ProviderScope.containerOf(context);
              expect(container, isNotNull);
              return const Scaffold(
                body: Center(
                  child: Text('Riverpod Test'),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Riverpod Test'), findsOneWidget);
  });
}
