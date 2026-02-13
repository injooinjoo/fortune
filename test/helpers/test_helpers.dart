// Test Helpers - 테스트 공통 유틸리티
// 모든 테스트에서 사용할 수 있는 헬퍼 함수들

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 테스트용 MaterialApp 래퍼
Widget createTestableWidget(Widget child, {List<Override>? overrides}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      home: child,
      // 테스트용 테마
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
      ),
    ),
  );
}

/// 테스트용 Scaffold 래퍼
Widget createScaffoldTestWidget(Widget child, {List<Override>? overrides}) {
  return createTestableWidget(
    Scaffold(body: child),
    overrides: overrides,
  );
}

/// 비동기 작업 대기 헬퍼
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final endTime = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(endTime)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  throw Exception('Widget not found within timeout: $finder');
}

/// 스크롤하여 위젯 찾기
Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder finder,
  Finder scrollable, {
  double delta = 100,
  int maxScrolls = 50,
}) async {
  int scrollCount = 0;

  while (finder.evaluate().isEmpty && scrollCount < maxScrolls) {
    await tester.drag(scrollable, Offset(0, -delta));
    await tester.pumpAndSettle();
    scrollCount++;
  }

  if (finder.evaluate().isEmpty) {
    throw Exception('Widget not found after $maxScrolls scrolls: $finder');
  }
}

/// 테스트 데이터 생성 헬퍼
class TestDataFactory {
  /// 테스트용 사용자 정보
  static Map<String, dynamic> createUserInfo({
    String birthDate = '1990-01-01',
    String birthTime = '09:00',
    String gender = 'male',
    bool isLunar = false,
  }) {
    return {
      'birthDate': birthDate,
      'birthTime': birthTime,
      'gender': gender,
      'isLunar': isLunar,
    };
  }

  /// 테스트용 운세 결과
  static Map<String, dynamic> createFortuneResult({
    int overallScore = 85,
    List<Map<String, dynamic>>? sections,
  }) {
    return {
      'overallScore': overallScore,
      'sections': sections ??
          [
            {
              'key': 'summary',
              'title': '오늘의 운세',
              'content': '좋은 하루가 될 것입니다.',
              'score': 85,
            },
            {
              'key': 'love',
              'title': '애정운',
              'content': '연인과의 관계가 좋아집니다.',
              'score': 90,
            },
            {
              'key': 'career',
              'title': '직장운',
              'content': '업무에서 좋은 성과가 있습니다.',
              'score': 80,
            },
          ],
      'luckyItems': {
        'color': '파랑',
        'number': 7,
        'direction': '동쪽',
      },
      'advice': '긍정적인 마음을 유지하세요.',
    };
  }

  /// 테스트용 타로 카드 데이터
  static Map<String, dynamic> createTarotCard({
    int index = 0,
    String name = 'The Fool',
    String nameKo = '바보',
    bool isReversed = false,
  }) {
    return {
      'index': index,
      'name': name,
      'nameKo': nameKo,
      'isReversed': isReversed,
      'meaning': isReversed ? '역방향 의미' : '정방향 의미',
      'imagePath': 'assets/images/tarot/decks/rider_waite/major/$index.jpg',
    };
  }

  /// 테스트용 토큰 잔액
  static Map<String, dynamic> createTokenBalance({
    int remainingTokens = 10,
    int usedTokens = 5,
    bool hasUnlimitedAccess = false,
  }) {
    return {
      'remainingTokens': remainingTokens,
      'usedTokens': usedTokens,
      'totalTokens': remainingTokens + usedTokens,
      'hasUnlimitedAccess': hasUnlimitedAccess,
    };
  }
}

/// Golden Test 헬퍼 (스크린샷 비교)
class GoldenTestHelper {
  static Future<void> compareGolden(
    WidgetTester tester,
    Widget widget,
    String goldenFileName,
  ) async {
    await tester.pumpWidget(createTestableWidget(widget));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$goldenFileName.png'),
    );
  }
}

/// 접근성 테스트 헬퍼
class AccessibilityTestHelper {
  /// Semantics 레이블 확인
  static void expectSemanticLabel(WidgetTester tester, String label) {
    expect(
      find.bySemanticsLabel(label),
      findsOneWidget,
      reason: 'Semantic label "$label" should exist for accessibility',
    );
  }

  /// 탭 가능한 요소 크기 확인 (최소 44x44)
  static void expectTappableSize(WidgetTester tester, Finder finder) {
    final element = finder.evaluate().first;
    final renderBox = element.renderObject as RenderBox;
    final size = renderBox.size;

    expect(
      size.width >= 44 && size.height >= 44,
      isTrue,
      reason: 'Tappable element should be at least 44x44 for accessibility',
    );
  }
}
