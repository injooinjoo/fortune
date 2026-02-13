import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/design_system/design_system.dart';
import '../../core/widgets/unified_button.dart';
import '../../core/widgets/unified_button_enums.dart';
import '../../core/extensions/l10n_extension.dart';

/// TOSS 스타일 Bottom Sheet
class AppBottomSheet {
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
      backgroundColor: Colors.transparent,
      barrierColor: DSColors.overlay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (context) => _AppBottomSheetWrapper(
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
    required List<AppBottomSheetOption<T>> options,
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
    String? confirmText,
    String? cancelText,
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
        confirmText: confirmText ?? context.l10n.confirm,
        cancelText: cancelText ?? context.l10n.cancel,
        isDanger: isDanger,
      ),
    );
  }
}

/// Bottom Sheet Wrapper
class _AppBottomSheetWrapper extends StatelessWidget {
  final Widget child;
  final bool showHandle;
  final double? height;
  final Color? backgroundColor;

  const _AppBottomSheetWrapper({
    required this.child,
    this.showHandle = true,
    this.height,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          Flexible(child: child),
        ],
      ),
    ).animate().slideY(
      begin: 1,
      end: 0,
      duration: DSAnimation.normal,
      curve: Curves.easeOutCubic,
    );
  }
}

/// 선택 Bottom Sheet
class _TossSelectionBottomSheet<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<AppBottomSheetOption<T>> options;

  const _TossSelectionBottomSheet({
    required this.title,
    this.subtitle,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.heading3.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: DSSpacing.sm),
              Text(
                subtitle!,
                style: context.bodySmall.copyWith(
                  color: context.colors.textDisabled,
                ),
              ),
            ],
            const SizedBox(height: DSSpacing.md),
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.heading3.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: DSSpacing.md),
            Text(
              message,
              style: context.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: DSSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: UnifiedButton(
                    text: cancelText,
                    style: UnifiedButtonStyle.secondary,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: UnifiedButton(
                    text: confirmText,
                    style: UnifiedButtonStyle.primary,
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
  final AppBottomSheetOption<T> option;
  final VoidCallback onTap;

  const _OptionItem({
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(DSRadius.smd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: DSSpacing.md,
        ),
        child: Row(
          children: [
            if (option.icon != null) ...[
              Icon(
                option.icon,
                size: 24,
                color: option.isDanger
                    ? DSColors.error
                    : context.colors.textSecondary,
              ),
              const SizedBox(width: DSSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: context.bodyLarge.copyWith(
                      color: option.isDanger
                          ? DSColors.error
                          : context.colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (option.description != null) ...[
                    const SizedBox(height: DSSpacing.xs),
                    Text(
                      option.description!,
                      style: context.bodySmall.copyWith(
                        color: context.colors.textDisabled,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (option.trailing != null) ...[
              const SizedBox(width: DSSpacing.md),
              option.trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Bottom Sheet Option
class AppBottomSheetOption<T> {
  final String label;
  final T value;
  final String? description;
  final IconData? icon;
  final Widget? trailing;
  final bool isDanger;

  const AppBottomSheetOption({
    required this.label,
    required this.value,
    this.description,
    this.icon,
    this.trailing,
    this.isDanger = false,
  });
}