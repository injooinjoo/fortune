import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/design_system/theme/ds_theme.dart';
import 'package:fortune/screens/onboarding/steps/name_input_step.dart';
import 'package:fortune/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildSubject({
    required VoidCallback onNext,
    bool allowSkip = false,
    VoidCallback? onSkip,
  }) {
    return ProviderScope(
      child: MaterialApp(
        theme: DSTheme.light(),
        home: Scaffold(
          body: NameInputStep(
            initialName: '',
            onNameChanged: (_) {},
            onNext: onNext,
            allowSkip: allowSkip,
            onSkip: onSkip,
          ),
        ),
      ),
    );
  }

  testWidgets('done 제출은 필수 동의 2개를 모두 통과해야만 진행된다', (tester) async {
    var nextCalled = false;

    await tester.pumpWidget(
      buildSubject(
        onNext: () => nextCalled = true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '홍길동');
    await tester.pump();

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(nextCalled, isFalse);

    await tester.tap(find.byType(AnimatedContainer).at(0));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(nextCalled, isFalse);

    await tester.tap(find.byType(AnimatedContainer).at(1));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(nextCalled, isTrue);
  });

  testWidgets('다음 진행 시 약관과 개인정보 동의가 함께 저장된다', (tester) async {
    var nextCalled = false;
    final storageService = StorageService();

    await tester.pumpWidget(
      buildSubject(
        onNext: () => nextCalled = true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '홍길동');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AnimatedContainer).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AnimatedContainer).at(1));
    await tester.pumpAndSettle();

    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(nextCalled, isTrue);
    expect(await storageService.hasAcceptedTerms(), isTrue);
    expect(await storageService.hasAcceptedPrivacyPolicy(), isTrue);
  });

  testWidgets('건너뛰기는 필수 동의 전에는 동작하지 않고 동의 후에만 허용된다', (tester) async {
    var skipCalled = false;

    await tester.pumpWidget(
      buildSubject(
        onNext: () {},
        allowSkip: true,
        onSkip: () => skipCalled = true,
      ),
    );
    await tester.pumpAndSettle();

    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.text('건너뛰기'));
    await tester.pumpAndSettle();
    expect(skipCalled, isFalse);

    await tester.tap(find.byType(AnimatedContainer).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AnimatedContainer).at(1));
    await tester.pumpAndSettle();

    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.text('건너뛰기'));
    await tester.pumpAndSettle();

    expect(skipCalled, isTrue);
  });
}
