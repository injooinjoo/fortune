import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/core/utils/haptic_utils.dart';

/// TOSS 스타일 Toast
class AppToast {
  static final List<_ToastEntry> _toasts = [];
  static OverlayEntry? _currentOverlay;

  /// 기본 Toast 표시
  static void show({
    required BuildContext context,
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionText,
    VoidCallback? onAction,
    bool enableHaptic = true,
  }) {
    if (enableHaptic) {
      switch (type) {
        case AppToastType.success:
          HapticUtils.mediumImpact();
          break;
        case AppToastType.error:
          HapticUtils.heavyImpact();
          break;
        case AppToastType.warning:
          HapticUtils.mediumImpact();
          break;
        case AppToastType.info:
          HapticUtils.lightImpact();
          break;
      }
    }

    final entry = _ToastEntry(
      message: message,
      type: type,
      duration: duration,
      actionText: actionText,
      onAction: onAction,
    );

    _toasts.add(entry);
    _showToast(context);
  }

  /// 성공 Toast
  static void success({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
    bool enableHaptic = true,
  }) {
    show(
      context: context,
      message: message,
      type: AppToastType.success,
      duration: duration,
      enableHaptic: enableHaptic,
    );
  }

  /// 에러 Toast
  static void error({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionText,
    VoidCallback? onAction,
    bool enableHaptic = true,
  }) {
    show(
      context: context,
      message: message,
      type: AppToastType.error,
      duration: duration,
      actionText: actionText,
      onAction: onAction,
      enableHaptic: enableHaptic,
    );
  }

