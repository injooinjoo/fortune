import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../glassmorphism/glass_container.dart';
import '../glassmorphism/glass_effects.dart';

enum ToastType { success, error, warning, info }

class Toast {
  static OverlayEntry? _currentToast;

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    // Remove any existing toast
    _currentToast?.remove();
    _currentToast = null;

    final overlay = Overlay.of(context);
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
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
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
        return Colors.green;
      case ToastType.error:
        return Colors.red;
      case ToastType.warning:
        return Colors.orange;
      case ToastType.info:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Positioned(
      top: mediaQuery.padding.top + 16,
      left: 16,
      right: 16,
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
              child: ShimmerGlass(
                shimmerColor: _color,
                borderRadius: BorderRadius.circular(16),
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  blur: 20,
                  boxShadow: GlassEffects.glassShadow(
                    color: _color,
                    elevation: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _icon,
                          color: _color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _dismiss,
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}

class SnackBarHelper {
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.green, Icons.check_circle_rounded);
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.red, Icons.error_rounded);
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.orange, Icons.warning_rounded);
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.blue, Icons.info_rounded);
  }

  static void _showSnackBar(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}