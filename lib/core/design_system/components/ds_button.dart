import 'dart:async';

import 'package:flutter/material.dart';
import '../tokens/ds_colors.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_typography.dart';
import '../tokens/ds_animation.dart';
import '../utils/ds_haptics.dart';
import '../theme/ds_extensions.dart';

/// Button style variants
enum DSButtonStyle {
  /// Filled accent button - modern CTA style
  primary,

  /// Light gray filled background
  secondary,

  /// Clean border style
  outline,

  /// Transparent, accent text only
  ghost,

  /// Destructive action (red)
  destructive,

  /// Premium accent (kept for compatibility)
  gold,
}

/// Button size variants
enum DSButtonSize {
  /// 56px height
  large,

  /// 48px height
  medium,

  /// 40px height
  small,
}

/// Loading indicator type
enum DSButtonLoadingType {
  /// Three bouncing dots animation (default)
  dots,

  /// Circular progress indicator
  circular,
}

/// Modern AI Chat style button component
///
/// Clean, minimalist design with subtle press effects.
/// Supports floating mode, progress bar, debounce, and custom loading.
///
/// Usage:
/// ```dart
/// // Primary CTA button
/// DSButton.primary(
///   text: 'Continue',
///   onPressed: () {},
/// )
///
/// // Floating bottom button
/// DSFloatingButton(
///   text: '다음',
///   onPressed: () {},
/// )
///
/// // Progress button
/// DSButton.progress(
///   text: '다음',
///   currentStep: 2,
///   totalSteps: 5,
///   onPressed: () {},
/// )
/// ```
class DSButton extends StatefulWidget {
  /// Button text
  final String text;

  /// Subtitle/description text (optional)
  final String? subtitle;

  /// Press callback (null = disabled)
  final VoidCallback? onPressed;

  /// Button style variant
  final DSButtonStyle style;

  /// Button size
  final DSButtonSize size;

  /// Show loading indicator
  final bool isLoading;

  /// Loading indicator type
  final DSButtonLoadingType loadingType;

  /// Leading icon (IconData)
  final IconData? leadingIcon;

  /// Leading widget (overrides leadingIcon if both set)
  final Widget? leadingWidget;

  /// Trailing icon
  final IconData? trailingIcon;

  /// Full width button
  final bool fullWidth;

  /// Custom width
  final double? width;

  /// Custom margin
  final EdgeInsetsGeometry? margin;

  /// Enable haptic feedback
  final bool enableHaptic;

  /// Enable debounce to prevent double-tap
  final bool enableDebounce;

  /// Debounce duration
  final Duration debounceDuration;

  /// Show progress bar
  final bool showProgress;

  /// Current step (for progress)
  final int? currentStep;

  /// Total steps (for progress)
  final int? totalSteps;

  /// Custom progress color
  final Color? progressColor;

  /// Custom height (overrides size-based height)
  final double? customHeight;

  const DSButton({
    super.key,
    required this.text,
    this.subtitle,
    this.onPressed,
    this.style = DSButtonStyle.primary,
    this.size = DSButtonSize.large,
    this.isLoading = false,
    this.loadingType = DSButtonLoadingType.dots,
    this.leadingIcon,
    this.leadingWidget,
    this.trailingIcon,
    this.fullWidth = true,
    this.width,
    this.margin,
    this.enableHaptic = true,
    this.enableDebounce = true,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.showProgress = false,
    this.currentStep,
    this.totalSteps,
    this.progressColor,
    this.customHeight,
  });

