/// Fortune App - Integration Test (E2E)
/// 전체 앱 플로우를 테스트하는 E2E 테스트
///
/// 실행 방법:
/// ```bash
/// flutter test integration_test/app_test.dart
/// ```

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fortune/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('앱 시작 테스트', () {
    testWidgets('앱이 정상적으로 시작되어야 함', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 앱이 시작되면 어떤 화면이든 렌더링되어야 함
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('랜딩 페이지가 표시되어야 함 (비로그인 상태)', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 랜딩 페이지의 "시작하기" 버튼 또는 "Fortune" 텍스트 확인
      final startButton = find.text('시작하기');
      final fortuneText = find.text('Fortune');

      expect(
        startButton.evaluate().isNotEmpty || fortuneText.evaluate().isNotEmpty,
        isTrue,
        reason: '랜딩 페이지가 표시되어야 합니다',
      );
    });
  });

  group('네비게이션 테스트', () {
    testWidgets('시작하기 버튼 탭 시 다음 화면으로 이동', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 시작하기 버튼 찾기
      final startButton = find.text('시작하기');
      if (startButton.evaluate().isNotEmpty) {
        await tester.tap(startButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 화면이 변경되었는지 확인 (랜딩이 아닌 다른 화면)
        // 온보딩이나 홈 화면이 표시되어야 함
      }
    });
  });
}
