import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'unified_button_enums.dart';
import 'dart:async';

/// 모든 버튼 기능을 통합한 UnifiedButton
///
/// 기능:
/// - 4가지 스타일 (primary, secondary, ghost, text)
/// - 3가지 크기 (large, medium, small)
/// - Floating 기능 (화면 하단 고정)
/// - Progress 기능 (프로그레스 바)
/// - Loading 기능 (3-dot, circular, tarot, mystical)
/// - Debouncing (중복 클릭 방지)
/// - 햅틱 피드백
/// - 다크모드 자동 대응
/// - Gradient 지원
/// - 애니메이션 (fadeIn, slideY, scale)
///
/// 사용 예시:
/// ```dart
/// // 기본 버튼
/// UnifiedButton(
///   text: '확인',
///   onPressed: () {},
/// )
///
/// // Floating 버튼 (하단 고정)
/// UnifiedButton.floating(
///   text: '다음',
///   onPressed: () {},
/// )
///
/// // Progress 버튼
/// UnifiedButton.progress(
///   text: '다음',
///   currentStep: 2,
///   totalSteps: 5,
///   onPressed: () {},
/// )
/// ```
class UnifiedButton extends StatefulWidget {
  // ========== 기본 설정 ==========
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;

  // ========== 스타일 설정 ==========
  final UnifiedButtonStyle style;
  final UnifiedButtonSize size;

  // ========== 로딩 설정 ==========
  final bool isLoading;
  final String? loadingText;
  final UnifiedLoadingType loadingType;

  // ========== 프로그레스 설정 ==========
  final bool showProgress;
  final int? currentStep;
  final int? totalSteps;
  final Color? progressColor;

  // ========== Floating 설정 ==========
  final bool isFloating;
  final double floatingBottom;
  final double floatingHeight;
  final EdgeInsetsGeometry? floatingPadding;
  final bool hideWhenDisabled;

  // ========== 추가 옵션 ==========
  final Widget? icon;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final bool enableHaptic;
  final bool enableDebounce;
  final Duration debounceDuration;

  // ========== 애니메이션 ==========
  final bool enableAnimation;
  final Duration? animationDelay;
  final UnifiedButtonAnimation? animationType;

  // ========== 전통 스타일 테마 ==========
  final bool useBrushFrame;

