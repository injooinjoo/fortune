테스트 코드를 자동으로 생성합니다.

## 입력 정보

- **테스트 대상 파일**: $ARGUMENTS 또는 사용자에게 질문
- **테스트 유형**: widget, provider, service

## 테스트 파일 위치

```
원본: lib/features/{feature}/presentation/pages/{name}_page.dart
테스트: test/features/{feature}/presentation/pages/{name}_page_test.dart
```

## Widget 테스트 템플릿

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class Mock{Name}Notifier extends Mock implements {Name}Notifier {}
class Mock{Service} extends Mock implements {Service} {}

void main() {
  late Mock{Name}Notifier mockNotifier;

  setUp(() {
    mockNotifier = Mock{Name}Notifier();
  });

  group('{Name}Page', () {
    testWidgets('renders correctly in initial state', (tester) async {
      when(() => mockNotifier.state).thenReturn(const {Name}State());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            {name}NotifierProvider.overrideWith((ref) => mockNotifier),
          ],
          child: const MaterialApp(home: {Name}Page()),
        ),
      );

      expect(find.byType({Name}Page), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      when(() => mockNotifier.state).thenReturn(
        const {Name}State(isLoading: true),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            {name}NotifierProvider.overrideWith((ref) => mockNotifier),
          ],
          child: const MaterialApp(home: {Name}Page()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when error occurs', (tester) async {
      when(() => mockNotifier.state).thenReturn(
        const {Name}State(error: 'Test error'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            {name}NotifierProvider.overrideWith((ref) => mockNotifier),
          ],
          child: const MaterialApp(home: {Name}Page()),
        ),
      );

      expect(find.text('Test error'), findsOneWidget);
    });

    testWidgets('displays result when data is loaded', (tester) async {
      final testResult = {ResultType}(/* test data */);
      when(() => mockNotifier.state).thenReturn(
        {Name}State(result: testResult),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            {name}NotifierProvider.overrideWith((ref) => mockNotifier),
          ],
          child: const MaterialApp(home: {Name}Page()),
        ),
      );

      // 결과 표시 검증
      expect(find.byType({ResultWidget}), findsOneWidget);
    });
  });
}
```

## Provider 테스트 템플릿

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class Mock{Service} extends Mock implements {Service} {}

void main() {
  late Mock{Service} mockService;
  late ProviderContainer container;

  setUp(() {
    mockService = Mock{Service}();
    container = ProviderContainer(
      overrides: [
        {name}ServiceProvider.overrideWithValue(mockService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('{Name}Notifier', () {
    test('initial state is correct', () {
      final state = container.read({name}NotifierProvider);

      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.result, isNull);
    });

    test('load{Name} sets loading state', () async {
      when(() => mockService.fetch{Name}())
          .thenAnswer((_) async => testResult);

      final notifier = container.read({name}NotifierProvider.notifier);
      final future = notifier.load{Name}();

      expect(container.read({name}NotifierProvider).isLoading, true);

      await future;

      expect(container.read({name}NotifierProvider).isLoading, false);
      expect(container.read({name}NotifierProvider).result, testResult);
    });

    test('handles error correctly', () async {
      when(() => mockService.fetch{Name}())
          .thenThrow(Exception('Test error'));

      final notifier = container.read({name}NotifierProvider.notifier);
      await notifier.load{Name}();

      expect(container.read({name}NotifierProvider).isLoading, false);
      expect(container.read({name}NotifierProvider).error, isNotNull);
    });
  });
}
```

## 실행 명령어

```bash
flutter test test/features/{feature}/
```

## 관련 Agent

- testing-architect

