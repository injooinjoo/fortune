import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

/// TOSS 스타일 Bottom Sheet
class TossBottomSheet {
  /// 기본 Bottom Sheet 표시
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showHandle = true,
    double? height,
    bool isScrollControlled = false,
    Color? backgroundColor,
    bool enableHaptic = true,
  }) {
    if (enableHaptic) {
      HapticPatterns.execute(context.toss.hapticPatterns.success);
    }

    final tossTheme = context.toss;
    final bottomSheetStyles = tossTheme.bottomSheetStyles;
    
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.textPrimary.withValues(alpha: bottomSheetStyles.barrierOpacity),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(bottomSheetStyles.borderRadius),
        ),
      ),
      builder: (context) => _TossBottomSheetWrapper(
        showHandle: showHandle,
        height: height,
        backgroundColor: backgroundColor,
        child: builder(context),
      )
    );
  }

  /// 선택 Bottom Sheet
  static Future<T?> showSelection<T>({
    required BuildContext context,
    required String title,
    required List<TossBottomSheetOption<T>> options,
    String? subtitle,
    bool showHandle = true,
    bool enableHaptic = true,
  }) {
    return show<T>(
      context: context,
      enableHaptic: enableHaptic,
      showHandle: showHandle,
      builder: (context) => _TossSelectionBottomSheet<T>(
        title: title,
        subtitle: subtitle,
        options: options,
      )
    );
  }

  /// 확인 Bottom Sheet
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = '확인',
    String cancelText = '취소',
    bool isDanger = false,
    bool showHandle = true,
    bool enableHaptic = true,
  }) {
    return show<bool>(
      context: context,
      enableHaptic: enableHaptic,
      showHandle: showHandle,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => _TossConfirmationBottomSheet(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDanger: isDanger,
      )
    );
  }

  /// 정보 Bottom Sheet
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
    Widget? content,
    bool showHandle = true,
    bool enableHaptic = true,
  }) {
    return show<void>(
      context: context,
      enableHaptic: enableHaptic,
      showHandle: showHandle,
      builder: (context) => _TossInfoBottomSheet(
        title: title,
        message: message,
        actionText: actionText,
        onAction: onAction,
        content: content,
      )
    );
  }
}

/// Bottom Sheet Wrapper
class _TossBottomSheetWrapper extends StatelessWidget {
  final Widget child;
  final bool showHandle;
  final double? height;
  final Color? backgroundColor;

  const _TossBottomSheetWrapper({
    required this.child,
    required this.showHandle,
    this.height,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final tossTheme = context.toss;
    final bottomSheetStyles = tossTheme.bottomSheetStyles;
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.toss.cardSurface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(bottomSheetStyles.borderRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle);
            Container(
              margin: EdgeInsets.only(top: AppSpacing.spacing2),
              width: bottomSheetStyles.handleWidth,
              height: bottomSheetStyles.handleHeight,
              decoration: BoxDecoration(
                color: context.toss.dividerColor.withValues(alpha: bottomSheetStyles.handleOpacity),
                borderRadius: BorderRadius.circular(bottomSheetStyles.handleHeight / 2),
              ),
            ),
          Flexible(child: child),
        ],
      ),
    )
        .animate()
        .slideY(
          begin: 1,
          end: 0,
          duration: bottomSheetStyles.slideAnimationDuration,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(duration: bottomSheetStyles.fadeAnimationDuration);
  }
}

/// 선택 Bottom Sheet
class _TossSelectionBottomSheet<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<TossBottomSheetOption<T>> options;

  const _TossSelectionBottomSheet({
    required this.title,
    required this.options,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.toss.bottomSheetStyles.contentPadding.left,
                context.toss.bottomSheetStyles.contentPadding.top,
                context.toss.bottomSheetStyles.contentPadding.right,
                context.toss.bottomSheetStyles.contentPadding.bottom - context.toss.bottomSheetStyles.spacing / 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.spacing2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: context.toss.bottomSheetStyles.subtitleFontSize,
                        color: context.toss.secondaryText,
                        fontFamily: 'TossProductSans',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Divider(height: context.toss.cardStyles.borderWidth, color: context.toss.dividerColor),
            ...options.map((option) => _OptionTile(option: option)),
          ],
        ),
      ),
    );
  }
}

/// 옵션 타일
class _OptionTile<T> extends StatelessWidget {
  final TossBottomSheetOption<T> option;

