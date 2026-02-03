import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/decision_service.dart';
import '../../domain/models/decision_receipt.dart';
import '../../domain/models/user_coach_preferences.dart';

// ========================================
// Decision Receipts State & Provider
// ========================================

/// 결정 기록 목록 상태
class DecisionReceiptsState {
  final List<DecisionReceipt> receipts;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int offset;

  const DecisionReceiptsState({
    this.receipts = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.offset = 0,
  });

  DecisionReceiptsState copyWith({
    List<DecisionReceipt>? receipts,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? offset,
  }) {
    return DecisionReceiptsState(
      receipts: receipts ?? this.receipts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
    );
  }
}

/// 결정 기록 목록 Notifier
class DecisionReceiptsNotifier extends StateNotifier<DecisionReceiptsState> {
  final DecisionService _service;
  String? _userId;

  static const _pageSize = 20;

  DecisionReceiptsNotifier(this._service)
      : super(const DecisionReceiptsState());

  /// 사용자 ID 설정 및 초기 로드
  Future<void> initialize(String userId) async {
    _userId = userId;
    await loadReceipts(refresh: true);
  }

  /// 결정 기록 목록 로드
  Future<void> loadReceipts({
    bool refresh = false,
    DecisionType? filterType,
    OutcomeStatus? filterStatus,
  }) async {
    if (_userId == null) {
      state = state.copyWith(error: '로그인이 필요합니다');
      return;
    }

    if (state.isLoading) return;

    final offset = refresh ? 0 : state.offset;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final receipts = await _service.listReceipts(
        userId: _userId!,
        decisionType: filterType,
        outcomeStatus: filterStatus,
        limit: _pageSize,
        offset: offset,
      );

      final hasMore = receipts.length >= _pageSize;
      final newReceipts = refresh ? receipts : [...state.receipts, ...receipts];

      state = state.copyWith(
        receipts: newReceipts,
        isLoading: false,
        hasMore: hasMore,
        offset: offset + receipts.length,
      );
    } catch (e) {
      debugPrint('❌ Error loading receipts: $e');
      state = state.copyWith(
        isLoading: false,
        error: '결정 기록을 불러오는데 실패했습니다',
      );
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadReceipts(refresh: true);
  }

  /// 결정 기록 추가 (로컬)
  void addReceipt(DecisionReceipt receipt) {
    state = state.copyWith(
      receipts: [receipt, ...state.receipts],
    );
  }

  /// 결정 기록 업데이트 (로컬)
  void updateReceipt(DecisionReceipt receipt) {
    final index = state.receipts.indexWhere((r) => r.id == receipt.id);
    if (index >= 0) {
      final newReceipts = [...state.receipts];
      newReceipts[index] = receipt;
      state = state.copyWith(receipts: newReceipts);
    }
  }

  /// 결정 기록 삭제
  Future<void> deleteReceipt(String receiptId) async {
    if (_userId == null) return;

    try {
      await _service.deleteReceipt(userId: _userId!, receiptId: receiptId);
      state = state.copyWith(
        receipts: state.receipts.where((r) => r.id != receiptId).toList(),
      );
    } catch (e) {
      debugPrint('❌ Error deleting receipt: $e');
      state = state.copyWith(error: '삭제에 실패했습니다');
    }
  }

