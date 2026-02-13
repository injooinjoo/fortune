import 'package:flutter/material.dart';
import '../tokens/ds_colors.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../theme/ds_extensions.dart';

/// ChatGPT-inspired bottom sheet
///
/// Usage:
/// ```dart
/// DSBottomSheet.show(
///   context: context,
///   showHandle: true,
///   child: YourContent(),
/// )
/// ```
class DSBottomSheet extends StatelessWidget {
  /// Bottom sheet content
  final Widget child;

  /// Show drag handle
  final bool showHandle;

  /// Show close button
  final bool showClose;

  /// Title
  final String? title;

  /// Content padding
  final EdgeInsetsGeometry? padding;

  /// Maximum height factor (0.0 to 1.0)
  final double maxHeightFactor;

  /// Is scrollable
  final bool isScrollable;

  const DSBottomSheet({
    super.key,
    required this.child,
    this.showHandle = true,
    this.showClose = false,
    this.title,
    this.padding,
    this.maxHeightFactor = 0.9,
    this.isScrollable = false,
  });

  /// Show modal bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool showHandle = true,
    bool showClose = false,
    String? title,
    EdgeInsetsGeometry? padding,
    double maxHeightFactor = 0.9,
    bool isScrollable = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool useRootNavigator = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useRootNavigator: useRootNavigator,
      backgroundColor: Colors.transparent,
      barrierColor: DSColors.overlay,
      builder: (context) => DSBottomSheet(
        showHandle: showHandle,
        showClose: showClose,
        title: title,
        padding: padding,
        maxHeightFactor: maxHeightFactor,
        isScrollable: isScrollable,
        child: child,
      ),
    );
  }

  /// Show action sheet style bottom sheet
  static Future<int?> showActions({
    required BuildContext context,
    String? title,
    required List<DSBottomSheetAction> actions,
    String cancelText = '취소',
    bool showCancel = true,
  }) {
    return show<int>(
      context: context,
      showHandle: false,
      child: _ActionSheetContent(
        title: title,
        actions: actions,
        cancelText: cancelText,
        showCancel: showCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final mediaQuery = MediaQuery.of(context);

    Widget content = child;

    if (isScrollable) {
      content = SingleChildScrollView(
        padding: padding ?? const EdgeInsets.all(DSSpacing.bottomSheetPadding),
        child: child,
      );
    } else if (padding != null) {
      content = Padding(
        padding: padding!,
        child: child,
      );
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * maxHeightFactor,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DSRadius.xxl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            if (showHandle)
              Padding(
                padding: const EdgeInsets.only(
                  top: DSSpacing.sm,
                  bottom: DSSpacing.xs,
                ),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

            // Header (title + close)
            if (title != null || showClose)
              Padding(
                padding: EdgeInsets.only(
                  left: DSSpacing.bottomSheetPadding,
                  right:
                      showClose ? DSSpacing.xs : DSSpacing.bottomSheetPadding,
                  top: showHandle ? DSSpacing.xs : DSSpacing.md,
                  bottom: DSSpacing.sm,
                ),
                child: Row(
                  children: [
                    if (title != null)
                      Expanded(
                        child: Text(
                          title!,
                          style: typography.headingSmall.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    if (showClose)
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: colors.textSecondary,
                          size: 24,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                  ],
                ),
              ),

            // Content
            if (isScrollable) Flexible(child: content) else content,
          ],
        ),
      ),
    );
  }
}

/// Action item for action sheet
class DSBottomSheetAction {
  final String title;
  final IconData? icon;
  final bool isDestructive;
  final bool isSelected;

  const DSBottomSheetAction({
    required this.title,
    this.icon,
    this.isDestructive = false,
    this.isSelected = false,
  });
}

class _ActionSheetContent extends StatelessWidget {
  final String? title;
  final List<DSBottomSheetAction> actions;
  final String cancelText;
  final bool showCancel;

  const _ActionSheetContent({
    this.title,
    required this.actions,
    required this.cancelText,
    required this.showCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.bottomSheetPadding,
              vertical: DSSpacing.md,
            ),
            child: Text(
              title!,
              style: typography.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        // Actions
        ...List.generate(actions.length, (index) {
          final action = actions[index];
          final color =
              action.isDestructive ? colors.error : colors.textPrimary;

          return Column(
            children: [
              if (index > 0 || title != null)
                Divider(height: 0.5, color: colors.divider),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.bottomSheetPadding,
                      vertical: DSSpacing.md,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (action.icon != null) ...[
                          Icon(action.icon, color: color, size: 20),
                          const SizedBox(width: DSSpacing.sm),
                        ],
                        Text(
                          action.title,
                          style: typography.bodyLarge.copyWith(
                            color: color,
                            fontWeight: action.isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (action.isSelected) ...[
                          const SizedBox(width: DSSpacing.sm),
                          Icon(Icons.check, color: colors.accent, size: 20),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),

        // Cancel button
        if (showCancel) ...[
          const SizedBox(height: DSSpacing.sm),
          Container(
            width: double.infinity,
            height: 8,
            color: colors.backgroundSecondary,
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.bottomSheetPadding,
                  vertical: DSSpacing.md,
                ),
                child: Center(
                  child: Text(
                    cancelText,
                    style: typography.bodyLarge.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
