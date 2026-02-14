// ZPZG - Integration Test (E2E)
// 전체 앱 플로우를 테스트하는 E2E 테스트
//
// 실행 방법:
// ```bash
// flutter test integration_test/app_test.dart
// ```

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fortune/features/character/presentation/pages/swipe_home_shell.dart';
import 'test_app.dart';

Future<void> startAppAndWait(
  WidgetTester tester, {
  Duration waitDuration = const Duration(seconds: 10),
}) async {
  await tester.pumpWidget(createTestApp());

  final steps = waitDuration.inMilliseconds ~/ 100;
  for (int i = 0; i < steps; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeTestApp(
      skipSupabase: false,
      skipHive: false,
    );
  });

  group('앱 시작 테스트', () {
    testWidgets('앱이 정상적으로 시작되어야 함', (tester) async {
      await startAppAndWait(tester);

      // 앱이 시작되면 어떤 화면이든 렌더링되어야 함
      expect(find.byType(MaterialApp), findsWidgets);
    });

    testWidgets('초기 진입 후 메인 또는 랜딩 화면이 표시되어야 함', (tester) async {
      await startAppAndWait(tester);

      // Chat-First 라우팅 기준: 채팅 셸(로그인/게스트) 또는 시작 화면을 허용
      final chatShell = find.byType(SwipeHomeShell);
      final startButton = find.text('시작하기');

      expect(
        chatShell.evaluate().isNotEmpty || startButton.evaluate().isNotEmpty,
        isTrue,
        reason: '초기 진입 후 메인 또는 랜딩 화면이 표시되어야 합니다',
      );
    });
  });

  group('네비게이션 테스트', () {
    testWidgets('시작하기 버튼이 있으면 탭해도 앱이 안정적으로 동작해야 함', (tester) async {
      await startAppAndWait(tester);

      // 시작하기 버튼 찾기
      final startButton = find.text('시작하기');
      if (startButton.evaluate().isNotEmpty) {
        await tester.tap(startButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      expect(tester.takeException(), isNull);
    });
  });
}
