import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../services/user_interaction_service.dart';

part 'content_interaction_provider.freezed.dart';

/// 콘텐츠 인터랙션 상태
@freezed
class ContentInteractionState with _$ContentInteractionState {
  const factory ContentInteractionState({
    @Default(false) bool isSaved,
    @Default(false) bool isLoading,
    @Default(null) String? error,
  }) = _ContentInteractionState;
}

/// 콘텐츠 인터랙션 Notifier
class ContentInteractionNotifier extends StateNotifier<ContentInteractionState> {
  final String contentKey;
  final UserInteractionService _service;

  ContentInteractionNotifier(this.contentKey, this._service)
      : super(const ContentInteractionState()) {
    _loadInitialState();
  }

  /// 초기 저장 상태 로드
  Future<void> _loadInitialState() async {
    try {
      final isSaved = await _service.isSaved(contentKey: contentKey);
      if (mounted) {
        state = state.copyWith(isSaved: isSaved);
      }
    } catch (e) {
      debugPrint('[ContentInteractionNotifier] loadInitialState error: $e');
    }
  }

  /// 저장(좋아요) 토글
  Future<void> toggleSave({
    required String contentType,
    String? contentId, // UUID인 경우에만 전달
    Map<String, dynamic>? metadata,
  }) async {
    if (state.isLoading) return;

    // 낙관적 업데이트
    final previousState = state.isSaved;
    state = state.copyWith(
      isSaved: !previousState,
      isLoading: true,
      error: null,
    );

    try {
      final result = await _service.toggleSave(
        contentKey: contentKey,
        contentType: contentType,
        contentId: contentId,
        metadata: metadata,
      );

      if (mounted) {
        state = state.copyWith(
          isSaved: result,
          isLoading: false,
        );
      }
    } catch (e) {
      // 롤백
      if (mounted) {
        state = state.copyWith(
          isSaved: previousState,
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }

  /// 저장 상태 새로고침
  Future<void> refresh() async {
    await _loadInitialState();
  }
}

/// 콘텐츠 인터랙션 Provider (Family)
/// 각 contentKey별로 독립적인 상태 관리
final contentInteractionProvider = StateNotifierProvider.family<
    ContentInteractionNotifier, ContentInteractionState, String>(
  (ref, contentKey) {
    return ContentInteractionNotifier(contentKey, UserInteractionService());
  },
);

/// 여러 콘텐츠의 저장 상태 일괄 조회
final savedContentKeysProvider = FutureProvider.family<Set<String>, List<String>>(
  (ref, contentKeys) async {
    final service = UserInteractionService();
    return service.getSavedStatusBatch(contentKeys);
  },
);

/// 저장된 콘텐츠 목록 Provider
final savedContentsProvider = FutureProvider.family<List<Map<String, dynamic>>, String?>(
  (ref, contentType) async {
    final service = UserInteractionService();
    return service.getSavedContents(contentType: contentType);
  },
);
