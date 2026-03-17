import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/features/chat/domain/models/fortune_survey_config.dart';
import 'package:fortune/features/chat/presentation/widgets/survey/chat_survey_chips.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: DSTheme.light(),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('survey chips render DS-style labels and emit selection',
      (tester) async {
    SurveyOption? selectedOption;

    await tester.pumpWidget(
      _wrap(
        ChatSurveyChips(
          options: const [
            SurveyOption(id: 'work', label: '일과 집중', emoji: '💼'),
            SurveyOption(
              id: 'relationship',
              label: '대화와 관계',
              icon: Icons.forum_outlined,
            ),
          ],
          selectedIds: const {'work'},
          onSelect: (option) {
            selectedOption = option;
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('💼 일과 집중'), findsOneWidget);
    expect(find.text('대화와 관계'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNothing);

    await tester.tap(find.text('대화와 관계'));
    await tester.pumpAndSettle();

    expect(selectedOption?.id, 'relationship');
  });
}
