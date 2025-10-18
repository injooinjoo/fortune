import 'package:flutter/material.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';

/// 표준 운세 페이지 레이아웃
///
/// 입력 페이지용 표준 레이아웃:
/// - Stack 기반 구조
/// - SingleChildScrollView + padding
/// - FloatingBottomButton 고정
/// - 하단 여백 자동 추가
class StandardFortunePageLayout extends StatelessWidget {
  /// 스크롤 가능한 메인 컨텐츠
  final Widget child;

  /// 하단 고정 버튼 텍스트
  final String buttonText;

  /// 버튼 클릭 콜백
  final VoidCallback? onButtonPressed;

  /// 로딩 상태
  final bool isLoading;

  /// 버튼 스타일 (기본값: primary)
  final TossButtonStyle buttonStyle;

  /// 버튼 사이즈 (기본값: large)
  final TossButtonSize buttonSize;

  /// 버튼 아이콘 (선택 사항)
  final Widget? buttonIcon;

  /// 컨텐츠 패딩 (기본값: 20)
  final EdgeInsets contentPadding;

  const StandardFortunePageLayout({
    super.key,
    required this.child,
    required this.buttonText,
    required this.onButtonPressed,
    this.isLoading = false,
    this.buttonStyle = TossButtonStyle.primary,
    this.buttonSize = TossButtonSize.large,
    this.buttonIcon,
    this.contentPadding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 메인 컨텐츠 영역
        SingleChildScrollView(
          padding: contentPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              child,
              // 하단 버튼 공간만큼 여백 추가
              const BottomButtonSpacing(),
            ],
          ),
        ),

        // 하단 고정 버튼
        TossFloatingProgressButtonPositioned(
          text: buttonText,
          onPressed: onButtonPressed,
          isEnabled: onButtonPressed != null && !isLoading,
          showProgress: false,
          isVisible: true,
          isLoading: isLoading,
          icon: buttonIcon,
        ),
      ],
    );
  }
}

/// 결과 페이지용 표준 레이아웃
///
/// 결과 페이지는 버튼이 필요 없으므로 SingleChildScrollView만 제공
class StandardFortuneResultLayout extends StatelessWidget {
  /// 스크롤 가능한 결과 컨텐츠
  final Widget child;

  /// 컨텐츠 패딩 (기본값: 20)
  final EdgeInsets contentPadding;

  const StandardFortuneResultLayout({
    super.key,
    required this.child,
    this.contentPadding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: contentPadding,
      child: child,
    );
  }
}
