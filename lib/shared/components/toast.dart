import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';

enum ToastType {
  success, error, warning, info
}

class Toast {
  static OverlayEntry? _currentToast;

  static void show(
    BuildContext context, {
    required String message,
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
    final theme = Theme.of(context);

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
      duration: TossDesignSystem.durationShort,
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

  Color get _color {
    switch (widget.type) {
      case ToastType.success:
        return TossDesignSystem.successGreen;
      case ToastType.error:
        return TossDesignSystem.errorRed;
      case ToastType.warning:
        return TossDesignSystem.warningOrange;
      case ToastType.info:
        return TossDesignSystem.tossBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Positioned(
      top: mediaQuery.padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: TossDesignSystem.transparent,
            child: GestureDetector(
              onTap: widget.onTap ?? _dismiss,
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity!.abs() > 100) {
                  _dismiss();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TossDesignSystem.spacingM,
                  vertical: TossDesignSystem.spacingM,
                ),
                decoration: BoxDecoration(
                  color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray900,
                  borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: TossDesignSystem.gray900.withValues(alpha: 0.2),
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
                      color: TossDesignSystem.white,
                      size: 20,
                    ),
                    const SizedBox(width: TossDesignSystem.spacingS),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: TossDesignSystem.body2.copyWith(
                          color: TossDesignSystem.white,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: TossDesignSystem.white,
              size: 20,
            ),
            const SizedBox(width: TossDesignSystem.spacingS),
            Expanded(
              child: Text(
                message,
                style: TossDesignSystem.body2.copyWith(
                  color: TossDesignSystem.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray900,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
        ),
        margin: const EdgeInsets.all(TossDesignSystem.spacingM),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}