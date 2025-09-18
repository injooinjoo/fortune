import 'package:flutter/material.dart';
import 'toss_button.dart';
import '../../core/theme/toss_design_system.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: Colors.transparent, // 완전히 투명한 배경
        padding: padding ?? EdgeInsets.fromLTRB(
          20,
          0, // 상단 패딩 제거
          20,
          16 + bottomPadding,
        ),
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
    // 버튼 높이(56) + 하단 패딩(16) + bottom safe area + 추가 여백
    return SizedBox(
      height: 56 + 16 + bottomPadding + additionalSpacing,
    );
  }
}