import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';

/// Floating 방식의 프로그레스 바 통합 Toss 버튼
///
/// 버튼 내부 배경이 진행률만큼 채워지는 방식으로 프로그레스를 표현합니다.
/// 기존 Floating 버튼 패턴을 유지하면서 프로그레스 기능을 추가했습니다.
///
/// 사용 예시:
/// ```dart
/// TossFloatingProgressButton(
///   text: '다음',
///   currentStep: 2,
///   totalSteps: 5,
///   onPressed: () {},
///   isEnabled: true,
/// )
/// ```
class TossFloatingProgressButton extends StatelessWidget {
  /// 버튼 텍스트
  final String text;

  /// 현재 단계 (1부터 시작)
  final int? currentStep;

  /// 전체 단계
  final int? totalSteps;

  /// 버튼 클릭 콜백
  final VoidCallback? onPressed;

  /// 활성화 여부
  final bool isEnabled;

  /// 프로그레스 표시 여부 (false일 경우 일반 버튼처럼 동작)
  final bool showProgress;

  /// 버튼 높이
  final double height;

  /// 로딩 상태
  final bool isLoading;

  /// 아이콘 (선택)
  final Widget? icon;

  const TossFloatingProgressButton({
    super.key,
    required this.text,
    this.currentStep,
    this.totalSteps,
    this.onPressed,
    this.isEnabled = true,
    this.showProgress = true,
    this.height = 58.0,
    this.isLoading = false,
    this.icon,
  });

  /// 진행률 계산 (0.0 ~ 1.0)
  double get _progressPercentage {
    if (!showProgress || currentStep == null || totalSteps == null || totalSteps == 0) {
      return 1.0; // 프로그레스 없으면 100%
    }
    return (currentStep! / totalSteps!).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveEnabled = isEnabled && !isLoading && onPressed != null;

    // 색상 정의
    final backgroundColor = isDark
        ? TossDesignSystem.grayDark200
        : TossDesignSystem.gray100;

    final progressColor = effectiveEnabled
        ? (isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue)
        : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300);

    final textColor = effectiveEnabled
        ? TossDesignSystem.white
        : (isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveEnabled ? () {
            TossDesignSystem.hapticLight();
            onPressed!();
          } : null,
          borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
            child: Stack(
              children: [
                // 배경 레이어 (회색)
                Container(
                  width: double.infinity,
                  height: height,
                  color: backgroundColor,
                ),

                // 프로그레스 레이어 (파란색, 진행률만큼 채움)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: MediaQuery.of(context).size.width * _progressPercentage,
                  height: height,
                  color: progressColor,
                ),

                // 텍스트 및 아이콘 레이어
                Center(
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(textColor),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (icon != null) ...[
                              icon!,
                              const SizedBox(width: TossDesignSystem.spacingXS),
                            ],
                            Text(
                              text,
                              style: TossDesignSystem.button.copyWith(
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating Positioned로 감싼 프로그레스 버튼
///
/// 키보드 위치에 따라 자동으로 위치가 조정되는 Floating 버튼입니다.
/// `AnimatedPositioned`를 사용하여 부드러운 애니메이션을 제공합니다.
///
/// 사용 예시:
/// ```dart
/// Stack(
///   children: [
///     // 메인 콘텐츠
///     TossFloatingProgressButtonPositioned(
///       text: '다음',
///       currentStep: 2,
///       totalSteps: 5,
///       onPressed: () {},
///       isVisible: true, // 버튼 표시 여부
///     ),
///   ],
/// )
/// ```
class TossFloatingProgressButtonPositioned extends StatelessWidget {
  /// 버튼 텍스트
  final String text;

  /// 현재 단계
  final int? currentStep;

  /// 전체 단계
  final int? totalSteps;

  /// 버튼 클릭 콜백
  final VoidCallback? onPressed;

  /// 활성화 여부
  final bool isEnabled;

  /// 버튼 표시 여부 (false면 화면 밖으로 이동)
  final bool isVisible;

  /// 프로그레스 표시 여부
  final bool showProgress;

  /// 로딩 상태
  final bool isLoading;

  /// 아이콘
  final Widget? icon;

  /// 키보드가 있을 때 추가 여백
  final double keyboardPadding;

  /// 키보드가 없을 때 하단 여백
  final double bottomPadding;

  const TossFloatingProgressButtonPositioned({
    super.key,
    required this.text,
    this.currentStep,
    this.totalSteps,
    this.onPressed,
    this.isEnabled = true,
    this.isVisible = true,
    this.showProgress = true,
    this.isLoading = false,
    this.icon,
    this.keyboardPadding = 16.0,
    this.bottomPadding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: isVisible
          ? (isKeyboardVisible ? keyboardHeight + keyboardPadding : bottomPadding)
          : -100,
      left: 24,
      right: 24,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isVisible ? 1.0 : 0.0,
        child: TossFloatingProgressButton(
          text: text,
          currentStep: currentStep,
          totalSteps: totalSteps,
          onPressed: onPressed,
          isEnabled: isEnabled,
          showProgress: showProgress,
          isLoading: isLoading,
          icon: icon,
        ),
      ),
    );
  }
}
