import 'package:flutter/material.dart';

/// Fortune 기능의 버튼 위치 및 간격 표준 상수
class FortuneButtonSpacing {
  // 페이지 레벨 패딩
  static const double pagePadding = 20.0;
  static const double pageHorizontalPadding = 20.0;
  static const double pageVerticalPadding = 20.0;
  
  // 하단 고정 버튼 영역
  static const double bottomButtonAreaPadding = 16.0;
  static const double bottomSafeAreaPadding = 20.0;
  
  // 버튼 주변 간격
  static const double buttonTopSpacing = 32.0; // 콘텐츠와 버튼 사이
  static const double buttonBottomSpacing = 20.0; // 버튼과 하단 사이
  
  // 버튼 간 간격
  static const double buttonHorizontalGap = 12.0; // 가로 배치 버튼 간격
  static const double buttonVerticalGap = 16.0; // 세로 배치 버튼 간격
  
  // 섹션 간격
  static const double sectionGap = 32.0; // 섹션 간 간격
  static const double subsectionGap = 24.0; // 서브섹션 간 간격
  
  // 버튼 그룹 패딩
  static EdgeInsets get bottomFixedPadding => const EdgeInsets.fromLTRB(
    pageHorizontalPadding,
    bottomButtonAreaPadding,
    pageHorizontalPadding,
    bottomSafeAreaPadding,
  );
  
  static EdgeInsets get inlineButtonPadding => const EdgeInsets.symmetric(
    horizontal: pageHorizontalPadding,
  );
  
  // 하단 고정 버튼 컨테이너 데코레이션
  static BoxDecoration get bottomButtonDecoration => BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, -2),
      ),
    ],
  );
  
  // Safe Area 포함 하단 패딩 계산
  static EdgeInsets bottomFixedPaddingWithSafeArea(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return EdgeInsets.fromLTRB(
      pageHorizontalPadding,
      bottomButtonAreaPadding,
      pageHorizontalPadding,
      bottomSafeAreaPadding + bottomInset,
    );
  }
}

/// 버튼 위치 패턴 열거형
enum FortuneButtonPosition {
  /// 하단 고정 (주요 CTA)
  bottomFixed,
  
  /// 스크롤 내부 인라인
  inline,
  
  /// 플로팅 액션 버튼
  floating,
  
  /// 병렬 배치 (2개 이상)
  parallel,
}

/// 버튼 위치 표준화 헬퍼
class FortuneButtonPositionHelper {
  /// 하단 고정 버튼 래퍼
  static Widget bottomFixed({
    required Widget child,
    required BuildContext context,
    BoxDecoration? decoration,
  }) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: FortuneButtonSpacing.bottomFixedPaddingWithSafeArea(context),
        decoration: decoration ?? FortuneButtonSpacing.bottomButtonDecoration,
        child: child,
      ),
    );
  }
  
  /// 인라인 버튼 래퍼
  static Widget inline({
    required Widget child,
    double topSpacing = FortuneButtonSpacing.buttonTopSpacing,
    double bottomSpacing = FortuneButtonSpacing.buttonBottomSpacing,
  }) {
    return Padding(
      padding: FortuneButtonSpacing.inlineButtonPadding,
      child: Column(
        children: [
          if (topSpacing > 0) SizedBox(height: topSpacing),
          child,
          if (bottomSpacing > 0) SizedBox(height: bottomSpacing),
        ],
      ),
    );
  }
  
  /// 병렬 버튼 래퍼 (2개)
  static Widget parallel({
    required Widget leftButton,
    required Widget rightButton,
    double gap = FortuneButtonSpacing.buttonHorizontalGap,
  }) {
    return Row(
      children: [
        Expanded(child: leftButton),
        SizedBox(width: gap),
        Expanded(child: rightButton),
      ],
    );
  }
  
  /// 병렬 버튼 래퍼 (3개 이상)
  static Widget parallelMultiple({
    required List<Widget> buttons,
    double gap = FortuneButtonSpacing.buttonHorizontalGap,
  }) {
    final List<Widget> children = [];
    for (int i = 0; i < buttons.length; i++) {
      children.add(Expanded(child: buttons[i]));
      if (i < buttons.length - 1) {
        children.add(SizedBox(width: gap));
      }
    }
    return Row(children: children);
  }
}