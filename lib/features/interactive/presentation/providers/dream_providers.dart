// Dream Providers
//
// 꿈 관련 상태 관리 (StateNotifier & Providers)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/dream_models.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../presentation/providers/providers.dart';

// ============================================================================
// Dream Entry Providers (꿈 일기 - DreamPage)
// ============================================================================

// Provider for dream entries
final dreamEntriesProvider = StateNotifierProvider<DreamEntriesNotifier, List<DreamEntry>>(
  (ref) => DreamEntriesNotifier(),
);

// Provider for dream analysis
final dreamAnalysisProvider = StateNotifierProvider.family<DreamAnalysisNotifier, AsyncValue<DreamAnalysis?>, String>(
  (ref, dreamId) => DreamAnalysisNotifier(ref, dreamId),
);

// ============================================================================
// Dream Interpretation Providers (꿈 해몽 - DreamInterpretationPage)
// ============================================================================

final dreamInterpretationProvider = StateNotifierProvider.family<DreamInterpretationNotifier, AsyncValue<DreamAnalysisResult?>, DreamInput>(
  (ref, input) => DreamInterpretationNotifier(ref, input));

class DreamEntriesNotifier extends StateNotifier<List<DreamEntry>> {
  DreamEntriesNotifier() : super([]) {
    _loadEntries();
  }

  void _loadEntries() {
    // Load from local storage in real app
    state = [
      DreamEntry(
        id: '1',
        title: '하늘을 나는 꿈',
        content: '구름 위를 자유롭게 날아다니는 꿈을 꿨습니다.',
        date: DateTime.now().subtract(const Duration(days: 1)),
        tags: ['비행', '자유', '행복'],
        luckScore: 85,
        analysis: '매우 길한 꿈입니다. 목표 달성의 가능성이 높습니다.',
      ),
      DreamEntry(
        id: '2',
        title: '물고기를 잡는 꿈',
        content: '맑은 강에서 큰 물고기를 잡았습니다.',
        date: DateTime.now().subtract(const Duration(days: 3)),
        tags: ['물고기', '재물', '성공'],
        luckScore: 75,
        analysis: '재물운이 좋아질 징조입니다.',
      ),
    ];
  }

  void addEntry(DreamEntry entry) {
    state = [entry, ...state];
  }

  void deleteEntry(String id) {
    state = state.where((entry) => entry.id != id).toList();
  }
}

class DreamAnalysisNotifier extends StateNotifier<AsyncValue<DreamAnalysis?>> {
  final Ref ref;
  final String dreamId;

  DreamAnalysisNotifier(this.ref, this.dreamId) : super(const AsyncValue.loading()) {
    _analyzeDream();
  }

  Future<void> _analyzeDream() async {
    try {
      // In real app, this would call the API
      await Future.delayed(const Duration(seconds: 2));

      state = AsyncValue.data(
        DreamAnalysis(
          dreamType: '길몽',
          overallLuck: 85,
          interpretation: '하늘을 나는 꿈은 자유와 성취를 상징합니다. 현재 당신이 추구하는 목표에 대한 강한 의지와 가능성을 나타냅니다.',
          symbols: ['하늘', '비행', '자유', '성취'],
          advice: '이 시기에 새로운 도전을 시작하면 좋은 결과를 얻을 수 있습니다.'));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class DreamInterpretationNotifier extends StateNotifier<AsyncValue<DreamAnalysisResult?>> {
  final Ref ref;
  final DreamInput input;

  DreamInterpretationNotifier(this.ref, this.input) : super(const AsyncValue.loading()) {
    _analyzeDream();
  }

  Future<void> _analyzeDream() async {
    try {
      final tokenService = ref.read(tokenProvider.notifier);

      // Check token balance
      final hasEnoughTokens = await tokenService.consumeTokens(
        fortuneType: 'dream',
        amount: 2,
      );

      if (!hasEnoughTokens) {
        state = AsyncValue.error(
          Exception('토큰이 부족합니다'),
          StackTrace.current,
        );
        return;
      }

      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        ApiEndpoints.generate,
        data: {
          'type': 'dream-interpretation',
          'userInfo': {
            'name': input.name,
            'birth_date': input.birthDate.toIso8601String(),
            'dream_content': input.dreamContent,
          },
        },
      );

      if (response.data['success'] == true) {
        state = AsyncValue.data(DreamAnalysisResult.fromJson(response.data));
      } else {
        throw Exception(response.data['error'] ?? '꿈 해몽 분석에 실패했습니다');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
