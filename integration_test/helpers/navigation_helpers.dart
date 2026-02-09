// Navigation Helpers for Integration Tests
// GoRouter 기반 네비게이션 테스트 유틸리티
//
// 사용법:
// ```dart
// await NavigationHelpers.goToHome(tester);
// await NavigationHelpers.goToFortuneList(tester);
// await NavigationHelpers.tapBottomNavTab(tester, NavTab.fortune);
// ```

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 바텀 네비게이션 탭 인덱스
enum NavTab {
  /// 홈 탭 (인덱스 0)
  home,

  /// 운세 탭 (인덱스 1)
  fortune,

  /// 트렌드 탭 (인덱스 2)
  trend,

  /// 프리미엄 탭 (인덱스 3)
  premium,

  /// 프로필 탭 (인덱스 4)
  profile,
}

/// 네비게이션 테스트 헬퍼
class NavigationHelpers {
  NavigationHelpers._();

  /// 탭 라벨 매핑
  static const Map<NavTab, String> _tabLabels = {
    NavTab.home: '홈',
    NavTab.fortune: '운세',
    NavTab.trend: '트렌드',
    NavTab.premium: '프리미엄',
    NavTab.profile: '프로필',
  };

  /// 탭 경로 매핑
  static const Map<NavTab, String> _tabRoutes = {
    NavTab.home: '/home',
    NavTab.fortune: '/fortune',
    NavTab.trend: '/trend',
    NavTab.premium: '/premium',
    NavTab.profile: '/profile',
  };

  // ==========================================================================
  // 바텀 네비게이션 조작
  // ==========================================================================

  /// 바텀 네비게이션 탭 선택
  ///
  /// [tester] - WidgetTester 인스턴스
  /// [tab] - 선택할 탭
  /// [waitDuration] - 탭 후 대기 시간
  static Future<bool> tapBottomNavTab(
    WidgetTester tester,
    NavTab tab, {
    Duration waitDuration = const Duration(seconds: 2),
  }) async {
    final label = _tabLabels[tab]!;

    // 탭 라벨로 찾기
    final tabFinder = find.text(label);

    if (tabFinder.evaluate().isEmpty) {
      debugPrint('⚠️ NavTab not found: $label');
      return false;
    }

    await tester.tap(tabFinder);

    // pumpAndSettle 대신 pump 사용 (루핑 애니메이션 문제)
    for (int i = 0; i < (waitDuration.inMilliseconds ~/ 100); i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    debugPrint('✅ Tapped nav tab: $label');
    return true;
  }

  /// 바텀 네비게이션 인덱스로 탭 선택
  static Future<bool> tapBottomNavByIndex(
    WidgetTester tester,
    int index, {
    Duration waitDuration = const Duration(seconds: 2),
  }) async {
    if (index < 0 || index >= NavTab.values.length) {
      debugPrint('⚠️ Invalid nav index: $index');
      return false;
    }

    return tapBottomNavTab(tester, NavTab.values[index], waitDuration: waitDuration);
  }

  /// 현재 선택된 탭 확인
  static NavTab? getCurrentTab(WidgetTester tester) {
    // 선택된 아이콘 색상이나 스타일로 확인
    for (final tab in NavTab.values) {
      final label = _tabLabels[tab]!;
      final textFinder = find.text(label);

      if (textFinder.evaluate().isNotEmpty) {
        final textWidget = tester.widget<Text>(textFinder.first);
        // 선택된 탭은 FontWeight.w600
        if (textWidget.style?.fontWeight == FontWeight.w600) {
          return tab;
        }
      }
    }
    return null;
  }

  // ==========================================================================
  // 페이지 네비게이션
  // ==========================================================================

  /// 홈 페이지로 이동
  static Future<void> goToHome(WidgetTester tester) async {
    await tapBottomNavTab(tester, NavTab.home);
  }

  /// 운세 목록 페이지로 이동
  static Future<void> goToFortuneList(WidgetTester tester) async {
    await tapBottomNavTab(tester, NavTab.fortune);
  }

  /// 트렌드 페이지로 이동
  static Future<void> goToTrend(WidgetTester tester) async {
    await tapBottomNavTab(tester, NavTab.trend);
  }

  /// 프리미엄 페이지로 이동
  static Future<void> goToPremium(WidgetTester tester) async {
    await tapBottomNavTab(tester, NavTab.premium);
  }

  /// 프로필 페이지로 이동
  static Future<void> goToProfile(WidgetTester tester) async {
    await tapBottomNavTab(tester, NavTab.profile);
  }

  // ==========================================================================
  // 뒤로가기 및 네비게이션 스택
  // ==========================================================================

  /// 뒤로가기 버튼 탭
  static Future<bool> tapBackButton(WidgetTester tester) async {
    final backButton = find.byType(BackButton);
    final iconBackButton = find.byIcon(Icons.arrow_back);
    final iconBackIosButton = find.byIcon(Icons.arrow_back_ios);

    Finder? foundButton;
    if (backButton.evaluate().isNotEmpty) {
      foundButton = backButton;
    } else if (iconBackButton.evaluate().isNotEmpty) {
      foundButton = iconBackButton;
    } else if (iconBackIosButton.evaluate().isNotEmpty) {
      foundButton = iconBackIosButton;
    }

    if (foundButton == null) {
      debugPrint('⚠️ Back button not found');
      return false;
    }

    await tester.tap(foundButton.first);
    await tester.pump(const Duration(milliseconds: 500));

    debugPrint('✅ Tapped back button');
    return true;
  }

  /// 시스템 뒤로가기 시뮬레이션 (Android)
  static Future<void> simulateSystemBack(WidgetTester tester) async {
    // Navigator.maybePop 호출
    final navigatorState = tester.state<NavigatorState>(find.byType(Navigator).first);
    await navigatorState.maybePop();
    await tester.pump(const Duration(milliseconds: 500));
    debugPrint('✅ Simulated system back');
  }

  // ==========================================================================
  // 특정 운세 페이지 이동
  // ==========================================================================

  /// 운세 상세 페이지로 이동 (텍스트 탭)
  static Future<bool> goToFortuneByText(
    WidgetTester tester,
    String fortuneName, {
    bool scrollToFind = true,
  }) async {
    // 먼저 운세 탭으로 이동
    await goToFortuneList(tester);

    final fortuneFinder = find.text(fortuneName);

    if (fortuneFinder.evaluate().isEmpty && scrollToFind) {
      // 스크롤해서 찾기
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        for (int i = 0; i < 10; i++) {
          if (fortuneFinder.evaluate().isNotEmpty) break;
          await tester.drag(scrollable.first, const Offset(0, -300));
          await tester.pump(const Duration(milliseconds: 300));
        }
      }
    }

    if (fortuneFinder.evaluate().isEmpty) {
      debugPrint('⚠️ Fortune not found: $fortuneName');
      return false;
    }

    await tester.tap(fortuneFinder.first);
    await tester.pump(const Duration(seconds: 2));

    debugPrint('✅ Navigated to fortune: $fortuneName');
    return true;
  }

