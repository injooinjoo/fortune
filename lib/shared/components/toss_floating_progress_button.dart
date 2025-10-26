import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'dart:async';

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
class TossFloatingProgressButton extends StatefulWidget {
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

  @override
  State<TossFloatingProgressButton> createState() => _TossFloatingProgressButtonState();
}

class _TossFloatingProgressButtonState extends State<TossFloatingProgressButton> {
  Timer? _debounceTimer;
  bool _isProcessing = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// 진행률 계산 (0.0 ~ 1.0)
  double get _progressPercentage {
    if (!widget.showProgress || widget.currentStep == null || widget.totalSteps == null || widget.totalSteps == 0) {
      return 1.0; // 프로그레스 없으면 100%
    }
    return (widget.currentStep! / widget.totalSteps!).clamp(0.0, 1.0);
  }

  /// 중복 호출 방지 + Debouncing을 적용한 onTap 핸들러
  void _handleTap() {
    // 이미 처리 중이면 무시
    if (_isProcessing) return;

    // Debounce 타이머 취소
    _debounceTimer?.cancel();

    // 500ms 이내 중복 탭 방지
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });

    setState(() {
      _isProcessing = true;
    });

    TossDesignSystem.hapticLight();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveEnabled = widget.isEnabled && !widget.isLoading && !_isProcessing && widget.onPressed != null;

    // 색상 정의
    final backgroundColor = isDark
        ? TossDesignSystem.grayDark200
        : TossDesignSystem.gray100;

    final progressColor = effectiveEnabled
        ? (isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue)
        : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300);

    // 프로그레스가 텍스트 위치(중앙, 50%)를 넘었는지 여부에 따라 텍스트 색상 결정
    final isProgressOverText = _progressPercentage >= 0.5;

    final textColor = effectiveEnabled
        ? (isProgressOverText
            ? TossDesignSystem.white // 프로그레스가 텍스트를 덮었으면 흰색
            : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight)) // 아니면 배경과 대조되는 색
        : (isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500);

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveEnabled ? _handleTap : null,
          borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
            child: Stack(
              children: [
                // 배경 레이어 (회색)
                Container(
                  width: double.infinity,
                  height: widget.height,
                  color: backgroundColor,
                ),

                // 프로그레스 레이어 (파란색, 진행률만큼 채움)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: MediaQuery.of(context).size.width * _progressPercentage,
                  height: widget.height,
                  color: progressColor,
                ),

                // 텍스트 및 아이콘 레이어
                Center(
                  child: widget.isLoading
                      ? _ThreeDotsLoadingIndicator(color: textColor)
                      : AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TossDesignSystem.button.copyWith(
                            color: textColor,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.icon != null) ...[
                                widget.icon!,
                                const SizedBox(width: TossDesignSystem.spacingXS),
                              ],
                              Text(widget.text),
                            ],
                          ),
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

/// 점 3개 로딩 애니메이션
class _ThreeDotsLoadingIndicator extends StatefulWidget {
  final Color color;

  const _ThreeDotsLoadingIndicator({required this.color});

  @override
  State<_ThreeDotsLoadingIndicator> createState() => _ThreeDotsLoadingIndicatorState();
}

class _ThreeDotsLoadingIndicatorState extends State<_ThreeDotsLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // 각 점마다 0.2초씩 딜레이
            final delay = index * 0.2;
            final value = (_controller.value - delay) % 1.0;

            // 0.0 ~ 0.5: fade in (0.3 → 1.0)
            // 0.5 ~ 1.0: fade out (1.0 → 0.3)
            final opacity = value < 0.5
                ? 0.3 + (value * 2) * 0.7  // 0.3 → 1.0
                : 1.0 - ((value - 0.5) * 2) * 0.7;  // 1.0 → 0.3

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: index == 1 ? 4 : 2),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(opacity.clamp(0.3, 1.0)),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

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
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: isVisible
          ? (isKeyboardVisible
              ? keyboardHeight + keyboardPadding
              : safeAreaBottom + bottomPadding)
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
