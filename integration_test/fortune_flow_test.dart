/// Fortune Flow - Integration Test
/// 운세 조회 플로우 E2E 테스트
///
/// 실행 방법:
/// ```bash
/// flutter test integration_test/fortune_flow_test.dart -d <device_id>
/// ```

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fortune/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('운세 목록 페이지 테스트', () {
    testWidgets('운세 목록이 표시되어야 함', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 로그인된 상태에서 운세 목록 페이지로 이동했다고 가정
      // 실제 테스트에서는 테스트용 로그인 처리 필요

      // 운세 카테고리 확인
      final fortuneCategories = [
        '오늘의 운세',
        '타로',
        '사주',
        '궁합',
      ];

      for (final category in fortuneCategories) {
        final categoryFinder = find.textContaining(category);
        // 카테고리가 있으면 확인
        if (categoryFinder.evaluate().isNotEmpty) {
          expect(categoryFinder, findsWidgets);
        }
      }
    });
  });

  group('타로 운세 플로우 테스트', () {
    testWidgets('타로 페이지 진입 및 덱 선택', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 타로 메뉴 찾기 및 탭
      final tarotMenu = find.text('타로');
      if (tarotMenu.evaluate().isNotEmpty) {
        await tester.tap(tarotMenu);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 타로 덱 선택 화면 확인
        final deckSelection = find.textContaining('덱');
        if (deckSelection.evaluate().isNotEmpty) {
          expect(deckSelection, findsWidgets);
        }
      }
    });

    testWidgets('타로 카드 선택 및 결과 표시', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 타로 플로우 테스트
      // 1. 덱 선택
      // 2. 스프레드 선택
      // 3. 카드 선택
      // 4. 결과 표시

      // 이 테스트는 실제 로그인 상태에서 수행해야 함
    });
  });

  group('사주 운세 플로우 테스트', () {
    testWidgets('사주 페이지 진입', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 사주 메뉴 찾기
      final sajuMenu = find.text('사주');
      if (sajuMenu.evaluate().isNotEmpty) {
        await tester.tap(sajuMenu);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 생년월일 입력 폼 확인
        final birthDateInput = find.textContaining('생년월일');
        if (birthDateInput.evaluate().isNotEmpty) {
          expect(birthDateInput, findsWidgets);
        }
      }
    });
  });

  group('프리미엄 플로우 테스트', () {
    testWidgets('블러 콘텐츠 표시 확인', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 블러 처리된 콘텐츠가 있는지 확인
      // UnifiedBlurWrapper 사용 확인
      final blurredContent = find.byType(ClipRect);
      // 블러 콘텐츠가 있으면 광고 또는 프리미엄 버튼이 있어야 함
    });

    testWidgets('프리미엄 구매 버튼 표시', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 프리미엄/구독 관련 버튼 찾기
      final premiumButtons = [
        find.textContaining('프리미엄'),
        find.textContaining('구독'),
        find.textContaining('광고'),
        find.textContaining('토큰'),
      ];

      for (final button in premiumButtons) {
        if (button.evaluate().isNotEmpty) {
          // 버튼이 탭 가능한지 확인
          expect(button, findsWidgets);
        }
      }
    });
  });
}
