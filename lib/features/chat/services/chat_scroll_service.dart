import 'dart:async';
import 'package:flutter/material.dart';

/// 채팅 스크롤 관련 상수
class ChatScrollConstants {
  ChatScrollConstants._();

  /// 스크롤 애니메이션 지속 시간
  static const Duration scrollDuration = Duration(milliseconds: 400);

  /// 레이아웃 계산 대기 시간
  static const Duration layoutDelay = Duration(milliseconds: 150);

  /// 후속 레이아웃 변화 반영 대기 시간
  static const Duration settleDelay = Duration(milliseconds: 80);

  /// 디바운스 딜레이
  static const Duration debounceDelay = Duration(milliseconds: 50);

  /// 스크롤 애니메이션 커브
  static const Curve scrollCurve = Curves.easeOutCubic;

  /// 마지막 위치 보정 재시도 횟수
  static const int maxBottomScrollAttempts = 6;

  /// 하단 도달 판정 오차
  static const double bottomTolerance = 12;
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

  int _scrollRequestId = 0;

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
    _scheduleBottomScroll(animated: true);
  }

  /// 최하단으로 즉시 스크롤 (애니메이션 없음, 초기 진입용)
  ///
  /// 채팅방 진입 시 사용. 애니메이션 없이 즉시 맨 아래로 이동.
  void scrollToBottomInstant() {
    _scheduleBottomScroll(animated: false);
  }

  /// 특정 메시지 상단으로 스크롤
  ///
  /// 세션 시작 메시지가 채팅 상단부에 보이도록 유지할 때 사용합니다.
  void scrollToMessageTop({
    required BuildContext messageContext,
    double alignment = 0.14,
  }) {
    _debounceTimer?.cancel();
    final requestId = ++_scrollRequestId;
    _debounceTimer = Timer(ChatScrollConstants.debounceDelay, () {
      unawaited(
        _performMessageTopScroll(
          messageContext: messageContext,
          alignment: alignment,
          requestId: requestId,
        ),
      );
    });
  }

  void _scheduleBottomScroll({required bool animated}) {
    _debounceTimer?.cancel();
    final requestId = ++_scrollRequestId;
    _debounceTimer = Timer(ChatScrollConstants.debounceDelay, () {
      unawaited(
        _performBottomScroll(
          animated: animated,
          requestId: requestId,
        ),
      );
    });
  }

  Future<void> _performBottomScroll({
    required bool animated,
    required int requestId,
  }) async {
    var previousMaxScrollExtent = -1.0;

    for (var attempt = 0;
        attempt < ChatScrollConstants.maxBottomScrollAttempts;
        attempt++) {
      final delay = attempt == 0
          ? ChatScrollConstants.layoutDelay
          : ChatScrollConstants.settleDelay;
      await Future<void>.delayed(delay);

      if (!_isActiveRequest(requestId)) {
        return;
      }

      final position = scrollController.position;
      if (!position.hasContentDimensions) {
        continue;
      }

      final maxScrollExtent = position.maxScrollExtent;
      final distanceToBottom = maxScrollExtent - position.pixels;
      final needsScroll =
          distanceToBottom.abs() > ChatScrollConstants.bottomTolerance;

      if (needsScroll) {
        if (animated && attempt == 0) {
          try {
            await scrollController.animateTo(
              maxScrollExtent,
              duration: ChatScrollConstants.scrollDuration,
              curve: ChatScrollConstants.scrollCurve,
            );
          } catch (_) {
            return;
          }
        } else {
          scrollController.jumpTo(maxScrollExtent);
        }
      }

      final updatedDistance = scrollController.position.maxScrollExtent -
          scrollController.position.pixels;
      final extentChanged =
          (scrollController.position.maxScrollExtent - previousMaxScrollExtent)
                  .abs() >
              ChatScrollConstants.bottomTolerance;
      previousMaxScrollExtent = scrollController.position.maxScrollExtent;

      if (!extentChanged &&
          updatedDistance.abs() <= ChatScrollConstants.bottomTolerance) {
        return;
      }
    }
  }

  Future<void> _performMessageTopScroll({
    required BuildContext messageContext,
    required double alignment,
    required int requestId,
  }) async {
    for (var attempt = 0;
        attempt < ChatScrollConstants.maxBottomScrollAttempts;
        attempt++) {
      final delay = attempt == 0
          ? ChatScrollConstants.layoutDelay
          : ChatScrollConstants.settleDelay;
      await Future<void>.delayed(delay);

      if (!_isActiveRequest(requestId) || !messageContext.mounted) {
        return;
      }

      try {
        await Scrollable.ensureVisible(
          messageContext,
          alignment: alignment,
          duration:
              attempt == 0 ? ChatScrollConstants.scrollDuration : Duration.zero,
          curve: ChatScrollConstants.scrollCurve,
        );
      } catch (_) {
        return;
      }
    }
  }

  bool _isActiveRequest(int requestId) {
    return isMounted() &&
        scrollController.hasClients &&
        requestId == _scrollRequestId;
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
    if (!isMounted() || !scrollController.hasClients || !cardContext.mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isMounted() ||
          !scrollController.hasClients ||
          !cardContext.mounted) {
        return;
      }

      Scrollable.ensureVisible(
        cardContext,
        alignment: 0,
        duration: ChatScrollConstants.scrollDuration,
        curve: ChatScrollConstants.scrollCurve,
      ).catchError((error) {
        debugPrint('⚠️ [ChatScrollService] scrollToCardTop failed: $error');
        _scheduleBottomScroll(animated: true);
      });
    });
  }
}
