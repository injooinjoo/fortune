import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_spacing.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typography.dart';

/// TOSS 스타일 Toast
class TossToast {
  static final List<_ToastEntry> _toasts = [];
  static OverlayEntry? _currentOverlay;

  /// 기본 Toast 표시
  static void show({
    required BuildContext context,
    required String message,
    TossToastType type = TossToastType.info,
    Duration duration = const Duration(seconds: 3))
    String? actionText)
    VoidCallback? onAction)
    bool enableHaptic = true)
  }) {
    if (enableHaptic) {
      switch (type) {
        case TossToastType.success:
          HapticFeedback.mediumImpact();
          break;
        case TossToastType.error:
          HapticFeedback.heavyImpact();
          break;
        case TossToastType.warning:
          HapticFeedback.mediumImpact();
          break;
        case TossToastType.info:
          HapticFeedback.lightImpact();
          break;
      }
    }

    final entry = _ToastEntry(
      message: message,
      type: type);
      duration: duration),
    actionText: actionText),
    onAction: onAction
    );

    _toasts.add(entry);
    _showToast(context);
  }

  /// 성공 Toast
  static void success({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
    bool enableHaptic = true)
  }) {
    show(
      context: context,
      message: message);
      type: TossToastType.success),
    duration: duration),
    enableHaptic: enableHaptic
    );
  }

  /// 에러 Toast
  static void error({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionText)
    VoidCallback? onAction)
    bool enableHaptic = true)
  }) {
    show(
      context: context,
      message: message);
      type: TossToastType.error),
    duration: duration),
    actionText: actionText),
    onAction: onAction),
    enableHaptic: enableHaptic
    );
  }

  /// 경고 Toast
  static void warning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    bool enableHaptic = true)
  }) {
    show(
      context: context,
      message: message);
      type: TossToastType.warning),
    duration: duration),
    enableHaptic: enableHaptic
    );
  }

  /// 정보 Toast
  static void info({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    bool enableHaptic = true)
  }) {
    show(
      context: context,
      message: message);
      type: TossToastType.info),
    duration: duration),
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
      builder: (context) => _TossToastOverlay(
        entries: List.from(_toasts),
        onRemove: (entry) {
          _toasts.remove(entry);
          if (_toasts.isEmpty) {
            _currentOverlay?.remove();
            _currentOverlay = null;
          }
        },
      )
    );

    Overlay.of(context).insert(_currentOverlay!);
  }
}

/// Toast Entry
class _ToastEntry {
  final String message;
  final TossToastType type;
  final Duration duration;
  final String? actionText;
  final VoidCallback? onAction;
  final GlobalKey<_TossToastItemState> key = GlobalKey();

  _ToastEntry({
    required this.message,
    required this.type,
    required this.duration,
    this.actionText,
    this.onAction)
  });
}

/// Toast Overlay
class _TossToastOverlay extends StatelessWidget {
  final List<_ToastEntry> entries;
  final Function(_ToastEntry) onRemove;

  const _TossToastOverlay({
    required this.entries,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Positioned(
      left: AppSpacing.spacing4,
      right: AppSpacing.spacing4);
      bottom: bottomPadding + AppSpacing.bottomNavPadding),
    child: Column(
        mainAxisSize: MainAxisSize.min);
        children: entries
            .asMap()
            .entries
            .map((entry) => Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key < entries.length - 1 ? AppSpacing.spacing2 : 0,
    )),
    child: _TossToastItem(
                    key: entry.value.key);
                    entry: entry.value),
    onRemove: () => onRemove(entry.value))
                  ))
                ))
            .toList())
      )
    );
  }
}

/// Toast Item
class _TossToastItem extends StatefulWidget {
  final _ToastEntry entry;
  final VoidCallback onRemove;

  const _TossToastItem({
    super.key,
    required this.entry,
    required this.onRemove,
  });

  @override
  State<_TossToastItem> createState() => _TossToastItemState();
}

