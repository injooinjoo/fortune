import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/features/fortune/presentation/pages/dream_fortune_chat_page.dart';
import 'package:fortune/features/fortune/presentation/providers/dream_chat_provider.dart';
import 'package:fortune/presentation/providers/token_provider.dart';

void main() {
  group('DreamFortuneChatPage Tests', () {
    testWidgets('Dream fortune chat page loads correctly', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenProvider.overrideWith((ref) => TokenNotifier()),
          ],
          child: const MaterialApp(
            home: DreamFortuneChatPage(),
          ),
        ),
      );

      // Verify the page is created
      expect(find.byType(DreamFortuneChatPage), findsOneWidget);
      
      // Verify the header shows
      expect(find.text('꿈 해몽'), findsOneWidget);
      
      // Allow animations to complete
      await tester.pumpAndSettle();
    });

    testWidgets('Initial greeting message appears', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: DreamFortuneChatPage(),
          ),
        ),
      );

      // Allow the initial greeting to load
      await tester.pumpAndSettle();

      // Verify fortune teller greeting exists
      expect(find.textContaining('안녕하세요'), findsWidgets);
    });

    testWidgets('Input widget is visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: DreamFortuneChatPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify input field exists
      expect(find.byType(TextField), findsOneWidget);
      
      // Verify voice button exists
      expect(find.byIcon(Icons.mic), findsOneWidget);
      
      // Verify send button exists
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });
  });
}