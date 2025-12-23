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
  /// Vermilion seal stamp style (주색 인장) - Korean traditional CTA
  primary,

  /// Hanji paper background with ink text
  secondary,

  /// Ink-wash border style
  outline,

  /// Transparent, accent text only
  ghost,

  /// Destructive action (vermilion red)
  destructive,

  /// Gold accent for premium actions
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

/// Korean Traditional "Saaju" button component
///
/// Features seal/stamp (인장) styling with press-into-paper effect
/// and vermilion red (주색) for primary actions
///
/// Usage:
/// ```dart
/// // Vermilion seal button (primary CTA)
/// DSButton.primary(
///   text: '운세 보기',
///   onPressed: () {},
/// )
///
/// // Gold accent button (premium)
/// DSButton.gold(
///   text: '프리미엄 구매',
///   onPressed: () {},
/// )
///
/// // Hanji paper style (secondary)
/// DSButton.secondary(
///   text: '취소',
///   onPressed: () {},
/// )
/// ```
class DSButton extends StatefulWidget {
  /// Button text
  final String text;

  /// Press callback (null = disabled)
  final VoidCallback? onPressed;

  /// Button style variant
  final DSButtonStyle style;

  /// Button size
  final DSButtonSize size;

  /// Show loading indicator
  final bool isLoading;

  /// Leading icon
  final IconData? leadingIcon;

  /// Trailing icon
  final IconData? trailingIcon;

  /// Full width button
  final bool fullWidth;

  /// Enable haptic feedback
  final bool enableHaptic;

  const DSButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = DSButtonStyle.primary,
    this.size = DSButtonSize.large,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = true,
    this.enableHaptic = true,
  });

  /// Primary CTA button
  factory DSButton.primary({
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
      style: DSButtonStyle.primary,
      size: size,
      isLoading: isLoading,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      fullWidth: fullWidth,
      enableHaptic: enableHaptic,
    );
  }

  /// Secondary button
  factory DSButton.secondary({
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
      style: DSButtonStyle.secondary,
      size: size,
      isLoading: isLoading,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      fullWidth: fullWidth,
      enableHaptic: enableHaptic,
    );
  }

  /// Outline button
  factory DSButton.outline({
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
      style: DSButtonStyle.outline,
      size: size,
      isLoading: isLoading,
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

  /// Gold accent button (for premium actions)
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

  @override
  void initState() {
    super.initState();
    // Seal press animation - press into paper effect (인장 효과)
    _scaleController = AnimationController(
      duration: DSAnimation.sealPress,
      reverseDuration: DSAnimation.sealRelease,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: DSAnimation.sealPressScale,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: DSAnimation.sealPressCurve,
        reverseCurve: DSAnimation.sealReleaseCurve,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
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
    if (widget.enableHaptic) {
      DSHaptics.light();
    }
    widget.onPressed?.call();
  }

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  double get _height {
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEnabled = _isEnabled;

    // Get colors and decoration based on style and state
    Color backgroundColor;
    Color foregroundColor;
    Color? borderColor;
    List<BoxShadow>? boxShadow;

    switch (widget.style) {
      case DSButtonStyle.primary:
        // Vermilion seal stamp style (주색 인장)
        backgroundColor = isEnabled
            ? (_isPressed ? colors.accentSecondaryHover : colors.accentSecondary)
            : colors.accentSecondary.withValues(alpha: 0.5);
        foregroundColor = colors.ctaForeground;
        // Seal shadow when not pressed
        if (!_isPressed && isEnabled) {
          boxShadow = [
            BoxShadow(
              color: colors.accentSecondary.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ];
        }
        break;
      case DSButtonStyle.secondary:
        // Hanji paper background with ink text
        backgroundColor = isEnabled
            ? colors.secondaryBackground
            : colors.secondaryBackground.withValues(alpha: 0.5);
        foregroundColor = isEnabled
            ? colors.secondaryForeground
            : colors.textDisabled;
        break;
      case DSButtonStyle.outline:
        // Ink-wash border style
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? colors.textPrimary : colors.textDisabled;
        borderColor = isEnabled
            ? colors.textPrimary.withValues(alpha: 0.2)
            : colors.textDisabled;
        break;
      case DSButtonStyle.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? colors.accent : colors.textDisabled;
        break;
      case DSButtonStyle.destructive:
        backgroundColor = isEnabled
            ? (_isPressed ? DSColors.accentSecondaryHover : colors.error)
            : colors.error.withValues(alpha: 0.5);
        foregroundColor = DSColors.ctaForeground;
        break;
      case DSButtonStyle.gold:
        // Gold accent for premium actions (황금색)
        backgroundColor = isEnabled
            ? (_isPressed
                ? colors.accentTertiary.withValues(alpha: 0.9)
                : colors.accentTertiary)
            : colors.accentTertiary.withValues(alpha: 0.5);
        foregroundColor = Colors.white;
        // Gold glow when not pressed
        if (!_isPressed && isEnabled) {
          boxShadow = [
            BoxShadow(
              color: colors.accentTertiary.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ];
        }
        break;
    }

    final Widget buttonContent = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(foregroundColor),
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
        ] else if (widget.leadingIcon != null) ...[
          Icon(widget.leadingIcon, size: _iconSize, color: foregroundColor),
          const SizedBox(width: DSSpacing.sm),
        ],
        Text(
          widget.text,
          style: _textStyle.copyWith(color: foregroundColor),
        ),
        if (widget.trailingIcon != null && !widget.isLoading) ...[
          const SizedBox(width: DSSpacing.sm),
          Icon(widget.trailingIcon, size: _iconSize, color: foregroundColor),
        ],
      ],
    );

    final Widget button = AnimatedBuilder(
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
          duration: DSAnimation.durationFast,
          height: _height,
          padding: EdgeInsets.symmetric(
            horizontal: widget.size == DSButtonSize.small
                ? DSSpacing.md
                : DSSpacing.buttonHorizontal,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(DSRadius.seal),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1)
                : null,
            boxShadow: boxShadow,
          ),
          child: Center(child: buttonContent),
        ),
      ),
    );

    if (widget.fullWidth) {
      return button;
    }

    return IntrinsicWidth(child: button);
  }
}
