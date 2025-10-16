import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/talisman_wish.dart';
import '../../domain/models/talisman_design.dart';
import '../../domain/models/talisman_effect.dart';
import '../../data/services/talisman_service.dart';
import '../../../../core/utils/logger.dart';

// Service Provider
final talismanServiceProvider = Provider<TalismanService>((ref) {
  return TalismanService();
});

// State Classes
class TalismanGenerationState {
  final bool isLoading;
  final TalismanDesign? design;
  final String? error;
  final TalismanGenerationStep step;

  const TalismanGenerationState({
    this.isLoading = false,
    this.design,
    this.error,
    this.step = TalismanGenerationStep.categorySelection,
  });

  TalismanGenerationState copyWith({
    bool? isLoading,
    TalismanDesign? design,
    String? error,
    TalismanGenerationStep? step,
  }) {
    return TalismanGenerationState(
      isLoading: isLoading ?? this.isLoading,
      design: design ?? this.design,
      error: error ?? this.error,
      step: step ?? this.step,
    );
  }
}

enum TalismanGenerationStep {
  categorySelection,
  wishInput,
  generation,
  result,
}

class TalismanListState {
  final bool isLoading;
  final List<TalismanDesign> talismans;
  final String? error;

  const TalismanListState({
    this.isLoading = false,
    this.talismans = const [],
    this.error,
  });

  TalismanListState copyWith({
    bool? isLoading,
    List<TalismanDesign>? talismans,
    String? error,
  }) {
    return TalismanListState(
      isLoading: isLoading ?? this.isLoading,
      talismans: talismans ?? this.talismans,
      error: error ?? this.error,
    );
  }
}

// State Notifiers
class TalismanGenerationNotifier extends StateNotifier<TalismanGenerationState> {
  final TalismanService _talismanService;
  final String? _userId;

  TalismanGenerationNotifier(this._talismanService, this._userId)
      : super(const TalismanGenerationState());

  void selectCategory(TalismanCategory category) {
    state = state.copyWith(
      step: TalismanGenerationStep.wishInput,
      error: null,
    );
  }

  void goBack() {
    switch (state.step) {
      case TalismanGenerationStep.wishInput:
        state = state.copyWith(step: TalismanGenerationStep.categorySelection);
        break;
      case TalismanGenerationStep.generation:
        state = state.copyWith(step: TalismanGenerationStep.wishInput);
        break;
      case TalismanGenerationStep.result:
        state = state.copyWith(step: TalismanGenerationStep.categorySelection);
        break;
      case TalismanGenerationStep.categorySelection:
        break;
    }
  }

  Future<void> generateTalisman({
    required TalismanCategory category,
    required String specificWish,
  }) async {
    state = state.copyWith(
      isLoading: true,
      step: TalismanGenerationStep.generation,
      error: null,
    );

    try {
      Logger.info('Starting talisman generation for category: ${category.name}');
      
      final design = await _talismanService.generateTalisman(
        category: category,
        specificWish: specificWish,
        userId: _userId,
      );

      state = state.copyWith(
        isLoading: false,
        design: design,
        step: TalismanGenerationStep.result,
      );

      Logger.info('Talisman generation completed successfully');
    } catch (e, stackTrace) {
      Logger.error('Talisman generation failed', e, stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        step: TalismanGenerationStep.wishInput,
      );
    }
  }

  void reset() {
    state = const TalismanGenerationState();
  }
}

class TalismanListNotifier extends StateNotifier<TalismanListState> {
  final TalismanService _talismanService;
  final String _userId;

  TalismanListNotifier(this._talismanService, this._userId)
      : super(const TalismanListState());

  Future<void> loadTalismans() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);

    try {
      final talismans = await _talismanService.getUserTalismans(_userId);
      state = state.copyWith(
        isLoading: false,
        talismans: talismans,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to load talismans', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadTalismans();
  }
}

// Providers
final talismanGenerationProvider = StateNotifierProvider.family<
    TalismanGenerationNotifier, TalismanGenerationState, String?>(
  (ref, userId) {
    final service = ref.watch(talismanServiceProvider);
    return TalismanGenerationNotifier(service, userId);
  },
);

final talismanListProvider = StateNotifierProvider.family<
    TalismanListNotifier, TalismanListState, String>(
  (ref, userId) {
    final service = ref.watch(talismanServiceProvider);
    return TalismanListNotifier(service, userId);
  },
);

// Effect tracking provider
final talismanEffectProvider = FutureProvider.family<TalismanStats, String>(
  (ref, talismanId) async {
    final service = ref.watch(talismanServiceProvider);
    return service.getTalismanStats(talismanId);
  },
);

// Today's talisman limit check (무료 사용자는 하루 1개 제한)
final dailyTalismanLimitProvider = FutureProvider.family<bool, String>(
  (ref, userId) async {
    final service = ref.watch(talismanServiceProvider);
    final talismans = await service.getUserTalismans(userId);
    
    final today = DateTime.now();
    final todayTalismans = talismans.where((talisman) {
      final createdDate = talisman.createdAt;
      return createdDate.year == today.year &&
             createdDate.month == today.month &&
             createdDate.day == today.day;
    }).toList();

    // 무료 사용자는 하루 1개, 프리미엄 사용자는 무제한
    return todayTalismans.isNotEmpty; // TODO: 프리미엄 상태 확인 로직 추가
  },
);