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

  /// 결과 카드 헤더로 스크롤 - 비활성화됨
  ///
  /// 자석 기능이 제거되어 아무 동작도 하지 않습니다.
  /// 대신 결과 표시 전 clearConversation()이 호출됩니다.
  void scrollToFortuneResult({
    required String messageId,
    required BuildContext cardContext,
  }) {
    // 자석 기능 비활성화 - 아무것도 하지 않음
  }
}
