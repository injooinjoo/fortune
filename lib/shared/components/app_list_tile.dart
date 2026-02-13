import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

/// Korean Traditional style list tile
/// Supports icon, title, subtitle, and trailing widget
class AppListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;
  final bool isEnabled;
  final Color? backgroundColor;

  const AppListTile({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.showDivider = false,
    this.isEnabled = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final Widget content = Container(
      color: backgroundColor ?? colors.surface,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled
                  ? () {
                      if (onTap != null) {
                        DSHaptics.light();
                        onTap!();
                      }
                    }
                  : null,
              splashColor: colors.accentSecondary.withValues(alpha: 0.1),
              highlightColor: colors.accentSecondary.withValues(alpha: 0.05),
              child: Padding(
                padding: padding ??
                    const EdgeInsets.symmetric(
                      horizontal: DSSpacing.lg,
                      vertical: DSSpacing.md,
                    ),
                child: Row(
                  children: [
                    if (leading != null) ...[
                      _buildLeading(context),
                      const SizedBox(width: DSSpacing.md),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: typography.bodyMedium.copyWith(
                              color: isEnabled
                                  ? colors.textPrimary
                                  : colors.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: DSSpacing.xxs),
                            Text(
                              subtitle!,
                              style: typography.bodySmall.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: DSSpacing.md),
                      trailing!,
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: colors.divider,
              indent: leading != null
                  ? DSSpacing.lg + 40 + DSSpacing.md
                  : DSSpacing.lg,
              endIndent: DSSpacing.lg,
            ),
        ],
      ),
    );

    return content;
  }

  Widget _buildLeading(BuildContext context) {
    final colors = context.colors;

    if (leading is Icon) {
      final icon = leading as Icon;
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        child: Icon(
          icon.icon,
          color: icon.color ?? colors.textSecondary,
          size: 20,
        ),
      );
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: leading,
    );
  }
}

/// Korean Traditional style section header
class TossListSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  const TossListSection({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      color: colors.backgroundSecondary,
      padding: padding ??
          const EdgeInsets.fromLTRB(
            DSSpacing.lg,
            DSSpacing.md,
            DSSpacing.lg,
            DSSpacing.sm,
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.labelSmall.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: DSSpacing.xxs),
                  Text(
                    subtitle!,
                    style: typography.labelSmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Korean Traditional style complex list tile
class TossComplexListTile extends StatelessWidget {
  final Widget? icon;
  final String title;
  final String? subtitle;
  final String? value;
  final String? valueLabel;
  final Color? valueColor;
  final Widget? badge;
  final VoidCallback? onTap;
  final bool showArrow;

  const TossComplexListTile({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.value,
    this.valueLabel,
    this.valueColor,
    this.badge,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Material(
      color: colors.surface,
      child: InkWell(
        onTap: onTap != null
            ? () {
                DSHaptics.light();
                onTap!();
              }
            : null,
        splashColor: colors.accentSecondary.withValues(alpha: 0.1),
        highlightColor: colors.accentSecondary.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: DSSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: typography.bodyMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: DSSpacing.xs),
                          badge!,
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: DSSpacing.xxs),
                      Text(
                        subtitle!,
                        style: typography.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (value != null || valueLabel != null) ...[
                const SizedBox(width: DSSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (value != null)
                      Text(
                        value!,
                        style: value!.contains(RegExp(r'\d'))
                            ? typography.numberMedium.copyWith(
                                color: valueColor ?? colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              )
                            : typography.bodyMedium.copyWith(
                                color: valueColor ?? colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                      ),
                    if (valueLabel != null) ...[
                      const SizedBox(height: DSSpacing.xxs),
                      Text(
                        valueLabel!,
                        style: typography.labelSmall.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              if (showArrow && onTap != null) ...[
                const SizedBox(width: DSSpacing.sm),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: colors.textTertiary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Korean Traditional style badge (seal-like design)
class TossBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const TossBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.xs),
      ),
      child: Text(
        text,
        style: typography.labelSmall.copyWith(
          color: textColor ?? colors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
