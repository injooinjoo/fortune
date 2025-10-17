import 'package:flutter/material.dart';
import 'toss_button.dart';
import '../../core/theme/toss_theme.dart';

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
  final bool showProgress;
  final int currentProgress;
  final int totalSteps;

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
    this.showProgress = false,
    this.currentProgress = 0,
    this.totalSteps = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // hideWhenDisabled가 true이고 onPressed가 null이면 버튼을 숨김
    if (hideWhenDisabled && onPressed == null) {
      return const SizedBox.shrink();
    }

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 프로그래스바 (showProgress가 true일 때만 표시)
            if (showProgress && totalSteps > 0) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: List.generate(totalSteps, (index) {
                    final isActive = index < currentProgress;
                    return Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? TossTheme.primaryBlue
                                    : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE8E8E8)),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          if (index < totalSteps - 1) const SizedBox(width: 8),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
            // 버튼
            TossButton(
              text: text,
              onPressed: onPressed,
              style: style,
              size: size,
              isLoading: isLoading,
              isEnabled: isEnabled,
              icon: icon,
              width: double.infinity,
            ),
          ],
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