  const UnifiedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isEnabled = true,
    this.style = UnifiedButtonStyle.primary,
    this.size = UnifiedButtonSize.large,
    this.isLoading = false,
    this.loadingText,
    this.loadingType = UnifiedLoadingType.dots,
    this.showProgress = false,
    this.currentStep,
    this.totalSteps,
    this.progressColor,
    this.isFloating = false,
    this.floatingBottom = 0.0,
    this.floatingHeight = 58.0,
    this.floatingPadding,
    this.hideWhenDisabled = false,
    this.icon,
    this.width,
    this.margin,
    this.gradient,
    this.enableHaptic = true,
    this.enableDebounce = true,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.enableAnimation = false,
    this.animationDelay,
    this.animationType,
    this.useBrushFrame = false, // 에셋 미존재로 기본값 false (필요시 에셋 추가 후 true로 변경)
  });

  // ========== Factory 생성자 (기존 호환성) ==========

  /// UnifiedButton.primary 호환
  factory UnifiedButton.primary({
    required String text,
    VoidCallback? onPressed,
    UnifiedButtonSize size = UnifiedButtonSize.large,
    bool isLoading = false,
    bool isEnabled = true,
    Widget? icon,
    double? width,
    EdgeInsetsGeometry? margin,
  }) {
    return UnifiedButton(
      text: text,
      onPressed: onPressed,
      style: UnifiedButtonStyle.primary,
      size: size,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      width: width,
      margin: margin,
    );
  }

  /// UnifiedButton.secondary 호환
  factory UnifiedButton.secondary({
    required String text,
    VoidCallback? onPressed,
    UnifiedButtonSize size = UnifiedButtonSize.large,
    bool isLoading = false,
    bool isEnabled = true,
    Widget? icon,
    double? width,
    EdgeInsetsGeometry? margin,
  }) {
    return UnifiedButton(
      text: text,
      onPressed: onPressed,
      style: UnifiedButtonStyle.secondary,
      size: size,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      width: width,
      margin: margin,
    );
  }

  /// UnifiedButton.ghost 호환
  factory UnifiedButton.ghost({
    required String text,
    VoidCallback? onPressed,
    UnifiedButtonSize size = UnifiedButtonSize.medium,
    bool isLoading = false,
    bool isEnabled = true,
    Widget? icon,
    double? width,
    EdgeInsetsGeometry? margin,
  }) {
    return UnifiedButton(
      text: text,
      onPressed: onPressed,
      style: UnifiedButtonStyle.ghost,
      size: size,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      width: width,
      margin: margin,
    );
  }

  /// UnifiedButton.text 호환
  factory UnifiedButton.text({
    required String text,
    VoidCallback? onPressed,
    UnifiedButtonSize size = UnifiedButtonSize.small,
    bool isLoading = false,
    bool isEnabled = true,
    Widget? icon,
    EdgeInsetsGeometry? margin,
  }) {
    return UnifiedButton(
      text: text,
      onPressed: onPressed,
      style: UnifiedButtonStyle.text,
      size: size,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      width: null,
      margin: margin,
    );
  }

  /// FloatingBottomButton 호환
  factory UnifiedButton.floating({
    required String text,
    VoidCallback? onPressed,
    UnifiedButtonStyle style = UnifiedButtonStyle.primary,
    UnifiedButtonSize size = UnifiedButtonSize.large,
    bool isLoading = false,
    bool isEnabled = true,
    Widget? icon,
    bool showShadow = true,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    bool hideWhenDisabled = false,
    double height = 58.0,
    double bottom = 0.0,
    bool showProgress = false,
    int? currentStep,
    int? totalSteps,
  }) {
    return UnifiedButton(
      text: text,
      onPressed: onPressed,
      style: style,
      size: size,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      isFloating: true,
      floatingBottom: bottom,
      floatingHeight: height,
      floatingPadding: padding,
      hideWhenDisabled: hideWhenDisabled,
      showProgress: showProgress,
      currentStep: currentStep,
      totalSteps: totalSteps,
    );
  }

  /// 빨간색 Floating 버튼 (소원빌기 등 특별한 액션용)
  factory UnifiedButton.floatingDanger({
    required String text,
    VoidCallback? onPressed,
    UnifiedButtonSize size = UnifiedButtonSize.large,
    bool isLoading = false,
    bool isEnabled = true,
    Widget? icon,
    EdgeInsetsGeometry? padding,
    bool hideWhenDisabled = false,
    double height = 58.0,
    double bottom = 0.0,
  }) {
    return UnifiedButton(
      text: text,
      onPressed: onPressed,
      style: UnifiedButtonStyle.danger,
      size: size,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      isFloating: true,
      floatingBottom: bottom,
      floatingHeight: height,
      floatingPadding: padding,
      hideWhenDisabled: hideWhenDisabled,
    );
  }

  /// TossFloatingProgressButton 호환
  factory UnifiedButton.progress({
    required String text,
    required int currentStep,
    required int totalSteps,
    VoidCallback? onPressed,
    bool isEnabled = true,
    bool isFloating = false,
    double height = 58.0,
    bool isLoading = false,
    Widget? icon,
  }) {
    return UnifiedButton(
      text: text,
      onPressed: onPressed,
      isEnabled: isEnabled,
      showProgress: true,
      currentStep: currentStep,
      totalSteps: totalSteps,
      isFloating: isFloating,
      floatingHeight: height,
      isLoading: isLoading,
      icon: icon,
    );
  }

  /// FortuneButton.analyze 호환
  factory UnifiedButton.analyze({
    required VoidCallback? onPressed,
    bool isLoading = false,
    String text = '인사이트 분석하기',
    bool enableAnimation = true,
    Duration? animationDelay,
  }) {
    return UnifiedButton(
      text: isLoading ? '분석 중...' : text,
      onPressed: isLoading ? null : onPressed,
      style: UnifiedButtonStyle.primary,
      isLoading: isLoading,
      icon: isLoading ? null : const Icon(Icons.auto_awesome, size: 20),
      width: double.infinity,
      enableAnimation: enableAnimation,
      animationDelay: animationDelay,
      animationType: UnifiedButtonAnimation.fadeIn,
    );
  }

  /// FortuneButton.next 호환
  factory UnifiedButton.next({
    required VoidCallback? onPressed,
    bool isEnabled = true,
    String text = '다음',
    bool enableAnimation = true,
    Duration? animationDelay,
  }) {
    return UnifiedButton(
      text: text,
      onPressed: isEnabled ? onPressed : null,
      style: UnifiedButtonStyle.primary,
      isEnabled: isEnabled,
      width: double.infinity,
      enableAnimation: enableAnimation,
      animationDelay: animationDelay,
      animationType: UnifiedButtonAnimation.fadeIn,
    );
  }

  /// FortuneButton.previous 호환
  factory UnifiedButton.previous({
    required VoidCallback? onPressed,
    String text = '이전',
    bool enableAnimation = true,
    Duration? animationDelay,
  }) {
    return UnifiedButton(
      text: text,
      onPressed: onPressed,
      style: UnifiedButtonStyle.secondary,
      width: double.infinity,
      enableAnimation: enableAnimation,
      animationDelay: animationDelay,
      animationType: UnifiedButtonAnimation.fadeIn,
    );
  }

  /// FortuneButton.viewFortune 호환
  factory UnifiedButton.viewFortune({
    required VoidCallback? onPressed,
    bool isEnabled = true,
    bool isLoading = false,
    String text = '인사이트 보기',
    bool enableAnimation = true,
    Duration? animationDelay,
  }) {
    return UnifiedButton(
      text: isLoading ? '인사이트 생성 중...' : text,
      onPressed: (isEnabled && !isLoading) ? onPressed : null,
      style: UnifiedButtonStyle.primary,
      isLoading: isLoading,
      icon: const Icon(Icons.visibility, size: 20),
      width: double.infinity,
      enableAnimation: enableAnimation,
      animationDelay: animationDelay,
      animationType: UnifiedButtonAnimation.fadeIn,
    );
  }

  /// FortuneButton.retry 호환
  factory UnifiedButton.retry({
    required VoidCallback? onPressed,
    String text = '다시 시도',
    bool enableAnimation = true,
    Duration? animationDelay,
  }) {
    return UnifiedButton(
      text: text,
      onPressed: onPressed,
      style: UnifiedButtonStyle.secondary,
      icon: const Icon(Icons.refresh, size: 20),
      width: double.infinity,
      enableAnimation: enableAnimation,
      animationDelay: animationDelay,
      animationType: UnifiedButtonAnimation.fadeIn,
    );
  }

  @override
  State<UnifiedButton> createState() => _UnifiedButtonState();
}

