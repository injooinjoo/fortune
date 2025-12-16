// Psychology Test Providers
//
// 심리 테스트 상태 관리 (StateNotifier & Providers)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/psychology_test_models.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../data/services/fortune_api_service.dart';
import '../../../../presentation/providers/token_provider.dart';

final psychologyTestProvider = StateNotifierProvider.family<PsychologyTestNotifier, AsyncValue<PsychologyTestResult?>, PsychologyTestInput>(
  (ref, input) => PsychologyTestNotifier(ref, input));

class PsychologyTestNotifier extends StateNotifier<AsyncValue<PsychologyTestResult?>> {
  final Ref ref;
  final PsychologyTestInput input;

  PsychologyTestNotifier(this.ref, this.input) : super(const AsyncValue.loading()) {
    _analyzeTest();
  }

  Future<void> _analyzeTest() async {
    try {
      final apiService = ref.read(fortuneApiServiceProvider);
      final tokenService = ref.read(tokenProvider.notifier);

      // Check token balance
      final hasEnoughTokens = await tokenService.checkAndConsumeTokens(
        3,
        'psychology-test');

      if (!hasEnoughTokens) {
        state = AsyncValue.error(
          Exception('복주머니가 부족합니다'),
          StackTrace.current);
        return;
      }

      final response = await apiService.post(
        ApiEndpoints.generateFortune,
        data: {
          'type': 'psychology-test',
          'userInfo': {
            'name': input.name,
            'birth_date': input.birthDate,
            'answers': input.answers,
          },
        },
      );

      if (response['success'] == true) {
        state = AsyncValue.data(PsychologyTestResult.fromJson(response));
      } else {
        throw Exception(response['error'] ?? '심리 테스트 분석에 실패했습니다');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