  /// Primary CTA button
  factory DSButton.primary({
    Key? key,
    required String text,
    String? subtitle,
    VoidCallback? onPressed,
    DSButtonSize size = DSButtonSize.large,
    bool isLoading = false,
    DSButtonLoadingType loadingType = DSButtonLoadingType.dots,
    IconData? leadingIcon,
    Widget? leadingWidget,
    IconData? trailingIcon,
    bool fullWidth = true,
    double? width,
    bool enableHaptic = true,
    bool enableDebounce = true,
  }) {
    return DSButton(
      key: key,
      text: text,
      subtitle: subtitle,
      onPressed: onPressed,
      style: DSButtonStyle.primary,
      size: size,
      isLoading: isLoading,
      loadingType: loadingType,
      leadingIcon: leadingIcon,
      leadingWidget: leadingWidget,
      trailingIcon: trailingIcon,
      fullWidth: fullWidth,
      width: width,
      enableHaptic: enableHaptic,
      enableDebounce: enableDebounce,
    );
  }

  /// Secondary button
  factory DSButton.secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    DSButtonSize size = DSButtonSize.large,
    bool isLoading = false,
    DSButtonLoadingType loadingType = DSButtonLoadingType.dots,
    IconData? leadingIcon,
    Widget? leadingWidget,
    IconData? trailingIcon,
    bool fullWidth = true,
    double? width,
    bool enableHaptic = true,
    bool enableDebounce = true,
  }) {
    return DSButton(
      key: key,
      text: text,
      onPressed: onPressed,
      style: DSButtonStyle.secondary,
      size: size,
      isLoading: isLoading,
      loadingType: loadingType,
      leadingIcon: leadingIcon,
      leadingWidget: leadingWidget,
      trailingIcon: trailingIcon,
      fullWidth: fullWidth,
      width: width,
      enableHaptic: enableHaptic,
      enableDebounce: enableDebounce,
    );
  }

  /// Outline button
  factory DSButton.outline({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    DSButtonSize size = DSButtonSize.large,
    bool isLoading = false,
    DSButtonLoadingType loadingType = DSButtonLoadingType.dots,
    IconData? leadingIcon,
    IconData? trailingIcon,
    bool fullWidth = true,
    bool enableHaptic = true,
  }) {
    return DSButton(
      key: key,
      text: text,
      onPressed: onPressed,
      style: DSButtonStyle.outline,
      size: size,
      isLoading: isLoading,
      loadingType: loadingType,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      fullWidth: fullWidth,
      enableHaptic: enableHaptic,
    );
  }

  /// Ghost button (text only)
  factory DSButton.ghost({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    DSButtonSize size = DSButtonSize.medium,
    bool isLoading = false,
    IconData? leadingIcon,
    IconData? trailingIcon,
    bool fullWidth = false,
    bool enableHaptic = true,
  }) {
    return DSButton(
      key: key,
      text: text,
      onPressed: onPressed,
      style: DSButtonStyle.ghost,
      size: size,
      isLoading: isLoading,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      fullWidth: fullWidth,
      enableHaptic: enableHaptic,
    );
  }

  /// Destructive button (for delete, logout, etc)
  factory DSButton.destructive({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    DSButtonSize size = DSButtonSize.large,
    bool isLoading = false,
    IconData? leadingIcon,
    IconData? trailingIcon,
    bool fullWidth = true,
    bool enableHaptic = true,
  }) {
    return DSButton(
      key: key,
      text: text,
      onPressed: onPressed,
      style: DSButtonStyle.destructive,
      size: size,
      isLoading: isLoading,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      fullWidth: fullWidth,
      enableHaptic: enableHaptic,
    );
  }

  /// Progress button with step indicator
  factory DSButton.progress({
    Key? key,
    required String text,
    required int currentStep,
    required int totalSteps,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? leadingIcon,
    Widget? leadingWidget,
    double? height,
    Color? progressColor,
    bool enableHaptic = true,
    bool enableDebounce = true,
  }) {
    return DSButton(
      key: key,
      text: text,
      onPressed: onPressed,
      showProgress: true,
      currentStep: currentStep,
      totalSteps: totalSteps,
      isLoading: isLoading,
      leadingIcon: leadingIcon,
      leadingWidget: leadingWidget,
      customHeight: height,
      progressColor: progressColor,
      enableHaptic: enableHaptic,
      enableDebounce: enableDebounce,
    );
  }

  /// Gold/Premium accent button
  @Deprecated('Use primary button for most cases')
  factory DSButton.gold({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    DSButtonSize size = DSButtonSize.large,
    bool isLoading = false,
    IconData? leadingIcon,
    IconData? trailingIcon,
    bool fullWidth = true,
    bool enableHaptic = true,
  }) {
    return DSButton(
      key: key,
      text: text,
      onPressed: onPressed,
      style: DSButtonStyle.gold,
      size: size,
      isLoading: isLoading,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      fullWidth: fullWidth,
      enableHaptic: enableHaptic,
    );
  }

  @override
  State<DSButton> createState() => _DSButtonState();
}

