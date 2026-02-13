import 'dart:async';
import 'package:flutter/material.dart';

/// 채팅 스크롤 관련 상수
class ChatScrollConstants {
  ChatScrollConstants._();

  /// 스크롤 애니메이션 지속 시간
  static const Duration scrollDuration = Duration(milliseconds: 400);

  /// 레이아웃 계산 대기 시간
  static const Duration layoutDelay = Duration(milliseconds: 150);

  /// 디바운스 딜레이
  static const Duration debounceDelay = Duration(milliseconds: 50);

  /// 스크롤 애니메이션 커브
  static const Curve scrollCurve = Curves.easeOutCubic;
}

/// 채팅 스크롤 서비스
///
/// 채팅 스크롤 로직을 통합 관리합니다.
/// - 자석 기능(결과 카드 자동 스크롤) 비활성화됨
/// - 결과 표시 시 clearConversation()으로 대체
class ChatScrollService {
  final ScrollController scrollController;

  /// 디바운스 타이머
  Timer? _debounceTimer;

  /// mounted 상태 체크 콜백
  final bool Function() isMounted;

  ChatScrollService({
    required this.scrollController,
    required this.isMounted,
  });

  /// 리소스 정리
  void dispose() {
    _debounceTimer?.cancel();
  }

  /// 최하단으로 스크롤 (일반 메시지용)
  ///
  /// 디바운싱 적용으로 연속 호출 시 마지막 것만 실행
  void scrollToBottom() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(ChatScrollConstants.debounceDelay, () {
      _performScrollToBottom();
    });
  }

  void _performScrollToBottom() {
    if (!isMounted() || !scrollController.hasClients) return;

    Future.delayed(ChatScrollConstants.layoutDelay, () {
      if (!isMounted() || !scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: ChatScrollConstants.scrollDuration,
        curve: ChatScrollConstants.scrollCurve,
      );
    });
  }

  /// 결과 카드 헤더로 스크롤
  ///
  /// 운세 결과가 표시될 때 카드 상단이 보이도록 스크롤합니다.
  void scrollToFortuneResult({
    required String messageId,
    required BuildContext cardContext,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(ChatScrollConstants.debounceDelay, () {
      _performScrollToCardTop(cardContext);
    });
  }

  /// 결과 카드 상단으로 스크롤
  void _performScrollToCardTop(BuildContext cardContext) {
    if (!isMounted() || !scrollController.hasClients) return;

    Future.delayed(ChatScrollConstants.layoutDelay, () {
      if (!isMounted() || !scrollController.hasClients) return;
      if (!cardContext.mounted) return;

      try {
        // 카드 위젯의 RenderObject 찾기
        final renderObject = cardContext.findRenderObject();
        if (renderObject is! RenderBox) return;

        // 스크롤 가능한 부모 찾기
        final scrollableState = Scrollable.maybeOf(cardContext);
        if (scrollableState == null) return;

        if (!scrollableState.context.mounted) return;
        final scrollableRenderObject =
            scrollableState.context.findRenderObject(); // ignore: use_build_context_synchronously
        if (scrollableRenderObject is! RenderBox) return;

        // 카드의 위치 계산 (스크롤 뷰 기준)
        final cardPosition = renderObject.localToGlobal(
          Offset.zero,
          ancestor: scrollableRenderObject,
        );

        // 현재 스크롤 위치 + 카드 상단 위치 = 목표 스크롤 위치
        // 약간의 상단 여백(16px) 추가
        final targetOffset = scrollController.offset + cardPosition.dy - 16;

        // 유효한 범위 내로 제한
        final clampedOffset = targetOffset.clamp(
          scrollController.position.minScrollExtent,
          scrollController.position.maxScrollExtent,
        );

        scrollController.animateTo(
          clampedOffset,
          duration: ChatScrollConstants.scrollDuration,
          curve: ChatScrollConstants.scrollCurve,
        );
      } catch (e) {
        // 실패 시 기본 하단 스크롤
        debugPrint('⚠️ [ChatScrollService] scrollToCardTop failed: $e');
        _performScrollToBottom();
      }
    });
  }
}