  /// 경고 Toast
  static void warning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    bool enableHaptic = true,
  }) {
    show(
      context: context,
      message: message,
      type: AppToastType.warning,
      duration: duration,
      enableHaptic: enableHaptic,
    );
  }

  /// 정보 Toast
  static void info({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    bool enableHaptic = true,
  }) {
    show(
      context: context,
      message: message,
      type: AppToastType.info,
      duration: duration,
      enableHaptic: enableHaptic,
    );
  }

  /// 모든 Toast 제거
  static void clear() {
    _toasts.clear();
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  static void _showToast(BuildContext context) {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
    }

    _currentOverlay = OverlayEntry(
      builder: (context) => _AppToastOverlay(
        entries: List.from(_toasts),
        onRemove: (entry) {
          _toasts.remove(entry);
          if (_toasts.isEmpty) {
            _currentOverlay?.remove();
            _currentOverlay = null;
          }
        },
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }
}

/// Toast Entry
class _ToastEntry {
  final String message;
  final AppToastType type;
  final Duration duration;
  final String? actionText;
  final VoidCallback? onAction;
  final GlobalKey<_AppToastItemState> key = GlobalKey();

  _ToastEntry({
    required this.message,
    required this.type,
    required this.duration,
    this.actionText,
    this.onAction,
  });
}

/// Toast Overlay
class _AppToastOverlay extends StatelessWidget {
  final List<_ToastEntry> entries;
  final Function(_ToastEntry) onRemove;

  const _AppToastOverlay({
    required this.entries,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: DSSpacing.md,
      right: DSSpacing.md,
      bottom: bottomPadding + DSSpacing.lg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: entries
            .asMap()
            .entries
            .map((entry) => Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key < entries.length - 1 ? DSSpacing.sm : 0,
                  ),
                  child: _AppToastItem(
                    key: entry.value.key,
                    entry: entry.value,
                    onRemove: () => onRemove(entry.value),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

/// Toast Item
class _AppToastItem extends StatefulWidget {
  final _ToastEntry entry;
  final VoidCallback onRemove;

  const _AppToastItem({
    super.key,
    required this.entry,
    required this.onRemove,
  });

  @override
  State<_AppToastItem> createState() => _AppToastItemState();
}

class _AppToastItemState extends State<_AppToastItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Auto dismiss
    if (widget.entry.actionText == null) {
      Future.delayed(widget.entry.duration, () {
        if (mounted) {
          _dismiss();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onRemove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final colors = _getColors(isDark);
    final icon = _getIcon();

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.horizontal,
          onDismissed: (_) => widget.onRemove(),
          child: Container(
            decoration: BoxDecoration(
              color: colors.backgroundColor,
              borderRadius: BorderRadius.circular(DSRadius.smd),
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.md,
                  vertical: DSSpacing.md,
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: colors.iconColor,
                    ),
                    const SizedBox(width: DSSpacing.md),
                    Expanded(
                      child: Text(
                        widget.entry.message,
                        style: context.bodySmall.copyWith(
                          color: colors.textColor,
                        ),
                      ),
                    ),
                    if (widget.entry.actionText != null) ...[
                      const SizedBox(width: DSSpacing.md),
                      InkWell(
                        onTap: () {
                          widget.entry.onAction?.call();
                          _dismiss();
                        },
                        borderRadius: BorderRadius.circular(DSRadius.xs),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DSSpacing.sm,
                            vertical: DSSpacing.xs,
                          ),
                          child: Text(
                            widget.entry.actionText!,
                            style: context.labelMedium.copyWith(
                              color: colors.actionColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _ToastColors _getColors(bool isDark) {
    switch (widget.entry.type) {
      case AppToastType.success:
        return _ToastColors(
          backgroundColor: isDark
              ? DSColors.success.withValues(alpha: 0.9)
              : DSColors.success.withValues(alpha: 0.08),
          iconColor: isDark
              ? DSColors.success.withValues(alpha: 0.5)
              : DSColors.success.withValues(alpha: 0.9),
          textColor: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
          actionColor: isDark
              ? DSColors.success.withValues(alpha: 0.5)
              : DSColors.success.withValues(alpha: 0.9),
        );
      case AppToastType.error:
        return _ToastColors(
          backgroundColor: isDark
              ? DSColors.error.withValues(alpha: 0.9)
              : DSColors.error.withValues(alpha: 0.08),
          iconColor: isDark
              ? DSColors.error.withValues(alpha: 0.5)
              : DSColors.error.withValues(alpha: 0.9),
          textColor: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
          actionColor: isDark
              ? DSColors.error.withValues(alpha: 0.5)
              : DSColors.error.withValues(alpha: 0.9),
        );
      case AppToastType.warning:
        return _ToastColors(
          backgroundColor: isDark
              ? DSColors.warning.withValues(alpha: 0.9)
              : DSColors.warning.withValues(alpha: 0.08),
          iconColor: isDark
              ? DSColors.warning.withValues(alpha: 0.5)
              : DSColors.warning.withValues(alpha: 0.9),
          textColor: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
          actionColor: isDark
              ? DSColors.warning.withValues(alpha: 0.5)
              : DSColors.warning.withValues(alpha: 0.9),
        );
      case AppToastType.info:
        return _ToastColors(
          backgroundColor: isDark
              ? DSColors.textTertiaryDark.withValues(alpha: 0.9)
              : DSColors.textTertiaryDark.withValues(alpha: 0.08),
          iconColor: isDark
              ? DSColors.textTertiaryDark.withValues(alpha: 0.5)
              : DSColors.textTertiaryDark.withValues(alpha: 0.9),
          textColor: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
          actionColor: isDark
              ? DSColors.accentDark.withValues(alpha: 0.5)
              : DSColors.accentDark.withValues(alpha: 0.9),
        );
    }
  }

  IconData _getIcon() {
    switch (widget.entry.type) {
      case AppToastType.success:
        return Icons.check_circle_outline;
      case AppToastType.error:
        return Icons.error_outline;
      case AppToastType.warning:
        return Icons.warning_amber_outlined;
      case AppToastType.info:
        return Icons.info_outline;
    }
  }
}

/// Toast 색상
class _ToastColors {
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color actionColor;

  const _ToastColors({
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.actionColor,
  });
}

/// Toast 타입
enum AppToastType {
  success,
  error,
  warning,
  info,
}

/// Screenshot 감지 Toast
class TossScreenshotToast {
  static void show({
    required BuildContext context,
    String message = '운세를 공유하시겠어요?',
    String actionText = '공유하기',
    required VoidCallback onShare,
  }) {
    AppToast.show(
      context: context,
      message: message,
      type: AppToastType.info,
      duration: const Duration(seconds: 5),
      actionText: actionText,
      onAction: onShare,
    );
  }
}

/// 네트워크 상태 Toast
class TossNetworkToast {
  static void showOffline(BuildContext context) {
    AppToast.show(
      context: context,
      message: '네트워크 연결이 끊어졌습니다',
      type: AppToastType.warning,
      duration: const Duration(seconds: 4),
    );
  }

  static void showOnline(BuildContext context) {
    AppToast.show(
      context: context,
      message: '네트워크가 연결되었습니다',
      type: AppToastType.success,
      duration: const Duration(seconds: 2),
    );
  }
}
