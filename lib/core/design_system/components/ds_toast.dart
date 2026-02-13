import 'dart:async';
import 'package:flutter/material.dart';
import '../tokens/ds_colors.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_typography.dart';
import '../tokens/ds_animation.dart';
import '../theme/ds_extensions.dart';
import '../utils/ds_haptics.dart';

/// Toast type variants
enum DSToastType {
  /// Default informational toast
  info,

  /// Success toast
  success,

  /// Error toast
  error,

  /// Warning toast
  warning,
}

/// Toast position
enum DSToastPosition {
  top,
  bottom,
}

/// ChatGPT-inspired toast notification
///
/// Usage:
/// ```dart
/// DSToast.show(
///   context: context,
///   message: '저장되었습니다',
///   type: DSToastType.success,
/// )
/// ```
class DSToast {
  static OverlayEntry? _currentEntry;
  static Timer? _timer;

  /// Show a toast message
  static void show({
    required BuildContext context,
    required String message,
    DSToastType type = DSToastType.info,
    DSToastPosition position = DSToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
    VoidCallback? onTap,
    bool enableHaptic = true,
  }) {
    // Remove any existing toast
    dismiss();

    // Haptic feedback
    if (enableHaptic) {
      switch (type) {
        case DSToastType.success:
          DSHaptics.success();
          break;
        case DSToastType.error:
          DSHaptics.error();
          break;
        case DSToastType.warning:
          DSHaptics.warning();
          break;
        case DSToastType.info:
          DSHaptics.light();
          break;
      }
    }

    final overlay = Overlay.of(context);

    _currentEntry = OverlayEntry(
      builder: (context) => _DSToastWidget(
        message: message,
        type: type,
        position: position,
        icon: icon,
        onTap: onTap,
        onDismiss: dismiss,
      ),
    );

    overlay.insert(_currentEntry!);

    // Auto dismiss
    _timer = Timer(duration, dismiss);
  }

  /// Show success toast
  static void success(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      type: DSToastType.success,
      icon: Icons.check_circle_outline,
    );
  }

  /// Show error toast
  static void error(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      type: DSToastType.error,
      icon: Icons.error_outline,
    );
  }

  /// Show warning toast
  static void warning(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      type: DSToastType.warning,
      icon: Icons.warning_amber_outlined,
    );
  }

  /// Show info toast
  static void info(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      type: DSToastType.info,
      icon: Icons.info_outline,
    );
  }

  /// Dismiss current toast
  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _DSToastWidget extends StatefulWidget {
  final String message;
  final DSToastType type;
  final DSToastPosition position;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _DSToastWidget({
    required this.message,
    required this.type,
    required this.position,
    this.icon,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<_DSToastWidget> createState() => _DSToastWidgetState();
}

class _DSToastWidgetState extends State<_DSToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DSAnimation.durationMedium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    final slideBegin = widget.position == DSToastPosition.top
        ? const Offset(0, -1)
        : const Offset(0, 1);

    _slideAnimation = Tween<Offset>(
      begin: slideBegin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  Color _getBackgroundColor(DSColorScheme colors) {
    switch (widget.type) {
      case DSToastType.info:
        return colors.surface;
      case DSToastType.success:
        return colors.successBackground;
      case DSToastType.error:
        return colors.errorBackground;
      case DSToastType.warning:
        return colors.warningBackground;
    }
  }

  Color _getForegroundColor(DSColorScheme colors) {
    switch (widget.type) {
      case DSToastType.info:
        return colors.textPrimary;
      case DSToastType.success:
        return colors.success;
      case DSToastType.error:
        return colors.error;
      case DSToastType.warning:
        return colors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final shadows = context.shadows;
    final mediaQuery = MediaQuery.of(context);

    final backgroundColor = _getBackgroundColor(colors);
    final foregroundColor = _getForegroundColor(colors);

    return Positioned(
      top: widget.position == DSToastPosition.top
          ? mediaQuery.padding.top + DSSpacing.md
          : null,
      bottom: widget.position == DSToastPosition.bottom
          ? mediaQuery.padding.bottom + DSSpacing.xxl
          : null,
      left: DSSpacing.pageHorizontal,
      right: DSSpacing.pageHorizontal,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: widget.onTap,
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null) {
                final isSwipingAway = (widget.position == DSToastPosition.top &&
                        details.primaryVelocity! < 0) ||
                    (widget.position == DSToastPosition.bottom &&
                        details.primaryVelocity! > 0);
                if (isSwipingAway) {
                  _dismiss();
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md,
                vertical: DSSpacing.sm + 4,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(DSRadius.md),
                boxShadow: shadows.toast,
                border: widget.type == DSToastType.info
                    ? Border.all(color: colors.border, width: 1)
                    : null,
              ),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: foregroundColor,
                      size: 20,
                    ),
                    const SizedBox(width: DSSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      widget.message,
                      style: typography.bodyMedium.copyWith(
                        color: widget.type == DSToastType.info
                            ? colors.textPrimary
                            : foregroundColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Snackbar-style toast with action
///
/// Usage:
/// ```dart
/// DSSnackbar.show(
///   context: context,
///   message: '항목이 삭제되었습니다',
///   action: DSSnackbarAction(
///     label: '실행 취소',
///     onPressed: () => undoDelete(),
///   ),
/// )
/// ```
class DSSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    DSSnackbarAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    final colors = DSColorScheme(Theme.of(context).brightness);
    final typography = const DSTypographyScheme();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: typography.bodyMedium.copyWith(
            color: colors.textPrimary,
          ),
        ),
        backgroundColor: colors.surface,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        margin: const EdgeInsets.all(DSSpacing.md),
        action: action != null
            ? SnackBarAction(
                label: action.label,
                textColor: colors.accent,
                onPressed: action.onPressed,
              )
            : null,
      ),
    );
  }
}

/// Snackbar action
class DSSnackbarAction {
  final String label;
  final VoidCallback onPressed;

  const DSSnackbarAction({
    required this.label,
    required this.onPressed,
  });
}
