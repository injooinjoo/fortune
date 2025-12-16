import 'package:flutter/material.dart';
import '../tokens/ds_colors.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../theme/ds_extensions.dart';
import 'ds_button.dart';

/// ChatGPT-inspired modal dialog
///
/// Usage:
/// ```dart
/// DSModal.confirm(
///   context: context,
///   title: '로그아웃',
///   message: '정말 로그아웃 하시겠습니까?',
///   confirmText: '로그아웃',
///   isDestructive: true,
/// )
/// ```
class DSModal extends StatelessWidget {
  /// Modal title
  final String? title;

  /// Modal message
  final String? message;

  /// Custom content
  final Widget? content;

  /// Primary action text
  final String? primaryText;

  /// Secondary action text
  final String? secondaryText;

  /// Primary action callback
  final VoidCallback? onPrimary;

  /// Secondary action callback
  final VoidCallback? onSecondary;

  /// Is primary action destructive
  final bool isDestructive;

  /// Show close button
  final bool showClose;

  /// Is primary action loading
  final bool isPrimaryLoading;

  const DSModal({
    super.key,
    this.title,
    this.message,
    this.content,
    this.primaryText,
    this.secondaryText,
    this.onPrimary,
    this.onSecondary,
    this.isDestructive = false,
    this.showClose = false,
    this.isPrimaryLoading = false,
  });

  /// Show a simple alert modal
  static Future<void> alert({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = '확인',
  }) {
    return showDialog(
      context: context,
      barrierColor: DSColors.overlay,
      builder: (context) => DSModal(
        title: title,
        message: message,
        primaryText: buttonText,
        onPrimary: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show a confirmation modal
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    String? message,
    String confirmText = '확인',
    String cancelText = '취소',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: DSColors.overlay,
      builder: (context) => DSModal(
        title: title,
        message: message,
        primaryText: confirmText,
        secondaryText: cancelText,
        isDestructive: isDestructive,
        onPrimary: () => Navigator.of(context).pop(true),
        onSecondary: () => Navigator.of(context).pop(false),
      ),
    );
  }

  /// Show a custom modal
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: DSColors.overlay,
      barrierDismissible: barrierDismissible,
      builder: (context) => child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final shadows = context.shadows;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSRadius.xl),
      ),
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 320,
          minWidth: 280,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.xl),
          boxShadow: [shadows.modal],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            if (showClose)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: colors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

            // Content
            Padding(
              padding: EdgeInsets.only(
                left: DSSpacing.modalPadding,
                right: DSSpacing.modalPadding,
                top: showClose ? 0 : DSSpacing.modalPadding,
                bottom: DSSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  if (title != null) ...[
                    Text(
                      title!,
                      style: typography.headingSmall.copyWith(
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (message != null || content != null)
                      const SizedBox(height: DSSpacing.sm),
                  ],

                  // Message
                  if (message != null)
                    Text(
                      message!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                  // Custom content
                  if (content != null) content!,
                ],
              ),
            ),

            // Actions
            if (primaryText != null || secondaryText != null) ...[
              const SizedBox(height: DSSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(
                  left: DSSpacing.modalPadding,
                  right: DSSpacing.modalPadding,
                  bottom: DSSpacing.modalPadding,
                ),
                child: Column(
                  children: [
                    if (primaryText != null)
                      DSButton(
                        text: primaryText!,
                        onPressed: onPrimary,
                        style: isDestructive
                            ? DSButtonStyle.destructive
                            : DSButtonStyle.primary,
                        size: DSButtonSize.medium,
                        isLoading: isPrimaryLoading,
                      ),
                    if (secondaryText != null) ...[
                      const SizedBox(height: DSSpacing.sm),
                      DSButton(
                        text: secondaryText!,
                        onPressed: onSecondary,
                        style: DSButtonStyle.ghost,
                        size: DSButtonSize.medium,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Input modal for single input
///
/// Usage:
/// ```dart
/// final result = await DSInputModal.show(
///   context: context,
///   title: '이름 변경',
///   placeholder: '새 이름',
///   initialValue: '홍길동',
/// );
/// ```
class DSInputModal extends StatefulWidget {
  final String title;
  final String? message;
  final String? placeholder;
  final String? initialValue;
  final String confirmText;
  final String cancelText;
  final int? maxLength;

  const DSInputModal({
    super.key,
    required this.title,
    this.message,
    this.placeholder,
    this.initialValue,
    this.confirmText = '확인',
    this.cancelText = '취소',
    this.maxLength,
  });

  static Future<String?> show({
    required BuildContext context,
    required String title,
    String? message,
    String? placeholder,
    String? initialValue,
    String confirmText = '확인',
    String cancelText = '취소',
    int? maxLength,
  }) {
    return showDialog<String>(
      context: context,
      barrierColor: DSColors.overlay,
      builder: (context) => DSInputModal(
        title: title,
        message: message,
        placeholder: placeholder,
        initialValue: initialValue,
        confirmText: confirmText,
        cancelText: cancelText,
        maxLength: maxLength,
      ),
    );
  }

  @override
  State<DSInputModal> createState() => _DSInputModalState();
}

class _DSInputModalState extends State<DSInputModal> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return DSModal(
      title: widget.title,
      message: widget.message,
      content: Padding(
        padding: const EdgeInsets.only(top: DSSpacing.md),
        child: TextField(
          controller: _controller,
          maxLength: widget.maxLength,
          autofocus: true,
          style: typography.bodyMedium.copyWith(
            color: colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: typography.bodyMedium.copyWith(
              color: colors.textTertiary,
            ),
            filled: true,
            fillColor: colors.backgroundTertiary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DSRadius.md),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DSRadius.md),
              borderSide: BorderSide(color: colors.accent, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.sm,
            ),
          ),
        ),
      ),
      primaryText: widget.confirmText,
      secondaryText: widget.cancelText,
      onPrimary: () => Navigator.of(context).pop(_controller.text),
      onSecondary: () => Navigator.of(context).pop(),
    );
  }
}