  /// 결과 기록
  Future<DecisionReceipt?> recordOutcome({
    required String receiptId,
    required OutcomeStatus outcomeStatus,
    String? outcomeNotes,
    int? outcomeRating,
  }) async {
    if (_userId == null) return null;

    try {
      final updated = await _service.recordOutcome(
        userId: _userId!,
        receiptId: receiptId,
        outcomeStatus: outcomeStatus,
        outcomeNotes: outcomeNotes,
        outcomeRating: outcomeRating,
      );

      updateReceipt(updated);
      return updated;
    } catch (e) {
      debugPrint('❌ Error recording outcome: $e');
      state = state.copyWith(error: '결과 기록에 실패했습니다');
      return null;
    }
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 결정 기록 목록 Provider
final decisionReceiptsProvider =
    StateNotifierProvider<DecisionReceiptsNotifier, DecisionReceiptsState>((ref) {
  final service = ref.watch(decisionServiceProvider);
  return DecisionReceiptsNotifier(service);
});

// ========================================
// Pending Follow-ups State & Provider
// ========================================

/// 팔로업 대기 상태
class PendingFollowUpsState {
  final List<DecisionReceipt> receipts;
  final bool isLoading;
  final String? error;

  const PendingFollowUpsState({
    this.receipts = const [],
    this.isLoading = false,
    this.error,
  });

  PendingFollowUpsState copyWith({
    List<DecisionReceipt>? receipts,
    bool? isLoading,
    String? error,
  }) {
    return PendingFollowUpsState(
      receipts: receipts ?? this.receipts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get count => receipts.length;
  bool get hasAny => receipts.isNotEmpty;
}

/// 팔로업 대기 Notifier
class PendingFollowUpsNotifier extends StateNotifier<PendingFollowUpsState> {
  final DecisionService _service;
  String? _userId;

  PendingFollowUpsNotifier(this._service)
      : super(const PendingFollowUpsState());

  /// 초기화
  Future<void> initialize(String userId) async {
    _userId = userId;
    await loadPending();
  }

  /// 팔로업 대기 목록 로드
  Future<void> loadPending() async {
    if (_userId == null) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final receipts = await _service.getPendingFollowUps(
        userId: _userId!,
        limit: 10,
      );

      state = state.copyWith(
        receipts: receipts,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('❌ Error loading pending follow-ups: $e');
      state = state.copyWith(
        isLoading: false,
        error: '팔로업 목록을 불러오는데 실패했습니다',
      );
    }
  }

  /// 팔로업 완료 (목록에서 제거)
  void markCompleted(String receiptId) {
    state = state.copyWith(
      receipts: state.receipts.where((r) => r.id != receiptId).toList(),
    );
  }

  /// 새로고침
  Future<void> refresh() => loadPending();
}

/// 팔로업 대기 Provider
final pendingFollowUpsProvider =
    StateNotifierProvider<PendingFollowUpsNotifier, PendingFollowUpsState>((ref) {
  final service = ref.watch(decisionServiceProvider);
  return PendingFollowUpsNotifier(service);
});

// ========================================
// Coach Preferences State & Provider
// ========================================

/// 코치 설정 상태
class CoachPreferencesState {
  final UserCoachPreferences? preferences;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const CoachPreferencesState({
    this.preferences,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  CoachPreferencesState copyWith({
    UserCoachPreferences? preferences,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return CoachPreferencesState(
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }

  bool get isReady => preferences != null && !isLoading;
}

/// 코치 설정 Notifier
class CoachPreferencesNotifier extends StateNotifier<CoachPreferencesState> {
  final DecisionService _service;
  String? _userId;

  CoachPreferencesNotifier(this._service)
      : super(const CoachPreferencesState());

  /// 초기화
  Future<void> initialize(String userId) async {
    _userId = userId;
    await loadPreferences();
  }

  /// 설정 로드
  Future<void> loadPreferences() async {
    if (_userId == null) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final preferences = await _service.getPreferences(userId: _userId!);

      state = state.copyWith(
        preferences: preferences,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('❌ Error loading preferences: $e');
      state = state.copyWith(
        isLoading: false,
        error: '설정을 불러오는데 실패했습니다',
      );
    }
  }

  /// 설정 업데이트
  Future<bool> updatePreferences({
    TonePreference? tonePreference,
    ResponseLength? responseLength,
    DecisionStyle? decisionStyle,
    RelationshipStatus? relationshipStatus,
    AgeGroup? ageGroup,
    String? occupationType,
    List<String>? preferredCategories,
    bool? followUpReminderEnabled,
    int? followUpDays,
    bool? pushNotificationEnabled,
    AnonymousPrefixType? communityAnonymousPrefix,
    bool? communityParticipationEnabled,
  }) async {
    if (_userId == null) return false;

    try {
      state = state.copyWith(isSaving: true, error: null);

      final updated = await _service.updatePreferences(
        userId: _userId!,
        tonePreference: tonePreference,
        responseLength: responseLength,
        decisionStyle: decisionStyle,
        relationshipStatus: relationshipStatus,
        ageGroup: ageGroup,
        occupationType: occupationType,
        preferredCategories: preferredCategories,
        followUpReminderEnabled: followUpReminderEnabled,
        followUpDays: followUpDays,
        pushNotificationEnabled: pushNotificationEnabled,
        communityAnonymousPrefix: communityAnonymousPrefix,
        communityParticipationEnabled: communityParticipationEnabled,
      );

      state = state.copyWith(
        preferences: updated,
        isSaving: false,
      );

      return true;
    } catch (e) {
      debugPrint('❌ Error updating preferences: $e');
      state = state.copyWith(
        isSaving: false,
        error: '설정 저장에 실패했습니다',
      );
      return false;
    }
  }

  /// 설정 초기화
  Future<bool> resetPreferences() async {
    if (_userId == null) return false;

    try {
      state = state.copyWith(isSaving: true, error: null);

      final reset = await _service.resetPreferences(userId: _userId!);

      state = state.copyWith(
        preferences: reset,
        isSaving: false,
      );

      return true;
    } catch (e) {
      debugPrint('❌ Error resetting preferences: $e');
      state = state.copyWith(
        isSaving: false,
        error: '초기화에 실패했습니다',
      );
      return false;
    }
  }

  /// 톤 설정 빠른 업데이트
  Future<bool> setTone(TonePreference tone) async {
    return updatePreferences(tonePreference: tone);
  }

  /// 응답 길이 빠른 업데이트
  Future<bool> setResponseLength(ResponseLength length) async {
    return updatePreferences(responseLength: length);
  }

  /// 결정 스타일 빠른 업데이트
  Future<bool> setDecisionStyle(DecisionStyle style) async {
    return updatePreferences(decisionStyle: style);
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 코치 설정 Provider
final coachPreferencesProvider =
    StateNotifierProvider<CoachPreferencesNotifier, CoachPreferencesState>((ref) {
  final service = ref.watch(decisionServiceProvider);
  return CoachPreferencesNotifier(service);
});

// ========================================
// Decision Stats Provider
// ========================================

/// 결정 통계 Provider (FutureProvider)
final decisionStatsProvider = FutureProvider.family<DecisionStats?, String>(
  (ref, userId) async {
    final service = ref.watch(decisionServiceProvider);
    try {
      return await service.getStats(userId: userId);
    } catch (e) {
      debugPrint('❌ Error loading stats: $e');
      return null;
    }
  },
);

// ========================================
// Decision Patterns Provider
// ========================================

/// 결정 패턴 분석 Provider (FutureProvider)
final decisionPatternsProvider = FutureProvider.family<DecisionPatternAnalysis?, String>(
  (ref, userId) async {
    final service = ref.watch(decisionServiceProvider);
    try {
      return await service.getPatterns(userId: userId);
    } catch (e) {
      debugPrint('❌ Error loading patterns: $e');
      return null;
    }
  },
);

// ========================================
// Decision Analysis State & Provider
// ========================================

/// 결정 분석 상태
class DecisionAnalysisState {
  final DecisionAnalysisResult? result;
  final bool isLoading;
  final String? error;

  const DecisionAnalysisState({
    this.result,
    this.isLoading = false,
    this.error,
  });

  DecisionAnalysisState copyWith({
    DecisionAnalysisResult? result,
    bool? isLoading,
    String? error,
  }) {
    return DecisionAnalysisState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 결정 분석 Notifier
class DecisionAnalysisNotifier extends StateNotifier<DecisionAnalysisState> {
  final DecisionService _service;

  DecisionAnalysisNotifier(this._service)
      : super(const DecisionAnalysisState());

  /// 결정 분석 요청
  Future<DecisionAnalysisResult?> analyzeDecision({
    required String userId,
    required String question,
    DecisionType decisionType = DecisionType.lifestyle,
    List<String>? options,
    bool isPremium = false,
    bool saveReceipt = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _service.analyzeDecision(
        userId: userId,
        question: question,
        decisionType: decisionType,
        options: options,
        isPremium: isPremium,
        saveReceipt: saveReceipt,
      );

      state = state.copyWith(
        result: result,
        isLoading: false,
      );

      return result;
    } catch (e) {
      debugPrint('❌ Error analyzing decision: $e');
      state = state.copyWith(
        isLoading: false,
        error: '결정 분석에 실패했습니다',
      );
      return null;
    }
  }

  /// 결과 클리어
  void clearResult() {
    state = const DecisionAnalysisState();
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 결정 분석 Provider
final decisionAnalysisProvider =
    StateNotifierProvider<DecisionAnalysisNotifier, DecisionAnalysisState>((ref) {
  final service = ref.watch(decisionServiceProvider);
  return DecisionAnalysisNotifier(service);
});
