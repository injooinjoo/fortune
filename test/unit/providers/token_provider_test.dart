import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/presentation/providers/token_provider.dart';
import 'package:fortune/domain/entities/token.dart';

void main() {
  // Helper to create TokenBalance with required fields
  TokenBalance createBalance({
    String userId = 'test-user-id',
    int remainingTokens = 10,
    int usedTokens = 5,
    int totalTokens = 15,
    bool hasUnlimitedAccess = false,
  }) {
    return TokenBalance(
      userId: userId,
      remainingTokens: remainingTokens,
      usedTokens: usedTokens,
      totalTokens: totalTokens,
      lastUpdated: DateTime.now(),
      hasUnlimitedAccess: hasUnlimitedAccess,
    );
  }

  group('TokenState', () {
    test('초기 상태가 올바르게 생성되어야 함', () {
      const state = TokenState();

      expect(state.balance, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.packages, isEmpty);
      expect(state.history, isEmpty);
      expect(state.subscription, isNull);
      expect(state.isConsumingToken, false);
    });

    test('기본 소비율이 설정되어야 함', () {
      const state = TokenState();

      // Simple fortunes (1 token)
      expect(state.consumptionRates['daily'], 1);
      expect(state.consumptionRates['today'], 1);
      expect(state.consumptionRates['tomorrow'], 1);

      // Medium complexity (2 tokens)
      expect(state.consumptionRates['love'], 2);
      expect(state.consumptionRates['career'], 2);
      expect(state.consumptionRates['tarot'], 2);

      // Complex fortunes (3 tokens)
      expect(state.consumptionRates['saju'], 3);
      expect(state.consumptionRates['traditional-saju'], 3);

      // Premium fortunes (5 tokens)
      expect(state.consumptionRates['startup'], 5);
      expect(state.consumptionRates['celebrity-match'], 5);
    });

    test('copyWith으로 balance를 설정할 수 있어야 함', () {
      const state = TokenState();
      final balance = createBalance(
        remainingTokens: 10,
        usedTokens: 5,
        totalTokens: 15,
      );

      final newState = state.copyWith(balance: balance);

      expect(newState.balance, isNotNull);
      expect(newState.balance!.remainingTokens, 10);
      expect(newState.balance!.usedTokens, 5);
      expect(newState.balance!.totalTokens, 15);
    });

    test('hasUnlimitedTokens가 올바르게 동작해야 함', () {
      // 프로필 없으면 무제한 토큰 없음
      const state1 = TokenState();
      expect(state1.hasUnlimitedTokens, false);

      // 테스트 계정이 아니면 무제한 토큰 없음
      final balance = createBalance(
        remainingTokens: 0,
        usedTokens: 0,
        totalTokens: 0,
        hasUnlimitedAccess: true,
      );
      final state2 = state1.copyWith(balance: balance);
      expect(state2.hasUnlimitedTokens, false); // userProfile이 필요함
    });

    test('canConsumeTokens가 올바르게 동작해야 함', () {
      final balance = createBalance(
        remainingTokens: 5,
        usedTokens: 10,
        totalTokens: 15,
      );
      final state = const TokenState().copyWith(balance: balance);

      // 토큰 충분
      expect(state.canConsumeTokens(1), true);
      expect(state.canConsumeTokens(5), true);

      // 토큰 부족
      expect(state.canConsumeTokens(6), false);
      expect(state.canConsumeTokens(10), false);
    });

    test('무제한 접근 시 항상 canConsumeTokens가 true여야 함', () {
      final balance = createBalance(
        remainingTokens: 0,
        usedTokens: 0,
        totalTokens: 0,
        hasUnlimitedAccess: true,
      );
      final state = const TokenState().copyWith(balance: balance);

      expect(state.canConsumeTokens(100), true);
      expect(state.canConsumeTokens(1000), true);
    });

    test('getTokensForFortuneType가 올바르게 동작해야 함', () {
      const state = TokenState();

      expect(state.getTokensForFortuneType('daily'), 1);
      expect(state.getTokensForFortuneType('saju'), 3);
      expect(state.getTokensForFortuneType('startup'), 5);

      // 정의되지 않은 운세 타입은 기본값 1
      expect(state.getTokensForFortuneType('unknown'), 1);
    });

    test('currentTokens getter가 올바르게 동작해야 함', () {
      // balance가 null인 경우
      const state1 = TokenState();
      expect(state1.currentTokens, 0);

      // balance가 있는 경우
      final balance = createBalance(
        remainingTokens: 25,
        usedTokens: 10,
        totalTokens: 35,
      );
      final state2 = state1.copyWith(balance: balance);
      expect(state2.currentTokens, 25);
    });

    test('isConsumingToken 상태가 올바르게 변경되어야 함', () {
      const state1 = TokenState();
      expect(state1.isConsumingToken, false);

      final state2 = state1.copyWith(isConsumingToken: true);
      expect(state2.isConsumingToken, true);

      final state3 = state2.copyWith(isConsumingToken: false);
      expect(state3.isConsumingToken, false);
    });

    test('error 상태가 올바르게 관리되어야 함', () {
      const state1 = TokenState();
      expect(state1.error, isNull);

      // INSUFFICIENT_TOKENS 에러
      final state2 = state1.copyWith(error: 'INSUFFICIENT_TOKENS');
      expect(state2.error, 'INSUFFICIENT_TOKENS');

      // 에러 클리어 (null로 설정)
      final state3 = state2.copyWith(error: null);
      expect(state3.error, isNull);
    });

    test('로딩 → 성공 플로우가 올바르게 동작해야 함', () {
      // 초기 상태
      const state1 = TokenState();

      // 로딩 시작
      final state2 = state1.copyWith(isLoading: true, error: null);
      expect(state2.isLoading, true);

      // 성공
      final balance = createBalance(
        remainingTokens: 10,
        usedTokens: 5,
        totalTokens: 15,
      );
      final state3 = state2.copyWith(isLoading: false, balance: balance);
      expect(state3.isLoading, false);
      expect(state3.balance, isNotNull);
      expect(state3.error, isNull);
    });

    test('토큰 소비 낙관적 업데이트 플로우', () {
      // 초기 상태 (10개 토큰)
      final balance = createBalance(
        remainingTokens: 10,
        usedTokens: 5,
        totalTokens: 15,
      );
      final state1 = const TokenState().copyWith(balance: balance);

      // 소비 시작
      final state2 = state1.copyWith(isConsumingToken: true);
      expect(state2.isConsumingToken, true);

      // 낙관적 업데이트 (3개 소비)
      final newBalance = createBalance(
        remainingTokens: 7,
        usedTokens: 8,
        totalTokens: 15,
      );
      final state3 = state2.copyWith(
        balance: newBalance,
        isConsumingToken: false,
      );

      expect(state3.balance!.remainingTokens, 7);
      expect(state3.balance!.usedTokens, 8);
      expect(state3.isConsumingToken, false);
    });
  });

  group('TokenBalance', () {
    test('TokenBalance가 올바르게 생성되어야 함', () {
      final balance = createBalance(
        remainingTokens: 10,
        usedTokens: 5,
        totalTokens: 15,
      );

      expect(balance.remainingTokens, 10);
      expect(balance.usedTokens, 5);
      expect(balance.totalTokens, 15);
      expect(balance.hasUnlimitedAccess, false);
    });

    test('copyWith으로 remainingTokens를 변경할 수 있어야 함', () {
      final balance1 = createBalance(
        remainingTokens: 10,
        usedTokens: 5,
        totalTokens: 15,
      );

      final balance2 = balance1.copyWith(
        remainingTokens: 7,
        usedTokens: 8,
      );

      expect(balance2.remainingTokens, 7);
      expect(balance2.usedTokens, 8);
      expect(balance2.totalTokens, 15); // 변경되지 않음
    });

    test('hasEnoughTokens getter가 올바르게 동작해야 함', () {
      // 토큰이 있는 경우
      final balance1 = createBalance(remainingTokens: 5);
      expect(balance1.hasEnoughTokens, true);

      // 토큰이 없는 경우
      final balance2 = createBalance(remainingTokens: 0);
      expect(balance2.hasEnoughTokens, false);

      // 무제한 접근인 경우
      final balance3 = createBalance(remainingTokens: 0, hasUnlimitedAccess: true);
      expect(balance3.hasEnoughTokens, true);
    });
  });
}
