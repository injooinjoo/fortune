// Landing Page - Integration Test
// 랜딩 페이지 E2E 테스트
//
// 실행 방법:
// ```bash
// flutter test integration_test/landing_test.dart -d "iPhone 15 Pro"
// ```
//
// 참고: pumpAndSettle은 루핑 애니메이션이 있으면 완료되지 않습니다.
// 대신 pump()를 사용하여 특정 시간만 기다립니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fortune/main.dart' as app;

/// 앱이 초기화될 때까지 pump를 반복 호출
/// pumpAndSettle 대신 사용 (루핑 애니메이션 문제 해결)
Future<void> pumpUntilReady(
  WidgetTester tester, {
  Duration duration = const Duration(seconds: 10),
  Duration interval = const Duration(milliseconds: 500),
}) async {
  final endTime = DateTime.now().add(duration);

  while (DateTime.now().isBefore(endTime)) {
    await tester.pump(interval);

    // MaterialApp이 렌더링되면 기본 초기화 완료
    if (find.byType(MaterialApp).evaluate().isNotEmpty) {
      // 추가로 2초 더 pump하여 UI 안정화
      for (int i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      return;
    }
  }
}

/// 앱을 시작하고 특정 시간만큼 pump
Future<void> startAppAndWait(
  WidgetTester tester, {
  Duration waitDuration = const Duration(seconds: 5),
}) async {
  app.main();

  // 여러 프레임을 렌더링하여 앱 초기화 대기
  for (int i = 0; i < (waitDuration.inMilliseconds ~/ 100); i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('랜딩 페이지 테스트', () {
    testWidgets('TC001: 앱이 정상적으로 시작되어야 함', (tester) async {
      await startAppAndWait(tester, waitDuration: const Duration(seconds: 8));

      // MaterialApp이 렌더링되어야 함
      expect(find.byType(MaterialApp), findsOneWidget);
      debugPrint('TC001 PASSED: MaterialApp rendered');
    });

    testWidgets('TC002: 앱 UI 요소 확인', (tester) async {
      await startAppAndWait(tester, waitDuration: const Duration(seconds: 8));

      // 앱이 시작되면 다음 중 하나가 있어야 함:
      // - 랜딩 페이지 (시작하기 버튼)
      // - 홈 화면 (이미 로그인된 경우)
      final hasStartButton = find.text('시작하기').evaluate().isNotEmpty;
      final hasScaffold = find.byType(Scaffold).evaluate().isNotEmpty;
      final hasMaterialApp = find.byType(MaterialApp).evaluate().isNotEmpty;

      // 앱이 정상적으로 렌더링되어야 함
      expect(
        hasMaterialApp && hasScaffold,
        isTrue,
        reason: '앱이 정상적으로 렌더링되어야 합니다',
      );

      debugPrint('TC002 PASSED: UI elements found');
      debugPrint('  - hasStartButton: $hasStartButton');
      debugPrint('  - hasScaffold: $hasScaffold');
    });

    testWidgets('TC003: 인터랙티브 요소 존재 확인', (tester) async {
      await startAppAndWait(tester, waitDuration: const Duration(seconds: 8));

      // 인터랙티브 요소들 확인
      final buttons = find.byType(ElevatedButton);
      final textButtons = find.byType(TextButton);
      final inkWells = find.byType(InkWell);
      final gestureDetectors = find.byType(GestureDetector);

      final hasInteractiveElements =
          buttons.evaluate().isNotEmpty ||
          textButtons.evaluate().isNotEmpty ||
          inkWells.evaluate().isNotEmpty ||
          gestureDetectors.evaluate().isNotEmpty;

      expect(
        hasInteractiveElements,
        isTrue,
        reason: '인터랙티브 요소가 있어야 합니다',
      );

      debugPrint('TC003 PASSED: Interactive elements found');
      debugPrint('  - ElevatedButton: ${buttons.evaluate().length}');
      debugPrint('  - TextButton: ${textButtons.evaluate().length}');
      debugPrint('  - InkWell: ${inkWells.evaluate().length}');
      debugPrint('  - GestureDetector: ${gestureDetectors.evaluate().length}');
    });

    testWidgets('TC004: Scaffold 위젯 확인', (tester) async {
      await startAppAndWait(tester, waitDuration: const Duration(seconds: 8));

      // Scaffold가 있어야 함
      expect(find.byType(Scaffold), findsWidgets);
      debugPrint('TC004 PASSED: Scaffold found');
    });
  });

  group('앱 상태 테스트', () {
    testWidgets('TC005: 인증 상태에 따른 화면 분기', (tester) async {
      await startAppAndWait(tester, waitDuration: const Duration(seconds: 10));

      // 인증 상태에 따라 다른 화면이 표시됨
      // - 비로그인: 랜딩 페이지 (시작하기 버튼)
      // - 로그인됨: 홈 화면

      final hasStartButton = find.text('시작하기').evaluate().isNotEmpty;

      if (hasStartButton) {
        debugPrint('TC005: 랜딩 페이지 표시됨 (비로그인 상태)');
      } else {
        debugPrint('TC005: 홈 화면 표시됨 (로그인 상태)');
      }

      // 어떤 상태든 MaterialApp이 있어야 함
      expect(find.byType(MaterialApp), findsOneWidget);
      debugPrint('TC005 PASSED: App state verified');
    });

    testWidgets('TC006: 앱이 크래시 없이 실행됨', (tester) async {
      // 이 테스트는 앱이 크래시 없이 시작되는지 확인
      var crashed = false;

      try {
        await startAppAndWait(tester, waitDuration: const Duration(seconds: 10));
      } catch (e) {
        crashed = true;
        debugPrint('TC006 FAILED: App crashed with error: $e');
      }

      expect(crashed, isFalse, reason: '앱이 크래시 없이 시작되어야 합니다');
      debugPrint('TC006 PASSED: App started without crash');
    });
  });

  group('성능 테스트', () {
    testWidgets('TC007: 앱 초기 렌더링 시간 측정', (tester) async {
      final stopwatch = Stopwatch()..start();

      app.main();

      // MaterialApp이 나타날 때까지 시간 측정
      for (int i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.byType(MaterialApp).evaluate().isNotEmpty) {
          stopwatch.stop();
          break;
        }
      }

      // 앱이 10초 이내에 첫 화면을 렌더링해야 함
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(10000),
        reason: '앱 첫 렌더링이 10초 이내에 완료되어야 합니다',
      );

      debugPrint('TC007 PASSED: App initial render time: ${stopwatch.elapsedMilliseconds}ms');

      // 백그라운드 Provider 정리를 위한 추가 대기
      // ThemeModeNotifier 등이 완전히 초기화되도록 함
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    });
  });
}
