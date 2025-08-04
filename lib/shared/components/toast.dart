import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../glassmorphism/glass_container.dart';
import '../glassmorphism/glass_effects.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_animations.dart';

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
      duration: AppAnimations.durationMedium,
      vsync: this
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
        return AppColors.success;
      case ToastType.error:
        return AppColors.error;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.info:
        return AppColors.primary;
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
                borderRadius: AppDimensions.borderRadiusLarge,
                child: GlassContainer(
        padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing4,
                    vertical: AppSpacing.spacing3,
                  ),
                  borderRadius: AppDimensions.borderRadiusLarge,
                  blur: 20,
                  boxShadow: GlassEffects.glassShadow(
        color: _color,
                    elevation: 8,
                  ),
                  child: Row(
        children: [
                      Container(
                        padding: AppSpacing.paddingAll8,
                        decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.2),
                          borderRadius: AppDimensions.borderRadiusMedium,
                        ),
                        child: Icon(
                          _icon,
                          color: _color,
                          size: AppDimensions.iconSizeMedium,
                        ),
                      ),
                      SizedBox(width: AppSpacing.spacing3),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: AppSpacing.spacing2),
                      IconButton(
                        onPressed: _dismiss,
                        icon: Icon(
                          Icons.close_rounded,
                          size: AppDimensions.iconSizeSmall,
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
    _showSnackBar(context, message, AppColors.success, Icons.check_circle_rounded);
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.error, Icons.error_rounded);
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.warning, Icons.warning_rounded);
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.primary, Icons.info_rounded);
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
            Icon(icon, color: AppColors.textPrimaryDark, size: AppDimensions.iconSizeSmall),
            SizedBox(width: AppSpacing.spacing3),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.textPrimaryDark),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusMedium,
        ),
        margin: AppSpacing.paddingAll16,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}