import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/core/design_system/design_system.dart';
import 'package:ondo/screens/onboarding/steps/birth_input_step.dart';

void main() {
  Widget buildSubject({
    required void Function(DateTime) onBirthDateChanged,
  }) {
    return ProviderScope(
      child: MaterialApp(
        theme: DSTheme.light(),
        home: Scaffold(
          body: BirthInputStep(
            onBirthDateChanged: onBirthDateChanged,
            onNext: () {},
            onBack: () {},
          ),
        ),
      ),
    );
  }

  testWidgets(
    'revealing progressive date fields does not throw render or semantics exceptions',
    (tester) async {
      DateTime? selectedDate;
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        buildSubject(
          onBirthDateChanged: (value) => selectedDate = value,
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.enterText(find.byType(TextField).first, '1990');
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.takeException(), isNull);

      await tester.enterText(find.byType(TextField).at(1), '12');
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.takeException(), isNull);

      await tester.enterText(find.byType(TextField).at(2), '25');
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.takeException(), isNull);

      expect(selectedDate, DateTime(1990, 12, 25));
      expect(find.byType(TextField), findsNWidgets(5));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      semanticsHandle.dispose();
    },
  );
}
