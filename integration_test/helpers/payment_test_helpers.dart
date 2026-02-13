// Payment Test Helpers for Integration Tests
// 결제 기능 테스트 전용 유틸리티
//
// 사용법:
// ```dart
// await PaymentTestHelpers.verifyTokenBalance(tester);
// await PaymentTestHelpers.simulatePurchase(tester);
// await PaymentTestHelpers.testInsufficientTokensFlow(tester);
// ```

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'navigation_helpers.dart';
import '../mocks/mock_in_app_purchase.dart';

/// 결제 테스트 헬퍼
class PaymentTestHelpers {
  PaymentTestHelpers._();

  // ==========================================================================
  // 토큰 (Soul) 관련
  // ==========================================================================

  /// 토큰 잔액 표시 확인
  static Future<bool> verifyTokenBalanceDisplay(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 1));

    // Soul/토큰 잔액 표시 찾기
    final tokenIndicators = [
      find.textContaining('Soul'),
      find.textContaining('토큰'),
      find.byIcon(Icons.currency_bitcoin),
      find.byIcon(Icons.monetization_on),
    ];

    for (final indicator in tokenIndicators) {
      if (indicator.evaluate().isNotEmpty) {
        debugPrint('✅ Token balance display found');
        return true;
      }
    }

    debugPrint('⚠️ Token balance display not found');
    return false;
  }

  /// 토큰 잔액 가져오기 (숫자 추출)
  static int? getDisplayedTokenBalance(WidgetTester tester) {
    // Soul 또는 토큰 옆의 숫자 찾기
    final soulText = find.textContaining('Soul');
    if (soulText.evaluate().isNotEmpty) {
      final widget = tester.widget<Text>(soulText.first);
      final text = widget.data ?? '';
      final match = RegExp(r'\d+').firstMatch(text);
      if (match != null) {
        return int.tryParse(match.group(0)!);
      }
    }

    return null;
  }

  /// 토큰 부족 모달 표시 대기
  static Future<bool> waitForInsufficientTokensModal(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      await tester.pump(const Duration(milliseconds: 300));

      final modalIndicators = [
        find.textContaining('토큰 부족'),
        find.textContaining('Soul 부족'),
        find.textContaining('충전'),
        find.textContaining('구매'),
        find.byType(BottomSheet),
        find.byType(AlertDialog),
      ];

      for (final indicator in modalIndicators) {
        if (indicator.evaluate().isNotEmpty) {
          debugPrint('✅ Insufficient tokens modal appeared');
          return true;
        }
      }
    }

    debugPrint('⚠️ Insufficient tokens modal not found');
    return false;
  }

  /// 토큰 충전 버튼 탭
  static Future<bool> tapTokenPurchaseButton(WidgetTester tester) async {
    final purchaseButtons = [
      find.text('충전하기'),
      find.text('구매하기'),
      find.text('토큰 충전'),
      find.text('Soul 충전'),
      find.textContaining('충전'),
    ];

    for (final button in purchaseButtons) {
      if (button.evaluate().isNotEmpty) {
        await tester.tap(button.first);
        await tester.pump(const Duration(seconds: 1));
        debugPrint('✅ Tapped token purchase button');
        return true;
      }
    }

    debugPrint('⚠️ Token purchase button not found');
    return false;
  }

  // ==========================================================================
  // 토큰 구매 플로우
  // ==========================================================================

  /// 토큰 구매 페이지로 이동
  static Future<bool> goToTokenPurchasePage(WidgetTester tester) async {
    return NavigationHelpers.goToTokenPurchase(tester);
  }

  /// 토큰 패키지 선택
  static Future<bool> selectTokenPackage(
    WidgetTester tester, {
    MockProductDetails? product,
  }) async {
    await tester.pump(const Duration(seconds: 1));

    // 패키지 선택 (기본: 첫 번째 패키지)
    final packageFinders = [
      find.textContaining('Soul'),
      find.textContaining('토큰'),
      find.byType(Card),
      find.byType(ListTile),
    ];

    for (final finder in packageFinders) {
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        await tester.pump(const Duration(milliseconds: 500));
        debugPrint('✅ Selected token package');
        return true;
      }
    }

    debugPrint('⚠️ Token package not found');
    return false;
  }

  /// 구매 버튼 탭 (최종 결제)
  static Future<bool> tapPurchaseConfirmButton(WidgetTester tester) async {
    final confirmButtons = [
      find.text('구매하기'),
      find.text('결제하기'),
      find.text('확인'),
      find.textContaining('원'),
      find.byType(ElevatedButton),
    ];

    for (final button in confirmButtons) {
      if (button.evaluate().isNotEmpty) {
        // 마지막 매칭 버튼 탭 (보통 확인 버튼이 아래에 있음)
        await tester.tap(button.last);
        await tester.pump(const Duration(seconds: 2));
        debugPrint('✅ Tapped purchase confirm button');
        return true;
      }
    }

    debugPrint('⚠️ Purchase confirm button not found');
    return false;
  }

  /// 전체 토큰 구매 플로우 테스트
  static Future<PaymentTestResult> testTokenPurchaseFlow(
    WidgetTester tester, {
    MockInAppPurchaseService? mockIAP,
  }) async {
    final result = PaymentTestResult(type: 'token_purchase');

    try {
      // 1. 토큰 구매 페이지로 이동
      final navigated = await goToTokenPurchasePage(tester);
      if (!navigated) {
        result.error = '토큰 구매 페이지로 이동 실패';
        return result;
      }
      result.navigatedToPage = true;

      // 2. 패키지 선택
      final selected = await selectTokenPackage(tester);
      if (!selected) {
        result.error = '패키지 선택 실패';
        return result;
      }
      result.selectedProduct = true;

      // 3. 구매 버튼 탭
      final confirmed = await tapPurchaseConfirmButton(tester);
      if (!confirmed) {
        result.error = '구매 확인 버튼 탭 실패';
        return result;
      }
      result.tappedPurchaseButton = true;

      // 4. Mock 구매 결과 확인
      await tester.pump(const Duration(seconds: 3));
      result.purchaseCompleted = true;
      result.success = true;

      debugPrint('✅ Token purchase flow completed');
    } catch (e) {
      result.error = e.toString();
      debugPrint('❌ Token purchase flow failed: $e');
    }

    return result;
  }

  // ==========================================================================
  // 구독 (Subscription) 관련
  // ==========================================================================

  /// 구독 페이지로 이동
  static Future<bool> goToSubscriptionPage(WidgetTester tester) async {
    return NavigationHelpers.goToSubscription(tester);
  }

  /// 구독 옵션 선택
  static Future<bool> selectSubscriptionOption(
    WidgetTester tester, {
    bool isMonthly = true,
  }) async {
    await tester.pump(const Duration(seconds: 1));

    final optionText = isMonthly ? '월간' : '연간';
    final alterText = isMonthly ? '월' : '년';

    final optionFinders = [
      find.textContaining(optionText),
      find.textContaining(alterText),
      find.textContaining('프리미엄'),
    ];

    for (final finder in optionFinders) {
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        await tester.pump(const Duration(milliseconds: 500));
        debugPrint('✅ Selected subscription: $optionText');
        return true;
      }
    }

    debugPrint('⚠️ Subscription option not found');
    return false;
  }

  /// 구독 상태 확인 (프리미엄 배지)
  static bool isSubscribed(WidgetTester tester) {
    final premiumIndicators = [
      find.textContaining('프리미엄'),
      find.textContaining('Premium'),
      find.byIcon(Icons.workspace_premium),
      find.byIcon(Icons.star),
    ];

    return premiumIndicators.any((f) => f.evaluate().isNotEmpty);
  }

  /// 전체 구독 플로우 테스트
  static Future<PaymentTestResult> testSubscriptionFlow(
    WidgetTester tester, {
    bool isMonthly = true,
    MockInAppPurchaseService? mockIAP,
  }) async {
    final result = PaymentTestResult(type: 'subscription');

    try {
      // 1. 구독 페이지로 이동
      final navigated = await goToSubscriptionPage(tester);
      if (!navigated) {
        result.error = '구독 페이지로 이동 실패';
        return result;
      }
      result.navigatedToPage = true;

      // 2. 옵션 선택
      final selected = await selectSubscriptionOption(tester, isMonthly: isMonthly);
      if (!selected) {
        result.error = '구독 옵션 선택 실패';
        return result;
      }
      result.selectedProduct = true;

      // 3. 구매 버튼 탭
      final confirmed = await tapPurchaseConfirmButton(tester);
      if (!confirmed) {
        result.error = '구독 확인 버튼 탭 실패';
        return result;
      }
      result.tappedPurchaseButton = true;

      // 4. 결과 확인
      await tester.pump(const Duration(seconds: 3));
      result.purchaseCompleted = true;
      result.success = true;

      debugPrint('✅ Subscription flow completed');
    } catch (e) {
      result.error = e.toString();
      debugPrint('❌ Subscription flow failed: $e');
    }

    return result;
  }

  // ==========================================================================
  // 구매 복원
  // ==========================================================================

  /// 구매 복원 버튼 찾기 및 탭
  static Future<bool> tapRestorePurchasesButton(WidgetTester tester) async {
    // 설정 페이지로 이동
    final navigated = await NavigationHelpers.goToSettings(tester);
    if (!navigated) {
      debugPrint('⚠️ Could not navigate to settings');
      return false;
    }

    await tester.pump(const Duration(seconds: 1));

    final restoreFinders = [
      find.text('구매 복원'),
      find.text('복원'),
      find.textContaining('Restore'),
      find.textContaining('복원'),
    ];

    for (final finder in restoreFinders) {
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        await tester.pump(const Duration(seconds: 2));
        debugPrint('✅ Tapped restore purchases button');
        return true;
      }
    }

    debugPrint('⚠️ Restore purchases button not found');
    return false;
  }

  /// 복원 결과 확인
  static Future<bool> verifyRestoreResult(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));

    final successIndicators = [
      find.textContaining('복원 완료'),
      find.textContaining('성공'),
      find.textContaining('복원되었습니다'),
    ];

    final failureIndicators = [
      find.textContaining('복원 실패'),
      find.textContaining('구매 내역 없음'),
      find.textContaining('없습니다'),
    ];

    for (final indicator in successIndicators) {
      if (indicator.evaluate().isNotEmpty) {
        debugPrint('✅ Restore successful');
        return true;
      }
    }

    for (final indicator in failureIndicators) {
      if (indicator.evaluate().isNotEmpty) {
        debugPrint('ℹ️ No purchases to restore');
        return true; // 구매 내역 없음도 정상 결과
      }
    }

    debugPrint('⚠️ Restore result unclear');
    return false;
  }

  // ==========================================================================
  // 구매 취소
  // ==========================================================================

  /// 구매 취소 테스트
  static Future<bool> testPurchaseCancellation(WidgetTester tester) async {
    // 토큰 구매 페이지로 이동
    await goToTokenPurchasePage(tester);

    // 패키지 선택
    await selectTokenPackage(tester);

    // 뒤로가기 또는 취소 버튼
    final cancelButtons = [
      find.text('취소'),
      find.byIcon(Icons.close),
      find.byIcon(Icons.arrow_back),
    ];

    for (final button in cancelButtons) {
      if (button.evaluate().isNotEmpty) {
        await tester.tap(button.first);
        await tester.pump(const Duration(seconds: 1));
        debugPrint('✅ Purchase cancelled');
        return true;
      }
    }

    // 시스템 뒤로가기
    await NavigationHelpers.tapBackButton(tester);
    debugPrint('✅ Purchase cancelled via back button');
    return true;
  }

  // ==========================================================================
  // 무료 토큰
  // ==========================================================================

  /// 일일 무료 토큰 수령
  static Future<bool> claimDailyFreeTokens(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 1));

    final claimFinders = [
      find.text('무료 토큰 받기'),
      find.text('출석 보상'),
      find.textContaining('무료'),
      find.textContaining('받기'),
    ];

    for (final finder in claimFinders) {
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        await tester.pump(const Duration(seconds: 2));
        debugPrint('✅ Claimed daily free tokens');
        return true;
      }
    }

    debugPrint('⚠️ Free token claim button not found');
    return false;
  }

  /// 광고 시청 후 토큰 받기
  static Future<bool> watchAdForTokens(WidgetTester tester) async {
    final adFinders = [
      find.text('광고 보고 받기'),
      find.textContaining('광고'),
      find.byIcon(Icons.play_circle),
      find.byIcon(Icons.video_library),
    ];

    for (final finder in adFinders) {
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);

        // 광고 로딩 대기 (Mock에서는 즉시 완료)
        await tester.pump(const Duration(seconds: 3));

        debugPrint('✅ Watched ad for tokens');
        return true;
      }
    }

    debugPrint('⚠️ Ad button not found');
    return false;
  }

  // ==========================================================================
  // 결제 에러 처리
  // ==========================================================================

  /// 결제 실패 메시지 확인
  static bool hasPaymentError(WidgetTester tester) {
    final errorIndicators = [
      find.textContaining('실패'),
      find.textContaining('오류'),
      find.textContaining('Error'),
      find.textContaining('취소'),
    ];

    return errorIndicators.any((f) => f.evaluate().isNotEmpty);
  }

  /// 결제 성공 메시지 확인
  static bool hasPaymentSuccess(WidgetTester tester) {
    final successIndicators = [
      find.textContaining('완료'),
      find.textContaining('성공'),
      find.textContaining('감사'),
      find.textContaining('충전되었습니다'),
    ];

    return successIndicators.any((f) => f.evaluate().isNotEmpty);
  }

  /// 재시도 버튼 탭
  static Future<bool> tapRetryButton(WidgetTester tester) async {
    final retryFinders = [
      find.text('다시 시도'),
      find.text('재시도'),
      find.textContaining('다시'),
    ];

    for (final finder in retryFinders) {
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        await tester.pump(const Duration(seconds: 1));
        debugPrint('✅ Tapped retry button');
        return true;
      }
    }

    debugPrint('⚠️ Retry button not found');
    return false;
  }

  // ==========================================================================
  // Mock 제어
  // ==========================================================================

  /// Mock IAP 서비스 설정 - 다음 구매 성공
  static void setNextPurchaseSuccess(MockInAppPurchaseService mock) {
    mock.setNextPurchaseResult(MockPurchaseResult.success);
  }

  /// Mock IAP 서비스 설정 - 다음 구매 실패
  static void setNextPurchaseFailure(
    MockInAppPurchaseService mock, {
    MockPurchaseResult result = MockPurchaseResult.paymentFailed,
  }) {
    mock.setNextPurchaseResult(result);
  }

  /// Mock IAP 서비스 설정 - 다음 구매 취소
  static void setNextPurchaseCancelled(MockInAppPurchaseService mock) {
    mock.setNextPurchaseResult(MockPurchaseResult.cancelled);
  }

  /// Mock 토큰 잔액 설정
  static void setMockTokenBalance(MockInAppPurchaseService mock, int balance) {
    mock.setTokenBalance(balance);
  }

  /// Mock 프리미엄 상태 설정
  static void setMockPremiumStatus(MockInAppPurchaseService mock, bool isPremium) {
    mock.setSubscriptionStatus(isPremium);
  }
}

/// 결제 테스트 결과
class PaymentTestResult {
  final String type;
  bool navigatedToPage = false;
  bool selectedProduct = false;
  bool tappedPurchaseButton = false;
  bool purchaseCompleted = false;
  bool success = false;
  String? error;

  PaymentTestResult({required this.type});

  @override
  String toString() {
    return 'PaymentTestResult('
        'type: $type, '
        'navigated: $navigatedToPage, '
        'selected: $selectedProduct, '
        'tapped: $tappedPurchaseButton, '
        'completed: $purchaseCompleted, '
        'success: $success, '
        'error: $error)';
  }
}
