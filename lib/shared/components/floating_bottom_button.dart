import 'package:flutter/material.dart';
import 'toss_button.dart';

/// 화면 하단에 floating되는 버튼 위젯
class FloatingBottomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final TossButtonStyle style;
  final TossButtonSize size;
  final bool isLoading;
  final bool isEnabled;
  final Widget? icon;
  final bool showShadow;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool hideWhenDisabled;
  final double height;
  final double bottom; // ✅ bottom 위치 커스터마이징

  const FloatingBottomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = TossButtonStyle.primary,
    this.size = TossButtonSize.large,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.showShadow = true,
    this.backgroundColor,
    this.padding,
    this.hideWhenDisabled = false,
    this.height = 58.0, // TossFloatingProgressButton과 동일한 높이
    this.bottom = 0.0, // ✅ 기본값 0 (화면 하단)
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // hideWhenDisabled가 true이고 onPressed가 null이면 버튼을 숨김
    if (hideWhenDisabled && onPressed == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottom, // ✅ 커스터마이징 가능한 bottom 위치
      child: Container(
        color: Colors.transparent, // 완전히 투명한 배경
        padding: padding ?? EdgeInsets.fromLTRB(
          20,
          0, // 상단 패딩 제거
          20,
          16 + bottomPadding,
        ),
        child: SizedBox(
          height: height,
          child: TossButton(
            text: text,
            onPressed: onPressed,
            style: style,
            size: size,
            isLoading: isLoading,
            isEnabled: isEnabled,
            icon: icon,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}

/// 하단 버튼 공간만큼의 여백을 제공하는 위젯
class BottomButtonSpacing extends StatelessWidget {
  final double additionalSpacing;
  
  const BottomButtonSpacing({
    super.key,
    this.additionalSpacing = 0,
  });
  
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // 버튼 높이(58) + 하단 패딩(16) + bottom safe area + 추가 여백
    return SizedBox(
      height: 58 + 16 + bottomPadding + additionalSpacing,
    );
  }
}