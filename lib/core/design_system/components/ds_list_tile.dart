import 'package:flutter/material.dart';
import '../tokens/ds_spacing.dart';
import '../theme/ds_extensions.dart';
import '../utils/ds_haptics.dart';

/// ChatGPT-inspired list tile component
///
/// Usage:
/// ```dart
/// DSListTile(
///   leading: Icon(Icons.person),
///   title: '프로필 편집',
///   subtitle: '이름, 사진 변경',
///   trailing: DSChevron(),
///   onTap: () {},
/// )
/// ```
class DSListTile extends StatelessWidget {
  /// Leading widget (icon, avatar, etc.)
  final Widget? leading;

  /// Title text
  final String title;

  /// Subtitle text
  final String? subtitle;

  /// Trailing widget (chevron, toggle, badge, etc.)
  final Widget? trailing;

  /// Tap callback
  final VoidCallback? onTap;

  /// Show divider below
  final bool showDivider;

  /// Is this the last item in a group
  final bool isLast;

  /// Content padding
  final EdgeInsetsGeometry? padding;

  /// Enable haptic feedback on tap
  final bool enableHaptic;

  /// Custom title style
  final TextStyle? titleStyle;

  /// Custom subtitle style
  final TextStyle? subtitleStyle;

  const DSListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.isLast = false,
    this.padding,
    this.enableHaptic = true,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final effectivePadding = padding ?? const EdgeInsets.symmetric(
      horizontal: DSSpacing.listItemHorizontal,
      vertical: DSSpacing.listItemVertical,
    );

    Widget content = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        border: (!isLast && showDivider)
            ? Border(
                bottom: BorderSide(
                  color: colors.divider,
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          // Leading
          if (leading != null) ...[
            IconTheme(
              data: IconThemeData(
                color: colors.textSecondary,
                size: 22,
              ),
              child: leading!,
            ),
            const SizedBox(width: DSSpacing.md),
          ],

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: titleStyle ?? typography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: subtitleStyle ?? typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),

          // Trailing
          if (trailing != null) ...[
            const SizedBox(width: DSSpacing.sm),
            trailing!,
          ] else if (onTap != null) ...[
            const SizedBox(width: DSSpacing.sm),
            DSChevron(color: colors.textTertiary),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (enableHaptic) {
              DSHaptics.selection();
            }
            onTap?.call();
          },
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Chevron icon for list tiles
class DSChevron extends StatelessWidget {
  final Color? color;
  final double size;

  const DSChevron({
    super.key,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right,
      size: size,
      color: color ?? context.colors.textTertiary,
    );
  }
}

/// Destructive list tile for delete/logout actions
///
/// Usage:
/// ```dart
/// DSDestructiveListTile(
///   leading: Icon(Icons.logout),
///   title: '로그아웃',
///   onTap: () {},
/// )
/// ```
class DSDestructiveListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool isLast;
  final bool enableHaptic;

  const DSDestructiveListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
    this.showDivider = true,
    this.isLast = false,
    this.enableHaptic = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return DSListTile(
      leading: leading != null
          ? IconTheme(
              data: IconThemeData(color: colors.error),
              child: leading!,
            )
          : null,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      showDivider: showDivider,
      isLast: isLast,
      enableHaptic: enableHaptic,
      titleStyle: typography.bodyMedium.copyWith(
        color: colors.error,
      ),
      trailing: onTap != null ? DSChevron(color: colors.error) : null,
    );
  }
}
