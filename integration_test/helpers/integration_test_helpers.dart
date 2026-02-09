// Integration Test Helpers
// 테스트에서 자주 사용되는 유틸리티 함수 모음

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 앱이 완전히 렌더링될 때까지 대기
///
/// [tester] - WidgetTester 인스턴스
/// [timeout] - 최대 대기 시간 (기본: 10초)
Future<void> pumpAppAndSettle(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  await tester.pumpAndSettle(timeout);
}

/// 특정 위젯이 나타날 때까지 대기
///
/// [tester] - WidgetTester 인스턴스
/// [finder] - 찾을 위젯의 Finder
/// [timeout] - 최대 대기 시간 (기본: 10초)
/// [pollInterval] - 폴링 간격 (기본: 500ms)
Future<bool> waitForWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
  Duration pollInterval = const Duration(milliseconds: 500),
}) async {
  final endTime = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(endTime)) {
    await tester.pump(pollInterval);

    if (finder.evaluate().isNotEmpty) {
      return true;
    }
  }

  return false;
}

/// 위젯을 찾아서 탭
///
/// [tester] - WidgetTester 인스턴스
/// [finder] - 탭할 위젯의 Finder
/// [settleAfter] - 탭 후 settle 대기 여부 (기본: true)
Future<void> findAndTap(
  WidgetTester tester,
  Finder finder, {
  bool settleAfter = true,
}) async {
  expect(finder, findsOneWidget, reason: 'Widget to tap not found');
  await tester.tap(finder);

  if (settleAfter) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

/// 텍스트 필드에 텍스트 입력
///
/// [tester] - WidgetTester 인스턴스
/// [finder] - TextField의 Finder
/// [text] - 입력할 텍스트
Future<void> enterText(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  expect(finder, findsOneWidget, reason: 'TextField not found');
  await tester.enterText(finder, text);
  await tester.pump();
}

/// 스크린샷 촬영 (디버깅용)
///
/// 참고: 실제 스크린샷은 IntegrationTestWidgetsFlutterBinding에서 제공
Future<void> takeScreenshot(
  WidgetTester tester,
  String name,
) async {
  debugPrint('📸 Screenshot: $name');
  // IntegrationTestWidgetsFlutterBinding.instance.takeScreenshot(name);
  await tester.pump();
}

/// 특정 텍스트가 화면에 있는지 확인
bool hasText(String text) {
  return find.text(text).evaluate().isNotEmpty;
}

/// 특정 텍스트를 포함하는 위젯이 있는지 확인
bool hasTextContaining(String text) {
  return find.textContaining(text).evaluate().isNotEmpty;
}

/// 특정 위젯 타입이 화면에 있는지 확인
bool hasWidgetType<T extends Widget>() {
  return find.byType(T).evaluate().isNotEmpty;
}

/// 특정 Key를 가진 위젯이 있는지 확인
bool hasKey(Key key) {
  return find.byKey(key).evaluate().isNotEmpty;
}

/// 스크롤 가능한 영역에서 위젯을 찾을 때까지 스크롤
///
/// [tester] - WidgetTester 인스턴스
/// [finder] - 찾을 위젯의 Finder
/// [scrollableFinder] - 스크롤 영역의 Finder
/// [maxScrolls] - 최대 스크롤 횟수 (기본: 10)
/// [scrollDelta] - 스크롤 이동량 (기본: -300.0)
Future<bool> scrollUntilVisible(
  WidgetTester tester,
  Finder finder, {
  Finder? scrollableFinder,
  int maxScrolls = 10,
  double scrollDelta = -300.0,
}) async {
  final scrollable = scrollableFinder ?? find.byType(Scrollable).first;

  for (int i = 0; i < maxScrolls; i++) {
    if (finder.evaluate().isNotEmpty) {
      return true;
    }

    await tester.drag(scrollable, Offset(0, scrollDelta));
    await tester.pumpAndSettle();
  }

  return finder.evaluate().isNotEmpty;
}

/// 네비게이션 바텀 바 아이템 탭
///
/// [tester] - WidgetTester 인스턴스
/// [index] - 탭할 아이템 인덱스
Future<void> tapBottomNavItem(
  WidgetTester tester,
  int index,
) async {
  final bottomNav = find.byType(BottomNavigationBar);
  expect(bottomNav, findsOneWidget, reason: 'BottomNavigationBar not found');

  final navItems = find.descendant(
    of: bottomNav,
    matching: find.byType(InkResponse),
  );

  expect(navItems.evaluate().length, greaterThan(index),
      reason: 'Nav item index out of range');

  await tester.tap(navItems.at(index));
  await tester.pumpAndSettle();
}

/// 다이얼로그가 열릴 때까지 대기
Future<bool> waitForDialog(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  return waitForWidget(tester, find.byType(AlertDialog), timeout: timeout);
}

/// 바텀시트가 열릴 때까지 대기
Future<bool> waitForBottomSheet(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  return waitForWidget(tester, find.byType(BottomSheet), timeout: timeout);
}

/// 로딩 인디케이터가 사라질 때까지 대기
Future<void> waitForLoadingToFinish(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 30),
  Duration pollInterval = const Duration(milliseconds: 500),
}) async {
  final endTime = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(endTime)) {
    await tester.pump(pollInterval);

    final hasLoading = find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
        find.byType(LinearProgressIndicator).evaluate().isNotEmpty;

    if (!hasLoading) {
      return;
    }
  }
}

/// Snackbar가 표시될 때까지 대기
Future<bool> waitForSnackbar(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  return waitForWidget(tester, find.byType(SnackBar), timeout: timeout);
}

/// 현재 화면의 모든 위젯 타입 출력 (디버깅용)
void printWidgetTree(WidgetTester tester) {
  debugPrint('=== Widget Tree ===');
  final scaffold = find.byType(Scaffold);
  if (scaffold.evaluate().isNotEmpty) {
    debugPrint('Scaffold found');
  }

  final texts = find.byType(Text);
  debugPrint('Text widgets: ${texts.evaluate().length}');

  final buttons = find.byType(ElevatedButton);
  debugPrint('ElevatedButton widgets: ${buttons.evaluate().length}');

  final textButtons = find.byType(TextButton);
  debugPrint('TextButton widgets: ${textButtons.evaluate().length}');

  final inkWells = find.byType(InkWell);
  debugPrint('InkWell widgets: ${inkWells.evaluate().length}');
  debugPrint('==================');
}
