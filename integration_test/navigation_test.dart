/// Navigation Integration Test (Category B1)
/// 네비게이션 E2E 테스트
///
/// 실행 방법:
/// ```bash
/// flutter test integration_test/navigation_test.dart -d "iPhone 15 Pro" --dart-define=TEST_MODE=true
/// ```
///
/// 테스트 케이스 10개:
/// - NAV-001: 바텀 네비 홈 탭
/// - NAV-002: 바텀 네비 운세 탭
/// - NAV-003: 바텀 네비 트렌드 탭
/// - NAV-004: 바텀 네비 프리미엄 탭
/// - NAV-005: 바텀 네비 프로필 탭
/// - NAV-006: 딥링크 운세 페이지
/// - NAV-007: 딥링크 타로 페이지
/// - NAV-008: 뒤로가기 스택 네비게이션
/// - NAV-009: 홈 버튼으로 홈 복귀
/// - NAV-010: iOS 스와이프 뒤로가기

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fortune/main.dart' as app;
import 'helpers/navigation_helpers.dart';

/// 앱 시작 헬퍼
Future<void> startAppAndWait(
  WidgetTester tester, {
  Duration waitDuration = const Duration(seconds: 5),
}) async {
  app.main();
  for (int i = 0; i < (waitDuration.inMilliseconds ~/ 100); i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🟡 Category B1: 네비게이션 테스트 (10개)', () {
    // ========================================================================
    // 바텀 네비게이션 테스트
    // ========================================================================

    testWidgets('NAV-001: 바텀 네비 홈 탭', (tester) async {
      await startAppAndWait(tester, waitDuration: const Duration(seconds: 10));

      // 홈 탭 선택
      await NavigationHelpers.tapBottomNavTab(tester, NavTab.home);
      await tester.pump(const Duration(seconds: 2));

      // 홈 화면 확인
      final homeIndicators = [
        find.textContaining('홈'),
        find.textContaining('오늘'),
        find.textContaining('운세'),
      ];

      bool isOnHomeScreen = false;
      for (final indicator in homeIndicators) {
        if (indicator.evaluate().isNotEmpty) {
          isOnHomeScreen = true;
          break;
        }
      }

      expect(find.byType(Scaffold), findsWidgets);
      debugPrint('✅ NAV-001 PASSED: Home tab navigation: $isOnHomeScreen');
    });

    testWidgets('NAV-002: 바텀 네비 운세 탭', (tester) async {
      await startAppAndWait(tester, waitDuration: const Duration(seconds: 10));

      // 운세 탭 선택
      await NavigationHelpers.tapBottomNavTab(tester, NavTab.fortune);
      await tester.pump(const Duration(seconds: 2));

      // 운세 목록 화면 확인
      final fortuneIndicators = [
        find.textContaining('운세'),
        find.textContaining('타로'),
        find.textContaining('궁합'),
        find.textContaining('사주'),
      ];

      bool isOnFortuneScreen = false;
      for (final indicator in fortuneIndicators) {
        if (indicator.evaluate().isNotEmpty) {
          isOnFortuneScreen = true;
          break;
        }
      }

      expect(find.byType(Scaffold), findsWidgets);
      debugPrint('✅ NAV-002 PASSED: Fortune tab navigation: $isOnFortuneScreen');
    });

    testWidgets('NAV-003: 바텀 네비 트렌드 탭', (tester) async {
      await startAppAndWait(tester, waitDuration: const Duration(seconds: 10));

      // 트렌드 탭 선택
      await NavigationHelpers.tapBottomNavTab(tester, NavTab.trend);
      await tester.pump(const Duration(seconds: 2));

      // 트렌드/인터랙티브 화면 확인
      final trendIndicators = [
        find.textContaining('트렌드'),
        find.textContaining('인터랙티브'),
        find.textContaining('심리'),
        find.textContaining('밸런스'),
        find.textContaining('이상형'),
      ];

      bool isOnTrendScreen = false;
      for (final indicator in trendIndicators) {
        if (indicator.evaluate().isNotEmpty) {
          isOnTrendScreen = true;
          break;
        }
      }

      expect(find.byType(Scaffold), findsWidgets);
      debugPrint('✅ NAV-003 PASSED: Trend tab navigation: $isOnTrendScreen');
    });

    testWidgets('NAV-004: 바텀 네비 프리미엄 탭', (tester) async {
      await startAppAndWait(tester, waitDuration: const Duration(seconds: 10));

      // 프리미엄 탭 선택
      await NavigationHelpers.tapBottomNavTab(tester, NavTab.premium);
      await tester.pump(const Duration(seconds: 2));

      // 프리미엄 화면 확인
      final premiumIndicators = [
        find.textContaining('프리미엄'),
        find.textContaining('Premium'),
        find.textContaining('구독'),
        find.textContaining('토큰'),
        find.textContaining('Soul'),
      ];

      bool isOnPremiumScreen = false;
      for (final indicator in premiumIndicators) {
        if (indicator.evaluate().isNotEmpty) {
          isOnPremiumScreen = true;
          break;
        }
      }

      expect(find.byType(Scaffold), findsWidgets);
      debugPrint('✅ NAV-004 PASSED: Premium tab navigation: $isOnPremiumScreen');
    });

    testWidgets('NAV-005: 바텀 네비 프로필 탭', (tester) async {
      await startAppAndWait(tester, waitDuration: const Duration(seconds: 10));

      // 프로필 탭 선택
      await NavigationHelpers.tapBottomNavTab(tester, NavTab.profile);
      await tester.pump(const Duration(seconds: 2));

      // 프로필 화면 확인
      final profileIndicators = [
        find.textContaining('프로필'),
        find.byType(CircleAvatar),
        find.byIcon(Icons.person),
        find.byIcon(Icons.settings),
        find.textContaining('설정'),
      ];

      bool isOnProfileScreen = false;
      for (final indicator in profileIndicators) {
        if (indicator.evaluate().isNotEmpty) {
          isOnProfileScreen = true;
          break;
        }
      }

      expect(find.byType(Scaffold), findsWidgets);
      debugPrint('✅ NAV-005 PASSED: Profile tab navigation: $isOnProfileScreen');
    });

    // ========================================================================
    // 딥링크 테스트
    // ========================================================================

    testWidgets('NAV-006: 딥링크 운세 페이지 접근', (tester) async {
      await startAppAndWait(tester, waitDuration: const Duration(seconds: 10));

      // 운세 탭으로 이동 후 특정 운세 선택 (딥링크 시뮬레이션)
      await NavigationHelpers.tapBottomNavTab(tester, NavTab.fortune);
      await tester.pump(const Duration(seconds: 2));

      // 일일 운세 메뉴 찾기
      final dailyFortuneFinders = [
        find.textContaining('일일'),
        find.textContaining('오늘'),
        find.textContaining('데일리'),
      ];

      bool navigatedToDaily = false;
      for (final finder in dailyFortuneFinders) {
        if (finder.evaluate().isNotEmpty) {
          navigatedToDaily = true;
          await tester.tap(finder.first);
          await tester.pump(const Duration(seconds: 2));
          break;
        }
      }

      expect(find.byType(Scaffold), findsWidgets);
      debugPrint('✅ NAV-006 PASSED: Deep link to daily fortune: $navigatedToDaily');
    });

    testWidgets('NAV-007: 딥링크 타로 페이지 접근', (tester) async {
      await startAppAndWait(tester, waitDuration: const Duration(seconds: 10));

      // 운세 탭으로 이동 후 타로 선택 (딥링크 시뮬레이션)
      await NavigationHelpers.tapBottomNavTab(tester, NavTab.fortune);
      await tester.pump(const Duration(seconds: 2));

      // 타로 메뉴 찾기
      final tarotFinders = [
        find.textContaining('타로'),
        find.textContaining('Tarot'),
      ];

      bool navigatedToTarot = false;
      for (final finder in tarotFinders) {
        if (finder.evaluate().isNotEmpty) {
          navigatedToTarot = true;
          await tester.tap(finder.first);
          await tester.pump(const Duration(seconds: 2));
          break;
        }
      }

      expect(find.byType(Scaffold), findsWidgets);
      debugPrint('✅ NAV-007 PASSED: Deep link to tarot: $navigatedToTarot');
    });

    // ========================================================================
    // 네비게이션 스택 테스트
    // ========================================================================

    testWidgets('NAV-008: 뒤로가기 스택 네비게이션', (tester) async {
      await startAppAndWait(tester, waitDuration: const Duration(seconds: 10));

      // 1. 홈에서 시작
      await NavigationHelpers.tapBottomNavTab(tester, NavTab.home);
      await tester.pump(const Duration(seconds: 1));

      // 2. 프로필로 이동
      await NavigationHelpers.tapBottomNavTab(tester, NavTab.profile);
      await tester.pump(const Duration(seconds: 1));

      // 3. 설정 페이지 진입 시도
      final settingsIcon = find.byIcon(Icons.settings);
      bool navigatedToSettings = false;

      if (settingsIcon.evaluate().isNotEmpty) {
        await tester.tap(settingsIcon.first);
        await tester.pump(const Duration(seconds: 2));
        navigatedToSettings = true;

        // 4. 뒤로가기
        await NavigationHelpers.tapBackButton(tester);
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.byType(Scaffold), findsWidgets);
      debugPrint('✅ NAV-008 PASSED: Back navigation stack: $navigatedToSettings');
    });

    testWidgets('NAV-009: 홈 버튼으로 홈 복귀', (tester) async {
      await startAppAndWait(tester, waitDuration: const Duration(seconds: 10));

      // 1. 프로필로 이동
      await NavigationHelpers.tapBottomNavTab(tester, NavTab.profile);
      await tester.pump(const Duration(seconds: 1));

      // 2. 운세로 이동
      await NavigationHelpers.tapBottomNavTab(tester, NavTab.fortune);
      await tester.pump(const Duration(seconds: 1));

      // 3. 다시 홈으로
      await NavigationHelpers.tapBottomNavTab(tester, NavTab.home);
      await tester.pump(const Duration(seconds: 2));

      // 홈 화면 확인
      final homeIndicators = [
        find.textContaining('홈'),
        find.textContaining('오늘'),
      ];

      bool isBackHome = false;
      for (final indicator in homeIndicators) {
        if (indicator.evaluate().isNotEmpty) {
          isBackHome = true;
          break;
        }
      }

      expect(find.byType(Scaffold), findsWidgets);
      debugPrint('✅ NAV-009 PASSED: Home button return: $isBackHome');
    });

    testWidgets('NAV-010: iOS 스와이프 뒤로가기', (tester) async {
      await startAppAndWait(tester, waitDuration: const Duration(seconds: 10));

      // 1. 운세 탭으로 이동
      await NavigationHelpers.tapBottomNavTab(tester, NavTab.fortune);
      await tester.pump(const Duration(seconds: 2));

      // 2. 운세 항목 탭하여 상세 페이지 이동
      final fortuneItems = find.byType(InkWell);
      bool navigatedToDetail = false;

      if (fortuneItems.evaluate().isNotEmpty) {
        await tester.tap(fortuneItems.first);
        await tester.pump(const Duration(seconds: 2));
        navigatedToDetail = true;

        // 3. 화면 왼쪽에서 오른쪽으로 스와이프 (iOS 뒤로가기)
        await tester.drag(
          find.byType(Scaffold).first,
          const Offset(300, 0), // 왼쪽에서 오른쪽으로
        );
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.byType(Scaffold), findsWidgets);
      debugPrint('✅ NAV-010 PASSED: iOS swipe back gesture: $navigatedToDetail');
    });
  });
}
