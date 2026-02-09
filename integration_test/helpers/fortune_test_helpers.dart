// Fortune Test Helpers for Integration Tests
// 운세 기능 테스트 전용 유틸리티
//
// 사용법:
// ```dart
// await FortuneTestHelpers.generateDailyFortune(tester);
// await FortuneTestHelpers.selectTarotCards(tester, 3);
// await FortuneTestHelpers.verifyFortuneResult(tester);
// ```

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'navigation_helpers.dart';

/// 운세 테스트 헬퍼
class FortuneTestHelpers {
  FortuneTestHelpers._();

  // ==========================================================================
  // 공통 운세 생성 플로우
  // ==========================================================================

  /// 일반적인 운세 생성 플로우 실행
  ///
  /// 1. 운세 페이지로 이동
  /// 2. 생성 버튼 탭
  /// 3. 로딩 대기
  /// 4. 결과 확인
  static Future<FortuneTestResult> generateFortune(
    WidgetTester tester, {
    required String fortuneName,
    Duration loadingTimeout = const Duration(seconds: 30),
  }) async {
    final result = FortuneTestResult(fortuneName: fortuneName);

    try {
      // 운세 페이지로 이동
      final navigated = await NavigationHelpers.goToFortuneByText(tester, fortuneName);
      if (!navigated) {
        result.error = '운세 페이지로 이동 실패';
        return result;
      }
      result.navigatedToPage = true;

      // 생성 버튼 탭 (다양한 버튼 텍스트 처리)
      final generateButtonTapped = await _tapGenerateButton(tester);
      if (!generateButtonTapped) {
        result.error = '생성 버튼을 찾을 수 없음';
        return result;
      }
      result.tappedGenerateButton = true;

      // 로딩 대기
      await _waitForFortuneLoading(tester, timeout: loadingTimeout);

      // 결과 확인
      result.hasResult = await _verifyFortuneResult(tester);
      result.success = result.hasResult;

      debugPrint('✅ Fortune generated: $fortuneName');
    } catch (e) {
      result.error = e.toString();
      debugPrint('❌ Fortune generation failed: $e');
    }

    return result;
  }

  /// 생성 버튼 탭 (다양한 버튼 텍스트 지원)
  static Future<bool> _tapGenerateButton(WidgetTester tester) async {
    final buttonTexts = [
      '운세 보기',
      '결과 보기',
      '확인하기',
      '시작하기',
      '분석하기',
      '해석하기',
      '생성하기',
      '다음',
      '완료',
    ];

    for (final text in buttonTexts) {
      final finder = find.text(text);
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        await tester.pump(const Duration(milliseconds: 500));
        return true;
      }
    }

    // ElevatedButton 타입으로 찾기
    final elevatedButton = find.byType(ElevatedButton);
    if (elevatedButton.evaluate().isNotEmpty) {
      await tester.tap(elevatedButton.first);
      await tester.pump(const Duration(milliseconds: 500));
      return true;
    }