  const _OptionTile({required this.option});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: option.isEnabled
          ? () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop(option.value);
            }
          : null,
      child: Opacity(
        opacity: option.isEnabled ? 1.0 : 0.4,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.toss.bottomSheetStyles.contentPadding.left,
            vertical: AppSpacing.spacing3,
          ),
          child: Row(
            children: [
              if (option.icon != null) ...[
                Icon(
                  option.icon,
                  size: context.toss.bottomSheetStyles.iconSize,
                  color: option.isDestructive
                      ? AppColors.error
                      : (theme.brightness == Brightness.light
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryDark),
                ),
                SizedBox(width: AppSpacing.spacing3),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: option.isDestructive
                            ? AppColors.error
                            : (theme.brightness == Brightness.light
                                ? AppColors.textPrimary
                                : AppColors.textPrimaryDark),
                        fontFamily: 'TossProductSans',
                      ),
                    ),
                    if (option.subtitle != null) ...[
                      SizedBox(height: AppSpacing.spacing1),
                      Text(
                        option.subtitle!,
                        style: TextStyle(
                          fontSize: context.toss.bottomSheetStyles.subtitleFontSize,
                          color: theme.brightness == Brightness.light
                              ? AppColors.textSecondary.withValues(alpha: 0.6)
                              : AppColors.textSecondary.withValues(alpha: 0.4),
                          fontFamily: 'TossProductSans',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (option.trailing != null)
                option.trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

/// 확인 Bottom Sheet
class _TossConfirmationBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDanger;

  const _TossConfirmationBottomSheet({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.isDanger,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: context.toss.bottomSheetStyles.contentPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: context.toss.bottomSheetStyles.spacing),
            Text(
              message,
              style: TextStyle(
                fontSize: context.toss.bottomSheetStyles.messageFontSize,
                color: context.toss.secondaryText,
                fontFamily: 'TossProductSans',
                height: context.toss.cardStyles.borderWidth * 1.5,
              ),
            ),
            SizedBox(height: context.toss.bottomSheetStyles.largeSpacing),
            Row(
              children: [
                Expanded(
                  child: _TossBottomSheetButton(
                    text: cancelText,
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TossBottomSheetButtonStyle.secondary,
                  ),
                ),
                SizedBox(width: context.toss.bottomSheetStyles.spacing),
                Expanded(
                  child: _TossBottomSheetButton(
                    text: confirmText,
                    onPressed: () => Navigator.of(context).pop(true),
                    style: isDanger
                        ? TossBottomSheetButtonStyle.danger
                        : TossBottomSheetButtonStyle.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 정보 Bottom Sheet
class _TossInfoBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? content;

  const _TossInfoBottomSheet({
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: context.toss.bottomSheetStyles.contentPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: context.toss.bottomSheetStyles.spacing),
            Text(
              message,
              style: TextStyle(
                fontSize: context.toss.bottomSheetStyles.messageFontSize,
                color: context.toss.secondaryText,
                fontFamily: 'TossProductSans',
                height: context.toss.cardStyles.borderWidth * 1.5,
              ),
            ),
            if (content != null) ...[
              SizedBox(height: AppSpacing.spacing5),
              content!,
            ],
            if (actionText != null) ...[
              SizedBox(height: context.toss.bottomSheetStyles.largeSpacing),
              SizedBox(
                width: double.infinity,
                child: _TossBottomSheetButton(
                  text: actionText!,
                  onPressed: () {
                    onAction?.call();
                    Navigator.of(context).pop();
                  },
                  style: TossBottomSheetButtonStyle.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bottom Sheet 버튼
class _TossBottomSheetButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final TossBottomSheetButtonStyle style;

  const _TossBottomSheetButton({
    required this.text,
    required this.onPressed,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    
    switch (style) {
      case TossBottomSheetButtonStyle.primary:
        backgroundColor = context.toss.primaryText;
        textColor = context.isDarkMode ? context.toss.primaryText : AppColors.textPrimaryDark;
        break;
      case TossBottomSheetButtonStyle.secondary:
        backgroundColor = context.toss.glassBackground.withValues(alpha: 0.5);
        textColor = context.toss.primaryText;
        break;
      case TossBottomSheetButtonStyle.danger:
        backgroundColor = context.toss.errorColor;
        textColor = AppColors.textPrimaryDark;
        break;
    }
    
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(context.toss.bottomSheetStyles.buttonBorderRadius),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(context.toss.bottomSheetStyles.buttonBorderRadius),
        child: Container(
          height: context.toss.bottomSheetStyles.buttonHeight,
          alignment: Alignment.center,
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}

/// Bottom Sheet 옵션
class TossBottomSheetOption<T> {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final T value;
  final bool isEnabled;
  final bool isDestructive;

  const TossBottomSheetOption({
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.trailing,
    this.isEnabled = true,
    this.isDestructive = false,
  });
}

/// Bottom Sheet 버튼 스타일
enum TossBottomSheetButtonStyle {
  
  
  primary,
  secondary,
  danger,
  
  
}