  /// 타로 페이지로 이동
  static Future<bool> goToTarot(WidgetTester tester) async {
    return goToFortuneByText(tester, '타로');
  }

  /// 궁합 페이지로 이동
  static Future<bool> goToCompatibility(WidgetTester tester) async {
    return goToFortuneByText(tester, '궁합');
  }

  /// 꿈해몽 페이지로 이동
  static Future<bool> goToDream(WidgetTester tester) async {
    return goToFortuneByText(tester, '꿈해몽');
  }

  /// 사주 페이지로 이동
  static Future<bool> goToSaju(WidgetTester tester) async {
    return goToFortuneByText(tester, '사주');
  }

  // ==========================================================================
  // 설정 및 서브 페이지
  // ==========================================================================

  /// 설정 페이지로 이동
  static Future<bool> goToSettings(WidgetTester tester) async {
    // 프로필 탭으로 이동
    await goToProfile(tester);

    // 설정 아이콘 찾기
    final settingsIcon = find.byIcon(Icons.settings);
    final settingsIconOutlined = find.byIcon(Icons.settings_outlined);

    Finder? settingsFinder;
    if (settingsIcon.evaluate().isNotEmpty) {
      settingsFinder = settingsIcon;
    } else if (settingsIconOutlined.evaluate().isNotEmpty) {
      settingsFinder = settingsIconOutlined;
    }

    if (settingsFinder == null) {
      // 텍스트로 찾기
      final settingsText = find.text('설정');
      if (settingsText.evaluate().isEmpty) {
        debugPrint('⚠️ Settings button not found');
        return false;
      }
      settingsFinder = settingsText;
    }

    await tester.tap(settingsFinder.first);
    await tester.pump(const Duration(seconds: 2));

    debugPrint('✅ Navigated to settings');
    return true;
  }

  /// 토큰 구매 페이지로 이동
  static Future<bool> goToTokenPurchase(WidgetTester tester) async {
    await goToPremium(tester);

    // 토큰/Soul 관련 텍스트 찾기
    final tokenFinders = [
      find.textContaining('Soul'),
      find.textContaining('토큰'),
      find.textContaining('충전'),
    ];

    for (final finder in tokenFinders) {
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        await tester.pump(const Duration(seconds: 2));
        debugPrint('✅ Navigated to token purchase');
        return true;
      }
    }