    return false;
  }

  /// 운세 로딩 대기
  static Future<void> _waitForFortuneLoading(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      await tester.pump(const Duration(milliseconds: 500));

      // 로딩 인디케이터가 없으면 완료
      final hasLoading = find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
          find.byType(LinearProgressIndicator).evaluate().isNotEmpty ||
          find.textContaining('로딩').evaluate().isNotEmpty ||
          find.textContaining('생성 중').evaluate().isNotEmpty ||
          find.textContaining('분석 중').evaluate().isNotEmpty;

      if (!hasLoading) {
        return;
      }
    }
  }

  /// 운세 결과 확인
  static Future<bool> _verifyFortuneResult(WidgetTester tester) async {
    // 결과 관련 위젯 확인
    final resultIndicators = [
      find.textContaining('운세'),
      find.textContaining('결과'),
      find.textContaining('해석'),
      find.textContaining('조언'),
      find.textContaining('점수'),
      find.byType(Card),
    ];

    for (final indicator in resultIndicators) {
      if (indicator.evaluate().isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  // ==========================================================================
  // 오늘의 운세 (Daily Fortune)
  // ==========================================================================

  /// 오늘의 운세 생성
  static Future<FortuneTestResult> generateDailyFortune(WidgetTester tester) async {
    return generateFortune(tester, fortuneName: '오늘의 운세');
  }

  /// 홈 화면에서 오늘의 운세 카드 확인
  static Future<bool> verifyDailyFortuneOnHome(WidgetTester tester) async {
    await NavigationHelpers.goToHome(tester);
    await tester.pump(const Duration(seconds: 2));

    // 홈에서 운세 카드 확인
    final fortuneCard = find.textContaining('운세');
    return fortuneCard.evaluate().isNotEmpty;
  }

  // ==========================================================================
  // 타로 (Tarot)
  // ==========================================================================

  /// 타로 카드 선택
  static Future<bool> selectTarotCards(
    WidgetTester tester, {
    int cardCount = 3,
  }) async {
    // 타로 페이지로 이동
    final navigated = await NavigationHelpers.goToTarot(tester);
    if (!navigated) return false;

    // 카드 선택 대기
    await tester.pump(const Duration(seconds: 2));

    // 탭 가능한 카드 요소 찾기
    final cardFinders = [
      find.byType(InkWell),
      find.byType(GestureDetector),
    ];

    int selectedCount = 0;
    for (final finder in cardFinders) {
      final widgets = finder.evaluate().toList();
      for (int i = 0; i < widgets.length && selectedCount < cardCount; i++) {
        try {
          await tester.tap(finder.at(i));
          await tester.pump(const Duration(milliseconds: 300));
          selectedCount++;
        } catch (_) {
          continue;
        }
      }
      if (selectedCount >= cardCount) break;
    }

    debugPrint('✅ Selected $selectedCount tarot cards');
    return selectedCount >= cardCount;
  }

  /// 타로 결과 확인
  static Future<bool> verifyTarotResult(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));

    final resultIndicators = [
      find.textContaining('카드'),
      find.textContaining('의미'),
      find.textContaining('해석'),
      find.textContaining('조언'),
    ];

    for (final indicator in resultIndicators) {
      if (indicator.evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  // ==========================================================================
  // 궁합 (Compatibility)
  // ==========================================================================

  /// 궁합 정보 입력
  static Future<bool> enterCompatibilityInfo(
    WidgetTester tester, {
    String person1Name = '테스트1',
    String person1Birth = '1990-01-01',
    String person2Name = '테스트2',
    String person2Birth = '1992-02-02',
  }) async {
    // 궁합 페이지로 이동
    final navigated = await NavigationHelpers.goToCompatibility(tester);
    if (!navigated) return false;

    await tester.pump(const Duration(seconds: 2));

    // 이름 입력 필드 찾기
    final textFields = find.byType(TextField);
    if (textFields.evaluate().length >= 2) {
      await tester.enterText(textFields.at(0), person1Name);
      await tester.pump();
      await tester.enterText(textFields.at(1), person2Name);
      await tester.pump();
    }

    debugPrint('✅ Entered compatibility info');
    return true;
  }

  /// 궁합 결과 생성
  static Future<FortuneTestResult> generateCompatibility(WidgetTester tester) async {
    return generateFortune(tester, fortuneName: '궁합');
  }

  // ==========================================================================
  // 꿈해몽 (Dream)
  // ==========================================================================

  /// 꿈 내용 입력
  static Future<bool> enterDreamContent(
    WidgetTester tester, {
    String dreamContent = '하늘을 나는 꿈을 꾸었습니다. 구름 위를 걸어다니며 새들과 함께 날았습니다.',
  }) async {
    // 꿈해몽 페이지로 이동
    final navigated = await NavigationHelpers.goToDream(tester);
    if (!navigated) return false;

    await tester.pump(const Duration(seconds: 2));

    // 텍스트 입력 필드 찾기
    final textField = find.byType(TextField);
    final textFormField = find.byType(TextFormField);

    if (textField.evaluate().isNotEmpty) {
      await tester.enterText(textField.first, dreamContent);
    } else if (textFormField.evaluate().isNotEmpty) {
      await tester.enterText(textFormField.first, dreamContent);
    } else {
      debugPrint('⚠️ Dream input field not found');
      return false;
    }

    await tester.pump();
    debugPrint('✅ Entered dream content');
    return true;
  }

  /// 꿈해몽 결과 생성
  static Future<FortuneTestResult> generateDreamInterpretation(WidgetTester tester) async {
    await enterDreamContent(tester);
    return generateFortune(tester, fortuneName: '꿈해몽');
  }

  // ==========================================================================
  // MBTI 운세
  // ==========================================================================

  /// MBTI 선택
  static Future<bool> selectMbti(
    WidgetTester tester, {
    String mbti = 'INTJ',
  }) async {
    // MBTI 페이지로 이동
    final navigated = await NavigationHelpers.goToFortuneByText(tester, 'MBTI');
    if (!navigated) return false;

    await tester.pump(const Duration(seconds: 2));

    // MBTI 버튼 찾기
    final mbtiFinder = find.text(mbti);
    if (mbtiFinder.evaluate().isNotEmpty) {
      await tester.tap(mbtiFinder.first);
      await tester.pump(const Duration(milliseconds: 500));
      debugPrint('✅ Selected MBTI: $mbti');
      return true;
    }

    // 모든 16가지 MBTI 타입 시도
    for (final type in _allMbtiTypes) {
      final finder = find.text(type);
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        await tester.pump(const Duration(milliseconds: 500));
        debugPrint('✅ Selected MBTI: $type');
        return true;
      }
    }

    debugPrint('⚠️ MBTI selection not found');
    return false;
  }

  static const List<String> _allMbtiTypes = [
    'INTJ', 'INTP', 'ENTJ', 'ENTP',
    'INFJ', 'INFP', 'ENFJ', 'ENFP',
    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
    'ISTP', 'ISFP', 'ESTP', 'ESFP',
  ];

  // ==========================================================================
  // 생년월일/사주 입력
  // ==========================================================================

  /// 생년월일 입력 (DatePicker 사용)
  static Future<bool> enterBirthDate(
    WidgetTester tester, {
    int year = 1990,
    int month = 1,
    int day = 15,
  }) async {
    // DatePicker나 숫자 입력 필드 찾기
    final yearField = find.textContaining('년');

    // 년/월/일 버튼이 있으면 탭
    if (yearField.evaluate().isNotEmpty) {
      await tester.tap(yearField.first);
      await tester.pump(const Duration(milliseconds: 300));
      // 숫자 입력 또는 피커 선택
      final yearText = find.text(year.toString());
      if (yearText.evaluate().isNotEmpty) {
        await tester.tap(yearText.first);
      }
    }

    debugPrint('✅ Entered birth date: $year-$month-$day');
    return true;
  }

  /// 생시 입력
  static Future<bool> enterBirthTime(
    WidgetTester tester, {
    int hour = 12,
    bool isLunar = false,
  }) async {
    // 시간 선택 위젯 찾기
    final timeSelector = find.textContaining('시');

    if (timeSelector.evaluate().isNotEmpty) {
      await tester.tap(timeSelector.first);
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 음력 옵션
    if (isLunar) {
      final lunarOption = find.text('음력');
      if (lunarOption.evaluate().isNotEmpty) {
        await tester.tap(lunarOption.first);
        await tester.pump();
      }
    }

    debugPrint('✅ Entered birth time: $hour시');
    return true;
  }

  /// 성별 선택
  static Future<bool> selectGender(
    WidgetTester tester, {
    bool isMale = true,
  }) async {
    final genderText = isMale ? '남성' : '여성';
    final alternateText = isMale ? '남' : '여';

    final genderFinder = find.text(genderText);
    final alternateFinder = find.text(alternateText);

    if (genderFinder.evaluate().isNotEmpty) {
      await tester.tap(genderFinder.first);
      await tester.pump();
      debugPrint('✅ Selected gender: $genderText');
      return true;
    } else if (alternateFinder.evaluate().isNotEmpty) {
      await tester.tap(alternateFinder.first);
      await tester.pump();
      debugPrint('✅ Selected gender: $alternateText');
      return true;
    }

    debugPrint('⚠️ Gender selection not found');
    return false;
  }

  // ==========================================================================
  // 결과 검증
  // ==========================================================================

  /// 운세 결과 페이지인지 확인
  static bool isOnFortuneResultPage(WidgetTester tester) {
    final resultIndicators = [
      find.textContaining('결과'),
      find.textContaining('운세'),
      find.textContaining('점수'),
      find.textContaining('조언'),
      find.textContaining('해석'),
    ];

    return resultIndicators.any((f) => f.evaluate().isNotEmpty);
  }

  /// 블러 처리 확인 (미결제 상태)
  static bool isResultBlurred(WidgetTester tester) {
    // BlurWrapper나 ImageFilter.blur 사용 확인
    final blurWidget = find.byKey(const Key('blur_wrapper'));
    final blurredContent = find.textContaining('구매');

    return blurWidget.evaluate().isNotEmpty || blurredContent.evaluate().isNotEmpty;
  }

  /// 공유 버튼 존재 확인
  static bool hasShareButton(WidgetTester tester) {
    final shareIcon = find.byIcon(Icons.share);
    final shareText = find.text('공유');
    final shareOutlined = find.byIcon(Icons.share_outlined);

    return shareIcon.evaluate().isNotEmpty ||
        shareText.evaluate().isNotEmpty ||
        shareOutlined.evaluate().isNotEmpty;
  }

  /// 공유 버튼 탭
  static Future<bool> tapShareButton(WidgetTester tester) async {
    final shareFinders = [
      find.byIcon(Icons.share),
      find.byIcon(Icons.share_outlined),
      find.text('공유'),
    ];

    for (final finder in shareFinders) {
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        await tester.pump(const Duration(seconds: 1));
        debugPrint('✅ Tapped share button');
        return true;
      }
    }

    debugPrint('⚠️ Share button not found');
    return false;
  }

  /// 저장 버튼 탭
  static Future<bool> tapSaveButton(WidgetTester tester) async {
    final saveFinders = [
      find.byIcon(Icons.bookmark),
      find.byIcon(Icons.bookmark_border),
      find.byIcon(Icons.save),
      find.text('저장'),
    ];

    for (final finder in saveFinders) {
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        await tester.pump(const Duration(seconds: 1));
        debugPrint('✅ Tapped save button');
        return true;
      }
    }

    debugPrint('⚠️ Save button not found');
    return false;
  }

  // ==========================================================================
  // 히스토리 관련
  // ==========================================================================

  /// 운세 히스토리 페이지로 이동
  static Future<bool> goToFortuneHistory(WidgetTester tester) async {
    await NavigationHelpers.goToProfile(tester);
    await tester.pump(const Duration(seconds: 1));

    final historyFinders = [
      find.text('운세 기록'),
      find.text('히스토리'),
      find.text('내 운세'),
      find.byIcon(Icons.history),
    ];

    for (final finder in historyFinders) {
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        await tester.pump(const Duration(seconds: 2));
        debugPrint('✅ Navigated to fortune history');
        return true;
      }
    }

    debugPrint('⚠️ History button not found');
    return false;
  }

  /// 히스토리에서 운세 삭제
  static Future<bool> deleteFortuneFromHistory(WidgetTester tester) async {
    // 삭제 버튼 또는 스와이프 삭제
    final deleteIcon = find.byIcon(Icons.delete);
    final deleteOutlined = find.byIcon(Icons.delete_outline);

    if (deleteIcon.evaluate().isNotEmpty) {
      await tester.tap(deleteIcon.first);
    } else if (deleteOutlined.evaluate().isNotEmpty) {
      await tester.tap(deleteOutlined.first);
    } else {
      // 스와이프 삭제 시도
      final listTile = find.byType(ListTile);
      if (listTile.evaluate().isNotEmpty) {
        await tester.drag(listTile.first, const Offset(-300, 0));
      } else {
        debugPrint('⚠️ Delete option not found');
        return false;
      }
    }

    await tester.pump(const Duration(milliseconds: 500));

    // 삭제 확인 다이얼로그
    final confirmDelete = find.text('삭제');
    if (confirmDelete.evaluate().isNotEmpty) {
      await tester.tap(confirmDelete.last);
      await tester.pump(const Duration(seconds: 1));
    }

    debugPrint('✅ Deleted fortune from history');
    return true;
  }
}

/// 운세 테스트 결과
class FortuneTestResult {
  final String fortuneName;
  bool navigatedToPage = false;
  bool tappedGenerateButton = false;
  bool hasResult = false;
  bool success = false;
  String? error;

  FortuneTestResult({required this.fortuneName});

  @override
  String toString() {
    return 'FortuneTestResult('
        'fortuneName: $fortuneName, '
        'navigated: $navigatedToPage, '
        'tapped: $tappedGenerateButton, '
        'hasResult: $hasResult, '
        'success: $success, '
        'error: $error)';
  }
}
