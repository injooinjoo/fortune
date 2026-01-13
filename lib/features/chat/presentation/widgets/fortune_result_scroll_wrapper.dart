import 'package:flutter/material.dart';

/// 운세 결과 카드를 감싸서 렌더링 완료 시 스크롤 콜백을 호출하는 래퍼
///
/// 타이핑 인디케이터의 onRendered 패턴과 동일한 방식으로 동작합니다.
/// 결과 카드가 완전히 렌더링된 후 콜백을 호출하여 정확한 스크롤 위치 계산을 가능하게 합니다.
class FortuneResultScrollWrapper extends StatefulWidget {
  final Widget child;

  /// 메시지 고유 ID (중복 스크롤 방지용)
  final String messageId;

  /// 렌더링 완료 후 호출되는 콜백
  /// messageId와 BuildContext를 전달하여 1회성 스크롤 처리 가능
  final void Function(String messageId, BuildContext context)? onRendered;

  const FortuneResultScrollWrapper({
    super.key,
    required this.child,
    required this.messageId,
    this.onRendered,
  });

  @override
  State<FortuneResultScrollWrapper> createState() =>
      _FortuneResultScrollWrapperState();
}

class _FortuneResultScrollWrapperState
    extends State<FortuneResultScrollWrapper> {
  @override
  void initState() {
    super.initState();
    // 렌더링 완료 후 콜백 호출 (타이핑 인디케이터와 동일한 패턴)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onRendered?.call(widget.messageId, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
