import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/toss_design_system.dart';
import '../../shared/components/toss_button.dart';

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
      HapticFeedback.mediumImpact();
    }
    
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: TossDesignSystem.white.withValues(alpha: 0.0),
      barrierColor: TossDesignSystem.black.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TossDesignSystem.radiusXL),
        ),
      ),
      builder: (context) => _TossBottomSheetWrapper(
        showHandle: showHandle,
        height: height,
        backgroundColor: backgroundColor,
        child: builder(context),
      ),
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
      ),
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
      builder: (context) => _TossConfirmationBottomSheet(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDanger: isDanger,
      ),
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
    this.showHandle = true,
    this.height,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TossDesignSystem.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle) ...[
            SizedBox(height: TossDesignSystem.spacingS),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: TossDesignSystem.spacingS),
          ],
          Flexible(child: child),
        ],
      ),
    ).animate().slideY(
      begin: 1,
      end: 0,
      duration: TossDesignSystem.durationMedium,
      curve: Curves.easeOutCubic,
    );
  }
}

/// 선택 Bottom Sheet
class _TossSelectionBottomSheet<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<TossBottomSheetOption<T>> options;

  const _TossSelectionBottomSheet({
    required this.title,
    this.subtitle,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(TossDesignSystem.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TossDesignSystem.heading4.copyWith(
                color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: TossDesignSystem.spacingS),
              Text(
                subtitle!,
                style: TossDesignSystem.body3.copyWith(
                  color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
                ),
              ),
            ],
            SizedBox(height: TossDesignSystem.spacingM),
            ...options.map((option) => _OptionItem(
              option: option,
              onTap: () => Navigator.of(context).pop(option.value),
            )),
          ],
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
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(TossDesignSystem.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TossDesignSystem.heading4.copyWith(
                color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              ),
            ),
            SizedBox(height: TossDesignSystem.spacingM),
            Text(
              message,
              style: TossDesignSystem.body2.copyWith(
                color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
              ),
            ),
            SizedBox(height: TossDesignSystem.spacingL),
            Row(
              children: [
                Expanded(
                  child: TossButton(
                    text: cancelText,
                    style: TossButtonStyle.secondary,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                SizedBox(width: TossDesignSystem.spacingM),
                Expanded(
                  child: TossButton(
                    text: confirmText,
                    style: TossButtonStyle.primary,
                    onPressed: () => Navigator.of(context).pop(true),
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

/// Option Item
class _OptionItem<T> extends StatelessWidget {
  final TossBottomSheetOption<T> option;
  final VoidCallback onTap;

  const _OptionItem({
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(TossDesignSystem.radiusS),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: TossDesignSystem.spacingM,
        ),
        child: Row(
          children: [
            if (option.icon != null) ...[
              Icon(
                option.icon,
                size: 24,
                color: option.isDanger
                    ? TossDesignSystem.errorRed
                    : (isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600),
              ),
              SizedBox(width: TossDesignSystem.spacingM),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TossDesignSystem.body1.copyWith(
                      color: option.isDanger
                          ? TossDesignSystem.errorRed
                          : (isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (option.description != null) ...[
                    SizedBox(height: TossDesignSystem.spacingXS),
                    Text(
                      option.description!,
                      style: TossDesignSystem.body3.copyWith(
                        color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (option.trailing != null) ...[
              SizedBox(width: TossDesignSystem.spacingM),
              option.trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Bottom Sheet Option
class TossBottomSheetOption<T> {
  final String label;
  final T value;
  final String? description;
  final IconData? icon;
  final Widget? trailing;
  final bool isDanger;

  const TossBottomSheetOption({
    required this.label,
    required this.value,
    this.description,
    this.icon,
    this.trailing,
    this.isDanger = false,
  });
}