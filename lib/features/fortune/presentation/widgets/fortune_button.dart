import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/components/toss_button.dart';
import '../constants/fortune_button_spacing.dart';

/// 운세 페이지 전용 버튼 컴포넌트
/// 표준화된 스타일과 애니메이션을 제공
class FortuneButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final FortuneButtonType type;
  final bool isLoading;
  final bool isEnabled;
  final Widget? icon;
  final double? width;
  final bool animate;
  final Duration? animationDelay;

  const FortuneButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = FortuneButtonType.primary,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.animate = true,
    this.animationDelay,
  });

  /// 운세 분석 버튼
  factory FortuneButton.analyze({
    required VoidCallback? onPressed,
    bool isLoading = false,
    String text = '운세 분석하기',
  }) {
    return FortuneButton(
      text: isLoading ? '분석 중...' : text,
      onPressed: isLoading ? null : onPressed,
      type: FortuneButtonType.primary,
      isLoading: isLoading,
      icon: isLoading ? null : const Icon(Icons.auto_awesome, size: 20),
    );
  }

  /// 다음 단계 버튼
  factory FortuneButton.next({
    required VoidCallback? onPressed,
    bool isEnabled = true,
    String text = '다음',
  }) {
    return FortuneButton(
      text: text,
      onPressed: isEnabled ? onPressed : null,
      type: FortuneButtonType.primary,
      isEnabled: isEnabled,
    );
  }

  /// 이전 단계 버튼
  factory FortuneButton.previous({
    required VoidCallback? onPressed,
    String text = '이전',
  }) {
    return FortuneButton(
      text: text,
      onPressed: onPressed,
      type: FortuneButtonType.secondary,
    );
  }

  /// 운세 보기 버튼 (최종 CTA)
  factory FortuneButton.viewFortune({
    required VoidCallback? onPressed,
    bool isEnabled = true,
    bool isLoading = false,
    String text = '운세 보기',
  }) {
    return FortuneButton(
      text: isLoading ? '운세 생성 중...' : text,
      onPressed: (isEnabled && !isLoading) ? onPressed : null,
      type: FortuneButtonType.primary,
      isLoading: isLoading,
      icon: const Icon(Icons.visibility, size: 20),
    );
  }

  /// 재시도 버튼
  factory FortuneButton.retry({
    required VoidCallback? onPressed,
    String text = '다시 시도',
  }) {
    return FortuneButton(
      text: text,
      onPressed: onPressed,
      type: FortuneButtonType.secondary,
      icon: const Icon(Icons.refresh, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget button = TossButton(
      text: text,
      onPressed: onPressed,
      style: _getTossButtonStyle(),
      size: TossButtonSize.large,
      isLoading: isLoading,
      isEnabled: isEnabled && !isLoading,
      icon: icon,
      width: width ?? double.infinity,
    );

    if (animate && animationDelay != null) {
      button = button
          .animate(delay: animationDelay!)
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.2, end: 0);
    } else if (animate) {
      button = button
          .animate()
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.2, end: 0);
    }

    return button;
  }

  TossButtonStyle _getTossButtonStyle() {
    switch (type) {
      case FortuneButtonType.primary:
        return TossButtonStyle.primary;
      case FortuneButtonType.secondary:
        return TossButtonStyle.secondary;
      case FortuneButtonType.ghost:
        return TossButtonStyle.ghost;
      case FortuneButtonType.text:
        return TossButtonStyle.text;
    }
  }
}

/// 운세 버튼 타입
enum FortuneButtonType {
  primary,   // 주요 액션 (운세 보기, 분석하기)
  secondary, // 보조 액션 (이전, 취소)
  ghost,     // 테두리만 있는 버튼
  text,      // 텍스트만 있는 버튼
}

/// 운세 버튼 그룹 (이전/다음 등)
class FortuneButtonGroup extends StatelessWidget {
  final Widget? leftButton;
  final Widget? rightButton;
  final Widget? singleButton;
  final FortuneButtonPosition position;

  const FortuneButtonGroup({
    super.key,
    this.leftButton,
    this.rightButton,
    this.singleButton,
    this.position = FortuneButtonPosition.inline,
  });

  /// 이전/다음 버튼 그룹
  factory FortuneButtonGroup.navigation({
    required VoidCallback? onPrevious,
    required VoidCallback? onNext,
    bool showPrevious = true,
    bool isNextEnabled = true,
    String previousText = '이전',
    String nextText = '다음',
    FortuneButtonPosition position = FortuneButtonPosition.bottomFixed,
  }) {
    return FortuneButtonGroup(
      leftButton: showPrevious
          ? FortuneButton.previous(
              onPressed: onPrevious,
              text: previousText,
            )
          : null,
      rightButton: FortuneButton.next(
        onPressed: onNext,
        isEnabled: isNextEnabled,
        text: nextText,
      ),
      position: position,
    );
  }

  /// 단일 CTA 버튼
  factory FortuneButtonGroup.single({
    required Widget button,
    FortuneButtonPosition position = FortuneButtonPosition.inline,
  }) {
    return FortuneButtonGroup(
      singleButton: button,
      position: position,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (singleButton != null) {
      content = singleButton!;
    } else if (leftButton != null && rightButton != null) {
      content = FortuneButtonPositionHelper.parallel(
        leftButton: leftButton!,
        rightButton: rightButton!,
      );
    } else if (leftButton != null) {
      content = leftButton!;
    } else if (rightButton != null) {
      content = rightButton!;
    } else {
      return const SizedBox.shrink();
    }

    switch (position) {
      case FortuneButtonPosition.bottomFixed:
        return FortuneButtonPositionHelper.bottomFixed(
          child: content,
          context: context,
        );
      case FortuneButtonPosition.inline:
        return FortuneButtonPositionHelper.inline(
          child: content,
        );
      case FortuneButtonPosition.floating:
      case FortuneButtonPosition.parallel:
        return content;
    }
  }
}

/// 표준 운세 버튼 섹션
/// 스크롤 영역과 버튼을 분리하여 관리
class FortunePageWithButton extends StatelessWidget {
  final Widget content;
  final Widget button;
  final bool useBottomFixed;

  const FortunePageWithButton({
    super.key,
    required this.content,
    required this.button,
    this.useBottomFixed = true,
  });

  @override
  Widget build(BuildContext context) {
    if (useBottomFixed) {
      return Stack(
        children: [
          // 스크롤 가능한 컨텐츠
          Positioned.fill(
            child: content,
          ),
          // 하단 고정 버튼
          FortuneButtonPositionHelper.bottomFixed(
            child: button,
            context: context,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Expanded(child: content),
          FortuneButtonPositionHelper.inline(
            child: button,
          ),
        ],
      );
    }
  }
}