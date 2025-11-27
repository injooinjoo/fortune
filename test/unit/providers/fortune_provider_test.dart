import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/presentation/providers/fortune_provider.dart';
import 'package:fortune/domain/entities/fortune.dart';

void main() {
  group('FortuneState', () {
    test('초기 상태가 올바르게 생성되어야 함', () {
      const state = FortuneState();

      expect(state.isLoading, false);
      expect(state.fortune, isNull);
      expect(state.error, isNull);
    });

    test('copyWith으로 isLoading 상태를 변경할 수 있어야 함', () {
      const state = FortuneState();
      final newState = state.copyWith(isLoading: true);

      expect(newState.isLoading, true);
      expect(newState.fortune, isNull);
      expect(newState.error, isNull);
    });

    test('copyWith으로 fortune을 설정할 수 있어야 함', () {
      const state = FortuneState();
      final fortune = Fortune(
        id: 'test-id',
        userId: 'test-user-id',
        type: 'daily',
        content: '오늘의 운세입니다.',
        overallScore: 85,
        description: '좋은 하루가 될 것입니다.',
        luckyItems: {'행운의 숫자': '7'},
        recommendations: ['긍정적인 마음을 유지하세요'],
        category: 'general',
        createdAt: DateTime.now(),
      );

      final newState = state.copyWith(fortune: fortune);

      expect(newState.fortune, isNotNull);
      expect(newState.fortune!.id, 'test-id');
      expect(newState.fortune!.type, 'daily');
      expect(newState.fortune!.overallScore, 85);
      expect(newState.isLoading, false);
    });

    test('copyWith으로 error를 설정할 수 있어야 함', () {
      const state = FortuneState();
      final newState = state.copyWith(error: '로그인이 필요합니다');

      expect(newState.error, '로그인이 필요합니다');
      expect(newState.isLoading, false);
      expect(newState.fortune, isNull);
    });

    test('로딩 → 성공 플로우가 올바르게 동작해야 함', () {
      // 초기 상태
      const state1 = FortuneState();
      expect(state1.isLoading, false);

      // 로딩 시작
      final state2 = state1.copyWith(isLoading: true, error: null);
      expect(state2.isLoading, true);
      expect(state2.error, isNull);

      // 성공
      final fortune = Fortune(
        id: 'test-id',
        userId: 'test-user-id',
        type: 'daily',
        content: '운세 내용',
        overallScore: 90,
        description: '설명',
        luckyItems: {},
        recommendations: [],
        category: 'general',
        createdAt: DateTime.now(),
      );

      final state3 = state2.copyWith(isLoading: false, fortune: fortune);
      expect(state3.isLoading, false);
      expect(state3.fortune, isNotNull);
      expect(state3.error, isNull);
    });

    test('로딩 → 실패 플로우가 올바르게 동작해야 함', () {
      // 초기 상태
      const state1 = FortuneState();

      // 로딩 시작
      final state2 = state1.copyWith(isLoading: true, error: null);
      expect(state2.isLoading, true);

      // 실패
      final state3 = state2.copyWith(
        isLoading: false,
        error: '네트워크 오류가 발생했습니다',
      );
      expect(state3.isLoading, false);
      expect(state3.fortune, isNull);
      expect(state3.error, '네트워크 오류가 발생했습니다');
    });
  });

  group('FortuneGenerationParams', () {
    test('파라미터가 올바르게 생성되어야 함', () {
      final params = FortuneGenerationParams(
        fortuneType: 'daily',
        userInfo: {
          'birthDate': '1990-01-01',
          'gender': 'male',
        },
      );

      expect(params.fortuneType, 'daily');
      expect(params.userInfo['birthDate'], '1990-01-01');
      expect(params.userInfo['gender'], 'male');
    });

    test('다양한 운세 타입 파라미터 생성', () {
      final sajuParams = FortuneGenerationParams(
        fortuneType: 'saju',
        userInfo: {
          'birthDate': '1990-01-01',
          'birthTime': '09:00',
          'isLunar': false,
        },
      );

      expect(sajuParams.fortuneType, 'saju');
      expect(sajuParams.userInfo['birthTime'], '09:00');
      expect(sajuParams.userInfo['isLunar'], false);
    });
  });
}