class _DSButtonState extends State<DSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;
  Timer? _debounceTimer;
  bool _isDebouncing = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: DSAnimation.buttonPress,
      reverseDuration: DSAnimation.buttonRelease,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: DSAnimation.pressScale,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: DSAnimation.buttonPressCurve,
        reverseCurve: DSAnimation.buttonReleaseCurve,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isEnabled) return;
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTap() {
    if (!_isEnabled || widget.isLoading) return;

    // Debounce logic
    if (widget.enableDebounce) {
      if (_isDebouncing) return;
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.debounceDuration, () {
        if (mounted) setState(() => _isDebouncing = false);
      });
      setState(() => _isDebouncing = true);
    }

    if (widget.enableHaptic) {
      DSHaptics.light();
    }
    widget.onPressed?.call();
  }

  bool get _isEnabled =>
      widget.onPressed != null && !widget.isLoading && !_isDebouncing;

  double get _height {
    if (widget.customHeight != null) return widget.customHeight!;
    switch (widget.size) {
      case DSButtonSize.large:
        return 56.0;
      case DSButtonSize.medium:
        return 48.0;
      case DSButtonSize.small:
        return 40.0;
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case DSButtonSize.large:
        return DSTypography.buttonLarge;
      case DSButtonSize.medium:
        return DSTypography.buttonMedium;
      case DSButtonSize.small:
        return DSTypography.buttonSmall;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case DSButtonSize.large:
        return 20.0;
      case DSButtonSize.medium:
        return 18.0;
      case DSButtonSize.small:
        return 16.0;
    }
  }

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
    // Progress button uses a different layout
    if (widget.showProgress &&
        widget.currentStep != null &&
        widget.totalSteps != null) {
      return _buildProgressButton(context);
    }

    return _buildStandardButton(context);
  }

  Widget _buildProgressButton(BuildContext context) {
    final colors = context.colors;
    final isEnabled = _isEnabled;

    final backgroundColor = colors.backgroundTertiary;
    final progressColor = widget.progressColor ??
        (isEnabled ? colors.accent : colors.textDisabled);
    final isProgressOverText = _progressPercentage >= 0.5;
    final textColor = isEnabled
        ? (isProgressOverText ? colors.ctaForeground : colors.textPrimary)
        : colors.textDisabled;

    final button = SizedBox(
      width: widget.width ?? double.infinity,
      height: _height,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DSRadius.button),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: _height,
                  color: backgroundColor,
                ),
                AnimatedContainer(
                  duration: DSAnimation.normal,
                  curve: Curves.easeInOut,
                  width:
                      (widget.width ?? MediaQuery.of(context).size.width) *
                          _progressPercentage,
                  height: _height,
                  color: progressColor,
                ),
                Center(
                  child: widget.isLoading
                      ? _buildLoadingIndicator(textColor)
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_effectiveLeading != null) ...[
                              _effectiveLeading!,
                              const SizedBox(width: DSSpacing.xs),
                            ],
                            Text(
                              widget.text,
                              style: _textStyle.copyWith(color: textColor),
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

    if (widget.margin != null) {
      return Padding(padding: widget.margin!, child: button);
    }
    return button;
  }

  Widget _buildStandardButton(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isEnabled = _isEnabled;

    Color backgroundColor;
    Color foregroundColor;
    Color? borderColor;
    List<BoxShadow>? boxShadow;

    switch (widget.style) {
      case DSButtonStyle.primary:
        backgroundColor = isEnabled
            ? (_isPressed
                ? colors.backgroundTertiary
                : colors.surfaceSecondary)
            : colors.surfaceSecondary.withValues(alpha: 0.5);
        foregroundColor =
            isEnabled ? colors.textPrimary : colors.textDisabled;
        break;

      case DSButtonStyle.secondary:
        backgroundColor = isEnabled
            ? (_isPressed
                ? colors.backgroundTertiary
                : colors.backgroundSecondary)
            : colors.backgroundSecondary.withValues(alpha: 0.5);
        foregroundColor =
            isEnabled ? colors.textPrimary : colors.textDisabled;
        break;

      case DSButtonStyle.outline:
        backgroundColor =
            _isPressed ? colors.backgroundSecondary : Colors.transparent;
        foregroundColor =
            isEnabled ? colors.textPrimary : colors.textDisabled;
        borderColor =
            isEnabled ? colors.border : colors.border.withValues(alpha: 0.5);
        break;

      case DSButtonStyle.ghost:
        backgroundColor =
            _isPressed ? colors.backgroundSecondary : Colors.transparent;
        foregroundColor = isEnabled ? colors.accent : colors.textDisabled;
        break;

      case DSButtonStyle.destructive:
        backgroundColor = isEnabled
            ? (_isPressed
                ? colors.error.withValues(alpha: 0.9)
                : colors.error)
            : colors.error.withValues(alpha: 0.5);
        foregroundColor = DSColors.textPrimaryDark;
        break;

      case DSButtonStyle.gold:
        backgroundColor = isEnabled
            ? (_isPressed
                ? colors.warning.withValues(alpha: 0.9)
                : colors.warning)
            : colors.warning.withValues(alpha: 0.5);
        foregroundColor = DSColors.textPrimary;
        break;
    }

    // Build text content (with optional subtitle)
    final Widget textContent = widget.subtitle != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.text,
                style: _textStyle.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.subtitle!,
                style: typography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          )
        : Text(
            widget.text,
            style: _textStyle.copyWith(color: foregroundColor),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          );

    final Widget buttonContent = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: widget.subtitle != null
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          _buildLoadingIndicator(foregroundColor),
          const SizedBox(width: DSSpacing.sm),
        ] else if (_effectiveLeading != null) ...[
          IconTheme(
            data: IconThemeData(color: foregroundColor, size: _iconSize),
            child: _effectiveLeading!,
          ),
          if (widget.text.isNotEmpty) const SizedBox(width: DSSpacing.sm),
        ],
        if (widget.text.isNotEmpty) Flexible(child: textContent),
        if (widget.trailingIcon != null && !widget.isLoading) ...[
          const SizedBox(width: DSSpacing.sm),
          Icon(widget.trailingIcon, size: _iconSize, color: foregroundColor),
        ],
      ],
    );

    Widget button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: DSAnimation.fast,
          constraints: BoxConstraints(
            minHeight: widget.subtitle != null ? _height + 16 : _height,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.size == DSButtonSize.small
                ? DSSpacing.md
                : DSSpacing.buttonHorizontal,
            vertical: widget.subtitle != null ? DSSpacing.sm + 4 : 0,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(DSRadius.button),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1)
                : null,
            boxShadow: boxShadow,
          ),
          child: Center(child: buttonContent),
        ),
      ),
    );

    if (widget.width != null) {
      button = SizedBox(width: widget.width, child: button);
    } else if (widget.fullWidth) {
      // Already full width via constraints
    } else {
      button = IntrinsicWidth(child: button);
    }

    if (widget.margin != null) {
      button = Padding(padding: widget.margin!, child: button);
    }

    return button;
  }

  Widget? get _effectiveLeading {
    if (widget.leadingWidget != null) return widget.leadingWidget;
    if (widget.leadingIcon != null) {
      return Icon(widget.leadingIcon, size: _iconSize);
    }
    return null;
  }

  Widget _buildLoadingIndicator(Color color) {
    switch (widget.loadingType) {
      case DSButtonLoadingType.dots:
        return _ThreeDotsLoading(color: color);
      case DSButtonLoadingType.circular:
        return SizedBox(
          width: _iconSize,
          height: _iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        );
    }
  }
}

