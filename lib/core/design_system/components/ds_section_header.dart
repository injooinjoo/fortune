import 'package:flutter/material.dart';
import '../tokens/ds_spacing.dart';
import '../theme/ds_extensions.dart';

/// ChatGPT-inspired section header (settings style)
///
/// Usage:
/// ```dart
/// DSSectionHeader(title: '계정')  // → "계정" shown as uppercase gray text
///
/// DSSectionHeader(
///   title: '설정',
///   trailing: TextButton(child: Text('편집'), onPressed: () {}),
/// )
/// ```
class DSSectionHeader extends StatelessWidget {
  /// Section title
  final String title;

  /// Whether to uppercase the title (ChatGPT style)
  final bool uppercase;

  /// Trailing widget (edit button, etc.)
  final Widget? trailing;

  /// Padding
  final EdgeInsetsGeometry? padding;

  const DSSectionHeader({
    super.key,
    required this.title,
    this.uppercase = true,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final effectivePadding = padding ?? const EdgeInsets.only(
      left: DSSpacing.pageHorizontal,
      right: DSSpacing.pageHorizontal,
      top: DSSpacing.sectionHeaderTop,
      bottom: DSSpacing.sectionHeaderBottom,
    );

    return Padding(
      padding: effectivePadding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              uppercase ? title.toUpperCase() : title,
              style: typography.labelSmall.copyWith(
                color: colors.textSecondary,
                letterSpacing: uppercase ? 0.5 : 0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Page title header (large heading)
///
/// Usage:
/// ```dart
/// DSPageHeader(title: '설정')
/// ```
class DSPageHeader extends StatelessWidget {
  /// Page title
  final String title;

  /// Subtitle
  final String? subtitle;

  /// Trailing widget
  final Widget? trailing;

  /// Padding
  final EdgeInsetsGeometry? padding;

  const DSPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final effectivePadding = padding ?? const EdgeInsets.symmetric(
      horizontal: DSSpacing.pageHorizontal,
      vertical: DSSpacing.md,
    );

    return Padding(
      padding: effectivePadding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.headingLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    subtitle!,
                    style: typography.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Divider with optional label
///
/// Usage:
/// ```dart
/// DSDivider()  // Simple divider
/// DSDivider(label: '또는')  // Divider with centered label
/// ```
class DSDivider extends StatelessWidget {
  /// Optional label in the middle
  final String? label;

  /// Indent from left
  final double? indent;

  /// Indent from right
  final double? endIndent;

  /// Thickness
  final double thickness;

  const DSDivider({
    super.key,
    this.label,
    this.indent,
    this.endIndent,
    this.thickness = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    if (label != null) {
      return Row(
        children: [
          Expanded(
            child: Divider(
              color: colors.divider,
              thickness: thickness,
              indent: indent ?? DSSpacing.pageHorizontal,
              endIndent: DSSpacing.md,
            ),
          ),
          Text(
            label!,
            style: typography.labelSmall.copyWith(
              color: colors.textTertiary,
            ),
          ),
          Expanded(
            child: Divider(
              color: colors.divider,
              thickness: thickness,
              indent: DSSpacing.md,
              endIndent: endIndent ?? DSSpacing.pageHorizontal,
            ),
          ),
        ],
      );
    }

    return Divider(
      color: colors.divider,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
