import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/fortune_design_system.dart';
import '../theme/typography_unified.dart';
import '../theme/font_config.dart';
import '../../core/widgets/unified_button.dart';
import '../../core/widgets/unified_button_enums.dart';

/// TOSS 스타일 Dialog
class AppDialog {
  /// 기본 Dialog 표시
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    EdgeInsets? padding,
    bool enableHaptic = true,
  }) {
    if (enableHaptic) {
      HapticFeedback.mediumImpact();
    }

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: (Theme.of(context).brightness == Brightness.light
          ? TossDesignSystem.gray900
          : TossDesignSystem.white).withValues(alpha: 0.5),
      builder: (context) => _AppDialogWrapper(
        padding: padding,
        child: child,
      ),
    );
  }

  /// 확인 Dialog
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = '확인',
    String cancelText = '취소',
    bool isDanger = false,
    bool barrierDismissible = true,
    bool enableHaptic = true,
  }) {
    return show<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      enableHaptic: enableHaptic,
      child: _TossConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDanger: isDanger,
      ),
    );
  }

  /// 알림 Dialog
  static Future<void> showAlert({
    required BuildContext context,
    required String title,
    required String message,
    String actionText = '확인',
    bool enableHaptic = true,
  }) {
    return show<void>(
      context: context,
      barrierDismissible: false,
      enableHaptic: enableHaptic,
      child: _TossAlertDialog(
        title: title,
        message: message,
        actionText: actionText,
      ),
    );
  }

  /// 성공 Dialog
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    String? message,
    String actionText = '확인',
    Duration? autoCloseDuration,
    bool enableHaptic = true,
  }) {
    if (enableHaptic) {
      HapticFeedback.heavyImpact();
    }

    final future = show<void>(
      context: context,
      barrierDismissible: false,
      enableHaptic: false,
      child: _TossSuccessDialog(
        title: title,
        message: message,
        actionText: actionText,
      ),
    );

    if (autoCloseDuration != null) {
      Future.delayed(autoCloseDuration, () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
    }

    return future;
  }

  /// 에러 Dialog
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String actionText = '확인',
    bool enableHaptic = true,
  }) {
    if (enableHaptic) {
      HapticFeedback.heavyImpact();
    }

    return show<void>(
      context: context,
      barrierDismissible: false,
      enableHaptic: false,
      child: _TossErrorDialog(
        title: title,
        message: message,
        actionText: actionText,
      ),
    );
  }

  /// 로딩 Dialog
  static void showLoading({
    required BuildContext context,
    String? message,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: (Theme.of(context).brightness == Brightness.light
          ? TossDesignSystem.gray900
          : TossDesignSystem.white).withValues(alpha: 0.5),
      builder: (context) => _AppLoadingDialog(
        message: message,
      ),
    );
  }

  /// 로딩 Dialog 닫기
  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }
}

/// Dialog Wrapper
class _AppDialogWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const _AppDialogWrapper({
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Material(
          color: theme.brightness == Brightness.light
              ? TossDesignSystem.white
              : TossDesignSystem.grayDark100,
          borderRadius: BorderRadius.circular(TossDesignSystem.radiusL),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(24),
            child: child,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              duration: TossDesignSystem.durationShort,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(duration: TossDesignSystem.durationShort),
      ),
    );
  }
}

