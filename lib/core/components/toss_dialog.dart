import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme_extensions.dart';
import 'toss_button.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';

/// TOSS 스타일 Dialog
class TossDialog {
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
      barrierColor: AppColors.textPrimary.withValues(alpha: context.toss.dialogStyles.barrierOpacity),
      builder: (context) => _TossDialogWrapper(
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
      barrierColor: AppColors.textPrimary.withValues(alpha: context.toss.dialogStyles.barrierOpacity),
      builder: (context) => _TossLoadingDialog(
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
class _TossDialogWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const _TossDialogWrapper({
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: context.toss.dialogStyles.wrapperPadding,
        child: Material(
          color: theme.brightness == Brightness.light
              ? AppColors.textPrimaryDark
              : const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(context.toss.dialogStyles.borderRadius),
          child: Padding(
            padding: padding ?? context.toss.dialogStyles.contentPadding,
            child: child,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              duration: context.toss.dialogStyles.scaleAnimationDuration,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(duration: context.toss.dialogStyles.fadeAnimationDuration),
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
        SizedBox(height: context.toss.dialogStyles.spacing),
        Text(
          message,
          style: TextStyle(
            fontSize: context.toss.dialogStyles.messageFontSize,
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.textSecondary.withOpacity(0.7)
                : AppColors.textSecondary.withOpacity(0.3),
            fontFamily: 'TossProductSans',
            height: 1.5,
          ),
        ),
        SizedBox(height: context.toss.dialogStyles.largeSpacing),
        Row(
          children: [
            Expanded(
              child: TossButton(
                text: cancelText,
                onPressed: () => Navigator.of(context).pop(false),
                style: TossButtonStyle.secondary,
                size: TossButtonSize.medium,
              ),
            ),
            SizedBox(width: context.toss.dialogStyles.spacing),
            Expanded(
              child: TossButton(
                text: confirmText,
                onPressed: () => Navigator.of(context).pop(true),
                style: isDanger
                    ? TossButtonStyle.danger
                    : TossButtonStyle.primary,
                size: TossButtonSize.medium,
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
        SizedBox(height: context.toss.dialogStyles.spacing),
        Text(
          message,
          style: TextStyle(
            fontSize: context.toss.dialogStyles.messageFontSize,
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.textSecondary.withOpacity(0.7)
                : AppColors.textSecondary.withOpacity(0.3),
            fontFamily: 'TossProductSans',
            height: 1.5,
          ),
        ),
        SizedBox(height: context.toss.dialogStyles.largeSpacing),
        SizedBox(
          width: double.infinity,
          child: TossButton(
            text: actionText,
            onPressed: () => Navigator.of(context).pop(),
            style: TossButtonStyle.primary,
            size: TossButtonSize.medium,
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
          width: context.toss.dialogStyles.iconContainerSize,
          height: context.toss.dialogStyles.iconContainerSize,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: context.toss.dialogStyles.iconSize,
            color: AppColors.success,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: context.toss.animationDurations.long,
              curve: Curves.elasticOut,
            ),
        SizedBox(height: context.toss.dialogStyles.largeSpacing),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
        if (message != null) ...[
          SizedBox(height: context.toss.dialogStyles.spacing),
          Text(
            message!,
            style: TextStyle(
              fontSize: context.toss.dialogStyles.messageFontSize,
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.textSecondary.withOpacity(0.7)
                  : AppColors.textSecondary.withOpacity(0.3),
              fontFamily: 'TossProductSans',
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        SizedBox(height: context.toss.dialogStyles.largeSpacing),
        SizedBox(
          width: double.infinity,
          child: TossButton(
            text: actionText,
            onPressed: () => Navigator.of(context).pop(),
            style: TossButtonStyle.primary,
            size: TossButtonSize.medium,
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
          width: context.toss.dialogStyles.iconContainerSize,
          height: context.toss.dialogStyles.iconContainerSize,
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline,
            size: context.toss.dialogStyles.iconSize,
            color: AppColors.error,
          ),
        )
            .animate()
            .shake(duration: context.toss.dialogStyles.shakeAnimationDuration, hz: 2, offset: const Offset(4, 0)),
        SizedBox(height: context.toss.dialogStyles.largeSpacing),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.toss.dialogStyles.spacing),
        Text(
          message,
          style: TextStyle(
            fontSize: context.toss.dialogStyles.messageFontSize,
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.textSecondary.withOpacity(0.7)
                : AppColors.textSecondary.withOpacity(0.3),
            fontFamily: 'TossProductSans',
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.toss.dialogStyles.largeSpacing),
        SizedBox(
          width: double.infinity,
          child: TossButton(
            text: actionText,
            onPressed: () => Navigator.of(context).pop(),
            style: TossButtonStyle.primary,
            size: TossButtonSize.medium,
          ),
        ),
      ],
    );
  }
}

/// 로딩 Dialog
class _TossLoadingDialog extends StatelessWidget {
  final String? message;

  const _TossLoadingDialog({
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Container(
        padding: EdgeInsets.all(context.toss.dialogStyles.largeSpacing + context.toss.dialogStyles.spacing / 2),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light
              ? AppColors.textPrimaryDark
              : const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(context.toss.dialogStyles.borderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: context.toss.dialogStyles.loadingSize,
              height: context.toss.dialogStyles.loadingSize,
              child: CircularProgressIndicator(
                strokeWidth: context.toss.dialogStyles.loadingStrokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.brightness == Brightness.light
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryDark,
                ),
              ),
            ),
            if (message != null) ...[
              SizedBox(height: context.toss.dialogStyles.largeSpacing),
              Text(
                message!,
                style: TextStyle(
                  fontSize: context.toss.dialogStyles.messageFontSize,
                  fontFamily: 'TossProductSans',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      )
          .animate(
            onPlay: (controller) => controller.repeat(),
          )
          .shimmer(duration: context.toss.dialogStyles.shimmerDuration),
    );
  }
}