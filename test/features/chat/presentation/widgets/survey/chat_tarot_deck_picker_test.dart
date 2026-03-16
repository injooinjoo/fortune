import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/features/chat/domain/models/fortune_survey_config.dart';
import 'package:fortune/features/chat/presentation/widgets/survey/chat_tarot_deck_picker.dart';
import 'package:fortune/presentation/providers/tarot_deck_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('deck picker persists selected deck and emits survey option',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    SurveyOption? selectedOption;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: DSTheme.light(),
          home: Scaffold(
            body: SizedBox(
              width: 2200,
              child: ChatTarotDeckPicker(
                onSelect: (option) {
                  selectedOption = option;
                },
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('tarot-deck-rider_waite')), findsOneWidget);
    expect(find.byKey(const ValueKey('tarot-deck-thoth')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('tarot-deck-thoth')));
    await tester.pumpAndSettle();

    expect(selectedOption?.id, 'thoth');
    expect(selectedOption?.label, '토트 타로');
    expect(container.read(selectedTarotDeckProvider), 'thoth');
  });
}