class _UnifiedButtonState extends State<UnifiedButton> {
  Timer? _debounceTimer;
  bool _isProcessing = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Debouncing + 햅틱 피드백 적용 탭 핸들러
  void _handleTap() {
    // Debounce 비활성화 시 바로 실행
    if (!widget.enableDebounce) {
      if (widget.enableHaptic) {
        DSHaptics.light();
      }
      widget.onPressed?.call();
      return;
    }

    // 이미 처리 중이면 무시
    if (_isProcessing) return;

    // Debounce 타이머 취소
    _debounceTimer?.cancel();

    // Debounce 시간 후 재활성화
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });

    setState(() {
      _isProcessing = true;
    });

    if (widget.enableHaptic) {
      DSHaptics.light();
    }
    widget.onPressed?.call();
  }

  /// 진행률 계산 (0.0 ~ 1.0)
  double get _progressPercentage {
    if (!widget.showProgress ||
        widget.currentStep == null ||
        widget.totalSteps == null ||
        widget.totalSteps == 0) {
      return 1.0;
    }
    return (widget.currentStep! / widget.totalSteps!).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    Widget button = _buildButton(context);

    // 애니메이션 적용
    if (widget.enableAnimation) {
      button = _applyAnimation(button);
    }

    // Floating 래퍼 적용
    if (widget.isFloating) {
      return _buildFloatingWrapper(context, button);
    }

    // margin 적용
    if (widget.margin != null) {
      button = Padding(
        padding: widget.margin!,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButton(BuildContext context) {
    // Progress 버튼
    if (widget.showProgress &&
        widget.currentStep != null &&
        widget.totalSteps != null) {
      return _buildProgressButton(context);
    }

    // 일반 버튼
    return _buildBasicButton(context);
  }

  Widget _buildProgressButton(BuildContext context) {
    final colors = context.colors;
    final effectiveEnabled = widget.isEnabled &&
        !widget.isLoading &&
        !_isProcessing &&
        widget.onPressed != null;

    // 색상 정의
    final backgroundColor = colors.backgroundTertiary;

    final progressColor = widget.progressColor ??
        (effectiveEnabled ? colors.accent : colors.textDisabled);

    // 프로그레스가 텍스트 위치를 넘었는지 여부
    final isProgressOverText = _progressPercentage >= 0.5;

    final textColor = effectiveEnabled
        ? (isProgressOverText ? colors.ctaForeground : colors.textPrimary)
        : colors.textDisabled;

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.floatingHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveEnabled ? _handleTap : null,
          borderRadius: BorderRadius.circular(DSRadius.md),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DSRadius.md),
            child: Stack(
              children: [
                // 배경 레이어
                Container(
                  width: double.infinity,
                  height: widget.floatingHeight,
                  color: backgroundColor,
                ),

                // 프로그레스 레이어
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: (widget.width ?? MediaQuery.of(context).size.width) *
                      _progressPercentage,
                  height: widget.floatingHeight,
                  color: progressColor,
                ),

                // 텍스트 및 아이콘 레이어
                Center(
                  child: widget.isLoading
                      ? _buildLoadingIndicator(textColor)
                      : AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: DSTypography.buttonLarge.copyWith(
                            color: textColor,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.icon != null) ...[
                                widget.icon!,
                                const SizedBox(width: DSSpacing.xs),
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

  Widget _buildBasicButton(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;
    final effectiveEnabled = widget.isEnabled &&
        !widget.isLoading &&
        !_isProcessing &&
        widget.onPressed != null;

    final Widget child = widget.isLoading
        ? _buildLoadingIndicator(
            _getTextColor(colors, isDark, effectiveEnabled))
        : Row(
            mainAxisSize:
                widget.width != null ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    color: _getTextColor(colors, isDark, effectiveEnabled),
                    size: 20,
                  ),
                  child: widget.icon!,
                ),
                if (widget.text.isNotEmpty) const SizedBox(width: DSSpacing.xs),
              ],
              if (widget.text.isNotEmpty)
                Flexible(
                  child: Text(
                    widget.text,
                    style: _getTextStyle(colors, isDark, effectiveEnabled)
                        .copyWith(
                      inherit: false, // CRITICAL: Prevent TextStyle lerp error
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
            ],
          );

    // Use Material + InkWell instead of ElevatedButton/OutlinedButton/TextButton
    // to avoid AnimatedDefaultTextStyle lerp issues during theme transitions
    final buttonConfig = _getButtonConfig(colors, effectiveEnabled);

    Widget button = Material(
      color: widget.useBrushFrame && widget.style == UnifiedButtonStyle.primary
          ? Colors.transparent
          : buttonConfig.backgroundColor,
      borderRadius: BorderRadius.circular(DSRadius.md),
      child: InkWell(
        onTap: effectiveEnabled ? _handleTap : null,
        borderRadius: BorderRadius.circular(DSRadius.md),
        splashColor: buttonConfig.splashColor,
        highlightColor: buttonConfig.highlightColor,
        child: Container(
          height: _getHeight(),
          padding: _getPadding(),
          decoration:
              widget.useBrushFrame && widget.style == UnifiedButtonStyle.primary
                  ? BoxDecoration(
                      image: DecorationImage(
                        image: const AssetImage(
                            'assets/images/ui/btn_brush_frame.png'),
                        fit: BoxFit.fill,
                        colorFilter: !effectiveEnabled
                            ? ColorFilter.mode(
                                Colors.white.withValues(alpha: 0.5),
                                BlendMode.dstIn,
                              )
                            : null,
                      ),
                    )
                  : (buttonConfig.border != null
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(DSRadius.md),
                          border: buttonConfig.border,
                        )
                      : null),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );

    if (widget.width != null) {
      button = SizedBox(
        width: widget.width,
        child: button,
      );
    }

    return button;
  }

  /// Button configuration based on style
  _ButtonConfig _getButtonConfig(DSColorScheme colors, bool enabled) {
    switch (widget.style) {
      case UnifiedButtonStyle.primary:
        return _ButtonConfig(
          backgroundColor: enabled
              ? colors.ctaBackground
              : colors.ctaBackground.withValues(alpha: 0.5),
          splashColor: colors.ctaForeground.withValues(alpha: 0.1),
          highlightColor: colors.ctaForeground.withValues(alpha: 0.05),
          border: null,
        );
      case UnifiedButtonStyle.secondary:
        return _ButtonConfig(
          backgroundColor: colors.backgroundTertiary,
          splashColor: colors.textPrimary.withValues(alpha: 0.1),
          highlightColor: colors.textPrimary.withValues(alpha: 0.05),
          border: null,
        );
      case UnifiedButtonStyle.ghost:
        return _ButtonConfig(
          backgroundColor: Colors.transparent,
          splashColor: colors.accent.withValues(alpha: 0.1),
          highlightColor: colors.accent.withValues(alpha: 0.05),
          border: Border.all(
            color: enabled ? colors.accent : colors.border,
            width: 1,
          ),
        );
      case UnifiedButtonStyle.text:
        return _ButtonConfig(
          backgroundColor: Colors.transparent,
          splashColor: colors.accent.withValues(alpha: 0.1),
          highlightColor: colors.accent.withValues(alpha: 0.05),
          border: null,
        );
      case UnifiedButtonStyle.danger:
        return _ButtonConfig(
          backgroundColor:
              enabled ? DSColors.error : DSColors.error.withValues(alpha: 0.5),
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          border: null,
        );
    }
  }

  Widget _buildFloatingWrapper(BuildContext context, Widget button) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // hideWhenDisabled가 true이고 onPressed가 null이면 버튼 숨김
    if (widget.hideWhenDisabled && widget.onPressed == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: widget.floatingBottom,
      child: Container(
        color: Colors.transparent,
        padding: widget.floatingPadding ??
            EdgeInsets.fromLTRB(
              20,
              0,
              20,
              16 + bottomPadding,
            ),
        child: SizedBox(
          height: widget.floatingHeight,
          child: button,
        ),
      ),
    );
  }

  Widget _applyAnimation(Widget button) {
    if (widget.animationDelay != null) {
      button = button
          .animate(delay: widget.animationDelay!)
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.2, end: 0);
    } else {
      button =
          button.animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
    }

    return button;
  }

  Widget _buildLoadingIndicator(Color color) {
    switch (widget.loadingType) {
      case UnifiedLoadingType.dots:
        return _ThreeDotsLoadingIndicator(color: color);
      case UnifiedLoadingType.circular:
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );
      case UnifiedLoadingType.tarot:
      case UnifiedLoadingType.mystical:
        // TODO: 추후 타로/신비 애니메이션 구현
        return _ThreeDotsLoadingIndicator(color: color);
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case UnifiedButtonSize.large:
        return 56.0;
      case UnifiedButtonSize.medium:
        return 48.0;
      case UnifiedButtonSize.small:
        return 40.0;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (widget.size) {
      case UnifiedButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: DSSpacing.lg);
      case UnifiedButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: DSSpacing.md);
      case UnifiedButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: DSSpacing.md);
    }
  }

  TextStyle _getTextStyle(DSColorScheme colors, bool isDark, bool enabled) {
    final baseStyle = widget.size == UnifiedButtonSize.small
        ? DSTypography.buttonSmall
        : DSTypography.buttonLarge;

    return baseStyle.copyWith(
      color: _getTextColor(colors, isDark, enabled),
    );
  }

  Color _getTextColor(DSColorScheme colors, bool isDark, bool enabled) {
    if (!enabled) {
      return colors.textDisabled;
    }

    switch (widget.style) {
      case UnifiedButtonStyle.primary:
        return colors.ctaForeground;
      case UnifiedButtonStyle.secondary:
        return colors.textPrimary;
      case UnifiedButtonStyle.ghost:
        return colors.accent;
      case UnifiedButtonStyle.text:
        return colors.accent;
      case UnifiedButtonStyle.danger:
        return Colors.white;
    }
  }

  // Old ButtonStyle methods removed - using _ButtonConfig with Material + InkWell instead
}

/// 점 3개 로딩 애니메이션
class _ThreeDotsLoadingIndicator extends StatefulWidget {
  final Color color;

  const _ThreeDotsLoadingIndicator({required this.color});

  @override
  State<_ThreeDotsLoadingIndicator> createState() =>
      _ThreeDotsLoadingIndicatorState();
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
                ? 0.3 + (value * 2) * 0.7
                : 1.0 - ((value - 0.5) * 2) * 0.7;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: index == 1 ? 4 : 2),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color:
                      widget.color.withValues(alpha: opacity.clamp(0.3, 1.0)),
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

/// Button configuration for custom Material + InkWell implementation
/// Used to avoid AnimatedDefaultTextStyle lerp issues during theme transitions
class _ButtonConfig {
  final Color backgroundColor;
  final Color splashColor;
  final Color highlightColor;
  final Border? border;

  const _ButtonConfig({
    required this.backgroundColor,
    required this.splashColor,
    required this.highlightColor,
    this.border,
  });
}
