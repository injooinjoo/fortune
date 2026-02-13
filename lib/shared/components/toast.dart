import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

enum ToastType { success, error, warning, info }

class Toast {
  static OverlayEntry? _currentToast;

  static void show(BuildContext context,
      {required String message,
      ToastType type = ToastType.info,
      Duration duration = const Duration(seconds: 3),
      VoidCallback? onTap}) {
    // Remove any existing toast
    _currentToast?.remove();
    _currentToast = null;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      // Overlay가 없는 경우 조기 리턴
      return;
    }

    final toast = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        duration: duration,
        onTap: onTap,
        onDismiss: () {
          _currentToast?.remove();
          _currentToast = null;
        },
      ),
    );

    _currentToast = toast;
    overlay.insert(toast);

    // Auto dismiss after duration
    Future.delayed(duration, () {
      if (_currentToast == toast) {
        toast.remove();
        _currentToast = null;
      }
    });
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: ToastType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: ToastType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: ToastType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: ToastType.info);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
    this.onTap,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DSAnimation.durationFast,
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  IconData get _icon {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
      case ToastType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final mediaQuery = MediaQuery.of(context);

    return Positioned(
      top: mediaQuery.padding.top + DSSpacing.md,
      left: DSSpacing.md,
      right: DSSpacing.md,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onTap ?? _dismiss,
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity!.abs() > 100) {
                  _dismiss();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.md,
                  vertical: DSSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: colors.textPrimary.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(DSRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: colors.textPrimary.withValues(alpha: 0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _icon,
                      color: colors.background,
                      size: 20,
                    ),
                    const SizedBox(width: DSSpacing.sm),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: typography.bodyMedium.copyWith(
                          color: colors.background,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SnackBarHelper {
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(context, message, Icons.check_circle_rounded);
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(context, message, Icons.error_rounded);
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackBar(context, message, Icons.warning_rounded);
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(context, message, Icons.info_rounded);
  }

  static void _showSnackBar(
    BuildContext context,
    String message,
    IconData icon,
  ) {
    final colors = context.colors;
    final typography = context.typography;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: colors.background,
              size: 20,
            ),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: typography.bodyMedium.copyWith(
                  color: colors.background,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors.textPrimary.withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        margin: const EdgeInsets.all(DSSpacing.md),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}