// ============================================
// FLOATING BUTTON WRAPPER
// ============================================

/// Floating button that sticks to the bottom of the screen.
///
/// Wraps a DSButton with safe area padding and positioning.
/// Must be used inside a Stack.
///
/// ```dart
/// Stack(
///   children: [
///     content,
///     DSFloatingButton(
///       text: '다음',
///       onPressed: () {},
///     ),
///   ],
/// )
/// ```
class DSFloatingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final DSButtonStyle style;
  final DSButtonSize size;
  final bool isLoading;
  final DSButtonLoadingType loadingType;
  final IconData? leadingIcon;
  final Widget? leadingWidget;
  final bool enableHaptic;
  final bool enableDebounce;
  final double bottom;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool hideWhenDisabled;

  /// Progress bar support
  final bool showProgress;
  final int? currentStep;
  final int? totalSteps;
  final Color? progressColor;

  const DSFloatingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = DSButtonStyle.primary,
    this.size = DSButtonSize.large,
    this.isLoading = false,
    this.loadingType = DSButtonLoadingType.dots,
    this.leadingIcon,
    this.leadingWidget,
    this.enableHaptic = true,
    this.enableDebounce = true,
    this.bottom = 0.0,
    this.height,
    this.padding,
    this.hideWhenDisabled = false,
    this.showProgress = false,
    this.currentStep,
    this.totalSteps,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    if (hideWhenDisabled && onPressed == null) {
      return const SizedBox.shrink();
    }

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottom,
      child: Container(
        color: Colors.transparent,
        padding: padding ??
            EdgeInsets.fromLTRB(
              DSSpacing.pageHorizontal,
              0,
              DSSpacing.pageHorizontal,
              DSSpacing.md + bottomPadding,
            ),
        child: SizedBox(
          height: height ?? 58.0,
          child: DSButton(
            text: text,
            onPressed: onPressed,
            style: style,
            size: size,
            isLoading: isLoading,
            loadingType: loadingType,
            leadingIcon: leadingIcon,
            leadingWidget: leadingWidget,
            enableHaptic: enableHaptic,
            enableDebounce: enableDebounce,
            showProgress: showProgress,
            currentStep: currentStep,
            totalSteps: totalSteps,
            progressColor: progressColor,
            customHeight: height ?? 58.0,
          ),
        ),
      ),
    );
  }
}

/// Spacing widget to reserve space for a floating bottom button.
///
/// Place this at the end of a scrollable list to prevent
/// content from being hidden behind the floating button.
class DSBottomButtonSpacing extends StatelessWidget {
  final double additionalSpacing;

  const DSBottomButtonSpacing({
    super.key,
    this.additionalSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SizedBox(
      height: 58 + DSSpacing.md + bottomPadding + additionalSpacing,
    );
  }
}

// ============================================
// THREE DOTS LOADING ANIMATION
// ============================================

class _ThreeDotsLoading extends StatefulWidget {
  final Color color;

  const _ThreeDotsLoading({required this.color});

  @override
  State<_ThreeDotsLoading> createState() => _ThreeDotsLoadingState();
}

class _ThreeDotsLoadingState extends State<_ThreeDotsLoading>
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
            final delay = index * 0.2;
            final value = (_controller.value - delay) % 1.0;
            final opacity = value < 0.5
                ? 0.3 + (value * 2) * 0.7
                : 1.0 - ((value - 0.5) * 2) * 0.7;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: index == 1 ? 4 : 2),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.color
                      .withValues(alpha: opacity.clamp(0.3, 1.0)),
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