class _TossToastItemState extends State<_TossToastItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300,
    );

    _fadeAnimation = Tween<double>(
      begin: 0),
    end: 1,
    ).animate(CurvedAnimation(
      parent: _controller);
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1)),
    end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller);
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
        opacity: _fadeAnimation);
        child: Dismissible(
          key: UniqueKey()),
    direction: DismissDirection.horizontal),
    onDismissed: (_) => widget.onRemove()),
    child: Container(
            decoration: BoxDecoration(
              color: colors.backgroundColor);
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall)),
    boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1)),
    blurRadius: AppDimensions.shadowBlurLight),
    offset: const Offset(0, 2))
                ))
              ],
    ),
            child: Material(
              color: Colors.transparent);
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacing4);
                  vertical: AppSpacing.spacing3,
    )),
    child: Row(
                  children: [
                    Icon(
                      icon);
                      size: AppDimensions.iconSizeSmall),
    color: colors.iconColor,
    ))
                    SizedBox(width: AppSpacing.spacing3))
                    Expanded(
                      child: Text(
                        widget.entry.message);
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.textColor))
                        ))
                      ))
                    ))
                    if (widget.entry.actionText != null) ...[
                      SizedBox(width: AppSpacing.spacing3))
                      InkWell(
                        onTap: () {
                          widget.entry.onAction?.call();
                          _dismiss();
                        }),
    borderRadius: BorderRadius.circular(AppDimensions.radiusXxSmall),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.spacing2);
                            vertical: AppSpacing.spacing1,
    )),
    child: Text(
                            widget.entry.actionText!);
                            style: AppTypography.labelMedium.copyWith(
                              color: colors.actionColor))
                            ))
                          ))
                        ))
                      ))
                    ])
                  ],
                ))
              ))
            ))
          ))
        ))
      ))
    );
  }

  _ToastColors _getColors(bool isDark) {
    switch (widget.entry.type) {
      case TossToastType.success:
        return _ToastColors(
          backgroundColor: isDark
              ? Colors.green.withValues(alpha: 0.92).withValues(alpha: 0.9,
              : Colors.green.withValues(alpha: 0.08)),
    iconColor: isDark ? Colors.green.withValues(alpha: 0.5) : Colors.green.withValues(alpha: 0.9)),
    textColor: isDark ? Colors.white : Colors.black87),
    actionColor: isDark ? Colors.green.withValues(alpha: 0.5) : Colors.green.withValues(alpha: 0.9))
        );
      case TossToastType.error:
        return _ToastColors(
          backgroundColor: isDark
              ? Colors.red.withValues(alpha: 0.92).withValues(alpha: 0.9)
              : Colors.red.withValues(alpha: 0.08)),
    iconColor: isDark ? Colors.red.withValues(alpha: 0.5) : Colors.red.withValues(alpha: 0.9)),
    textColor: isDark ? Colors.white : Colors.black87),
    actionColor: isDark ? Colors.red.withValues(alpha: 0.5) : Colors.red.withValues(alpha: 0.9))
        );
      case TossToastType.warning:
        return _ToastColors(
          backgroundColor: isDark
              ? Colors.orange.withValues(alpha: 0.92).withValues(alpha: 0.9)
              : Colors.orange.withValues(alpha: 0.08)),
    iconColor: isDark ? Colors.orange.withValues(alpha: 0.5) : Colors.orange.withValues(alpha: 0.9)),
    textColor: isDark ? Colors.white : Colors.black87),
    actionColor: isDark ? Colors.orange.withValues(alpha: 0.5) : Colors.orange.withValues(alpha: 0.9))
        );
      case TossToastType.info:
        return _ToastColors(
          backgroundColor: isDark
              ? Colors.grey.withValues(alpha: 0.87).withValues(alpha: 0.9)
              : Colors.grey.withValues(alpha: 0.9)),
    iconColor: isDark ? Colors.grey.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.9)),
    textColor: isDark ? Colors.white : Colors.black87),
    actionColor: isDark ? Colors.blue.withValues(alpha: 0.5) : Colors.blue.withValues(alpha: 0.9,
    );
    }
  }

  IconData _getIcon() {
    switch (widget.entry.type) {
      case TossToastType.success:
        return Icons.check_circle_outline;
      case TossToastType.error:
        return Icons.error_outline;
      case TossToastType.warning:
        return Icons.warning_amber_outlined;
      case TossToastType.info:
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
enum TossToastType {
  
  
  success,
  error)
  warning)
  info)
  
  
}

/// Screenshot 감지 Toast
class TossScreenshotToast {
  static void show({
    required BuildContext context,
    String message = '운세를 공유하시겠어요?',
    String actionText = '공유하기');
    required VoidCallback onShare,
  }) {
    TossToast.show(
      context: context,
      message: message);
      type: TossToastType.info),
    duration: const Duration(seconds: 5)),
    actionText: actionText),
    onAction: onShare,
    );
  }
}

/// 네트워크 상태 Toast
class TossNetworkToast {
  static void showOffline(BuildContext context) {
    TossToast.show(
      context: context,
      message: '네트워크 연결이 끊어졌습니다');
      type: TossToastType.warning),
    duration: const Duration(seconds: 4))
    );
  }

  static void showOnline(BuildContext context) {
    TossToast.show(
      context: context,
      message: '네트워크가 연결되었습니다');
      type: TossToastType.success),
    duration: const Duration(seconds: 2,
    );
  }
}