/// 확인 Dialog
class _TossConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDanger;

  const _TossConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.isDanger,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: TossDesignSystem.spacingM),
        Text(
          message,
          style: TossDesignSystem.body2.copyWith(
            color: Theme.of(context).brightness == Brightness.light
                ? TossDesignSystem.gray600
                : TossDesignSystem.gray400,
          ),
        ),
        SizedBox(height: TossDesignSystem.spacingL),
        Row(
          children: [
            Expanded(
              child: UnifiedButton(
                text: cancelText,
                onPressed: () => Navigator.of(context).pop(false),
                style: UnifiedButtonStyle.secondary,
                size: UnifiedButtonSize.medium,
              ),
            ),
            SizedBox(width: TossDesignSystem.spacingM),
            Expanded(
              child: UnifiedButton(
                text: confirmText,
                onPressed: () => Navigator.of(context).pop(true),
                style: UnifiedButtonStyle.primary,
                size: UnifiedButtonSize.medium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 알림 Dialog
class _TossAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String actionText;

  const _TossAlertDialog({
    required this.title,
    required this.message,
    required this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: TossDesignSystem.spacingM),
        Text(
          message,
          style: TossDesignSystem.body2.copyWith(
            color: Theme.of(context).brightness == Brightness.light
                ? TossDesignSystem.gray600
                : TossDesignSystem.gray400,
          ),
        ),
        SizedBox(height: TossDesignSystem.spacingL),
        SizedBox(
          width: double.infinity,
          child: UnifiedButton(
            text: actionText,
            onPressed: () => Navigator.of(context).pop(),
            style: UnifiedButtonStyle.primary,
            size: UnifiedButtonSize.medium,
          ),
        ),
      ],
    );
  }
}

/// 성공 Dialog
class _TossSuccessDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String actionText;

  const _TossSuccessDialog({
    required this.title,
    this.message,
    required this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: (Theme.of(context).brightness == Brightness.light
                ? TossDesignSystem.successGreen
                : TossDesignSystem.successGreen).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: 48,
            color: Theme.of(context).brightness == Brightness.light
                ? TossDesignSystem.successGreen
                : TossDesignSystem.successGreen,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: TossDesignSystem.durationLong,
              curve: Curves.elasticOut,
            ),
        SizedBox(height: TossDesignSystem.spacingL),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
        if (message != null) ...[
          SizedBox(height: TossDesignSystem.spacingM),
          Text(
            message!,
            style: TypographyUnified.bodySmall.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                  ? TossDesignSystem.gray600.withValues(alpha: 0.7)
                  : TossDesignSystem.gray600.withValues(alpha: 0.3),
              fontFamily: FontConfig.primary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        SizedBox(height: TossDesignSystem.spacingL),
        SizedBox(
          width: double.infinity,
          child: UnifiedButton(
            text: actionText,
            onPressed: () => Navigator.of(context).pop(),
            style: UnifiedButtonStyle.primary,
            size: UnifiedButtonSize.medium,
          ),
        ),
      ],
    );
  }
}

/// 에러 Dialog
class _TossErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String actionText;

  const _TossErrorDialog({
    required this.title,
    required this.message,
    required this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: (Theme.of(context).brightness == Brightness.light
                ? TossDesignSystem.errorRed
                : TossDesignSystem.errorRed).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).brightness == Brightness.light
                ? TossDesignSystem.errorRed
                : TossDesignSystem.errorRed,
          ),
        )
            .animate()
            .shake(duration: TossDesignSystem.durationMedium, hz: 2, offset: const Offset(4, 0)),
        SizedBox(height: TossDesignSystem.spacingL),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: TossDesignSystem.spacingM),
        Text(
          message,
          style: TossDesignSystem.body2.copyWith(
            color: Theme.of(context).brightness == Brightness.light
                ? TossDesignSystem.gray600
                : TossDesignSystem.gray400,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: TossDesignSystem.spacingL),
        SizedBox(
          width: double.infinity,
          child: UnifiedButton(
            text: actionText,
            onPressed: () => Navigator.of(context).pop(),
            style: UnifiedButtonStyle.primary,
            size: UnifiedButtonSize.medium,
          ),
        ),
      ],
    );
  }
}

/// 로딩 Dialog
class _AppLoadingDialog extends StatelessWidget {
  final String? message;

  const _AppLoadingDialog({
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Container(
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light
              ? TossDesignSystem.white
              : TossDesignSystem.grayDark100,
          borderRadius: BorderRadius.circular(TossDesignSystem.radiusL),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.brightness == Brightness.light
                      ? TossDesignSystem.gray900
                      : TossDesignSystem.white,
                ),
              ),
            ),
            if (message != null) ...[
              SizedBox(height: TossDesignSystem.spacingL),
              Text(
                message!,
                style: TossDesignSystem.body2,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      )
          .animate(
            onPlay: (controller) => controller.repeat(),
          )
          .shimmer(duration: const Duration(milliseconds: 1500)),
    );
  }
}