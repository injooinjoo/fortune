import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

enum PaperRuntimeButtonVariant {
  primary,
  danger,
  secondary,
  ghost,
}

class PaperRuntimeAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final bool centerTitle;
  final bool showDivider;
  final Color? backgroundColor;
  final String? leadingText;
  final VoidCallback? onLeadingTextTap;

  const PaperRuntimeAppBar({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.centerTitle = true,
    this.showDivider = true,
    this.backgroundColor,
    this.leadingText,
    this.onLeadingTextTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppBar(
      backgroundColor: backgroundColor ?? colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leadingWidth: leadingText != null ? 80 : null,
      leading: leading ??
          (leadingText != null
              ? TextButton(
                  onPressed: onLeadingTextTap ??
                      () => Navigator.of(context).maybePop(),
                  child: Text(
                    leadingText!,
                    style: context.bodyMedium.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : IconButton(
                  tooltip: '뒤로 가기',
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.of(context).maybePop(),
                )),
      title: Text(
        title,
        style: context.heading3.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: trailing != null
          ? [
              Padding(
                padding: const EdgeInsets.only(right: DSSpacing.sm),
                child: trailing,
              ),
            ]
          : null,
      bottom: showDivider
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(
                height: 1,
                thickness: 1,
                color: colors.border.withValues(alpha: 0.72),
              ),
            )
          : null,
    );
  }
}

class PaperRuntimeMenuTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showChevron;
  final bool showDivider;
  final bool destructive;
  final EdgeInsetsGeometry padding;

  const PaperRuntimeMenuTile({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.showChevron = true,
    this.showDivider = false,
    this.destructive = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: DSSpacing.pageHorizontal,
      vertical: DSSpacing.md,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final titleColor = destructive ? colors.error : colors.textPrimary;

    final row = Container(
      padding: padding,
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: colors.border.withValues(alpha: 0.72),
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.bodyLarge.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: context.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (showChevron && onTap != null)
            Icon(
              Icons.chevron_right,
              color: destructive ? colors.error : colors.textTertiary,
            ),
        ],
      ),
    );

    if (onTap == null) {
      return row;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: row,
      ),
    );
  }
}

class PaperRuntimeToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool showDivider;

  const PaperRuntimeToggleTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return PaperRuntimeMenuTile(
      title: title,
      subtitle: subtitle,
      showDivider: showDivider,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
      ),
      showChevron: false,
      onTap: onChanged == null ? null : () => onChanged!(!value),
    );
  }
}

class PaperRuntimeButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expanded;
  final PaperRuntimeButtonVariant variant;

  const PaperRuntimeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expanded = true,
    this.variant = PaperRuntimeButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEnabled = onPressed != null && !isLoading;

    late final Color backgroundColor;
    late final Color foregroundColor;
    late final BorderSide borderSide;

    switch (variant) {
      case PaperRuntimeButtonVariant.primary:
        backgroundColor = isEnabled
            ? colors.textPrimary
            : colors.surface.withValues(alpha: 0.9);
        foregroundColor = isEnabled ? colors.background : colors.textTertiary;
        borderSide = BorderSide.none;
        break;
      case PaperRuntimeButtonVariant.danger:
        backgroundColor =
            isEnabled ? colors.error : colors.surface.withValues(alpha: 0.9);
        foregroundColor = colors.background;
        borderSide = BorderSide.none;
        break;
      case PaperRuntimeButtonVariant.secondary:
        backgroundColor = colors.surface.withValues(alpha: 0.96);
        foregroundColor = isEnabled ? colors.textPrimary : colors.textTertiary;
        borderSide = BorderSide(
          color: colors.border.withValues(alpha: 0.8),
        );
        break;
      case PaperRuntimeButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor =
            isEnabled ? colors.textSecondary : colors.textTertiary;
        borderSide = BorderSide.none;
        break;
    }

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      alignment: Alignment.center,
      height: variant == PaperRuntimeButtonVariant.ghost ? 44 : 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          variant == PaperRuntimeButtonVariant.ghost
              ? DSRadius.md
              : DSRadius.xxl,
        ),
        border: borderSide == BorderSide.none
            ? null
            : Border.fromBorderSide(borderSide),
      ),
      child: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foregroundColor,
              ),
            )
          : Text(
              label,
              style: context.bodyLarge.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
    );

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(DSRadius.xxl),
        onTap: isEnabled ? onPressed : null,
        child: content,
      ),
    );

    if (!expanded) {
      return button;
    }

    return SizedBox(
      width: double.infinity,
      child: button,
    );
  }
}

InputDecoration paperRuntimeInputDecoration(
  BuildContext context, {
  String? hintText,
  Widget? suffixIcon,
  bool enabled = true,
}) {
  final colors = context.colors;

  return InputDecoration(
    hintText: hintText,
    hintStyle: context.bodyMedium.copyWith(
      color: colors.textTertiary,
    ),
    filled: true,
    fillColor: colors.surface.withValues(alpha: enabled ? 0.96 : 0.88),
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: DSSpacing.lg,
      vertical: DSSpacing.md,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DSRadius.xxl),
      borderSide: BorderSide(
        color: colors.border.withValues(alpha: 0.82),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DSRadius.xxl),
      borderSide: BorderSide(
        color: colors.border.withValues(alpha: 0.82),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DSRadius.xxl),
      borderSide: BorderSide(
        color: colors.textPrimary.withValues(alpha: 0.35),
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DSRadius.xxl),
      borderSide: BorderSide(
        color: colors.border.withValues(alpha: 0.6),
      ),
    ),
  );
}