    debugPrint('⚠️ Token purchase button not found');
    return false;
  }

  /// 구독 페이지로 이동
  static Future<bool> goToSubscription(WidgetTester tester) async {
    await goToPremium(tester);

    final subscriptionFinders = [
      find.textContaining('구독'),
      find.textContaining('프리미엄'),
      find.textContaining('Premium'),
    ];

    for (final finder in subscriptionFinders) {
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        await tester.pump(const Duration(seconds: 2));
        debugPrint('✅ Navigated to subscription');
        return true;
      }
    }

    debugPrint('⚠️ Subscription button not found');
    return false;
  }

  // ==========================================================================
  // 유틸리티
  // ==========================================================================

  /// 바텀시트 닫기
  static Future<void> closeBottomSheet(WidgetTester tester) async {
    // 바텀시트 외부 탭 또는 드래그
    final bottomSheet = find.byType(BottomSheet);
    if (bottomSheet.evaluate().isNotEmpty) {
      // 바텀시트를 아래로 드래그
      await tester.drag(bottomSheet.first, const Offset(0, 400));
      await tester.pump(const Duration(milliseconds: 500));
      debugPrint('✅ Closed bottom sheet');
    }
  }

  /// 다이얼로그 닫기
  static Future<void> closeDialog(WidgetTester tester) async {
    final closeButton = find.byIcon(Icons.close);
    final cancelButton = find.text('취소');
    final okButton = find.text('확인');

    if (closeButton.evaluate().isNotEmpty) {
      await tester.tap(closeButton.first);
    } else if (cancelButton.evaluate().isNotEmpty) {
      await tester.tap(cancelButton.first);
    } else if (okButton.evaluate().isNotEmpty) {
      await tester.tap(okButton.first);
    } else {
      // 바깥 영역 탭
      await tester.tapAt(const Offset(10, 10));
    }

    await tester.pump(const Duration(milliseconds: 500));
    debugPrint('✅ Closed dialog');
  }

  /// 모든 탭 순회 (스모크 테스트용)
  static Future<void> visitAllTabs(
    WidgetTester tester, {
    Duration delayBetweenTabs = const Duration(seconds: 1),
  }) async {
    for (final tab in NavTab.values) {
      await tapBottomNavTab(tester, tab);
      await tester.pump(delayBetweenTabs);
      debugPrint('📍 Visited tab: ${_tabLabels[tab]}');
    }
  }

  /// 현재 페이지에 특정 텍스트가 있는지 확인
  static bool isOnPageWithText(String text) {
    return find.text(text).evaluate().isNotEmpty;
  }

  /// 현재 페이지에 특정 위젯 타입이 있는지 확인
  static bool isOnPageWithWidget<T extends Widget>() {
    return find.byType(T).evaluate().isNotEmpty;
  }

  /// 딥링크 테스트용 - 특정 경로로 직접 이동 (테스트 환경에서만)
  static String getRouteForTab(NavTab tab) {
    return _tabRoutes[tab]!;
  }

  /// 딥링크 경로 목록
  static const List<String> commonDeepLinks = [
    '/home',
    '/fortune',
    '/fortune/daily',
    '/fortune/tarot',
    '/fortune/compatibility',
    '/fortune/mbti',
    '/fortune/dream',
    '/fortune/saju',
    '/trend',
    '/premium',
    '/profile',
    '/settings',
  ];
}

/// 운세 페이지 경로
class FortuneRoutes {
  FortuneRoutes._();

  static const String daily = '/fortune/daily';
  static const String tarot = '/fortune/tarot';
  static const String compatibility = '/fortune/compatibility';
  static const String mbti = '/fortune/mbti';
  static const String dream = '/fortune/dream';
  static const String saju = '/fortune/saju';
  static const String love = '/fortune/love';
  static const String wealth = '/fortune/investment';
  static const String health = '/fortune/health';
  static const String talisman = '/fortune/talisman';
  static const String faceReading = '/fortune/face-reading';
  static const String biorhythm = '/fortune/biorhythm';
  static const String exam = '/fortune/exam';
  static const String pet = '/fortune/pet';
  static const String moving = '/fortune/moving';
  static const String celebrity = '/fortune/celebrity';
  static const String exLover = '/fortune/ex-lover';
  static const String family = '/fortune/family';
  static const String career = '/fortune/career';
  static const String luckyItems = '/fortune/lucky-items';
  static const String avoidPeople = '/fortune/avoid-people';
  static const String blindDate = '/fortune/blind-date';
}
